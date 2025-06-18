#!/usr/bin/perl

# Copyright 2012 C & P Bibliography Services
#
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use strict;
use warnings;

use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );

use Koha::Script -cron;
use Koha::DateUtils qw( dt_from_string );
use C4::Context;
use C4::Biblio qw( UpdateTotalIssues );
use C4::Log    qw( cronlogaction );
use DateTime;
use DateTime::Format::MySQL;
use Time::HiRes qw( time );
use POSIX       qw( ceil strftime );

sub usage {
    pod2usage( -verbose => 2 );
    exit;
}

$| = 1;

# command-line parameters
my $verbose   = 0;
my $test_only = 0;
my $want_help = 0;
my $since;
my $interval;
my $usestats    = 0;
my $useitems    = 0;
my $incremental = 0;
my $progress    = 100;
my $unit;

my $command_line_options = join( " ", @ARGV );
cronlogaction( { info => $command_line_options } );

my $result = GetOptions(
    'v|verbose'    => \$verbose,
    't|test'       => \$test_only,
    's|since=s'    => \$since,
    'i|interval=s' => \$interval,
    'use-stats'    => \$usestats,
    'use-items'    => \$useitems,
    'incremental'  => \$incremental,
    'p|progress=i' => \$progress,
    'h|help'       => \$want_help
);

binmode( STDOUT, ":encoding(UTF-8)" );

if ( defined $since && defined $interval ) {
    print "The --since and --interval options are mutually exclusive.\n\n";
    $want_help = 1;
}

if ( $useitems && $incremental ) {
    print "The --use-items and --incremental options are mutually exclusive.\n\n";
    $want_help = 1;
}

if ( $incremental && !( defined $since || defined $interval ) ) {
    $interval = '24h';
}

unless ( $usestats || $useitems ) {
    print "You must specify either --use-stats and/or --use-items.\n\n";
    $want_help = 1;
}

usage() if $want_help;

my $dbh = C4::Context->dbh;

my $num_bibs_processed = 0;
my $num_bibs_updated   = 0;
my $num_bibs_error     = 0;

my $starttime = time();

process_items() if $useitems;
process_stats() if $usestats;

report();

cronlogaction( { action => 'End', info => "COMPLETED" } );

exit 0;

sub process_items {
    my $query = "SELECT items.biblionumber, SUM(items.issues) FROM items GROUP BY items.biblionumber;";
    process_query($query);
}

sub process_stats {
    if ($interval) {
        my $dt = dt_from_string();

        my %units = (
            h => 'hours',
            d => 'days',
            w => 'weeks',
            m => 'months',
            y => 'years'
        );

        $interval =~ m/([0-9]*)([hdwmy]?)$/;
        $unit  = $2 || 'd';
        $since = DateTime::Format::MySQL->format_datetime( $dt->subtract( $units{$unit} => $1 ) );
    }
    my $limit = '';
    $limit = " WHERE statistics.datetime >= ?" if ( $interval || $since );

    my $query = "SELECT biblio.biblionumber, COUNT(statistics.itemnumber) FROM biblio\
 LEFT JOIN items ON (biblio.biblionumber=items.biblionumber)\
 LEFT JOIN statistics ON (items.itemnumber=statistics.itemnumber AND statistics.type = 'issue')
 $limit\
 GROUP BY biblio.biblionumber";
    process_query( $query, $limit );

}

sub process_query {
    my $query    = shift;
    my $uselimit = shift;
    my $sth      = $dbh->prepare($query);

    if ( $since && $uselimit ) {
        $sth->execute($since);
    } else {
        $sth->execute();
    }

    while ( my ( $biblionumber, $totalissues ) = $sth->fetchrow_array() ) {
        $num_bibs_processed++;
        $totalissues = 0 unless $totalissues;
        print "Processing bib $biblionumber ($totalissues issues)\n"
            if $verbose;
        if ( not $test_only ) {
            my $ret;
            if ( $incremental && $totalissues > 0 ) {
                $ret = UpdateTotalIssues( $biblionumber, $totalissues, undef, 1 );
            } else {
                $ret = UpdateTotalIssues( $biblionumber, 0, $totalissues, 1 );
            }
            if ( $ret == -1 ) {
                print "Error while processing bib $biblionumber\n" if $verbose;
                $num_bibs_error++;
            } elsif ( $ret == 1 ) {
                $num_bibs_updated++;
            }
        }
        if ( not $test_only and ( $num_bibs_processed % $progress ) == 0 ) {
            print_progress($num_bibs_processed);
        }
    }

}

sub report {
    my $endtime   = time();
    my $totaltime = ceil( ( $endtime - $starttime ) * 1000 );
    $starttime = strftime( '%D %T', localtime($starttime) );
    $endtime   = strftime( '%D %T', localtime($endtime) );

    my $summary = <<_SUMMARY_;

Update total issues count script report
=======================================================
Run started at:                         $starttime
Run ended at:                           $endtime
Total run time:                         $totaltime ms
Number of bibs processed:               $num_bibs_processed
Number of bibs modified:                $num_bibs_updated
Number of bibs with error:              $num_bibs_error
_SUMMARY_
    $summary .= "\n****  Ran in test mode only  ****\n" if $test_only;
    print $summary;
}

sub print_progress {
    my $recs = shift;
    print "... processed $recs records\n";
}

=head1 NAME

update_totalissues.pl

=head1 SYNOPSIS

  update_totalissues.pl --use-stats
  update_totalissues.pl --use-items
  update_totalissues.pl --progress=1000
  update_totalissues.pl --since='2012-01-01'
  update_totalissues.pl --interval=30d

=head1 DESCRIPTION

This batch job populates bibliographic records' total issues count based
on historical issue statistics.

=over 8

=item B<--help>

Prints this help

=item B<-v|--verbose>

Provide verbose log information (list every bib modified).

=item B<--use-stats>

Use the data in the statistics table for populating total issues.

=item B<--use-items>

Use items.issues data for populating total issues. Note that issues
data from the items table does not respect the --since or --interval
options, by definition. Also note that if both --use-stats and
--use-items are specified, the count of biblios processed will be
misleading.

=item B<-s|--since=DATE>

Only process issues recorded in the statistics table since DATE.

=item B<-i|--interval=S>

Only process issues recorded in the statistics table in the last N
units of time. The interval should consist of a number with a one-letter
unit suffix. The valid suffixes are h (hours), d (days), w (weeks),
m (months), and y (years). The default unit is days.

=item B<--incremental>

Add the number of issues found in the statistics table to the existing
total issues count. Intended so that this script can be used as a cron
job to update popularity information during low-usage periods. If neither
--since or --interval are specified, incremental mode will default to
processing the last twenty-four hours.

=item B<--progress=N>

Print the progress to standard output after every N records are processed.

=item B<--test>

Only test the popularity population script.

=back

=head1 WARNING

If the time on your database server does not match the time on your Koha
server you will need to take that into account, and probably use the
--since argument instead of the --interval argument for incremental
updating.

=head1 CREDITS

This patch to Koha was sponsored by the Arcadia Public Library and the
Arcadia Public Library Foundation in honor of Jackie Faust-Moreno, late
director of the Arcadia Public Library.

=head1 AUTHOR

Jared Camins-Esakov <jcamins AT cpbibliography DOT com>

=cut
