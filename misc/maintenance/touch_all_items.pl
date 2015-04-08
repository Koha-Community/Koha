#!/usr/bin/perl
#
# Copyright (C) 2011 ByWater Solutions
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
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

# possible modules to use
use Getopt::Long;
use C4::Context;
use C4::Items;
use Pod::Usage;


sub usage {
    pod2usage( -verbose => 2 );
    exit;
}

# Database handle
my $dbh = C4::Context->dbh;

# Benchmarking variables
my $startime = time();
my $goodcount = 0;
my $badcount = 0;
my $totalcount = 0;

# Options
my $verbose;
my $whereclause = '';
my $help;
my $outfile;

GetOptions(
  'o|output:s' => \$outfile,
  'v' => \$verbose,
  'where:s' => \$whereclause,
  'help|h'   => \$help,
);

usage() if $help;

if ($whereclause) {
   $whereclause = "WHERE $whereclause";
}

# output log or STDOUT
if (defined $outfile) {
   open (OUT, ">$outfile") || die ("Cannot open output file");
} else {
   open(OUT, ">&STDOUT") || die ("Couldn't duplicate STDOUT: $!");
}

my $sth_fetch = $dbh->prepare("SELECT biblionumber, itemnumber, itemcallnumber FROM items $whereclause");
$sth_fetch->execute();

# fetch info from the search
while (my ($biblionumber, $itemnumber, $itemcallnumber) = $sth_fetch->fetchrow_array){
   
  my $modok = ModItem({itemcallnumber => $itemcallnumber}, $biblionumber, $itemnumber);

  if ($modok) {
     $goodcount++;
     print OUT "Touched item $itemnumber\n" if (defined $verbose);
  } else {
     $badcount++;
     print OUT "ERROR WITH ITEM $itemnumber !!!!\n";
  }

  $totalcount++;

}

# Benchmarking
my $endtime = time();
my $time = $endtime-$startime;
my $accuracy = ($goodcount / $totalcount) * 100; # this is a percentage
my $averagetime = 0;
unless ($time == 0) {$averagetime = $totalcount / $time;};
print "Good: $goodcount, Bad: $badcount (of $totalcount) in $time seconds\n";
printf "Accuracy: %.2f%%\nAverage time per record: %.6f seconds\n", $accuracy, $averagetime if (defined $verbose);

=head1 NAME

touch_all_items.pl

=head1 SYNOPSIS

  touch_all_items.pl
  touch_all_items.pl -v
  touch_all_items.pl --where=STRING

=head1 DESCRIPTION

When changes are made to ModItem (or the routines that are called by it), it is
sometimes necessary to run ModItem on all or some records in the catalog when
upgrading. This script does that.

=over 8

=item B<--help>

Prints this help

=item B<-v>

Provide verbose log information.

=item B<--where>

Limits the search with a user-specified WHERE clause.

=back

=cut

