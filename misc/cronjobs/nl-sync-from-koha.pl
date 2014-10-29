#!/usr/bin/perl

# Copyright 2014 Oslo Public Library

=head1 NAME

nl-sync-from-koha.pl - Sync patrons from Koha to the Norwegian national patron database (NL).

=head1 SYNOPSIS

 perl nl-sync-from-koha.pl -v --run

=cut

use Koha::NorwegianPatronDB qw( NLCheckSysprefs NLSync );
use Koha::Database;
use Getopt::Long;
use Pod::Usage;
use Modern::Perl;

# Get options
my ( $run, $verbose, $debug ) = get_options();

=head1 ACTIONS

=head2

Find local patrons that have been changed and need to be sent upstream to NL.
These patrons will be distinguished by two borrower attributes:

=over 4

=item * The "nlstatus" attribute will have a value of "needsync". (Which means
that the patron has been changed in Koha, but not yet successfully synced
upstream.)

=item * The "nlsync" attribute will have a value of 1. (Which means that this
patron has accepted to be synced with NL, as opposed to a value of 0 which
would indicate that the patron has asked not to be synced with NL.)

=back

=head1 STEPS

This script performs the following steps:

=head2 Check sysprefs

Check that the necessary sysprefs are set before proceeding.

=cut

my $check_result = NLCheckSysprefs();
if ( $check_result->{'error'} == 1 ) {
    if ( $check_result->{'nlenabled'} == 0 ) { say "* Please activate this function with the NorwegianPatronDBEnable system preference." };
    if ( $check_result->{'endpoint'}  == 0 ) { say "* Please specify an endpoint with the NorwegianPatronDBEndpoint system preference." };
    if ( $check_result->{'userpass'}  == 0 ) { say "* Please fill in the NorwegianPatronDBUsername and NorwegianPatronDBPassword system preferences." };
    exit 0;
}

unless ( $run ) {
    say "* You have not specified --run, no real syncing will be done.";
}

=head2 Find patrons that need to be synced

Patrons with either of these statuses:

=over 4

=item * edited

=item * new

=item * deleted

=back

=cut

my @needs_sync = Koha::Database->new->schema->resultset('BorrowerSync')->search({
    -and => [
      sync     => 1,
      synctype => 'norwegianpatrondb',
      -or => [
        syncstatus => 'edited',
        syncstatus => 'new',
        syncstatus => 'delete',
      ],
    ],
});

=head2 Do the actual sync

Data is synced to NL with NLSync.

=cut

my $sync_success = 0;
my $sync_failed  = 0;
foreach my $borrower ( @needs_sync ) {
    my $cardnumber = $borrower->borrowernumber->cardnumber;
    my $firstname  = $borrower->borrowernumber->firstname;
    my $surname    = $borrower->borrowernumber->surname;
    my $syncstatus = $borrower->syncstatus;
    say "*** Syncing patron: $cardnumber - $firstname $surname ($syncstatus)" if $verbose;
    if ( $run ) {
        my $response = NLSync({ 'patron' => $borrower->borrowernumber });
        if ( $response ) {
            my $result = $response->result;
            if ( $result->{'status'} && $result->{'status'} == 1 ) {
                $sync_success++;
            } else {
                $sync_failed++;
            }
            if ( $result->{'melding'} && $verbose ) {
                say $result->{'melding'};
            }
        }
    }
}

=head2 Summarize if verbose mode is enabled

Specify -v on the command line to get a summary of the syncing operations.

=cut

if ( $verbose ) {
    say "-----------------------------";
    say "Sync succeeded: $sync_success";
    say "Sync failed   : $sync_failed";
}

=head1 OPTIONS

=over 4

=item B<-r, --run>

Actually carry out syncing operations. Without this option, the script will
only report what it would have done, but not change any data, locally or
remotely.

=item B<-v --verbose>

Report on the progress of the script.

=item B<-d --debug>

Even more output.

=item B<-h, -?, --help>

Prints this help message and exits.

=back

=cut

sub get_options {

  # Options
  my $run     = '',
  my $verbose = '';
  my $debug   = '';
  my $help    = '';

  GetOptions (
    'r|run'     => \$run,
    'v|verbose' => \$verbose,
    'd|debug'   => \$debug,
    'h|?|help'  => \$help
  );

  pod2usage( -exitval => 0 ) if $help;

  return ( $run, $verbose, $debug );

}

=head1 AUTHOR

Magnus Enger <digitalutvikling@gmail.com>

=head1 COPYRIGHT

Copyright 2014 Oslo Public Library

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it under the terms
of the GNU General Public License as published by the Free Software Foundation;
either version 3 of the License, or (at your option) any later version.

You should have received a copy of the GNU General Public License along with
Koha; if not, write to the Free Software Foundation, Inc., 51 Franklin Street,
Fifth Floor, Boston, MA 02110-1301 USA.

=cut
