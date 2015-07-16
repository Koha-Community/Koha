#!/usr/bin/perl

# This file is a test script for C4::VirtualShelves.pm
# Author : Antoine Farnault, antoine@koha-fr.org
# Larger modifications by Jonathan Druart and Marcel de Rooy

use Modern::Perl;
use Test::More tests => 56;
use MARC::Record;

use C4::Biblio qw( AddBiblio DelBiblio );
use C4::Context;
use C4::Members qw( AddMember );

use Koha::Virtualshelves;


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

#-----------------------TEST Virtualshelf constructor------------------------#

# creating shelves (could be <10 when names are not unique)
my @shelves;
for my $i (0..9){
    my $name= randomname();
    my $catg= int(rand(2))+1;
    my $shelf = eval {
        Koha::Virtualshelf->new(
            {
                shelfname => $name,
                category  => $catg,
                owner     =>$borrowernumbers[$i],
            }
        )->store;
    };
    if ( $@ or not $shelf ) {
        my $valid_name = Koha::Virtualshelf->new(
            {
                shelfname => $name,
                category  => $catg,
                owner     =>$borrowernumbers[$i],
            }
        )->is_shelfname_valid;
        is( $valid_name, 0, 'If the insert has failed, it should be caused by an invalid shelfname (or maybe not?)' );
    } else {
        ok($shelf->shelfnumber > -1, "The shelf $i should have been inserted");
    }
    push @shelves, {
        number => $shelf->shelfnumber,
        name   => $shelf->shelfname,
        catg   => $shelf->category,
        owner  => $borrowernumbers[$i],
    };
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
        is($countbefore, $countafter - 1, 'added bib to list');  # the bib has been successfully added.
    } else {
        is($countbefore, $countafter, 'did not add duplicate bib to list');
    }

    $used{$key}++;
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
