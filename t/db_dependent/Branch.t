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

use Test::More tests => 36;

use C4::Branch;

BEGIN {
    use FindBin;
    use lib $FindBin::Bin;
    use_ok('C4::Branch');
}
can_ok(
    'C4::Branch', qw(
      GetBranchCategory
      GetBranchName
      GetBranch
      GetBranches
      GetBranchesLoop
      GetBranchDetail
      get_branchinfos_of
      ModBranch
      CheckBranchCategorycode
      GetBranchInfo
      GetCategoryTypes
      GetBranchCategories
      GetBranchesInCategory
      ModBranchCategoryInfo
      DelBranch
      DelBranchCategory
      CheckCategoryUnique
      mybranch
      GetBranchesCount)
);


# Start transaction
my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

# clear the slate
$dbh->do('DELETE FROM branchcategories');

# Start test

my $count = GetBranchesCount;
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
is( GetBranchesCount, $count + 2, "two branches added" );

#Test DelBranch

is( DelBranch( $b2->{branchcode} ), 1,          "One row affected" );
is( GetBranchesCount,               $count + 1, "branch BRB deleted" );

#Test GetBranchName
is( GetBranchName( $b1->{branchcode} ),
    $b1->{branchname}, "GetBranchName returns the right name" );

#Test GetBranchDetail
my $branchdetail = GetBranchDetail( $b1->{branchcode} );
$branchdetail->{add} = 1;
$b1->{issuing}       = undef;    # Not used in DB
is_deeply( $branchdetail, $b1, 'branchdetail is right' );

#Test Getbranches
my $branches = GetBranches;
is( scalar( keys %$branches ),
    GetBranchesCount, "GetBranches returns the right number of branches" );

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
    branchurl      => 'urlA modified',
    branchip       => 'ipA modified',
    branchprinter  => undef,
    branchnotes    => 'notesA modified',
    opac_info      => 'opacA modified'
};

ModBranch($b1);
is( GetBranchesCount, $count + 1,
    "A branch has been modified, no new branch added" );
$branchdetail = GetBranchDetail( $b1->{branchcode} );
$b1->{issuing} = undef;
is_deeply( $branchdetail, $b1 , "GetBranchDetail gives the details of BRA");

#Test categories
my $categories = GetBranchCategories;
my $count_cat  = scalar( keys $categories );

my $cat1 = {
    add              => 1,
    categorycode     => 'CAT1',
    categoryname     => 'catname1',
    codedescription  => 'catdesc1',
    categorytype     => 'cattype1',
    show_in_pulldown => 1
};
my $cat2 = {
    add              => 1,
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

ModBranchCategoryInfo({
    add => 1,
    %new_category,
});

ModBranchCategoryInfo($cat1);
ModBranchCategoryInfo($cat2);

$categories = GetBranchCategories;
is( scalar( keys $categories ), $count_cat + 3, "Two categories added" );
delete $cat1->{add};
delete $cat2->{add};
delete $new_category{add};
is_deeply($categories, [ $cat1,$cat2,\%new_category ], 'retrieve all expected library categories (bug 10515)');

#test GetBranchCategory
my $cat1detail = GetBranchCategory( $cat1->{categorycode} );
delete $cat1->{add};
is_deeply( $cat1detail, $cat1, 'CAT1 details are right' );
my $category = GetBranchCategory('LIBCATCODE');
is_deeply($category, \%new_category, 'fetched newly added library category');

#Test DelBranchCategory
my $del = DelBranchCategory( $cat2->{categorycode} );
is( $del, 1, 'One row affected' );

$categories = GetBranchCategories;
is( scalar( keys $categories ), $count_cat + 2, "Category  CAT2 deleted" );

my $cat2detail = GetBranchCategory( $cat2->{categorycode} );
is( $cat2detail, undef, 'CAT2 doesnt exist' );

$category = GetBranchCategory();
is($category, undef, 'retrieve library category only if code is supplied (bug 10515)');

#Test CheckBranchCategoryCode
my $check1 = CheckBranchCategorycode( $cat1->{categorycode} );
my $check2 = CheckBranchCategorycode( $cat2->{categorycode} );
like( $check1, '/^\d+$/', "CheckBranchCategorycode returns a number" );

$b2->{CAT1} = 1;
ModBranch($b2);
is( GetBranchesCount, $count + 2, 'BRB added' );
is(
    CheckBranchCategorycode( $cat1->{categorycode} ),
    $check1 + 1,
    'BRB added to CAT1'
);

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

ModBranchCategoryInfo({add => 1,%$cat2});
$categories = GetBranchCategories;
is( scalar( keys $categories ), $count_cat + 3, "Two categories added" );
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
is(
    CheckBranchCategorycode( $cat2->{categorycode} ),
    $check2 + 1,
    'BRB added to CAT2'
);
push( @cat, $cat2->{categorycode} );
delete $b2->{CAT1};
delete $b2->{CAT2};
$b2->{issuing}    = undef;
$b2->{categories} = \@cat;
is_deeply( @$b2info[0], $b2, 'BRB has the category CAT1 and CAT2' );

#Test GetBranchesInCategory
my $brCat1 = GetBranchesInCategory( $cat1->{categorycode} );
my @b      = ( $b2->{branchcode} );
is_deeply( $brCat1, \@b, 'CAT1 has branch BRB' );

my $b3 = {
    add            => 1,
    branchcode     => 'BRC',
    branchname     => 'BranchC',
    branchaddress1 => 'adr1C',
    branchaddress2 => 'adr2C',
    branchaddress3 => 'adr3C',
    branchzip      => 'zipC',
    branchcity     => 'cityC',
    branchstate    => 'stateC',
    branchcountry  => 'countryC',
    branchphone    => 'phoneC',
    branchfax      => 'faxC',
    branchemail    => 'emailC',
    branchurl      => 'urlC',
    branchip       => 'ipC',
    branchprinter  => undef,
    branchnotes    => 'noteC',
    opac_info      => 'opacC',
    CAT1           => 1,
    CAT2           => 1
};
ModBranch($b3);
$brCat1 = GetBranchesInCategory( $cat1->{categorycode} );
push( @b, $b3->{branchcode} );
is_deeply( $brCat1, \@b, 'CAT1 has branch BRB and BRC' );
is(
    CheckBranchCategorycode( $cat1->{categorycode} ),
    $check1 + 2,
    'BRC has been added to CAT1'
);

#Test CheckCategoryUnique
is( CheckCategoryUnique('CAT2'),          0, 'CAT2 exists' );
is( CheckCategoryUnique('CAT_NO_EXISTS'), 1, 'CAT_NO_EXISTS doesnt exist' );

#Test GetCategoryTypes
my @category_types = GetCategoryTypes();
is_deeply(\@category_types, [ 'searchdomain', 'properties' ], 'received expected library category types');

$categories = GetBranchCategories(undef, undef, 'LIBCATCODE');
is_deeply($categories, [ {%$cat1}, {%$cat2},{ %new_category, selected => 1 } ], 'retrieve expected, eselected library category (bug 10515)');

#TODO later: test mybranchine and onlymine
# Actually we cannot mock C4::Context->userenv in unit tests

#Test GetBranchesLoop
my $loop = GetBranchesLoop;
is( scalar(@$loop), GetBranchesCount, 'There is the right number of branches' );

# End transaction
$dbh->rollback;

