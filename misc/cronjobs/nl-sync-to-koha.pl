#!/usr/bin/perl

# Copyright 2014 Oslo Public Library

=head1 NAME

nl-sync-to-koha.pl - Sync patrons from the Norwegian national patron database (NL) to Koha.

=head1 SYNOPSIS

 perl nl-sync-to-koha.pl -v --run

=cut

use C4::Members::Attributes qw( UpdateBorrowerAttribute );
use Koha::NorwegianPatronDB qw( NLCheckSysprefs NLGetChanged );
use Koha::Patrons;
use Koha::Database;
use Getopt::Long;
use Pod::Usage;
use Modern::Perl;

# Get options
my ( $run, $from, $verbose, $debug ) = get_options();

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

# Do the sync
my $sync_success         = 0;
my $sync_failed          = 0;
my $skipped_local_change = 0;

# Get the borrowers that have been changed
my $result = NLGetChanged( $from );

if ( $verbose ) {
    say 'Number of records: ' . $result->{'antall_poster_returnert'};
    say 'Number of hits:    ' . $result->{'antall_treff'};
    say 'Message:           ' . $result->{'melding'};
    say 'Status:            ' . $result->{'status'};
    say 'Server time:       ' . $result->{'server_tid'};
    say "-----------------------------";
}

# Loop through the patrons
foreach my $patron ( @{ $result->{'kohapatrons'} } ) {
    if ( $verbose ) {
        if ( $patron->{'surname'} ) {
            say "*** Name: " . $patron->{'surname'};
        } else {
            say "*** No name";
        }
        say 'Created by:     ' . $patron->{'_extra'}->{'created_by'};
        say 'Last change by: ' . $patron->{'_extra'}->{'last_change_by'};
    }
    # Only sync in changes made by other libraries
    if ( C4::Context->preference("NorwegianPatronDBUsername") ne $patron->{'_extra'}->{'last_change_by'} ) {
        # Make a copy of the data in the hashref and store it as a hash
        my %clean_patron = %$patron;
        # Delete the extra data from the copy of the hashref
        delete $clean_patron{'_extra'};
        # Find the borrowernumber based on cardnumber
        my $stored_patron = Koha::Patrons->find({ cardnumber => $patron->{cardnumber} });
        my $borrowernumber = $stored_patron->borrowernumber;
        if ( $run ) {
            # FIXME Exceptions must be caught here
            if ( $stored_patron->set(\%clean_patron)->store ) {
                # Get the sync object
                my $sync = Koha::Database->new->schema->resultset('BorrowerSync')->find({
                    'synctype'       => 'norwegianpatrondb',
                    'borrowernumber' => $borrowernumber,
                });
                # Update the syncstatus to 'synced'
                $sync->update( { 'syncstatus' => 'synced' } );
                # Update the 'synclast' attribute with the "server time" ("server_tid") returned by the method
                $sync->update( { 'lastsync' => $result->{'result'}->{'server_tid'} } );
                # Save social security number as attribute
                UpdateBorrowerAttribute(
                    $borrowernumber,
                    { code => 'fnr', attribute => $patron->{'_extra'}->{'socsec'} },
                );
                $sync_success++;
            } else {
                $sync_failed++;
            }
        }
    } else {
        say "Skipped, local change" if $verbose;
        $skipped_local_change++;
    }
}

if ( $verbose ) {
    say "-----------------------------";
    say "Sync succeeded:       $sync_success";
    say "Sync failed   :       $sync_failed";
    say "Skipped local change: $skipped_local_change";
}

=head1 OPTIONS

=over 4

=item B<-r, --run>

Actually carry out syncing operations. Without this option, the script will
only report what it would have done, but not change any data, locally or
remotely.

=item B<-v --verbose>

Report on the progress of the script.

=item B<-f --from>

Date and time to sync from, if this should be different from "1 second past
midnight of the day before". The date should be in this format:

    2014-06-03T00:00:01

=item B<-d --debug>

Even more output.

=item B<-h, -?, --help>

Prints this help message and exits.

=back

=cut

sub get_options {

  # Options
  my $run     = '',
  my $from    = '',
  my $verbose = '';
  my $debug   = '';
  my $help    = '';

  GetOptions (
    'r|run'     => \$run,
    'f|from=s'  => \$from,
    'v|verbose' => \$verbose,
    'd|debug'   => \$debug,
    'h|?|help'  => \$help
  );

  pod2usage( -exitval => 0 ) if $help;

  return ( $run, $from, $verbose, $debug );

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
