#!/usr/bin/perl

#
# This file is a test script for C4::VirtualShelves.pm
# Author : Antoine Farnault, antoine@koha-fr.org
#

use Modern::Perl;
use Test::More tests => 82;
use MARC::Record;

use C4::Biblio qw( AddBiblio DelBiblio );
use C4::Context;

# Getting some borrowers from database.
my $dbh = C4::Context->dbh;
my $query = q{
    SELECT borrowernumber
    FROM   borrowers
    LIMIT  10
};
my $sth = $dbh->prepare($query);
$sth->execute;
my @borrowers;
while(my $borrower = $sth->fetchrow){
    push @borrowers, $borrower;
}

# Creating some biblios
my @biblionumbers;
foreach(0..9) {
    my ($biblionumber)= AddBiblio(MARC::Record->new, '');
        #item number ignored
    push @biblionumbers, $biblionumber;
}

# FIXME Why are you deleting my shelves? See bug 10386.
my $delete_virtualshelf = q{
    DELETE FROM  virtualshelves WHERE 1
};
my $delete_virtualshelfcontent = q{
    DELETE  FROM  virtualshelfcontents WHERE 1
};

$sth = $dbh->prepare($delete_virtualshelf);
$sth->execute;
$sth = $dbh->prepare($delete_virtualshelfcontent);
$sth->execute;
# ---

#----------------------------------------------------------------------#
#
#           TESTS START HERE
#
#----------------------------------------------------------------------#

use_ok('C4::VirtualShelves');

#-----------------------TEST AddShelf function------------------------#
# usage : $shelfnumber = &AddShelf( $shelfname, $owner, $category);

# creating 10 good shelves.
my @shelves;
for(my $i=0; $i<10;$i++){
     my $ShelfNumber = AddShelf(
    {shelfname=>"Shelf_".$i, category=>int(rand(2))+1 }, $borrowers[$i] );
     die "test Not ok, remove some shelves before" if ($ShelfNumber == -1);
     ok($ShelfNumber > -1, "created shelf");   # Shelf creation successful;
     push @shelves, $ShelfNumber if $ShelfNumber > -1;
}

ok(10 == scalar @shelves, 'created 10 lists'); # 10 shelves in @shelves;

# try to create some shelf which already exists.
for(my $i=0;$i<10;$i++){
    my @shlf=GetShelf($shelves[$i]);

    # FIXME This test still needs some attention
    # A shelf name is not per se unique ! See report 10386
    #temporary hack: Original test only for public list
    if( $shlf[3]==2 ) {
        my $badNumShelf= AddShelf(
            {shelfname=>"Shelf_".$i, category => 2}, $borrowers[$i]);
        ok(-1==$badNumShelf, 'do not create public lists with duplicate names');
            #AddShelf returns -1 if name already exist.
    }
    else {
        ok(1==1, "This trivial test cannot fail :)"); #leave count intact
    }
}

#-----------TEST AddToShelf & GetShelfContents &  DelFromShelf functions--------------#
# usage : &AddToShelf($biblionumber, $shelfnumber);
# usage : $biblist = &GetShelfContents($shelfnumber);
# usage : $biblist = GetShelfContents($shelfnumber);

my %used = ();
for(my $i=0; $i<10;$i++){
    my $bib = $biblionumbers[int(rand(9))];
    my $shelfnumber = $shelves[int(rand(9))];

    my $key = "$bib\t$shelfnumber";
    my $should_fail = exists($used{$key}) ? 1 : 0;

    my ($biblistBefore,$countbefore) = GetShelfContents($shelfnumber);
    my $status = AddToShelf($bib,$shelfnumber,$borrowers[$i]);
    my ($biblistAfter,$countafter) = GetShelfContents($shelfnumber);

    if ($should_fail) {
        ok(!defined($status), 'failed to add to list when we should');
    } else {
        ok(defined($status), 'added to list when we should');
    }

    if (defined $status) {
        ok($countbefore == $countafter - 1, 'added bib to list');  # the bib has been successfuly added.
    } else {
        ok($countbefore == $countafter,     'did not add duplicate bib to list');  # the bib has been successfuly added.
    }

    $used{$key}++;

}

#-----------------------TEST ModShelf & GetShelf functions------------------------#
# usage : ModShelf($shelfnumber, $shelfname, $owner, $category )
# usage : (shelfnumber,shelfname,owner,category) = GetShelf($shelfnumber);

for(my $i=0; $i<10;$i++){
    my $rand = int(rand(9));
    my $numA = $shelves[$rand];
    my $shelf = { shelfname => "NewName_".$rand,
    category =>  int(rand(2))+1 };

    ModShelf($numA,$shelf);
    my ($numB,$nameB,$ownerB,$categoryB) = GetShelf($numA);

    ok($numA == $numB, 'modified shelf');
    ok($shelf->{shelfname} eq $nameB,     '... and name change took');
    ok($shelf->{category}  eq $categoryB, '... and category change took');
}

#-----------------------TEST DelShelf & DelFromShelf functions------------------------#
# usage : ($status) = &DelShelf($shelfnumber);

for(my $i=0; $i<10;$i++){
    my $shelfnumber = $shelves[$i];
    my $status = DelShelf($shelfnumber);
    ok(1 == $status, "deleted shelf $shelfnumber and its contents");
}

#----------------------- CLEANUP ----------------------------------------------#
DelBiblio($_) for @biblionumbers;
