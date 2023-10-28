#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

=head1 NAME

xgettext.pl - xgettext(1)-like interface for .tt strings extraction

=cut

use FindBin;
use lib $FindBin::Bin;

use strict;
use warnings;
use Getopt::Long qw( GetOptions );
use POSIX;
use Locale::PO;
use TmplTokenizer;
use VerboseWarnings;

use vars qw( $convert_from );
use vars qw( $files_from $directory $output $sort );
use vars qw( $extract_all_p );
use vars qw( $pedantic_p );
use vars qw( %text %translation );
use vars qw( $charset_in $charset_out );
use vars qw( $disable_fuzzy_p );
use vars qw( $verbose_p );
use vars qw( $po_mode_p );

our $OUTPUT;

###############################################################################

sub string_negligible_p {
    my($t) = @_;				# a string
    # Don't emit pure whitespace, pure numbers, pure punctuation,
    # single letters, or TMPL_VAR's.
    # Punctuation should arguably be translated. But without context
    # they are untranslatable. Note that $t is a string, not a token object.
    return !$extract_all_p && (
    	       TmplTokenizer::blank_p($t)	# blank or TMPL_VAR
	    || $t =~ /^\d+$/			# purely digits
	    || $t =~ /^[-\+\.,:;!\?'"%\(\)\[\]\|]+$/ # punctuation w/o context
	    || $t =~ /^[A-Za-z]$/		# single letters
            || $t =~ /^(&[a-z]+;|&#\d+;|&#x[0-9a-fA-F]+;|%%|%s|\s|[[:punct:]])*$/ # html entities,placeholder,punct, ...
        || ( $t =~ /^\[\%.*\%\]$/ and $t !~ /\%\].*\[\%/ )    # pure TT entities
        || $t =~ /^\s*<\?.*\?>/                               # ignore xml prolog
	)
}

sub token_negligible_p {
    my ($x) = @_;
    my $t = $x->type;
    return !$extract_all_p && (
          $t == C4::TmplTokenType::TEXT() ? string_negligible_p( $x->string )
        : $t == C4::TmplTokenType::DIRECTIVE() ? 1
        : $t == C4::TmplTokenType::TEXT_PARAMETRIZED()
        && join(
            '',
            map {
                my $t = $_->type;
                    $t == C4::TmplTokenType::DIRECTIVE() ? '1'
                  : $t == C4::TmplTokenType::TAG()       ? ''
                  : token_negligible_p($_)               ? ''
                  : '1'
            } @{ $x->children }
        ) eq ''
    );
}

###############################################################################

sub remember {
    my($token, $string) = @_;
    # If we determine that the string is negligible, don't bother to remember
    unless (string_negligible_p( $string ) || token_negligible_p( $token )) {
        my $key = TmplTokenizer::string_canon( $string );
        $text{$key} = [] unless defined $text{$key};
        push @{$text{$key}}, $token;
    }
}

###############################################################################

sub string_list {
    my @t = keys %text;
    # The real gettext tools seems to sort case sensitively; I don't know why
    @t = sort { $a cmp $b } @t if $sort eq 's';
    @t = sort {
	    my @aa = sort { $a->pathname cmp $b->pathname
		    || $a->line_number <=> $b->line_number } @{$text{$a}};
	    my @bb = sort { $a->pathname cmp $b->pathname
		    || $a->line_number <=> $b->line_number } @{$text{$b}};
	    $aa[0]->pathname cmp $bb[0]->pathname
		    || $aa[0]->line_number <=> $bb[0]->line_number;
	} @t if $sort eq 'F';
    return @t;
}

  ###############################################################################

sub text_extract {
    my($h) = @_;
    for (;;) {
        my $s = TmplTokenizer::next_token($h);
        last unless defined $s;
        my($kind, $t, $attr) = ($s->type, $s->string, $s->attributes);
        if ($kind eq C4::TmplTokenType::TEXT) {
	    if ($t =~ /\S/s && $t !~ /<!/){
		remember( $s, $t );
	    }
        } elsif ($kind eq C4::TmplTokenType::TEXT_PARAMETRIZED) {
	    if ($s->form =~ /\S/s && $s->form !~ /<!/){
		remember( $s, $s->form );
	    }
        } elsif ($kind eq C4::TmplTokenType::TAG && %$attr) {
            # value [tag=input], meta
            my $tag;
            $tag = lc($1) if $t =~ /^<(\S+)/s;
            for my $a ('alt', 'content', 'title', 'value', 'label', 'placeholder', 'aria-label') {
                if ($attr->{$a}) {
                    next if $a eq 'label' && $tag ne 'optgroup';
                    next if $a eq 'content' && $tag ne 'meta';
                    next if $a eq 'value' && ($tag ne 'input'
                        || (ref $attr->{'type'} && $attr->{'type'}->[1] =~ /^(?:hidden|radio|checkbox)$/)); # FIXME
                    my($key, $val, $val_orig, $order) = @{$attr->{$a}}; #FIXME
                    $val = TmplTokenizer::trim($val);
                    # for selected attributes replace '[%..%]' with '%s' globally
                    if ( $a =~ /title|value|alt|content|placeholder|aria-label/ ) {
                        $val =~ s/\[\%.*?\%\]/\%s/g;
                    }
                    # save attribute text for translation
                    remember( $s, $val ) if $val =~ /\S/s;
                }
            }
        } elsif ($s->has_js_data) {
            for my $t (@{$s->js_data}) {
              remember( $s, $t->[3] ) if $t->[0]; # FIXME
            }
        }
    }
}

###############################################################################

sub generate_strings_list {
    # Emit all extracted strings.
    for my $t (string_list) {
        printf $OUTPUT "%s\n", $t;
    }
}

###############################################################################

sub generate_po_file {
    # We don't emit the Plural-Forms header; it's meaningless for us
    my $pot_charset = (defined $charset_out? $charset_out: 'CHARSET');
    $pot_charset = TmplTokenizer::charset_canon($pot_charset);
    # Time stamps aren't exactly right semantically. I don't know how to fix it.
    my $time = POSIX::strftime('%Y-%m-%d %H:%M%z', localtime(time));
    my $time_pot = $time;
    my $time_po  = $po_mode_p? $time: 'YEAR-MO-DA HO:MI+ZONE';
    print $OUTPUT <<EOF;
# SOME DESCRIPTIVE TITLE.
# Copyright (C) YEAR THE PACKAGE'S COPYRIGHT HOLDER
# This file is distributed under the same license as the PACKAGE package.
# FIRST AUTHOR <EMAIL\@ADDRESS>, YEAR.
#
EOF
    print $OUTPUT <<EOF unless $disable_fuzzy_p;
#, fuzzy
EOF
    print $OUTPUT <<EOF;
msgid ""
msgstr ""
"Project-Id-Version: Koha\\n"
"POT-Creation-Date: $time_pot\\n"
"PO-Revision-Date: $time_po\\n"
"Last-Translator: FULL NAME <EMAIL\@ADDRESS>\\n"
"Language-Team: LANGUAGE <LL\@li.org>\\n"
"MIME-Version: 1.0\\n"
"Content-Type: text/plain; charset=$pot_charset\\n"
"Content-Transfer-Encoding: 8bit\\n"

EOF
    my $directory_re = quotemeta("$directory/");
    for my $t (string_list) {
	if ($text{$t}->[0]->type == C4::TmplTokenType::TEXT_PARAMETRIZED) {
	    my($token, $n) = ($text{$t}->[0], 0);
        printf $OUTPUT "#. For the first occurrence,\n"
		    if @{$text{$t}} > 1 && $token->parameters_and_fields > 0;
	    for my $param ($token->parameters_and_fields) {
		$n += 1;
		my $type = $param->type;
		my $subtype = ($type == C4::TmplTokenType::TAG
			&& $param->string =~ /^<input\b/is?
				$param->attributes->{'type'}->[1]: undef);
		my $fmt = TmplTokenizer::_formalize( $param );
		$fmt =~ s/^%/%$n\$/;
		if ($type == C4::TmplTokenType::DIRECTIVE) {
#		    $type = "Template::Toolkit Directive";
		    $type = $param->string =~ /\[%(.*?)%\]/is? $1: 'ERROR';
		    my $name = $param->string =~ /\bname=(["']?)([^\s"']+)\1/is?
			    $2: undef;
            printf $OUTPUT "#. %s: %s\n", $fmt,
			"$type" . (defined $name? " name=$name": '');
		} else {
		    my $name = $param->attributes->{'name'};
            my $value;
            $value = $param->attributes->{'value'}
			    unless $subtype =~ /^(?:text)$/;
            printf $OUTPUT "#. %s: %s\n", $fmt, "type=$subtype"
			    . (defined $name?  " name=$name->[1]": '')
			    . (defined $value? " value=$value->[1]": '');
		}
	    }
	} elsif ($text{$t}->[0]->type == C4::TmplTokenType::TAG) {
	    my($token) = ($text{$t}->[0]);
        printf $OUTPUT "#. For the first occurrence,\n"
		    if @{$text{$t}} > 1 && $token->parameters_and_fields > 0;
	    if ($token->string =~ /^<meta\b/is) {
		my $type = $token->attributes->{'http-equiv'}->[1];
        print $OUTPUT "#. META http-equiv=$type\n" if defined $type;
	    } elsif ($token->string =~ /^<([a-z0-9]+)/is) {
		my $tag = uc($1);
		my $type = (lc($tag) eq 'input'?
			$token->attributes->{'type'}: undef);
		my $name = $token->attributes->{'name'};
        printf $OUTPUT "#. %s\n", $tag
		    . (defined $type? " type=$type->[1]": '')
		    . (defined $name? " name=$name->[1]": '');
	    }
	} elsif ($text{$t}->[0]->has_js_data) {
        printf $OUTPUT "#. For the first occurrence,\n" if @{$text{$t}} > 1;
        printf $OUTPUT "#. SCRIPT\n";
	}
	my $cformat_p;
	for my $token (@{$text{$t}}) {
	    my $pathname = $token->pathname;
	    $pathname =~ s/^$directory_re//os;
        $pathname =~ s/^.*\/koha-tmpl\/(.*)$/$1/;
        printf $OUTPUT "#: %s:%d\n", $pathname, $token->line_number
		    if defined $pathname && defined $token->line_number;
	    $cformat_p = 1 if $token->type == C4::TmplTokenType::TEXT_PARAMETRIZED;
	}
        printf $OUTPUT "#, c-format\n" if $cformat_p;
        printf $OUTPUT "msgid %s\n", TmplTokenizer::quote_po(
            TmplTokenizer::string_canon(
                TmplTokenizer::charset_convert($t, $charset_in, $charset_out)
            )
        );
        printf $OUTPUT "msgstr %s\n\n", (defined $translation{$t}?
		TmplTokenizer::quote_po( $translation{$t} ): "\"\"");
    }
}

###############################################################################

sub convert_translation_file {
    open(my $INPUT, '<:encoding(utf-8)', $convert_from) || die "$convert_from: $!\n";
    VerboseWarnings::set_input_file_name($convert_from);
    while (<$INPUT>) {
	chomp;
	my($msgid, $msgstr) = split(/\t/);
	die "$convert_from: $.: Malformed tmpl_process input (no tab)\n"
		unless defined $msgstr;

	# Fixup some of the bad strings
	$msgid =~ s/^SELECTED>//;

	# Create dummy token
	my $token = TmplToken->new( $msgid, C4::TmplTokenType::UNKNOWN, undef, undef );
	remember( $token, $msgid );
	$msgstr =~ s/^(?:LIMIT;|LIMITED;)//g; # unneeded for tmpl_process3
	$translation{$msgid} = $msgstr unless $msgstr eq '*****';

	if ($msgid  =~ /\bcharset=(["']?)([^;\s"']+)\1/s) {
        my $candidate = TmplTokenizer::charset_canon($2);
	    die "Conflicting charsets in msgid: $candidate vs $charset_in\n"
		    if defined $charset_in && $charset_in ne $candidate;
	    $charset_in = $candidate;
	}
	if ($msgstr =~ /\bcharset=(["']?)([^;\s"']+)\1/s) {
        my $candidate = TmplTokenizer::charset_canon($2);
	    die "Conflicting charsets in msgid: $candidate vs $charset_out\n"
		    if defined $charset_out && $charset_out ne $candidate;
	    $charset_out = $candidate;
	}
    }
    # The following assumption is correct; that's what HTML::Template assumes
    if (!defined $charset_in) {
        $charset_in = $charset_out = TmplTokenizer::charset_canon('utf-8');
        warn "Warning: Can't determine original templates' charset, defaulting to $charset_in\n";
    }
}

###############################################################################

sub usage {
    my($exitcode) = @_;
    my $h = $exitcode? *STDERR: *STDOUT;
    print $h <<EOF;
Usage: $0 [OPTIONS]
Extract translatable strings from given HTML::Template input files.

Input file location:
  -f, --files-from=FILE          Get list of input files from FILE
  -D, --directory=DIRECTORY      Add DIRECTORY to list for input files search

Output file location:
  -o, --output=FILE              Write output to specified file

HTML::Template options:
  -a, --extract-all              Extract all strings
      --pedantic-warnings        Issue warnings even for detected problems
                                 which are likely to be harmless

Output details:
  -s, --sort-output              generate sorted output
  -F, --sort-by-file             sort output by file location
  -v, --verbose                  explain what is being done

Informative output:
      --help                     Display this help and exit

Try `perldoc $0' for perhaps more information.
EOF
    exit($exitcode);
}

###############################################################################

sub usage_error {
    print STDERR "$_[0]\n" if @_;
    print STDERR "Try `$0 --help' for more information.\n";
    exit(-1);
}

###############################################################################

Getopt::Long::config qw( bundling no_auto_abbrev );
GetOptions(
    'a|extract-all'			=> \$extract_all_p,
    'charset=s'	=> sub { $charset_in = $charset_out = $_[1] },	# INTERNAL
    'convert-from=s'			=> \$convert_from,
    'D|directory=s'			=> \$directory,
    'disable-fuzzy'			=> \$disable_fuzzy_p,	# INTERNAL
    'f|files-from=s'			=> \$files_from,
    'I|input-charset=s'			=> \$charset_in,	# INTERNAL
    'pedantic-warnings|pedantic'	=> sub { $pedantic_p = 1 },
    'O|output-charset=s'		=> \$charset_out,	# INTERNAL
    'output|o=s'			=> \$output,
    'po-mode'				=> \$po_mode_p,		# INTERNAL
    's|sort-output'			=> sub { $sort = 's' },
    'F|sort-by-file'			=> sub { $sort = 'F' },
    'v|verbose'				=> \$verbose_p,
    'help'				=> sub { usage(0) },
) || usage_error;

VerboseWarnings::set_application_name($0);
VerboseWarnings::set_pedantic_mode($pedantic_p);

usage_error('Missing mandatory option -f')
	unless defined $files_from || defined $convert_from;
$directory = '.' unless defined $directory;

usage_error('You cannot specify both --convert-from and --files-from')
	if defined $convert_from && defined $files_from;

if (defined $output && $output ne '-') {
    print STDERR "$0: Opening output file \"$output\"\n" if $verbose_p;
    open($OUTPUT, '>:encoding(utf-8)', $output) || die "$output: $!\n";
} else {
    print STDERR "$0: Outputting to STDOUT...\n" if $verbose_p;
    open($OUTPUT, q{>}, "&STDOUT");
}

if (defined $files_from) {
    print STDERR "$0: Opening input file list \"$files_from\"\n" if $verbose_p;
    open(my $INPUT, '<:encoding(utf-8)', $files_from) || die "$files_from: $!\n";
    while (<$INPUT>) {
	chomp;
	my $input = /^\//? $_: "$directory/$_";
	my $h = TmplTokenizer->new( $input );
	$h->set_allow_cformat( 1 );
    VerboseWarnings::set_input_file_name($input);
	print STDERR "$0: Processing file \"$input\"\n" if $verbose_p;
	text_extract( $h );
    }
    close $INPUT;
} else {
    print STDERR "$0: Converting \"$convert_from\"\n" if $verbose_p;
    convert_translation_file;
}
generate_po_file;

warn "This input will not work with Mozilla standards-compliant mode\n", undef
	if TmplTokenizer::syntaxerror_p;


exit(-1) if TmplTokenizer::fatal_p;

###############################################################################

=head1 DESCRIPTION

This script has behaviour similar to
xgettext(1), and generates gettext-compatible output files.

A gettext-like format provides the following advantages:

=over

=item -

Translation to non-English-like languages with different word
order:  gettext's c-format strings can theoretically be
emulated if we are able to do some analysis on the .tt input
and treat <TMPL_VAR> in a way similar to %s.

=item - 

Context for the extracted strings:  the gettext format provides
the filenames and line numbers where each string can be found.
The translator can read the source file and see the context,
in case the string by itself can mean several different things.

=item - 

Place for the translator to add comments about the translations.

=item -

Gettext-compatible tools, if any, might be usable if we adopt
the gettext format.

=back

This script has already been in use for over a year and should
be reasonable stable. Nevertheless, it is still somewhat
experimental and there are still some issues.

Please refer to the explanation in tmpl_process3 for further
details.

If you want to generate GNOME-style POTFILES.in files, such
files (passed to -f) can be generated thus:

    (cd ../.. && find koha-tmpl/opac-tmpl/default/en \
        -name \*.inc -o -name \*.tt) > opac/POTFILES.in
    (cd ../.. && find koha-tmpl/intranet-tmpl/default/en \
        -name \*.inc -o -name \*.tt) > intranet/POTFILES.in

This is, however, quite pointless, because the "create" and
"update" actions have already been implemented in tmpl_process3.pl.

=head2 Strings inside JavaScript

In the SCRIPT elements, the script will attempt to scan for
_("I<string literal>") patterns, and extract the I<string literal>
as a translatable string.

Note that the C-like _(...) notation is required.

The JavaScript must actually define a _ function
so that the code remains correct JavaScript.
A suitable definition of such a function can be

	function _(s) { return s } // dummy function for gettext

=head1 SEE ALSO

tmpl_process3.pl,
xgettext(1),
Locale::PO(3),
translator_doc.txt

=head1 BUGS

There probably are some. Bugs related to scanning of <INPUT>
tags seem to be especially likely to be present.

Its diagnostics are probably too verbose.

When a <TMPL_VAR> within a JavaScript-related attribute is
detected, the script currently displays no warnings at all.
It might be good to display some kind of warning.

Its sort order (-s option) seems to be different than the real
xgettext(1)'s sort option. This will result in translation
strings inside the generated PO file spuriously moving about
when tmpl_process3.pl calls msgmerge(1) to update the PO file.

If a Javascript string has leading spaces, it will
generate strings with spurious leading spaces,
leading to failure to match the strings when actually generating
translated files.

=cut
