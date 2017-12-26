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

use Koha::Acquisition::Budgets;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $nb_of_budgets= Koha::Acquisition::Budgets->search->count;
my $now = dt_from_string;
my $new_budget = Koha::Acquisition::Budget->new({
    budget_period_startdate => $now,
    budget_period_enddate => $now,
    budget_period_active => 1,
    budget_period_description => 'a new budget',
    budget_period_total => 1000,
})->store;

like( $new_budget->budget_period_id, qr|^\d+$|, 'Adding a new budget should have set the budget_period_id');
is( Koha::Acquisition::Budgets->search->count, $nb_of_budgets + 1, 'The budget should have been added' );

my $retrieved_budget = Koha::Acquisition::Budgets->find( $new_budget->budget_period_id);
is( $retrieved_budget->budget_period_description, $new_budget->budget_period_description, 'Find a budget by budget_period_id should return the correct budget' );

$retrieved_budget->delete;
is( Koha::Acquisition::Budgets->search->count, $nb_of_budgets, 'Delete should have deleted the budget' );

$schema->storage->txn_rollback;

