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

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Item::Transfers;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Test::NoWarnings;
use Test::More tests => 9;
use Test::Exception;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'item relation tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $item     = $builder->build_sample_item();
    my $transfer = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                itemnumber => $item->itemnumber,
            }
        }
    );

    my $transfer_item = $transfer->item;
    is( ref($transfer_item),        'Koha::Item',      'Koha::Item::Transfer->item should return a Koha::Item' );
    is( $transfer_item->itemnumber, $item->itemnumber, 'Koha::Item::Transfer->item should return the correct item' );

    $schema->storage->txn_rollback;
};

subtest 'from_library relation tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $transfer = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                frombranch => $library->branchcode,
            }
        }
    );

    my $from_library = $transfer->from_library;
    is( ref($from_library), 'Koha::Library', 'Koha::Item::Transfer->from_library should return a Koha::Library' );
    is(
        $from_library->branchcode, $library->branchcode,
        'Koha::Item::Transfer->from_library should return the correct library'
    );

    $schema->storage->txn_rollback;
};

subtest 'to_library relation tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $transfer = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                tobranch => $library->branchcode,
            }
        }
    );

    my $to_library = $transfer->to_library;
    is( ref($to_library), 'Koha::Library', 'Koha::Item::Transfer->to_library should return a Koha::Library' );
    is(
        $to_library->branchcode, $library->branchcode,
        'Koha::Item::Transfer->to_library should return the correct library'
    );

    $schema->storage->txn_rollback;
};

subtest 'transit tests' => sub {
    plan tests => 7;

    $schema->storage->txn_begin;

    my $library1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item     = $builder->build_sample_item(
        {
            homebranch    => $library1->branchcode,
            holdingbranch => $library2->branchcode,
            datelastseen  => undef
        }
    );

    my $transfer = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                itemnumber => $item->itemnumber,
                frombranch => $library2->branchcode,
                tobranch   => $library1->branchcode,
                reason     => 'Manual'
            }
        }
    );
    is( ref($transfer), 'Koha::Item::Transfer', 'Mock transfer added' );

    # Item checked out should result in failure
    my $checkout = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => { itemnumber => $item->itemnumber }
        }
    );
    is( ref($checkout), 'Koha::Checkout', 'Mock checkout added' );

    throws_ok { $transfer->transit() }
    'Koha::Exceptions::Item::Transfer::OnLoan',
        'Exception thrown if item is checked out';

    $checkout->delete;

    # CartToShelf test
    $item->set( { location => 'CART', permanent_location => 'TEST' } )->store();
    is( $item->location, 'CART', 'Item location set to CART' );
    $transfer->discard_changes;
    $transfer->transit();
    $item->discard_changes;
    is( $item->location, 'TEST', 'Item location correctly restored to match permanent location' );

    # Transit state set
    ok( $transfer->datesent, 'Transit set the datesent for the transfer' );

    # Last seen
    ok( $item->datelastseen, 'Transit set item datelastseen date' );

    $schema->storage->txn_rollback;
};

subtest 'receive tests' => sub {
    plan tests => 5;

    $schema->storage->txn_begin;

    my $library1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item     = $builder->build_sample_item(
        {
            homebranch    => $library1->branchcode,
            holdingbranch => $library2->branchcode,
            datelastseen  => undef
        }
    );

    my $transfer = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                itemnumber  => $item->itemnumber,
                frombranch  => $library2->branchcode,
                tobranch    => $library1->branchcode,
                datearrived => undef,
                reason      => 'Manual'
            }
        }
    );
    is( ref($transfer), 'Koha::Item::Transfer', 'Mock transfer added' );

    # Item checked out should result in failure
    my $checkout = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => { itemnumber => $item->itemnumber }
        }
    );
    is( ref($checkout), 'Koha::Checkout', 'Mock checkout added' );

    throws_ok { $transfer->receive() }
    'Koha::Exceptions::Item::Transfer::OnLoan',
        'Exception thrown if item is checked out';

    $checkout->delete;

    # Transit state set
    $transfer->discard_changes;
    $transfer->receive();
    ok( $transfer->datearrived, 'Receipt set the datearrived for the transfer' );

    # Last seen
    ok( $item->datelastseen, 'Receipt set item datelastseen date' );

    $schema->storage->txn_rollback;
};

subtest 'in_transit tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $library_from = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_to   = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item         = $builder->build_sample_item(
        {
            homebranch    => $library_to->branchcode,
            holdingbranch => $library_from->branchcode,
        }
    );

    my $transfer = Koha::Item::Transfer->new(
        {
            itemnumber    => $item->itemnumber,
            frombranch    => $library_from->branchcode,
            tobranch      => $library_to->branchcode,
            daterequested => dt_from_string,
        }
    )->store;

    ok( !$transfer->in_transit, 'in_transit returns false when only daterequested is defined' );

    $transfer->datesent(dt_from_string)->store;
    ok( $transfer->in_transit, 'in_transit returns true when datesent is defined' );

    $transfer->datearrived(dt_from_string)->store;
    ok( !$transfer->in_transit, 'in_transit returns false when datearrived is defined' );

    $transfer->set( { datearrived => undef, datecancelled => dt_from_string } )->store;
    ok( !$transfer->in_transit, 'in_transit returns false when datecancelled is defined' );

    $schema->storage->txn_rollback;
};

subtest 'cancel tests' => sub {
    plan tests => 7;

    $schema->storage->txn_begin;

    my $library1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item     = $builder->build_sample_item(
        {
            homebranch    => $library1->branchcode,
            holdingbranch => $library2->branchcode,
            datelastseen  => undef
        }
    );
    my $cancellation_reason = 'Manual';

    my $transfer = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                itemnumber          => $item->itemnumber,
                frombranch          => $library2->branchcode,
                tobranch            => $library1->branchcode,
                datesent            => \'NOW()',
                datearrived         => undef,
                datecancelled       => undef,
                reason              => 'Manual',
                cancellation_reason => undef
            }
        }
    );
    is( ref($transfer), 'Koha::Item::Transfer', 'Mock transfer added' );

    # Missing mandatory parameter
    throws_ok { $transfer->cancel() } 'Koha::Exceptions::MissingParameter',
        'Exception thrown if a reason is not passed to cancel';

    # Item in transit should result in failure
    throws_ok { $transfer->cancel( { reason => $cancellation_reason } ) }
    'Koha::Exceptions::Item::Transfer::InTransit',
        'Exception thrown if item is in transit';

    $transfer->cancel( { reason => $cancellation_reason, force => 1 } );
    ok( $transfer->datecancelled, 'Forced cancellation, cancellation date set' );
    is( $transfer->cancellation_reason, 'Manual', 'Forced cancellation, cancellation reason is set' );

    $transfer->datecancelled(undef);
    $transfer->cancellation_reason(undef);
    $transfer->datesent(undef);

    # Transit state unset
    $transfer->store()->discard_changes;
    $transfer->cancel( { reason => $cancellation_reason } );
    ok( $transfer->datecancelled, 'Cancellation date set upon call to cancel' );
    is( $transfer->cancellation_reason, 'Manual', 'Cancellation reason is set' );

    $schema->storage->txn_rollback;
};

subtest 'store() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $library_a = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_b = $builder->build_object( { class => 'Koha::Libraries' } );

    my $item = $builder->build_sample_item(
        {
            homebranch    => $library_a->branchcode,
            holdingbranch => $library_b->branchcode,
        }
    );

    # make sure there aren't transfer logs
    $schema->resultset('ActionLog')->search( { module => 'TRANSFERS' } )->delete();
    is( $schema->resultset('ActionLog')->search( { module => 'TRANSFERS' } )->count(), 0, 'No transfer logs' );

    # enable logging
    t::lib::Mocks::mock_preference( 'TransfersLog', 1 );

    # Add a new transfer entry
    my $transfer = Koha::Item::Transfer->new(
        {
            itemnumber          => $item->itemnumber,
            frombranch          => $library_b->branchcode,
            tobranch            => $library_a->branchcode,
            datesent            => \'NOW()',
            datearrived         => undef,
            datecancelled       => undef,
            reason              => 'Manual',
            cancellation_reason => undef,
        }
    )->store();
    is(
        $schema->resultset('ActionLog')->search( { module => 'TRANSFERS', action => 'CREATE' } )->count(), 1,
        'Logging enabled, log added on creation'
    );

    $transfer->reason('Reserve')->store();
    is(
        $schema->resultset('ActionLog')->search( { module => 'TRANSFERS', action => 'UPDATE' } )->count(), 1,
        'Logging enabled, log added on update'
    );

    # enable logging
    t::lib::Mocks::mock_preference( 'TransfersLog', 0 );
    $transfer = Koha::Item::Transfer->new(
        {
            itemnumber          => $item->itemnumber,
            frombranch          => $library_b->branchcode,
            tobranch            => $library_a->branchcode,
            datesent            => \'NOW()',
            datearrived         => undef,
            datecancelled       => undef,
            reason              => 'Manual',
            cancellation_reason => undef,
        }
    )->store();
    is(
        $schema->resultset('ActionLog')->search( { module => 'TRANSFERS', action => 'CREATE' } )->count(), 1,
        'Logging disabled, log not generated on creation'
    );

    $transfer->reason('Reserve')->store();
    is(
        $schema->resultset('ActionLog')->search( { module => 'TRANSFERS', action => 'UPDATE' } )->count(), 1,
        'Logging enabled, log not generated on update'
    );

    $schema->storage->txn_rollback;
};
