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

use Test::More tests => 4;

use Koha::City;
use Koha::Cities;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $nb_of_cities = Koha::Cities->search->count;
my $new_city_1 = Koha::City->new({
    city_name => 'my_city_name_for_test_1',
    city_state => 'my_city_state_for_test_1',
    city_zipcode => 'my_zipcode_4_test_1',
    city_country => 'my_city_country_for_test_1',
})->store;
my $new_city_2 = Koha::City->new({
    city_name => 'my_city_name_for_test_2',
    city_state => 'my_city_state_for_test_2',
    city_zipcode => 'my_zipcode_4_test_2',
    city_country => 'my_city_country_for_test_2',
})->store;

like( $new_city_1->cityid, qr|^\d+$|, 'Adding a new city should have set the cityid');
is( Koha::Cities->search->count, $nb_of_cities + 2, 'The 2 cities should have been added' );

my $retrieved_city_1 = Koha::Cities->find( $new_city_1->cityid );
is( $retrieved_city_1->city_name, $new_city_1->city_name, 'Find a city by id should return the correct city' );

$retrieved_city_1->delete;
is( Koha::Cities->search->count, $nb_of_cities + 1, 'Delete should have deleted the city' );

$schema->storage->txn_rollback;

