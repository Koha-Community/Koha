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
use Test::More tests => 7;
use Koha::Database;
use Koha::Acquisition::Currency;
use Koha::Acquisition::Currencies;
use t::lib::TestBuilder;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{RaiseError} = 1;

my $builder = t::lib::TestBuilder->new;
my $nb_of_currencies = Koha::Acquisition::Currencies->search->count;
my $new_currency_1 = Koha::Acquisition::Currency->new({
    currency => 'my_cur_1',
    symbol => 'symb1',
    isocode => 'isoc1',
    rate => 1,
    active => 1,
})->store;

my $retrieved_currency_1 = Koha::Acquisition::Currencies->find( $new_currency_1->currency );
is( $retrieved_currency_1->active, 1, 'Active should have been set to 1' );

my $new_currency_2 = Koha::Acquisition::Currency->new({
    currency => 'my_cur_2',
    symbol => 'symb2',
    isocode => 'isoc2',
    rate => 2,
    active => 1,
})->store;

is( Koha::Acquisition::Currencies->search->count, $nb_of_currencies + 2, 'The 2 currencies should have been added' );
my $retrieved_currency_2 = Koha::Acquisition::Currencies->find( $new_currency_2->currency );
is( $retrieved_currency_2->active, 1, 'Active should have been set to 1' );

$retrieved_currency_2->store;
$retrieved_currency_2 = Koha::Acquisition::Currencies->find( $new_currency_2->currency );
is( $retrieved_currency_2->active, 1, 'Editing the existing active currency should not remove its active flag' );

my $active_currency = Koha::Acquisition::Currencies->get_active;
is ( $active_currency->currency, $retrieved_currency_2->currency, 'The active currency should be the last one marked as active' );

my $nb_of_active_currencies = Koha::Acquisition::Currencies->search({active => 1})->count;
is ( $nb_of_active_currencies, 1, 'Only 1 currency should be marked as active' );

$retrieved_currency_1->delete;
is( Koha::Acquisition::Currencies->search->count, $nb_of_currencies + 1, 'Delete should have deleted the currency' );
