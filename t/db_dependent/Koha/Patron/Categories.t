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

use Test::More tests => 11;

use C4::Context;
use Koha::Database;
use Koha::Patron::Category;
use Koha::Patron::Categories;
use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $branch = $builder->build({ source => 'Branch', });
my $nb_of_categories = Koha::Patron::Categories->search->count;
my $new_category_1 = Koha::Patron::Category->new({
    categorycode => 'mycatcodeX',
    description  => 'mycatdescX',
})->store;
$new_category_1->add_branch_limitation( $branch->{branchcode} );
my $new_category_2 = Koha::Patron::Category->new({
    categorycode => 'mycatcodeY',
    description  => 'mycatdescY',
    checkprevcheckout => undef,
})->store;

is( Koha::Patron::Categories->search->count, $nb_of_categories + 2, 'The 2 patron categories should have been added' );

my $retrieved_category_1 = Koha::Patron::Categories->find( $new_category_1->categorycode );
is( $retrieved_category_1->categorycode, $new_category_1->categorycode, 'Find a patron category by categorycode should return the correct category' );
is_deeply( $retrieved_category_1->branch_limitations, [ $branch->{branchcode} ], 'The branch limitation should have been stored and retrieved' );
is_deeply( $retrieved_category_1->default_messaging, [], 'By default there is not messaging option' );

my $retrieved_category_2 = Koha::Patron::Categories->find( $new_category_2->categorycode );
is( $retrieved_category_1->checkprevcheckout, 'inherit', 'Koha::Patron::Category->store should default checkprevcheckout to inherit' );
is( $retrieved_category_2->checkprevcheckout, 'inherit', 'Koha::Patron::Category->store should default checkprevcheckout to inherit' );

my $another_branch = $builder->build( { source => 'Branch', } );
C4::Context->_new_userenv('my_new_userenv');
C4::Context->set_userenv( 0, 0, 'usercnum', 'firstname', 'surname', $another_branch->{branchcode}, 'My wonderful library', '', '', '' );
my $new_category_3 = Koha::Patron::Category->new(
    {   categorycode => 'mycatcodeZ',
        description  => 'mycatdescZ',
    }
)->store;
$new_category_3->add_branch_limitation( $another_branch->{branchcode} );
is( Koha::Patron::Categories->search->count, $nb_of_categories + 3, 'The 3rd patron category should have been added' );
my @limited_categories = Koha::Patron::Categories->search_limited;
my @limited_category_codes = map { $_->categorycode } @limited_categories;
is( scalar( grep { $_ eq $new_category_1->categorycode } @limited_category_codes ), 0, 'The first category is limited to another branch' );
is( scalar( grep { $_ eq $new_category_2->categorycode } @limited_category_codes ), 1, 'The second category is not limited' );
is( scalar( grep { $_ eq $new_category_3->categorycode } @limited_category_codes ), 1, 'The third category is limited to my branch ' );

$retrieved_category_1->delete;
is( Koha::Patron::Categories->search->count, $nb_of_categories + 2, 'Delete should have deleted the patron category' );

$schema->storage->txn_rollback;

1;
