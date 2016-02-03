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

use Test::More tests => 16;

use C4::Branch;
use Koha::Database;
use Koha::Library;
use Koha::Libraries;
use Koha::LibraryCategories;

BEGIN {
    use FindBin;
    use lib $FindBin::Bin;
    use_ok('C4::Branch');
}
can_ok(
    'C4::Branch', qw(
      GetBranch
      GetBranches
      mybranch
      )
);

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $dbh = C4::Context->dbh;

# clear the slate
$dbh->do('DELETE FROM branchcategories');

# Start test

my $count = Koha::Libraries->search->count;
like( $count, '/^\d+$/', "the count is a number" );

#add 2 branches
my $b1 = {
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
    opac_info      => 'opacA',
    issuing        => undef,
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
    issuing        => undef,
};
Koha::Library->new($b1)->store;
Koha::Library->new($b2)->store;

is( Koha::Libraries->search->count, $count + 2, "two branches added" );

is( Koha::Libraries->find( $b2->{branchcode} )->delete, 1,          "One row affected" );
is( Koha::Libraries->search->count,             $count + 1, "branch BRB deleted" );

#Test Getbranches
my $branches = GetBranches();
is( scalar( keys %$branches ),
    Koha::Libraries->search->count, "GetBranches returns the right number of branches" );

#Test modify a library

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
    opac_info      => 'opacA modified',
    issuing        => undef,
};

Koha::Libraries->find($b1->{branchcode})->set($b1)->store;
is( Koha::Libraries->search->count, $count + 1,
    "A branch has been modified, no new branch added" );

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

my $b2_stored = Koha::Library->new($b2)->store;
my $CAT1 = Koha::LibraryCategories->find('CAT1');
$b2_stored->add_to_categories([$CAT1]);
is( Koha::Libraries->search->count, $count + 2, 'BRB added' );

my $b1info = Koha::Libraries->find( $b1->{branchcode} );
is_deeply( $b1info->get_categories->count, 0, 'BRA has no categories' );

my $b2info = Koha::Libraries->find( $b2->{branchcode} );
is_deeply( $b2info->get_categories->count, 1, 'BRB has the category CAT1' );

Koha::LibraryCategory->new($cat2)->store;
is( Koha::LibraryCategories->search->count, $count_cat + 3, "Two categories added" );

#TODO later: test mybranchine and onlymine
# Actually we cannot mock C4::Context->userenv in unit tests

$schema->storage->txn_rollback;
