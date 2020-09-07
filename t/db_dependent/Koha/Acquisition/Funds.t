#!/usr/bin/perl

# Copyright 2017 Koha Development team
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

use Koha::Acquisition::Funds;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $nb_of_funds = Koha::Acquisition::Funds->search->count;
my $new_fund = Koha::Acquisition::Fund->new({
    budget_code => 'my_budget_code_for_test',
    budget_name => 'my_budget_name_for_test',
})->store;

like( $new_fund->budget_id, qr|^\d+$|, 'Adding a new fund should have set the budget_id');
is( Koha::Acquisition::Funds->search->count, $nb_of_funds + 1, 'The fund should have been added' );

my $retrieved_fund_1 = Koha::Acquisition::Funds->find( $new_fund->budget_id );
is( $retrieved_fund_1->budget_name, $new_fund->budget_name, 'Find a fund by budget_id should return the correct fund' );

$retrieved_fund_1->delete;
is( Koha::Acquisition::Funds->search->count, $nb_of_funds, 'Delete should have deleted the fund' );

$schema->storage->txn_rollback;

