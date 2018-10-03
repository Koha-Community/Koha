#!/usr/bin/perl

# Test filter partially based on Ambrose's hideous subst.pl code
# The idea is that the .tt files are not valid HTML, and as a result
# HTML::Parse would be completely confused by these templates.
# This is just a simple scanner (not a parser) & should give better results.

# This script is meant to be a drop-in replacement of text-extract.pl

# A grander plan: Code could be written to detect template variables and
# construct gettext-c-format-string-like meta-strings (e.g., "Results %s
# through %s of %s records" that will be more likely to be translatable
# to languages where word order is very unlike English word order.
# --> This will be relatively major rework, and requires corresponding
# rework in tmpl_process.pl

use FindBin;
use lib $FindBin::Bin;

use strict;
#use warnings; FIXME - Bug 2505
use Getopt::Long;
use TmplTokenizer;
use VerboseWarnings;

use vars qw( $input );
use vars qw( $debug_dump_only_p );
use vars qw( $pedantic_p );
use vars qw( $allow_cformat_p ); # FOR TESTING PURPOSES ONLY!!

###############################################################################

sub underline ($) { # for testing only
    my($s) = @_;
    join('', map {/[\0-\37]/? $_: "$_\b$_"} split(//, $s));
}

sub debug_dump ($) { # for testing only
    my($h) = @_;
    print "re_tag_compat is /", TmplTokenizer::re_tag(1), "/\n";
    for (;;) {
	my $s = TmplTokenizer::next_token $h;
    last unless defined $s;
	printf "%s\n", ('-' x 79);
	my($kind, $t, $attr) = ($s->type, $s->string, $s->attributes);
	printf "%s [line %d]:\n", $kind->to_string, $s->line_number;
	printf "%4dH%s\n", length($t), underline($t);
    if ($kind == TmplTokenType::TAG() && %$attr) {
	    printf "Attributes:\n";
	    for my $a (keys %$attr) {
		my($key, $val, $val_orig, $order) = @{$attr->{$a}};
		printf "%s = %dH%s -- %s\n", $a, length $val, underline $val,
		$val_orig;
	    }
	}
    if ($kind == TmplTokenType::TEXT_PARAMETRIZED()) {
	    printf "Form (c-format string):\n";
	    printf "%dH%s\n", length $s->form, underline $s->form;
	    printf "Parameters:\n";
	    my $i = 1;
	    for my $a ($s->parameters) {
		my $t = $a->string;
		printf "%%%d\$s = %dH%s\n", $i, length $t, underline $t;
		$i += 1;
	    }
	}
	if ($s->has_js_data) {
	    printf "JavaScript translatable strings:\n";
	    for my $t (@{$s->js_data}) {
		printf "%dH%s\n", length $t->[3], underline $t->[3] if $t->[0]; # FIXME
	    }
	}
    }
}

###############################################################################

sub text_extract ($) {
    my($h) = @_;
    my %text = ();
    for (;;) {
	my $s = TmplTokenizer::next_token $h;
    last unless defined $s;
	my($kind, $t, $attr) = ($s->type, $s->string, $s->attributes);
    if ($kind == TmplTokenType::TEXT()) {
	    $t = TmplTokenizer::trim $t;
	    $text{$t} = 1 if $t =~ /\S/s;
    } elsif ($kind == TmplTokenType::TAG() && %$attr) {
	    # value [tag=input], meta
	    my $tag = lc($1) if $t =~ /^<(\S+)/s;
	    for my $a ('alt', 'content', 'title', 'value') {
		if ($attr->{$a}) {
		    next if $a eq 'content' && $tag ne 'meta';
		    next if $a eq 'value' && ($tag ne 'input'
			|| (ref $attr->{'type'} && $attr->{'type'}->[1] =~ /^(?:hidden|radio)$/)); # FIXME
		    my($key, $val, $val_orig, $order) = @{$attr->{$a}}; #FIXME
		    $val = TmplTokenizer::trim $val;
		    $text{$val} = 1 if $val =~ /\S/s;
		}
	    }
	} elsif ($s->has_js_data) {
	    for my $t (@{$s->js_data}) {
		remember( $s, $t->[3] ) if $t->[0]; # FIXME
	    }
	}
    }
    # Emit all extracted strings.
    # Don't emit pure whitespace, pure numbers, or TMPL_VAR's.
    for my $t (keys %text) {
	printf "%s\n", $t
	    unless TmplTokenizer::blank_p($t) || $t =~ /^\d+$/;
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
    'enable-cformat'	=> \$allow_cformat_p,
    'f|file=s'		=> \$input,
    'debug-dump-only'	=> \$debug_dump_only_p,
    'pedantic-warnings'	=> sub { $pedantic_p = 1 },
    'help'		=> sub { usage(0) },
) || usage_error;

VerboseWarnings::set_application_name $0;
VerboseWarnings::set_input_file_name $input;
VerboseWarnings::set_pedantic_mode $pedantic_p;

usage_error('Missing mandatory option -f') unless defined $input;

my $h = TmplTokenizer->new( $input );
$h->set_allow_cformat( 1 ) if $allow_cformat_p;
if ($debug_dump_only_p) {
    debug_dump( $h );
} else {
    text_extract( $h );
}

warn "This input will not work with Mozilla standards-compliant mode\n", undef
	if TmplTokenizer::syntaxerror_p;

close INPUT;

exit(-1) if TmplTokenizer::fatal_p;
