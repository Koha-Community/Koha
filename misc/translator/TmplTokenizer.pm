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

sub ALLOW_CFORMAT_P	() {'allow-cformat-p'}

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

sub allow_cformat_p {
    my $this = shift;
    return $this->{+ALLOW_CFORMAT_P};
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

sub set_allow_cformat {
    my $this = shift;
    $this->{+ALLOW_CFORMAT_P} = $_[0];
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
    } elsif ($this->_peek_readahead =~ /^(?:[^<]|<[<\s])*(?:[^<\s])/s) {	# non-space normal text
	($kind, $it) = (TmplTokenType::TEXT, $&);
	$this->_set_readahead( $' );
	warn_normal "Unescaped < in $it\n", $this->line_number_start
		if !$this->cdata_mode_p && $it =~ /</s;
    } else {				# tag/declaration/processing instruction
	my $ok_p = 0;
	for (my $cdata_close = $this->cdata_close;;) {
	    if ($this->cdata_mode_p) {
		my $next = $this->_pop_readahead;
		if ($next =~ /^$cdata_close/) {
		    ($kind, $it) = (TmplTokenType::TAG, $&);
		    $this->_push_readahead( $' );
		    $ok_p = 1;
		} elsif ($next =~ /^((?:(?!$cdata_close).)+)($cdata_close)/) {
		    ($kind, $it) = (TmplTokenType::TEXT, $1);
		    $this->_push_readahead( "$2$'" );
		    $ok_p = 1;
		} else {
		    ($kind, $it) = (TmplTokenType::TEXT, $next);
		    $ok_p = 1;
		}
	    } elsif ($this->_peek_readahead =~ /^$re_tag_compat/os) {
		# If we detect a "closed start tag" but we know that the
		# following token looks like a TMPL_VAR, don't stop
		my($head, $tail, $post) = ($1, $2, $3);
		if ($tail eq '' && $post =~ $re_tmpl_var) {
		    # Don't bother to show the warning if we're too confused
		    warn_normal "Possible SGML \"closed start tag\" notation: $head<\n", $this->line_number
			    if split(/\n/, $head) < 10;
		} else {
		    ($kind, $it) = (TmplTokenType::TAG, "$head>");
		    $this->_set_readahead( $post );
		    $ok_p = 1;
		    warn_normal "SGML \"closed start tag\" notation: $head<\n", $this->line_number if $tail eq '';
		}
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
		warn_normal "Apache #include directive found instead of HTML::Template <TMPL_INCLUDE> directive", $this->line_number_start;
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
    warn_normal "Unrecognizable token found: "
	    . (split(/\n/, $it) < 10? $it: '(too confused to show details)')
	    . "\n", $this->line_number_start
	if $kind == TmplTokenType::UNKNOWN;
    return defined $it? (ref $it? $it: TmplToken->new($it, $kind, $this->line_number, $this->filename)): undef;
}

sub _next_token_intermediate {
    my $this = shift;
    my $h = $this->_handle;
    my $it;
    if (!$this->cdata_mode_p) {
	$it = $this->_next_token_internal($h);
	if (defined $it && $it->type == TmplTokenType::TAG) {
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

sub _token_groupable_p ($) { # groupable into a TEXT_PARAMETRIZED token
    my($t) = @_;
    return $t->type == TmplTokenType::TEXT
	|| ($t->type == TmplTokenType::DIRECTIVE
		&& $t->string =~ /^(?:$re_tmpl_var)$/os)
	|| ($t->type == TmplTokenType::TAG
		&& ($t->string =~ /^<\/?(?:b|em|h[123456]|i|u)\b/is
		|| ($t->string =~ /^<input/i
		    && $t->attributes->{'type'} =~ /^(?:text)$/i)))
}

sub _quote_cformat ($) {
    my($s) = @_;
    $s =~ s/%/%%/g;
    return $s;
}

sub _formalize ($) {
    my($t) = @_;
    return $t->type == TmplTokenType::DIRECTIVE? '%s': _quote_cformat($t->string);
}

sub next_token {
    my $this = shift;
    my $h = $this->_handle;
    my $it;
    $this->{_queue} = [] unless defined $this->{_queue};
    if (@{$this->{_queue}}) {
	$it = pop @{$this->{_queue}};
    } else {
	$it = $this->_next_token_intermediate($h);
	if (!$this->cdata_mode_p && $this->allow_cformat_p && defined $it
	    && ($it->type == TmplTokenType::TEXT?
		!blank_p( $it->string ): _token_groupable_p( $it ))) {
	    my @structure = ( $it );
	    my($n_trailing_spaces, $next) = (0, undef);
	    my($nonblank_text_p, $parametrized_p, $next) = (0, 0);
	    if ($it->type == TmplTokenType::TEXT) {
		$nonblank_text_p = 1 if !blank_p( $it->string );
	    } elsif ($it->type == TmplTokenType::DIRECTIVE) {
		$parametrized_p = 1;
	    }
	    for (my $i = 1, $n_trailing_spaces = 0;; $i += 1) {
		$next = $this->_next_token_intermediate($h);
		push @structure, $next; # for consistency (with initialization)
	    last unless defined $next && _token_groupable_p( $next );
		if ($next->type == TmplTokenType::TEXT) {
		    if (blank_p( $next->string )) {
			$n_trailing_spaces += 1;
		    } else {
			($n_trailing_spaces, $nonblank_text_p) = (0, 1);
		    }
		} elsif ($next->type == TmplTokenType::DIRECTIVE) {
		    $n_trailing_spaces = 0;
		    $parametrized_p = 1;
		} else {
		    $n_trailing_spaces = 0;
		}
	    }
	    # Undo the last token
	    push @{$this->{_queue}}, pop @structure;
	    # Undo trailing blank tokens
	    for (my $i = 0; $i < $n_trailing_spaces; $i += 1) {
		push @{$this->{_queue}}, pop @structure;
	    }
	    if (@structure < 2) {
		# Nothing to do
		;
	    } elsif ($nonblank_text_p && $parametrized_p) {
		# Create the corresponding c-format string
		my $string = join('', map { $_->string } @structure);
		my $form = join('', map { _formalize $_ } @structure);
		$it = TmplToken->new($string, TmplTokenType::TEXT_PARAMETRIZED, $it->line_number, $it->pathname);
		$it->set_form( $form );
		$it->set_children( @structure );
	    } elsif ($nonblank_text_p && $structure[0]->type == TmplTokenType::TEXT && $structure[$#structure]->type == TmplTokenType::TEXT) {
		# Combine the strings
		my $string = join('', map { $_->string } @structure);
		$it = TmplToken->new($string, TmplTokenType::TEXT, $it->line_number, $it->pathname);;
	    } else {
		# Requeue the tokens thus seen for re-emitting
		for (;;) {
		    push @{$this->{_queue}}, pop @structure;
		last if !@structure;
		}
		$it = pop @{$this->{_queue}};
	    }
	}
    }
    return $it;
}

###############################################################################

# Other simple functions (These are not methods)

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

sub quote_po ($) {
    my($s) = @_;
    # Locale::PO->quote is buggy, it doesn't quote newlines :-/
    $s =~ s/([\\"])/\\\1/gs;
    $s =~ s/\n/\\n/g;
    $s =~ s/[\177-\377]/ sprintf("\\%03o", ord($&)) /egs;
    return "\"$s\"";
}

# Some functions that shouldn't be here... should be moved out some time
sub parametrize ($@) {
    my($fmt, @params) = @_;
    my $it = '';
    for (my $n = 0; length $fmt;) {
	if ($fmt =~ /^[^%]+/) {
	    $fmt = $';
	    $it .= $&;
	} elsif ($fmt =~ /^%%/) {
	    $fmt = $';
	    $it .= '%';
	} elsif ($fmt =~ /^%(?:(\d+)\$)?(?:(\d+)(?:\.(\d+))?)?s/) {
	    $n += 1;
	    my($i, $width, $prec) = ((defined $1? $1: $n), $2, $3);
	    $fmt = $';
	    if (!defined $width && !defined $prec) {
		$it .= $params[$i]
	    } elsif (defined $width && defined $prec && !$width && !$prec) {
		;
	    } else {
		die "Unsupported precision specification in format: $&\n"; #XXX
	    }
	} elsif ($fmt =~ /^%[^%a-zA-Z]*[a-zA-Z]/) {
	    $fmt = $';
	    $it .= $&;
	    die "Unknown or unsupported format specification: $&\n"; #XXX
	} else {
	    die "Completely confused parametrizing: $fmt\n";#XXX
	}
    }
    return $it;
}

sub charset_canon ($) {
    my($charset) = @_;
    $charset = uc($charset);
    $charset = "$1-$2" if $charset =~ /^(ISO|UTF)(\d.*)/i;
    $charset = 'Big5' if $charset eq 'BIG5'; # "Big5" must be in mixed case
    return $charset;
}

###############################################################################

=pod

In addition to the basic scanning, this class will also perform
the following:

=over

=item -

Emulation of c-format strings (see below)

=item -

Display of warnings for certain things that affects either the
ability of this class to yield correct output, or things that
are known to cause the original template to cause trouble.

=item -

Automatic correction of some of the things warned about
(e.g., SGML "closed start tag" notation).

=back

=head2 c-format strings emulation

Because English word order is not universal, a simple extraction
of translatable strings may yield some strings like "Accounts for"
or ambiguous strings like "in". This makes the resulting strings
difficult to translate, but does not affect all languages alike.
For example, Chinese (with a somewhat different word order) would
be hit harder, but French would be relatively unaffected.

To overcome this problem, the scanner can be configured to detect
patterns with <TMPL_VAR> directives (as well as certain HTML tags),
and try to construct a larger pattern that will appear in the PO
file as c-format strings with %s placeholders. This additional
step allows the translator to deal with cases where word order
is different (replacing %s with %1$s, %2$s, etc.), or when certain
words will require certain inflectional suffixes in sentences.

Because this is an incompatible change, this mode must be explicitly
turned on using the set_cformat(1) method call.

=head1 HISTORY

This tokenizer is mostly based
on Ambrose's hideous Perl script known as subst.pl.

=cut

1;
