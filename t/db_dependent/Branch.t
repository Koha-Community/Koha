#!/usr/bin/perl

# Copyright 2013 Equinox Software, Inc.
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use C4::Context;
use Data::Dumper;

use Test::More tests => 21;

use C4::Branch;
use Koha::Libraries;
use Koha::LibraryCategories;

BEGIN {
    use FindBin;
    use lib $FindBin::Bin;
    use_ok('C4::Branch');
}
can_ok(
    'C4::Branch', qw(
      GetBranchName
      GetBranch
      GetBranches
      GetBranchesLoop
      GetBranchDetail
      ModBranch
      GetBranchInfo
      mybranch
      )
);


# Start transaction
my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

# clear the slate
$dbh->do('DELETE FROM branchcategories');

# Start test

my $count = Koha::Libraries->search->count;
like( $count, '/^\d+$/', "the count is a number" );

#add 2 branches
my $b1 = {
    add            => 1,
    branchcode     => 'BRA',
    branchname     => 'BranchA',
    branchaddress1 => 'adr1A',
    branchaddress2 => 'adr2A',
    branchaddress3 => 'adr3A',
    branchzip      => 'zipA',
    branchcity     => 'cityA',
    branchstate    => 'stateA',
    branchcountry  => 'countryA',
    branchphone    => 'phoneA',
    branchfax      => 'faxA',
    branchemail    => 'emailA',
    branchreplyto  => 'emailreply',
    branchreturnpath => 'branchreturn',
    branchurl      => 'urlA',
    branchip       => 'ipA',
    branchprinter  => undef,
    branchnotes    => 'noteA',
    opac_info      => 'opacA'
};
my $b2 = {
    branchcode     => 'BRB',
    branchname     => 'BranchB',
    branchaddress1 => 'adr1B',
    branchaddress2 => 'adr2B',
    branchaddress3 => 'adr3B',
    branchzip      => 'zipB',
    branchcity     => 'cityB',
    branchstate    => 'stateB',
    branchcountry  => 'countryB',
    branchphone    => 'phoneB',
    branchfax      => 'faxB',
    branchemail    => 'emailB',
    branchreplyto  => 'emailreply',
    branchreturnpath => 'branchreturn',
    branchurl      => 'urlB',
    branchip       => 'ipB',
    branchprinter  => undef,
    branchnotes    => 'noteB',
    opac_info      => 'opacB',
};
ModBranch($b1);
is( ModBranch($b2), undef, 'the field add is missing' );

$b2->{add} = 1;
ModBranch($b2);
is( Koha::Libraries->search->count, $count + 2, "two branches added" );

is( Koha::Libraries->find( $b2->{branchcode} )->delete, 1,          "One row affected" );
is( Koha::Libraries->search->count,             $count + 1, "branch BRB deleted" );

#Test GetBranchName
is( GetBranchName( $b1->{branchcode} ),
    $b1->{branchname}, "GetBranchName returns the right name" );

#Test GetBranchDetail
my $branchdetail = GetBranchDetail( $b1->{branchcode} );
$branchdetail->{add} = 1;
$b1->{issuing}       = undef;    # Not used in DB
is_deeply( $branchdetail, $b1, 'branchdetail is right' );

#Test Getbranches
my $branches = GetBranches();
is( scalar( keys %$branches ),
    Koha::Libraries->search->count, "GetBranches returns the right number of branches" );

#Test ModBranch

$b1 = {
    branchcode     => 'BRA',
    branchname     => 'BranchA modified',
    branchaddress1 => 'adr1A modified',
    branchaddress2 => 'adr2A modified',
    branchaddress3 => 'adr3A modified',
    branchzip      => 'zipA modified',
    branchcity     => 'cityA modified',
    branchstate    => 'stateA modified',
    branchcountry  => 'countryA modified',
    branchphone    => 'phoneA modified',
    branchfax      => 'faxA modified',
    branchemail    => 'emailA modified',
    branchreplyto  => 'emailreply modified',
    branchreturnpath => 'branchreturn modified',
    branchurl      => 'urlA modified',
    branchip       => 'ipA modified',
    branchprinter  => undef,
    branchnotes    => 'notesA modified',
    opac_info      => 'opacA modified'
};

ModBranch($b1);
is( Koha::Libraries->search->count, $count + 1,
    "A branch has been modified, no new branch added" );
$branchdetail = GetBranchDetail( $b1->{branchcode} );
$b1->{issuing} = undef;
is_deeply( $branchdetail, $b1 , "GetBranchDetail gives the details of BRA");

#Test categories
my $count_cat  = Koha::LibraryCategories->search->count;

my $cat1 = {
    categorycode     => 'CAT1',
    categoryname     => 'catname1',
    codedescription  => 'catdesc1',
    categorytype     => 'cattype1',
    show_in_pulldown => 1
};
my $cat2 = {
    categorycode     => 'CAT2',
    categoryname     => 'catname2',
    categorytype     => 'catype2',
    codedescription  => 'catdesc2',
    show_in_pulldown => 1
};

my %new_category = (
    categorycode     => 'LIBCATCODE',
    categoryname     => 'library category name',
    codedescription  => 'library category code description',
    categorytype     => 'searchdomain',
    show_in_pulldown => 1,
);

Koha::LibraryCategory->new(\%new_category)->store;
Koha::LibraryCategory->new($cat1)->store;
Koha::LibraryCategory->new($cat2)->store;

my $categories = Koha::LibraryCategories->search;
is( $categories->count, $count_cat + 3, "Two categories added" );

my $del = Koha::LibraryCategories->find( $cat2->{categorycode} )->delete;
is( $del, 1, 'One row affected' );

is( Koha::LibraryCategories->search->count, $count_cat + 2, "Category CAT 2 deleted" );

$b2->{CAT1} = 1;
ModBranch($b2);
is( Koha::Libraries->search->count, $count + 2, 'BRB added' );

#Test GetBranchInfo
my $b1info = GetBranchInfo( $b1->{branchcode} );
$b1->{categories} = [];
is_deeply( @$b1info[0], $b1, 'BRA has no categories' );

my $b2info = GetBranchInfo( $b2->{branchcode} );
my @cat    = ( $cat1->{categorycode} );
delete $b2->{add};
delete $b2->{CAT1};
$b2->{issuing}    = undef;
$b2->{categories} = \@cat;
is_deeply( @$b2info[0], $b2, 'BRB has the category CAT1' );

Koha::LibraryCategory->new($cat2)->store;
is( Koha::LibraryCategories->search->count, $count_cat + 3, "Two categories added" );
$b2 = {
    branchcode     => 'BRB',
    branchname     => 'BranchB',
    branchaddress1 => 'adr1B',
    branchaddress2 => 'adr2B',
    branchaddress3 => 'adr3B',
    branchzip      => 'zipB',
    branchcity     => 'cityB',
    branchstate    => 'stateB',
    branchcountry  => 'countryB',
    branchphone    => 'phoneB',
    branchfax      => 'faxB',
    branchemail    => 'emailB',
    branchreplyto  => 'emailreply',
    branchreturnpath => 'branchreturn',
    branchurl      => 'urlB',
    branchip       => 'ipB',
    branchprinter  => undef,
    branchnotes    => 'noteB',
    opac_info      => 'opacB',
    CAT1           => 1,
    CAT2           => 1
};
ModBranch($b2);
$b2info = GetBranchInfo( $b2->{branchcode} );
push( @cat, $cat2->{categorycode} );
delete $b2->{CAT1};
delete $b2->{CAT2};
$b2->{issuing}    = undef;
$b2->{categories} = \@cat;
is_deeply( @$b2info[0], $b2, 'BRB has the category CAT1 and CAT2' );

#TODO later: test mybranchine and onlymine
# Actually we cannot mock C4::Context->userenv in unit tests

#Test GetBranchesLoop
my $loop = GetBranchesLoop;
is( scalar(@$loop), Koha::Libraries->search->count, 'There is the right number of branches' );

# End transaction
$dbh->rollback;

