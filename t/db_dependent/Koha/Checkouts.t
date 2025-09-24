#!/usr/bin/perl

# Copyright 2015 Koha Development team
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
use Test::More tests => 13;
use Test::MockModule;
use Test::Warn;

use C4::Circulation qw( MarkIssueReturned AddReturn );
use C4::Reserves    qw( AddReserve );
use Koha::Checkouts;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Holds;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder         = t::lib::TestBuilder->new;
my $library         = $builder->build( { source => 'Branch' } );
my $patron          = $builder->build( { source => 'Borrower', value => { branchcode => $library->{branchcode} } } );
my $item_1          = $builder->build_sample_item;
my $item_2          = $builder->build_sample_item;
my $nb_of_checkouts = Koha::Checkouts->search->count;
my $new_checkout_1  = Koha::Checkout->new(
    {
        borrowernumber => $patron->{borrowernumber},
        itemnumber     => $item_1->itemnumber,
        branchcode     => $library->{branchcode},
    }
)->store;
my $new_checkout_2 = Koha::Checkout->new(
    {
        borrowernumber => $patron->{borrowernumber},
        itemnumber     => $item_2->itemnumber,
        branchcode     => $library->{branchcode},
    }
)->store;

like(
    $new_checkout_1->issue_id, qr|^\d+$|,
    'Adding a new checkout should have set the issue_id'
);
is(
    Koha::Checkouts->search->count,
    $nb_of_checkouts + 2,
    'The 2 checkouts should have been added'
);

my $retrieved_checkout_1 = Koha::Checkouts->find( $new_checkout_1->issue_id );
is(
    $retrieved_checkout_1->itemnumber,
    $new_checkout_1->itemnumber,
    'Find a checkout by id should return the correct checkout'
);

subtest 'is_overdue' => sub {
    plan tests => 6;
    my $ten_days_ago   = dt_from_string->add( days => -10 );
    my $ten_days_later = dt_from_string->add( days => 10 );
    my $yesterday      = dt_from_string->add( days => -1 );
    my $tomorrow       = dt_from_string->add( days => 1 );

    $retrieved_checkout_1->date_due($ten_days_ago)->store;
    is(
        $retrieved_checkout_1->is_overdue,
        1, 'The item should have been returned 10 days ago'
    );

    $retrieved_checkout_1->date_due($ten_days_later)->store;
    is( $retrieved_checkout_1->is_overdue, 0, 'The item is due in 10 days' );

    $retrieved_checkout_1->date_due($tomorrow)->store;
    is(
        $retrieved_checkout_1->is_overdue($ten_days_later),
        1, 'The item should have been returned yesterday'
    );

    $retrieved_checkout_1->date_due($yesterday)->store;
    is(
        $retrieved_checkout_1->is_overdue($ten_days_ago),
        0, 'Ten days ago the item due yesterday was not late'
    );

    $retrieved_checkout_1->date_due($tomorrow)->store;
    is(
        $retrieved_checkout_1->is_overdue($ten_days_later),
        1, 'In Ten days, the item due tomorrow will be late'
    );

    $retrieved_checkout_1->date_due($yesterday)->store;
    is(
        $retrieved_checkout_1->is_overdue($ten_days_ago),
        0, 'In Ten days, the item due yesterday will still be late'
    );
};

subtest 'item' => sub {
    plan tests => 2;
    my $item = $retrieved_checkout_1->item;
    is(
        ref($item), 'Koha::Item',
        'Koha::Checkout->item should return a Koha::Item'
    );
    is(
        $item->itemnumber, $item_1->itemnumber,
        'Koha::Checkout->item should return the correct item'
    );
};

subtest 'account_lines' => sub {
    plan tests => 3;

    my $accountline = Koha::Account::Line->new(
        {
            issue_id          => $retrieved_checkout_1->id,
            borrowernumber    => $retrieved_checkout_1->borrowernumber,
            itemnumber        => $retrieved_checkout_1->itemnumber,
            branchcode        => $retrieved_checkout_1->branchcode,
            date              => \'NOW()',
            debit_type_code   => 'OVERDUE',
            status            => 'UNRETURNED',
            interface         => 'cli',
            amount            => '1',
            amountoutstanding => '1',
        }
    )->store();

    my $account_lines = $retrieved_checkout_1->account_lines;
    is(
        ref($account_lines), 'Koha::Account::Lines',
        'Koha::Checkout->account_lines should return a Koha::Account::Lines'
    );

    my $line = $account_lines->next;
    is(
        ref($line), 'Koha::Account::Line',
        'next returns a Koha::Account::Line'
    );

    is(
        $accountline->id,
        $line->id,
        'Koha::Checkout->account_lines should return the correct account_lines'
    );
};

subtest 'patron' => sub {
    plan tests => 3;
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->{branchcode} }
        }
    );

    my $item     = $builder->build_sample_item;
    my $checkout = Koha::Checkout->new(
        {
            borrowernumber => $patron->borrowernumber,
            itemnumber     => $item->itemnumber,
            branchcode     => $library->{branchcode},
        }
    )->store;

    t::lib::Mocks::mock_userenv( { branchcode => $library->{branchcode} } );

    my $p = $checkout->patron;
    is(
        ref($p), 'Koha::Patron',
        'Koha::Checkout->patron should return a Koha::Patron'
    );
    is(
        $p->borrowernumber, $patron->borrowernumber,
        'Koha::Checkout->patron should return the correct patron'
    );

    # Testing Koha::Old::Checkout->patron now
    my $issue_id = $checkout->issue_id;
    C4::Circulation::MarkIssueReturned(
        $p->borrowernumber,
        $checkout->itemnumber
    );
    $p->delete;
    my $old_issue = Koha::Old::Checkouts->find($issue_id);
    is(
        $old_issue->patron, undef,
        'Koha::Checkout->patron should return undef if the patron record has been deleted'
    );
};

$retrieved_checkout_1->delete;
is(
    Koha::Checkouts->search->count,
    $nb_of_checkouts + 1,
    'Delete should have deleted the checkout'
);

subtest 'issuer' => sub {
    plan tests => 3;
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->{branchcode} }
        }
    );
    my $issuer = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->{branchcode} }
        }
    );

    my $item     = $builder->build_sample_item;
    my $checkout = Koha::Checkout->new(
        {
            borrowernumber => $patron->borrowernumber,
            issuer_id      => $issuer->borrowernumber,
            itemnumber     => $item->itemnumber,
            branchcode     => $library->{branchcode},
        }
    )->store;

    my $i = $checkout->issuer;
    is(
        ref($i), 'Koha::Patron',
        'Koha::Checkout->issuer should return a Koha::Patron'
    );
    is(
        $i->borrowernumber, $issuer->borrowernumber,
        'Koha::Checkout->issuer should return the correct patron'
    );

    # Testing Koha::Old::Checkout->patron now
    my $issue_id = $checkout->issue_id;
    C4::Circulation::MarkIssueReturned(
        $patron->borrowernumber,
        $checkout->itemnumber
    );
    $i->delete;
    my $old_issue = Koha::Old::Checkouts->find($issue_id);
    is(
        $old_issue->issuer_id, undef,
        'Koha::Checkout->issuer_id should return undef if the patron record has been deleted'
    );

};

subtest 'Koha::Old::Checkouts->filter_by_todays_checkins' => sub {

    plan tests => 3;

    # We will create 7 checkins for a given patron
    # 3 checked in today - 2 days, and 4 checked in today
    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->{branchcode} }
        }
    );
    t::lib::Mocks::mock_userenv( { patron => $librarian } );
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->{branchcode} }
        }
    );

    my @checkouts;

    # Create 7 checkouts
    for ( 0 .. 6 ) {
        my $item = $builder->build_sample_item;
        push @checkouts,
            Koha::Checkout->new(
            {
                borrowernumber => $patron->borrowernumber,
                itemnumber     => $item->itemnumber,
                branchcode     => $library->{branchcode},
            }
        )->store;
    }

    # Checkin 3 today - 2 days
    my $not_today = dt_from_string->add( days => -2 );
    for my $i ( 0 .. 2 ) {
        my $checkout = $checkouts[$i];
        C4::Circulation::AddReturn(
            $checkout->item->barcode, $library->{branchcode},
            undef,                    $not_today->set_hour( int( rand(24) ) )
        );
    }

    # Checkin 4 today
    my $today = dt_from_string;
    for my $i ( 3 .. 6 ) {
        my $checkout = $checkouts[$i];
        C4::Circulation::AddReturn(
            $checkout->item->barcode, $library->{branchcode},
            undef,                    $today->set_hour( int( rand(24) ) )
        );
    }

    my $old_checkouts = $patron->old_checkouts;
    is( $old_checkouts->count, 7, 'There should be 7 old checkouts' );
    my $todays_checkins = $old_checkouts->filter_by_todays_checkins;
    is( $todays_checkins->count, 4, 'There should be 4 checkins today' );
    is_deeply(
        [ $todays_checkins->get_column('itemnumber') ],
        [ map { $_->itemnumber } @checkouts[ 3 .. 6 ] ],
        q{Correct list of today's checkins}
    );
};

$schema->storage->txn_rollback;

subtest 'automatic_checkin' => sub {

    plan tests => 10;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    my $due_ac_item  = $builder->build_sample_item( { homebranch => $patron->branchcode, itemlost => 0 } );
    my $ac_item      = $builder->build_sample_item( { homebranch => $patron->branchcode, itemlost => 0 } );
    my $odue_ac_item = $builder->build_sample_item( { homebranch => $patron->branchcode, itemlost => 0 } );
    my $normal_item  = $builder->build_sample_item( { homebranch => $patron->branchcode, itemlost => 0 } );

    $due_ac_item->itemtype->automatic_checkin(1)->store;
    $odue_ac_item->itemtype->automatic_checkin(1)->store;
    $ac_item->itemtype->automatic_checkin(1)->store;
    $normal_item->itemtype->automatic_checkin(0)->store;

    my $today     = dt_from_string;
    my $tomorrow  = dt_from_string->add( days => 1 );
    my $yesterday = dt_from_string->subtract( days => 1 );

    # Checkout due for automatic checkin
    my $checkout_due_aci = Koha::Checkout->new(
        {
            borrowernumber => $patron->borrowernumber,
            itemnumber     => $due_ac_item->itemnumber,
            branchcode     => $patron->branchcode,
            date_due       => $today,
        }
    )->store;

    # Checkout not due for automatic checkin
    my $checkout_odue_aci = Koha::Checkout->new(
        {
            borrowernumber => $patron->borrowernumber,
            itemnumber     => $odue_ac_item->itemnumber,
            branchcode     => $patron->branchcode,
            date_due       => $yesterday
        }
    )->store;

    # Checkout not due for automatic checkin
    my $checkout_aci = Koha::Checkout->new(
        {
            borrowernumber => $patron->borrowernumber,
            itemnumber     => $ac_item->itemnumber,
            branchcode     => $patron->branchcode,
            date_due       => $tomorrow
        }
    )->store;

    # due checkout for nomal itemtype
    my $checkout_ni = Koha::Checkout->new(
        {
            borrowernumber => $patron->borrowernumber,
            itemnumber     => $normal_item->itemnumber,
            branchcode     => $patron->branchcode,
            date_due       => $today,
        }
    )->store;

    my $searched = Koha::Checkouts->find( $checkout_ni->issue_id );
    is(
        $searched->issue_id, $checkout_ni->issue_id,
        'checkout for normal_item exists'
    );

    $searched = Koha::Checkouts->find( $checkout_aci->issue_id );
    is(
        $searched->issue_id, $checkout_aci->issue_id,
        'checkout for ac_item exists'
    );

    $searched = Koha::Checkouts->find( $checkout_due_aci->issue_id );
    is(
        $searched->issue_id,
        $checkout_due_aci->issue_id,
        'checkout for due_ac_item exists'
    );

    $searched = Koha::Checkouts->find( $checkout_odue_aci->issue_id );
    is(
        $searched->issue_id,
        $checkout_odue_aci->issue_id,
        'checkout for odue_ac_item exists'
    );

    Koha::Checkouts->automatic_checkin;

    $searched = Koha::Checkouts->find( $checkout_ni->issue_id );
    is(
        $searched->issue_id, $checkout_ni->issue_id,
        'checkout for normal_item still exists'
    );

    $searched = Koha::Checkouts->find( $checkout_aci->issue_id );
    is(
        $searched->issue_id, $checkout_aci->issue_id,
        'checkout for ac_item still exists'
    );

    $searched = Koha::Checkouts->find( $checkout_due_aci->issue_id );
    is( $searched, undef, 'checkout for due_ac_item doesn\'t exist anymore' );

    $searched = Koha::Checkouts->find( $checkout_odue_aci->issue_id );
    is( $searched, undef, 'checkout for odue_ac_item doesn\'t exist anymore' );

    $searched = Koha::Old::Checkouts->find( $checkout_odue_aci->issue_id );
    is(
        dt_from_string( $searched->returndate ), $yesterday,
        'old checkout for odue_ac_item has the right return date'
    );

    subtest 'automatic_checkin AutomaticCheckinAutoFill tests' => sub {

        plan tests => 3;

        my $checkout_2_due_ac = Koha::Checkout->new(
            {
                borrowernumber => $patron->borrowernumber,
                itemnumber     => $due_ac_item->itemnumber,
                branchcode     => $patron->branchcode,
                date_due       => $today
            }
        )->store;

        my $patron_2 =
            $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $patron->branchcode } } );
        my $reserveid = AddReserve(
            {
                branchcode     => $patron->branchcode,
                borrowernumber => $patron_2->id,
                biblionumber   => $due_ac_item->biblionumber,
                priority       => 1
            }
        );

        t::lib::Mocks::mock_preference( 'AutomaticCheckinAutoFill', '0' );

        Koha::Checkouts->automatic_checkin;
        my $reserve = Koha::Holds->find($reserveid);

        is( $reserve->found, undef, "Hold was not filled when AutomaticCheckinAutoFill disabled" );

        my $checkout_3_due_ac = Koha::Checkout->new(
            {
                borrowernumber => $patron->borrowernumber,
                itemnumber     => $due_ac_item->itemnumber,
                branchcode     => $patron->branchcode,
                date_due       => $today
            }
        )->store;
        t::lib::Mocks::mock_preference( 'AutomaticCheckinAutoFill', '1' );

        Koha::Checkouts->automatic_checkin;
        $reserve->discard_changes;

        is( $reserve->found, 'W', "Hold was filled when AutomaticCheckinAutoFill enabled" );

        my $checkout_2_odue_ac = Koha::Checkout->new(
            {
                borrowernumber => $patron->borrowernumber,
                itemnumber     => $odue_ac_item->itemnumber,
                branchcode     => $patron->branchcode,
                date_due       => $today
            }
        )->store;
        my $branch2    = $builder->build_object( { class => "Koha::Libraries" } );
        my $reserve2id = AddReserve(
            {
                branchcode     => $branch2->branchcode,
                borrowernumber => $patron_2->id,
                biblionumber   => $odue_ac_item->biblionumber,
                priority       => 1
            }
        );
        Koha::Checkouts->automatic_checkin;

        my $reserve2 = Koha::Holds->find($reserve2id);
        is(
            $reserve2->found, 'T',
            "Hold was filled when AutomaticCheckinAutoFill enabled and transfer was initiated when branches didn't match"
        );
    };

    $schema->storage->txn_rollback;
};

subtest 'attempt_auto_renew' => sub {

    plan tests => 33;

    $schema->storage->txn_begin;

    my $renew_error = 'auto_renew';
    my $module      = Test::MockModule->new('C4::Circulation');
    $module->mock( 'CanBookBeRenewed', sub { return ( 1, $renew_error ) } );
    $module->mock( 'AddRenewal',       sub { warn "AddRenewal called" } );
    my $checkout = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => {
                date_due         => '2023-01-01 23:59:59',
                returndate       => undef,
                auto_renew       => 1,
                auto_renew_error => undef,
                onsite_checkout  => 0,
                renewals_count   => 0,
            }
        }
    );

    my ( $success, $error, $updated );
    warning_is {
        ( $success, $error, $updated ) = $checkout->attempt_auto_renew();
    }
    undef, "AddRenewal not called without confirm";
    ok( $success, "Issue is renewed when error is 'auto_renew'" );
    is( $error, undef, "No error when renewed" );
    ok( $updated, "Issue reported as updated when renewed" );

    warning_is {
        ( $success, $error, $updated ) = $checkout->attempt_auto_renew( { confirm => 1 } );
    }
    "AddRenewal called", "AddRenewal called when confirm is passed";
    ok( $success, "Issue is renewed when error is 'auto_renew'" );
    is( $error, undef, "No error when renewed" );
    ok( $updated, "Issue reported as updated when renewed" );

    $module->mock( 'AddRenewal', sub { return; } );

    $renew_error = 'anything_else';
    ( $success, $error, $updated ) = $checkout->attempt_auto_renew();
    ok( !$success, "Success is untrue for any other status" );
    is( $error, 'anything_else', "The error is passed through" );
    ok( $updated, "Issue reported as updated when status changes" );
    $checkout->discard_changes();
    is( $checkout->auto_renew_error, undef, "Error not updated if confirm not passed" );

    ( $success, $error, $updated ) = $checkout->attempt_auto_renew( { confirm => 1 } );
    ok( !$success, "Success is untrue for any other status" );
    is( $error, 'anything_else', "The error is passed through" );
    ok( $updated, "Issue updated when confirm passed" );
    $checkout->discard_changes();
    is( $checkout->auto_renew_error, 'anything_else', "Error updated if confirm passed" );

    # Error now equals 'anything_else'
    ( $success, $error, $updated ) = $checkout->attempt_auto_renew();
    ok( !$updated, "Issue not reported as updated when status has not changed" );

    $renew_error = "auto_unseen_final";
    ( $success, $error, $updated ) = $checkout->attempt_auto_renew( { confirm => 1 } );
    ok( $success, "Issue is renewed when error is 'auto_unseen_final'" );
    is( $error, 'auto_unseen_final', "Error of finality reported when renewed" );
    ok( $updated, "Issue reported as updated when renewed" );
    $checkout->discard_changes();
    is( $checkout->auto_renew_error, 'auto_unseen_final', "Error updated" );

    $renew_error = "too_unseen";
    ( $success, $error, $updated ) = $checkout->attempt_auto_renew( { confirm => 1 } );
    ok( !$success, "Issue is not renewed when error is 'too_unseen'" );
    is( $error, 'too_unseen', "Error reported correctly" );
    ok( !$updated, "Issue not reported as updated when moved from final to too unseen" );
    $checkout->discard_changes();
    is( $checkout->auto_renew_error, 'too_unseen', "Error updated" );

    $renew_error = "auto_renew_final";
    ( $success, $error, $updated ) = $checkout->attempt_auto_renew( { confirm => 1 } );
    ok( $success, "Issue is renewed when error is 'auto_renew_final'" );
    is( $error, 'auto_renew_final', "Error of finality reported when renewed" );
    ok( $updated, "Issue reported as updated when renewed" );
    $checkout->discard_changes();
    is( $checkout->auto_renew_error, 'auto_renew_final', "Error updated" );

    $renew_error = "too_many";
    ( $success, $error, $updated ) = $checkout->attempt_auto_renew( { confirm => 1 } );
    ok( !$success, "Issue is not renewed when error is 'too_many'" );
    is( $error, 'too_many', "Error reported correctly" );
    ok( !$updated, "Issue not reported as updated when moved from final to too many" );
    $checkout->discard_changes();
    is( $checkout->auto_renew_error, 'too_many', "Error updated" );

    $schema->storage->txn_rollback;
};
