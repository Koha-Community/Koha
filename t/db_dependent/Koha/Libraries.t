#!/usr/bin/perl

# Copyright 2015 Koha Development team
#
# This file is part of Koha
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 9;

use Koha::Library;
use Koha::Libraries;
use Koha::LibraryCategory;
use Koha::LibraryCategories;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $nb_of_libraries = Koha::Libraries->search->count;
my $nb_of_categories = Koha::LibraryCategories->search->count;
my $new_library_1 = Koha::Library->new({
    branchcode => 'my_bc_1',
    branchname => 'my_branchname_1',
    branchnotes => 'my_branchnotes_1',
})->store;
my $new_library_2 = Koha::Library->new({
    branchcode => 'my_bc_2',
    branchname => 'my_branchname_2',
    branchnotes => 'my_branchnotes_2',
})->store;
my $new_category_1 = Koha::LibraryCategory->new({
    categorycode => 'my_cc_1',
    categoryname => 'my_categoryname_1',
    codedescription => 'my_codedescription_1',
    categorytype => 'properties',
} )->store;
my $new_category_2 = Koha::LibraryCategory->new( {
          categorycode    => 'my_cc_2',
          categoryname    => 'my_categoryname_2',
          codedescription => 'my_codedescription_2',
          categorytype    => 'searchdomain',
} )->store;
my $new_category_3 = Koha::LibraryCategory->new( {
          categorycode    => 'my_cc_3',
          categoryname    => 'my_categoryname_3',
          codedescription => 'my_codedescription_3',
          categorytype    => 'searchdomain',
} )->store;

is( Koha::Libraries->search->count,         $nb_of_libraries + 2,  'The 2 libraries should have been added' );
is( Koha::LibraryCategories->search->count, $nb_of_categories + 3, 'The 3 library categories should have been added' );

$new_library_1->add_to_categories( [$new_category_1] );
$new_library_2->add_to_categories( [$new_category_2] );
my $retrieved_library_1 = Koha::Libraries->find( $new_library_1->branchcode );
is( $retrieved_library_1->branchname, $new_library_1->branchname, 'Find a library by branchcode should return the correct library' );
is( Koha::Libraries->find( $new_library_1->branchcode )->get_categories->count, 1, '1 library should have been linked to the category 1' );

$retrieved_library_1->update_categories( [ $new_category_2, $new_category_3 ] );
is( Koha::Libraries->find( $new_library_1->branchcode )->get_categories->count, 2, '2 libraries should have been linked to the category 2' );

my $retrieved_category_2 = Koha::LibraryCategories->find( $new_category_2->categorycode );
is( $retrieved_category_2->libraries->count, 2, '2 libraries should have been linked to the category_2' );
is( $retrieved_category_2->categorycode, uc('my_cc_2'), 'The Koha::LibraryCategory constructor should have upercased the categorycode' );

$retrieved_library_1->delete;
is( Koha::Libraries->search->count, $nb_of_libraries + 1, 'Delete should have deleted the library' );

$retrieved_category_2->delete;
is( Koha::LibraryCategories->search->count, $nb_of_categories + 2, 'Delete should have deleted the library category' );

$schema->storage->txn_rollback;
1;
