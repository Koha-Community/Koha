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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 16;

use Test::Exception;

use Koha::Database;
use Koha::Account;
use Koha::Account::CreditTypes;
use Koha::Account::DebitTypes;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'library' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $register = $builder->build_object(
        {
            class => 'Koha::Cash::Registers',
            value => { branch => $library->branchcode },
        }
    );

    is(
        ref( $register->library ),
        'Koha::Library',
        'Koha::Cash::Register->library should return a Koha::Library'
    );

    is(
        $register->library->id,
        $library->id,
        'Koha::Cash::Register->library returns the correct Koha::Library'
    );

    $schema->storage->txn_rollback;
};

subtest 'accountlines' => sub {
    plan tests => 5;

    $schema->storage->txn_begin;

    my $register = $builder->build_object( { class => 'Koha::Cash::Registers' } );

    my $accountlines = $register->accountlines;
    is(
        ref($accountlines), 'Koha::Account::Lines',
        'Koha::Cash::Register->accountlines should always return a Koha::Account::Lines set'
    );
    is(
        $accountlines->count, 0,
        'Koha::Cash::Register->accountlines should always return the correct number of accountlines'
    );

    my $accountline1 = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => { register_id => $register->id },
        }
    );
    my $accountline2 = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => { register_id => $register->id },
        }
    );

    $accountlines = $register->accountlines;
    is(
        ref($accountlines), 'Koha::Account::Lines',
        'Koha::Cash::Register->accountlines should return a set of Koha::Account::Lines'
    );
    is(
        $accountlines->count, 2,
        'Koha::Cash::Register->accountlines should return the correct number of accountlines'
    );

    $accountline1->delete;
    is(
        $register->accountlines->next->id, $accountline2->id,
        'Koha::Cash::Register->accountlines should return the correct acocuntlines'
    );

    $schema->storage->txn_rollback;
};

subtest 'branch_default' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;
    my $library   = $builder->build_object( { class => 'Koha::Libraries' } );
    my $register1 = $builder->build_object(
        {
            class => 'Koha::Cash::Registers',
            value => { branch => $library->branchcode, branch_default => 1 },
        }
    );
    my $register2 = $builder->build_object(
        {
            class => 'Koha::Cash::Registers',
            value => { branch => $library->branchcode, branch_default => 0 },
        }
    );

    subtest 'store' => sub {
        plan tests => 2;

        $register1->name('Test till 1');
        ok(
            $register1->store(),
            "Store works as expected when branch_default is not changed"
        );

        $register1->branch_default(0);
        throws_ok { $register1->store(); }
        'Koha::Exceptions::Object::ReadOnlyProperty',
            'Exception thrown if direct update to branch_default is attempted';

    };

    subtest 'make_default' => sub {
        plan tests => 3;

        ok( $register2->make_default, 'Koha::Register->make_default ran' );

        $register1 = $register1->get_from_storage;
        $register2 = $register2->get_from_storage;
        is( $register1->branch_default, 0, 'register1 was unset as expected' );
        is( $register2->branch_default, 1, 'register2 was set as expected' );
    };

    subtest 'drop_default' => sub {
        plan tests => 2;

        ok( $register2->drop_default, 'Koha::Register->drop_default ran' );

        $register2 = $register2->get_from_storage;
        is( $register2->branch_default, 0, 'register2 was unset as expected' );
    };

    $schema->storage->txn_rollback;
};

subtest 'cashup' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    # Ensure reconciliation notes are not required for these tests
    t::lib::Mocks::mock_preference( 'CashupReconciliationNoteRequired', 0 );

    my $register = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );

    my $cashup1;
    subtest 'add_cashup' => sub {
        plan tests => 6;

        ok(
            $cashup1 = $register->add_cashup(
                {
                    manager_id      => $patron->id,
                    reconciliations => [ { payment_type => 'CASH', actual_amount => '12.00' } ]
                }
            ),
            'call successfull'
        );

        is(
            ref($cashup1),
            'Koha::Cash::Register::Cashup',
            'return is Koha::Cash::Register::Cashup'
        );
        is(
            $cashup1->code, 'CASHUP',
            'CASHUP code set in Koha::Cash::Register::Cashup'
        );
        is(
            $cashup1->manager_id, $patron->id,
            'manager_id set correctly in Koha::Cash::Register::Cashup'
        );
        is(
            $cashup1->amount, '12.000000',
            'amount set correctly in Koha::Cash::Register::Cashup'
        );
        isnt(
            $cashup1->timestamp, undef,
            'timestamp set in Koha::Cash::Register::Cashup'
        );
    };

    subtest 'last_cashup' => sub {
        plan tests => 3;

        my $cashup2 = $register->add_cashup(
            { manager_id => $patron->id, reconciliations => [ { payment_type => 'CASH', actual_amount => '6.00' } ] } );

        my $last_cashup = $register->last_cashup;
        is(
            ref($last_cashup),
            'Koha::Cash::Register::Cashup',
            'A cashup was returned when one existed'
        );
        is(
            $last_cashup->id, $cashup2->id,
            'The most recent cashup was returned'
        );
        $cashup1->delete;
        $cashup2->delete;
        $last_cashup = $register->last_cashup;
        is( $last_cashup, undef, 'undef is returned when no cashup exists' );
    };

    subtest 'cashups' => sub {
        plan tests => 4;

        my $cashups = $register->cashups;
        is(
            ref($cashups), 'Koha::Cash::Register::Cashups',
            'Koha::Cash::Register->cashups should always return a Koha::Cash::Register::Cashups set'
        );
        is(
            $cashups->count, 0,
            'Koha::Cash::Register->cashups should always return the correct number of cashups'
        );

        my $cashup3 = $register->add_cashup(
            { manager_id => $patron->id, reconciliations => [ { payment_type => 'CASH', actual_amount => '6.00' } ] } );

        $cashups = $register->cashups;
        is(
            ref($cashups), 'Koha::Cash::Register::Cashups',
            'Koha::Cash::Register->cashups should return a Koha::Cash::Register::Cashups set'
        );
        is(
            $cashups->count, 1,
            'Koha::Cash::Register->cashups should return the correct number of cashups'
        );

        $cashup3->delete;
    };

    subtest 'outstanding_accountlines' => sub {
        plan tests => 6;

        $schema->storage->txn_begin;

        my $test_register = $builder->build_object( { class => 'Koha::Cash::Registers' } );
        my $accountlines  = $test_register->outstanding_accountlines;
        is(
            ref($accountlines), 'Koha::Account::Lines',
            'Koha::Cash::Register->outstanding_accountlines should always return a Koha::Account::Lines set'
        );
        is(
            $accountlines->count, 0,
            'Koha::Cash::Register->outstanding_accountlines should always return the correct number of accountlines'
        );

        my $test_patron = $builder->build_object( { class => 'Koha::Patrons' } );

        my $accountline1 = $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id  => $test_register->id,
                    amount       => -2.50,
                    date         => \'SYSDATE() - INTERVAL 5 MINUTE',
                    payment_type => 'CASH'
                },
            }
        );
        my $accountline2 = $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id  => $test_register->id,
                    amount       => -1.50,
                    date         => \'SYSDATE() - INTERVAL 5 MINUTE',
                    payment_type => 'CASH'
                },
            }
        );

        $accountlines = $test_register->outstanding_accountlines;
        is( $accountlines->count, 2, 'No cashup, all accountlines returned' );

        # Calculate expected amount for this cashup
        my $expected_amount =
            ( $test_register->outstanding_accountlines->total( { payment_type => [ 'CASH', 'SIP00' ] } ) ) * -1;
        my $cashup3 = $test_register->add_cashup(
            {
                manager_id      => $test_patron->id,
                reconciliations => [ { payment_type => 'CASH', actual_amount => $expected_amount } ]
            }
        );

        $accountlines = $test_register->outstanding_accountlines;
        is( $accountlines->count, 0, 'Cashup added, no accountlines returned' );

        my $accountline3 = $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id  => $test_register->id,
                    amount       => 1.50,
                    date         => \'SYSDATE() + INTERVAL 5 MINUTE',
                    payment_type => 'CASH'
                },
            }
        );

        $accountlines = $test_register->outstanding_accountlines;
        is(
            $accountlines->count, 1,
            'Accountline added, one accountline returned'
        );
        is(
            $accountlines->next->id,
            $accountline3->id, 'Correct accountline returned'
        );

        $schema->storage->txn_rollback;
    };

    $schema->storage->txn_rollback;
};

subtest 'cashup_reconciliation' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    # Ensure reconciliation notes are not required for these tests
    t::lib::Mocks::mock_preference( 'CashupReconciliationNoteRequired', 0 );

    my $register = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );

    # Create some outstanding accountlines to establish expected amount
    my $accountline1 = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => {
                register_id      => $register->id,
                borrowernumber   => $patron->id,
                amount           => -10.00,                             # Credit (payment)
                credit_type_code => 'PAYMENT',
                debit_type_code  => undef,
                payment_type     => 'CASH',
                date             => \'SYSDATE() - INTERVAL 1 MINUTE',
                timestamp        => \'SYSDATE() - INTERVAL 1 MINUTE',
            }
        }
    );
    my $accountline2 = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => {
                register_id      => $register->id,
                borrowernumber   => $patron->id,
                amount           => -5.00,                              # Credit (payment)
                credit_type_code => 'PAYMENT',
                debit_type_code  => undef,
                payment_type     => 'CASH',
                date             => \'SYSDATE() - INTERVAL 1 MINUTE',
                timestamp        => \'SYSDATE() - INTERVAL 1 MINUTE',
            }
        }
    );

    my $expected_amount =
        $register->outstanding_accountlines->total( { payment_type => [ 'CASH', 'SIP00' ] } );    # Should be -15.00
    is( $expected_amount, -15.00, "Expected cash amount is calculated correctly" );

    subtest 'balanced_cashup' => sub {
        plan tests => 3;

        $schema->storage->txn_begin;

        # Test exact match - no surplus/deficit accountlines should be created
        my $amount = abs($expected_amount);    # 15.00 actual matches 15.00 expected

        my $cashup = $register->add_cashup(
            {
                manager_id      => $patron->id,
                reconciliations => [ { payment_type => 'CASH', actual_amount => $amount } ]
            }
        );

        ok( $cashup, 'Cashup created successfully' );
        is( sprintf( '%.0f', $cashup->amount ), sprintf( '%.0f', $amount ), 'Cashup amount matches actual amount' );

        # Check no surplus/deficit accountlines were created
        my $reconciliation_lines = Koha::Account::Lines->search(
            {
                register_id => $register->id,
                '-or'       => [
                    { credit_type_code => 'CASHUP_SURPLUS' },
                    { debit_type_code  => 'CASHUP_DEFICIT' }
                ]
            }
        );

        is( $reconciliation_lines->count, 0, 'No reconciliation accountlines created for balanced cashup' );

        $schema->storage->txn_rollback;
    };

    subtest 'surplus_cashup' => sub {
        plan tests => 10;

        $schema->storage->txn_begin;

        my $register2    = $builder->build_object( { class => 'Koha::Cash::Registers' } );
        my $accountline3 = $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id      => $register2->id,
                    borrowernumber   => $patron->id,
                    amount           => -20.00,           # Credit (payment)
                    credit_type_code => 'PAYMENT',
                    debit_type_code  => undef,
                    payment_type     => 'CASH',
                }
            }
        );

        my $expected =
            abs( $register2->outstanding_accountlines->total( { payment_type => [ 'CASH', 'SIP00' ] } ) );    # 20.00
        my $actual  = 25.00;                 # 5.00 surplus
        my $surplus = $actual - $expected;

        my $cashup = $register2->add_cashup(
            {
                manager_id      => $patron->id,
                reconciliations => [ { payment_type => 'CASH', actual_amount => $actual } ]
            }
        );

        ok( $cashup, 'Surplus cashup created successfully' );
        is( sprintf( '%.0f', $cashup->amount ), sprintf( '%.0f', $actual ), 'Cashup amount matches actual amount' );

        # Check surplus accountline was created
        my $surplus_lines = Koha::Account::Lines->search(
            {
                register_id      => $register2->id,
                credit_type_code => 'CASHUP_SURPLUS'
            }
        );

        is( $surplus_lines->count, 1, 'One surplus accountline created' );

        my $surplus_line = $surplus_lines->next;
        is(
            sprintf( '%.0f', $surplus_line->amount ), sprintf( '%.0f', -$surplus ),
            'Surplus amount is correct (negative for credit)'
        );
        is( $surplus_line->branchcode,   $register2->branch,          'Surplus branchcode matches register branch' );
        is( $surplus_line->payment_type, 'CASH',                      'Surplus payment_type is set to CASH' );
        is( sprintf( '%.0f', $surplus_line->amountoutstanding ), '0', 'Surplus amountoutstanding is set to 0' );

        # Note should be undef for surplus without user note
        is( $surplus_line->note, undef, 'No note for surplus without user reconciliation note' );

        # Test surplus with user note
        my $register_with_note    = $builder->build_object( { class => 'Koha::Cash::Registers' } );
        my $accountline_with_note = $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id      => $register_with_note->id,
                    borrowernumber   => $patron->id,
                    amount           => -10.00,
                    credit_type_code => 'PAYMENT',
                    debit_type_code  => undef,
                    payment_type     => 'CASH',
                }
            }
        );

        my $cashup_with_note = $register_with_note->add_cashup(
            {
                manager_id      => $patron->id,
                reconciliations => [
                    {
                        payment_type => 'CASH', actual_amount => 15.00,
                        note         => 'Found extra \x{00A3}5 under the till drawer'
                    }
                ],    # 5.00 surplus, note in £5 UTF-8
            }
        );

        my $surplus_with_note = Koha::Account::Lines->search(
            {
                register_id      => $register_with_note->id,
                credit_type_code => 'CASHUP_SURPLUS'
            }
        )->next;

        like(
            $surplus_with_note->note, qr/Found extra .+5 under the till drawer/,
            'User note included in surplus accountline'
        );
        is(
            $surplus_with_note->note, 'Found extra \x{00A3}5 under the till drawer',
            'Only user note stored (no base reconciliation info)'
        );

        $schema->storage->txn_rollback;
    };

    subtest 'deficit_cashup' => sub {
        plan tests => 10;

        $schema->storage->txn_begin;

        my $register3    = $builder->build_object( { class => 'Koha::Cash::Registers' } );
        my $accountline4 = $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id      => $register3->id,
                    borrowernumber   => $patron->id,
                    amount           => -30.00,           # Credit (payment)
                    credit_type_code => 'PAYMENT',
                    debit_type_code  => undef,
                    payment_type     => 'CASH',
                }
            }
        );

        my $expected =
            abs( $register3->outstanding_accountlines->total( { payment_type => [ 'CASH', 'SIP00' ] } ) );    # 30.00
        my $actual  = 25.00;                 # 5.00 deficit
        my $deficit = $expected - $actual;

        my $cashup = $register3->add_cashup(
            {
                manager_id      => $patron->id,
                reconciliations => [ { payment_type => 'CASH', actual_amount => $actual } ]
            }
        );

        ok( $cashup, 'Deficit cashup created successfully' );
        is( sprintf( '%.0f', $cashup->amount ), sprintf( '%.0f', $actual ), 'Cashup amount matches actual amount' );

        # Check deficit accountline was created
        my $deficit_lines = Koha::Account::Lines->search(
            {
                register_id     => $register3->id,
                debit_type_code => 'CASHUP_DEFICIT'
            }
        );

        is( $deficit_lines->count, 1, 'One deficit accountline created' );

        my $deficit_line = $deficit_lines->next;
        is(
            sprintf( '%.0f', $deficit_line->amount ), sprintf( '%.0f', $deficit ),
            'Deficit amount is correct (positive for debit)'
        );
        is( $deficit_line->branchcode,   $register3->branch,          'Deficit branchcode matches register branch' );
        is( $deficit_line->payment_type, 'CASH',                      'Deficit payment_type is set to CASH' );
        is( sprintf( '%.0f', $deficit_line->amountoutstanding ), '0', 'Deficit amountoutstanding is set to 0' );

        # Note should be undef for deficit without user note
        is( $deficit_line->note, undef, 'No note for deficit without user reconciliation note' );

        # Test deficit with user note
        my $register_deficit_note    = $builder->build_object( { class => 'Koha::Cash::Registers' } );
        my $accountline_deficit_note = $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id      => $register_deficit_note->id,
                    borrowernumber   => $patron->id,
                    amount           => -20.00,
                    credit_type_code => 'PAYMENT',
                    debit_type_code  => undef,
                    payment_type     => 'CASH',
                }
            }
        );

        my $cashup_deficit_note = $register_deficit_note->add_cashup(
            {
                manager_id      => $patron->id,
                reconciliations => [
                    {
                        payment_type  => 'CASH',
                        actual_amount => 15.00,
                        note          => 'Till was short, possibly due to incorrect change given',
                    }
                ],    # 5.00 deficit
            }
        );

        my $deficit_with_note = Koha::Account::Lines->search(
            {
                register_id     => $register_deficit_note->id,
                debit_type_code => 'CASHUP_DEFICIT'
            }
        )->next;

        like(
            $deficit_with_note->note, qr/Till was short, possibly due to incorrect change given/,
            'User note included in deficit accountline'
        );
        is(
            $deficit_with_note->note, 'Till was short, possibly due to incorrect change given',
            'Only user note stored (no base reconciliation info)'
        );

        $schema->storage->txn_rollback;
    };

    subtest 'transaction_integrity' => sub {
        plan tests => 4;

        $schema->storage->txn_begin;

        my $register4    = $builder->build_object( { class => 'Koha::Cash::Registers' } );
        my $accountline5 = $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id      => $register4->id,
                    borrowernumber   => $patron->id,
                    amount           => -10.00,
                    credit_type_code => 'PAYMENT',
                    debit_type_code  => undef,
                    payment_type     => 'CASH',
                }
            }
        );

        my $initial_accountline_count = Koha::Account::Lines->search( { register_id => $register4->id } )->count;

        my $initial_action_count = $register4->cashups->count;

        # Test successful transaction
        my $cashup = $register4->add_cashup(
            {
                manager_id      => $patron->id,
                reconciliations => [ { payment_type => 'CASH', actual_amount => 15.00 } ]    # Creates surplus
            }
        );

        # Check both cashup action and surplus accountline were created
        is( $register4->cashups->count, $initial_action_count + 1, 'Cashup action created' );

        my $final_accountline_count = Koha::Account::Lines->search( { register_id => $register4->id } )->count;

        is( $final_accountline_count, $initial_accountline_count + 1, 'Surplus accountline created' );

        # Verify the new accountline is the surplus
        my $surplus_line = Koha::Account::Lines->search(
            {
                register_id      => $register4->id,
                credit_type_code => 'CASHUP_SURPLUS'
            }
        )->next;

        ok( $surplus_line, 'Surplus accountline exists' );
        is( $surplus_line->register_id, $register4->id, 'Surplus linked to correct register' );

        $schema->storage->txn_rollback;
    };

    subtest 'note_handling' => sub {
        plan tests => 2;

        $schema->storage->txn_begin;

        my $register_note_test    = $builder->build_object( { class => 'Koha::Cash::Registers' } );
        my $accountline_note_test = $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id      => $register_note_test->id,
                    borrowernumber   => $patron->id,
                    amount           => -10.00,
                    credit_type_code => 'PAYMENT',
                    debit_type_code  => undef,
                    payment_type     => 'CASH',
                }
            }
        );

        # Test balanced cashup with note (should not create surplus/deficit)
        my $balanced_cashup = $register_note_test->add_cashup(
            {
                manager_id      => $patron->id,
                reconciliations => [
                    {
                        payment_type  => 'CASH',
                        actual_amount => 10.00,
                        note          => 'This note should be ignored for balanced cashup',
                    }
                ],    # Balanced
            }
        );

        my $balanced_reconciliation_lines = Koha::Account::Lines->search(
            {
                register_id => $register_note_test->id,
                '-or'       => [
                    { credit_type_code => 'CASHUP_SURPLUS' },
                    { debit_type_code  => 'CASHUP_DEFICIT' }
                ]
            }
        );

        is(
            $balanced_reconciliation_lines->count, 0,
            'No reconciliation accountlines created for balanced cashup with note'
        );

        # Test empty/whitespace note handling
        my $register_empty_note    = $builder->build_object( { class => 'Koha::Cash::Registers' } );
        my $accountline_empty_note = $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id      => $register_empty_note->id,
                    borrowernumber   => $patron->id,
                    amount           => -10.00,
                    credit_type_code => 'PAYMENT',
                    debit_type_code  => undef,
                    payment_type     => 'CASH',
                }
            }
        );

        my $empty_note_cashup = $register_empty_note->add_cashup(
            {
                manager_id      => $patron->id,
                reconciliations => [
                    { payment_type => 'CASH', actual_amount => 12.00, note => '   ' },    # whitespace-only note
                ],    # 2.00 surplus
            }
        );

        my $empty_note_surplus = Koha::Account::Lines->search(
            {
                register_id      => $register_empty_note->id,
                credit_type_code => 'CASHUP_SURPLUS'
            }
        )->next;

        is(
            $empty_note_surplus->note, undef,
            'No note stored when user note is empty/whitespace'
        );

        $schema->storage->txn_rollback;
    };

    $schema->storage->txn_rollback;
};

subtest 'two_phase_cashup_workflow' => sub {
    plan tests => 15;

    $schema->storage->txn_begin;

    # Create test data
    my $manager  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $register = $builder->build_object(
        {
            class => 'Koha::Cash::Registers',
            value => {
                branch         => $library->branchcode,
                starting_float => 0,
            }
        }
    );

    # Add some test transactions
    my $account_line1 = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => {
                amount           => 10.00,
                date             => \'SYSDATE() - INTERVAL 1 MINUTE',
                register_id      => undef,
                debit_type_code  => 'OVERDUE',
                credit_type_code => undef,
                payment_type     => undef,
            }
        }
    );

    my $account_line2 = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => {
                amount           => -5.00,
                date             => \'SYSDATE() - INTERVAL 1 MINUTE',
                register_id      => $register->id,
                debit_type_code  => undef,
                credit_type_code => 'PAYMENT',
                payment_type     => 'CASH'
            }
        }
    );

    # Test 1: start_cashup creates CASHUP_START action
    my $cashup_start = $register->start_cashup( { manager_id => $manager->id } );

    is(
        ref $cashup_start, 'Koha::Cash::Register::Cashup',
        'start_cashup returns Cash::Register::Cashup object'
    );

    my $start_action = Koha::Cash::Register::Actions->search(
        {
            register_id => $register->id,
            code        => 'CASHUP_START'
        }
    )->next;

    ok( $start_action, 'CASHUP_START action created in database' );
    is( $start_action->manager_id, $manager->id, 'CASHUP_START has correct manager_id' );

    # Test 2: cashup_in_progress detects active cashup
    my $in_progress = $register->cashup_in_progress;
    ok( $in_progress, 'cashup_in_progress detects active cashup' );
    is( $in_progress->id, $start_action->id, 'cashup_in_progress returns correct CASHUP_START action' );

    # Test 3: Cannot start another cashup while one is in progress
    throws_ok {
        $register->start_cashup( { manager_id => $manager->id } );
    }
    'Koha::Exceptions::Object::DuplicateID',
        'Cannot start second cashup while one is in progress';

    # Test 4: outstanding_accountlines behavior during active cashup
    my $outstanding = $register->outstanding_accountlines;
    is( $outstanding->count, 0, 'outstanding_accountlines returns 0 during active cashup' );

    # Test 5: Add transaction after cashup start (should appear in outstanding)
    my $account_line3 = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => {
                amount           => -8.00,
                date             => \'SYSDATE() + INTERVAL 1 MINUTE',
                register_id      => $register->id,
                debit_type_code  => undef,
                credit_type_code => 'PAYMENT',
                payment_type     => 'CASH',
            }
        }
    );

    # This new transaction should appear in outstanding (it's after CASHUP_START)
    $outstanding = $register->outstanding_accountlines;
    is( $outstanding->count, 1, 'New transaction after CASHUP_START appears in outstanding' );

    # Test 6: outstanding_accountlines correctly handles session boundaries
    my $session_accountlines = $register->outstanding_accountlines;
    my $session_total        = $session_accountlines->total;
    is(
        $session_total, -8.00,
        'outstanding_accountlines correctly calculates session totals with CASHUP_START cutoff'
    );

    # Test 7: Complete cashup with exact amount (no reconciliation)
    my $expected_cashup_amount = 5.00;                    # CASH PAYMENT prior to CASHUP_START
    my $cashup_complete        = $register->add_cashup(
        {
            manager_id      => $manager->id,
            reconciliations => [ { payment_type => 'CASH', actual_amount => $expected_cashup_amount } ]
        }
    );

    is(
        ref $cashup_complete, 'Koha::Cash::Register::Cashup',
        'add_cashup returns Cashup object'
    );

    # Check no reconciliation lines were created
    my $surplus_lines = $cashup_complete->accountlines->search(
        {
            register_id      => $register->id,
            credit_type_code => 'CASHUP_SURPLUS'
        }
    );
    my $deficit_lines = $cashup_complete->accountlines->search(
        {
            register_id     => $register->id,
            debit_type_code => 'CASHUP_DEFICIT'
        }
    );

    is( $surplus_lines->count, 0, 'No surplus lines created for exact cashup' );
    is( $deficit_lines->count, 0, 'No deficit lines created for exact cashup' );

    # Test 8: cashup_in_progress returns undef after completion
    $in_progress = $register->cashup_in_progress;
    is( $in_progress, undef, 'cashup_in_progress returns undef after completion' );

    # Test 9: outstanding_accountlines now includes new transaction
    $outstanding = $register->outstanding_accountlines;
    is( $outstanding->count,  1,    'outstanding_accountlines includes transaction after completion' );
    is( $outstanding->total, -8.00, 'outstanding_accountlines total is correct after completion' );

    $schema->storage->txn_rollback;
};

subtest 'cashup_in_progress' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my $register = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $manager  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );

    # Test 1: No cashups ever performed
    subtest 'no_cashups_ever' => sub {
        plan tests => 1;

        my $in_progress = $register->cashup_in_progress;
        is( $in_progress, undef, 'cashup_in_progress returns undef when no cashups have ever been performed' );
    };

    # Test 2: Only quick cashups performed
    subtest 'only_quick_cashups' => sub {
        plan tests => 2;

        # Add cash for first quick cashup
        $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id      => $register->id,
                    borrowernumber   => $patron->id,
                    amount           => -10.00,
                    credit_type_code => 'PAYMENT',
                    payment_type     => 'CASH',
                }
            }
        );

        # Add a quick cashup
        my $quick_cashup = $register->add_cashup(
            { manager_id => $manager->id, reconciliations => [ { payment_type => 'CASH', actual_amount => '10.00' } ] }
        );
        $quick_cashup->timestamp( \'NOW() - INTERVAL 30 MINUTE' )->store();

        my $in_progress = $register->cashup_in_progress;
        is( $in_progress, undef, 'cashup_in_progress returns undef after quick cashup completion' );

        # Add cash for second quick cashup
        $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id      => $register->id,
                    borrowernumber   => $patron->id,
                    amount           => -5.00,
                    credit_type_code => 'PAYMENT',
                    payment_type     => 'CASH',
                }
            }
        );

        # Add another quick cashup
        my $quick_cashup2 = $register->add_cashup(
            { manager_id => $manager->id, reconciliations => [ { payment_type => 'CASH', actual_amount => '5.00' } ] }
        );

        $in_progress = $register->cashup_in_progress;
        is( $in_progress, undef, 'cashup_in_progress returns undef after multiple quick cashups' );
    };

    # Test 3: Multiple CASHUP_START actions
    subtest 'multiple_start_actions' => sub {
        plan tests => 2;

        my $register2 = $builder->build_object( { class => 'Koha::Cash::Registers' } );
        my $patron    = $builder->build_object( { class => 'Koha::Patrons' } );

        # Add cash transactions before starting cashup
        $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id      => $register2->id,
                    borrowernumber   => $patron->id,
                    amount           => -5.00,
                    credit_type_code => 'PAYMENT',
                    payment_type     => 'CASH',
                }
            }
        );

        # Create multiple CASHUP_START actions
        my $start1 = $register2->start_cashup( { manager_id => $manager->id } );
        $start1->timestamp( \'NOW() - INTERVAL 60 MINUTE' )->store();

        # Complete the first one
        my $complete1 = $register2->add_cashup(
            { manager_id => $manager->id, reconciliations => [ { payment_type => 'CASH', actual_amount => '1.00' } ] }
        );
        $complete1->timestamp( \'NOW() - INTERVAL 50 MINUTE' )->store();

        # Add more cash for second cashup
        $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id      => $register2->id,
                    borrowernumber   => $patron->id,
                    amount           => -3.00,
                    credit_type_code => 'PAYMENT',
                    payment_type     => 'CASH',
                }
            }
        );

        # Start another one
        my $start2 = $register2->start_cashup( { manager_id => $manager->id } );

        my $in_progress = $register2->cashup_in_progress;
        is( ref($in_progress), 'Koha::Cash::Register::Cashup', 'Returns most recent CASHUP_START when multiple exist' );
        is( $in_progress->id,  $start2->id, 'Returns the correct (most recent) CASHUP_START action' );
    };

    # Test 4: Mixed quick and two-phase workflows
    subtest 'mixed_workflows' => sub {
        plan tests => 3;

        my $register3 = $builder->build_object( { class => 'Koha::Cash::Registers' } );
        my $patron    = $builder->build_object( { class => 'Koha::Patrons' } );

        # Add cash for first quick cashup
        $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id      => $register3->id,
                    borrowernumber   => $patron->id,
                    amount           => -5.00,
                    credit_type_code => 'PAYMENT',
                    payment_type     => 'CASH',
                }
            }
        );

        # Quick cashup first
        my $quick = $register3->add_cashup(
            { manager_id => $manager->id, reconciliations => [ { payment_type => 'CASH', actual_amount => '5.00' } ] }
        );
        $quick->timestamp( \'NOW() - INTERVAL 40 MINUTE' )->store();

        # Add cash for two-phase cashup
        $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id      => $register3->id,
                    borrowernumber   => $patron->id,
                    amount           => -3.00,
                    credit_type_code => 'PAYMENT',
                    payment_type     => 'CASH',
                }
            }
        );

        # Start two-phase
        my $start = $register3->start_cashup( { manager_id => $manager->id } );
        $start->timestamp( \'NOW() - INTERVAL 30 MINUTE' )->store();

        my $in_progress = $register3->cashup_in_progress;
        is( ref($in_progress), 'Koha::Cash::Register::Cashup', 'Detects two-phase in progress after quick cashup' );
        is( $in_progress->id,  $start->id,                     'Returns correct CASHUP_START after mixed workflow' );

        # Complete two-phase
        my $complete = $register3->add_cashup(
            { manager_id => $manager->id, reconciliations => [ { payment_type => 'CASH', actual_amount => '3.00' } ] }
        );

        $in_progress = $register3->cashup_in_progress;
        is( $in_progress, undef, 'Returns undef after completing two-phase in mixed workflow' );
    };

    # Test 5: Timestamp edge cases
    subtest 'timestamp_edge_cases' => sub {
        plan tests => 2;

        my $register4 = $builder->build_object( { class => 'Koha::Cash::Registers' } );
        my $patron    = $builder->build_object( { class => 'Koha::Patrons' } );

        # Add cash for cashup
        $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id      => $register4->id,
                    borrowernumber   => $patron->id,
                    amount           => -2.00,
                    credit_type_code => 'PAYMENT',
                    payment_type     => 'CASH',
                }
            }
        );

        # Create CASHUP_START
        my $start      = $register4->start_cashup( { manager_id => $manager->id } );
        my $start_time = $start->timestamp;

        # Create CASHUP with exactly the same timestamp (edge case)
        my $complete = $register4->add_cashup(
            { manager_id => $manager->id, reconciliations => [ { payment_type => 'CASH', actual_amount => '1.00' } ] }
        );
        $complete->timestamp($start_time)->store();

        my $in_progress = $register4->cashup_in_progress;
        is( $in_progress, undef, 'Handles same timestamp edge case correctly' );

        # Test with CASHUP timestamp slightly before CASHUP_START (edge case)
        my $register5 = $builder->build_object( { class => 'Koha::Cash::Registers' } );

        # Add cash for register5
        $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id      => $register5->id,
                    borrowernumber   => $patron->id,
                    amount           => -2.00,
                    credit_type_code => 'PAYMENT',
                    payment_type     => 'CASH',
                }
            }
        );

        my $start2 = $register5->start_cashup( { manager_id => $manager->id } );

        my $complete2 = $register5->add_cashup(
            { manager_id => $manager->id, reconciliations => [ { payment_type => 'CASH', actual_amount => '1.00' } ] }
        );
        $complete2->timestamp( \'NOW() - INTERVAL 1 MINUTE' )->store();

        $in_progress = $register5->cashup_in_progress;
        is(
            ref($in_progress), 'Koha::Cash::Register::Cashup',
            'Correctly identifies active cashup when completion is backdated'
        );
    };

    # Test 6: Performance with many cashups
    subtest 'performance_with_many_cashups' => sub {
        plan tests => 1;

        my $register6 = $builder->build_object( { class => 'Koha::Cash::Registers' } );
        my $patron    = $builder->build_object( { class => 'Koha::Patrons' } );

        # Add cash for the many quick cashups
        for my $i ( 1 .. 10 ) {
            $builder->build_object(
                {
                    class => 'Koha::Account::Lines',
                    value => {
                        register_id      => $register6->id,
                        borrowernumber   => $patron->id,
                        amount           => -1.00,
                        credit_type_code => 'PAYMENT',
                        payment_type     => 'CASH',
                    }
                }
            );
        }

        # Create many quick cashups
        for my $i ( 1 .. 10 ) {
            my $cashup = $register6->add_cashup(
                {
                    manager_id      => $manager->id,
                    reconciliations => [ { payment_type => 'CASH', actual_amount => '1.00' } ]
                }
            );
            my $timestamp = "NOW() - INTERVAL $i MINUTE";
            $cashup->timestamp( \$timestamp )->store();
        }

        # Add cash for two-phase cashup
        $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id      => $register6->id,
                    borrowernumber   => $patron->id,
                    amount           => -2.00,
                    credit_type_code => 'PAYMENT',
                    payment_type     => 'CASH',
                }
            }
        );

        # Start a two-phase cashup
        my $start = $register6->start_cashup( { manager_id => $manager->id } );

        my $in_progress = $register6->cashup_in_progress;
        is( ref($in_progress), 'Koha::Cash::Register::Cashup', 'Performs correctly with many previous cashups' );
    };

    $schema->storage->txn_rollback;
};

subtest 'start_cashup_parameter_validation' => sub {
    plan tests => 5;

    $schema->storage->txn_begin;

    my $register = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $manager  = $builder->build_object( { class => 'Koha::Patrons' } );

    # Test 1: Valid parameters
    subtest 'valid_parameters' => sub {
        plan tests => 3;

        my $register1 = $builder->build_object( { class => 'Koha::Cash::Registers' } );
        my $patron    = $builder->build_object( { class => 'Koha::Patrons' } );

        # Add cash transaction before starting cashup
        $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id      => $register1->id,
                    borrowernumber   => $patron->id,
                    amount           => -5.00,
                    credit_type_code => 'PAYMENT',
                    payment_type     => 'CASH',
                }
            }
        );

        my $cashup_start = $register1->start_cashup( { manager_id => $manager->id } );

        is( ref($cashup_start),        'Koha::Cash::Register::Cashup', 'start_cashup returns correct object type' );
        is( $cashup_start->manager_id, $manager->id,                   'manager_id set correctly' );
        is( $cashup_start->code,       'CASHUP_START',                 'code set correctly to CASHUP_START' );
    };

    # Test 2: Missing manager_id
    subtest 'missing_manager_id' => sub {
        plan tests => 1;

        my $register2 = $builder->build_object( { class => 'Koha::Cash::Registers' } );

        eval { $register2->start_cashup( {} ); };
        ok( $@, 'start_cashup fails when manager_id is missing' );
    };

    # Test 3: Invalid manager_id
    subtest 'invalid_manager_id' => sub {
        plan tests => 1;

        my $register3 = $builder->build_object( { class => 'Koha::Cash::Registers' } );
        my $patron    = $builder->build_object( { class => 'Koha::Patrons' } );

        # Add cash transaction before starting cashup
        $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id      => $register3->id,
                    borrowernumber   => $patron->id,
                    amount           => -5.00,
                    credit_type_code => 'PAYMENT',
                    payment_type     => 'CASH',
                }
            }
        );

        throws_ok {
            $register3->start_cashup( { manager_id => 99999999 } );
        }
        'Koha::Exceptions::Object::FKConstraint', 'start_cashup throws FK constraint exception with invalid manager_id';
    };

    # Test 4: Duplicate start_cashup prevention
    subtest 'duplicate_prevention' => sub {
        plan tests => 2;

        my $register4 = $builder->build_object( { class => 'Koha::Cash::Registers' } );
        my $patron    = $builder->build_object( { class => 'Koha::Patrons' } );

        # Add cash transaction before starting cashup
        $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id      => $register4->id,
                    borrowernumber   => $patron->id,
                    amount           => -5.00,
                    credit_type_code => 'PAYMENT',
                    payment_type     => 'CASH',
                }
            }
        );

        # First start should succeed
        my $first_start = $register4->start_cashup( { manager_id => $manager->id } );
        ok( $first_start, 'First start_cashup succeeds' );

        # Second start should fail
        throws_ok {
            $register4->start_cashup( { manager_id => $manager->id } );
        }
        'Koha::Exceptions::Object::DuplicateID',
            'Second start_cashup throws DuplicateID exception';
    };

    # Test 5: Database transaction integrity
    subtest 'transaction_integrity' => sub {
        plan tests => 3;

        my $register5 = $builder->build_object( { class => 'Koha::Cash::Registers' } );

        # Add some transactions to establish expected amount
        my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
        my $account = $patron->account;

        my $fine = $account->add_debit(
            {
                amount    => '15.00',
                type      => 'OVERDUE',
                interface => 'cron'
            }
        );

        my $payment = $account->pay(
            {
                cash_register => $register5->id,
                amount        => '15.00',
                credit_type   => 'PAYMENT',
                payment_type  => 'CASH',
                lines         => [$fine]
            }
        );

        my $initial_action_count = $register5->_result->search_related('cash_register_actions')->count;

        my $start = $register5->start_cashup( { manager_id => $manager->id } );

        # Verify action was created
        my $final_action_count = $register5->_result->search_related('cash_register_actions')->count;
        is( $final_action_count, $initial_action_count + 1, 'CASHUP_START action created in database' );

        # Verify expected amount calculation (can be positive or negative, but not zero)
        ok( $start->amount != 0, 'Expected amount calculated correctly' );

        # Verify timestamp is set
        ok( defined $start->timestamp, 'Timestamp is set on CASHUP_START action' );
    };

    $schema->storage->txn_rollback;
};

subtest 'add_cashup' => sub {
    plan tests => 5;

    $schema->storage->txn_begin;

    my $register = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $manager  = $builder->build_object( { class => 'Koha::Patrons' } );

    # Test 1: Valid parameters
    subtest 'valid_parameters' => sub {
        plan tests => 3;

        my $register1 = $builder->build_object( { class => 'Koha::Cash::Registers' } );

        my $cashup = $register1->add_cashup(
            { manager_id => $manager->id, reconciliations => [ { payment_type => 'CASH', actual_amount => '10.00' } ] }
        );

        is( ref($cashup),        'Koha::Cash::Register::Cashup', 'add_cashup returns correct object type' );
        is( $cashup->manager_id, $manager->id,                   'manager_id set correctly' );
        is( $cashup->amount + 0, 10,                             'amount set correctly' );
    };

    # Test 2: Missing required parameters
    subtest 'missing_parameters' => sub {
        plan tests => 3;

        my $register2 = $builder->build_object( { class => 'Koha::Cash::Registers' } );

        # Missing manager_id
        eval {
            $register2->add_cashup( { reconciliations => [ { payment_type => 'CASH', actual_amount => '10.00' } ] } );
        };
        ok( $@, 'add_cashup fails when manager_id is missing' );

        # Missing amount
        eval { $register2->add_cashup( { manager_id => $manager->id } ); };
        ok( $@, 'add_cashup fails when amount is missing' );

        # Missing both
        eval { $register2->add_cashup( {} ); };
        ok( $@, 'add_cashup fails when both parameters are missing' );
    };

    # Test 3: Invalid amount parameter
    subtest 'invalid_amount' => sub {
        plan tests => 6;

        my $register3 = $builder->build_object( { class => 'Koha::Cash::Registers' } );

        # Zero amount is now valid (for non-cash transaction scenarios)
        my $zero_cashup;
        lives_ok {
            $zero_cashup = $register3->add_cashup(
                {
                    manager_id      => $manager->id,
                    reconciliations => [ { payment_type => 'CASH', actual_amount => '0.00' } ]
                }
            );
        }
        'Zero amount is accepted for non-cash transaction scenarios';
        is( $zero_cashup->amount + 0, 0, 'Zero amount stored correctly' );

        # Negative amount is now valid (for float deficits)
        my $negative_cashup;
        lives_ok {
            $negative_cashup = $register3->add_cashup(
                {
                    manager_id      => $manager->id,
                    reconciliations => [ { payment_type => 'CASH', actual_amount => '-5.00' } ]
                }
            );
        }
        'Negative amount is accepted for float deficit scenarios';
        is( $negative_cashup->amount + 0, -5, 'Negative amount stored correctly' );

        # Non-numeric amount
        throws_ok {
            $register3->add_cashup(
                {
                    manager_id      => $manager->id,
                    reconciliations => [ { payment_type => 'CASH', actual_amount => 'invalid' } ]
                }
            );
        }
        'Koha::Exceptions::Account::AmountNotPositive',
            'Non-numeric amount throws AmountNotPositive exception';

        # Empty string amount
        throws_ok {
            $register3->add_cashup(
                { manager_id => $manager->id, reconciliations => [ { payment_type => 'CASH', actual_amount => '' } ] }
            );
        }
        'Koha::Exceptions::Account::AmountNotPositive',
            'Empty string amount throws AmountNotPositive exception';
    };

    # Test 4: Reconciliation note handling
    subtest 'reconciliation_note_handling' => sub {
        plan tests => 4;

        my $register4 = $builder->build_object( { class => 'Koha::Cash::Registers' } );
        my $patron    = $builder->build_object( { class => 'Koha::Patrons' } );
        my $account   = $patron->account;

        # Create transaction to enable surplus creation
        my $fine = $account->add_debit(
            {
                amount    => '10.00',
                type      => 'OVERDUE',
                interface => 'cron'
            }
        );

        my $payment = $account->pay(
            {
                cash_register => $register4->id,
                amount        => '10.00',
                credit_type   => 'PAYMENT',
                payment_type  => 'CASH',
                lines         => [$fine]
            }
        );

        # Test normal note
        my $cashup1 = $register4->add_cashup(
            {
                manager_id      => $manager->id,
                reconciliations =>
                    [ { payment_type => 'CASH', actual_amount => '15.00', note => 'Found extra money in drawer' } ]
                ,    # Creates surplus
            }
        );

        my $surplus1 = Koha::Account::Lines->search(
            {
                register_id      => $register4->id,
                credit_type_code => 'CASHUP_SURPLUS'
            }
        )->next;
        is( $surplus1->note, 'Found extra money in drawer', 'Normal reconciliation note stored correctly' );

        # Test very long note (should be truncated)
        my $register5 = $builder->build_object( { class => 'Koha::Cash::Registers' } );
        my $long_note = 'x' x 1500;    # Longer than 1000 character limit

        my $fine2 = $account->add_debit(
            {
                amount    => '10.00',
                type      => 'OVERDUE',
                interface => 'cron'
            }
        );

        my $payment2 = $account->pay(
            {
                cash_register => $register5->id,
                amount        => '10.00',
                credit_type   => 'PAYMENT',
                payment_type  => 'CASH',
                lines         => [$fine2]
            }
        );

        my $cashup2 = $register5->add_cashup(
            {
                manager_id      => $manager->id,
                reconciliations => [ { payment_type => 'CASH', actual_amount => '15.00', note => $long_note } ],
            }
        );

        my $surplus2 = Koha::Account::Lines->search(
            {
                register_id      => $register5->id,
                credit_type_code => 'CASHUP_SURPLUS'
            }
        )->next;
        is( length( $surplus2->note ), 1000, 'Long reconciliation note truncated to 1000 characters' );

        # Test whitespace-only note (should be undef)
        my $register6 = $builder->build_object( { class => 'Koha::Cash::Registers' } );

        my $fine3 = $account->add_debit(
            {
                amount    => '10.00',
                type      => 'OVERDUE',
                interface => 'cron'
            }
        );

        my $payment3 = $account->pay(
            {
                cash_register => $register6->id,
                amount        => '10.00',
                credit_type   => 'PAYMENT',
                payment_type  => 'CASH',
                lines         => [$fine3]
            }
        );

        my $cashup3 = $register6->add_cashup(
            {
                manager_id      => $manager->id,
                reconciliations => [
                    { payment_type => 'CASH', actual_amount => '15.00', note => '   ' },    # whitespace-only note
                ],
            }
        );

        my $surplus3 = Koha::Account::Lines->search(
            {
                register_id      => $register6->id,
                credit_type_code => 'CASHUP_SURPLUS'
            }
        )->next;
        is( $surplus3->note, undef, 'Whitespace-only reconciliation note stored as undef' );

        # Test empty string note (should be undef)
        my $register7 = $builder->build_object( { class => 'Koha::Cash::Registers' } );

        my $fine4 = $account->add_debit(
            {
                amount    => '10.00',
                type      => 'OVERDUE',
                interface => 'cron'
            }
        );

        my $payment4 = $account->pay(
            {
                cash_register => $register7->id,
                amount        => '10.00',
                credit_type   => 'PAYMENT',
                payment_type  => 'CASH',
                lines         => [$fine4]
            }
        );

        my $cashup4 = $register7->add_cashup(
            {
                manager_id      => $manager->id,
                reconciliations => [
                    { payment_type => 'CASH', actual_amount => '15.00', note => '' },    # empty-string note
                ],
            }
        );

        my $surplus4 = Koha::Account::Lines->search(
            {
                register_id      => $register7->id,
                credit_type_code => 'CASHUP_SURPLUS'
            }
        )->next;
        is( $surplus4->note, undef, 'Empty string reconciliation note stored as undef' );
    };

    # Test 5: Invalid manager_id
    subtest 'invalid_manager_id' => sub {
        plan tests => 1;

        my $register9 = $builder->build_object( { class => 'Koha::Cash::Registers' } );

        throws_ok {
            $register9->add_cashup(
                { manager_id => 99999999, reconciliations => [ { payment_type => 'CASH', actual_amount => '10.00' } ] }
            );
        }
        'Koha::Exceptions::Object::FKConstraint', 'add_cashup throws FK constraint exception with invalid manager_id';
    };

    $schema->storage->txn_rollback;
};

subtest 'required_reconciliation_note' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my $register = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $manager  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );
    my $account  = $patron->account;

    # Create a cash transaction
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

    # Enable the required note preference
    t::lib::Mocks::mock_preference( 'CashupReconciliationNoteRequired', 1 );

    # Test 1: Missing note with discrepancy throws exception
    throws_ok {
        $register->add_cashup(
            {
                manager_id      => $manager->id,
                reconciliations => [ { payment_type => 'CASH', actual_amount => '15.00' } ]    # Creates discrepancy
            }
        );
    }
    'Koha::Exceptions::MissingParameter',
        'Missing reconciliation note with discrepancy throws MissingParameter exception when preference enabled';

    # Test 2: Note provided with discrepancy succeeds
    my $cashup1;
    lives_ok {
        $cashup1 = $register->add_cashup(
            {
                manager_id      => $manager->id,
                reconciliations =>
                    [ { payment_type => 'CASH', actual_amount => '15.00', note => 'Found extra money' } ],
            }
        );
    }
    'Cashup with note and discrepancy succeeds when preference enabled';

    # Test 3: No note with no discrepancy succeeds (note only required for discrepancies)
    my $register2 = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $fine2     = $account->add_debit(
        {
            amount    => '20.00',
            type      => 'OVERDUE',
            interface => 'cron'
        }
    );

    my $payment2 = $account->pay(
        {
            cash_register => $register2->id,
            amount        => '20.00',
            credit_type   => 'PAYMENT',
            payment_type  => 'CASH',
            lines         => [$fine2]
        }
    );

    my $cashup2;
    lives_ok {
        $cashup2 = $register2->add_cashup(
            {
                manager_id      => $manager->id,
                reconciliations =>
                    [ { payment_type => 'CASH', actual_amount => '20.00' } ]    # Exact amount, no discrepancy
            }
        );
    }
    'Cashup without note succeeds when there is no discrepancy';

    # Test 4: Preference disabled allows missing note even with discrepancy
    t::lib::Mocks::mock_preference( 'CashupReconciliationNoteRequired', 0 );

    my $register3 = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $fine3     = $account->add_debit(
        {
            amount    => '10.00',
            type      => 'OVERDUE',
            interface => 'cron'
        }
    );

    my $payment3 = $account->pay(
        {
            cash_register => $register3->id,
            amount        => '10.00',
            credit_type   => 'PAYMENT',
            payment_type  => 'CASH',
            lines         => [$fine3]
        }
    );

    my $cashup3;
    lives_ok {
        $cashup3 = $register3->add_cashup(
            {
                manager_id      => $manager->id,
                reconciliations => [ { payment_type => 'CASH', actual_amount => '15.00' } ]    # Creates discrepancy
            }
        );
    }
    'Missing note with discrepancy succeeds when preference disabled';

    $schema->storage->txn_rollback;
};

subtest 'cashup_payment_types' => sub {
    plan tests => 5;

    my $register = $builder->build_object( { class => 'Koha::Cash::Registers' } );

    t::lib::Mocks::mock_preference( 'CashupPaymentTypes', 'CASH,SIP00' );
    is_deeply(
        $register->cashup_payment_types, [ 'CASH', 'SIP00' ],
        'Reads ordered list from CashupPaymentTypes'
    );

    t::lib::Mocks::mock_preference( 'CashupPaymentTypes', 'CHEQUE, CARD , CASH' );
    is_deeply(
        $register->cashup_payment_types, [ 'CHEQUE', 'CARD', 'CASH' ],
        'Trims whitespace and preserves order'
    );

    t::lib::Mocks::mock_preference( 'CashupPaymentTypes', '' );
    is_deeply(
        $register->cashup_payment_types, [ 'CASH', 'SIP00' ],
        'Falls back to [CASH, SIP00] when preference is empty'
    );

    t::lib::Mocks::mock_preference( 'CashupPaymentTypes', undef );
    is_deeply(
        $register->cashup_payment_types, [ 'CASH', 'SIP00' ],
        'Falls back to [CASH, SIP00] when preference is undefined'
    );

    t::lib::Mocks::mock_preference( 'CashupPaymentTypes', ',,CASH,, CHEQUE,' );
    is_deeply(
        $register->cashup_payment_types, [ 'CASH', 'CHEQUE' ],
        'Skips empty fragments from a malformed list'
    );
};

subtest 'cashup_payment_types_breakdown' => sub {
    plan tests => 8;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'CashupReconciliationNoteRequired', 0 );
    t::lib::Mocks::mock_preference( 'CashupPaymentTypes',               'CASH,CHEQUE' );

    my $register = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );

    $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => {
                register_id      => $register->id,
                borrowernumber   => $patron->id,
                amount           => -10.00,
                credit_type_code => 'PAYMENT',
                debit_type_code  => undef,
                payment_type     => 'CASH',
                date             => \'SYSDATE() - INTERVAL 1 MINUTE',
                timestamp        => \'SYSDATE() - INTERVAL 1 MINUTE',
            }
        }
    );
    $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => {
                register_id      => $register->id,
                borrowernumber   => $patron->id,
                amount           => -5.00,
                credit_type_code => 'PAYMENT',
                debit_type_code  => undef,
                payment_type     => 'CHEQUE',
                date             => \'SYSDATE() - INTERVAL 1 MINUTE',
                timestamp        => \'SYSDATE() - INTERVAL 1 MINUTE',
            }
        }
    );

    my $rows = $register->cashup_payment_types_breakdown;
    is( scalar @$rows,                             2,       'One row per configured payment type' );
    is( $rows->[0]->{payment_type},                'CASH',  'First row matches first configured type' );
    is( sprintf( '%.2f', $rows->[0]->{expected} ), '10.00', 'CASH expected total reflects outstanding accountlines' );
    is( sprintf( '%.2f', $rows->[1]->{expected} ), '5.00',  'CHEQUE expected total reflects outstanding accountlines' );

    # Regression: starting a two-phase cashup (CASHUP_START) used to make the
    # helper crash because cashup_in_progress returned a Koha::Cash::Register::Action
    # which has no accountlines method. Confirm cashup_in_progress now returns a
    # Cashup with accountlines, and the breakdown stays callable.
    $register->start_cashup( { manager_id => $patron->id } );

    my $in_progress = $register->cashup_in_progress;
    isa_ok( $in_progress, 'Koha::Cash::Register::Cashup', 'cashup_in_progress returns a Cashup' );
    ok( $in_progress->can('accountlines'), 'returned object can accountlines' );

    my $rows_after_start;
    eval { $rows_after_start = $register->cashup_payment_types_breakdown };
    ok( !$@, 'breakdown callable while a CASHUP_START is in progress' )
        or diag $@;
    is( scalar @{ $rows_after_start || [] }, 2, 'Still returns one row per configured type after start_cashup' );

    $schema->storage->txn_rollback;
};

subtest 'start_cashup_respects_configured_payment_types' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'CashupPaymentTypes', 'CASH,CHEQUE' );

    my $manager  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $register = $builder->build_object( { class => 'Koha::Cash::Registers' } );

    $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => {
                register_id      => $register->id,
                amount           => -10.00,
                credit_type_code => 'PAYMENT',
                debit_type_code  => undef,
                payment_type     => 'CASH',
                date             => \'SYSDATE() - INTERVAL 1 MINUTE',
                timestamp        => \'SYSDATE() - INTERVAL 1 MINUTE',
            }
        }
    );
    $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => {
                register_id      => $register->id,
                amount           => -5.00,
                credit_type_code => 'PAYMENT',
                debit_type_code  => undef,
                payment_type     => 'CHEQUE',
                date             => \'SYSDATE() - INTERVAL 1 MINUTE',
                timestamp        => \'SYSDATE() - INTERVAL 1 MINUTE',
            }
        }
    );

    # Regression: start_cashup used to filter expected_amount on a hardcoded
    # ['CASH','SIP00'] list regardless of CashupPaymentTypes, so the
    # CASHUP_START snapshot amount silently dropped any other configured type.
    my $cashup_start = $register->start_cashup( { manager_id => $manager->id } );

    is(
        sprintf( '%.2f', $cashup_start->amount ), '15.00',
        'CASHUP_START amount reflects all configured payment types, not just CASH/SIP00'
    );

    $schema->storage->txn_rollback;
};

subtest 'cashup_per_payment_type' => sub {
    plan tests => 14;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'CashupReconciliationNoteRequired', 0 );
    t::lib::Mocks::mock_preference( 'CashupPaymentTypes',               'CASH,CHEQUE' );

    my $register = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );

    # Outstanding: CASH 10.00 + CHEQUE 5.00
    $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => {
                register_id      => $register->id,
                borrowernumber   => $patron->id,
                amount           => -10.00,
                credit_type_code => 'PAYMENT',
                debit_type_code  => undef,
                payment_type     => 'CASH',
                date             => \'SYSDATE() - INTERVAL 1 MINUTE',
                timestamp        => \'SYSDATE() - INTERVAL 1 MINUTE',
            }
        }
    );
    $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => {
                register_id      => $register->id,
                borrowernumber   => $patron->id,
                amount           => -5.00,
                credit_type_code => 'PAYMENT',
                debit_type_code  => undef,
                payment_type     => 'CHEQUE',
                date             => \'SYSDATE() - INTERVAL 1 MINUTE',
                timestamp        => \'SYSDATE() - INTERVAL 1 MINUTE',
            }
        }
    );

    # Mixed: cash deficit £1 + cheque surplus £2
    my $cashup = $register->add_cashup(
        {
            manager_id      => $patron->id,
            reconciliations => [
                { payment_type => 'CASH',   actual_amount => 9.00 },
                { payment_type => 'CHEQUE', actual_amount => 7.00 },
            ],
        }
    );

    ok( $cashup, 'Per-type cashup created' );
    is( sprintf( '%.2f', $cashup->amount ), '16.00', 'CASHUP action stores total of all actual_amounts' );

    my $surplus =
        Koha::Account::Lines->search( { register_id => $register->id, credit_type_code => 'CASHUP_SURPLUS' } )->next;
    ok( $surplus, 'Surplus accountline created for cheque overage' );
    is( $surplus->payment_type,                     'CHEQUE', 'Surplus tagged with cheque payment type' );
    is( sprintf( '%.2f', abs( $surplus->amount ) ), '2.00',   'Cheque surplus is £2.00' );

    my $deficit =
        Koha::Account::Lines->search( { register_id => $register->id, debit_type_code => 'CASHUP_DEFICIT' } )->next;
    ok( $deficit, 'Deficit accountline created for cash shortfall' );
    is( $deficit->payment_type,              'CASH', 'Deficit tagged with cash payment type' );
    is( sprintf( '%.2f', $deficit->amount ), '1.00', 'Cash deficit is £1.00' );

    # Balanced types create no lines — verify no PAYMENT_TYPE='CARD' surplus/deficit was emitted
    my $card_lines = Koha::Account::Lines->search(
        {
            register_id  => $register->id,
            payment_type => 'CARD',
            -or          => [
                { credit_type_code => 'CASHUP_SURPLUS' },
                { debit_type_code  => 'CASHUP_DEFICIT' }
            ]
        }
    );
    is( $card_lines->count, 0, 'No reconciliation lines for unconfigured payment types' );

    # Reject unknown payment type
    throws_ok {
        $register->add_cashup(
            {
                manager_id      => $patron->id,
                reconciliations => [ { payment_type => 'GIFTCARD', actual_amount => 5.00 } ],
            }
        );
    }
    'Koha::Exceptions::Object::BadValue', 'Rejects payment type not in CashupPaymentTypes';

    # Reject missing actual_amount
    throws_ok {
        $register->add_cashup(
            {
                manager_id      => $patron->id,
                reconciliations => [ { payment_type => 'CASH' } ],
            }
        );
    }
    'Koha::Exceptions::MissingParameter', 'Rejects entry missing actual_amount';

    # Reject non-numeric actual_amount
    throws_ok {
        $register->add_cashup(
            {
                manager_id      => $patron->id,
                reconciliations => [ { payment_type => 'CASH', actual_amount => 'abc' } ],
            }
        );
    }
    'Koha::Exceptions::Account::AmountNotPositive', 'Rejects non-numeric actual_amount';

    # Missing 'reconciliations' parameter
    throws_ok {
        $register->add_cashup( { manager_id => $patron->id } );
    }
    'Koha::Exceptions::MissingParameter', "Rejects when 'reconciliations' is not provided";

    # Empty reconciliations arrayref
    throws_ok {
        $register->add_cashup( { manager_id => $patron->id, reconciliations => [] } );
    }
    'Koha::Exceptions::MissingParameter', 'Rejects an empty reconciliations arrayref';

    $schema->storage->txn_rollback;
};

subtest 'cashup_per_payment_type_notes' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'CashupReconciliationNoteRequired', 0 );
    t::lib::Mocks::mock_preference( 'CashupPaymentTypes',               'CASH,CHEQUE' );

    my $register = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );

    # Outstanding: CASH 10.00 + CHEQUE 5.00
    for my $pt (qw(CASH CHEQUE)) {
        my $amt = $pt eq 'CASH' ? -10.00 : -5.00;
        $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id      => $register->id,
                    borrowernumber   => $patron->id,
                    amount           => $amt,
                    credit_type_code => 'PAYMENT',
                    debit_type_code  => undef,
                    payment_type     => $pt,
                    date             => \'SYSDATE() - INTERVAL 1 MINUTE',
                    timestamp        => \'SYSDATE() - INTERVAL 1 MINUTE',
                }
            }
        );
    }

    # Per-row notes — each discrepant row gets its own reason.
    $register->add_cashup(
        {
            manager_id      => $patron->id,
            reconciliations => [
                { payment_type => 'CASH',   actual_amount => 9.00, note => 'Cash short - change kept' },
                { payment_type => 'CHEQUE', actual_amount => 7.00, note => 'Cheque overage - counted twice' },
            ],
        }
    );

    my $surplus =
        Koha::Account::Lines->search( { register_id => $register->id, credit_type_code => 'CASHUP_SURPLUS' } )->next;
    is( $surplus->note, 'Cheque overage - counted twice', 'Surplus line carries its own per-row note' );

    my $deficit =
        Koha::Account::Lines->search( { register_id => $register->id, debit_type_code => 'CASHUP_DEFICIT' } )->next;
    is( $deficit->note, 'Cash short - change kept', 'Deficit line carries its own per-row note' );

    # Note required: a discrepant row missing its own note throws.
    t::lib::Mocks::mock_preference( 'CashupReconciliationNoteRequired', 1 );

    my $register3 = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    for my $pt (qw(CASH CHEQUE)) {
        my $amt = $pt eq 'CASH' ? -10.00 : -5.00;
        $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => {
                    register_id      => $register3->id,
                    borrowernumber   => $patron->id,
                    amount           => $amt,
                    credit_type_code => 'PAYMENT',
                    debit_type_code  => undef,
                    payment_type     => $pt,
                    date             => \'SYSDATE() - INTERVAL 1 MINUTE',
                    timestamp        => \'SYSDATE() - INTERVAL 1 MINUTE',
                }
            }
        );
    }

    throws_ok {
        $register3->add_cashup(
            {
                manager_id      => $patron->id,
                reconciliations => [
                    { payment_type => 'CASH',   actual_amount => 9.00, note => 'Drawer short' },
                    { payment_type => 'CHEQUE', actual_amount => 7.00 },    # missing
                ],
            }
        );
    }
    'Koha::Exceptions::MissingParameter', 'Note-required throws when a discrepant row lacks its own note';

    # Whitespace-only entry note is treated as undef.
    my $register5 = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => {
                register_id      => $register5->id,
                borrowernumber   => $patron->id,
                amount           => -10.00,
                credit_type_code => 'PAYMENT',
                debit_type_code  => undef,
                payment_type     => 'CASH',
                date             => \'SYSDATE() - INTERVAL 1 MINUTE',
                timestamp        => \'SYSDATE() - INTERVAL 1 MINUTE',
            }
        }
    );
    throws_ok {
        $register5->add_cashup(
            {
                manager_id      => $patron->id,
                reconciliations => [ { payment_type => 'CASH', actual_amount => 9.00, note => '   ' } ],
            }
        );
    }
    'Koha::Exceptions::MissingParameter', 'Whitespace-only entry note does not satisfy the note-required check';

    $schema->storage->txn_rollback;
};
