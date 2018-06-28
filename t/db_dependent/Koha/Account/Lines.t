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

use Test::More tests => 4;
use Test::Exception;

use Koha::Account;
use Koha::Account::Lines;
use Koha::Account::Offsets;
use Koha::Items;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'item() tests' => sub {

    plan tests => 2;

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
        accounttype    => "F",
        amount         => 10,
    })->store;

    my $account_line_item = $line->item;
    is( ref( $account_line_item ), 'Koha::Item', 'Koha::Account::Line->item should return a Koha::Item' );
    is( $line->itemnumber, $account_line_item->itemnumber, 'Koha::Account::Line->item should return the correct item' );

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
            accounttype       => "F",
            amount            => 10,
            amountoutstanding => 10
        }
    )->store;

    my $debit_2 = Koha::Account::Line->new(
        {   borrowernumber    => $patron->id,
            accounttype       => "F",
            amount            => 10,
            amountoutstanding => 10
        }
    )->store;

    $lines = Koha::Account::Lines->search({ borrowernumber => $patron->id });
    is( $lines->total_outstanding, 20, 'total_outstanding sums correctly' );

    my $credit_1 = Koha::Account::Line->new(
        {   borrowernumber    => $patron->id,
            accounttype       => "F",
            amount            => -10,
            amountoutstanding => -10
        }
    )->store;

    $lines = Koha::Account::Lines->search({ borrowernumber => $patron->id });
    is( $lines->total_outstanding, 10, 'total_outstanding sums correctly' );

    my $credit_2 = Koha::Account::Line->new(
        {   borrowernumber    => $patron->id,
            accounttype       => "F",
            amount            => -10,
            amountoutstanding => -10
        }
    )->store;

    $lines = Koha::Account::Lines->search({ borrowernumber => $patron->id });
    is( $lines->total_outstanding, 0, 'total_outstanding sums correctly' );

    my $credit_3 = Koha::Account::Line->new(
        {   borrowernumber    => $patron->id,
            accounttype       => "F",
            amount            => -100,
            amountoutstanding => -100
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

    my $credit = $account->add_credit({ amount => 100, user_id => $patron->id });

    ok( $credit->is_credit, 'is_credit detects credits' );
    ok( !$credit->is_debit, 'is_debit detects credits' );

    my $debit = Koha::Account::Line->new(
    {
        borrowernumber => $patron->id,
        accounttype    => "F",
        amount         => 10,
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

    my $credit = $account->add_credit( { amount => 100, user_id => $patron->id } );

    my $debit_1 = Koha::Account::Line->new(
        {   borrowernumber    => $patron->id,
            accounttype       => "F",
            amount            => 10,
            amountoutstanding => 10
        }
    )->store;

    my $debit_2 = Koha::Account::Line->new(
        {   borrowernumber    => $patron->id,
            accounttype       => "F",
            amount            => 100,
            amountoutstanding => 100
        }
    )->store;

    $credit->discard_changes;
    $debit_1->discard_changes;

    my $debits = Koha::Account::Lines->search({ accountlines_id => $debit_1->id });
    my $remaining_credit = $credit->apply( { debits => $debits, offset_type => 'Manual Credit' } );
    is( $remaining_credit * 1, 90, 'Remaining credit is correctly calculated' );
    $credit->discard_changes;
    is( $credit->amountoutstanding * -1, $remaining_credit, 'Remaining credit correctly stored' );

    # re-read debit info
    $debit_1->discard_changes;
    is( $debit_1->amountoutstanding * 1, 0, 'Debit has been cancelled' );

    my $offsets = Koha::Account::Offsets->search( { credit_id => $credit->id, debit_id => $debit_1->id } );
    is( $offsets->count, 1, 'Only one offset is generated' );
    my $THE_offset = $offsets->next;
    is( $THE_offset->amount * 1, 10, 'Amount was calculated correctly (less than the available credit)' );
    is( $THE_offset->type, 'Manual Credit', 'Passed type stored correctly' );

    $debits = Koha::Account::Lines->search({ accountlines_id => $debit_2->id });
    $remaining_credit = $credit->apply( { debits => $debits } );
    is( $remaining_credit, 0, 'No remaining credit left' );
    $credit->discard_changes;
    is( $credit->amountoutstanding * 1, 0, 'No outstanding credit' );
    $debit_2->discard_changes;
    is( $debit_2->amountoutstanding * 1, 10, 'Outstanding amount decremented correctly' );

    $offsets = Koha::Account::Offsets->search( { credit_id => $credit->id, debit_id => $debit_2->id } );
    is( $offsets->count, 1, 'Only one offset is generated' );
    $THE_offset = $offsets->next;
    is( $THE_offset->amount * 1, 90, 'Amount was calculated correctly (less than the available credit)' );
    is( $THE_offset->type, 'credit_applied', 'Defaults to credit_applied offset type' );

    $debits = Koha::Account::Lines->search({ accountlines_id => $debit_1->id });
    throws_ok
        { $credit->apply({ debits => $debits }); }
        'Koha::Exceptions::Account::NoAvailableCredit',
        '->apply() can only be used with outstanding credits';

    $debits = Koha::Account::Lines->search({ accountlines_id => $credit->id });
    throws_ok
        { $debit_1->apply({ debits => $debits }); }
        'Koha::Exceptions::Account::IsNotCredit',
        '->apply() can only be used with credits';

    $debits = Koha::Account::Lines->search({ accountlines_id => $credit->id });
    my $credit_3 = $account->add_credit({ amount => 1 });
    throws_ok
        { $credit_3->apply({ debits => $debits }); }
        'Koha::Exceptions::Account::IsNotDebit',
        '->apply() can only be applied to credits';

    my $credit_2 = $account->add_credit({ amount => 20 });
    my $debit_3  = Koha::Account::Line->new(
        {   borrowernumber    => $patron->id,
            accounttype       => "F",
            amount            => 100,
            amountoutstanding => 100
        }
    )->store;

    $debits = Koha::Account::Lines->search({ accountlines_id => { -in => [ $debit_1->id, $debit_2->id, $debit_3->id, $credit->id ] } });
    throws_ok {
        $credit_2->apply( { debits => $debits, offset_type => 'Manual Credit' } ); }
        'Koha::Exceptions::Account::IsNotDebit',
        '->apply() rolls back if any of the passed lines is not a debit';

    is( $debit_1->discard_changes->amountoutstanding * 1,   0, 'No changes to already cancelled debit' );
    is( $debit_2->discard_changes->amountoutstanding * 1,  10, 'Debit cancelled' );
    is( $debit_3->discard_changes->amountoutstanding * 1, 100, 'Outstanding amount correctly calculated' );
    is( $credit_2->discard_changes->amountoutstanding * -1, 20, 'No changes made' );

    $debits = Koha::Account::Lines->search({ accountlines_id => { -in => [ $debit_1->id, $debit_2->id, $debit_3->id ] } });
    $remaining_credit = $credit_2->apply( { debits => $debits, offset_type => 'Manual Credit' } );

    is( $debit_1->discard_changes->amountoutstanding * 1,  0, 'No changes to already cancelled debit' );
    is( $debit_2->discard_changes->amountoutstanding * 1,  0, 'Debit cancelled' );
    is( $debit_3->discard_changes->amountoutstanding * 1, 90, 'Outstanding amount correctly calculated' );
    is( $credit_2->discard_changes->amountoutstanding * 1, 0, 'No remaining credit' );

    $schema->storage->txn_rollback;
};
