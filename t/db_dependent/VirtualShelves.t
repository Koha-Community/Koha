#!/usr/bin/perl

# This file is a test script for C4::VirtualShelves.pm
# Author : Antoine Farnault, antoine@koha-fr.org
# Larger modifications by Jonathan Druart and Marcel de Rooy

use Modern::Perl;
use Test::More tests => 96;
use MARC::Record;

use C4::Biblio qw( AddBiblio DelBiblio );
use C4::Context;
use C4::Members qw( AddMember );


my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

# Create some borrowers
my @borrowernumbers;
for my $i ( 1 .. 10 ) {
    my $borrowernumber = AddMember(
        firstname =>  'my firstname',
        surname => 'my surname ' . $i,
        categorycode => 'S',
        branchcode => 'CPL',
    );
    push @borrowernumbers, $borrowernumber;
}

# Creating some biblios
my @biblionumbers;
foreach(0..9) {
    my ($biblionumber)= AddBiblio(MARC::Record->new, '');
        #item number ignored
    push @biblionumbers, $biblionumber;
}

#----------------------------------------------------------------------#
#
#           TESTS START HERE
#
#----------------------------------------------------------------------#

use_ok('C4::VirtualShelves');

#-----------------------TEST AddShelf function------------------------#
# usage : $shelfnumber = &AddShelf( $shelfname, $owner, $category);

# creating shelves (could be <10 when names are not unique)
my @shelves;
for my $i (0..9){
    my $name= randomname();
    my $catg= int(rand(2))+1;
    my $ShelfNumber= AddShelf(
        {
            shelfname => $name,
            category  => $catg,
        },
        $borrowernumbers[$i]);

    if($ShelfNumber>-1) {
        ok($ShelfNumber > -1, "created shelf");   # Shelf creation successful;
    }
    else {
        my $t= C4::VirtualShelves::_CheckShelfName(
            $name, $catg, $borrowernumbers[$i], 0);
        is($t, 0, "Name clash expected on shelf creation");
    }
    push @shelves, {
        number => $ShelfNumber,
        name   => $name,
        catg   => $catg,
        owner  => $borrowernumbers[$i],
    }; #also push the errors
}

# try to create shelves with duplicate names
for my $i (0..9){
    if($shelves[$i]->{number}<0) {
        ok(1, 'skip duplicate test for earlier name clash');
        next;
    }
    my @shlf=GetShelf($shelves[$i]->{number}); #number, name, owner, catg, ...

    # A shelf name is not per se unique!
    if( $shlf[3]==2 ) { #public list: try to create with same name
        my $badNumShelf= AddShelf( {
            shelfname=> $shelves[$i]->{name},
            category => 2
        }, $borrowernumbers[$i]);
        is($badNumShelf, -1, 'do not create public lists with duplicate names');
            #AddShelf returns -1 if name already exist.
        DelShelf($badNumShelf) if $badNumShelf>-1; #delete if went wrong..
    }
    else { #private list, try to add another one for SAME user (owner)
        my $badNumShelf= defined($shlf[2])? AddShelf(
            {
                shelfname=> $shelves[$i]->{name},
                category => 1,
            },
            $shlf[2]): -1;
        is($badNumShelf, -1, 'do not create private lists with duplicate name for same user');
        DelShelf($badNumShelf) if $badNumShelf>-1; #delete if went wrong..
    }
}

#-----------TEST AddToShelf & GetShelfContents &  DelFromShelf functions--------------#
# usage : &AddToShelf($biblionumber, $shelfnumber);
# usage : $biblist = &GetShelfContents($shelfnumber);
# usage : $biblist = GetShelfContents($shelfnumber);

my %used = ();
for my $i (0..9){
    my $bib = $biblionumbers[int(rand(9))];
    my $shelfnumber = $shelves[int(rand(9))]->{number};
    if($shelfnumber<0) {
        ok(1, 'skip add to list-test for shelf -1');
        ok(1, 'skip counting list entries for shelf -1');
        next;
    }

    my $key = "$bib\t$shelfnumber";
    my $should_fail = exists($used{$key}) ? 1 : 0;
    #FIXME We assume here that we have permission to add..
    #The different permissions could be tested too.

    my ($biblistBefore,$countbefore) = GetShelfContents($shelfnumber);
    my $status = AddToShelf($bib,$shelfnumber,$borrowernumbers[$i]);
    my ($biblistAfter,$countafter) = GetShelfContents($shelfnumber);

    if ($should_fail) {
        ok(!defined($status), 'failed to add to list when we should');
    } else {
        ok(defined($status), 'added to list when we should');
    }

    if (defined $status) {
        is($countbefore, $countafter - 1, 'added bib to list');  # the bib has been successfuly added.
    } else {
        is($countbefore, $countafter, 'did not add duplicate bib to list');
    }

    $used{$key}++;
}

#-----------------------TEST ModShelf & GetShelf functions------------------------#
# usage : ModShelf($shelfnumber, $shelfname, $owner, $category )
# usage : (shelfnumber,shelfname,owner,category) = GetShelf($shelfnumber);

for my $i (0..9){
    my $rand = int(rand(9));
    my $numA = $shelves[$rand]->{number};
    if($numA<0) {
        ok(1, 'Skip ModShelf test for shelf -1');
        ok(1, 'Skip ModShelf test for shelf -1');
        ok(1, 'Skip ModShelf test for shelf -1');
        next;
    }
    my $newname= randomname();
    my $shelf = {
        shelfname => $newname,
        category =>  3-$shelves[$rand]->{catg}, # tric: 1->2 and 2->1
    };
    #check name change (with category change)
    if(C4::VirtualShelves::_CheckShelfName($newname,$shelf->{category},
            $shelves[$rand]->{owner}, $numA)) {
        ModShelf($numA,$shelf);
        my ($numB,$nameB,$ownerB,$categoryB) = GetShelf($numA);
        is($numA, $numB, 'modified shelf');
        is($shelf->{shelfname}, $nameB,     '... and name change took');
        is($shelf->{category}, $categoryB, '... and category change took');
    }
    else {
        ok(1, "No ModShelf for $newname") for 1..3;
    }
}

#----------------------- TEST AddShare ----------------------------------------#

#first count the number of shares in the table; keep in mind that AddShare may
#delete some expired records while housekeeping
my $sql_sharecount="select count(*) from virtualshelfshares where DATEDIFF(sharedate, NOW())>0";
my $cnt1=$dbh->selectrow_array($sql_sharecount);

#try to add a share without shelfnumber: should fail
AddShare(0, 'abcdefghij');
my $cnt2=$dbh->selectrow_array($sql_sharecount);
is($cnt1,$cnt2, "Did not add an invalid share record");

#add another share: should be okay
#AddShare assumes that you tested if category==private (so we could actually
#be doing something illegal here :)
my $n=$shelves[0]->{number};
if($n<0) {
    ok(1, 'Skip AddShare for shelf -1');
}
else {
    AddShare($n, 'abcdefghij');
    my $cnt3=$dbh->selectrow_array($sql_sharecount);
    is(1+$cnt2, $cnt3, "Added one new share record with invitekey");
}

#----------------------- TEST AcceptShare -------------------------------------#

# test accepting a wrong key
my $testkey= 'keyisgone9';
my $acctest="delete from virtualshelfshares where invitekey=?";
$dbh->do($acctest,undef,($testkey)); #just be sure it does not exist
$acctest="select shelfnumber from virtualshelves";
my ($accshelf)= $dbh->selectrow_array($acctest);
is(AcceptShare($accshelf,$testkey,$borrowernumbers[0]),undef,'Did not accept invalid key');

# test accepting a good key
if( AddShare($accshelf,$testkey) && $borrowernumbers[0] ) {
    is(AcceptShare($accshelf, $testkey, $borrowernumbers[0]),1,'Accepted share');
}
else { #cannot accept if addshared failed somehow
    ok(1, 'Skipped second AcceptShare test');
}

#----------------------- TEST IsSharedList ------------------------------------#

for my $i (0..9) {
    my $sql="select count(*) from virtualshelfshares where shelfnumber=? and borrowernumber is not null";
    my $sh=$shelves[$i]->{number};
    my ($n)=$dbh->selectrow_array($sql,undef,($sh));
    is(IsSharedList($sh),$n? 1: '', "Checked IsSharedList for shelf $sh");
}

#----------------TEST DelShelf & DelFromShelf functions------------------------#

for my $i (0..9){
    my $shelfnumber = $shelves[$i]->{number};
    if($shelfnumber<0) {
        ok(1, 'Skip DelShelf for shelf -1');
        next;
    }
    my $status = DelShelf($shelfnumber);
    is($status, 1, "deleted shelf $shelfnumber and its contents");
}

#----------------------- TEST RemoveShare -------------------------------------#

my $remshr_test="select borrowernumber, shelfnumber from virtualshelfshares where borrowernumber is not null";
my @remshr_shelf= $dbh->selectrow_array($remshr_test);
if(@remshr_shelf) {
    is(RemoveShare(@remshr_shelf),1,'Removed a shelf share');
}
else {
    ok(1,'Skipped RemoveShare test');
}

#----------------------- SOME SUBS --------------------------------------------#

sub randomname {
    my $rv='';
    for(0..19) {
        $rv.= ('a'..'z','A'..'Z',0..9) [int(rand()*62)];
    }
    return $rv;
}

$dbh->rollback;
