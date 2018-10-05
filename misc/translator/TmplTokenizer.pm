package TmplTokenizer;

use strict;
#use warnings; FIXME - Bug 2505
use C4::TmplTokenType;
use C4::TmplToken;
use C4::TTParser;
use VerboseWarnings qw( pedantic_p error_normal warn_normal warn_pedantic );
require Exporter;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

###############################################################################

=head1 NAME

TmplTokenizer.pm - Simple-minded wrapper class for TTParser

=head1 DESCRIPTION

A wrapper for the functionality found in TTParser to allow an easier transition to Template Toolkit

=cut

###############################################################################


@ISA = qw(Exporter);
@EXPORT_OK = qw();

use vars qw( $pedantic_attribute_error_in_nonpedantic_mode_p );
use vars qw( $pedantic_tmpl_var_use_in_nonpedantic_mode_p );
use vars qw( $pedantic_error_markup_in_pcdata_p );

###############################################################################

# Hideous stuff
use vars qw( $re_xsl $re_end_entity $re_tmpl_var);
BEGIN {
    $re_tmpl_var = q{\[%\s*[get|set|default]?\s*[\w\.]+\s*[|.*?]?\s*%\]};
    $re_xsl = q{<\/?(?:xsl:)(?:[\s\-a-zA-Z0-9"'\/\.\[\]\@\(\):=,$]+)\/?>};
    $re_end_entity = '(?:;|$|(?=\s))'; # semicolon or before-whitespace
}
# End of the hideous stuff

use vars qw( $serial );

###############################################################################

sub FATAL_P		() {'fatal-p'}
sub SYNTAXERROR_P	() {'syntaxerror-p'}

sub FILENAME		() {'input'}
#sub HANDLE		() {'handle'}

#sub READAHEAD		() {'readahead'}
sub LINENUM_START	() {'lc_0'}
sub LINENUM		() {'lc'}
sub CDATA_MODE_P	() {'cdata-mode-p'}
sub CDATA_CLOSE		() {'cdata-close'}
#sub PCDATA_MODE_P	() {'pcdata-mode-p'}	# additional submode for CDATA
sub JS_MODE_P		() {'js-mode-p'}	# cdata-mode-p must also be true

sub ALLOW_CFORMAT_P	() {'allow-cformat-p'}

sub new {
    shift;
    my ($filename) = @_;
    #open my $handle,$filename or die "can't open $filename";
    my $parser = C4::TTParser->new;
    $parser->build_tokens( $filename );
    bless {
      filename => $filename,
      _parser => $parser
#     , handle => $handle
#     , readahead => []
    } , __PACKAGE__;
}

###############################################################################

# Simple getters

sub filename {
    my $this = shift;
    return $this->{filename};
}

sub fatal_p {
    my $this = shift;
    return $this->{+FATAL_P};
}

# work around, currently not implemented
sub syntaxerror_p {
#    my $this = shift;
#    return $this->{+SYNTAXERROR_P};
    return 0;
}

sub js_mode_p {
    my $this = shift;
    return $this->{+JS_MODE_P};
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

sub _set_js_mode {
    my $this = shift;
    $this->{+JS_MODE_P} = $_[0];
    return $this;
}

#used in xgettext, tmpl_process3
sub set_allow_cformat {
    my $this = shift;
    $this->{+ALLOW_CFORMAT_P} = $_[0];
    return $this;
}

###############################################################################

use vars qw( $js_EscapeSequence );
BEGIN {
    # Perl quoting is really screwed up, but this common subexp is way too long
    $js_EscapeSequence = q{\\\\(?:['"\\\\bfnrt]|[^0-7xu]|[0-3]?[0-7]{1,2}|x[\da-fA-F]{2}|u[\da-fA-F]{4})};
}
sub parenleft  () { '(' }
sub parenright () { ')' }

sub _split_js ($) {
    my ($s0) = @_;
    my @it = ();
    while (length $s0) {
        if ($s0 =~ /^\s+/s) {				# whitespace
          push @it, $&;
          $s0 = $';
        } elsif ($s0 =~ /^\/\/[^\r\n]*(?:[\r\n]|$)/s) {	# C++-style comment
        push @it, $&;
        $s0 = $';
        } elsif ($s0 =~ /^\/\*(?:(?!\*\/).)*\*\//s) {	# C-style comment
            push @it, $&;
            $s0 = $';
        # Keyword or identifier, ECMA-262 p.13 (section 7.5)
        } elsif ($s0 =~ /^[A-Z_\$][A-Z\d_\$]*/is) {	# IdentifierName
            push @it, $&;
            $s0 = $';
        # Punctuator, ECMA-262 p.13 (section 7.6)
        } elsif ($s0 =~ /^(?:[\(\){}\[\];]|>>>=|<<=|>>=|[-\+\*\/\&\|\^\%]=|>>>|<<|>>|--|\+\+|\|\||\&\&|==|<=|>=|!=|[=><,!~\?:\.\-\+\*\/\&\|\^\%])/s) {
            push @it, $&;
            $s0 = $';
        # DecimalLiteral, ECMA-262 p.14 (section 7.7.3); note: bug in the spec
        } elsif ($s0 =~ /^(?:0|[1-9]\d+(?:\.\d*(?:[eE][-\+]?\d+)?)?)/s) {
            push @it, $&;
            $s0 = $';
        # HexIntegerLiteral, ECMA-262 p.15 (section 7.7.3)
        } elsif ($s0 =~ /^0[xX][\da-fA-F]+/s) {
            push @it, $&;
            $s0 = $';
        # OctalIntegerLiteral, ECMA-262 p.15 (section 7.7.3)
        } elsif ($s0 =~ /^0[\da-fA-F]+/s) {
            push @it, $&;
            $s0 = $';
        # StringLiteral, ECMA-262 p.17 (section 7.7.4)
        # XXX SourceCharacter doesn't seem to be defined (?)
        } elsif ($s0 =~ /^(?:"(?:(?!["\\\r\n]).|$js_EscapeSequence)*"|'(?:(?!['\\\r\n]).|$js_EscapeSequence)*')/os) {
            push @it, $&;
            $s0 = $';
        } elsif ($s0 =~ /^./) {				# UNKNOWN TOKEN !!!
            push @it, $&;
            $s0 = $';
        }
    }
    return @it;
}

sub STATE_UNDERSCORE     () { 1 }
sub STATE_PARENLEFT      () { 2 }
sub STATE_STRING_LITERAL () { 3 }

# XXX This is a crazy hack. I don't want to write an ECMAScript parser.
# XXX A scanner is one thing; a parser another thing.
sub _identify_js_translatables (@) {
    my @input = @_;
    my @output = ();
    # We mark a JavaScript translatable string as in C, i.e., _("literal")
    # For simplicity, we ONLY look for "_" "(" StringLiteral ")"
    for (my $i = 0, my $state = 0, my($j, $q, $s); $i <= $#input; $i += 1) {
#        warn $input[$i];
        my $reset_state_p = 0;
        push @output, [0, $input[$i]];
        if ($input[$i] !~ /\S/s) {
          ;
        } elsif ($state == 0) {
          $state = STATE_UNDERSCORE if $input[$i] eq '_';
        } elsif ($state == STATE_UNDERSCORE) {
          $state = $input[$i] eq parenleft ? STATE_PARENLEFT : 0;
        } elsif ($state == STATE_PARENLEFT) {
          if ($input[$i] =~ /^(['"])(.*)\1$/s) {
            ($state, $j, $q, $s) = (STATE_STRING_LITERAL, $#output, $1, $2);
          } else {
            $state = 0;
          }
        } elsif ($state == STATE_STRING_LITERAL) {
          if ($input[$i] eq parenright) {
            $output[$j] = [1, $output[$j]->[1], $q, $s];
          }
          $state = 0;
        } else {
          die "identify_js_translatables internal error: Unknown state $state"
        }
    }
#    use Data::Dumper;
#    warn Dumper \@output;
    return \@output;
}

###############################################################################

sub string_canon ($) {
  my $s = shift;
  # Fold all whitespace into single blanks
  $s =~ s/\s+/ /g;
  $s =~ s/^\s+//g;
  return $s;
}

# safer version used internally, preserves new lines
sub string_canon_safe ($) {
  my $s = shift;
  # fold tabs and spaces into single spaces
  $s =~ s/[\ \t]+/ /gs;
  return $s;
}


sub _quote_cformat{
  my $s = shift;
  $s =~ s/%/%%/g;
  return $s;
}

sub _formalize_string_cformat{
  my $s = shift;
  return _quote_cformat( string_canon_safe $s );
}

sub _formalize{
  my $t = shift;
  if( $t->type == C4::TmplTokenType::DIRECTIVE ){
    return '%s';
  } elsif( $t->type == C4::TmplTokenType::TEXT ){
    return _formalize_string_cformat( $t->string );
  } elsif( $t->type == C4::TmplTokenType::TAG ){
    if( $t->string =~ m/^a\b/is ){
      return '<a>';
    } elsif( $t->string =~ m/^input\b/is ){
      if( lc $t->attributes->{'type'}->[1] eq 'text' ){
        return '%S';
      } else{
        return '%p';
      }
    } else{
      return _quote_cformat $t->string;
    }	  
  } else{
    return _quote_cformat $t->string;
  }
}

# internal parametization, used within next_token
# method that takes in an array of TEXT and DIRECTIVE tokens (DIRECTIVEs must be GET) and return a C4::TmplTokenType::TEXT_PARAMETRIZED
sub _parametrize_internal{
    my $this = shift;
    my @parts = @_;
    # my $s = "";
    # for my $item (@parts){
    #     if( $item->type == C4::TmplTokenType::TEXT ){
    #         $s .= $item->string;
    #     } else {
    #         #must be a variable directive
    #         $s .= "%s";
    #     }
    # }
    my $s = join( "", map { _formalize $_ } @parts );
    # should both the string and form be $s? maybe only the later? posibly the former....
    # used line number from first token, should suffice
    my $t = C4::TmplToken->new( $s, C4::TmplTokenType::TEXT_PARAMETRIZED, $parts[0]->line_number, $this->filename );
    $t->set_children(@parts);
    $t->set_form($s);
    return $t;
}

sub next_token {
    my $self = shift;
    my $next;
#    warn "in next_token";
    # parts that make up a text_parametrized (future children of the token)
    my @parts = ();
    while(1){
        $next = $self->{_parser}->next_token;
        if (! $next){
            if (@parts){
                return $self->_parametrize_internal(@parts);
            }
            else {
                return undef;
            }
        }
        # if cformat mode is off, dont bother parametrizing, just return them as they come
        return $next unless $self->allow_cformat_p;
        if( $next->type == C4::TmplTokenType::TEXT ){
            push @parts, $next;
        } 
#        elsif( $next->type == C4::TmplTokenType::DIRECTIVE && $next->string =~ m/\[%\s*\w+\s*%\]/ ){
        elsif( $next->type == C4::TmplTokenType::DIRECTIVE ){
            push @parts, $next;
        } 
        elsif ( $next->type == C4::TmplTokenType::CDATA){
            $self->_set_js_mode(1);
            my $s0 = $next->string;
            my @head = ();
            my @tail = ();

            if ($s0 =~ /^(\s*\[%\s*)(.*)(\s%=]\s*)$/s) {
                push @head, $1;
                 push @tail, $3;
                $s0 = $2;
            }
            push @head, _split_js $s0;
            $next->set_js_data(_identify_js_translatables(@head, @tail) );
	    return $next unless @parts;	    
	    $self->{_parser}->unshift_token($next);
            return $self->_parametrize_internal(@parts);
        }
        else {
            # if there is nothing in parts, return this token
            return $next unless @parts;

            # OTHERWISE, put this token back and return the parametrized string of @parts
            $self->{_parser}->unshift_token($next);
            return $self->_parametrize_internal(@parts);
        }

    }
}

###############################################################################

# function taken from old version
# used by tmpl_process3
sub parametrize ($$$$) {
    my($fmt_0, $cformat_p, $t, $f) = @_;
    my $it = '';
    if ($cformat_p) {
	my @params = $t->parameters_and_fields;
	for (my $n = 0, my $fmt = $fmt_0; length $fmt;) {
	    if ($fmt =~ /^[^%]+/) {
		$fmt = $';
		$it .= $&;
	    } elsif ($fmt =~ /^%%/) {
		$fmt = $';
		$it .= '%';
	    } elsif ($fmt =~ /^%(?:(\d+)\$)?(?:(\d+)(?:\.(\d+))?)?s/s) {
		$n += 1;
		my($i, $width, $prec) = ((defined $1? $1: $n), $2, $3);
		$fmt = $';
		if (defined $width && defined $prec && !$width && !$prec) {
		    ;
		} elsif (defined $params[$i - 1]) {
		    my $param = $params[$i - 1];
		    warn_normal "$fmt_0: $&: Expected a TMPL_VAR, but found a "
			    . $param->type->to_string . "\n", undef
			    if $param->type != C4::TmplTokenType::DIRECTIVE;
		    warn_normal "$fmt_0: $&: Unsupported "
				. "field width or precision\n", undef
			    if defined $width || defined $prec;
		    warn_normal "$fmt_0: $&: Parameter $i not known", undef
			    unless defined $param;
		    $it .= defined $f? &$f( $param ): $param->string;
		}
	    } elsif ($fmt =~ /^%(?:(\d+)\$)?(?:(\d+)(?:\.(\d+))?)?([pS])/s) {
		$n += 1;
		my($i, $width, $prec, $conv) = ((defined $1? $1: $n), $2, $3, $4);
		$fmt = $';

		my $param = $params[$i - 1];
		if (!defined $param) {
		    warn_normal "$fmt_0: $&: Parameter $i not known", undef;
		} else {
		    if ($param->type == C4::TmplTokenType::TAG
			    && $param->string =~ /^<input\b/is) {
			my $type = defined $param->attributes?
				lc($param->attributes->{'type'}->[1]): undef;
			if ($conv eq 'S') {
			    warn_normal "$fmt_0: $&: Expected type=text, "
					. "but found type=$type", undef
				    unless $type eq 'text';
			} elsif ($conv eq 'p') {
			    warn_normal "$fmt_0: $&: Expected type=radio, "
					. "but found type=$type", undef
				    unless $type eq 'radio';
			}
		    } else {
			warn_normal "$&: Expected an INPUT, but found a "
				. $param->type->to_string . "\n", undef
		    }
		    warn_normal "$fmt_0: $&: Unsupported "
				. "field width or precision\n", undef
			    if defined $width || defined $prec;
		    $it .= defined $f? &$f( $param ): $param->string;
		}
	    } elsif ($fmt =~ /^%[^%a-zA-Z]*[a-zA-Z]/) {
		$fmt = $';
		$it .= $&;
		die "$&: Unknown or unsupported format specification\n"; #XXX
	    } else {
		die "$&: Completely confused parametrizing -- msgid: $fmt_0\n";#XXX
	    }
	}
    }
    my @anchors = $t->anchors;
    for (my $n = 0, my $fmt = $it, $it = ''; length $fmt;) {
	if ($fmt =~ /^(?:(?!<a\d+>).)+/is) {
	    $fmt = $';
	    $it .= $&;
	} elsif ($fmt =~ /^<a(\d+)>/is) {
	    $n += 1;
	    my $i  = $1;
	    $fmt = $';
	    my $anchor = $anchors[$i - 1];
	    warn_normal "$&: Anchor $1 not found for msgid \"$fmt_0\"", undef #FIXME
		    unless defined $anchor;
	    $it .= $anchor->string;
	} else {
	    die "Completely confused decoding anchors: $fmt\n";#XXX
	}
    }
    return $it;
}


# Other simple functions (These are not methods)

sub blank_p ($) {
    my($s) = @_;
    return $s =~ /^(?:\s|\&nbsp$re_end_entity|$re_tmpl_var|$re_xsl)*$/osi;
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
    $s =~ s/([\\"])/\\$1/gs;
    $s =~ s/\n/\\n/g;
    #$s =~ s/[\177-\377]/ sprintf("\\%03o", ord($&)) /egs;
    return "\"$s\"";
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
turned on using the set_allow_cformat(1) method call.

=head2 The flag characters

The character % is followed by zero or more of the following flags:

=over

=item #

The value comes from HTML <INPUT> elements.
This abuse of the flag character is somewhat reasonable,
since TMPL_VAR and INPUT are both variables, but of different kinds.

=back

=head2 The field width and precision

An optional 0.0 can be specified for %s to specify
that the <TMPL_VAR> should be suppressed.

=head2 The conversion specifier

=over

=item p

Specifies any input field that is neither text nor hidden
(which currently mean radio buttons).
The p conversion specifier is chosen because this does not
evoke any certain sensible data type.

=item S

Specifies a text input field (<INPUT TYPE=TEXT>).
This use of the S conversion specifier is somewhat reasonable,
since text input fields contain values of undeterminable type,
which can be treated as strings.

=item s

Specifies a <TMPL_VAR>.
This use of the o conversion specifier is somewhat reasonable,
since <TMPL_VAR> denotes values of undeterminable type, which
can be treated as strings.

=back

=head1 BUGS

There is no code to save the tag name anywhere in the scanned token.

The use of <AI<i>> to stand for the I<i>th anchor
is not very well thought out.
Some abuse of c-format specifies might have been more appropriate.

=head1 HISTORY

This tokenizer is mostly based
on Ambrose's hideous Perl script known as subst.pl.

=cut

1;
