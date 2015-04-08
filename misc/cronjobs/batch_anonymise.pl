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

use strict;
use warnings;
use Carp;

BEGIN {

    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use C4::Context;
use C4::Circulation;
use C4::Dates;
use Date::Calc qw(
  Today
  Add_Delta_Days
);
use Getopt::Long;

sub usage {
    print STDERR <<USAGE;
Usage: $0  --days DAYS  [-h|--help]
   --days DAYS        (MANDATORY) anonymise patron history that is older than DAYS days.
   -v --verbose       gives a little more information
   -h --help          prints this help message, and exits, ignoring all
                      other options
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

my ($year,$month,$day) = Today();
my ($newyear,$newmonth,$newday) = Add_Delta_Days ($year,$month,$day,(-1)*$days);
my $formatdate = sprintf "%4d-%02d-%02d",$newyear,$newmonth,$newday;
$verbose and print "Checkouts before $formatdate will be anonymised.\n";

my ($rows, $err_history_not_deleted) = AnonymiseIssueHistory($formatdate);
carp "Anonymisation of reading history failed." if ($err_history_not_deleted);
$verbose and print "$rows checkouts anonymised.\n";

exit(0);
