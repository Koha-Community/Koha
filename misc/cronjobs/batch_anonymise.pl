#!/usr/bin/perl

# Copyright 2011, ByWater Solutions.
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Script -cron;

use C4::Context;
use C4::Log qw( cronlogaction );

use Koha::Database;
use Koha::DateUtils qw(dt_from_string output_pref);
use Koha::Old::Checkouts;
use Koha::Old::Holds;

use Getopt::Long qw( GetOptions );

sub usage {
    print STDERR <<USAGE;
Usage: $0  --days DAYS  [-h|--help]
   --days DAYS        (MANDATORY) anonymise patron history that is older than DAYS days.
   -v --verbose       gives a little more information
   -h --help          prints this help message, and exits, ignoring all
                      other options
Note: If the system preference 'AnonymousPatron' is not defined, NULL will be used.
USAGE
    exit $_[0];
}

my $command_line_options = join( " ", @ARGV );
cronlogaction( { info => $command_line_options } );

my ( $help, $days, $verbose );

GetOptions(
    'h|help'    => \$help,
    'days:i'    => \$days,
    'v|verbose' => \$verbose,
) || usage(1);

if ($help) {
    usage(0);
}

if ( !$days ) {
    print "The days parameter is mandatory.\n\n";
    usage(1);
}

my $date = dt_from_string->subtract( days => $days );

print "Checkouts and holds before "
    . output_pref( { dt => $date, dateformat => 'iso', dateonly => 1 } )
    . " will be anonymised.\n"
    if $verbose;

my $rows = Koha::Old::Checkouts->filter_by_anonymizable->filter_by_last_update(
    { days => $days, timestamp_column_name => 'returndate' } )->anonymize;

$verbose and print int($rows) . " checkouts anonymised.\n";

$rows = Koha::Old::Holds->filter_by_anonymizable->filter_by_last_update( { days => $days } )->anonymize;

$verbose and print int($rows) . " holds anonymised.\n";

cronlogaction( { action => 'End', info => "COMPLETED" } );

exit(0);
