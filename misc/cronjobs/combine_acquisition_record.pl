#!/usr/bin/perl

# Copyright 2016 Koha-Suomi Oy
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;
use C4::Context;
use Getopt::Long;
use POSIX qw/strftime/;
use C4::Reserves;

my $help;
my $verbose = 1;
my $separated;

GetOptions(
    'h|help'      => \$help,
    'v|verbose=i' => \$verbose,
    's|separated' => \$separated,
);
my $usage = << 'ENDUSAGE';

This script combines acquisition records and removes all additionals. This can be used for combining all same records
or only records which have same branchcode prefix.

This script has the following parameters :
    -h --help: this message
    -v --verbose
    -s --separated: this is for combining same branchcode prefix, have to set before verbose to work

ENDUSAGE

if ($help) {
    print $usage;
    exit;
}


#Preparing variables
my @branches;
my $currentbranch = '';

#Let's start by getting all the branchcodes

my $dbh = C4::Context->dbh;
my $query = "SELECT * FROM branches";
my $sth = $dbh->prepare($query);

$sth->execute();

#Adding branchcodes to the @branches list
while (my $branch = $sth->fetchrow_hashref){
	#Getting the first 3 letters from branchcode to identify the city
	#where library is located

	my $prefix = substr($branch->{'branchcode'}, 0, 3);

	#Leaving the duplicates out of the @branches list
	if($currentbranch ne $prefix){
		push @branches, $prefix;
	}

    $currentbranch = $prefix;
}

#Now we are getting current time
my $date = time();

#Now we include all the orders from specified time span

my $days = 1; #This variable is used to determine how old orders we include in this merge
$date = $date - ($days * 24 * 60 * 60);

#Parsing the date in to correct format
my $datestring = strftime "%F", localtime($date);

print "Finding an existing record for records ordered after $datestring.\n" if $verbose;
print "Fetching all the ordered items.\n" if $verbose;
#Here we go through every new item that has been ordered to a specific branch
foreach my $branch(@branches){
	my $orders;
	#Getting every unique item from ordered items
	$query = "SELECT bi.isbn, b.title, bi.issn, bi.ean, aq.biblionumber
			  FROM aqorders aq
			  JOIN items i ON i.biblionumber = aq.biblionumber
			  JOIN biblioitems bi ON bi.biblioitemnumber = i.biblioitemnumber
			  JOIN biblio b ON b.biblionumber = i.biblionumber
			  WHERE aq.entrydate >= ? ";
	$query .= "AND i.homebranch LIKE concat(?, '%') " if $separated;
	$query .= "GROUP BY aq.biblionumber
			  ORDER BY aq.biblionumber, b.title, bi.isbn, bi.issn, bi.ean
			  ASC";

	print "ITEMS: $query\n" if $verbose > 1;

	$sth = $dbh->prepare($query);
	$separated ? $sth->execute($datestring, $branch) : $sth->execute($datestring);

	while(my $row = $sth->fetchrow_arrayref()){
		push @$orders, [@$row];
	}
	#Finding all the ordered items with a specific isbn
	foreach my $order(@$orders){
		print "Looking for an existing item for @$order[4]. \n" if $verbose;

		if(@$order[0]){
			# If the record has isbn number

			#Next step is to find the smallest biblionumber in the current branch that holds
			#the current isbn number
			$query = "SELECT min(bi.biblionumber)
					  FROM biblioitems bi
					  JOIN items i ON i.biblioitemnumber = bi.biblioitemnumber
					  JOIN biblio b ON b.biblionumber = i.biblionumber
					  WHERE bi.isbn = ? ";
			$query .= "AND i.homebranch LIKE concat(?, '%') " if $separated;
			$query .= "AND b.title = ?";


			$sth = $dbh->prepare($query);
			$separated ? $sth->execute(@$order[0], $branch, @$order[1]) : $sth->execute(@$order[0], @$order[1]);

		}elsif(@$order[2]){
			# If the record has issn number

			$query = "SELECT min(bi.biblionumber)
					  FROM biblioitems bi
					  JOIN items i ON i.biblioitemnumber = bi.biblioitemnumber
					  JOIN biblio b ON b.biblionumber = i.biblionumber
					  WHERE bi.issn = ? ";
			$query .= "AND i.homebranch LIKE concat(?, '%') " if $separated;
			$query .= "AND b.title = ?";


			$sth = $dbh->prepare($query);
			$separated ? $sth->execute(@$order[2], $branch, @$order[1]) : $sth->execute(@$order[2], @$order[1]);

		}elsif(@$order[3]){
			# If the record has no isbn nor issn

			$query = "SELECT min(bi.biblionumber)
					  FROM biblioitems bi
					  JOIN items i ON i.biblioitemnumber = bi.biblioitemnumber
					  JOIN biblio b ON b.biblionumber = i.biblionumber
					  WHERE bi.ean = ? ";
			$query .= "AND i.homebranch LIKE concat(?, '%') " if $separated;
			$query .= "AND b.title = ?";


			$sth = $dbh->prepare($query);
			$separated ? $sth->execute(@$order[3], $branch, @$order[1]) : $sth->execute(@$order[3], @$order[1]);
		}else{
			# This happens if the record doesn't have isbn, issn or author. I doubt that this really happens
			# but just in case we have to skip to the next record (It's too unreliable to use title only to match records)
			print "Existing item not found\n" if $verbose;
			next;
		}

		my $minbiblionumber = $sth->fetchrow_arrayref;

		#And now the last step is to update the smallest biblionumber to items and aqorders tables
		#and remove the now useless items from biblio and biblioitems tables
		next unless @$minbiblionumber[0];
		if(@$minbiblionumber[0] ne @$order[4]){
			print "Merging biblio record @$order[4] with @$minbiblionumber\n" if $verbose;

			#Updating items table
			$query = "UPDATE items
					  SET biblionumber = ?, biblioitemnumber = ?
					  WHERE biblionumber = ? ";
			$query .= "AND homebranch LIKE concat(?, '%') " if $separated;

			$sth = $dbh->prepare($query);
			$separated ?  $sth->execute(@$minbiblionumber[0], @$minbiblionumber[0], @$order[4], $branch) : $sth->execute(@$minbiblionumber[0], @$minbiblionumber[0], @$order[4]);

			#Updating aqorders table
			$query = "UPDATE aqorders
					  SET biblionumber = ?
					  WHERE biblionumber = ?";

			$sth = $dbh->prepare($query);
			$sth->execute(@$minbiblionumber[0], @$order[4]);

			print "Merging reserves from @$order[4] with @$minbiblionumber\n" if $verbose;

			#Updating reserves table
			$query = "UPDATE reserves
					  SET biblionumber = ?
					  WHERE biblionumber = ?";

			$sth = $dbh->prepare($query);
			$sth->execute(@$minbiblionumber[0], @$order[4]);

			print "Fixing priority for patrons\n" if $verbose;

			C4::Reserves::_FixPriority({ biblionumber => @$minbiblionumber[0] });

			#Deleting unnecessary item from biblioitems table
			$query = "DELETE FROM biblioitems
					  WHERE biblionumber = ?";

			$sth = $dbh->prepare($query);
			$sth->execute(@$order[4]);

			#Deleting unnecessary item from biblio table
			$query = "DELETE FROM biblio
					  WHERE biblionumber = ?";

			$sth = $dbh->prepare($query);
			$sth->execute(@$order[4]);
		}else{
			print "Existing item not found\n" if $verbose;
		}
	}#foreach my $order
}#foreach my $branch
