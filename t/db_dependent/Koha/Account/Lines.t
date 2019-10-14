#!/usr/bin/perl

# Copyright 2018 Koha Development team
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
# along with Koha; if not, see <http://www.gnu.org/licenses>

use Modern::Perl;

use Test::More tests => 9;
use Test::Exception;

use C4::Circulation qw/AddIssue AddReturn/;
use Koha::Account;
use Koha::Account::Lines;
use Koha::Account::Offsets;
use Koha::Items;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'patron() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $library = $builder->build( { source => 'Branch' } );
    my $patron = $builder->build( { source => 'Borrower' } );

    my $line = Koha::Account::Line->new(
    {
        borrowernumber => $patron->{borrowernumber},
        debit_type_code    => "OVERDUE",
        status         => "RETURNED",
        amount         => 10,
        interface      => 'commandline',
    })->store;

    my $account_line_patron = $line->patron;
    is( ref( $account_line_patron ), 'Koha::Patron', 'Koha::Account::Line->patron should return a Koha::Patron' );
    is( $line->borrowernumber, $account_line_patron->borrowernumber, 'Koha::Account::Line->patron should return the correct borrower' );

    $line->borrowernumber(undef)->store;
    is( $line->patron, undef, 'Koha::Account::Line->patron should return undef if no patron linked' );

    $schema->storage->txn_rollback;
};


subtest 'item() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $library = $builder->build( { source => 'Branch' } );
    my $biblioitem = $builder->build( { source => 'Biblioitem' } );
    my $patron = $builder->build( { source => 'Borrower' } );
    my $item = Koha::Item->new(
    {
        biblionumber     => $biblioitem->{biblionumber},
        biblioitemnumber => $biblioitem->{biblioitemnumber},
        homebranch       => $library->{branchcode},
        holdingbranch    => $library->{branchcode},
        barcode          => 'some_barcode_12',
        itype            => 'BK',
    })->store;

    my $line = Koha::Account::Line->new(
    {
        borrowernumber => $patron->{borrowernumber},
        itemnumber     => $item->itemnumber,
        debit_type_code    => "OVERDUE",
        status         => "RETURNED",
        amount         => 10,
        interface      => 'commandline',
    })->store;

    my $account_line_item = $line->item;
    is( ref( $account_line_item ), 'Koha::Item', 'Koha::Account::Line->item should return a Koha::Item' );
    is( $line->itemnumber, $account_line_item->itemnumber, 'Koha::Account::Line->item should return the correct item' );

    $line->itemnumber(undef)->store;
    is( $line->item, undef, 'Koha::Account::Line->item should return undef if no item linked' );

    $schema->storage->txn_rollback;
};

subtest 'total_outstanding() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $patron  = $builder->build_object({ class => 'Koha::Patrons' });

    my $lines = Koha::Account::Lines->search({ borrowernumber => $patron->id });
    is( $lines->total_outstanding, 0, 'total_outstanding returns 0 if no lines (undef case)' );

    my $debit_1 = Koha::Account::Line->new(
        {   borrowernumber    => $patron->id,
            debit_type_code       => "OVERDUE",
            status            => "RETURNED",
            amount            => 10,
            amountoutstanding => 10,
            interface         => 'commandline',
        }
    )->store;

    my $debit_2 = Koha::Account::Line->new(
        {   borrowernumber    => $patron->id,
            debit_type_code       => "OVERDUE",
            status            => "RETURNED",
            amount            => 10,
            amountoutstanding => 10,
            interface         => 'commandline',
        }
    )->store;

    $lines = Koha::Account::Lines->search({ borrowernumber => $patron->id });
    is( $lines->total_outstanding, 20, 'total_outstanding sums correctly' );

    my $credit_1 = Koha::Account::Line->new(
        {   borrowernumber    => $patron->id,
            debit_type_code       => "OVERDUE",
            status            => "RETURNED",
            amount            => -10,
            amountoutstanding => -10,
            interface         => 'commandline',
        }
    )->store;

    $lines = Koha::Account::Lines->search({ borrowernumber => $patron->id });
    is( $lines->total_outstanding, 10, 'total_outstanding sums correctly' );

    my $credit_2 = Koha::Account::Line->new(
        {   borrowernumber    => $patron->id,
            debit_type_code       => "OVERDUE",
            status            => "RETURNED",
            amount            => -10,
            amountoutstanding => -10,
            interface         => 'commandline',
        }
    )->store;

    $lines = Koha::Account::Lines->search({ borrowernumber => $patron->id });
    is( $lines->total_outstanding, 0, 'total_outstanding sums correctly' );

    my $credit_3 = Koha::Account::Line->new(
        {   borrowernumber    => $patron->id,
            debit_type_code       => "OVERDUE",
            status            => "RETURNED",
            amount            => -100,
            amountoutstanding => -100,
            interface         => 'commandline',
        }
    )->store;

    $lines = Koha::Account::Lines->search({ borrowernumber => $patron->id });
    is( $lines->total_outstanding, -100, 'total_outstanding sums correctly' );

    $schema->storage->txn_rollback;
};

subtest 'is_credit() and is_debit() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $patron  = $builder->build_object({ class => 'Koha::Patrons' });
    my $account = $patron->account;

    my $credit = $account->add_credit({ amount => 100, user_id => $patron->id, interface => 'commandline' });

    ok( $credit->is_credit, 'is_credit detects credits' );
    ok( !$credit->is_debit, 'is_debit detects credits' );

    my $debit = Koha::Account::Line->new(
    {
        borrowernumber => $patron->id,
        debit_type_code    => "OVERDUE",
        status         => "RETURNED",
        amount         => 10,
        interface      => 'commandline',
    })->store;

    ok( !$debit->is_credit, 'is_credit detects debits' );
    ok( $debit->is_debit, 'is_debit detects debits');

    $schema->storage->txn_rollback;
};

subtest 'apply() tests' => sub {

    plan tests => 24;

    $schema->storage->txn_begin;

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $account = $patron->account;

    my $credit = $account->add_credit( { amount => 100, user_id => $patron->id, interface => 'commandline' } );

    my $debit_1 = Koha::Account::Line->new(
        {   borrowernumber    => $patron->id,
            debit_type_code       => "OVERDUE",
            status            => "RETURNED",
            amount            => 10,
            amountoutstanding => 10,
            interface         => 'commandline',
        }
    )->store;

    my $debit_2 = Koha::Account::Line->new(
        {   borrowernumber    => $patron->id,
            debit_type_code       => "OVERDUE",
            status            => "RETURNED",
            amount            => 100,
            amountoutstanding => 100,
            interface         => 'commandline',
        }
    )->store;

    $credit->discard_changes;
    $debit_1->discard_changes;

    my $debits = Koha::Account::Lines->search({ accountlines_id => $debit_1->id });
    my $remaining_credit = $credit->apply( { debits => [ $debits->as_list ], offset_type => 'Manual Credit' } );
    is( $remaining_credit * 1, 90, 'Remaining credit is correctly calculated' );
    $credit->discard_changes;
    is( $credit->amountoutstanding * -1, $remaining_credit, 'Remaining credit correctly stored' );

    # re-read debit info
    $debit_1->discard_changes;
    is( $debit_1->amountoutstanding * 1, 0, 'Debit has been cancelled' );

    my $offsets = Koha::Account::Offsets->search( { credit_id => $credit->id, debit_id => $debit_1->id } );
    is( $offsets->count, 1, 'Only one offset is generated' );
    my $THE_offset = $offsets->next;
    is( $THE_offset->amount * 1, -10, 'Amount was calculated correctly (less than the available credit)' );
    is( $THE_offset->type, 'Manual Credit', 'Passed type stored correctly' );

    $debits = Koha::Account::Lines->search({ accountlines_id => $debit_2->id });
    $remaining_credit = $credit->apply( { debits => [ $debits->as_list ] } );
    is( $remaining_credit, 0, 'No remaining credit left' );
    $credit->discard_changes;
    is( $credit->amountoutstanding * 1, 0, 'No outstanding credit' );
    $debit_2->discard_changes;
    is( $debit_2->amountoutstanding * 1, 10, 'Outstanding amount decremented correctly' );

    $offsets = Koha::Account::Offsets->search( { credit_id => $credit->id, debit_id => $debit_2->id } );
    is( $offsets->count, 1, 'Only one offset is generated' );
    $THE_offset = $offsets->next;
    is( $THE_offset->amount * 1, -90, 'Amount was calculated correctly (less than the available credit)' );
    is( $THE_offset->type, 'Credit Applied', 'Defaults to \'Credit Applied\' offset type' );

    $debits = Koha::Account::Lines->search({ accountlines_id => $debit_1->id });
    throws_ok
        { $credit->apply({ debits => [ $debits->as_list ] }); }
        'Koha::Exceptions::Account::NoAvailableCredit',
        '->apply() can only be used with outstanding credits';

    $debits = Koha::Account::Lines->search({ accountlines_id => $credit->id });
    throws_ok
        { $debit_1->apply({ debits => [ $debits->as_list ] }); }
        'Koha::Exceptions::Account::IsNotCredit',
        '->apply() can only be used with credits';

    $debits = Koha::Account::Lines->search({ accountlines_id => $credit->id });
    my $credit_3 = $account->add_credit({ amount => 1, interface => 'commandline' });
    throws_ok
        { $credit_3->apply({ debits => [ $debits->as_list ] }); }
        'Koha::Exceptions::Account::IsNotDebit',
        '->apply() can only be applied to credits';

    my $credit_2 = $account->add_credit({ amount => 20, interface => 'commandline' });
    my $debit_3  = Koha::Account::Line->new(
        {   borrowernumber    => $patron->id,
            debit_type_code       => "OVERDUE",
            status            => "RETURNED",
            amount            => 100,
            amountoutstanding => 100,
            interface         => 'commandline',
        }
    )->store;

    $debits = Koha::Account::Lines->search({ accountlines_id => { -in => [ $debit_1->id, $debit_2->id, $debit_3->id, $credit->id ] } });
    throws_ok {
        $credit_2->apply( { debits => [ $debits->as_list ], offset_type => 'Manual Credit' } ); }
        'Koha::Exceptions::Account::IsNotDebit',
        '->apply() rolls back if any of the passed lines is not a debit';

    is( $debit_1->discard_changes->amountoutstanding * 1,   0, 'No changes to already cancelled debit' );
    is( $debit_2->discard_changes->amountoutstanding * 1,  10, 'Debit cancelled' );
    is( $debit_3->discard_changes->amountoutstanding * 1, 100, 'Outstanding amount correctly calculated' );
    is( $credit_2->discard_changes->amountoutstanding * -1, 20, 'No changes made' );

    $debits = Koha::Account::Lines->search({ accountlines_id => { -in => [ $debit_1->id, $debit_2->id, $debit_3->id ] } });
    $remaining_credit = $credit_2->apply( { debits => [ $debits->as_list ], offset_type => 'Manual Credit' } );

    is( $debit_1->discard_changes->amountoutstanding * 1,  0, 'No changes to already cancelled debit' );
    is( $debit_2->discard_changes->amountoutstanding * 1,  0, 'Debit cancelled' );
    is( $debit_3->discard_changes->amountoutstanding * 1, 90, 'Outstanding amount correctly calculated' );
    is( $credit_2->discard_changes->amountoutstanding * 1, 0, 'No remaining credit' );

    $schema->storage->txn_rollback;
};

subtest 'Keep account info when related patron, staff or item is deleted' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $staff = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item = $builder->build_object({ class => 'Koha::Items' });
    my $issue = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => { itemnumber => $item->itemnumber }
        }
    );
    my $line = Koha::Account::Line->new(
    {
        borrowernumber => $patron->borrowernumber,
        manager_id     => $staff->borrowernumber,
        itemnumber     => $item->itemnumber,
        debit_type_code    => "OVERDUE",
        status         => "RETURNED",
        amount         => 10,
        interface      => 'commandline',
    })->store;

    $issue->delete;
    $item->delete;
    $line = $line->get_from_storage;
    is( $line->itemnumber, undef, "The account line should not be deleted when the related item is delete");

    $staff->delete;
    $line = $line->get_from_storage;
    is( $line->manager_id, undef, "The account line should not be deleted when the related staff is delete");

    $patron->delete;
    $line = $line->get_from_storage;
    is( $line->borrowernumber, undef, "The account line should not be deleted when the related patron is delete");

    $schema->storage->txn_rollback;
};

subtest 'adjust() tests' => sub {

    plan tests => 29;

    $schema->storage->txn_begin;

    # count logs before any actions
    my $action_logs = $schema->resultset('ActionLog')->search()->count;

    # Disable logs
    t::lib::Mocks::mock_preference( 'FinesLog', 0 );

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $account = $patron->account;

    my $debit_1 = Koha::Account::Line->new(
        {   borrowernumber    => $patron->id,
            debit_type_code       => "OVERDUE",
            status            => "RETURNED",
            amount            => 10,
            amountoutstanding => 10,
            interface         => 'commandline',
        }
    )->store;

    my $debit_2 = Koha::Account::Line->new(
        {   borrowernumber    => $patron->id,
            debit_type_code       => "OVERDUE",
            status            => "UNRETURNED",
            amount            => 100,
            amountoutstanding => 100,
            interface         => 'commandline'
        }
    )->store;

    my $credit = $account->add_credit( { amount => 40, user_id => $patron->id, interface => 'commandline' } );

    throws_ok { $debit_1->adjust( { amount => 50, type => 'bad', interface => 'commandline' } ) }
    qr/Update type not recognised/, 'Exception thrown for unrecognised type';

    throws_ok { $debit_1->adjust( { amount => 50, type => 'overdue_update', interface => 'commandline' } ) }
    qr/Update type not allowed on this debit_type/,
      'Exception thrown for type conflict';

    # Increment an unpaid fine
    $debit_2->adjust( { amount => 150, type => 'overdue_update', interface => 'commandline' } )->discard_changes;

    is( $debit_2->amount * 1, 150, 'Fine amount was updated in full' );
    is( $debit_2->amountoutstanding * 1, 150, 'Fine amountoutstanding was update in full' );
    isnt( $debit_2->date, undef, 'Date has been set' );

    my $offsets = Koha::Account::Offsets->search( { debit_id => $debit_2->id } );
    is( $offsets->count, 1, 'An offset is generated for the increment' );
    my $THIS_offset = $offsets->next;
    is( $THIS_offset->amount * 1, 50, 'Amount was calculated correctly (increment by 50)' );
    is( $THIS_offset->type, 'OVERDUE_INCREASE', 'Adjust type stored correctly' );

    is( $schema->resultset('ActionLog')->count(), $action_logs + 0, 'No log was added' );

    # Update fine to partially paid
    my $debits = Koha::Account::Lines->search({ accountlines_id => $debit_2->id });
    $credit->apply( { debits => [ $debits->as_list ], offset_type => 'Manual Credit' } );

    $debit_2->discard_changes;
    is( $debit_2->amount * 1, 150, 'Fine amount unaffected by partial payment' );
    is( $debit_2->amountoutstanding * 1, 110, 'Fine amountoutstanding updated by partial payment' );

    # Enable logs
    t::lib::Mocks::mock_preference( 'FinesLog', 1 );

    # Increment the partially paid fine
    $debit_2->adjust( { amount => 160, type => 'overdue_update', interface => 'commandline' } )->discard_changes;

    is( $debit_2->amount * 1, 160, 'Fine amount was updated in full' );
    is( $debit_2->amountoutstanding * 1, 120, 'Fine amountoutstanding was updated by difference' );

    $offsets = Koha::Account::Offsets->search( { debit_id => $debit_2->id } );
    is( $offsets->count, 3, 'An offset is generated for the increment' );
    $THIS_offset = $offsets->last;
    is( $THIS_offset->amount * 1, 10, 'Amount was calculated correctly (increment by 10)' );
    is( $THIS_offset->type, 'OVERDUE_INCREASE', 'Adjust type stored correctly' );

    is( $schema->resultset('ActionLog')->count(), $action_logs + 1, 'Log was added' );

    # Decrement the partially paid fine, less than what was paid
    $debit_2->adjust( { amount => 50, type => 'overdue_update', interface => 'commandline' } )->discard_changes;

    is( $debit_2->amount * 1, 50, 'Fine amount was updated in full' );
    is( $debit_2->amountoutstanding * 1, 10, 'Fine amountoutstanding was updated by difference' );

    $offsets = Koha::Account::Offsets->search( { debit_id => $debit_2->id } );
    is( $offsets->count, 4, 'An offset is generated for the decrement' );
    $THIS_offset = $offsets->last;
    is( $THIS_offset->amount * 1, -110, 'Amount was calculated correctly (decrement by 110)' );
    is( $THIS_offset->type, 'OVERDUE_DECREASE', 'Adjust type stored correctly' );

    # Decrement the partially paid fine, more than what was paid
    $debit_2->adjust( { amount => 30, type => 'overdue_update', interface => 'commandline' } )->discard_changes;
    is( $debit_2->amount * 1, 30, 'Fine amount was updated in full' );
    is( $debit_2->amountoutstanding * 1, 0, 'Fine amountoutstanding was zeroed (payment was 40)' );

    $offsets = Koha::Account::Offsets->search( { debit_id => $debit_2->id } );
    is( $offsets->count, 5, 'An offset is generated for the decrement' );
    $THIS_offset = $offsets->last;
    is( $THIS_offset->amount * 1, -20, 'Amount was calculated correctly (decrement by 20)' );
    is( $THIS_offset->type, 'OVERDUE_DECREASE', 'Adjust type stored correctly' );

    my $overpayment_refund = $account->lines->last;
    is( $overpayment_refund->amount * 1, -10, 'A new credit has been added' );
    is( $overpayment_refund->description, 'Overpayment refund', 'Credit generated with the expected description' );

    $schema->storage->txn_rollback;
};

subtest 'checkout() tests' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item = $builder->build_sample_item;
    my $account = $patron->account;

    t::lib::Mocks::mock_userenv({ branchcode => $library->branchcode });
    my $checkout = AddIssue( $patron->unblessed, $item->barcode );

    my $line = $account->add_debit({
        amount    => 10,
        interface => 'commandline',
        item_id   => $item->itemnumber,
        issue_id  => $checkout->issue_id,
        type      => 'OVERDUE',
    });

    my $line_checkout = $line->checkout;
    is( ref($line_checkout), 'Koha::Checkout', 'Result type is correct' );
    is( $line_checkout->issue_id, $checkout->issue_id, 'Koha::Account::Line->checkout should return the correct checkout');

    my ( $returned, undef, $old_checkout) = C4::Circulation::AddReturn( $item->barcode, $library->branchcode );
    is( $returned, 1, 'The item should have been returned' );

    $line = $line->get_from_storage;
    my $old_line_checkout = $line->checkout;
    is( ref($old_line_checkout), 'Koha::Old::Checkout', 'Result type is correct' );
    is( $old_line_checkout->issue_id, $old_checkout->issue_id, 'Koha::Account::Line->checkout should return the correct old_checkout' );

    $line->issue_id(undef)->store;
    is( $line->checkout, undef, 'Koha::Account::Line->checkout should return undef if no checkout linked' );

    $schema->storage->txn_rollback;
};

subtest "void() tests" => sub {

    plan tests => 16;

    $schema->storage->txn_begin;

    # Create a borrower
    my $categorycode = $builder->build({ source => 'Category' })->{ categorycode };
    my $branchcode   = $builder->build({ source => 'Branch' })->{ branchcode };

    my $borrower = Koha::Patron->new( {
        cardnumber => 'dariahall',
        surname => 'Hall',
        firstname => 'Daria',
    } );
    $borrower->categorycode( $categorycode );
    $borrower->branchcode( $branchcode );
    $borrower->store;

    my $account = Koha::Account->new({ patron_id => $borrower->id });

    my $line1 = Koha::Account::Line->new(
        {
            borrowernumber    => $borrower->borrowernumber,
            amount            => 10,
            amountoutstanding => 10,
            interface         => 'commandline',
            debit_type_code   => 'OVERDUE'
        }
    )->store();
    my $line2 = Koha::Account::Line->new(
        {
            borrowernumber    => $borrower->borrowernumber,
            amount            => 20,
            amountoutstanding => 20,
            interface         => 'commandline',
            debit_type_code   => 'OVERDUE'
        }
    )->store();

    is( $account->balance(), 30, "Account balance is 30" );
    is( $line1->amountoutstanding, 10, 'First fee has amount outstanding of 10' );
    is( $line2->amountoutstanding, 20, 'Second fee has amount outstanding of 20' );

    my $id = $account->pay(
        {
            lines  => [$line1, $line2],
            amount => 30,
        }
    );

    my $account_payment = Koha::Account::Lines->find( $id );

    is( $account->balance(), 0, "Account balance is 0" );

    $line1->_result->discard_changes();
    $line2->_result->discard_changes();
    is( $line1->amountoutstanding+0, 0, 'First fee has amount outstanding of 0' );
    is( $line2->amountoutstanding+0, 0, 'Second fee has amount outstanding of 0' );

    my $ret = $account_payment->void();

    is( ref($ret), 'Koha::Account::Line', 'Void returns the account line' );
    is( $account->balance(), 30, "Account balance is again 30" );

    $account_payment->_result->discard_changes();
    $line1->_result->discard_changes();
    $line2->_result->discard_changes();

    is( $account_payment->credit_type_code, 'Pay', 'Voided payment credit_type_code is still Pay' );
    is( $account_payment->status, 'VOID', 'Voided payment status is VOID' );
    is( $account_payment->amount+0, 0, 'Voided payment amount is 0' );
    is( $account_payment->amountoutstanding+0, 0, 'Voided payment amount outstanding is 0' );

    is( $line1->amountoutstanding+0, 10, 'First fee again has amount outstanding of 10' );
    is( $line2->amountoutstanding+0, 20, 'Second fee again has amount outstanding of 20' );

    # Accountlines that are not credits should be un-voidable
    my $line1_pre = $line1->unblessed();
    $ret = $line1->void();
    $line1->_result->discard_changes();
    my $line1_post = $line1->unblessed();
    is( $ret, undef, 'Attempted void on non-credit returns undef' );
    is_deeply( $line1_pre, $line1_post, 'Non-credit account line cannot be voided' );

    $schema->storage->txn_rollback;
};

1;
