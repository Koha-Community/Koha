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

use Test::More tests => 16;

use Test::MockModule;
use Test::Exception;
use Time::Fake;

use C4::Circulation qw( AddIssue LostItem AddReturn );
use C4::Context;
use C4::Serials qw( NewIssue AddItem2Serial );
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
    plan tests => 7;

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
    is( t::lib::Dates::compare( dt_from_string($item->datelastseen)->ymd, $today ),
        0, 'datelastseen must have been set to today if not given' );
    is(
        $item->itype,
        $biblio->biblioitem->itemtype,
        'items.itype must have been set to biblioitem.itemtype is not given'
    );
    $item->delete;

    subtest 'permanent_location' => sub {
        plan tests => 2;

        subtest 'location passed to ->store' => sub {
            plan tests => 7;

            my $location = 'my_loc';
            my $attributes = {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                biblionumber  => $biblio->biblionumber,
                location      => $location,
            };

            {
                # NewItemsDefaultLocation not set
                t::lib::Mocks::mock_preference( 'NewItemsDefaultLocation', '' );

                # Not passing permanent_location on creating the item
                my $item = Koha::Item->new($attributes)->store->get_from_storage;
                is( $item->location, $location,
                    'location must have been set to location if given' );
                is( $item->permanent_location, $item->location,
                    'permanent_location must have been set to location if not given' );
                $item->delete;

                # Passing permanent_location on creating the item
                $item = Koha::Item->new(
                    { %$attributes, permanent_location => 'perm_loc' } )
                  ->store->get_from_storage;
                is( $item->permanent_location, 'perm_loc',
                    'permanent_location must have been kept if given' );
                $item->delete;
            }

            {
                # NewItemsDefaultLocation set
                my $default_location = 'default_location';
                t::lib::Mocks::mock_preference( 'NewItemsDefaultLocation', $default_location );

                # Not passing permanent_location on creating the item
                my $item = Koha::Item->new($attributes)->store->get_from_storage;
                is( $item->location, $location,
                    'location must have been kept if given' );
                is( $item->permanent_location, $location,
                    'permanent_location must have been set to the location given' );
                $item->delete;

                # Passing permanent_location on creating the item
                $item = Koha::Item->new(
                    { %$attributes, permanent_location => 'perm_loc' } )
                  ->store->get_from_storage;
                is( $item->location, $location,
                    'location must have been kept if given' );
                is( $item->permanent_location, 'perm_loc',
                    'permanent_location must have been kept if given' );
                $item->delete;
            }
        };

        subtest 'location NOT passed to ->store' => sub {
            plan tests => 7;

            my $attributes = {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                biblionumber  => $biblio->biblionumber,
            };

            {
                # NewItemsDefaultLocation not set
                t::lib::Mocks::mock_preference( 'NewItemsDefaultLocation', '' );

                # Not passing permanent_location on creating the item
                my $item = Koha::Item->new($attributes)->store->get_from_storage;
                is( $item->location, undef,
                    'location not passed and no default, it is undef' );
                is( $item->permanent_location, $item->location,
                    'permanent_location must have been set to location if not given' );
                $item->delete;

                # Passing permanent_location on creating the item
                $item = Koha::Item->new(
                    { %$attributes, permanent_location => 'perm_loc' } )
                  ->store->get_from_storage;
                is( $item->permanent_location, 'perm_loc',
                    'permanent_location must have been kept if given' );
                $item->delete;
            }

            {
                # NewItemsDefaultLocation set
                my $default_location = 'default_location';
                t::lib::Mocks::mock_preference( 'NewItemsDefaultLocation', $default_location );

                # Not passing permanent_location on creating the item
                my $item = Koha::Item->new($attributes)->store->get_from_storage;
                is( $item->location, $default_location,
                    'location must have been set to default location if not given' );
                is( $item->permanent_location, $default_location,
                    'permanent_location must have been set to the default location as well' );
                $item->delete;

                # Passing permanent_location on creating the item
                $item = Koha::Item->new(
                    { %$attributes, permanent_location => 'perm_loc' } )
                  ->store->get_from_storage;
                is( $item->location, $default_location,
                    'location must have been set to default location if not given' );
                is( $item->permanent_location, 'perm_loc',
                    'permanent_location must have been kept if given' );
                $item->delete;
            }
        };

    };

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
            is( t::lib::Dates::compare( $item->$field_on, $yesterday ),
                0, $field_on . " was set upon first truthy setting" );

            # Update the field to a new 'true' value
            Time::Fake->offset( $today->epoch );
            $item->$field(2)->store;
            $item->get_from_storage;
            is( t::lib::Dates::compare( $item->$field_on, $yesterday ),
                0, $field_on . " was not updated upon second truthy setting" );

            # Update the field to a new 'false' value
            $item->$field(0)->store;
            $item->get_from_storage;
            is($item->$field_on, undef, $field_on . " was unset upon untruthy setting");

            Time::Fake->reset;
        }
    };

    subtest '_lost_found_trigger' => sub {
        plan tests => 10;

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
            $credit->apply( { debits => [ $debts->as_list ] } );

            # Simulate item marked as found
            $item->itemlost(0)->store;
            is( scalar ( grep { $_->message eq 'lost_refunded' } @{$item->object_messages} ), 0, 'No LOST_FOUND account line added' );

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

            plan tests => 16;

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
            $credit->apply( { debits => [ $debts->as_list ] } );

            # Simulate item marked as found
            $item->itemlost(0)->store;
            is( scalar ( grep { $_->message eq 'lost_refunded' } @{$item->object_messages} ), 1, 'Refund triggered' );

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

            my $processing_return = Koha::Account::Lines->search(
                {
                    itemnumber       => $item->itemnumber,
                    credit_type_code => 'PROCESSING_FOUND'
                },
                { rows => 1 }
            )->single;
            ok( $processing_return, 'An account line of type PROCESSING_FOUND is added' );
            is( $processing_return->amount + 0,
                -20.00,
                'The account line of type PROCESSING_FOUND has an amount of -20' );

            $lost_fee_line->discard_changes;
            is( $lost_fee_line->amountoutstanding + 0,
                0, 'Lost fee has no outstanding amount' );
            is( $lost_fee_line->debit_type_code,
                'LOST', 'Lost fee now still has account type of LOST' );
            is( $lost_fee_line->status, 'FOUND',
                "Lost fee now has account status of FOUND" );

            is( $patron->account->balance, -119,
'The patron balance is -119, a credit that equals the lost fee payment and the processing fee'
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

            # Set processingreturn_policy to '0' so processing fee is retained
            # these tests are just for lostreturn
            my $processingreturn_rule = $builder->build(
                {
                    source => 'CirculationRule',
                    value  => {
                        branchcode   => undef,
                        categorycode => undef,
                        itemtype     => undef,
                        rule_name    => 'processingreturn',
                        rule_value   => '0'
                    }
                }
            );

            # Simulate item marked as found
            $item->itemlost(0)->store;
            is( scalar ( grep { $_->message eq 'lost_refunded' } @{$item->object_messages} ), 1, 'Refund triggered' );

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
          'Test with partial payment and write off, and remaining debt' =>
          sub {

            plan tests => 19;

            t::lib::Mocks::mock_preference( 'AccountAutoReconcile', 0 );

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
                'Balance is PROCESSING + LOST'
            );

            # Partially pay fee (99 - 27 = 72)
            my $payment_amount = 24;
            my $payment        = $account->add_credit(
                {
                    amount    => $payment_amount,
                    type      => 'PAYMENT',
                    interface => 'test',
                }
            );

            $payment->apply( { debits => [$lost_fee_line] } );

            # Partially write off fee (72 - 20 = 52)
            my $write_off_amount = 20;
            my $write_off        = $account->add_credit(
                {
                    amount    => $write_off_amount,
                    type      => 'WRITEOFF',
                    interface => 'test',
                }
            );
            $write_off->apply( { debits => [$lost_fee_line] } );


            my $payment_amount_2 = 3;
            my $payment_2        = $account->add_credit(
                {
                    amount    => $payment_amount_2,
                    type      => 'PAYMENT',
                    interface => 'test',
                }
            );

            $payment_2->apply(
                { debits => [$lost_fee_line] } );

            # Partially write off fee (52 - 5 = 47)
            my $write_off_amount_2 = 5;
            my $write_off_2        = $account->add_credit(
                {
                    amount    => $write_off_amount_2,
                    type      => 'WRITEOFF',
                    interface => 'test',
                }
            );

            $write_off_2->apply(
                { debits => [$lost_fee_line] } );

            is(
                $account->balance,
                $processfee_amount +
                  $replacement_amount -
                  $payment_amount -
                  $write_off_amount -
                  $payment_amount_2 -
                  $write_off_amount_2,
                'Balance is PROCESSING + LOST - PAYMENT 1 - WRITEOFF - PAYMENT 2 - WRITEOFF 2'
            );

            # VOID payment_2 and writeoff_2
            $payment_2->void({ interface => 'test' });
            $write_off_2->void({ interface => 'test' });

            is(
                $account->balance,
                $processfee_amount +
                  $replacement_amount -
                  $payment_amount -
                  $write_off_amount,
                'Balance is PROCESSING + LOST - PAYMENT 1 - WRITEOFF (PAYMENT 2 and WRITEOFF 2 VOIDED)'
            );

            # Store the amountoutstanding value
            $lost_fee_line->discard_changes;
            my $outstanding = $lost_fee_line->amountoutstanding;
            is(
                $outstanding + 0,
                $replacement_amount - $payment_amount - $write_off_amount,
                "Lost Fee Outstanding is LOST - PAYMENT 1 - WRITEOFF"
            );

            # Simulate item marked as found
            $item->itemlost(0)->store;
            is( scalar ( grep { $_->message eq 'lost_refunded' } @{$item->object_messages} ), 1, 'Refund triggered' );

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
'The account line of type LOST_FOUND has an amount equal to the payment 1 + outstanding'
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
            $payment->apply( { debits => [$lost_fee_line] } );

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
            is( scalar ( grep { $_->message eq 'lost_refunded' } @{$item->object_messages} ), 1, 'Refund triggered' );

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
            is( scalar ( grep { $_->message eq 'lost_refunded' } @{$item->object_messages} ), 0, 'No refund triggered' );

        };

        subtest 'restore fine | no overdue' => sub {

            plan tests => 8;

            my $manager =
              $builder->build_object( { class => "Koha::Patrons" } );
            t::lib::Mocks::mock_userenv(
                { patron => $manager, branchcode => $manager->branchcode } );

            # Set lostreturn_policy to 'restore' for tests
            my $specific_rule_restore = $builder->build(
                {
                    source => 'CirculationRule',
                    value  => {
                        branchcode   => $manager->branchcode,
                        categorycode => undef,
                        itemtype     => undef,
                        rule_name    => 'lostreturn',
                        rule_value   => 'restore'
                    }
                }
            );

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
            $credit->apply( { debits => [ $debts->as_list ] } );

            # Simulate item marked as found
            $item->itemlost(0)->store;
            is( scalar ( grep { $_->message eq 'lost_refunded' } @{$item->object_messages} ), 1, 'Refund triggered' );
            is( scalar ( grep { $_->message eq 'lost_restored' } @{$item->object_messages} ), 0, 'Restore not triggered when there is no overdue fine found' );
        };

        subtest 'restore fine | unforgiven overdue' => sub {

            plan tests => 10;

            # Set lostreturn_policy to 'restore' for tests
            my $manager =
              $builder->build_object( { class => "Koha::Patrons" } );
            t::lib::Mocks::mock_userenv(
                { patron => $manager, branchcode => $manager->branchcode } );
            my $specific_rule_restore = $builder->build(
                {
                    source => 'CirculationRule',
                    value  => {
                        branchcode   => $manager->branchcode,
                        categorycode => undef,
                        itemtype     => undef,
                        rule_name    => 'lostreturn',
                        rule_value   => 'restore'
                    }
                }
            );

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
            $credit->apply( { debits => [ $debts->as_list ] } );

            # Fine not forgiven
            my $overdue = $account->add_debit(
                {
                    amount     => 30.00,
                    user_id    => $manager->borrowernumber,
                    library_id => $library->branchcode,
                    interface  => 'test',
                    item_id    => $item->itemnumber,
                    type       => 'OVERDUE',
                }
            )->store();
            $overdue->status('LOST')->store();
            $overdue->discard_changes;
            is( $overdue->status, 'LOST',
                'Overdue status set to LOST' );

            # Simulate item marked as found
            $item->itemlost(0)->store;
            is( scalar ( grep { $_->message eq 'lost_refunded' } @{$item->object_messages} ), 1, 'Refund triggered' );
            is( scalar ( grep { $_->message eq 'lost_restored' } @{$item->object_messages} ), 0, 'Restore not triggered when overdue was not forgiven' );
            $overdue->discard_changes;
            is( $overdue->status, 'FOUND',
                'Overdue status updated to FOUND' );
        };

        subtest 'restore fine | forgiven overdue' => sub {

            plan tests => 12;

            # Set lostreturn_policy to 'restore' for tests
            my $manager =
              $builder->build_object( { class => "Koha::Patrons" } );
            t::lib::Mocks::mock_userenv(
                { patron => $manager, branchcode => $manager->branchcode } );
            my $specific_rule_restore = $builder->build(
                {
                    source => 'CirculationRule',
                    value  => {
                        branchcode   => $manager->branchcode,
                        categorycode => undef,
                        itemtype     => undef,
                        rule_name    => 'lostreturn',
                        rule_value   => 'restore'
                    }
                }
            );

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
            $credit->apply( { debits => [ $debts->as_list ] } );

            # Add overdue
            my $overdue = $account->add_debit(
                {
                    amount     => 30.00,
                    user_id    => $manager->borrowernumber,
                    library_id => $library->branchcode,
                    interface  => 'test',
                    item_id    => $item->itemnumber,
                    type       => 'OVERDUE',
                }
            )->store();
            $overdue->status('LOST')->store();
            is( $overdue->status, 'LOST',
                'Overdue status set to LOST' );

            t::lib::Mocks::mock_preference( 'AccountAutoReconcile', 0 );

            # Forgive fine
            $credit = $account->add_credit(
                {
                    amount     => 30.00,
                    user_id    => $manager->borrowernumber,
                    library_id => $library->branchcode,
                    interface  => 'test',
                    type       => 'FORGIVEN',
                    item_id    => $item->itemnumber
                }
            );
            $credit->apply( { debits => [$overdue] } );

            # Simulate item marked as found
            $item->itemlost(0)->store;
            is( scalar ( grep { $_->message eq 'lost_refunded' } @{$item->object_messages} ), 1, 'Refund triggered' );
            is( scalar ( grep { $_->message eq 'lost_restored' } @{$item->object_messages} ), 1, 'Restore triggered when overdue was forgiven' );
            $overdue->discard_changes;
            is( $overdue->status, 'FOUND', 'Overdue status updated to FOUND' );
            is( $overdue->amountoutstanding, $overdue->amount, 'Overdue outstanding has been restored' );
            $credit->discard_changes;
            is( $credit->status, 'VOID', 'Overdue Forgival has been marked as VOID');
        };

        subtest 'Continue when userenv is not set' => sub {
            plan tests => 1;

            my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
            my $barcode            = 'KD123456795';
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
            my $item = $builder->build_sample_item(
                {
                    biblionumber     => $biblio->biblionumber,
                    homebranch       => $library->branchcode,
                    holdingbranch    => $library->branchcode,
                    barcode          => $barcode,
                    replacementprice => $replacement_amount,
                    itype            => $item_type->itemtype
                }
            );

            my $issue =
              C4::Circulation::AddIssue( $patron->unblessed, $barcode );

            # Simulate item marked as lost
            $item->itemlost(1)->store;
            C4::Circulation::LostItem( $item->itemnumber, 1 );

            # Unset the userenv
            C4::Context->_new_userenv(undef);

            # Simluate item marked as found
            $item->itemlost(0)->store;
            is( scalar ( grep { $_->message eq 'lost_refunded' } @{$item->object_messages} ), 1, 'Refund triggered' );

        };
    };

    subtest 'log_action' => sub {
        plan tests => 2;
        t::lib::Mocks::mock_preference( 'CataloguingLog', 1 );

        my $item = Koha::Item->new(
            {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                biblionumber  => $biblio->biblionumber,
                location      => 'my_loc',
            }
        )->store;
        is(
            Koha::ActionLogs->search(
                {
                    module => 'CATALOGUING',
                    action => 'ADD',
                    object => $item->itemnumber,
                    info   => 'item'
                }
            )->count,
            1,
            "Item creation logged"
        );

        $item->location('another_loc')->store;
        is(
            Koha::ActionLogs->search(
                {
                    module => 'CATALOGUING',
                    action => 'MODIFY',
                    object => $item->itemnumber
                }
            )->count,
            1,
            "Item modification logged"
        );
    };
};

subtest 'get_transfer' => sub {
    plan tests => 7;

    my $transfer = $new_item_1->get_transfer();
    is( $transfer, undef, 'Koha::Item->get_transfer should return undef if the item is not in transit' );

    my $library_to = $builder->build( { source => 'Branch' } );

    my $transfer_1 = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                itemnumber    => $new_item_1->itemnumber,
                frombranch    => $new_item_1->holdingbranch,
                tobranch      => $library_to->{branchcode},
                reason        => 'Manual',
                datesent      => undef,
                datearrived   => undef,
                datecancelled => undef,
                daterequested => \'NOW()'
            }
        }
    );

    $transfer = $new_item_1->get_transfer();
    is( ref($transfer), 'Koha::Item::Transfer', 'Koha::Item->get_transfer should return a Koha::Item::Transfer object' );

    my $transfer_2 = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                itemnumber    => $new_item_1->itemnumber,
                frombranch    => $new_item_1->holdingbranch,
                tobranch      => $library_to->{branchcode},
                reason        => 'Manual',
                datesent      => undef,
                datearrived   => undef,
                datecancelled => undef,
                daterequested => \'NOW()'
            }
        }
    );

    $transfer = $new_item_1->get_transfer();
    is( $transfer->branchtransfer_id, $transfer_1->branchtransfer_id, 'Koha::Item->get_transfer returns the oldest transfer request');

    $transfer_2->datesent(\'NOW()')->store;
    $transfer = $new_item_1->get_transfer();
    is( $transfer->branchtransfer_id, $transfer_2->branchtransfer_id, 'Koha::Item->get_transfer returns the in_transit transfer');

    my $transfer_3 = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                itemnumber    => $new_item_1->itemnumber,
                frombranch    => $new_item_1->holdingbranch,
                tobranch      => $library_to->{branchcode},
                reason        => 'Manual',
                datesent      => undef,
                datearrived   => undef,
                datecancelled => undef,
                daterequested => \'NOW()'
            }
        }
    );

    $transfer_2->datearrived(\'NOW()')->store;
    $transfer = $new_item_1->get_transfer();
    is( $transfer->branchtransfer_id, $transfer_1->branchtransfer_id, 'Koha::Item->get_transfer returns the next queued transfer');
    is( $transfer->itemnumber, $new_item_1->itemnumber, 'Koha::Item->get_transfer returns the right items transfer' );

    $transfer_1->datecancelled(\'NOW()')->store;
    $transfer = $new_item_1->get_transfer();
    is( $transfer->branchtransfer_id, $transfer_3->branchtransfer_id, 'Koha::Item->get_transfer ignores cancelled transfers');
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

# Restore userenv
t::lib::Mocks::mock_userenv({ branchcode => $library->{branchcode} });
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

subtest 'filter_by_visible_in_opac() tests' => sub {

    plan tests => 14;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    my $mocked_category = Test::MockModule->new('Koha::Patron::Category');
    my $exception = 1;
    $mocked_category->mock( 'override_hidden_items', sub {
        return $exception;
    });

    # have a fresh biblio
    my $biblio = $builder->build_sample_biblio;
    # have two itemtypes
    my $itype_1 = $builder->build_object({ class => 'Koha::ItemTypes' });
    my $itype_2 = $builder->build_object({ class => 'Koha::ItemTypes' });
    # have 5 items on that biblio
    my $item_1 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => -1,
            itype        => $itype_1->itemtype,
            withdrawn    => 1,
            copynumber   => undef
        }
    );
    my $item_2 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => 0,
            itype        => $itype_2->itemtype,
            withdrawn    => 2,
            copynumber   => undef
        }
    );
    my $item_3 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => 1,
            itype        => $itype_1->itemtype,
            withdrawn    => 3,
            copynumber   => undef
        }
    );
    my $item_4 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => 0,
            itype        => $itype_2->itemtype,
            withdrawn    => 4,
            copynumber   => undef
        }
    );
    my $item_5 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => 0,
            itype        => $itype_1->itemtype,
            withdrawn    => 5,
            copynumber   => undef
        }
    );
    my $item_6 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => 2,
            itype        => $itype_1->itemtype,
            withdrawn    => 5,
            copynumber   => undef
        }
    );

    my $rules = undef;

    my $mocked_context = Test::MockModule->new('C4::Context');
    $mocked_context->mock( 'yaml_preference', sub {
        return $rules;
    });

    t::lib::Mocks::mock_preference( 'hidelostitems', 0 );
    is( $biblio->items->filter_by_visible_in_opac->count,
        6, 'No rules passed, hidelostitems unset' );

    is( $biblio->items->filter_by_visible_in_opac({ patron => $patron })->count,
        6, 'No rules passed, hidelostitems unset, patron exception changes nothing' );

    $rules = { copynumber => [ 2 ] };

    t::lib::Mocks::mock_preference( 'hidelostitems', 1 );
    is(
        $biblio->items->filter_by_visible_in_opac->count,
        3,
        'No rules passed, hidelostitems set'
    );

    is(
        $biblio->items->filter_by_visible_in_opac({ patron => $patron })->count,
        3,
        'No rules passed, hidelostitems set, patron exception changes nothing'
    );

    $rules = { biblionumber => [ $biblio->biblionumber ] };
    is(
        $biblio->items->filter_by_visible_in_opac->count,
        0,
        'Biblionumber rule successfully hides all items'
    );

    my $biblio2 = $builder->build_sample_biblio;
    $rules = { biblionumber => [ $biblio2->biblionumber ] };
    my $prefetched = $biblio->items->search({},{ prefetch => ['branchtransfers','reserves'] })->filter_by_visible_in_opac;
    ok( $prefetched->next, "Can retrieve object when prefetching and hiding on a duplicated column");

    $rules = { withdrawn => [ 1, 2 ], copynumber => [ 2 ] };
    is(
        $biblio->items->filter_by_visible_in_opac->count,
        2,
        'Rules on withdrawn, hidelostitems set'
    );

    is(
        $biblio->items->filter_by_visible_in_opac({ patron => $patron })->count,
        3,
        'hidelostitems set, rules on withdrawn but patron override passed'
    );

    $rules = { itype => [ $itype_1->itemtype ], copynumber => [ 2 ] };
    is(
        $biblio->items->filter_by_visible_in_opac->count,
        2,
        'Rules on itype, hidelostitems set'
    );

    $rules = { withdrawn => [ 1, 2 ], itype => [ $itype_1->itemtype ], copynumber => [ 2 ] };
    is(
        $biblio->items->filter_by_visible_in_opac->count,
        1,
        'Rules on itype and withdrawn, hidelostitems set'
    );
    is(
        $biblio->items->filter_by_visible_in_opac
          ->next->itemnumber,
        $item_4->itemnumber,
        'The right item is returned'
    );

    $rules = { withdrawn => [ 1, 2 ], itype => [ $itype_2->itemtype ], copynumber => [ 2 ] };
    is(
        $biblio->items->filter_by_visible_in_opac->count,
        1,
        'Rules on itype and withdrawn, hidelostitems set'
    );
    is(
        $biblio->items->filter_by_visible_in_opac
          ->next->itemnumber,
        $item_5->itemnumber,
        'The right item is returned'
    );

    # Make sure the warning on the about page will work
    $rules = { itemlost => ['AB'] };
    my $c = Koha::Items->filter_by_visible_in_opac->count;
    my @warnings = C4::Context->dbh->selectrow_array('SHOW WARNINGS');
    like( $warnings[2], qr/Truncated incorrect (DOUBLE|DECIMAL) value: 'AB'/);

    $schema->storage->txn_rollback;
};

subtest 'filter_out_lost() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    # have a fresh biblio
    my $biblio = $builder->build_sample_biblio;
    # have 3 items on that biblio
    my $item_1 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => -1,
        }
    );
    my $item_2 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => 0,
        }
    );
    my $item_3 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => 1,
        }
    );

    is( $biblio->items->filter_out_lost->next->itemnumber, $item_2->itemnumber, 'Right item returned' );
    is( $biblio->items->filter_out_lost->count, 1, 'Only one item is not lost' );

    $schema->storage->txn_rollback;
};

subtest 'move_to_biblio() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $biblio1 = $builder->build_sample_biblio;
    my $biblio2 = $builder->build_sample_biblio;
    my $item1 = $builder->build_sample_item({ biblionumber => $biblio1->biblionumber });
    my $item2 = $builder->build_sample_item({ biblionumber => $biblio1->biblionumber });

    $biblio1->items->move_to_biblio($biblio2);

    $item1->discard_changes;
    $item2->discard_changes;

    is($item1->biblionumber, $biblio2->biblionumber, "Item 1 moved");
    is($item2->biblionumber, $biblio2->biblionumber, "Item 2 moved");

    $schema->storage->txn_rollback;

};

subtest 'search_ordered' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $library_a = $builder->build_object(
        { class => 'Koha::Libraries', value => { branchname => 'TEST_A' } } );
    my $library_z = $builder->build_object(
        { class => 'Koha::Libraries', value => { branchname => 'TEST_Z' } } );
    my $biblio = $builder->build_sample_biblio( { serial => 0 } );
    my $item1 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });
    my $item2 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });
    my $item3 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });

    { # Is not a serial

        # order_by homebranch.branchname
        $item1->discard_changes->update( { homebranch => $library_z->branchcode } );
        $item2->discard_changes->update( { homebranch => $library_a->branchcode } );
        $item3->discard_changes->update( { homebranch => $library_z->branchcode } );
        is_deeply( [ map { $_->itemnumber } $biblio->items->search_ordered->as_list ],
            [ $item2->itemnumber, $item1->itemnumber, $item3->itemnumber ],
            "not a serial - order by homebranch" );

        # order_by me.enumchron
        $biblio->items->update( { homebranch => $library_a->branchcode } );
        $item1->discard_changes->update( { enumchron => 'cc' } );
        $item2->discard_changes->update( { enumchron => 'bb' } );
        $item3->discard_changes->update( { enumchron => 'aa' } );
        is_deeply( [ map { $_->itemnumber } $biblio->items->search_ordered->as_list ],
            [ $item3->itemnumber, $item2->itemnumber, $item1->itemnumber ],
            "not a serial - order by enumchron" );

        # order_by LPAD( me.copynumber, 8, '0' )
        $biblio->items->update( { enumchron => undef } );
        $item1->discard_changes->update( { copynumber => '12345678' } );
        $item2->discard_changes->update( { copynumber => '34567890' } );
        $item3->discard_changes->update( { copynumber => '23456789' } );
        is_deeply( [ map { $_->itemnumber } $biblio->items->search_ordered->as_list ],
            [ $item1->itemnumber, $item3->itemnumber, $item2->itemnumber ],
            "not a serial - order by LPAD( me.copynumber, 8, '0' )" );

        # order_by -desc => 'me.dateaccessioned'
        $biblio->items->update( { copynumber => undef } );
        $item1->discard_changes->update( { dateaccessioned => '2022-08-19' } );
        $item2->discard_changes->update( { dateaccessioned => '2022-07-19' } );
        $item3->discard_changes->update( { dateaccessioned => '2022-09-19' } );
        is_deeply( [ map { $_->itemnumber } $biblio->items->search_ordered->as_list ],
            [ $item3->itemnumber, $item1->itemnumber, $item2->itemnumber ],
            "not a serial - order by date accessioned desc" );
    }

    {    # Is a serial

        my $sub_freq = $builder->build( { source => 'SubscriptionFrequency' } );
        my $sub_np =
          $builder->build( { source => 'SubscriptionNumberpattern' } );
        my $subscription = $builder->build_object(
            {
                class => 'Koha::Subscriptions',
                value => {
                    biblionumber  => $biblio->biblionumber,
                    periodicity   => $sub_freq->{id},
                    numberpattern => $sub_np->{id},
                    published_on_template => "[% publisheddatetext %] [% biblionumber %]",
                }
            }
        );
        $builder->build_object(
            {
                class => 'Koha::Subscription::Histories',
                value => {
                    subscriptionid => $subscription->subscriptionid,
                    biblionumber   => $biblio->biblionumber
                }
            }
        );

        $biblio->update( { serial => 1 } );
        my $serialid1 =
          C4::Serials::NewIssue( "serialseq", $subscription->subscriptionid,
            $biblio->biblionumber, 1, undef, undef, "publisheddatetext",
            "notes", "routingnotes" );
        C4::Serials::AddItem2Serial( $serialid1, $item1->itemnumber );
        my $serialid2 =
          C4::Serials::NewIssue( "serialseq", $subscription->subscriptionid,
            $biblio->biblionumber, 1, undef, undef, "publisheddatetext",
            "notes", "routingnotes" );
        C4::Serials::AddItem2Serial( $serialid2, $item2->itemnumber );
        my $serialid3 =
          C4::Serials::NewIssue( "serialseq", $subscription->subscriptionid,
            $biblio->biblionumber, 1, undef, undef, "publisheddatetext",
            "notes", "routingnotes" );
        C4::Serials::AddItem2Serial( $serialid3, $item3->itemnumber );
        my $serial1 = Koha::Serials->find($serialid1);
        my $serial2 = Koha::Serials->find($serialid2);
        my $serial3 = Koha::Serials->find($serialid3);

        # order_by serial.publisheddate
        $serial1->discard_changes->update( { publisheddate => '2022-09-19' } );
        $serial2->discard_changes->update( { publisheddate => '2022-07-19' } );
        $serial3->discard_changes->update( { publisheddate => '2022-08-19' } );
        is_deeply(
            [ map { $_->itemnumber } $biblio->items->search_ordered->as_list ],
            [ $item2->itemnumber, $item3->itemnumber, $item1->itemnumber ],
            "serial - order by publisheddate"
        );

        # order_by me.enumchron
        $serial1->discard_changes->update({ publisheddate => '2022-08-19' });
        $serial2->discard_changes->update({ publisheddate => '2022-08-19' });
        $serial3->discard_changes->update({ publisheddate => '2022-08-19' });
        $item1->discard_changes->update( { enumchron => 'cc' } );
        $item2->discard_changes->update( { enumchron => 'bb' } );
        $item3->discard_changes->update( { enumchron => 'aa' } );
        is_deeply( [ map { $_->itemnumber } $biblio->items->search_ordered->as_list ],
            [ $item3->itemnumber, $item2->itemnumber, $item1->itemnumber ],
            "serial - order by enumchron" );

        is( $serial1->publisheddatetext, "publisheddatetext " . $biblio->biblionumber, "Column publisheddatetext rendered correctly from template for serial1" );
        is( $serial2->publisheddatetext, "publisheddatetext " . $biblio->biblionumber, "Column publisheddatetext rendered correctly from template for serial2" );
        is( $serial3->publisheddatetext, "publisheddatetext " . $biblio->biblionumber, "Column publisheddatetext rendered correctly from template for serial3" );

    }

    $schema->storage->txn_rollback;

};

subtest 'filter_by_for_hold' => sub {

    plan tests => 13;

    $schema->storage->txn_begin;

    my $biblio  = $builder->build_sample_biblio;
    my $library = $builder->build_object({ class => 'Koha::Libraries' });

    t::lib::Mocks::mock_preference('IndependentBranches', 0); # more robust tests

    is( $biblio->items->filter_by_for_hold->count, 0, 'no item yet' );
    $builder->build_sample_item( { biblionumber => $biblio->biblionumber, notforloan => 1 } );
    is( $biblio->items->filter_by_for_hold->count, 0, 'no item for hold' );
    $builder->build_sample_item( { biblionumber => $biblio->biblionumber, notforloan => 0 } );
    is( $biblio->items->filter_by_for_hold->count, 1, '1 item for hold' );
    $builder->build_sample_item( { biblionumber => $biblio->biblionumber, notforloan => -1 } );
    is( $biblio->items->filter_by_for_hold->count, 2, '2 items for hold' );

    $builder->build_sample_item( { biblionumber => $biblio->biblionumber, itemlost => 0, library => $library->id } );
    $builder->build_sample_item( { biblionumber => $biblio->biblionumber, itemlost => 1, library => $library->id } );
    is( $biblio->items->filter_by_for_hold->count, 3, '3 items for hold - itemlost' );

    $builder->build_sample_item( { biblionumber => $biblio->biblionumber, withdrawn => 0, library => $library->id } );
    $builder->build_sample_item( { biblionumber => $biblio->biblionumber, withdrawn => 1, library => $library->id } );
    is( $biblio->items->filter_by_for_hold->count, 4, '4 items for hold - withdrawn' );

    $builder->build_sample_item( { biblionumber => $biblio->biblionumber, damaged => 0 } );
    $builder->build_sample_item( { biblionumber => $biblio->biblionumber, damaged => 1 } );
    t::lib::Mocks::mock_preference('AllowHoldsOnDamagedItems', 0);
    is( $biblio->items->filter_by_for_hold->count, 5, '5 items for hold - not damaged if not AllowHoldsOnDamagedItems' );
    t::lib::Mocks::mock_preference('AllowHoldsOnDamagedItems', 1);
    is( $biblio->items->filter_by_for_hold->count, 6, '6 items for hold - damaged if AllowHoldsOnDamagedItems' );

    my $itemtype = $builder->build_object({ class => 'Koha::ItemTypes' });
    my $not_holdable_itemtype = $itemtype->itemtype;
    $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itype        => $not_holdable_itemtype,
        }
    );
    Koha::CirculationRules->set_rule(
        {
            branchcode   => undef,
            itemtype     => $not_holdable_itemtype,
            rule_name    => 'holdallowed',
            rule_value   => 'not_allowed',
        }
    );
    is( $biblio->items->filter_by_for_hold->count, 6, '6 items for hold - holdallowed=not_allowed' );

    # Remove rule, test notforloan on itemtype
    Koha::CirculationRules->set_rule(
        {
            branchcode   => undef,
            itemtype     => $not_holdable_itemtype,
            rule_name    => 'holdallowed',
            rule_value   => undef,
        }
    );
    is( $biblio->items->filter_by_for_hold->count, 7, '7 items for hold - rule deleted' );
    $itemtype->notforloan(1)->store;
    is( $biblio->items->filter_by_for_hold->count, 6, '6 items for hold - notforloan' );

    {
        my $mock_context = Test::MockModule->new('C4::Context');
        $mock_context->mock( 'only_my_library', 1 );
        $mock_context->mock( 'mybranch',        $library->id );
        is( $biblio->items->filter_by_for_hold->count, 2, '2 items for hold, filtered by IndependentBranches' );
    }

    t::lib::Mocks::mock_preference('item-level_itypes', 0);
    $biblio->biblioitem->itemtype($not_holdable_itemtype)->store;
    is( $biblio->items->filter_by_for_hold->count, 0, '0 item-level_itypes=0' );

    t::lib::Mocks::mock_preference('item-level_itypes', 1);

    $schema->storage->txn_rollback;
};
