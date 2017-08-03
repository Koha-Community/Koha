#!/usr/bin/perl

# Copyright 2017 Koha Development team
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

use Test::More tests => 1;
use Test::Warn;

use C4::Reserves;
use Koha::Holds;
use Koha::Database;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

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
    my $item = $builder->build_object( { class => 'Koha::Items', value => $item_info } );

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
            $library->branchcode, $patron->borrowernumber,
            $item->biblionumber,  '',
            $priority,            undef,
            undef,                '',
            "title for fee",      $item->itemnumber,
        );
        my $hold = Koha::Holds->find($reserve_id);
        push @patrons, $patron;
        push @holds,   $hold;
    }

    # There are 3 holds on this records
    my $nb_of_holds =
      Koha::Holds->search( { biblionumber => $item->biblionumber } )->count;
    is( $nb_of_holds, 3,
        'There should have 3 holds placed on this biblio record' );
    my $first_hold  = $holds[0];
    my $second_hold = $holds[1];
    my $third_hold  = $holds[2];
    is( ref($second_hold), 'Koha::Hold',
        'We should play with Koha::Hold objects' );
    is( $second_hold->priority, 2,
        'Second hold should have a priority set to 3' );

    # Remove the second hold, only 2 should still exist in DB and priorities must have been updated
    my $is_cancelled = $second_hold->cancel;
    is( ref($is_cancelled), 'Koha::Hold',
        'Koha::Hold->cancel should return the Koha::Hold (?)' )
      ;    # This is can reconsidered
    is( $second_hold->in_storage, 0,
        'The hold has been cancelled and does not longer exist in DB' );
    $nb_of_holds =
      Koha::Holds->search( { biblionumber => $item->biblionumber } )->count;
    is( $nb_of_holds, 2,
        'a hold has been cancelled, there should have only 2 holds placed on this biblio record'
    );

    # discard_changes to refetch
    is( $first_hold->discard_changes->priority, 1, 'First hold should still be first' );
    is( $third_hold->discard_changes->priority, 2, 'Third hold should now be second' );

    subtest 'charge_cancel_fee parameter' => sub {
        plan tests => 4;
        my $patron_category = $builder->build_object({ class => 'Koha::Patron::Categories', value => { reservefee => 0 } } );
        my $patron = $builder->build_object({ class => 'Koha::Patrons', value => { categorycode => $patron_category->categorycode } });
        is( $patron->account->balance, 0, 'A new patron does not have any charges' );

        my @hold_info = (
            $library->branchcode, $patron->borrowernumber,
            $item->biblionumber,  '',
            1,                    undef,
            undef,                '',
            "title for fee",      $item->itemnumber,
        );

        # First, test cancelling a reserve when there's no charge configured.
        t::lib::Mocks::mock_preference('ExpireReservesMaxPickUpDelayCharge', 0);
        my $reserve_id = C4::Reserves::AddReserve( @hold_info );
        Koha::Holds->find( $reserve_id )->cancel( { charge_cancel_fee => 1 } );
        is( $patron->account->balance, 0, 'ExpireReservesMaxPickUpDelayCharge=0 - The patron should not have been charged' );

        # Then, test cancelling a reserve when there's no charge desired.
        t::lib::Mocks::mock_preference('ExpireReservesMaxPickUpDelayCharge', 42);
        $reserve_id = C4::Reserves::AddReserve( @hold_info );
        Koha::Holds->find( $reserve_id )->cancel(); # charge_cancel_fee => 0
        is( $patron->account->balance, 0, 'ExpireReservesMaxPickUpDelayCharge=42, but charge_cancel_fee => 0, The patron should not have been charged' );


        # Finally, test cancelling a reserve when there's a charge desired and configured.
        t::lib::Mocks::mock_preference('ExpireReservesMaxPickUpDelayCharge', 42);
        $reserve_id = C4::Reserves::AddReserve( @hold_info );
        Koha::Holds->find( $reserve_id )->cancel( { charge_cancel_fee => 1 } );
        is( int($patron->account->balance), 42, 'ExpireReservesMaxPickUpDelayCharge=42 and charge_cancel_fee => 1, The patron should have been charged!' );
    };

    subtest 'waiting hold' => sub {
        plan tests => 1;
        my $patron = $builder->build_object({ class => 'Koha::Patrons' });
        my $reserve_id = C4::Reserves::AddReserve(
            $library->branchcode, $patron->borrowernumber,
            $item->biblionumber,  '',
            1,                    undef,
            undef,                '',
            "title for fee",      $item->itemnumber,
            'W',
        );
        Koha::Holds->find( $reserve_id )->cancel;
        my $hold_old = Koha::Old::Holds->find( $reserve_id );
        is( $hold_old->found, 'W', 'The found column should have been kept and a hold is cancelled' );
    };

    subtest 'HoldsLog' => sub {
        plan tests => 2;
        my $patron = $builder->build_object({ class => 'Koha::Patrons' });
        my @hold_info = (
            $library->branchcode, $patron->borrowernumber,
            $item->biblionumber,  '',
            1,                    undef,
            undef,                '',
            "title for fee",      $item->itemnumber,
        );

        t::lib::Mocks::mock_preference('HoldsLog', 0);
        my $reserve_id = C4::Reserves::AddReserve(@hold_info);
        Koha::Holds->find( $reserve_id )->cancel;
        my $number_of_logs = $schema->resultset('ActionLog')->search( { module => 'HOLDS', action => 'CANCEL', object => $reserve_id } )->count;
        is( $number_of_logs, 0, 'Without HoldsLog, Koha::Hold->cancel should not have logged' );

        t::lib::Mocks::mock_preference('HoldsLog', 1);
        $reserve_id = C4::Reserves::AddReserve(@hold_info);
        Koha::Holds->find( $reserve_id )->cancel;
        $number_of_logs = $schema->resultset('ActionLog')->search( { module => 'HOLDS', action => 'CANCEL', object => $reserve_id } )->count;
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
        my @hold_info = (
            $library->branchcode, $patron->borrowernumber,
            $item->biblionumber,  '',
            1,                    undef,
            undef,                '',
            "title for fee",      $item->itemnumber,
        );

        t::lib::Mocks::mock_preference( 'ExpireReservesMaxPickUpDelayCharge',42 );
        my $reserve_id = C4::Reserves::AddReserve(@hold_info);
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
        is( $patron->account->balance, 0,
'If the hold has not been cancelled, the patron should not have been charged'
        );
    };

};

$schema->storage->txn_rollback;

1;
