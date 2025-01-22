#!/usr/bin/perl

# Copyright 2017 Aleisha Amohia <aleisha@catalyst.net.nz>
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

use Test::NoWarnings;
use Test::More tests => 5;

use Koha::Database;
use Koha::Acquisition::Basket;
use Koha::Acquisition::Baskets;
use Koha::Acquisition::Bookseller;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder        = t::lib::TestBuilder->new;
my $num_of_baskets = Koha::Acquisition::Baskets->search->count;

my $bookseller = Koha::Acquisition::Bookseller->new(
    {
        name => 'Bookseller1',
    }
)->store;

my $basket = Koha::Acquisition::Basket->new(
    {
        basketname   => 'Basket1',
        booksellerid => $bookseller->id,
        is_standing  => 0,
    }
)->store;

my $basket2 = Koha::Acquisition::Basket->new(
    {
        basketname   => 'BasketToDelete',
        booksellerid => $bookseller->id,
        is_standing  => 0,
    }
)->store;

like( $basket->basketno, qr|^\d+$|, 'Adding a new basket should have set the basketno' );

my $retrieved_basket = Koha::Acquisition::Baskets->find( $basket->basketno );
is( $retrieved_basket->basketname, $basket->basketname, 'Find a basket by id should return the correct basket' );

my $retrieved_bookseller = $retrieved_basket->bookseller;
is(
    $retrieved_bookseller->name, $bookseller->name,
    "Finding the bookseller of a basket by the basket's booksellerid should work as expected"
);

$basket2->delete;
is( Koha::Acquisition::Baskets->search->count, $num_of_baskets + 1, 'Delete should have deleted the basket' );

$schema->storage->txn_rollback;
