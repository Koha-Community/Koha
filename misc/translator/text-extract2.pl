#!/usr/bin/perl

# Test filter partially based on Ambrose's hideous subst.pl code
# The idea is that the .tmpl files are not valid HTML, and as a result
# HTML::Parse would be completely confused by these templates.
# This is just a simple scanner (not a parser) & should give better results.

# This script is meant to be a drop-in replacement of text-extract.pl

# FIXME: Strings like "<< Prev" or "Next >>" may confuse *this* filter
# TODO: Need to detect unclosed tags, empty tags, and other such stuff.
# (Why? Because Mozilla apparently knows what SGML unclosed tags are :-/ )

# A grander plan: Code could be written to detect template variables and
# construct gettext-c-format-string-like meta-strings (e.g., "Results %s
# through %s of %s records" that will be more likely to be translatable
# to languages where word order is very unlike English word order.
# --> This will be relatively major rework, and requires corresponding
# rework in tmpl_process.pl

use Getopt::Long;
use strict;

use vars qw( $input );
use vars qw( $debug_dump_only_p );
use vars qw( $pedantic_p );
use vars qw( $fatal_p );

###############################################################################

# Hideous stuff
use vars qw( $re_directive );
BEGIN {
    # $re_directive must not do any backreferences
    $re_directive = q{<(?:(?i)(?:!--\s*)?\/?TMPL_(?:VAR|LOOP|INCLUDE|IF|ELSE|UNLESS)(?:\s+(?:[a-zA-Z][-a-zA-Z0-9]*=)?(?:'[^']*'|"[^"]*"|[^\s<>]+))*\s*(?:--)?)>};
}

# Hideous stuff from subst.pl, slightly modified to use the above hideous stuff
# Note: The $re_tag's set $1 (<tag), $2 (>), and $3 (rest of string)
use vars qw( $re_comment $re_entity_name $re_end_entity $re_etag );
use vars qw( $re_tag_strict $re_tag_compat @re_tag );
sub re_tag ($) {
   my($compat) = @_;
   my $etag = $compat? '>': '<>\/';
   # See the file "subst.pl.test1" for how the following mess is derived
   # Unfortunately, inserting $re_directive's has made this even messier
   q{(<\/?(?:|(?:"(?:} . $re_directive . q{|[^"])*"|'(?:} . $re_directive . q{|[^'])*'|--(?:[^-]|-[^-])*--|(?:} . $re_directive . q{|[^-"'} . $etag . q{]|-[^-]))+))([} . $etag . q{])(.*)};
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

sub extract_attributes ($;$) {
    my($s, $lc) = @_;
    my %attr;
    $s = $1 if $s =~ /^<\S+(.*)\/\S$/s	# XML-style self-closing tags
	    || $s =~ /^<\S+(.*)\S$/s;	# SGML-style tags

    for (my $i = 0; $s =~ /^\s+(?:([a-zA-Z][-a-zA-Z0-9]*)\s*=\s*)?('((?:$re_directive|[^'])*)'|"((?:$re_directive|[^"])*)"|(($re_directive|[^\s<>])+))/os;) {
	my($key, $val, $val_orig, $rest)
		= ($1, (defined $3? $3: defined $4? $4: $5), $2, $');
	$i += 1;
	$attr{+lc($key)} = [$key, $val, $val_orig, $i];
	$s = $rest;
	warn "Warning: Attribute should be quoted"
		. (defined $lc? " near line $lc": '') . ": $val_orig\n"
		if $val_orig !~ /^['"]/ && (
			($pedantic_p && $val =~ /[^-\.A-Za-z0-9]/s)
			|| $val =~ /[<>]/s	# this covers $re_directive, too
		    )
    }
    if ($s =~ /\S/s) { # should never happen
	if ($s =~ /^([^\n]*)\n/s) { # this is even worse
	    warn "Error: Completely confused while extracting attributes"
		    . (defined $lc? " near line $lc": '') . ": $1\n";
	    warn "Error: " . (scalar split(/\n/, $s) - 1) . " more line(s) not shown.\n";
	    $fatal_p = 1;
	} else {
	    warn "Warning: Strange attribute syntax"
		    . (defined $lc? " near line $lc": '') . ": $s\n";
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
	warn "Warning: Unescaped < near line $lc_0: $it\n" if $it =~ /</s;
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
		($kind, $it, $readahead) = (KIND_TAG, "$1$2", $3);
		$ok_p = 1;
	    } elsif ($readahead =~ /^<!--(?:(?!-->).)*-->/s) {
		($kind, $it, $readahead) = (KIND_COMMENT, $&, $');
		$ok_p = 1;
		warn "Warning: Syntax error in comment at line $lc_0: $&\n";
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
    warn "Warning: Unrecognizable token found near line $lc_0: $it\n"
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

sub debug_dump (*) { # for testing only
    my($h) = @_;
    print "re_tag_compat is /$re_tag_compat/\n";
    for (;;) {
	my $s = next_token $h;
    last unless defined $s;
	printf "%s\n", ('-' x 79);
	my($kind, $t, $attr) = @$s; # FIXME
	printf "%s:\n", $kind;
	printf "%4dH%s\n", length($t),
		join('', map {/[\0-\37]/? $_: "$_\b$_"} split(//, $t));
	if ($kind eq KIND_TAG && %$attr) {
	    printf "Attributes:\n";
	    for my $a (keys %$attr) {
		my($key, $val, $val_orig, $order) = @{$attr->{$a}};
		printf "%s = %dH%s -- %s\n", $a, length $val,
		join('', map {/[\0-\37]/? $_: "$_\b$_"} split(//, $val)),
		$val_orig;
	    }
	}
    }
}

###############################################################################

sub trim ($) {
    my($s) = @_;
    $s =~ s/^(?:\s|\&nbsp$re_end_entity)+//os;
    $s =~ s/(?:\s|\&nbsp$re_end_entity)+$//os;
    return $s;
}

###############################################################################

sub text_extract (*) {
    my($h) = @_;
    my %text = ();
    for (;;) {
	my $s = next_token $h;
    last unless defined $s;
	my($kind, $t, $attr) = @$s; # FIXME
	if ($kind eq KIND_TEXT) {
	    $t = trim $t;
	    $text{$t} = 1 if $t =~ /\S/s;
	} elsif ($kind eq KIND_TAG && %$attr) {
	    # value [tag=input], meta
	    my $tag = lc($1) if $t =~ /^<(\S+)/s;
	    for my $a ('alt', 'content', 'title', 'value') {
		if ($attr->{$a}) {
		    next if $a eq 'content' && $tag ne 'meta';
		    next if $a eq 'value' && ($tag ne 'input'
			|| (ref $attr->{'type'} && $attr->{'type'}->[1] eq 'hidden')); # FIXME
		    my($key, $val, $val_orig, $order) = @{$attr->{$a}}; #FIXME
		    $val = trim $val;
		    $text{$val} = 1 if $val =~ /\S/s;
		}
	    }
	}
    }
    # Emit all extracted strings. Don't emit pure whitespace or pure numbers.
    for my $t (keys %text) {
	printf "%s\n", $t
	    unless $t =~ /^(?:\s|\&nbsp$re_end_entity)*$/os || $t =~ /^\d+$/;
    }
}

###############################################################################

sub usage ($) {
    my($exitcode) = @_;
    my $h = $exitcode? *STDERR: *STDOUT;
    print $h <<EOF;
Usage: $0 [OPTIONS]
Extract strings from HTML file.

      --debug-dump-only     Do not extract strings; but display scanned tokens
  -f, --file=FILE           Extract from the specified FILE
      --pedantic-warnings   Issue warnings even for detected problems which
			    are likely to be harmless
      --help                Display this help and exit
EOF
    exit($exitcode);
}

###############################################################################

sub usage_error (;$) {
    print STDERR "$_[0]\n" if @_;
    print STDERR "Try `$0 --help' for more information.\n";
    exit(-1);
}

###############################################################################

GetOptions(
    'f|file=s'		=> \$input,
    'debug-dump-only'	=> \$debug_dump_only_p,
    'pedantic-warnings'	=> sub { $pedantic_p = 1 },
    'help'		=> sub { usage(0) },
) || usage_error;
usage_error('Missing mandatory option -f') unless defined $input;

open(INPUT, "<$input") || die "$0: $input: $!\n";
if ($debug_dump_only_p) {
    debug_dump(*INPUT);
} else {
    text_extract(*INPUT);
}

warn "Warning: This input will not work with Mozilla standards-compliant mode\n"
	if $syntaxerror_p;

close INPUT;

exit(-1) if $fatal_p;
