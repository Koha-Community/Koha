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
use Test::More tests => 13;
use Test::Warn;

use C4::Circulation qw( AddIssue );
use C4::Reserves    qw( AddReserve CheckReserves ModReserve ModReserveCancelAll );
use Koha::AuthorisedValueCategory;
use Koha::Biblio::ItemGroups;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Holds;
use Koha::Old::Holds;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

subtest 'DB constraints' => sub {
    plan tests => 1;

    my $patron    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item      = $builder->build_sample_item;
    my $hold_info = {
        branchcode     => $patron->branchcode,
        borrowernumber => $patron->borrowernumber,
        biblionumber   => $item->biblionumber,
        priority       => 1,
        title          => "title for fee",
        itemnumber     => $item->itemnumber,
    };

    my $reserve_id = C4::Reserves::AddReserve($hold_info);
    my $hold       = Koha::Holds->find($reserve_id);

    warning_like {
        eval { $hold->priority(undef)->store }
    }
    qr{.*DBD::mysql::st execute failed: Column 'priority' cannot be null.*},
        'DBD should have raised an error about priority that cannot be null';
};

subtest 'cancel' => sub {
    plan tests => 12;
    my $biblioitem = $builder->build_object( { class => 'Koha::Biblioitems' } );
    my $library    = $builder->build_object( { class => 'Koha::Libraries' } );
    my $itemtype   = $builder->build_object( { class => 'Koha::ItemTypes', value => { rentalcharge => 0 } } );
    my $item_info  = {
        biblionumber     => $biblioitem->biblionumber,
        biblioitemnumber => $biblioitem->biblioitemnumber,
        homebranch       => $library->branchcode,
        holdingbranch    => $library->branchcode,
        itype            => $itemtype->itemtype,
    };
    my $item    = $builder->build_object( { class => 'Koha::Items', value => $item_info } );
    my $manager = $builder->build_object( { class => "Koha::Patrons" } );
    t::lib::Mocks::mock_userenv( { patron => $manager, branchcode => $manager->branchcode } );

    my ( @patrons, @holds );
    for my $i ( 0 .. 2 ) {
        my $priority = $i + 1;
        my $patron   = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { branchcode => $library->branchcode, }
            }
        );
        my $reserve_id = C4::Reserves::AddReserve(
            {
                branchcode     => $library->branchcode,
                borrowernumber => $patron->borrowernumber,
                biblionumber   => $item->biblionumber,
                priority       => $priority,
                title          => "title for fee",
                itemnumber     => $item->itemnumber,
            }
        );
        my $hold = Koha::Holds->find($reserve_id);
        push @patrons, $patron;
        push @holds,   $hold;
    }

    # There are 3 holds on this records
    my $nb_of_holds = Koha::Holds->search( { biblionumber => $item->biblionumber } )->count;
    is(
        $nb_of_holds, 3,
        'There should have 3 holds placed on this biblio record'
    );
    my $first_hold  = $holds[0];
    my $second_hold = $holds[1];
    my $third_hold  = $holds[2];
    is(
        ref($second_hold), 'Koha::Hold',
        'We should play with Koha::Hold objects'
    );
    is(
        $second_hold->priority, 2,
        'Second hold should have a priority set to 3'
    );

    # Remove the second hold, only 2 should still exist in DB and priorities must have been updated
    my $is_cancelled = $second_hold->cancel;
    is(
        ref($is_cancelled), 'Koha::Hold',
        'Koha::Hold->cancel should return the Koha::Hold (?)'
    );    # This is can reconsidered
    is(
        $second_hold->in_storage, 0,
        'The hold has been cancelled and does not longer exist in DB'
    );
    $nb_of_holds = Koha::Holds->search( { biblionumber => $item->biblionumber } )->count;
    is(
        $nb_of_holds, 2,
        'a hold has been cancelled, there should have only 2 holds placed on this biblio record'
    );

    # discard_changes to refetch
    is( $first_hold->discard_changes->priority, 1, 'First hold should still be first' );
    is( $third_hold->discard_changes->priority, 2, 'Third hold should now be second' );

    subtest 'charge_cancel_fee parameter' => sub {
        plan tests => 18;
        my $library1 = $builder->build_object( { class => 'Koha::Libraries' } );
        my $library2 = $builder->build_object( { class => 'Koha::Libraries' } );
        my $library3 = $builder->build_object( { class => 'Koha::Libraries' } );

        my $bib_title = "Test Title";

        my $borrower =
            $builder->build_object( { class => "Koha::Patrons", value => { branchcode => $library1->branchcode } } );

        my $itemtype1 = $builder->build_object( { class => 'Koha::ItemTypes', value => {} } );
        my $itemtype2 = $builder->build_object( { class => 'Koha::ItemTypes', value => {} } );
        my $itemtype3 = $builder->build_object( { class => 'Koha::ItemTypes', value => {} } );
        my $itemtype4 = $builder->build_object( { class => 'Koha::ItemTypes', value => {} } );

        my $borrowernumber = $borrower->borrowernumber;

        my $library_A_code = $library1->branchcode;

        my $biblio       = $builder->build_sample_biblio( { itemtype => $itemtype1->itemtype } );
        my $biblionumber = $biblio->biblionumber;
        my $item1        = $builder->build_sample_item(
            {
                biblionumber  => $biblionumber,
                itype         => $itemtype1->itemtype,
                homebranch    => $library_A_code,
                holdingbranch => $library_A_code
            }
        );
        my $item2 = $builder->build_sample_item(
            {
                biblionumber  => $biblionumber,
                itype         => $itemtype2->itemtype,
                homebranch    => $library_A_code,
                holdingbranch => $library_A_code
            }
        );
        my $item3 = $builder->build_sample_item(
            {
                biblionumber  => $biblionumber,
                itype         => $itemtype3->itemtype,
                homebranch    => $library_A_code,
                holdingbranch => $library_A_code
            }
        );

        my $library_B_code = $library2->branchcode;

        my $biblio2       = $builder->build_sample_biblio( { itemtype => $itemtype4->itemtype } );
        my $biblionumber2 = $biblio2->biblionumber;
        my $item4         = $builder->build_sample_item(
            {
                biblionumber  => $biblionumber2,
                itype         => $itemtype4->itemtype,
                homebranch    => $library_B_code,
                holdingbranch => $library_B_code
            }
        );

        my $library_C_code = $library3->branchcode;

        my $biblio3       = $builder->build_sample_biblio( { itemtype => $itemtype4->itemtype } );
        my $biblionumber3 = $biblio3->biblionumber;
        my $item5         = $builder->build_sample_item(
            {
                biblionumber  => $biblionumber3,
                itype         => $itemtype4->itemtype,
                homebranch    => $library_C_code,
                holdingbranch => $library_C_code
            }
        );

        Koha::CirculationRules->set_rules(
            {
                itemtype     => undef,
                categorycode => undef,
                branchcode   => undef,
                rules        => { expire_reserves_charge => undef }
            }
        );
        Koha::CirculationRules->set_rules(
            {
                itemtype     => $itemtype1->itemtype,
                categorycode => undef,
                branchcode   => undef,
                rules        => { expire_reserves_charge => '111' }
            }
        );
        Koha::CirculationRules->set_rules(
            {
                itemtype     => $itemtype2->itemtype,
                categorycode => undef,
                branchcode   => undef,
                rules        => { expire_reserves_charge => undef }
            }
        );
        Koha::CirculationRules->set_rules(
            {
                itemtype     => undef,
                categorycode => undef,
                branchcode   => $library_B_code,
                rules        => { expire_reserves_charge => '444' }
            }
        );
        Koha::CirculationRules->set_rules(
            {
                itemtype     => undef,
                categorycode => undef,
                branchcode   => $library_C_code,
                rules        => { expire_reserves_charge => '0' }
            }
        );

        t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'ItemHomeLibrary' );

        my $reserve_id;
        my $account;
        my $status;
        my $start_balance;

        # TEST: Hold itemtype1 item
        $reserve_id = AddReserve(
            {
                branchcode     => $library_A_code,
                borrowernumber => $borrowernumber,
                biblionumber   => $biblionumber,
                priority       => 1,
                itemnumber     => $item1->itemnumber,
            }
        );

        $account = Koha::Account->new( { patron_id => $borrowernumber } );

        ($status) = CheckReserves($item1);
        is( $status, 'Reserved', "Hold for the itemtype1 created" );

        $start_balance = $account->balance();

        Koha::Holds->find($reserve_id)->cancel( { charge_cancel_fee => 1 } );

        ($status) = CheckReserves($item1);
        is( $status, '', "Hold for the itemtype1 cancelled" );

        is( $account->balance() - $start_balance, 111, "Used circulation rule for itemtype1" );

        # TEST: circulation rule for itemtype2 has 'expire_reserves_charge' set undef, so it should use ExpireReservesMaxPickUpDelayCharge preference
        t::lib::Mocks::mock_preference( 'ExpireReservesMaxPickUpDelayCharge', 222 );

        $reserve_id = AddReserve(
            {
                branchcode     => $library_A_code,
                borrowernumber => $borrowernumber,
                biblionumber   => $biblionumber,
                priority       => 1,
                itemnumber     => $item2->itemnumber,
            }
        );

        $account = Koha::Account->new( { patron_id => $borrowernumber } );

        ($status) = CheckReserves($item2);
        is( $status, 'Reserved', "Hold for the itemtype2 created" );

        $start_balance = $account->balance();

        Koha::Holds->find($reserve_id)->cancel( { charge_cancel_fee => 1 } );

        ($status) = CheckReserves($item2);
        is( $status, '', "Hold for the itemtype2 cancelled" );

        is(
            $account->balance() - $start_balance, 222,
            "Used ExpireReservesMaxPickUpDelayCharge preference as expire_reserves_charge set to undef"
        );

        # TEST: no circulation rules for itemtype3, it should use ExpireReservesMaxPickUpDelayCharge preference
        t::lib::Mocks::mock_preference( 'ExpireReservesMaxPickUpDelayCharge', 333 );

        $reserve_id = AddReserve(
            {
                branchcode     => $library_A_code,
                borrowernumber => $borrowernumber,
                biblionumber   => $biblionumber,
                priority       => 1,
                itemnumber     => $item3->itemnumber,
            }
        );

        $account = Koha::Account->new( { patron_id => $borrowernumber } );

        ($status) = CheckReserves($item3);
        is( $status, 'Reserved', "Hold for the itemtype3 created" );

        $start_balance = $account->balance();

        Koha::Holds->find($reserve_id)->cancel( { charge_cancel_fee => 1 } );

        ($status) = CheckReserves($item3);
        is( $status, '', "Hold for the itemtype3 cancelled" );

        is(
            $account->balance() - $start_balance, 333,
            "Used ExpireReservesMaxPickUpDelayCharge preference as there's no circulation rules for itemtype3"
        );

        # TEST: circulation rule for itemtype4 with library_B_code
        t::lib::Mocks::mock_preference( 'ExpireReservesMaxPickUpDelayCharge', 555 );

        $reserve_id = AddReserve(
            {
                branchcode     => $library_B_code,
                borrowernumber => $borrowernumber,
                biblionumber   => $biblionumber2,
                priority       => 1,
                itemnumber     => $item4->itemnumber,
            }
        );

        $account = Koha::Account->new( { patron_id => $borrowernumber } );

        ($status) = CheckReserves($item4);
        is( $status, 'Reserved', "Hold for the itemtype4 created" );

        $start_balance = $account->balance();

        Koha::Holds->find($reserve_id)->cancel( { charge_cancel_fee => 1 } );

        ($status) = CheckReserves($item4);
        is( $status, '', "Hold for the itemtype4 cancelled" );

        is( $account->balance() - $start_balance, 444, "Used circulation rule for itemtype4 with library_B_code" );

        # TEST: circulation rule for library_C_code that has expire_reserves_charge = 0
        t::lib::Mocks::mock_preference( 'ExpireReservesMaxPickUpDelayCharge', 777 );

        $reserve_id = AddReserve(
            {
                branchcode     => $library_C_code,
                borrowernumber => $borrowernumber,
                biblionumber   => $biblionumber3,
                priority       => 1,
                itemnumber     => $item5->itemnumber,
            }
        );

        $account = Koha::Account->new( { patron_id => $borrowernumber } );

        ($status) = CheckReserves($item5);
        is( $status, 'Reserved', "Hold for the itemtype5 created" );

        $start_balance = $account->balance();

        Koha::Holds->find($reserve_id)->cancel( { charge_cancel_fee => 1 } );

        ($status) = CheckReserves($item5);
        is( $status, '', "Hold for the itemtype5 cancelled" );

        is(
            $account->balance() - $start_balance, 0,
            "Used circulation rule for itemtype4 with library_C_code even though it's 0"
        );

        # TEST: charge_cancel_fee is 0
        $reserve_id = AddReserve(
            {
                branchcode     => $library_B_code,
                borrowernumber => $borrowernumber,
                biblionumber   => $biblionumber2,
                priority       => 1,
                itemnumber     => $item4->itemnumber,
            }
        );

        $account = Koha::Account->new( { patron_id => $borrowernumber } );

        ($status) = CheckReserves($item4);
        is( $status, 'Reserved', "Hold for the itemtype4 created" );

        $start_balance = $account->balance();

        Koha::Holds->find($reserve_id)->cancel( { charge_cancel_fee => 0 } );

        ($status) = CheckReserves($item4);
        is( $status, '', "Hold for the itemtype4 cancelled" );

        is( $account->balance() - $start_balance, 0, "Patron not charged when charge_cancel_fee is 0" );
    };

    subtest 'waiting hold' => sub {
        plan tests => 1;
        my $patron     = $builder->build_object( { class => 'Koha::Patrons' } );
        my $reserve_id = C4::Reserves::AddReserve(
            {
                branchcode     => $library->branchcode,
                borrowernumber => $patron->borrowernumber,
                biblionumber   => $item->biblionumber,
                priority       => 1,
                title          => "title for fee",
                itemnumber     => $item->itemnumber,
                found          => 'W',
            }
        );
        Koha::Holds->find($reserve_id)->cancel;
        my $hold_old = Koha::Old::Holds->find($reserve_id);
        is( $hold_old->found, 'W', 'The found column should have been kept and a hold is cancelled' );
    };

    subtest 'HoldsLog' => sub {
        plan tests => 2;
        my $patron    = $builder->build_object( { class => 'Koha::Patrons' } );
        my $hold_info = {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblionumber,
            priority       => 1,
            title          => "title for fee",
            itemnumber     => $item->itemnumber,
        };

        t::lib::Mocks::mock_preference( 'HoldsLog', 0 );
        my $reserve_id = C4::Reserves::AddReserve($hold_info);
        Koha::Holds->find($reserve_id)->cancel;
        my $number_of_logs =
            $schema->resultset('ActionLog')->search( { module => 'HOLDS', action => 'CANCEL', object => $reserve_id } )
            ->count;
        is( $number_of_logs, 0, 'Without HoldsLog, Koha::Hold->cancel should not have logged' );

        t::lib::Mocks::mock_preference( 'HoldsLog', 1 );
        $reserve_id = C4::Reserves::AddReserve($hold_info);
        Koha::Holds->find($reserve_id)->cancel;
        $number_of_logs =
            $schema->resultset('ActionLog')->search( { module => 'HOLDS', action => 'CANCEL', object => $reserve_id } )
            ->count;
        is( $number_of_logs, 1, 'With HoldsLog, Koha::Hold->cancel should have logged' );
    };

    subtest 'rollback' => sub {
        plan tests => 3;
        my $patron_category = $builder->build_object(
            {
                class => 'Koha::Patron::Categories',
                value => { reservefee => 0 }
            }
        );
        my $patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { categorycode => $patron_category->categorycode }
            }
        );
        my $hold_info = {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblionumber,
            priority       => 1,
            title          => "title for fee",
            itemnumber     => $item->itemnumber,
        };

        t::lib::Mocks::mock_preference( 'ExpireReservesMaxPickUpDelayCharge', 42 );
        my $reserve_id = C4::Reserves::AddReserve($hold_info);
        my $hold       = Koha::Holds->find($reserve_id);

        # Add a row with the same id to make the cancel fails
        Koha::Old::Hold->new( $hold->unblessed )->store;

        warning_like {
            eval { $hold->cancel( { charge_cancel_fee => 1 } ) };
        }
        qr{.*DBD::mysql::st execute failed: Duplicate entry.*},
            'DBD should have raised an error about dup primary key';

        $hold = Koha::Holds->find($reserve_id);
        is( ref($hold), 'Koha::Hold', 'The hold should not have been deleted' );
        is(
            $patron->account->balance, 0,
            'If the hold has not been cancelled, the patron should not have been charged'
        );
    };

};

subtest 'cancel with reason' => sub {
    plan tests => 7;
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item    = $builder->build_sample_item( { library => $library->branchcode } );
    my $manager = $builder->build_object( { class => "Koha::Patrons" } );
    t::lib::Mocks::mock_userenv( { patron => $manager, branchcode => $manager->branchcode } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode, }
        }
    );

    my $reserve_id = C4::Reserves::AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblionumber,
            priority       => 1,
            itemnumber     => $item->itemnumber,
        }
    );

    my $hold = Koha::Holds->find($reserve_id);

    ok( $reserve_id, "Hold created" );
    ok( $hold,       "Hold found" );

    my $av =
        Koha::AuthorisedValue->new( { category => 'HOLD_CANCELLATION', authorised_value => 'TEST_REASON' } )->store;
    Koha::Notice::Templates->search( { code => 'HOLD_CANCELLATION' } )->delete();
    my $notice = Koha::Notice::Template->new(
        {
            name                   => 'Hold cancellation',
            module                 => 'reserves',
            code                   => 'HOLD_CANCELLATION',
            title                  => 'Hold cancelled',
            content                => 'Your hold was cancelled.',
            message_transport_type => 'email',
            branchcode             => q{},
        }
    )->store();

    $hold->cancel( { cancellation_reason => 'TEST_REASON' } );

    $hold = Koha::Holds->find($reserve_id);
    is( $hold, undef, 'Hold is not in the reserves table' );
    $hold = Koha::Old::Holds->find($reserve_id);
    ok( $hold, 'Hold was found in the old reserves table' );

    my $message = Koha::Notice::Messages->find( { borrowernumber => $patron->id, letter_code => 'HOLD_CANCELLATION' } );
    ok( $message, 'Found hold cancellation message' );
    is( $message->subject, 'Hold cancelled',           'Message has correct title' );
    is( $message->content, 'Your hold was cancelled.', 'Message has correct content' );

    $notice->delete;
    $av->delete;
    $message->delete;
};

subtest 'cancel all with reason' => sub {
    plan tests => 7;
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item    = $builder->build_sample_item( { library => $library->branchcode } );
    my $manager = $builder->build_object( { class => "Koha::Patrons" } );
    t::lib::Mocks::mock_userenv( { patron => $manager, branchcode => $manager->branchcode } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode, }
        }
    );

    my $reserve_id = C4::Reserves::AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblionumber,
            priority       => 1,
            itemnumber     => $item->itemnumber,
        }
    );

    my $hold = Koha::Holds->find($reserve_id);

    ok( $reserve_id, "Hold created" );
    ok( $hold,       "Hold found" );

    my $av =
        Koha::AuthorisedValue->new( { category => 'HOLD_CANCELLATION', authorised_value => 'TEST_REASON' } )->store;
    Koha::Notice::Templates->search( { code => 'HOLD_CANCELLATION' } )->delete();
    my $notice = Koha::Notice::Template->new(
        {
            name                   => 'Hold cancellation',
            module                 => 'reserves',
            code                   => 'HOLD_CANCELLATION',
            title                  => 'Hold cancelled',
            content                => 'Your hold was cancelled.',
            message_transport_type => 'email',
            branchcode             => q{},
        }
    )->store();

    ModReserveCancelAll( $item->id, $patron->id, 'TEST_REASON' );

    $hold = Koha::Holds->find($reserve_id);
    is( $hold, undef, 'Hold is not in the reserves table' );
    $hold = Koha::Old::Holds->find($reserve_id);
    ok( $hold, 'Hold was found in the old reserves table' );

    my $message = Koha::Notice::Messages->find( { borrowernumber => $patron->id, letter_code => 'HOLD_CANCELLATION' } );
    ok( $message, 'Found hold cancellation message' );
    is( $message->subject, 'Hold cancelled',           'Message has correct title' );
    is( $message->content, 'Your hold was cancelled.', 'Message has correct content' );

    $av->delete;
    $message->delete;
};

subtest 'cancel specific hold with ModReserveCancelAll' => sub {
    plan tests => 9;

    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item     = $builder->build_sample_item( { library => $library->branchcode } );
    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode, }
        }
    );

    my $patron2 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library2->branchcode, }
        }
    );

    my $reserve = C4::Reserves::AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblionumber,
            itemnumber     => $item->itemnumber,
            priority       => 0,
            found          => 'W',
        }
    );

    my $reserve2 = C4::Reserves::AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron2->borrowernumber,
            biblionumber   => $item->biblionumber,
        }
    );

    my $hold  = Koha::Holds->find($reserve);
    my $hold2 = Koha::Holds->find($reserve2);

    my $messages;
    my $nextreservinfo;

    # Test case where there is another hold for the same branch
    ( $messages, $nextreservinfo ) = ModReserveCancelAll( $item->itemnumber, $hold->borrowernumber );
    my $old_hold = Koha::Old::Holds->find( $hold->reserve_id );
    $hold = Koha::Holds->find( $hold->reserve_id );

    is( $hold, undef, 'First hold should be removed from reserves table' );
    isnt( $old_hold, undef, 'First hold should be moved to old_reserves table' );
    is( $hold2->priority, 1, 'Next reserve in line should be priority 1' );
    is(
        $nextreservinfo, $hold2->borrowernumber,
        'ModReserveCancelAll should return the borrowernumber for the next hold in line'
    );
    is(
        $messages->{'waiting'}, 1,
        'ModReserveCancelAll should return a waiting message if next hold is for current branch'
    );

    # Test case where there is another hold for a different branch
    $hold2->cancel;
    my $reserve3 = C4::Reserves::AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblionumber,
            itemnumber     => $item->itemnumber,
            priority       => 0,
            found          => 'W',
        }
    );

    my $reserve4 = C4::Reserves::AddReserve(
        {
            branchcode     => $library2->branchcode,
            borrowernumber => $patron2->borrowernumber,
            biblionumber   => $item->biblionumber,
        }
    );

    my $hold3 = Koha::Holds->find($reserve3);
    my $hold4 = Koha::Holds->find($reserve4);

    ( $messages, $nextreservinfo ) = ModReserveCancelAll( $item->itemnumber, $hold3->borrowernumber );
    is(
        $nextreservinfo, $hold4->borrowernumber,
        'ModReserveCancelAll should return the borrowernumber for the next hold in line'
    );
    is(
        $messages->{'transfert'}, $hold4->branchcode,
        'Next hold is for a different branch - ModReserveCancelAll should return its pickup branch in transfer message'
    );

    # Test case where there are no other holds
    $hold4->cancel;
    my $reserve5 = C4::Reserves::AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblionumber,
            itemnumber     => $item->itemnumber,
            priority       => 0,
            found          => 'W',
        }
    );

    my $hold5 = Koha::Holds->find($reserve5);

    ( $messages, $nextreservinfo ) = ModReserveCancelAll( $item->itemnumber, $hold5->borrowernumber );
    is( $nextreservinfo, undef, 'No more holds, nextreservinfo should not be defined' );
    is( $messages,       undef, 'No more holds, messages should not be defined' );
};

subtest 'Desks' => sub {
    plan tests => 5;
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );

    my $desk = Koha::Desk->new(
        {
            desk_name  => 'my_desk_name_for_test',
            branchcode => $library->branchcode,
        }
    )->store;
    ok( $desk, "Desk created" );
    my $item    = $builder->build_sample_item( { library => $library->branchcode } );
    my $manager = $builder->build_object( { class => "Koha::Patrons" } );
    t::lib::Mocks::mock_userenv( { patron => $manager, branchcode => $manager->branchcode } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode, }
        }
    );

    my $reserve_id = C4::Reserves::AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblionumber,
            priority       => 1,
            itemnumber     => $item->itemnumber,
        }
    );

    my $hold = Koha::Holds->find($reserve_id);

    ok( $reserve_id, "Hold created" );
    ok( $hold,       "Hold found" );
    $hold->set_waiting( $desk->desk_id );
    is( $hold->found,   'W',            'Hold is waiting with correct status set' );
    is( $hold->desk_id, $desk->desk_id, 'Hold is attach to its desk' );

};

subtest 'get_items_that_can_fill' => sub {
    plan tests => 6;

    Koha::CirculationRules->search(
        {
            rule_name  => 'holdallowed',
            rule_value => 'not_allowed',
        }
    )->delete;

    my $biblio  = $builder->build_sample_biblio;
    my $itype_1 = $builder->build_object( { class => 'Koha::ItemTypes' } );    # For 1, 2, 3, 4
    my $itype_2 = $builder->build_object( { class => 'Koha::ItemTypes' } );
    my $item_1  = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, itype => $itype_1->itemtype } );

    # waiting
    my $item_2 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, itype => $itype_1->itemtype } );
    my $item_3 =
        $builder->build_sample_item( { biblionumber => $biblio->biblionumber, itype => $itype_1->itemtype } );  # onloan
    my $item_4 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, itype => $itype_1->itemtype } )
        ;    # in transfer
    my $item_5 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, itype => $itype_2->itemtype } );
    my $lost       = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, itemlost   => 1 } );
    my $withdrawn  = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, withdrawn  => 1 } );
    my $notforloan = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, notforloan => -1 } );

    my $patron_1 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron_2 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron_3 = $builder->build_object( { class => 'Koha::Patrons' } );

    my $library_1 = $builder->build_object( { class => 'Koha::Libraries' } );

    t::lib::Mocks::mock_userenv( { patron => $patron_1 } );

    my $reserve_id_1 = C4::Reserves::AddReserve(
        {
            branchcode     => $library_1->branchcode,
            borrowernumber => $patron_1->borrowernumber,
            biblionumber   => $biblio->biblionumber,
            priority       => 1,
            itemnumber     => $item_1->itemnumber,
        }
    );

    my $holds = Koha::Holds->search( { reserve_id => $reserve_id_1 } );
    my $items = $holds->get_items_that_can_fill;
    is_deeply(
        [ map { $_->itemnumber } $items->as_list ], [ $item_1->itemnumber ],
        'Item level hold can only be filled by the specific item'
    );

    my $reserve_id_2 = C4::Reserves::AddReserve(
        {
            branchcode     => $library_1->branchcode,
            borrowernumber => $patron_2->borrowernumber,
            biblionumber   => $biblio->biblionumber,
            priority       => 2,
            branchcode     => $item_1->homebranch,
        }
    );

    my $waiting_reserve_id = C4::Reserves::AddReserve(
        {
            branchcode     => $library_1->branchcode,
            borrowernumber => $patron_2->borrowernumber,
            biblionumber   => $biblio->biblionumber,
            priority       => 0,
            found          => 'W',
            itemnumber     => $item_1->itemnumber,
        }
    );

    my $notforloan_reserve_id = C4::Reserves::AddReserve(
        {
            branchcode     => $library_1->branchcode,
            borrowernumber => $patron_2->borrowernumber,
            biblionumber   => $biblio->biblionumber,
            priority       => 0,
            itemnumber     => $notforloan->itemnumber,
        }
    );

    # item 3 is on loan
    AddIssue( $patron_3, $item_3->barcode );

    # item 4 is in transfer
    my $from = $builder->build_object( { class => 'Koha::Libraries' } );
    my $to   = $builder->build_object( { class => 'Koha::Libraries' } );
    Koha::Item::Transfer->new(
        {
            itemnumber  => $item_4->itemnumber,
            datearrived => undef,
            frombranch  => $from->branchcode,
            tobranch    => $to->branchcode
        }
    )->store;

    $holds = Koha::Holds->search(
        { reserve_id => [ $reserve_id_1, $reserve_id_2, $waiting_reserve_id, $notforloan_reserve_id, ] } );

    $items = $holds->get_items_that_can_fill;
    is_deeply(
        [ map { $_->itemnumber } $items->as_list ],
        [ $item_2->itemnumber, $item_5->itemnumber ], 'Only item 2 and 5 are available for filling the hold'
    );

    # Marking item_5 is no hold allowed
    Koha::CirculationRule->new(
        {
            rule_name  => 'holdallowed',
            rule_value => 'not_allowed',
            itemtype   => $item_5->itype
        }
    )->store;
    $items = $holds->get_items_that_can_fill;
    is_deeply(
        [ map { $_->itemnumber } $items->as_list ],
        [ $item_2->itemnumber ], 'Only item 2 is available for filling the hold'
    );

    my $noloan_itype = $builder->build_object( { class => 'Koha::ItemTypes', value => { notforloan => 1 } } );
    t::lib::Mocks::mock_preference( 'item-level_itypes', 0 );
    Koha::Holds->find($waiting_reserve_id)->delete;
    $holds = Koha::Holds->search( { reserve_id => [ $reserve_id_1, $reserve_id_2 ] } );
    $items = $holds->get_items_that_can_fill;
    is_deeply(
        [ sort { $a <=> $b } map { $_->itemnumber } $items->as_list ],
        [ $item_1->itemnumber, $item_2->itemnumber, $item_5->itemnumber ],
        'Items 1, 2, and 5 are available for filling the holds'
    );

    my $no_holds = Koha::Holds->new->empty();
    my $no_items = $no_holds->get_items_that_can_fill();
    is( ref $no_items,    "Koha::Items", "Routine returns a Koha::Items object" );
    is( $no_items->count, 0,             "Object is empty when called on no holds" );

};

subtest 'set_waiting+patron_expiration_date' => sub {
    plan tests => 2;
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );

    my $item    = $builder->build_sample_item( { library => $library->branchcode } );
    my $manager = $builder->build_object( { class => "Koha::Patrons" } );
    t::lib::Mocks::mock_userenv( { patron => $manager, branchcode => $manager->branchcode } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode, }
        }
    );

    subtest 'patron_expiration_date < expiration_date' => sub {
        plan tests => 6;
        t::lib::Mocks::mock_preference( 'ReservesMaxPickUpDelay', 5 );
        my $patron_expiration_date = dt_from_string->add( days => 3 )->ymd;
        my $reserve_id             = C4::Reserves::AddReserve(
            {
                branchcode      => $library->branchcode,
                borrowernumber  => $patron->borrowernumber,
                biblionumber    => $item->biblionumber,
                priority        => 1,
                itemnumber      => $item->itemnumber,
                expiration_date => $patron_expiration_date,
            }
        );

        my $hold = Koha::Holds->find($reserve_id);

        is(
            $hold->expirationdate,
            $patron_expiration_date,
            'expiration date set to patron expiration date'
        );
        is(
            $hold->patron_expiration_date, $patron_expiration_date,
            'patron expiration date correctly set'
        );

        $hold->set_waiting;

        $hold = $hold->get_from_storage;
        is( $hold->expirationdate,         $patron_expiration_date );
        is( $hold->patron_expiration_date, $patron_expiration_date );

        $hold->revert_found();

        $hold = $hold->get_from_storage;
        is( $hold->expirationdate,         $patron_expiration_date );
        is( $hold->patron_expiration_date, $patron_expiration_date );
    };

    subtest 'patron_expiration_date > expiration_date' => sub {
        plan tests => 6;
        t::lib::Mocks::mock_preference( 'ReservesMaxPickUpDelay', 5 );
        my $new_expiration_date    = dt_from_string->add( days => 5 )->ymd;
        my $patron_expiration_date = dt_from_string->add( days => 6 )->ymd;
        my $reserve_id             = C4::Reserves::AddReserve(
            {
                branchcode      => $library->branchcode,
                borrowernumber  => $patron->borrowernumber,
                biblionumber    => $item->biblionumber,
                priority        => 1,
                itemnumber      => $item->itemnumber,
                expiration_date => $patron_expiration_date,
            }
        );

        my $hold = Koha::Holds->find($reserve_id);

        is(
            $hold->expirationdate,
            $patron_expiration_date,
            'expiration date set to patron expiration date'
        );
        is(
            $hold->patron_expiration_date, $patron_expiration_date,
            'patron expiration date correctly set'
        );

        $hold->set_waiting;

        $hold = $hold->get_from_storage;
        is( $hold->expirationdate,         $new_expiration_date );
        is( $hold->patron_expiration_date, $patron_expiration_date );

        $hold->revert_found();

        $hold = $hold->get_from_storage;
        is( $hold->expirationdate,         $patron_expiration_date );
        is( $hold->patron_expiration_date, $patron_expiration_date );
    };
};

subtest 'Test Koha::Hold::item_group' => sub {
    plan tests => 1;
    my $library    = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron     = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item       = $builder->build_sample_item;
    my $item_group = $builder->build_object(
        {
            class => 'Koha::Biblio::ItemGroups',
        }
    );
    my $reserve_id = AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblionumber,
            itemnumber     => $item->itemnumber,
            item_group_id  => $item_group->id,
        }
    );

    my $hold = Koha::Holds->find($reserve_id);
    is(
        $hold->item_group_id, $item_group->id,
        'Koha::Hold::item_group returns the correct item_group'
    );
};

$schema->storage->txn_rollback;

subtest 'filter_by_found() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $unfilled   = $builder->build_object( { class => 'Koha::Holds', value => { found => undef } } );
    my $processing = $builder->build_object( { class => 'Koha::Holds', value => { found => 'P' } } );
    my $in_transit = $builder->build_object( { class => 'Koha::Holds', value => { found => 'T' } } );
    my $waiting    = $builder->build_object( { class => 'Koha::Holds', value => { found => 'W' } } );

    my $holds = Koha::Holds->search(
        { reserve_id => [ $unfilled->id, $processing->id, $in_transit->id, $waiting->id ] },
        { order_by   => ['reserve_id'] }
    );

    is( $holds->count, 4, 'Resultset count is correct' );

    my $found_holds = $holds->filter_by_found;

    is( $found_holds->count, 3, 'Resultset count is correct' );

    ok( $found_holds->next->is_in_processing, 'Status is correct (P)' );
    ok( $found_holds->next->is_in_transit,    'Status is correct (T)' );
    ok( $found_holds->next->is_waiting,       'Status is correct (W)' );

    $schema->storage->txn_rollback;
};

subtest 'filter_by_has_cancellation_requests() and filter_out_has_cancellation_requests() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    my $item_1 = $builder->build_sample_item;
    my $item_2 = $builder->build_sample_item;
    my $item_3 = $builder->build_sample_item;

    my $hold_1 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                found          => 'W',
                itemnumber     => $item_1->id,
                biblionumber   => $item_1->biblionumber,
                borrowernumber => $patron->id
            }
        }
    );
    my $hold_2 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                found          => 'W',
                itemnumber     => $item_2->id,
                biblionumber   => $item_2->biblionumber,
                borrowernumber => $patron->id
            }
        }
    );
    my $hold_3 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                found          => 'W',
                itemnumber     => $item_3->id,
                biblionumber   => $item_3->biblionumber,
                borrowernumber => $patron->id
            }
        }
    );

    my $rs = Koha::Holds->search( { reserve_id => [ $hold_1->id, $hold_2->id, $hold_3->id ] } );

    is( $rs->count, 3 );

    my $filtered_rs = $rs->filter_by_has_cancellation_requests;

    is( $filtered_rs->count, 0 );

    my $filtered_out_rs = $rs->filter_out_has_cancellation_requests;

    is( $filtered_out_rs->count, 3 );

    $hold_2->add_cancellation_request;

    $filtered_rs = $rs->filter_by_has_cancellation_requests;

    is( $filtered_rs->count,    1 );
    is( $filtered_rs->next->id, $hold_2->id );

    $filtered_out_rs = $rs->filter_out_has_cancellation_requests;

    is( $filtered_out_rs->count,    2 );
    is( $filtered_out_rs->next->id, $hold_1->id );

    $schema->storage->txn_rollback;
};

subtest 'processing() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $hold_1 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { found => 'P' }
        }
    );
    my $hold_2 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { found => undef }
        }
    );
    my $hold_3 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { found => 'T' }
        }
    );

    my $holds = Koha::Holds->search( { reserve_id => [ $hold_1->id, $hold_2->id, $hold_3->id ] } );
    is( $holds->count, 3, 'Resultset contains 3 holds' );

    my $processing = $holds->processing;
    is( $processing->count, 1 );
    is( $processing->next->id, $hold_1->id, "First hold is the only one in 'processing'" );

    $schema->storage->txn_rollback;
};
