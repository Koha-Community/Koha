#!/usr/bin/perl

# Test filter partially based on Ambrose's hideous subst.pl code
# The idea is that the .tmpl files are not valid HTML, and as a result
# HTML::Parse would be completely confused by these templates.
# This is just a simple scanner (not a parser) & should give better results.

# This script is meant to be a drop-in replacement of text-extract.pl

use Getopt::Long;
use strict;

use vars qw( $input );
use vars qw( $debug_dump_only_p );

###############################################################################

# Hideous stuff from subst.pl
# Note: The $re_tag's set $1 (<tag), $2 (>), and $3 (rest of string)
use vars qw( $re_comment $re_entity_name $re_end_entity $re_etag );
use vars qw( $re_tag_strict $re_tag_compat @re_tag );
sub re_tag ($) {
   my($compat) = @_;
   my $etag = $compat? '>': '<>\/';
   # See the file "subst.pl.test1" for how the following mess is derived
   q{(<\/?(?:|(?:"[^"]*"|'[^']*'|--(?:[^-]|-[^-])*--|(?:[^-"'} . $etag . q{]|-[^-]))+))([} . $etag . q{])(.*)};
}
BEGIN {
    $re_comment = '(?:--(?:[^-]|-[^-])*--)';
    $re_entity_name = '(?:[^&%#;<>\s]+)'; # NOTE: not really correct SGML
    $re_end_entity = '(?:;|$|(?=\s))'; # semicolon or before-whitespace
    $re_etag = q{(?:<\/?(?:"[^"]*"|'[^']*'|[^"'>\/])*[>\/])}; # end-tag
    @re_tag = ($re_tag_strict, $re_tag_compat) = (re_tag(0), re_tag(1));
}

# End of the hideous stuff

use vars qw( $re_directive );
BEGIN {
    # $re_directive must not do any backreferences
    $re_directive = q{<(?:!--\s*)?\/?TMPL_(?:VAR|LOOP|INCLUDE|IF|ELSE|UNLESS)\b(?:\s+(?:[a-zA-Z][-a-zA-Z0-9]*=)?(?:'[^']*'|"[^"]*"|[^\s<>]+))\s*(?:--)?>};
}

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
    $s = $1 if $s =~ /^<\S+(.*)\S$/s; # should be always true
    for (my $i = 0; $s =~ /^\s+(?:([a-zA-Z][-a-zA-Z0-9]*)=)?('((?:$re_directive|[^'])*)'|"((?:$re_directive|[^"])*)"|(($re_directive|[^\s<>])+))/os;) {
	my($key, $val, $val_orig, $rest)
		= ($1, (defined $3? $3: defined $4? $4: $5), $2, $');
	$i += 1;
	$attr{+lc($key)} = [$key, $val, $val_orig, $i];
	$s = $rest;
    }
    if ($s =~ /\S/s) { # should never happen
	warn "Warning: Strange attribute syntax"
		. (defined $lc? " in line $lc": '') . ": $s\n";
    } else {
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
    } elsif ($readahead =~ /^[^<]+/s) {	# non-whitespace normal text
	($kind, $it, $readahead) = (KIND_TEXT, $&, $');
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
	($kind, $it) = (KIND_UNKNOWN, $readahead)
		if !$ok_p && $eof_p && !length $readahead;
    }
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
	    push @$it, extract_attributes($it->[1], $lc); #FIXME
	}
    } else {
	for (;;) {
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
	$it = [KIND_CDATA, $it] if defined $it; #FIXME
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

sub text_extract (*) {
    my($h) = @_;
    my %text = ();
    for (;;) {
	my $s = next_token $h;
    last unless defined $s;
	my($kind, $t, $attr) = @$s; # FIXME
	if ($kind eq KIND_TEXT) {
	    $t =~ s/\s+$//s;
	    $text{$t} = 1 if $t =~ /\S/s; # FIXME... trailing whitespace
	} elsif ($kind eq KIND_TAG && %$attr) {
	    # value [tag=input], meta
	    my $tag = lc($1) if $t =~ /^<(\S+)/s;
	    for my $a ('alt', 'content', 'title', 'value') {
		if ($attr->{$a}) {
		    next if $a eq 'content' && $tag ne 'meta';
		    next if $a eq 'value' && ($tag ne 'input'
			|| (ref $attr->{'type'} && $attr->{'type'}->[1] eq 'hidden'));
		    my($key, $val, $val_orig, $order) = @{$attr->{$a}}; #FIXME
		    $val =~ s/\s+$//s;
		    $text{$val} = 1 if $val =~ /\S/s;
		}
	    }
	}
    }
    for my $t (keys %text) {
	printf "%s\n", $t unless $t =~ /^(?:\s|\&nbsp;)*$/s;
    }
}

###############################################################################

GetOptions(
    'f|file=s' => \$input,
    'debug-dump-only-p' => \$debug_dump_only_p,
) || exit(-1);

open(INPUT, "<$input") || die "$0: $input: $!\n";
if ($debug_dump_only_p) {
    debug_dump(*INPUT);
} else {
    text_extract(*INPUT);
}

warn "Warning: This input will not work with Mozilla standards-compliant mode\n"
	if $syntaxerror_p;

close INPUT;

