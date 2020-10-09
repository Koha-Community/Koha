#!/usr/bin/perl

# Copyright 2019 Koha Development team
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

use Test::More tests => 3;

use t::lib::TestBuilder;

use Koha::Database;

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'to_api() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $fund = $builder->build_object({ class => 'Koha::Acquisition::Funds' });
    my $fund_api = $fund->to_api();

    is( $fund->budget_id, $fund_api->{fund_id}, 'Mapping is correct for budget_id' );
    is( $fund->budget_period_id, $fund_api->{budget_id}, 'Mapping is correct for budget_period_id' );

    $schema->storage->txn_rollback;
};

subtest 'budget ()' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my $budget = $builder->build_object({ class => 'Koha::Acquisition::Budgets' });
    my $fund = $builder->build_object({ class => 'Koha::Acquisition::Funds', value => { budget_period_id => $budget->budget_period_id } });

    is($budget->budget_period_id, $fund->budget->budget_period_id, 'Fund\'s budget retrieved correctly');

    $schema->storage->txn_rollback;
};

subtest 'budget' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;
    my $f = $builder->build_object(
        {
            class => 'Koha::Acquisition::Funds',
        }
    );

    my $fund = Koha::Acquisition::Funds->find( $f->budget_id );
    is( ref( $fund->budget ),
        'Koha::Acquisition::Budget',
        '->fund should return a Koha::Acquisition::Budget object' );
    $schema->storage->txn_rollback;
};
