#!/usr/bin/perl

# Copyright 2020 Koha Development team
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

use Koha::Database;

use t::lib::TestBuilder;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'manager' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $manager = $builder->build_object( { class => 'Koha::Patrons' } );
    my $action = $builder->build_object(
        {
            class => 'Koha::Cash::Register::Actions',
            value => { manager_id => $manager->borrowernumber },
        }
    );

    is( ref( $action->manager ),
        'Koha::Patron',
        'Koha::Cash::Register::Action->manager should return a Koha::Patron' );

    is( $action->manager->id, $manager->id,
'Koha::Cash::Registeri::Action->manager returns the correct Koha::Patron'
    );

    $schema->storage->txn_rollback;

};

subtest 'register' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $register =
      $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $action = $builder->build_object(
        {
            class => 'Koha::Cash::Register::Actions',
            value => { register_id => $register->id },
        }
    );

    is(
        ref( $action->register ),
        'Koha::Cash::Register',
'Koha::Cash::Register::Action->register should return a Koha::Cash::Register'
    );

    is( $action->register->id, $register->id,
'Koha::Cash::Register::Action->register returns the correct Koha::Cash::Register'
    );

    $schema->storage->txn_rollback;

};

subtest 'cashup_summary' => sub {
    plan tests => 8;

    $schema->storage->txn_begin;

    my $register =
      $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $manager = $builder->build_object( { class => 'Koha::Patrons' } );

    # Transaction 1
    my $debt1 = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => {
                register_id       => undef,
                amount            => '1.00',
                amountoutstanding => '0.00',
                credit_type_code  => undef,
                debit_type_code   => 'OVERDUE',
                date              => \'NOW() - INTERVAL 10 MINUTE'
            },
        }
    );
    my $income1 = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => {
                register_id       => $register->id,
                amount            => '-1.00',
                amountoutstanding => '0.00',
                credit_type_code  => 'PAYMENT',
                debit_type_code   => undef,
                date              => \'NOW() - INTERVAL 5 MINUTE'
            },
        }
    );
    $builder->build_object(
        {
            class => 'Koha::Account::Offsets',
            value => {
                credit_id => $income1->accountlines_id,
                debit_id  => $debt1->accountlines_id,
                amount    => '1.00',
                type      => 'Payment'
            },
        }
    );

    # Transaction 2
    my $debt2 = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => {
                register_id       => undef,
                amount            => '1.00',
                amountoutstanding => '0.00',
                credit_type_code  => undef,
                debit_type_code   => 'ACCOUNT',
                date              => \'NOW() - INTERVAL 3 MINUTE'
            },
        }
    );
    my $debt3 = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => {
                register_id       => undef,
                amount            => '0.50',
                amountoutstanding => '0.00',
                credit_type_code  => undef,
                debit_type_code   => 'LOST',
                date              => \'NOW() - INTERVAL 3 MINUTE'
            },
        }
    );
    my $income2 = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => {
                register_id       => $register->id,
                amount            => '-1.50',
                amountoutstanding => '0.00',
                credit_type_code  => 'PAYMENT',
                debit_type_code   => undef,
                date              => \'NOW() - INTERVAL 3 MINUTE'
            },
        }
    );
    $builder->build_object(
        {
            class => 'Koha::Account::Offsets',
            value => {
                credit_id => $income2->accountlines_id,
                debit_id  => $debt2->accountlines_id,
                amount    => '1.00',
                type      => 'Payment'
            },
        }
    );
    $builder->build_object(
        {
            class => 'Koha::Account::Offsets',
            value => {
                credit_id => $income2->accountlines_id,
                debit_id  => $debt3->accountlines_id,
                amount    => '0.50',
                type      => 'Payment'
            },
        }
    );
    my $expected_income = [
        {
            debit_type_code => 'ACCOUNT',
            total           => '1.000000',
            debit_type      => { 'description' => 'Account creation fee' }
        },
        {
            debit_type_code => 'LOST',
            total           => '0.500000',
            debit_type      => { description => 'Lost item' }
        },
        {
            debit_type_code => 'OVERDUE',
            total           => '1.000000',
            debit_type      => { 'description' => 'Overdue fine' }
        }
    ];

    # Transaction 3
    my $refund1 = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => {
                register_id       => undef,
                amount            => '-0.50',
                amountoutstanding => '0.00',
                credit_type_code  => 'REFUND',
                debit_type_code   => undef,
                date              => \'NOW() - INTERVAL 3 MINUTE'
            },
        }
    );
    my $outgoing1 = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => {
                register_id       => $register->id,
                amount            => '0.50',
                amountoutstanding => '0.00',
                credit_type_code  => undef,
                debit_type_code   => 'PAYOUT',
                date              => \'NOW() - INTERVAL 3 MINUTE'
            },
        }
    );
    $builder->build_object(
        {
            class => 'Koha::Account::Offsets',
            value => {
                credit_id => $refund1->accountlines_id,
                debit_id  => $outgoing1->accountlines_id,
                amount    => '0.50',
                type      => 'Refund'
            },
        }
    );
    my $expected_outgoing = [
        {
            'total'       => '0.500000',
            'credit_type' => {
                'description' => 'A refund applied to a patrons fine'
            },
            'credit_type_code' => 'REFUND'
        }
    ];

    my $cashup1 =
      $register->add_cashup( { manager_id => $manager->id, amount => '2.00' } );

    my $summary = $cashup1->cashup_summary;

    is( $summary->{from_date}, undef,
        "from_date is undefined if there is only one recorded" );
    is( $summary->{to_date}, $cashup1->timestamp,
        "to_date equals cashup timestamp" );
    is( ref( $summary->{income_transactions} ),
        'Koha::Account::Lines',
        "income_transactions contains Koha::Account::Lines" );
    is( $summary->{income_transactions}->count,
        2, "income_transactions contains 2 transactions" );
    is( ref( $summary->{outgoing_transactions} ),
        'Koha::Account::Lines',
        "outgoing_transactions contains Koha::Account::Lines" );
    is( $summary->{outgoing_transactions}->count,
        1, "outgoing_transactions contains 1 transaction" );
    is_deeply( $summary->{income}, $expected_income,
        "income arrayref is correct" );
    is_deeply( $summary->{outgoing}, $expected_outgoing,
        "outgoing arrayref is correct" );

    $schema->storage->txn_rollback;
};

1;
