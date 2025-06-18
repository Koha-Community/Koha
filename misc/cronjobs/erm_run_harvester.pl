#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2022 PTFS Europe
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );
use POSIX;

use C4::Log         qw( cronlogaction );
use Koha::DateUtils qw( dt_from_string );
use Koha::ERM::EUsage::UsageDataProviders;
use Koha::Script -cron;

=head1 NAME

erm_run_harvester.pl This script will run the SUSHI harvesting for usage data providers

=cut

=head1 SYNOPSIS

erm_run_harvester.pl
  --begin-date <YYYY-MM-DD>
  [ --dry-run ][ --debug ][ --end-date <YYYY-MM-DD> ]

 Options:
   --help                         brief help message
   --man                          detailed help message
   --debug                        print additional debug messages during run
   --dry-run                      test run only, do not harvest data
   --begin-date <YYYY-MM-DD>      date to harvest from
   --end-date <YYYY-MM-DD>        date to harvest until, defaults to today if not set

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Print a detailed help message and exits.

=item B<--debug>

Add debug statements to run

=item B<--begin-date>

Date from which to harvest, previously harvested data will be ignored

=item B<--end-date>

Date to harvest until, defaults to today if not set

=item B<--dry-run>

Test run only, do not harvest

=back

=head1 DESCRIPTION

This script fetches usage data from ERM data providers defined in the interface.

=head2 Configuration

This script harvests from the given date to the specified end date, or until today

=head1 USAGE EXAMPLES

C<erm_run_harvester.pl> - With no arguments help is printed


C<erm_run_harvester.pl --begin-date 2000-01-01> - Harvest from the given date until today

C<erm_run_harvester.pl --begin-date 2000-01-01 --end-date 2024-01-01> - Harvest from the given date until the end date

C<erm_run_harvester.pl --begin-date 2000-01-01 --end-date 2024-01-01 --debug --dry-run> - Dry run, with debuig information

=cut

my $command_line_options = join( " ", @ARGV );
cronlogaction( { info => $command_line_options } );

# Command line option values
my $help       = 0;
my $man        = 0;
my $begin_date = 0;
my $end_date   = 0;
my $dry_run    = 0;
my $debug      = 0;

my $options = GetOptions(
    'h|help'       => \$help,
    'm|man'        => \$man,
    'begin-date=s' => \$begin_date,
    'end-date=s'   => \$end_date,
    'dry-run'      => \$dry_run,
    'debug'        => \$debug
);

pod2usage(1)               if $help;
pod2usage( -verbose => 2 ) if $man;

my $udproviders = Koha::ERM::EUsage::UsageDataProviders->search( { active => 1 } );
unless ( scalar @{ $udproviders->as_list() } ) {
    die "ERROR: No usage data providers found.";
}

unless ($begin_date) {
    print "ERROR: You must specify a begin-date\n\n";
    pod2usage(1);
}

debug_msg("Dry run: Harvests will not be enqueued") if $dry_run;
while ( my $udprovider = $udproviders->next ) {
    debug_msg(
        sprintf(
            "Processing usage data provider #%d - %s", $udprovider->erm_usage_data_provider_id, $udprovider->name
        )
    );

    my $harvest_begin_date = dt_from_string($begin_date);
    my $harvest_end_date   = dt_from_string($end_date) || dt_from_string();

    if ( $harvest_begin_date > $harvest_end_date ) {
        die sprintf(
            "ERROR: begin-date must be earlier than end-date. Begin is %s and end date is %s",
            $harvest_begin_date->ymd,
            $harvest_end_date->ymd,
        );
    }

    if ( !$dry_run ) {
        my $job_ids = $udprovider->enqueue_sushi_harvest_jobs(
            {
                begin_date => $harvest_begin_date->ymd,
                end_date   => $harvest_end_date->ymd
            }
        );
        my $report_type_jobs = join ", ", map { $_->{report_type} . ': Job ID #' . $_->{job_id} } @{$job_ids};

        debug_msg(
            sprintf(
                " - Harvest job enqueued (yyyy-mm-dd):\n - Begin date: %s \n - End date: %s \n - %s",
                $harvest_begin_date->ymd,
                $harvest_end_date->ymd,
                $report_type_jobs
            )
        );
    }

}

cronlogaction( { action => 'End', info => "COMPLETED" } );

sub debug_msg {
    my ($msg) = @_;

    if ( !$debug ) {
        return;
    }

    if ( ref $msg eq 'HASH' ) {
        use Data::Dumper;
        $msg = Dumper $msg;
    }
    print STDERR "$msg\n";
}
