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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Getopt::Long qw( GetOptions );
use Koha::DateUtils qw( dt_from_string );
use POSIX;

use Koha::Script;
use Koha::ERM::EUsage::UsageDataProviders;

# Command line option values
my $get_help   = 0;
my $begin_date = 0;
my $end_date   = 0;
my $dry_run    = 0;
my $debug      = 0;

my $options = GetOptions(
    'h|help'       => \$get_help,
    'begin-date=s' => \$begin_date,
    'end-date=s'   => \$end_date,
    'dry-run'      => \$dry_run,
    'debug'        => \$debug
);

if ($get_help) {
    get_help();
    exit 1;
}

my $udproviders = Koha::ERM::EUsage::UsageDataProviders->search( { active => 1 } );
unless ( scalar @{ $udproviders->as_list() } ) {
    die "ERROR: No usage data providers found.";
}

unless ($begin_date) {
    die "ERROR: Please specify a begin-date";
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

sub get_help {
    print <<"HELP";
$0: Run a SUSHI harvesting for a ERM usage data provider

This script will run the SUSHI harvesting for usage data providers

Parameters:
    --help or -h                         get help
    --begin-date                         begin date for the harvest in yyyy-mm-dd format (e.g.: '2023-08-21')
    --end-date                           end date for the harvest in yyyy-mm-dd format (e.g.: '2023-08-21')
    --dry-run                            only produce a run report, without actually doing anything permanent
    --debug                              print additional debugging info during run

Usage example:
./misc/cronjobs/erm_run_harvester.pl --begin-date 2023-06-21 --debug

HELP
}
