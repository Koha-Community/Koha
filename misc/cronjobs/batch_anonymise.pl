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
use Koha::Old::Checkouts;
use Koha::Old::Holds;

use Date::Calc qw( Add_Delta_Days Today );
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

my ( $help, $days, $verbose );

GetOptions(
    'h|help'       => \$help,
    'days:i'       => \$days,
    'v|verbose'    => \$verbose,
) || usage(1);

if ($help) {
    usage(0);
}

if ( !$days  ) {
    print "The days parameter is mandatory.\n\n";
    usage(1);
}

cronlogaction();

my ($year,$month,$day) = Today();
my ($newyear,$newmonth,$newday) = Add_Delta_Days ($year,$month,$day,(-1)*$days);
my $formatdate = sprintf "%4d-%02d-%02d",$newyear,$newmonth,$newday;
$verbose and print "Checkouts and holds before $formatdate will be anonymised.\n";

my $rows = Koha::Old::Checkouts
          ->filter_by_anonymizable
          ->filter_by_last_update( { days => $days, timestamp_column_name => 'returndate' })
          ->anonymize;

$verbose and print int($rows) . " checkouts anonymised.\n";

$rows = Koha::Old::Holds
          ->filter_by_anonymizable
          ->filter_by_last_update( { days => $days } )
          ->anonymize;

$verbose and print int($rows) . " holds anonymised.\n";

exit(0);
