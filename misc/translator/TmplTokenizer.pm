package TmplTokenizer;

use strict;
use TmplTokenType;
use TmplToken;
use VerboseWarnings qw( pedantic_p error_normal warn_normal warn_pedantic );
require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

###############################################################################

=head1 NAME

TmplTokenizer.pm - Simple-minded tokenizer class for HTML::Template .tmpl files

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

$VERSION = 0.02;

@ISA = qw(Exporter);
@EXPORT_OK = qw();

use vars qw( $pedantic_attribute_error_in_nonpedantic_mode_p );
use vars qw( $pedantic_tmpl_var_use_in_nonpedantic_mode_p );

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

use vars qw( $serial );

###############################################################################

sub FATAL_P		() {'fatal-p'}
sub SYNTAXERROR_P	() {'syntaxerror-p'}

sub FILENAME		() {'input'}
sub HANDLE		() {'handle'}

sub READAHEAD		() {'readahead'}
sub LINENUM_START	() {'lc_0'}
sub LINENUM		() {'lc'}
sub CDATA_MODE_P	() {'cdata-mode-p'}
sub CDATA_CLOSE		() {'cdata-close'}

sub new {
    my $this = shift;
    my($input) = @_;
    my $class = ref($this) || $this;
    my $self = {};
    bless $self, $class;

    my $handle = sprintf('TMPLTOKENIZER%d', $serial);
    $serial += 1;

    no strict;
    open($handle, "<$input") || die "$input: $!\n";
    use strict;
    $self->{+FILENAME} = $input;
    $self->{+HANDLE} = $handle;
    $self->{+READAHEAD} = [];
    return $self;
}

###############################################################################

# Simple getters

sub filename {
    my $this = shift;
    return $this->{+FILENAME};
}

sub _handle {
    my $this = shift;
    return $this->{+HANDLE};
}

sub fatal_p {
    my $this = shift;
    return $this->{+FATAL_P};
}

sub syntaxerror_p {
    my $this = shift;
    return $this->{+SYNTAXERROR_P};
}

sub has_readahead_p {
    my $this = shift;
    return @{$this->{+READAHEAD}};
}

sub _peek_readahead {
    my $this = shift;
    return $this->{+READAHEAD}->[$#{$this->{+READAHEAD}}];
}

sub line_number_start {
    my $this = shift;
    return $this->{+LINENUM_START};
}

sub line_number {
    my $this = shift;
    return $this->{+LINENUM};
}

sub cdata_mode_p {
    my $this = shift;
    return $this->{+CDATA_MODE_P};
}

sub cdata_close {
    my $this = shift;
    return $this->{+CDATA_CLOSE};
}

# Simple setters

sub _set_fatal {
    my $this = shift;
    $this->{+FATAL_P} = $_[0];
    return $this;
}

sub _set_syntaxerror {
    my $this = shift;
    $this->{+SYNTAXERROR_P} = $_[0];
    return $this;
}

sub _push_readahead {
    my $this = shift;
    push @{$this->{+READAHEAD}}, $_[0];
    return $this;
}

sub _pop_readahead {
    my $this = shift;
    return pop @{$this->{+READAHEAD}};
}

sub _append_readahead {
    my $this = shift;
    $this->{+READAHEAD}->[$#{$this->{+READAHEAD}}] .= $_[0];
    return $this;
}

sub _set_readahead {
    my $this = shift;
    $this->{+READAHEAD}->[$#{$this->{+READAHEAD}}] = $_[0];
    return $this;
}

sub _increment_line_number {
    my $this = shift;
    $this->{+LINENUM} += 1;
    return $this;
}

sub _set_line_number_start {
    my $this = shift;
    $this->{+LINENUM_START} = $_[0];
    return $this;
}

sub _set_cdata_mode {
    my $this = shift;
    $this->{+CDATA_MODE_P} = $_[0];
    return $this;
}

sub _set_cdata_close {
    my $this = shift;
    $this->{+CDATA_CLOSE} = $_[0];
    return $this;
}

###############################################################################

sub _extract_attributes ($;$) {
    my $this = shift;
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
	    $this->_set_fatal( 1 );
	} else {
	    warn_normal "Strange attribute syntax: $s\n", $lc;
	}
    }
    return \%attr;
}

sub _next_token_internal {
    my $this = shift;
    my($h) = @_;
    my($it, $kind);
    my $eof_p = 0;
    $this->_pop_readahead if $this->has_readahead_p
	    && !ref $this->_peek_readahead
	    && !length $this->_peek_readahead;
    if (!$this->has_readahead_p) {
	my $next = scalar <$h>;
	$eof_p = !defined $next;
	if (!$eof_p) {
	    $this->_increment_line_number;
	    $this->_push_readahead( $next );
	}
    }
    $this->_set_line_number_start( $this->line_number ); # remember 1st line num
    if ($this->has_readahead_p && ref $this->_peek_readahead) {	# TmplToken obj.
	($it, $kind) = ($this->_pop_readahead, undef);
    } elsif ($eof_p && !$this->has_readahead_p) {	# nothing left to do
	;
    } elsif ($this->_peek_readahead =~ /^\s+/s) {	# whitespace
	($kind, $it) = (TmplTokenType::TEXT, $&);
	$this->_set_readahead( $' );
    # FIXME the following (the [<\s] part) is an unreliable HACK :-(
    } elsif ($this->_peek_readahead =~ /^(?:[^<]|<[<\s])+/s) {	# non-space normal text
	($kind, $it) = (TmplTokenType::TEXT, $&);
	$this->_set_readahead( $' );
	warn_normal "Unescaped < in $it\n", $this->line_number_start
		if !$this->cdata_mode_p && $it =~ /</s;
    } else {				# tag/declaration/processing instruction
	my $ok_p = 0;
	for (my $cdata_close = $this->cdata_close;;) {
	    if ($this->cdata_mode_p) {
		if ($this->_peek_readahead =~ /^$cdata_close/) {
		    ($kind, $it) = (TmplTokenType::TAG, $&);
		    $this->_set_readahead( $' );
		    $ok_p = 1;
		} else {
		    ($kind, $it) = (TmplTokenType::TEXT, $this->_pop_readahead);
		    $ok_p = 1;
		}
	    } elsif ($this->_peek_readahead =~ /^$re_tag_compat/os) {
		($kind, $it) = (TmplTokenType::TAG, "$1>");
		$this->_set_readahead( $3 );
		$ok_p = 1;
		warn_normal "SGML \"closed start tag\" notation: $1<\n", $this->line_number_start if $2 eq '';
	    } elsif ($this->_peek_readahead =~ /^<!--(?:(?!-->).)*-->/s) {
		($kind, $it) = (TmplTokenType::COMMENT, $&);
		$this->_set_readahead( $' );
		$ok_p = 1;
		warn_normal "Syntax error in comment: $&\n", $this->line_number_start;
		$this->_set_syntaxerror( 1 );
	    }
	last if $ok_p;
	    my $next = scalar <$h>;
	    $eof_p = !defined $next;
	last if $eof_p;
	    $this->_increment_line_number;
	    $this->_append_readahead( $next );
	}
	if ($kind ne TmplTokenType::TAG) {
	    ;
	} elsif ($it =~ /^<!/) {
	    $kind = TmplTokenType::DECL;
	    $kind = TmplTokenType::COMMENT if $it =~ /^<!--(?:(?!-->).)*-->/;
	    if ($kind == TmplTokenType::COMMENT && $it =~ /^<!--\s*#include/s) {
		warn_normal "Apache #include directive found instead of HTML::Template directive <TMPL_INCLUDE>", $this->line_number_start;
	    }
	} elsif ($it =~ /^<\?/) {
	    $kind = TmplTokenType::PI;
	}
	if ($it =~ /^$re_directive/ios && !$this->cdata_mode_p) {
	    $kind = TmplTokenType::DIRECTIVE;
	}
	if (!$ok_p && $eof_p) {
	    ($kind, $it) = (TmplTokenType::UNKNOWN, $this->_peek_readahead);
	    $this->_set_readahead, undef;
	    $this->_set_syntaxerror( 1 );
	}
    }
    warn_normal "Unrecognizable token found: $it\n", $this->line_number_start
	    if $kind eq TmplTokenType::UNKNOWN;
    return defined $it? (ref $it? $it: TmplToken->new($it, $kind, $this->line_number, $this->filename)): undef;
}

sub next_token {
    my $this = shift;
    my $h = $this->_handle;
    my $it;
    if (!$this->cdata_mode_p) {
	$it = $this->_next_token_internal($h);
	if (defined $it && $it->type eq TmplTokenType::TAG) {
	    if ($it->string =~ /^<(script|style|textarea)\b/i) {
		$this->_set_cdata_mode( 1 );
		$this->_set_cdata_close( "</$1\\s*>" );
	    }
	    $it->set_attributes( $this->_extract_attributes($it->string, $it->line_number) );
	}
    } else {
	for ($it = '', my $cdata_close = $this->cdata_close;;) {
	    my $next = $this->_next_token_internal($h);
	last if !defined $next;
	    if (defined $next && $next->string =~ /$cdata_close/i) {
		$this->_push_readahead( $next ); # push entire TmplToken object
		$this->_set_cdata_mode( 0 );
	    }
	last unless $this->cdata_mode_p;
	    $it .= $next->string;
	}
	$it = TmplToken->new( $it, TmplTokenType::CDATA, $this->line_number );
	$this->_set_cdata_close, undef;
    }
    return $it;
}

###############################################################################

# Other easy functions

sub blank_p ($) {
    my($s) = @_;
    return $s =~ /^(?:\s|\&nbsp$re_end_entity|$re_tmpl_var)*$/os;
}

sub trim ($) {
    my($s0) = @_;
    my $l0 = length $s0;
    my $s = $s0;
    $s =~ s/^(\s|\&nbsp$re_end_entity)+//os; my $l1 = $l0 - length $s;
    $s =~ s/(\s|\&nbsp$re_end_entity)+$//os; my $l2 = $l0 - $l1 - length $s;
    return wantarray? (substr($s0, 0, $l1), $s, substr($s0, $l0 - $l2)): $s;
}

###############################################################################

=head1 FUTURE PLANS

Code could be written to detect template variables and
construct gettext-c-format-string-like meta-strings (e.g., "Results %s
through %s of %s records" that will be more likely to be translatable
to languages where word order is very unlike English word order.
This will be relatively major rework, requiring corresponding
rework in tmpl_process.pl

Gettext-style line number references would also be very helpful in
disambiguating the strings. Ultimately, we should generate and work
with gettext-style po files, so that translators are able to use
tools designed for gettext.

An example of a string untranslatable to Chinese is "Accounts for";
"Accounts for %s", however, would be translatable. Short words like
"in" would also be untranslatable, not only to Chinese, but also to
languages requiring declension of nouns.

=cut

1;
