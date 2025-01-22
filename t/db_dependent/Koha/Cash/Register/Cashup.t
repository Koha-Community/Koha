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
use Test::NoWarnings;
use Test::More tests => 4;

use Koha::Database;

use t::lib::TestBuilder;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'manager' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $manager = $builder->build_object( { class => 'Koha::Patrons' } );
    my $cashup  = $builder->build_object(
        {
            class => 'Koha::Cash::Register::Cashups',
            value => { manager_id => $manager->borrowernumber },
        }
    );

    is(
        ref( $cashup->manager ),
        'Koha::Patron',
        'Koha::Cash::Register::Cashup->manager should return a Koha::Patron'
    );

    is(
        $cashup->manager->id, $manager->id,
        'Koha::Cash::Register::Cashup->manager returns the correct Koha::Patron'
    );

    $schema->storage->txn_rollback;

};

subtest 'register' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $register = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $cashup   = $builder->build_object(
        {
            class => 'Koha::Cash::Register::Cashups',
            value => { register_id => $register->id },
        }
    );

    is(
        ref( $cashup->register ),
        'Koha::Cash::Register',
        'Koha::Cash::Register::Cashup->register should return a Koha::Cash::Register'
    );

    is(
        $cashup->register->id, $register->id,
        'Koha::Cash::Register::Cashup->register returns the correct Koha::Cash::Register'
    );

    $schema->storage->txn_rollback;

};

subtest 'summary' => sub {
    plan tests => 29;

    $schema->storage->txn_begin;

    my $register                = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $patron                  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $manager                 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $account                 = $patron->account;
    my $expected_total          = 0;
    my $expected_income_total   = 0;
    my $expected_income_grouped = [];
    my $expected_payout_total   = 0;
    my $expected_payout_grouped = [];

    # Transaction 1 (Fine (1.00) + Payment (-1.00))
    my $fine1 = $account->add_debit(
        {
            amount    => '1.00',
            type      => 'OVERDUE',
            interface => 'cron'
        }
    );
    $fine1->date( \'NOW() - INTERVAL 20 MINUTE' )->store;

    my $payment1 = $account->pay(
        {
            cash_register => $register->id,
            amount        => '1.00',
            credit_type   => 'PAYMENT',
            lines         => [$fine1]
        }
    );
    $payment1 = Koha::Account::Lines->find( $payment1->{payment_id} );
    $payment1->date( \'NOW() - INTERVAL 15 MINUTE' )->store;
    $expected_income_total += '1.00';

    # Overdue of 1.0 fully paid
    unshift @{$expected_income_grouped},
        {
        debit_type_code => 'OVERDUE',
        total           => '1',
        debit_type      => { description => 'Overdue fine' }
        };

    # Transaction 2 (Account (1.00) + Lost (0.50) + Payment (-1.50))
    my $account1 = $account->add_debit(
        {
            amount    => '1.00',
            type      => 'ACCOUNT',
            interface => 'cron'
        }
    );
    $account1->date( \'NOW() - INTERVAL 13 MINUTE' )->store;
    my $lost1 = $account->add_debit(
        {
            amount    => '0.50',
            type      => 'LOST',
            interface => 'cron'
        }
    );
    $lost1->date( \'NOW() - INTERVAL 13 MINUTE' )->store;
    my $payment2 = $account->pay(
        {
            cash_register => $register->id,
            amount        => '1.50',
            credit_type   => 'PAYMENT',
            lines         => [ $account1, $lost1 ]
        }
    );
    $payment2 = Koha::Account::Lines->find( $payment2->{payment_id} );
    $payment2->date( \'NOW() - INTERVAL 13 MINUTE' )->store;
    $expected_income_total += '1.5';

    # Lost charge of 0.5 fully paid
    unshift @{$expected_income_grouped},
        {
        debit_type_code => 'LOST',
        total           => '0.5',
        debit_type      => { description => 'Lost item' }
        };

    # Account fee of 1.0 fully paid
    unshift @{$expected_income_grouped},
        {
        debit_type_code => 'ACCOUNT',
        total           => '1',
        debit_type      => { description => 'Account creation fee' }
        };

    # Transaction 3 (Refund (-0.50) + Payout (0.50))
    $lost1->discard_changes;
    my $refund1 = $lost1->reduce(
        {
            amount         => '0.50',
            reduction_type => 'REFUND',
            interface      => 'cron'
        }
    );
    $refund1->date( \'NOW() - INTERVAL 13 MINUTE' )->store;

    my $payout1 = $refund1->payout(
        {
            cash_register => $register->id,
            amount        => '0.50',
            payout_type   => 'CASH',
            interface     => 'intranet',
            staff_id      => $manager->borrowernumber,
            branch        => $manager->branchcode
        }
    );
    $payout1->date( \'NOW() - INTERVAL 13 MINUTE' )->store;
    $expected_payout_total += '0.5';

    # Lost fee of 0.50 fully refunded
    unshift @{$expected_payout_grouped},
        {
        'total'            => '0.5',
        'credit_type'      => { 'description' => 'Refund' },
        'credit_type_code' => 'REFUND',
        'related_debit'    => {
            'debit_type_code' => 'LOST',
            'debit_type'      => { 'description' => 'Lost item' }
        }
        };

    $expected_total += $expected_income_total;
    $expected_total -= $expected_payout_total;

    # Cashup 1
    my $cashup1 = $register->add_cashup( { manager_id => $manager->id, amount => '2.00' } );

    my $summary = $cashup1->summary;

    is( $summary->{from_date}, undef,                    "from_date is undefined if there is only one recorded" );
    is( $summary->{to_date},   $cashup1->timestamp,      "to_date equals cashup timestamp" );
    is( ref( $summary->{income_grouped} ),      'ARRAY', "income_grouped contains an arrayref" );
    is( scalar @{ $summary->{income_grouped} }, 3,       "income_grouped contains 3 transactions" );
    is_deeply( $summary->{income_grouped}, $expected_income_grouped, "income_grouped arrayref is correct" );
    is( $summary->{income_total}, $expected_income_total, "income_total is correct" );

    is( ref( $summary->{payout_grouped} ),      'ARRAY', "payout_grouped contains an arrayref" );
    is( scalar @{ $summary->{payout_grouped} }, 1,       "payout_grouped contains 1 transaction" );
    is_deeply( $summary->{payout_grouped}, $expected_payout_grouped, "payout_grouped arrayref is correct" );
    is( $summary->{payout_total}, $expected_payout_total, "payout_total is correct" );
    is( $summary->{total},        $expected_total,        "total equals expected_total" );

    # Backdate cashup1 so we can add a new cashup to check 'previous'
    $cashup1->timestamp( \'NOW() - INTERVAL 12 MINUTE' )->store();
    $cashup1->discard_changes;
    $expected_total          = 0;
    $expected_income_total   = 0;
    $expected_income_grouped = [];
    $expected_payout_total   = 0;
    $expected_payout_grouped = [];

    # Transaction 4 ( Fine (2.75) + Partial payment (-2.00) )
    my $fine2 = $account->add_debit(
        {
            amount    => '2.75',
            type      => 'OVERDUE',
            interface => 'cron'
        }
    );
    $fine2->date( \'NOW() - INTERVAL 10 MINUTE' )->store;

    my $payment3 = $account->pay(
        {
            cash_register => $register->id,
            amount        => '2.00',
            credit_type   => 'PAYMENT',
            lines         => [$fine2]
        }
    );
    $payment3 = Koha::Account::Lines->find( $payment3->{payment_id} );
    $payment3->date( \'NOW() - INTERVAL 10 MINUTE' )->store;
    $expected_income_total += '2.00';

    unshift @{$expected_income_grouped},
        {
        debit_type_code => 'OVERDUE',
        total           => '-2.000000' * -1,
        debit_type      => { 'description' => 'Overdue fine' }
        };

    $expected_total += $expected_income_total;
    $expected_total -= $expected_payout_total;

    # Cashup 2
    my $cashup2 = $register->add_cashup( { manager_id => $manager->id, amount => '2.00' } );

    $summary = $cashup2->summary;

    is( $summary->{from_date}, $cashup1->timestamp, "from_date returns the timestamp of the previous cashup cashup" );
    is( $summary->{to_date},   $cashup2->timestamp, "to_date equals cashup timestamp" );
    is( ref( $summary->{income_grouped} ),      'ARRAY', "income_grouped contains Koha::Account::Lines" );
    is( scalar @{ $summary->{income_grouped} }, 1,       "income_grouped contains 1 transaction" );
    is_deeply(
        $summary->{income_grouped}, $expected_income_grouped,
        "income_grouped arrayref is correct for partial payment"
    );
    is( ref( $summary->{payout_grouped} ),      'ARRAY', "payout_grouped contains Koha::Account::Lines" );
    is( scalar @{ $summary->{payout_grouped} }, 0,       "payout_grouped contains 0 transactions" );
    is_deeply( $summary->{payout_grouped}, $expected_payout_grouped, "payout_grouped arrayref is correct" );
    is( $summary->{total}, $expected_total, "total equals expected_total" );

    # Backdate cashup2 so we can add a new cashup to check
    $cashup2->timestamp( \'NOW() - INTERVAL 6 MINUTE' )->store();
    $cashup2->discard_changes;
    $expected_total          = 0;
    $expected_income_total   = 0;
    $expected_income_grouped = [];
    $expected_payout_total   = 0;
    $expected_payout_grouped = [];

    # Transaction 5 (Refund (-1) + Payout (1))
    $account1->discard_changes;
    my $refund2 = $account1->reduce(
        {
            amount         => '1.00',
            reduction_type => 'REFUND',
            interface      => 'cron'
        }
    );
    $refund2->date( \'NOW() - INTERVAL 3 MINUTE' )->store;

    my $payout2 = $refund2->payout(
        {
            cash_register => $register->id,
            amount        => '1.00',
            payout_type   => 'CASH',
            interface     => 'intranet',
            staff_id      => $manager->borrowernumber,
            branch        => $manager->branchcode
        }
    );
    $payout2->date( \'NOW() - INTERVAL 3 MINUTE' )->store;
    $expected_payout_total += '1.00';

    # Account fee of 1.00 fully refunded (Across cashup boundary)
    unshift @{$expected_payout_grouped},
        {
        'total'            => '1',
        'credit_type'      => { 'description' => 'Refund' },
        'credit_type_code' => 'REFUND',
        'related_debit'    => {
            'debit_type_code' => 'ACCOUNT',
            'debit_type'      => { 'description' => 'Account creation fee' }
        }
        };

    $expected_total += $expected_income_total;
    $expected_total -= $expected_payout_total;

    # Cashup 3
    my $cashup3 = $register->add_cashup( { manager_id => $manager->id, amount => '2.00' } );

    $summary = $cashup3->summary;

    is( $summary->{from_date}, $cashup2->timestamp, "from_date returns the timestamp of the previous cashup cashup" );
    is( $summary->{to_date},   $cashup3->timestamp, "to_date equals cashup timestamp" );
    is( ref( $summary->{income_grouped} ),      'ARRAY', "income_grouped contains Koha::Account::Lines" );
    is( scalar @{ $summary->{income_grouped} }, 0,       "income_grouped contains 1 transaction" );
    is_deeply(
        $summary->{income_grouped}, $expected_income_grouped,
        "income_grouped arrayref is correct for partial payment"
    );
    is( ref( $summary->{payout_grouped} ),      'ARRAY', "payout_grouped contains Koha::Account::Lines" );
    is( scalar @{ $summary->{payout_grouped} }, 1,       "payout_grouped contains 0 transactions" );
    is_deeply( $summary->{payout_grouped}, $expected_payout_grouped, "payout_grouped arrayref is correct" );
    is( $summary->{total}, $expected_total, "total equals expected_total" );

    $schema->storage->txn_rollback;
};

1;
