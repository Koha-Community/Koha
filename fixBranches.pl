#!/usr/bin/perl

# script to fix all the branch settings in the items table of the koha database.

use strict;
use DBI;
use C4::Context;

# This script makes the following substitutions.
# on homebranch field:
my $home_default = 'C';
my %home = ( 'F'  => 'FP' ,
	     'FM' => 'FP' ,
	     'M'  => 'C'  ,
	     'P'  => 'C'  ,
	     'S'  => 'SP' ,
	     'T'  => 'C'  ,
	     'TR' => 'C'  ,
	     'I'  => 'C'  ,
	     'D'  => 'C'  ,
	     'L'  => 'LP' ,
	     'FP' => 'FP' ,
	     'SP' => 'SP' ,
	     'LP' => 'LP' ,
	     'C'  => 'C' );

# on holdingbranch field:
my $hold_default = 'L';
my %hold = ( 'F'  => 'F' ,
	     'FM' => 'FM' ,
	     'M'  => 'M'  ,
	     'P'  => 'P'  ,
	     'S'  => 'S' ,
	     'T'  => 'T'  ,
	     'TR' => 'TR'  ,
	     'I'  => 'I'  ,
	     'D'  => 'D'  ,
	     'L'  => 'L' ,
	     'FP' => 'F' ,
	     'C'  => 'L' ,
	     'SP' => 'S' ,
	     'LP' => 'L' );


# do the substitutions.....
my $dbh = C4::Context->dbh;

my $sth = $dbh->prepare("SELECT barcode, holdingbranch, homebranch FROM items");
$sth->execute();

my $today = localtime(time());
print "Output from fixBranches.pl   $today \n\n";

while (my $item = $sth->fetchrow_hashref) {
    my $oldhold = $item->{'holdingbranch'};
    my $newhold = $hold{$oldhold} ? $hold{$oldhold} : $hold_default ;
    if ($oldhold ne $newhold) {
	my $uth = $dbh->prepare("UPDATE items SET holdingbranch = ? WHERE barcode = ?");
	$uth->execute($newhold, $item->{'barcode'});
	print "$item->{'barcode'} : Holding branch setting changed from $oldhold -> $newhold \n";
	$uth->finish;
    }
    my $oldhome = $item->{'homebranch'};
    my $newhome = $home{$oldhome} ? $home{$oldhome} : $home_default ;
    if ($oldhome ne $newhome) {
	my $uth = $dbh->prepare("UPDATE items SET homebranch = ? WHERE barcode = ?");
	$uth->execute($newhome, $item->{'barcode'});
	print "$item->{'barcode'} : Home branch setting changed from $oldhome -> $newhome \n";
	$uth->finish;
    }
}

print "\nFinished output from fixbranches.pl\n";
