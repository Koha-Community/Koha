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
use C4::Biblio;
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

my $sth1 = $dbh->prepare("SELECT biblionumber, frameworkcode FROM biblio $whereclause");
$sth1->execute();

# fetch info from the search
while (my ($biblionumber, $frameworkcode) = $sth1->fetchrow_array){
  my $record = GetMarcBiblio($biblionumber);
 
  my $modok = ModBiblio($record, $biblionumber, $frameworkcode);

  if ($modok) {
     $goodcount++;
     print OUT "Touched biblio $biblionumber\n" if (defined $verbose);
  } else {
     $badcount++;
     print OUT "ERROR WITH BIBLIO $biblionumber !!!!\n";
  }

  $totalcount++;

}

# Benchmarking
my $endtime = time();
my $time = $endtime-$startime;
my $accuracy = ($goodcount / $totalcount) * 100; # this is a percentage
my $averagetime = 0;
unless ($time == 0) { $averagetime = $totalcount / $time; };
print "Good: $goodcount, Bad: $badcount (of $totalcount) in $time seconds\n";
printf "Accuracy: %.2f%%\nAverage time per record: %.6f seconds\n", $accuracy, $averagetime if (defined $verbose);

=head1 NAME

touch_all_biblios.pl

=head1 SYNOPSIS

  touch_all_biblios.pl
  touch_all_biblios.pl -v
  touch_all_biblios.pl --where=STRING

=head1 DESCRIPTION

When changes are made to ModBiblio (or the routines that are called by those),
it is sometimes necessary to run ModBiblio on all or some records in the catalog
when upgrading. This script does this.

=over 8

=item B<--help>

Prints this help

=item B<-v>

Provide verbose log information.

=item B<--where>

Limits the search with a user-specified WHERE clause.

=back

=cut

