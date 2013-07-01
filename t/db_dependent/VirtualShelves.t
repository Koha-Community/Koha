#!/usr/bin/perl

# This file is a test script for C4::VirtualShelves.pm
# Author : Antoine Farnault, antoine@koha-fr.org
# Larger modifications by Jonathan Druart and Marcel de Rooy

use Modern::Perl;
use Test::More tests => 71;
use MARC::Record;

use C4::Biblio qw( AddBiblio DelBiblio );
use C4::Context;


my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

# Getting some borrowers from database.
my $query = q{SELECT borrowernumber FROM borrowers LIMIT 10};
my $borr_ref=$dbh->selectall_arrayref($query);
if(@$borr_ref==0) { #no borrowers? should not occur of course
    $borr_ref->[0][0]=undef;
        #but even then, we can run this robust test :)
}
my @borrowers;
foreach(1..10) {
    my $t= $_> @$borr_ref ? int(rand()*@$borr_ref): $_-1; #repeat if not enough
    push @borrowers, $borr_ref->[$t][0];
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
for my $i(0..9){
    my $name= randomname();
    my $catg= int(rand(2))+1;
    my $ShelfNumber= AddShelf(
        {
            shelfname => $name,
            category  => $catg,
        },
        $borrowers[$i]);

    if($ShelfNumber>-1) {
        ok($ShelfNumber > -1, "created shelf");   # Shelf creation successful;
    }
    else {
        my $t= C4::VirtualShelves::_CheckShelfName(
            $name, $catg, $borrowers[$i], 0);
        ok($t==0, "Name clash expected on shelf creation");
    }
    push @shelves, {
        number => $ShelfNumber,
        name   => $name,
        catg   => $catg,
        owner  => $borrowers[$i],
    }; #also push the errors
}

# try to create shelves with duplicate names
for my $i(0..9){
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
        }, $borrowers[$i]);
        ok(-1==$badNumShelf, 'do not create public lists with duplicate names');
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
        ok(-1==$badNumShelf, 'do not create private lists with duplicate name for same user');
        DelShelf($badNumShelf) if $badNumShelf>-1; #delete if went wrong..
    }
}

#-----------TEST AddToShelf & GetShelfContents &  DelFromShelf functions--------------#
# usage : &AddToShelf($biblionumber, $shelfnumber);
# usage : $biblist = &GetShelfContents($shelfnumber);
# usage : $biblist = GetShelfContents($shelfnumber);

my %used = ();
for my $i(0..9){
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
        ok($countbefore == $countafter, 'did not add duplicate bib to list');
    }

    $used{$key}++;
}

#-----------------------TEST ModShelf & GetShelf functions------------------------#
# usage : ModShelf($shelfnumber, $shelfname, $owner, $category )
# usage : (shelfnumber,shelfname,owner,category) = GetShelf($shelfnumber);

for my $i(0..9){
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
        ok($numA == $numB, 'modified shelf');
        ok($shelf->{shelfname} eq $nameB,     '... and name change took');
        ok($shelf->{category}  eq $categoryB, '... and category change took');
    }
    else {
        ok(1, "No ModShelf for $newname") for 1..3;
    }
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
