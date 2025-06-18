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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use strict;
use warnings;

# possible modules to use
use Getopt::Long qw( GetOptions );

use Koha::Script;
use C4::Context;
use Koha::Items;
use Pod::Usage qw( pod2usage );

sub usage {
    pod2usage( -verbose => 2 );
    exit;
}

# Database handle
my $dbh = C4::Context->dbh;

# Benchmarking variables
my $startime   = time();
my $goodcount  = 0;
my $badcount   = 0;
my $totalcount = 0;

# Options
my $verbose;
my $whereclause = '';
my $help;
my $outfile;

GetOptions(
    'o|output:s' => \$outfile,
    'v'          => \$verbose,
    'where:s'    => \$whereclause,
    'help|h'     => \$help,
);

usage() if $help;

if ($whereclause) {
    $whereclause = "WHERE $whereclause";
}

# output log or STDOUT
my $fh;
if ( defined $outfile ) {
    open( $fh, '>', $outfile ) || die("Cannot open output file");
} else {
    open( $fh, '>&', \*STDOUT ) || die("Couldn't duplicate STDOUT: $!");
}

# FIXME Would be better to call Koha::Items->search here
my $sth_fetch = $dbh->prepare("SELECT biblionumber, itemnumber, itemcallnumber FROM items $whereclause");
$sth_fetch->execute();

# fetch info from the search
while ( my ( $biblionumber, $itemnumber, $itemcallnumber ) = $sth_fetch->fetchrow_array ) {

    my $item = Koha::Items->find($itemnumber);
    next unless $item;

    for my $c (qw( itemcallnumber cn_source )) {
        $item->make_column_dirty($c);
    }

    eval { $item->store };
    my $modok = $@ ? 0 : 1;

    if ($modok) {
        $goodcount++;
        print $fh "Touched item $itemnumber\n" if ( defined $verbose );
    } else {
        $badcount++;
        print $fh "ERROR WITH ITEM $itemnumber !!!!\n";
    }

    $totalcount++;

}
close($fh);

# Benchmarking
my $endtime     = time();
my $time        = $endtime - $startime;
my $accuracy    = $totalcount ? ( $goodcount / $totalcount ) * 100 : 0;    # this is a percentage
my $averagetime = 0;
$averagetime = $time / $totalcount if $totalcount;
print "Good: $goodcount, Bad: $badcount (of $totalcount) in $time seconds\n";
printf "Accuracy: %.2f%%\nAverage time per record: %.6f seconds\n", $accuracy, $averagetime if ( defined $verbose );

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

