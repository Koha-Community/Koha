package VerboseWarnings;

use strict;
require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

###############################################################################

=head1 NAME

VerboseWarnings.pm - Verbose warnings for Perl scripts

=head1 DESCRIPTION

Contains convenience functions to construct Unix-style informational,
verbose warnings.

=cut

###############################################################################

$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT_OK = qw(
    &pedantic_p
    &warn_normal
    &warn_pedantic
    &error_normal
);

###############################################################################

use vars qw( $appName $input $input_abbr $pedantic_p $pedantic_tag );

sub set_application_name ($) {
    my($s) = @_;
    $appName = $& if !defined $appName && $s =~ /[^\/]+$/;
}

sub set_input_file_name ($) {
    my($s) = @_;
    $input = $s;
    $input_abbr = $& if defined $s && $s =~ /[^\/]+$/;
}

sub set_pedantic_mode ($) {
    my($p) = @_;
    $pedantic_p = $p;
    $pedantic_tag = $pedantic_p? '': ' (negligible)';
}

sub pedantic_p () {
    return $pedantic_p;
}

sub construct_warn_prefix ($$) {
    my($prefix, $lc) = @_;
    die "construct_warn_prefix called before set_application_name"
	    unless defined $appName;
    die "construct_warn_prefix called before set_input_file_name"
	    unless defined $input;
    die "construct_warn_prefix called before set_pedantic_mode"
	    unless defined $pedantic_tag;

    # FIXME: The line number is not accurate, but should be "close enough"
    # FIXME: This wording is worse than what was there, but it's wrong to
    # FIXME: hard-code this thing in each warn statement. Need improvement.
    return "$appName: $prefix: " . (defined $lc? "$input_abbr: line $lc: ": "$input_abbr: ");
}

sub warn_normal ($$) {
    my($msg, $lc) = @_;
    my $prefix = construct_warn_prefix('Warning', $lc);
    $msg .= "\n" unless $msg =~ /\n$/s;
    warn "$prefix$msg";
}

sub warn_pedantic ($$$) {
    my($msg, $lc, $flag) = @_;
    my $prefix = construct_warn_prefix("Warning$pedantic_tag", $lc);
    $msg .= "\n" unless $msg =~ /\n$/s;
    warn "$prefix$msg" if $pedantic_p || !$$flag;
    if (!$pedantic_p) {
	$prefix = construct_warn_prefix("Warning$pedantic_tag", undef);
	warn $prefix."Further similar negligible warnings will not be reported, use --pedantic for details\n" unless $$flag;
	$$flag = 1;
    }
}

sub error_normal ($$) {
    my($msg, $lc) = @_;
    my $prefix = construct_warn_prefix('ERROR', $lc);
    $msg .= "\n" unless $msg =~ /\n$/s;
    warn "$prefix$msg";
}

###############################################################################
