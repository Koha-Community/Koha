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
use vars qw( $pedantic_error_markup_in_pcdata_p );

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
   q{(<\/?(?:|(?:"(?:} . $re_directive . q{|[^"])*"|'(?:} . $re_directive . q{|[^'])*'|--(?:(?!--)(?:$re_directive)*.)*--|(?:}
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
sub PCDATA_MODE_P	() {'pcdata-mode-p'}	# additional submode for CDATA

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

sub pcdata_mode_p {
    my $this = shift;
    return $this->{+PCDATA_MODE_P};
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

sub _set_pcdata_mode {
    my $this = shift;
    $this->{+PCDATA_MODE_P} = $_[0];
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
	    # There's something wrong with the attribute syntax.
	    # We might be able to deduce a likely cause by looking more.
	    if ($s =~ /^[a-z0-9]/is && "<foo $s>" =~ /^$re_tag_compat$/s) {
		warn_normal "Probably missing whitespace before or missing quotation mark near: $s\n", $lc;
	    } else {
		warn_normal "Strange attribute syntax: $s\n", $lc;
	    }
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
	my $bad_comment_p = 0;
	for (my $cdata_close = $this->cdata_close;;) {
	    if ($this->cdata_mode_p) {
		my $next = $this->_pop_readahead;
		if ($next =~ /^$cdata_close/is) {
		    ($kind, $it) = (TmplTokenType::TAG, $&);
		    $this->_push_readahead( $' );
		    $ok_p = 1;
		} elsif ($next =~ /^((?:(?!$cdata_close).)+)($cdata_close)/is) {
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
		    # FIXME. There's no method for _closed_start_tag_warning
		    if (!defined $this->{'_closed_start_tag_warning'}
			|| ($this->{'_closed_start_tag_warning'}->[0] eq $head
			&& $this->{'_closed_start_tag_warning'}->[1] != $this->line_number - 1)) {
		    warn_normal "Possible SGML \"closed start tag\" notation: $head<\n", $this->line_number
			    if split(/\n/, $head) < 10;
		    }
		    $this->{'_closed_start_tag_warning'} = [$head, $this->line_number];
		} else {
		    ($kind, $it) = (TmplTokenType::TAG, "$head>");
		    $this->_set_readahead( $post );
		    $ok_p = 1;
		    warn_normal "SGML \"closed start tag\" notation: $head<\n", $this->line_number if $tail eq '';
		}
	    } elsif ($this->_peek_readahead =~ /^<!--(?:(?!-->)$re_directive*.)*-->/os) {
		($kind, $it) = (TmplTokenType::COMMENT, $&);
		$this->_set_readahead( $' );
		$ok_p = 1;
		$bad_comment_p = 1;
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
	} elsif ($bad_comment_p) {
	    warn_normal sprintf("Syntax error in comment: %s\n", $it),
		    $this->line_number_start;
	    $this->_set_syntaxerror( 1 );
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
	    if ($it->string =~ /^<(script|style|textarea)\b/is) {
		$this->_set_cdata_mode( 1 );
		$this->_set_cdata_close( "</$1\\s*>" );
		$this->_set_pcdata_mode( 0 );
	    } elsif ($it->string =~ /^<(title)\b/is) {
		$this->_set_cdata_mode( 1 );
		$this->_set_cdata_close( "</$1\\s*>" );
		$this->_set_pcdata_mode( 1 );
	    }
	    $it->set_attributes( $this->_extract_attributes($it->string, $it->line_number) );
	}
    } else {
	my $eof_p = 0;
	for ($it = '', my $cdata_close = $this->cdata_close;;) {
	    my $next = $this->_next_token_internal($h);
	    $eof_p = !defined $next;
	last if $eof_p;
	    if (defined $next && $next->string =~ /$cdata_close/is) {
		$this->_push_readahead( $next ); # push entire TmplToken object
		$this->_set_cdata_mode( 0 );
	    }
	last unless $this->cdata_mode_p;
	    $it .= $next->string;
	}
	if ($eof_p) {
	    $it = undef;
	    error_normal "Unexpected end of file while looking for "
		    . $this->cdata_close
		    . "\n", $this->line_number_start;
	    $this->_set_fatal( 1 );
	    $this->_set_syntaxerror( 1 );
	}
	if ($this->pcdata_mode_p) {
	    my $check = $it;
	    $check =~ s/$re_directive//gos;
	    warn_pedantic "Markup found in PCDATA\n", $this->line_number,
			    \$pedantic_error_markup_in_pcdata_p
		    if $check =~ /$re_tag_compat/s;
	}
	$it = TmplToken->new( $it, TmplTokenType::CDATA, $this->line_number )
		if defined $it;
	$this->_set_pcdata_mode, 0;
	$this->_set_cdata_close, undef unless !defined $it;
    }
    return $it;
}

sub _token_groupable1_p ($) { # as first token, groupable into TEXT_PARAMETRIZED
    my($t) = @_;
    return ($t->type == TmplTokenType::TEXT && $t->string !~ /^[,\.:\|\s]+$/is)
	|| ($t->type == TmplTokenType::DIRECTIVE
		&& $t->string =~ /^(?:$re_tmpl_var)$/os)
	|| ($t->type == TmplTokenType::TAG
		&& ($t->string =~ /^<(?:b|em|h[123456]|i|u)\b/is
#		|| ($t->string =~ /^<input\b/is
#		    && $t->attributes->{'type'}->[1] =~ /^(?:radio|text)$/is)
		    ))
}

sub _token_groupable2_p ($) { # as other token, groupable into TEXT_PARAMETRIZED
    my($t) = @_;
    return ($t->type == TmplTokenType::TEXT && ($t->string =~ /^\s*$/s || $t->string !~ /^[\|\s]+$/is))
	|| ($t->type == TmplTokenType::DIRECTIVE
		&& $t->string =~ /^(?:$re_tmpl_var)$/os)
	|| ($t->type == TmplTokenType::TAG
		&& ($t->string =~ /^<\/?(?:a|b|em|h[123456]|i|u)\b/is
		|| ($t->string =~ /^<input\b/is
		    && $t->attributes->{'type'} =~ /^(?:radio|text)$/is)))
}

sub _quote_cformat ($) {
    my($s) = @_;
    $s =~ s/%/%%/g;
    return $s;
}

sub string_canon ($) {
    my($s) = @_;
    if (1) { # FIXME
	# Fold all whitespace into single blanks
	$s =~ s/\s+/ /gs;
    }
    return $s;
}

sub _formalize_string_cformat ($) {
    my($s) = @_;
    return _quote_cformat string_canon $s;
}

sub _formalize ($) {
    my($t) = @_;
    return $t->type == TmplTokenType::DIRECTIVE? '%s':
	   $t->type == TmplTokenType::TEXT?
		   _formalize_string_cformat($t->string):
	   $t->type == TmplTokenType::TAG?
		   ($t->string =~ /^<a\b/is? '<a>':
		    $t->string =~ /^<input\b/is? '<input>':
		    _quote_cformat($t->string)):
	       _quote_cformat($t->string);
}

sub _optimize {
    my $this = shift;
    my @structure = @_;
    my $undo_trailing_blanks = sub {
		for (my $i = $#structure; $i >= 0; $i -= 1) {
		last if $structure[$i]->type != TmplTokenType::TEXT;
		last if !blank_p($structure[$i]->string);
		    push @{$this->{_queue}}, pop @structure;
		}
	    };
    &$undo_trailing_blanks;
    # FIXME: If the last token is a close tag but there are no tags
    # FIXME: before it, drop the close tag back into the queue. This
    # FIXME: is an ugly hack to get rid of "foo %s</h1>" type mess.
    if (@structure >= 2
	    && $structure[$#structure]->type == TmplTokenType::TAG
	    && $structure[$#structure]->string =~ /^<\//s) {
	my $has_other_tags_p = 0;
	for (my $i = 0; $i < $#structure; $i += 1) {
	    $has_other_tags_p = 1 if $structure[$i]->type == TmplTokenType::TAG;
	last if $has_other_tags_p;
	}
	push @{$this->{_queue}}, pop @structure unless $has_other_tags_p;
	&$undo_trailing_blanks;
    }
    # FIXME: Do the same ugly hack for the last token being a ( or [
    if (@structure >= 2
	    && $structure[$#structure]->type == TmplTokenType::TEXT
	    && $structure[$#structure]->string =~ /^[\(\[]$/) { # not )]
	push @{$this->{_queue}}, pop @structure;
	&$undo_trailing_blanks;
    }
    return @structure;
}

sub looks_plausibly_like_groupable_text_p (@) {
    my @structure = @_;
    # The text would look plausibly groupable if all open tags are also closed.
    my @tags = ();
    my $error_p = 0;
    for (my $i = 0; $i <= $#structure; $i += 1) {
	if ($structure[$i]->type == TmplTokenType::TAG) {
	    if ($structure[$i]->string =~ /^<([A-Z0-9]+)/is) {
		my $tag = lc($1);
		push @tags, $tag unless $tag =~ /^<(?:input)/is
			|| $tag =~ /\/>$/is;
	    } elsif ($structure[$i]->string =~ /^<\/([A-Z0-9]+)/is) {
		if (@tags && lc($1) eq $tags[$#tags]) {
		    pop @tags;
		} else {
		    $error_p = 1;
		}
	    }
	} elsif ($structure[$i]->type != TmplTokenType::TEXT) {
	    $error_p = 1;
	}
    last if $error_p;
    }
    return !$error_p && !@tags;
}

sub next_token {
    my $this = shift;
    my $h = $this->_handle;
    my $it;
    $this->{_queue} = [] unless defined $this->{_queue};

    # Don't reparse anything in the queue. We can put a parametrized token
    # there if we need to, however.
    if (@{$this->{_queue}}) {
	$it = pop @{$this->{_queue}};
    } else {
	$it = $this->_next_token_intermediate($h);
	if (!$this->cdata_mode_p && $this->allow_cformat_p && defined $it
	    && ($it->type == TmplTokenType::TEXT?
		!blank_p( $it->string ): _token_groupable1_p( $it ))) {
	    my @structure = ( $it );
	    my @tags = ();
	    my $next = undef;
	    my($nonblank_text_p, $parametrized_p, $with_anchor_p, $with_input_p) = (0, 0, 0, 0);
	    if ($it->type == TmplTokenType::TEXT) {
		$nonblank_text_p = 1 if !blank_p( $it->string );
	    } elsif ($it->type == TmplTokenType::DIRECTIVE) {
		$parametrized_p = 1;
	    } elsif ($it->type == TmplTokenType::TAG && $it->string =~ /^<([A-Z0-9]+)/is) {
		push @tags, lc($1);
		$with_anchor_p = 1 if lc($1) eq 'a';
		$with_input_p = 1 if lc($1) eq 'input';
	    }
	    # We hate | and || in msgid strings, so we try to avoid them
	    for (my $i = 1, my $quit_p = 0, my $quit_next_p = ($it->type == TmplTokenType::TEXT && $it->string =~ /^\|+$/s);; $i += 1) {
		$next = $this->_next_token_intermediate($h);
		push @structure, $next; # for consistency (with initialization)
	    last unless defined $next && _token_groupable2_p( $next );
	    last if $quit_next_p;
		if ($next->type == TmplTokenType::TEXT) {
		    $nonblank_text_p = 1 if !blank_p( $next->string );
		    $quit_p = 1 if $next->string =~ /^\|+$/s; # We hate | and ||
		} elsif ($next->type == TmplTokenType::DIRECTIVE) {
		    $parametrized_p = 1;
		} elsif ($next->type == TmplTokenType::TAG) {
		    if ($next->string =~ /^<([A-Z0-9]+)/is) {
			push @tags, lc($1);
			$with_anchor_p = 1 if lc($1) eq 'a';
			$with_input_p = 1 if lc($1) eq 'input';
		    } elsif ($next->string =~ /^<\/([A-Z0-9]+)/is) {
			my $close = lc($1);
			$quit_p = 1 unless @tags && $close eq $tags[$#tags];
			$quit_next_p = 1 if $close =~ /^h\d$/;
			pop @tags;
		    }
		}
	    last if $quit_p;
	    }
	    # Undo the last token
	    push @{$this->{_queue}}, pop @structure;
	    # Simply it a bit more
	    @structure = $this->_optimize( @structure );
	    if (@structure < 2) {
		# Nothing to do
		;
	    } elsif ($nonblank_text_p && ($parametrized_p || $with_anchor_p || $with_input_p)) {
		# Create the corresponding c-format string
		my $string = join('', map { $_->string } @structure);
		my $form = join('', map { _formalize $_ } @structure);
		my($a_counter, $input_counter) = (0, 0);
		$form =~ s/<a>/ $a_counter += 1, "<a$a_counter>" /egs;
		$form =~ s/<input>/ $input_counter += 1, "<input$input_counter>" /egs;
		$it = TmplToken->new($string, TmplTokenType::TEXT_PARAMETRIZED,
			$it->line_number, $it->pathname);
		$it->set_form( $form );
		$it->set_children( @structure );
	    } elsif ($nonblank_text_p
		    && looks_plausibly_like_groupable_text_p( @structure )
		    && $structure[$#structure]->type == TmplTokenType::TEXT) {
		# Combine the strings
		my $string = join('', map { $_->string } @structure);
		$it = TmplToken->new($string, TmplTokenType::TEXT,
			$it->line_number, $it->pathname);;
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
    if (defined $it && $it->type == TmplTokenType::TEXT) {
	my $form = string_canon $it->string;
	$it->set_form( $form );
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
    #$s =~ s/[\177-\377]/ sprintf("\\%03o", ord($&)) /egs;
    return "\"$s\"";
}

# Some functions that shouldn't be here... should be moved out some time
sub parametrize ($$$) {
    my($fmt_0, $params, $anchors) = @_;
    my $it = '';
    for (my $n = 0, my $fmt = $fmt_0; length $fmt;) {
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
		my $param = $params->[$i - 1];
		$it .= $param;
		warn_normal "$&: Undefined parameter $i for msgid \"$fmt_0\"",
			    undef
			unless defined $param;
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
    for (my $n = 0, my $fmt = $it, $it = ''; length $fmt;) {
	if ($fmt =~ /^(?:(?!<a\d+>).)+/is) {
	    $fmt = $';
	    $it .= $&;
	} elsif ($fmt =~ /^<a(\d+)>/is) {
	    $n += 1;
	    my $i  = $1;
	    $fmt = $';
	    my $anchor = $anchors->[$i - 1];
	    warn_normal "$&: Anchor $1 not found for msgid \"$fmt_0\"", undef #FIXME
		    unless defined $anchor;
	    $it .= $anchor->string;
	} else {
	    die "Completely confused decoding anchors: $fmt\n";#XXX
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

use vars qw( @latin1_utf8 );
@latin1_utf8 = (
    "\302\200", "\302\201", "\302\202", "\302\203", "\302\204", "\302\205",
    "\302\206", "\302\207", "\302\210", "\302\211", "\302\212", "\302\213",
    "\302\214", "\302\215",   undef,      undef,    "\302\220", "\302\221",
    "\302\222", "\302\223", "\302\224", "\302\225", "\302\226", "\302\227",
    "\302\230", "\302\231", "\302\232", "\302\233", "\302\234", "\302\235",
    "\302\236", "\302\237", "\302\240", "\302\241", "\302\242", "\302\243",
    "\302\244", "\302\245", "\302\246", "\302\247", "\302\250", "\302\251",
    "\302\252", "\302\253", "\302\254", "\302\255", "\302\256", "\302\257",
    "\302\260", "\302\261", "\302\262", "\302\263", "\302\264", "\302\265",
    "\302\266", "\302\267", "\302\270", "\302\271", "\302\272", "\302\273",
    "\302\274", "\302\275", "\302\276", "\302\277", "\303\200", "\303\201",
    "\303\202", "\303\203", "\303\204", "\303\205", "\303\206", "\303\207",
    "\303\210", "\303\211", "\303\212", "\303\213", "\303\214", "\303\215",
    "\303\216", "\303\217", "\303\220", "\303\221", "\303\222", "\303\223",
    "\303\224", "\303\225", "\303\226", "\303\227", "\303\230", "\303\231",
    "\303\232", "\303\233", "\303\234", "\303\235", "\303\236", "\303\237",
    "\303\240", "\303\241", "\303\242", "\303\243", "\303\244", "\303\245",
    "\303\246", "\303\247", "\303\250", "\303\251", "\303\252", "\303\253",
    "\303\254", "\303\255", "\303\256", "\303\257", "\303\260", "\303\261",
    "\303\262", "\303\263", "\303\264", "\303\265", "\303\266", "\303\267",
    "\303\270", "\303\271", "\303\272", "\303\273", "\303\274", "\303\275",
    "\303\276", "\303\277" );

sub charset_convert ($$$) {
    my($s, $charset_in, $charset_out) = @_;
    if ($s !~ /[\200-\377]/s) { # FIXME: don't worry about iso2022 for now
	;
    } elsif ($charset_in eq 'ISO-8859-1' && $charset_out eq 'UTF-8') {
	$s =~ s/[\200-\377]/ $latin1_utf8[ord($&) - 128] /egs;
    } elsif ($charset_in ne $charset_out) {
	VerboseWarnings::warn_normal "conversion from $charset_in to $charset_out is not supported\n", undef;
    }
    return $s;
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
