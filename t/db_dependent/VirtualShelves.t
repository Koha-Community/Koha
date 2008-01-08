#!/usr/bin/perl

#
# This file is a test script for C4::VirtualShelves.pm
# Author : Antoine Farnault, antoine@koha-fr.org
#

use Test;
use strict;
use C4::Context;

# Making 30 tests.
BEGIN { plan tests => 30 }

# Getting some borrowers from database.
my $dbh = C4::Context->dbh;
my $query = qq/
    SELECT borrowernumber
    FROM   borrowers
    LIMIT  10
/;
my $sth = $dbh->prepare($query);
$sth->execute;
my @borrowers;
while(my $borrower = $sth->fetchrow){
    push @borrowers, $borrower;
}

# Getting some itemnumber from database
my $query = qq/
    SELECT itemnumber
    FROM   items
    LIMIT  10
/;
my $sth = $dbh->prepare($query);
$sth->execute;
my @items;
while(my $item = $sth->fetchrow){
    push @items, $item;
}

# Getting some biblionumbers from database
my $query = qq/
    SELECT biblionumber
    FROM   biblio
    LIMIT  10
/;
my $sth = $dbh->prepare($query);
$sth->execute;
my @biblionumbers;
while(my $biblionumber = $sth->fetchrow){
    push @biblionumbers, $biblionumber;
}

# ---
my $delete_virtualshelf = qq/
    DELETE FROM  virtualshelf WHERE 1
/;
my $delete_virtualshelfcontent =qq/
    DELETE  FROM  shelfcontents WHERE 1
/;

my $sth = $dbh->prepare($delete_virtualshelf);
$sth->execute;
my $sth = $dbh->prepare($delete_virtualshelfcontent);
$sth->execute;
# ---

#----------------------------------------------------------------------#
#
#           TESTS START HERE
#
#----------------------------------------------------------------------#

use C4::VirtualShelves;
my $version = C4::VirtualShelves->VERSION;
print "\n----------Testing C4::VirtualShelves version ".$version."--------\n";

ok($version);   # First test: the module is loaded & the version is readable.


#-----------------------TEST AddShelf function------------------------#
# usage : $shelfnumber = &AddShelf( $shelfname, $owner, $category);

# creating 10 good shelves.
my @shelves;
for(my $i=0; $i<10;$i++){
     my $ShelfNumber = AddShelf("Shelf_".$i,$borrowers[$i],int(rand(3))+1);
     die "test Not ok, remove some shelves before" if ($ShelfNumber == -1);
     ok($ShelfNumber);   # Shelf creation successful;
     push @shelves, $ShelfNumber if ok($ShelfNumber);
}

ok(10,scalar @shelves); # 10 shelves in @shelves;

# try to create some shelf which already exists.
for(my $i=0;$i<10;$i++){
    my $badNumShelf = AddShelf("Shelf_".int(rand(9)),'','');
    ok(-1,$badNumShelf);   # AddShelf returns -1 if name already exist.
}

#-----------TEST AddToShelf & &AddToShelfFromBiblio & GetShelfContents &  DelFromShelf functions--------------#
# usage : &AddToShelf($itemnumber, $shelfnumber);
# usage : $itemlist = &GetShelfContents($shelfnumber);
# usage : $itemlist = GetShelfContents($shelfnumber);

for(my $i=0; $i<10;$i++){
    my $item = $items[int(rand(9))];
    my $shelfnumber = $shelves[int(rand(9))];
    
    my $itemlistBefore = GetShelfContents($shelfnumber);
    AddToShelf($item,$shelfnumber);
    my $itemlistAfter = GetShelfContents($shelfnumber);
    ok(scalar @$itemlistBefore,scalar (@$itemlistAfter - 1));  # the item has been successfuly added.

    
    # same thing with AddToShelfFromBiblio
    my $biblionumber = $biblionumbers[int(rand(10))];
    &AddToShelfFromBiblio($biblionumber, $shelfnumber);
    my $AfterAgain = GetShelfContents($shelfnumber);
    ok(scalar @$itemlistAfter, scalar (@$AfterAgain -1));
}

#-----------------------TEST ModShelf & GetShelf functions------------------------#
# usage : ModShelf($shelfnumber, $shelfname, $owner, $category )
# usage : (shelfnumber,shelfname,owner,category) = GetShelf($shelfnumber);

for(my $i=0; $i<10;$i++){
    my $rand = int(rand(9));
    my $numA = $shelves[$rand];
    my $nameA = "NewName_".$rand;
    my $ownerA = $borrowers[$rand];
    my $categoryA = int(rand(3))+1;
    
    ModShelf($numA,$nameA,$ownerA,$categoryA);
    my ($numB,$nameB,$ownerB,$categoryB) = GetShelf($numA);
    
    ok($numA,$numB);
    ok($nameA,$nameB);
    ok($ownerB,$ownerA);
    ok($categoryA,$categoryB);
}

#-----------------------TEST DelShelf & DelFromShelf functions------------------------#
# usage : ($status) = &DelShelf($shelfnumber);
# usage : &DelFromShelf( $itemnumber, $shelfnumber);

for(my $i=0; $i<10;$i++){
    my $shelfnumber = $shelves[$i];
    my $status = DelShelf($shelfnumber);
    if($status){
        my $items = GetShelfContents($shelfnumber);
        ok($status,scalar @$items);
        foreach (@$items){ # delete all the item in this shelf
            DelFromShelf($_{'itemnumber'},$shelfnumber);
        }
        ok(DelShelf($shelfnumber));
    }
}
