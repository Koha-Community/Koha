package TmplTokenizer;

use strict;
use VerboseWarnings qw( pedantic_p error_normal warn_normal warn_pedantic );
require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

###############################################################################

=head1 NAME

TmplTokenizer.pm - Simple-minded tokenizer for HTML::Template .tmpl files

=head1 DESCRIPTION

Because .tmpl files contains HTML::Template directives
that tend to confuse real parsers (e.g., HTML::Parse),
it might be better to create a customized scanner
to scan the template files for tokens.
This module is a simple-minded attempt at such a scanner.

=head1 HISTORY

This tokenizer is mostly based
on Ambrose's hideous Perl script known as subst.pl.

=cut

###############################################################################

$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT_OK = qw(
    &KIND_TEXT
    &KIND_CDATA
    &KIND_TAG
    &KIND_DECL
    &KIND_PI
    &KIND_DIRECTIVE
    &KIND_COMMENT
    &KIND_UNKNOWN
);

use vars qw( $input );
use vars qw( $debug_dump_only_p );
use vars qw( $pedantic_attribute_error_in_nonpedantic_mode_p );
use vars qw( $pedantic_tmpl_var_use_in_nonpedantic_mode_p );
use vars qw( $fatal_p );

###############################################################################

# Hideous stuff
use vars qw( $re_directive $re_tmpl_var $re_tmpl_var_escaped $re_tmpl_include );
use vars qw( $re_directive_control $re_tmpl_endif_endloop );
BEGIN {
    # $re_directive must not do any backreferences
    $re_directive = q{<(?:(?i)(?:!--\s*)?\/?TMPL_(?:VAR|LOOP|INCLUDE|IF|ELSE|UNLESS)(?:\s+(?:[a-zA-Z][-a-zA-Z0-9]*=)?(?:'[^']*'|"[^"]*"|[^\s<>]+))*\s*(?:--)?)>};
    # TMPL_VAR or TMPL_INCLUDE
    $re_tmpl_var = q{<(?:(?i)(?:!--\s*)?TMPL_(?:VAR)(?:\s+(?:[a-zA-Z][-a-zA-Z0-9]*=)?(?:'[^']*'|"[^"]*"|[^\s<>]+))*\s*(?:--)?)>};
    $re_tmpl_include = q{<(?:(?i)(?:!--\s*)?TMPL_(?:INCLUDE)(?:\s+(?:[a-zA-Z][-a-zA-Z0-9]*=)?(?:'[^']*'|"[^"]*"|[^\s<>]+))*\s*(?:--)?)>};
    # TMPL_VAR ESCAPE=1/HTML/URL
    $re_tmpl_var_escaped = q{<(?:(?i)(?:!--\s*)?TMPL_(?:VAR|INCLUDE)(?:\s+(?:[a-zA-Z][-a-zA-Z0-9]*=)?(?:'[^']*'|"[^"]*"|[^\s<>]+))\s+ESCAPE=(?:1|HTML|URL)(?:\s+(?:[a-zA-Z][-a-zA-Z0-9]*=)?(?:'[^']*'|"[^"]*"|[^\s<>]+))*\s*(?:--)?)>};
    # Any control flow directive
    $re_directive_control = q{<(?:(?i)(?:!--\s*)?\/?TMPL_(?:LOOP|IF|ELSE|UNLESS)(?:\s+(?:[a-zA-Z][-a-zA-Z0-9]*=)?(?:'[^']*'|"[^"]*"|[^\s<>]+))*\s*(?:--)?)>};
    # /LOOP or /IF or /UNLESS
    $re_tmpl_endif_endloop = q{<(?:(?i)(?:!--\s*)?\/TMPL_(?:LOOP|IF|UNLESS)(?:\s+(?:[a-zA-Z][-a-zA-Z0-9]*=)?(?:'[^']*'|"[^"]*"|[^\s<>]+))*\s*(?:--)?)>};
}

# Hideous stuff from subst.pl, slightly modified to use the above hideous stuff
# Note: The $re_tag's set $1 (<tag), $2 (>), and $3 (rest of string)
use vars qw( $re_comment $re_entity_name $re_end_entity $re_etag );
use vars qw( $re_tag_strict $re_tag_compat @re_tag );
sub re_tag ($) {
   my($compat) = @_;
   my $etag = $compat? '>': '<>\/';
   # This is no longer similar to the original regexp in subst.pl :-(
   # Note that we don't want <> in compat mode; Mozilla knows about <
   q{(<\/?(?:|(?:"(?:} . $re_directive . q{|[^"])*"|'(?:} . $re_directive . q{|[^'])*'|--(?:[^-]|-[^-])*--|(?:}
   . $re_directive
   . q{|(?!--)[^"'<>} . $etag . q{]))+))([} . $etag . q{]|(?=<))(.*)};
}
BEGIN {
    $re_comment = '(?:--(?:[^-]|-[^-])*--)';
    $re_entity_name = '(?:[^&%#;<>\s]+)'; # NOTE: not really correct SGML
    $re_end_entity = '(?:;|$|(?=\s))'; # semicolon or before-whitespace
    $re_etag = q{(?:<\/?(?:"[^"]*"|'[^']*'|[^"'>\/])*[>\/])}; # end-tag
    @re_tag = ($re_tag_strict, $re_tag_compat) = (re_tag(0), re_tag(1));
}

# End of the hideous stuff

sub KIND_TEXT      () { 'TEXT' }
sub KIND_CDATA     () { 'CDATA' }
sub KIND_TAG       () { 'TAG' }
sub KIND_DECL      () { 'DECL' }
sub KIND_PI        () { 'PI' }
sub KIND_DIRECTIVE () { 'HTML::Template' }
sub KIND_COMMENT   () { 'COMMENT' }   # empty DECL with exactly one SGML comment
sub KIND_UNKNOWN   () { 'ERROR' }

use vars qw( $readahead $lc_0 $lc $syntaxerror_p );
use vars qw( $cdata_mode_p $cdata_close );

###############################################################################

# Easy accessors

sub fatal_p () {
    return $fatal_p;
}

sub syntaxerror_p () {
    return $syntaxerror_p;
}

###############################################################################

sub extract_attributes ($;$) {
    my($s, $lc) = @_;
    my %attr;
    $s = $1 if $s =~ /^<\S+(.*)\/\S$/s	# XML-style self-closing tags
	    || $s =~ /^<\S+(.*)\S$/s;	# SGML-style tags

    for (my $i = 0; $s =~ /^(?:$re_directive_control)?\s+(?:$re_directive_control)?(?:([a-zA-Z][-a-zA-Z0-9]*)\s*=\s*)?('((?:$re_directive|[^'])*)'|"((?:$re_directive|[^"])*)"|((?:$re_directive|[^\s<>])+))/os;) {
	my($key, $val, $val_orig, $rest)
		= ($1, (defined $3? $3: defined $4? $4: $5), $2, $');
	$i += 1;
	$attr{+lc($key)} = [$key, $val, $val_orig, $i];
	$s = $rest;
	if ($val =~ /$re_tmpl_include/os) {
	    warn_normal "TMPL_INCLUDE in attribute: $val_orig\n", $lc;
	} elsif ($val =~ /$re_tmpl_var/os && $val !~ /$re_tmpl_var_escaped/os) {
	    # XXX: we probably should not warn if key is "onclick" etc
	    # XXX: there's just no reasonable thing to suggest
	    my $suggest = ($key =~ /^(?:action|archive|background|cite|classid|codebase|data|datasrc|for|href|longdesc|profile|src|usemap)$/i? 'URL': 'HTML');
	    undef $suggest if $key =~ /^(?:onblur|onchange|onclick|ondblclick|onfocus|onkeydown|onkeypress|onkeyup|onload|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|onreset|onselect|onsubmit|onunload)$/i;
	    warn_pedantic
		    "Suggest ESCAPE=$suggest for TMPL_VAR in attribute \"$key\""
			. ": $val_orig",
		    $lc, \$pedantic_tmpl_var_use_in_nonpedantic_mode_p
		if defined $suggest && (pedantic_p || !$pedantic_tmpl_var_use_in_nonpedantic_mode_p);
	} elsif ($val_orig !~ /^['"]/) {
	    my $t = $val; $t =~ s/$re_directive_control//os;
	    warn_pedantic
		"Unquoted attribute contains character(s) that should be quoted"
		    . ": $val_orig",
		$lc, \$pedantic_attribute_error_in_nonpedantic_mode_p
		if $t =~ /[^-\.A-Za-z0-9]/s;
	}
    }
    my $s2 = $s; $s2 =~ s/$re_tmpl_endif_endloop//g; # for the next check
    if ($s2 =~ /\S/s) { # should never happen
	if ($s =~ /^([^\n]*)\n/s) { # this is even worse
	    error_normal("Completely confused while extracting attributes: $1", $lc);
	    error_normal((scalar(split(/\n/, $s)) - 1) . " more line(s) not shown.", undef);
	    $fatal_p = 1;
	} else {
	    warn_normal "Strange attribute syntax: $s\n", $lc;
	}
    }
    return \%attr;
}

sub next_token_internal (*) {
    my($h) = @_;
    my($it, $kind);
    my $eof_p = 0;
    if (!defined $readahead || !length $readahead) {
	my $next = scalar <$h>;
	$eof_p = !defined $next;
	if (!$eof_p) {
	    $lc += 1;
	    $readahead .= $next;
	}
    }
    $lc_0 = $lc;			# remember line number of first line
    if ($eof_p && !length $readahead) {	# nothing left to do
	;
    } elsif ($readahead =~ /^\s+/s) {	# whitespace
	($kind, $it, $readahead) = (KIND_TEXT, $&, $');
    # FIXME the following (the [<\s] part) is an unreliable HACK :-(
    } elsif ($readahead =~ /^(?:[^<]|<[<\s])+/s) {	# non-space normal text
	($kind, $it, $readahead) = (KIND_TEXT, $&, $');
	warn_normal "Warning: Unescaped < $it\n", $lc_0
		if !$cdata_mode_p && $it =~ /</s;
    } else {				# tag/declaration/processing instruction
	my $ok_p = 0;
	for (;;) {
	    if ($cdata_mode_p) {
		if ($readahead =~ /^$cdata_close/) {
		    ($kind, $it, $readahead) = (KIND_TAG, $&, $');
		    $ok_p = 1;
		} else {
		    ($kind, $it, $readahead) = (KIND_TEXT, $readahead, undef);
		    $ok_p = 1;
		}
	    } elsif ($readahead =~ /^$re_tag_compat/os) {
		($kind, $it, $readahead) = (KIND_TAG, "$1>", $3);
		$ok_p = 1;
		warn_normal "SGML \"closed start tag\" notation: $1<\n", $lc_0 if $2 eq '';
	    } elsif ($readahead =~ /^<!--(?:(?!-->).)*-->/s) {
		($kind, $it, $readahead) = (KIND_COMMENT, $&, $');
		$ok_p = 1;
		warn_normal "Syntax error in comment: $&\n", $lc_0;
		$syntaxerror_p = 1;
	    }
	last if $ok_p;
	    my $next = scalar <$h>;
	    $eof_p = !defined $next;
	last if $eof_p;
	    $lc += 1;
	    $readahead .= $next;
	}
	if ($kind ne KIND_TAG) {
	    ;
	} elsif ($it =~ /^<!/) {
	    $kind = KIND_DECL;
	    $kind = KIND_COMMENT if $it =~ /^<!--(?:(?!-->).)*-->/;
	} elsif ($it =~ /^<\?/) {
	    $kind = KIND_PI;
	}
	if ($it =~ /^$re_directive/ios && !$cdata_mode_p) {
	    $kind = KIND_DIRECTIVE;
	}
	if (!$ok_p && $eof_p) {
	    ($kind, $it, $readahead) = (KIND_UNKNOWN, $readahead, undef);
	    $syntaxerror_p = 1;
	}
    }
    warn_normal "Unrecognizable token found: $it\n", $lc_0
	    if $kind eq KIND_UNKNOWN;
    return defined $it? (wantarray? ($kind, $it):
				    [$kind, $it]): undef;
}

sub next_token (*) {
    my($h) = @_;
    my $it;
    if (!$cdata_mode_p) {
	$it = next_token_internal($h);
	if (defined $it && $it->[0] eq KIND_TAG) { # FIXME
	    ($cdata_mode_p, $cdata_close) = (1, "</$1\\s*>")
		    if $it->[1] =~ /^<(script|style|textarea)\b/i; #FIXME
	    push @$it, extract_attributes($it->[1], $lc_0); #FIXME
	}
    } else {
	for ($it = '';;) {
	    my $lc_prev = $lc;
	    my $next = next_token_internal($h);
	last if !defined $next;
	    if (defined $next && $next->[1] =~ /$cdata_close/i) { #FIXME
		($lc, $readahead) = ($lc_prev, $next->[1] . $readahead); #FIXME
		$cdata_mode_p = 0;
	    }
	last unless $cdata_mode_p;
	    $it .= $next->[1]; #FIXME
	}
	$it = [KIND_CDATA, $it]; #FIXME
	$cdata_close = undef;
    }
    return defined $it? (wantarray? @$it: $it): undef;
}

###############################################################################

sub trim ($) {
    my($s) = @_;
    $s =~ s/^(?:\s|\&nbsp$re_end_entity)+//os;
    $s =~ s/(?:\s|\&nbsp$re_end_entity)+$//os;
    return $s;
}

###############################################################################

=head1 FUTURE PLANS

Code could be written to detect template variables and
construct gettext-c-format-string-like meta-strings (e.g., "Results %s
through %s of %s records" that will be more likely to be translatable
to languages where word order is very unlike English word order.
This will be relatively major rework, requiring corresponding
rework in tmpl_process.pl

=cut
