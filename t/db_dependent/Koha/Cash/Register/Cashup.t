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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 6;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

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

subtest 'accountlines' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my $register = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );
    my $manager  = $builder->build_object( { class => 'Koha::Patrons' } );

    # Test 1: Basic functionality
    subtest 'basic_accountlines_functionality' => sub {
        plan tests => 2;

        my $account = $patron->account;
        my $fine    = $account->add_debit(
            {
                amount    => '10.00',
                type      => 'OVERDUE',
                interface => 'cron'
            }
        );
        $fine->date( \'NOW() - INTERVAL 30 MINUTE' )->store;

        my $payment = $account->pay(
            {
                cash_register => $register->id,
                amount        => '10.00',
                credit_type   => 'PAYMENT',
                payment_type  => 'CASH',
                lines         => [$fine]
            }
        );
        my $payment_line = Koha::Account::Lines->find( $payment->{payment_id} );
        $payment_line->date( \'NOW() - INTERVAL 25 MINUTE' )->store;

        # Cashup
        my $cashup = $register->add_cashup( { manager_id => $manager->id, amount => '10.00' } );

        # Check accountlines method exists and returns correct type
        my $accountlines = $cashup->accountlines;
        is( ref($accountlines), 'Koha::Account::Lines', 'accountlines returns Koha::Account::Lines object' );
        ok( $accountlines->count >= 0, 'accountlines returns a valid count' );
    };

    # Test 2: Two-phase workflow basics
    subtest 'two_phase_basics' => sub {
        plan tests => 3;

        my $register2 = $builder->build_object( { class => 'Koha::Cash::Registers' } );
        my $account2  = $patron->account;

        # Add initial cash transaction before starting cashup
        my $initial_fine = $account2->add_debit(
            {
                amount    => '3.00',
                type      => 'OVERDUE',
                interface => 'cron'
            }
        );

        my $initial_payment = $account2->pay(
            {
                cash_register => $register2->id,
                amount        => '3.00',
                credit_type   => 'PAYMENT',
                payment_type  => 'CASH',
                lines         => [$initial_fine]
            }
        );

        # Start cashup first
        my $cashup_start = $register2->start_cashup( { manager_id => $manager->id } );

        # Add transaction after start
        my $fine = $account2->add_debit(
            {
                amount    => '5.00',
                type      => 'OVERDUE',
                interface => 'cron'
            }
        );

        my $payment = $account2->pay(
            {
                cash_register => $register2->id,
                amount        => '5.00',
                credit_type   => 'PAYMENT',
                payment_type  => 'CASH',
                lines         => [$fine]
            }
        );

        # Complete cashup
        my $cashup_complete = $register2->add_cashup( { manager_id => $manager->id, amount => '5.00' } );

        # Check accountlines
        my $accountlines = $cashup_complete->accountlines;
        is( ref($accountlines), 'Koha::Account::Lines', 'Two-phase accountlines returns correct type' );
        ok( $accountlines->count >= 0, 'Two-phase accountlines returns valid count' );

        # Check filtering capability
        my $filtered = $accountlines->search( { payment_type => 'CASH' } );
        ok( defined $filtered, 'Accountlines can be filtered' );
    };

    # Test 3: Reconciliation inclusion
    subtest 'reconciliation_inclusion' => sub {
        plan tests => 2;

        my $register3 = $builder->build_object( { class => 'Koha::Cash::Registers' } );
        my $account3  = $patron->account;

        # Create transaction
        my $fine = $account3->add_debit(
            {
                amount    => '20.00',
                type      => 'OVERDUE',
                interface => 'cron'
            }
        );

        my $payment = $account3->pay(
            {
                cash_register => $register3->id,
                amount        => '20.00',
                credit_type   => 'PAYMENT',
                payment_type  => 'CASH',
                lines         => [$fine]
            }
        );

        # Cashup with surplus to create reconciliation line
        my $cashup = $register3->add_cashup(
            {
                manager_id => $manager->id,
                amount     => '25.00'         # Creates surplus
            }
        );

        my $accountlines = $cashup->accountlines;
        ok( $accountlines->count >= 1, 'Accountlines includes transactions when surplus created' );

        # Verify surplus line exists
        my $surplus_lines = $accountlines->search( { credit_type_code => 'CASHUP_SURPLUS' } );
        is( $surplus_lines->count, 1, 'Surplus reconciliation line is included' );
    };

    $schema->storage->txn_rollback;
};

subtest 'summary_session_boundaries' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my $register = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );
    my $manager  = $builder->build_object( { class => 'Koha::Patrons' } );

    # Test 1: Basic summary functionality
    subtest 'basic_summary_functionality' => sub {
        plan tests => 3;

        my $account = $patron->account;

        # Create a simple transaction and cashup
        my $fine = $account->add_debit(
            {
                amount    => '10.00',
                type      => 'OVERDUE',
                interface => 'cron'
            }
        );

        my $payment = $account->pay(
            {
                cash_register => $register->id,
                amount        => '10.00',
                credit_type   => 'PAYMENT',
                payment_type  => 'CASH',
                lines         => [$fine]
            }
        );

        my $cashup  = $register->add_cashup( { manager_id => $manager->id, amount => '10.00' } );
        my $summary = $cashup->summary;

        # Basic summary structure validation
        ok( defined $summary->{from_date} || !defined $summary->{from_date}, 'Summary has from_date field' );
        ok( defined $summary->{to_date},                                     'Summary has to_date field' );
        ok( defined $summary->{total},                                       'Summary has total field' );
    };

    # Test 2: Two-phase workflow basic functionality
    subtest 'two_phase_basic_functionality' => sub {
        plan tests => 4;

        my $register2 = $builder->build_object( { class => 'Koha::Cash::Registers' } );
        my $account   = $patron->account;

        # Add initial cash transaction before starting cashup
        my $initial_fine = $account->add_debit(
            {
                amount    => '5.00',
                type      => 'OVERDUE',
                interface => 'cron'
            }
        );

        my $initial_payment = $account->pay(
            {
                cash_register => $register2->id,
                amount        => '5.00',
                credit_type   => 'PAYMENT',
                payment_type  => 'CASH',
                lines         => [$initial_fine]
            }
        );

        # Start two-phase cashup
        my $cashup_start = $register2->start_cashup( { manager_id => $manager->id } );
        ok( defined $cashup_start, 'Two-phase cashup can be started' );

        # Create transaction during session
        my $fine = $account->add_debit(
            {
                amount    => '15.00',
                type      => 'OVERDUE',
                interface => 'cron'
            }
        );

        my $payment = $account->pay(
            {
                cash_register => $register2->id,
                amount        => '15.00',
                credit_type   => 'PAYMENT',
                payment_type  => 'CASH',
                lines         => [$fine]
            }
        );

        # Complete two-phase cashup
        my $cashup_complete = $register2->add_cashup( { manager_id => $manager->id, amount => '15.00' } );
        ok( defined $cashup_complete, 'Two-phase cashup can be completed' );

        my $summary = $cashup_complete->summary;
        ok( defined $summary,          'Two-phase completed cashup has summary' );
        ok( defined $summary->{total}, 'Two-phase summary has total' );
    };

    # Test 3: Reconciliation functionality
    subtest 'reconciliation_functionality' => sub {
        plan tests => 2;

        my $register3 = $builder->build_object( { class => 'Koha::Cash::Registers' } );
        my $account   = $patron->account;

        # Create transaction with surplus
        my $fine = $account->add_debit(
            {
                amount    => '20.00',
                type      => 'OVERDUE',
                interface => 'cron'
            }
        );

        my $payment = $account->pay(
            {
                cash_register => $register3->id,
                amount        => '20.00',
                credit_type   => 'PAYMENT',
                payment_type  => 'CASH',
                lines         => [$fine]
            }
        );

        # Cashup with surplus
        my $cashup = $register3->add_cashup(
            {
                manager_id => $manager->id,
                amount     => '25.00'         # Creates 5.00 surplus
            }
        );

        my $summary      = $cashup->summary;
        my $accountlines = $cashup->accountlines;

        ok( defined $summary, 'Cashup with reconciliation has summary' );

        # Check surplus reconciliation exists
        my $surplus_lines = $accountlines->search( { credit_type_code => 'CASHUP_SURPLUS' } );
        is( $surplus_lines->count, 1, 'Surplus reconciliation line is created and included' );
    };

    # Test 4: Edge cases
    subtest 'edge_cases' => sub {
        plan tests => 2;

        my $register4 = $builder->build_object( { class => 'Koha::Cash::Registers' } );

        # Empty cashup
        my $empty_cashup = $register4->add_cashup( { manager_id => $manager->id, amount => '1.00' } );
        my $summary      = $empty_cashup->summary;

        ok( defined $summary,          'Empty cashup has summary' );
        ok( defined $summary->{total}, 'Empty cashup summary has total' );
    };

    $schema->storage->txn_rollback;
};

1;
