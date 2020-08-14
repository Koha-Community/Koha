#!/usr/bin/perl

# Copyright 2016 Koha Development team
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

use Test::More tests => 11;
use Test::Exception;
use Time::Fake;

use C4::Circulation;
use C4::Context;
use Koha::Item;
use Koha::Item::Transfer::Limits;
use Koha::Items;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use t::lib::TestBuilder;
use t::lib::Mocks;
use t::lib::Dates;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $dbh     = C4::Context->dbh;

my $builder     = t::lib::TestBuilder->new;
my $library     = $builder->build( { source => 'Branch' } );
my $nb_of_items = Koha::Items->search->count;
my $biblio      = $builder->build_sample_biblio();
my $new_item_1   = $builder->build_sample_item({
    biblionumber => $biblio->biblionumber,
    homebranch       => $library->{branchcode},
    holdingbranch    => $library->{branchcode},
});
my $new_item_2   = $builder->build_sample_item({
    biblionumber => $biblio->biblionumber,
    homebranch       => $library->{branchcode},
    holdingbranch    => $library->{branchcode},
});


t::lib::Mocks::mock_userenv({ branchcode => $library->{branchcode} });

like( $new_item_1->itemnumber, qr|^\d+$|, 'Adding a new item should have set the itemnumber' );
is( Koha::Items->search->count, $nb_of_items + 2, 'The 2 items should have been added' );

my $retrieved_item_1 = Koha::Items->find( $new_item_1->itemnumber );
is( $retrieved_item_1->barcode, $new_item_1->barcode, 'Find a item by id should return the correct item' );

subtest 'store' => sub {
    plan tests => 6;

    my $biblio = $builder->build_sample_biblio;
    my $today  = dt_from_string->set( hour => 0, minute => 0, second => 0 );
    my $item   = Koha::Item->new(
        {
            homebranch    => $library->{branchcode},
            holdingbranch => $library->{branchcode},
            biblionumber  => $biblio->biblionumber,
            location      => 'my_loc',
        }
    )->store->get_from_storage;

    is( t::lib::Dates::compare( $item->replacementpricedate, $today ),
        0, 'replacementpricedate must have been set to today if not given' );
    is( t::lib::Dates::compare( $item->datelastseen, $today ),
        0, 'datelastseen must have been set to today if not given' );
    is(
        $item->itype,
        $biblio->biblioitem->itemtype,
        'items.itype must have been set to biblioitem.itemtype is not given'
    );
    is( $item->permanent_location, $item->location,
        'permanent_location must have been set to location if not given' );
    $item->delete;

    subtest '*_on updates' => sub {
        plan tests => 9;

        # Once the '_on' value is set (triggered by the related field turning from false to true)
        # it should not be re-set for any changes outside of the related field being 'unset'.

        my @fields = qw( itemlost withdrawn damaged );
        my $today = dt_from_string();
        my $yesterday = $today->clone()->subtract( days => 1 );

        for my $field ( @fields ) {
            my $item = $builder->build_sample_item(
                {
                    itemlost     => 0,
                    itemlost_on  => undef,
                    withdrawn    => 0,
                    withdrawn_on => undef,
                    damaged      => 0,
                    damaged_on   => undef
                }
            );
            my $field_on = $field . '_on';

            # Set field for the first time
            Time::Fake->offset( $yesterday->epoch );
            $item->$field(1)->store;
            $item->get_from_storage;
            is($item->$field_on, DateTime::Format::MySQL->format_datetime($yesterday), $field_on . " was set upon first truthy setting");

            # Update the field to a new 'true' value
            Time::Fake->offset( $today->epoch );
            $item->$field(2)->store;
            $item->get_from_storage;
            is($item->$field_on, DateTime::Format::MySQL->format_datetime($yesterday), $field_on . " was not updated upon second truthy setting");

            # Update the field to a new 'false' value
            $item->$field(0)->store;
            $item->get_from_storage;
            is($item->$field_on, undef, $field_on . " was unset upon untruthy setting");

            Time::Fake->reset;
        }
    };

    subtest '_lost_found_trigger' => sub {
        plan tests => 6;

        t::lib::Mocks::mock_preference( 'WhenLostChargeReplacementFee', 1 );
        t::lib::Mocks::mock_preference( 'WhenLostForgiveFine',          0 );

        my $processfee_amount  = 20;
        my $replacement_amount = 99.00;
        my $item_type          = $builder->build_object(
            {
                class => 'Koha::ItemTypes',
                value => {
                    notforloan         => undef,
                    rentalcharge       => 0,
                    defaultreplacecost => undef,
                    processfee         => $processfee_amount,
                    rentalcharge_daily => 0,
                }
            }
        );
        my $library = $builder->build_object( { class => 'Koha::Libraries' } );

        $biblio = $builder->build_sample_biblio( { author => 'Hall, Daria' } );

        subtest 'Full write-off tests' => sub {

            plan tests => 12;

            my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
            my $manager =
              $builder->build_object( { class => "Koha::Patrons" } );
            t::lib::Mocks::mock_userenv(
                { patron => $manager, branchcode => $manager->branchcode } );

            my $item = $builder->build_sample_item(
                {
                    biblionumber     => $biblio->biblionumber,
                    library          => $library->branchcode,
                    replacementprice => $replacement_amount,
                    itype            => $item_type->itemtype,
                }
            );

            C4::Circulation::AddIssue( $patron->unblessed, $item->barcode );

            # Simulate item marked as lost
            $item->itemlost(3)->store;
            C4::Circulation::LostItem( $item->itemnumber, 1 );

            my $processing_fee_lines = Koha::Account::Lines->search(
                {
                    borrowernumber  => $patron->id,
                    itemnumber      => $item->itemnumber,
                    debit_type_code => 'PROCESSING'
                }
            );
            is( $processing_fee_lines->count,
                1, 'Only one processing fee produced' );
            my $processing_fee_line = $processing_fee_lines->next;
            is( $processing_fee_line->amount + 0,
                $processfee_amount,
                'The right PROCESSING amount is generated' );
            is( $processing_fee_line->amountoutstanding + 0,
                $processfee_amount,
                'The right PROCESSING amountoutstanding is generated' );

            my $lost_fee_lines = Koha::Account::Lines->search(
                {
                    borrowernumber  => $patron->id,
                    itemnumber      => $item->itemnumber,
                    debit_type_code => 'LOST'
                }
            );
            is( $lost_fee_lines->count, 1, 'Only one lost item fee produced' );
            my $lost_fee_line = $lost_fee_lines->next;
            is( $lost_fee_line->amount + 0,
                $replacement_amount, 'The right LOST amount is generated' );
            is( $lost_fee_line->amountoutstanding + 0,
                $replacement_amount,
                'The right LOST amountoutstanding is generated' );
            is( $lost_fee_line->status, undef, 'The LOST status was not set' );

            my $account = $patron->account;
            my $debts   = $account->outstanding_debits;

            # Write off the debt
            my $credit = $account->add_credit(
                {
                    amount    => $account->balance,
                    type      => 'WRITEOFF',
                    interface => 'test',
                }
            );
            $credit->apply(
                { debits => [ $debts->as_list ], offset_type => 'Writeoff' } );

            # Simulate item marked as found
            $item->itemlost(0)->store;
            is( $item->{_refunded}, undef, 'No LOST_FOUND account line added' );

            $lost_fee_line->discard_changes;    # reload from DB
            is( $lost_fee_line->amountoutstanding + 0,
                0, 'Lost fee has no outstanding amount' );
            is( $lost_fee_line->debit_type_code,
                'LOST', 'Lost fee now still has account type of LOST' );
            is( $lost_fee_line->status, 'FOUND',
                "Lost fee now has account status of FOUND - No Refund" );

            is( $patron->account->balance,
                -0, 'The patron balance is 0, everything was written off' );
        };

        subtest 'Full payment tests' => sub {

            plan tests => 14;

            my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

            my $item = $builder->build_sample_item(
                {
                    biblionumber     => $biblio->biblionumber,
                    library          => $library->branchcode,
                    replacementprice => $replacement_amount,
                    itype            => $item_type->itemtype
                }
            );

            my $issue =
              C4::Circulation::AddIssue( $patron->unblessed, $item->barcode );

            # Simulate item marked as lost
            $item->itemlost(1)->store;
            C4::Circulation::LostItem( $item->itemnumber, 1 );

            my $processing_fee_lines = Koha::Account::Lines->search(
                {
                    borrowernumber  => $patron->id,
                    itemnumber      => $item->itemnumber,
                    debit_type_code => 'PROCESSING'
                }
            );
            is( $processing_fee_lines->count,
                1, 'Only one processing fee produced' );
            my $processing_fee_line = $processing_fee_lines->next;
            is( $processing_fee_line->amount + 0,
                $processfee_amount,
                'The right PROCESSING amount is generated' );
            is( $processing_fee_line->amountoutstanding + 0,
                $processfee_amount,
                'The right PROCESSING amountoutstanding is generated' );

            my $lost_fee_lines = Koha::Account::Lines->search(
                {
                    borrowernumber  => $patron->id,
                    itemnumber      => $item->itemnumber,
                    debit_type_code => 'LOST'
                }
            );
            is( $lost_fee_lines->count, 1, 'Only one lost item fee produced' );
            my $lost_fee_line = $lost_fee_lines->next;
            is( $lost_fee_line->amount + 0,
                $replacement_amount, 'The right LOST amount is generated' );
            is( $lost_fee_line->amountoutstanding + 0,
                $replacement_amount,
                'The right LOST amountountstanding is generated' );

            my $account = $patron->account;
            my $debts   = $account->outstanding_debits;

            # Pay off the debt
            my $credit = $account->add_credit(
                {
                    amount    => $account->balance,
                    type      => 'PAYMENT',
                    interface => 'test',
                }
            );
            $credit->apply(
                { debits => [ $debts->as_list ], offset_type => 'Payment' } );

            # Simulate item marked as found
            $item->itemlost(0)->store;
            is( $item->{_refunded}, 1, 'Refund triggered' );

            my $credit_return = Koha::Account::Lines->search(
                {
                    itemnumber       => $item->itemnumber,
                    credit_type_code => 'LOST_FOUND'
                },
                { rows => 1 }
            )->single;

            ok( $credit_return, 'An account line of type LOST_FOUND is added' );
            is( $credit_return->amount + 0,
                -99.00,
                'The account line of type LOST_FOUND has an amount of -99' );
            is(
                $credit_return->amountoutstanding + 0,
                -99.00,
'The account line of type LOST_FOUND has an amountoutstanding of -99'
            );

            $lost_fee_line->discard_changes;
            is( $lost_fee_line->amountoutstanding + 0,
                0, 'Lost fee has no outstanding amount' );
            is( $lost_fee_line->debit_type_code,
                'LOST', 'Lost fee now still has account type of LOST' );
            is( $lost_fee_line->status, 'FOUND',
                "Lost fee now has account status of FOUND" );

            is( $patron->account->balance, -99,
'The patron balance is -99, a credit that equals the lost fee payment'
            );
        };

        subtest 'Test without payment or write off' => sub {

            plan tests => 14;

            my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

            my $item = $builder->build_sample_item(
                {
                    biblionumber     => $biblio->biblionumber,
                    library          => $library->branchcode,
                    replacementprice => 23.00,
                    replacementprice => $replacement_amount,
                    itype            => $item_type->itemtype
                }
            );

            my $issue =
              C4::Circulation::AddIssue( $patron->unblessed, $item->barcode );

            # Simulate item marked as lost
            $item->itemlost(3)->store;
            C4::Circulation::LostItem( $item->itemnumber, 1 );

            my $processing_fee_lines = Koha::Account::Lines->search(
                {
                    borrowernumber  => $patron->id,
                    itemnumber      => $item->itemnumber,
                    debit_type_code => 'PROCESSING'
                }
            );
            is( $processing_fee_lines->count,
                1, 'Only one processing fee produced' );
            my $processing_fee_line = $processing_fee_lines->next;
            is( $processing_fee_line->amount + 0,
                $processfee_amount,
                'The right PROCESSING amount is generated' );
            is( $processing_fee_line->amountoutstanding + 0,
                $processfee_amount,
                'The right PROCESSING amountoutstanding is generated' );

            my $lost_fee_lines = Koha::Account::Lines->search(
                {
                    borrowernumber  => $patron->id,
                    itemnumber      => $item->itemnumber,
                    debit_type_code => 'LOST'
                }
            );
            is( $lost_fee_lines->count, 1, 'Only one lost item fee produced' );
            my $lost_fee_line = $lost_fee_lines->next;
            is( $lost_fee_line->amount + 0,
                $replacement_amount, 'The right LOST amount is generated' );
            is( $lost_fee_line->amountoutstanding + 0,
                $replacement_amount,
                'The right LOST amountountstanding is generated' );

            # Simulate item marked as found
            $item->itemlost(0)->store;
            is( $item->{_refunded}, 1, 'Refund triggered' );

            my $credit_return = Koha::Account::Lines->search(
                {
                    itemnumber       => $item->itemnumber,
                    credit_type_code => 'LOST_FOUND'
                },
                { rows => 1 }
            )->single;

            ok( $credit_return, 'An account line of type LOST_FOUND is added' );
            is( $credit_return->amount + 0,
                -99.00,
                'The account line of type LOST_FOUND has an amount of -99' );
            is(
                $credit_return->amountoutstanding + 0,
                0,
'The account line of type LOST_FOUND has an amountoutstanding of 0'
            );

            $lost_fee_line->discard_changes;
            is( $lost_fee_line->amountoutstanding + 0,
                0, 'Lost fee has no outstanding amount' );
            is( $lost_fee_line->debit_type_code,
                'LOST', 'Lost fee now still has account type of LOST' );
            is( $lost_fee_line->status, 'FOUND',
                "Lost fee now has account status of FOUND" );

            is( $patron->account->balance,
                20, 'The patron balance is 20, still owes the processing fee' );
        };

        subtest
          'Test with partial payement and write off, and remaining debt' =>
          sub {

            plan tests => 17;

            my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
            my $item = $builder->build_sample_item(
                {
                    biblionumber     => $biblio->biblionumber,
                    library          => $library->branchcode,
                    replacementprice => $replacement_amount,
                    itype            => $item_type->itemtype
                }
            );

            my $issue =
              C4::Circulation::AddIssue( $patron->unblessed, $item->barcode );

            # Simulate item marked as lost
            $item->itemlost(1)->store;
            C4::Circulation::LostItem( $item->itemnumber, 1 );

            my $processing_fee_lines = Koha::Account::Lines->search(
                {
                    borrowernumber  => $patron->id,
                    itemnumber      => $item->itemnumber,
                    debit_type_code => 'PROCESSING'
                }
            );
            is( $processing_fee_lines->count,
                1, 'Only one processing fee produced' );
            my $processing_fee_line = $processing_fee_lines->next;
            is( $processing_fee_line->amount + 0,
                $processfee_amount,
                'The right PROCESSING amount is generated' );
            is( $processing_fee_line->amountoutstanding + 0,
                $processfee_amount,
                'The right PROCESSING amountoutstanding is generated' );

            my $lost_fee_lines = Koha::Account::Lines->search(
                {
                    borrowernumber  => $patron->id,
                    itemnumber      => $item->itemnumber,
                    debit_type_code => 'LOST'
                }
            );
            is( $lost_fee_lines->count, 1, 'Only one lost item fee produced' );
            my $lost_fee_line = $lost_fee_lines->next;
            is( $lost_fee_line->amount + 0,
                $replacement_amount, 'The right LOST amount is generated' );
            is( $lost_fee_line->amountoutstanding + 0,
                $replacement_amount,
                'The right LOST amountountstanding is generated' );

            my $account = $patron->account;
            is(
                $account->balance,
                $processfee_amount + $replacement_amount,
                'Balance is PROCESSING + L'
            );

            # Partially pay fee
            my $payment_amount = 27;
            my $payment        = $account->add_credit(
                {
                    amount    => $payment_amount,
                    type      => 'PAYMENT',
                    interface => 'test',
                }
            );

            $payment->apply(
                { debits => [$lost_fee_line], offset_type => 'Payment' } );

            # Partially write off fee
            my $write_off_amount = 25;
            my $write_off        = $account->add_credit(
                {
                    amount    => $write_off_amount,
                    type      => 'WRITEOFF',
                    interface => 'test',
                }
            );
            $write_off->apply(
                { debits => [$lost_fee_line], offset_type => 'Writeoff' } );

            is(
                $account->balance,
                $processfee_amount +
                  $replacement_amount -
                  $payment_amount -
                  $write_off_amount,
                'Payment and write off applied'
            );

            # Store the amountoutstanding value
            $lost_fee_line->discard_changes;
            my $outstanding = $lost_fee_line->amountoutstanding;

            # Simulate item marked as found
            $item->itemlost(0)->store;
            is( $item->{_refunded}, 1, 'Refund triggered' );

            my $credit_return = Koha::Account::Lines->search(
                {
                    itemnumber       => $item->itemnumber,
                    credit_type_code => 'LOST_FOUND'
                },
                { rows => 1 }
            )->single;

            ok( $credit_return, 'An account line of type LOST_FOUND is added' );

            is(
                $account->balance,
                $processfee_amount - $payment_amount,
                'Balance is PROCESSING - PAYMENT (LOST_FOUND)'
            );

            $lost_fee_line->discard_changes;
            is( $lost_fee_line->amountoutstanding + 0,
                0, 'Lost fee has no outstanding amount' );
            is( $lost_fee_line->debit_type_code,
                'LOST', 'Lost fee now still has account type of LOST' );
            is( $lost_fee_line->status, 'FOUND',
                "Lost fee now has account status of FOUND" );

            is(
                $credit_return->amount + 0,
                ( $payment_amount + $outstanding ) * -1,
'The account line of type LOST_FOUND has an amount equal to the payment + outstanding'
            );
            is(
                $credit_return->amountoutstanding + 0,
                $payment_amount * -1,
'The account line of type LOST_FOUND has an amountoutstanding equal to the payment'
            );

            is(
                $account->balance,
                $processfee_amount - $payment_amount,
'The patron balance is the difference between the PROCESSING and the credit'
            );
          };

        subtest 'Partial payment, existing debits and AccountAutoReconcile' =>
          sub {

            plan tests => 10;

            my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
            my $barcode            = 'KD123456793';
            my $replacement_amount = 100;
            my $processfee_amount  = 20;

            my $item_type = $builder->build_object(
                {
                    class => 'Koha::ItemTypes',
                    value => {
                        notforloan         => undef,
                        rentalcharge       => 0,
                        defaultreplacecost => undef,
                        processfee         => 0,
                        rentalcharge_daily => 0,
                    }
                }
            );
            my $item = Koha::Item->new(
                {
                    biblionumber     => $biblio->biblionumber,
                    homebranch       => $library->branchcode,
                    holdingbranch    => $library->branchcode,
                    barcode          => $barcode,
                    replacementprice => $replacement_amount,
                    itype            => $item_type->itemtype
                },
            )->store;

            my $issue =
              C4::Circulation::AddIssue( $patron->unblessed, $barcode );

            # Simulate item marked as lost
            $item->itemlost(1)->store;
            C4::Circulation::LostItem( $item->itemnumber, 1 );

            my $lost_fee_lines = Koha::Account::Lines->search(
                {
                    borrowernumber  => $patron->id,
                    itemnumber      => $item->itemnumber,
                    debit_type_code => 'LOST'
                }
            );
            is( $lost_fee_lines->count, 1, 'Only one lost item fee produced' );
            my $lost_fee_line = $lost_fee_lines->next;
            is( $lost_fee_line->amount + 0,
                $replacement_amount, 'The right LOST amount is generated' );
            is( $lost_fee_line->amountoutstanding + 0,
                $replacement_amount,
                'The right LOST amountountstanding is generated' );

            my $account = $patron->account;
            is( $account->balance, $replacement_amount, 'Balance is L' );

            # Partially pay fee
            my $payment_amount = 27;
            my $payment        = $account->add_credit(
                {
                    amount    => $payment_amount,
                    type      => 'PAYMENT',
                    interface => 'test',
                }
            );
            $payment->apply(
                { debits => [$lost_fee_line], offset_type => 'Payment' } );

            is(
                $account->balance,
                $replacement_amount - $payment_amount,
                'Payment applied'
            );

            my $manual_debit_amount = 80;
            $account->add_debit(
                {
                    amount    => $manual_debit_amount,
                    type      => 'OVERDUE',
                    interface => 'test'
                }
            );

            is(
                $account->balance,
                $manual_debit_amount + $replacement_amount - $payment_amount,
                'Manual debit applied'
            );

            t::lib::Mocks::mock_preference( 'AccountAutoReconcile', 1 );

            # Simulate item marked as found
            $item->itemlost(0)->store;
            is( $item->{_refunded}, 1, 'Refund triggered' );

            my $credit_return = Koha::Account::Lines->search(
                {
                    itemnumber       => $item->itemnumber,
                    credit_type_code => 'LOST_FOUND'
                },
                { rows => 1 }
            )->single;

            ok( $credit_return, 'An account line of type LOST_FOUND is added' );

            is(
                $account->balance,
                $manual_debit_amount - $payment_amount,
                'Balance is PROCESSING - payment (LOST_FOUND)'
            );

            my $manual_debit = Koha::Account::Lines->search(
                {
                    borrowernumber  => $patron->id,
                    debit_type_code => 'OVERDUE',
                    status          => 'UNRETURNED'
                }
            )->next;
            is(
                $manual_debit->amountoutstanding + 0,
                $manual_debit_amount - $payment_amount,
                'reconcile_balance was called'
            );
          };

        subtest 'Patron deleted' => sub {
            plan tests => 1;

            my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
            my $barcode            = 'KD123456794';
            my $replacement_amount = 100;
            my $processfee_amount  = 20;

            my $item_type = $builder->build_object(
                {
                    class => 'Koha::ItemTypes',
                    value => {
                        notforloan         => undef,
                        rentalcharge       => 0,
                        defaultreplacecost => undef,
                        processfee         => 0,
                        rentalcharge_daily => 0,
                    }
                }
            );
            my $item = Koha::Item->new(
                {
                    biblionumber     => $biblio->biblionumber,
                    homebranch       => $library->branchcode,
                    holdingbranch    => $library->branchcode,
                    barcode          => $barcode,
                    replacementprice => $replacement_amount,
                    itype            => $item_type->itemtype
                },
            )->store;

            my $issue =
              C4::Circulation::AddIssue( $patron->unblessed, $barcode );

            # Simulate item marked as lost
            $item->itemlost(1)->store;
            C4::Circulation::LostItem( $item->itemnumber, 1 );

            $issue->delete();
            $patron->delete();

            # Simulate item marked as found
            $item->itemlost(0)->store;
            is( $item->{_refunded}, undef, 'No refund triggered' );

        };
    };
};

subtest 'get_transfer' => sub {
    plan tests => 3;

    my $transfer = $new_item_1->get_transfer();
    is( $transfer, undef, 'Koha::Item->get_transfer should return undef if the item is not in transit' );

    my $library_to = $builder->build( { source => 'Branch' } );

    C4::Circulation::transferbook({
        from_branch => $new_item_1->holdingbranch,
        to_branch => $library_to->{branchcode},
        barcode => $new_item_1->barcode,
    });

    $transfer = $new_item_1->get_transfer();
    is( ref($transfer), 'Koha::Item::Transfer', 'Koha::Item->get_transfer should return a Koha::Item::Transfers object' );

    is( $transfer->itemnumber, $new_item_1->itemnumber, 'Koha::Item->get_transfer should return a valid Koha::Item::Transfers object' );
};

subtest 'holds' => sub {
    plan tests => 5;

    my $biblio = $builder->build_sample_biblio();
    my $item   = $builder->build_sample_item({
        biblionumber => $biblio->biblionumber,
    });
    is($item->holds->count, 0, "Nothing returned if no holds");
    my $hold1 = $builder->build({ source => 'Reserve', value => { itemnumber=>$item->itemnumber, found => 'T' }});
    my $hold2 = $builder->build({ source => 'Reserve', value => { itemnumber=>$item->itemnumber, found => 'W' }});
    my $hold3 = $builder->build({ source => 'Reserve', value => { itemnumber=>$item->itemnumber, found => 'W' }});

    is($item->holds()->count,3,"Three holds found");
    is($item->holds({found => 'W'})->count,2,"Two waiting holds found");
    is_deeply($item->holds({found => 'T'})->next->unblessed,$hold1,"Found transit holds matches the hold");
    is($item->holds({found => undef})->count, 0,"Nothing returned if no matching holds");
};

subtest 'biblio' => sub {
    plan tests => 2;

    my $biblio = $retrieved_item_1->biblio;
    is( ref( $biblio ), 'Koha::Biblio', 'Koha::Item->biblio should return a Koha::Biblio' );
    is( $biblio->biblionumber, $retrieved_item_1->biblionumber, 'Koha::Item->biblio should return the correct biblio' );
};

subtest 'biblioitem' => sub {
    plan tests => 2;

    my $biblioitem = $retrieved_item_1->biblioitem;
    is( ref( $biblioitem ), 'Koha::Biblioitem', 'Koha::Item->biblioitem should return a Koha::Biblioitem' );
    is( $biblioitem->biblionumber, $retrieved_item_1->biblionumber, 'Koha::Item->biblioitem should return the correct biblioitem' );
};

subtest 'checkout' => sub {
    plan tests => 5;
    my $item = Koha::Items->find( $new_item_1->itemnumber );
    # No checkout yet
    my $checkout = $item->checkout;
    is( $checkout, undef, 'Koha::Item->checkout should return undef if there is no current checkout on this item' );

    # Add a checkout
    my $patron = $builder->build({ source => 'Borrower' });
    C4::Circulation::AddIssue( $patron, $item->barcode );
    $checkout = $retrieved_item_1->checkout;
    is( ref( $checkout ), 'Koha::Checkout', 'Koha::Item->checkout should return a Koha::Checkout' );
    is( $checkout->itemnumber, $item->itemnumber, 'Koha::Item->checkout should return the correct checkout' );
    is( $checkout->borrowernumber, $patron->{borrowernumber}, 'Koha::Item->checkout should return the correct checkout' );

    # Do the return
    C4::Circulation::AddReturn( $item->barcode );

    # There is no more checkout on this item, making sure it will not return old checkouts
    $checkout = $item->checkout;
    is( $checkout, undef, 'Koha::Item->checkout should return undef if there is no *current* checkout on this item' );
};

subtest 'can_be_transferred' => sub {
    plan tests => 5;

    t::lib::Mocks::mock_preference('UseBranchTransferLimits', 1);
    t::lib::Mocks::mock_preference('BranchTransferLimitsType', 'itemtype');

    my $biblio   = $builder->build_sample_biblio();
    my $library1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item  = $builder->build_sample_item({
        biblionumber     => $biblio->biblionumber,
        homebranch       => $library1->branchcode,
        holdingbranch    => $library1->branchcode,
    });

    is(Koha::Item::Transfer::Limits->search({
        fromBranch => $library1->branchcode,
        toBranch => $library2->branchcode,
    })->count, 0, 'There are no transfer limits between libraries.');
    ok($item->can_be_transferred({ to => $library2 }),
       'Item can be transferred between libraries.');

    my $limit = Koha::Item::Transfer::Limit->new({
        fromBranch => $library1->branchcode,
        toBranch => $library2->branchcode,
        itemtype => $item->effective_itemtype,
    })->store;
    is(Koha::Item::Transfer::Limits->search({
        fromBranch => $library1->branchcode,
        toBranch => $library2->branchcode,
    })->count, 1, 'Given we have added a transfer limit,');
    is($item->can_be_transferred({ to => $library2 }), 0,
       'Item can no longer be transferred between libraries.');
    is($item->can_be_transferred({ to => $library2, from => $library1 }), 0,
       'We get the same result also if we pass the from-library parameter.');
};

# Reset nb_of_items prior to testing delete
$nb_of_items = Koha::Items->search->count;

# Test delete
$retrieved_item_1->delete;
is( Koha::Items->search->count, $nb_of_items - 1, 'Delete should have deleted the item' );

$schema->storage->txn_rollback;
