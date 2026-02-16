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
use Test::More tests => 6;

use Test::Exception;

use Koha::Database;
use Koha::Account;
use Koha::Account::CreditTypes;
use Koha::Account::DebitTypes;

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

    my $register = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );

    my $cashup1;
    subtest 'add_cashup' => sub {
        plan tests => 6;

        ok(
            $cashup1 = $register->add_cashup( { manager_id => $patron->id, amount => '12.00' } ),
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

        my $cashup2 = $register->add_cashup( { manager_id => $patron->id, amount => '6.00' } );

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

        my $cashup3 = $register->add_cashup( { manager_id => $patron->id, amount => '6.00' } );

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

        my $accountlines = $register->outstanding_accountlines;
        is(
            ref($accountlines), 'Koha::Account::Lines',
            'Koha::Cash::Register->outstanding_accountlines should always return a Koha::Account::Lines set'
        );
        is(
            $accountlines->count, 0,
            'Koha::Cash::Register->outstanding_accountlines should always return the correct number of accountlines'
        );

        my $accountline1 = $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => { register_id => $register->id, date => \'NOW() - INTERVAL 5 MINUTE' },
            }
        );
        my $accountline2 = $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => { register_id => $register->id, date => \'NOW() - INTERVAL 5 MINUTE' },
            }
        );

        $accountlines = $register->outstanding_accountlines;
        is( $accountlines->count, 2, 'No cashup, all accountlines returned' );

        my $cashup3 = $register->add_cashup( { manager_id => $patron->id, amount => '2.50' } );

        $accountlines = $register->outstanding_accountlines;
        is( $accountlines->count, 0, 'Cashup added, no accountlines returned' );

        my $accountline3 = $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => { register_id => $register->id },
            }
        );

        # Fake the cashup timestamp to make sure it's before the accountline we just added,
        # we can't trust that these two actions are more than a second apart in a test
        $cashup3->timestamp( \'NOW() - INTERVAL 2 MINUTE' )->store;

        $accountlines = $register->outstanding_accountlines;
        is(
            $accountlines->count, 1,
            'Accountline added, one accountline returned'
        );
        is(
            $accountlines->next->id,
            $accountline3->id, 'Correct accountline returned'
        );
    };

    $schema->storage->txn_rollback;
};

subtest 'cashup_reconciliation' => sub {
    plan tests => 5;

    $schema->storage->txn_begin;

    # Ensure required account types for reconciliation exist (they should already exist from mandatory data)
    use Koha::Account::CreditTypes;
    use Koha::Account::DebitTypes;

    my $surplus_credit_type = Koha::Account::CreditTypes->find( { code => 'CASHUP_SURPLUS' } );
    if ( !$surplus_credit_type ) {
        $surplus_credit_type = $builder->build_object(
            {
                class => 'Koha::Account::CreditTypes',
                value => {
                    code                  => 'CASHUP_SURPLUS',
                    description           => 'Cash register surplus found during cashup',
                    can_be_added_manually => 0,
                    credit_number_enabled => 0,
                    is_system             => 1,
                    archived              => 0,
                }
            }
        );
    }

    my $deficit_debit_type = Koha::Account::DebitTypes->find( { code => 'CASHUP_DEFICIT' } );
    if ( !$deficit_debit_type ) {
        $deficit_debit_type = $builder->build_object(
            {
                class => 'Koha::Account::DebitTypes',
                value => {
                    code                => 'CASHUP_DEFICIT',
                    description         => 'Cash register deficit found during cashup',
                    can_be_invoiced     => 0,
                    can_be_sold         => 0,
                    default_amount      => undef,
                    is_system           => 1,
                    archived            => 0,
                    restricts_checkouts => 0,
                }
            }
        );
    }

    my $register = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );

    # Create some outstanding accountlines to establish expected amount
    my $accountline1 = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => {
                register_id      => $register->id,
                borrowernumber   => $patron->id,
                amount           => -10.00,          # Credit (payment)
                credit_type_code => 'PAYMENT',
                debit_type_code  => undef,
            }
        }
    );
    my $accountline2 = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => {
                register_id      => $register->id,
                borrowernumber   => $patron->id,
                amount           => -5.00,           # Credit (payment)
                credit_type_code => 'PAYMENT',
                debit_type_code  => undef,
            }
        }
    );

    my $expected_amount = $register->outstanding_accountlines->total;    # Should be -15.00

    subtest 'balanced_cashup' => sub {
        plan tests => 3;

        # Test exact match - no surplus/deficit accountlines should be created
        my $amount = abs($expected_amount);                              # 15.00 actual matches 15.00 expected

        my $cashup = $register->add_cashup(
            {
                manager_id => $patron->id,
                amount     => $amount
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
    };

    subtest 'surplus_cashup' => sub {
        plan tests => 7;

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
                }
            }
        );

        my $expected = abs( $register2->outstanding_accountlines->total );    # 20.00
        my $actual   = 25.00;                                                 # 5.00 surplus
        my $surplus  = $actual - $expected;

        my $cashup = $register2->add_cashup(
            {
                manager_id => $patron->id,
                amount     => $actual
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
                }
            }
        );

        my $cashup_with_note = $register_with_note->add_cashup(
            {
                manager_id          => $patron->id,
                amount              => 15.00,                                           # 5.00 surplus
                reconciliation_note => 'Found extra \x{00A3}5 under the till drawer'    # £5 in UTF-8
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
        plan tests => 7;

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
                }
            }
        );

        my $expected = abs( $register3->outstanding_accountlines->total );    # 30.00
        my $actual   = 25.00;                                                 # 5.00 deficit
        my $deficit  = $expected - $actual;

        my $cashup = $register3->add_cashup(
            {
                manager_id => $patron->id,
                amount     => $actual
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
                }
            }
        );

        my $cashup_deficit_note = $register_deficit_note->add_cashup(
            {
                manager_id          => $patron->id,
                amount              => 15.00,                                                     # 5.00 deficit
                reconciliation_note => 'Till was short, possibly due to incorrect change given'
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
                }
            }
        );

        my $initial_accountline_count = Koha::Account::Lines->search( { register_id => $register4->id } )->count;

        my $initial_action_count = $register4->cashups->count;

        # Test successful transaction
        my $cashup = $register4->add_cashup(
            {
                manager_id => $patron->id,
                amount     => 15.00          # Creates surplus
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
                }
            }
        );

        # Test balanced cashup with note (should not create surplus/deficit)
        my $balanced_cashup = $register_note_test->add_cashup(
            {
                manager_id          => $patron->id,
                amount              => 10.00,                                              # Balanced
                reconciliation_note => 'This note should be ignored for balanced cashup'
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
                }
            }
        );

        my $empty_note_cashup = $register_empty_note->add_cashup(
            {
                manager_id          => $patron->id,
                amount              => 12.00,         # 2.00 surplus
                reconciliation_note => '   '          # Whitespace only
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
