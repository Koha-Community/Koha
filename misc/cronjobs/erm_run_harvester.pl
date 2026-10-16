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

use Koha::DateUtils qw( dt_from_string );
use Koha::ERM::EUsage::UsageDataProviders;
use Koha::Script -cron;
use Scalar::Util qw( blessed );
use Try::Tiny    qw( catch try );

=head1 NAME

erm_run_harvester.pl This script will run the SUSHI harvesting for usage data providers

=cut

=head1 SYNOPSIS

erm_run_harvester.pl
  --begin-date <YYYY-MM-DD>
  [ --dry-run ][ --debug ][ --end-date <YYYY-MM-DD> ][ -p|--provider-id <id> ... ]

 Options:
   --help                         brief help message
   --man                          detailed help message
   --debug                        print additional debug messages during run
   --dry-run                      list the jobs that would be enqueued, do not enqueue them
   --begin-date <YYYY-MM-DD>      date to harvest from
   --end-date <YYYY-MM-DD>        date to harvest until, defaults to today; a later date is reduced to today
   -p|--provider-id <id> ...      harvest only given providers

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

Date to harvest until, defaults to today. A date after today is reduced to
today, so no job is enqueued for a month that has not happened yet.

=item B<-p|--provider-id ...>

Provider IDs that should be harvested; harvest all active providers if not set

=item B<--dry-run>

List the report types and the monthly periods that would be enqueued for each
provider, without enqueuing any job

=back

=head1 DESCRIPTION

This script fetches usage data from ERM data providers defined in the interface.

=head2 Configuration

This script harvests from the given date to the specified end date, or until today.
One background job is enqueued for each report type of the provider and for each
calendar month in the date range.

=head1 USAGE EXAMPLES

C<erm_run_harvester.pl> - With no arguments help is printed


C<erm_run_harvester.pl --begin-date 2000-01-01> - Harvest from the given date until today

C<erm_run_harvester.pl --begin-date 2000-01-01 --end-date 2024-01-01> - Harvest from the given date until the end date

C<erm_run_harvester.pl --begin-date 2000-01-01 --provider-id 1 --provider-id 3> - Harvest from the given date until today, but only the given providers

C<erm_run_harvester.pl --begin-date 2000-01-01 --end-date 2024-01-01 --debug --dry-run> - Dry run, with debug information

=cut

# Command line option values
my $help         = 0;
my $man          = 0;
my $begin_date   = 0;
my $end_date     = 0;
my @provider_ids = ();
my $dry_run      = 0;
my $debug        = 0;

my $options = GetOptions(
    'h|help'          => \$help,
    'm|man'           => \$man,
    'begin-date=s'    => \$begin_date,
    'end-date=s'      => \$end_date,
    'p|provider-id:s' => \@provider_ids,
    'dry-run'         => \$dry_run,
    'debug'           => \$debug
);

pod2usage(1)               if $help;
pod2usage( -verbose => 2 ) if $man;

my %search_condition = ( active => 1 );
if ( scalar @provider_ids ) {
    $search_condition{erm_usage_data_provider_id} = { -in => \@provider_ids };
}
my $udproviders = Koha::ERM::EUsage::UsageDataProviders->search( \%search_condition );
unless ( scalar @{ $udproviders->as_list() } ) {
    die "ERROR: No usage data providers found.";
}

unless ($begin_date) {
    print "ERROR: You must specify a begin-date\n\n";
    pod2usage(1);
}

debug_msg("Dry run: no harvest job will be enqueued") if $dry_run;
while ( my $udprovider = $udproviders->next ) {
    debug_msg(
        sprintf(
            "Processing usage data provider #%d - %s", $udprovider->erm_usage_data_provider_id, $udprovider->name
        )
    );

    my $harvest_begin_date = dt_from_string($begin_date);
    my $harvest_end_date   = dt_from_string($end_date) || dt_from_string();

    my @report_types = split /;/, $udprovider->report_types;
    my $periods      = try {
        $udprovider->harvest_periods(
            {
                begin_date => $harvest_begin_date->ymd,
                end_date   => $harvest_end_date->ymd
            }
        );
    } catch {
        die sprintf( "ERROR: %s\n", blessed $_ && $_->can('error') ? $_->error : $_ );
    };
    my $periods_text = join "\n - ", map { sprintf( "%s to %s", $_->{begin_date}, $_->{end_date} ) } @{$periods};

    if ($dry_run) {
        print sprintf(
            "Dry run: %d job(s) would be enqueued for provider #%d, one per report type (%s) and month:\n - %s\n",
            scalar(@report_types) * scalar( @{$periods} ),
            $udprovider->erm_usage_data_provider_id,
            join( ", ", @report_types ),
            $periods_text
        );
        next;
    }

    my $jobs = $udprovider->enqueue_sushi_harvest_jobs(
        {
            begin_date => $harvest_begin_date->ymd,
            end_date   => $harvest_end_date->ymd
        }
    );
    my %jobs_by_report_type;
    push @{ $jobs_by_report_type{ $_->{report_type} } }, $_ for @{$jobs};

    my $report_type_jobs = join "\n - ", map {
        my $type_jobs = $jobs_by_report_type{$_};
        sprintf(
            "%s: %d job(s) (%s to %s), Job IDs %s",
            $_,
            scalar @{$type_jobs},
            substr( $type_jobs->[0]->{begin_date}, 0, 7 ),
            substr( $type_jobs->[-1]->{end_date},  0, 7 ),
            join( ", ", map { '#' . $_->{job_id} } @{$type_jobs} )
        );
    } grep { $jobs_by_report_type{$_} } @report_types;

    debug_msg(
        sprintf(
            " - Harvest jobs enqueued (yyyy-mm-dd):\n - Begin date: %s \n - End date: %s \n - %s",
            $periods->[0]->{begin_date},
            $periods->[-1]->{end_date},
            $report_type_jobs
        )
    );
}

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
