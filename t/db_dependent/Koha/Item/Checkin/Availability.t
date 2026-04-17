#!/usr/bin/perl

# Copyright 2026 Koha Development team
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

use Test::More tests => 10;
use Test::NoWarnings;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;
use Koha::Item::Checkin::Availability;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'check() - item exists' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item    = $builder->build_object(
        {
            class => 'Koha::Items',
            value => { withdrawn => 0, itemlost => 0 }
        }
    );

    my $result = $item->checkin_availability( { library => $library->branchcode } );

    isa_ok( $result, 'Koha::Result::Availability', 'Returns Result object' );
    ok( $result->available, 'Item is available for check-in' );

    $schema->storage->txn_rollback;
};

subtest 'check() - BlockedWithdrawn blocker' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'BlockReturnOfWithdrawnItems', 1 );
    t::lib::Mocks::mock_preference( 'BlockReturnOfLostItems',      0 );

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item    = $builder->build_object(
        {
            class => 'Koha::Items',
            value => { withdrawn => 1, itemlost => 0 }
        }
    );

    # Not checked out: blocker and NotIssued confirmation
    my $result = $item->checkin_availability( { library => $library->branchcode } );

    is( $result->blockers->{BlockedWithdrawn}, 1,              'BlockedWithdrawn blocker set' );
    is( $result->confirmations->{NotIssued},   $item->barcode, 'NotIssued confirmation set for non-checked-out item' );

    # Checked out: blocker but no NotIssued, context has checkout/patron
    my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );
    my $checkout = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => {
                itemnumber     => $item->itemnumber,
                borrowernumber => $patron->borrowernumber,
            }
        }
    );

    $result = $item->checkin_availability( { library => $library->branchcode } );

    is( $result->blockers->{BlockedWithdrawn}, 1,                'BlockedWithdrawn blocker set for checked-out item' );
    is( ref( $result->context->{checkout} ),   'Koha::Checkout', 'checkout context preserved when blocked' );

    $schema->storage->txn_rollback;
};

subtest 'check() - withdrawn warning (not blocked)' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'BlockReturnOfWithdrawnItems', 0 );
    t::lib::Mocks::mock_preference( 'BlockReturnOfLostItems',      0 );

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item    = $builder->build_object(
        {
            class => 'Koha::Items',
            value => { withdrawn => 1, itemlost => 0 }
        }
    );

    my $result = $item->checkin_availability( { library => $library->branchcode } );

    ok( $result->available, 'no blockers when BlockReturnOfWithdrawnItems is off' );
    is( $result->warnings->{withdrawn},      1,              'withdrawn warning set' );
    is( $result->confirmations->{NotIssued}, $item->barcode, 'NotIssued confirmation still set' );

    $schema->storage->txn_rollback;
};

subtest 'check() - BlockedLost blocker' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'BlockReturnOfLostItems',      1 );
    t::lib::Mocks::mock_preference( 'BlockReturnOfWithdrawnItems', 0 );

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item    = $builder->build_object(
        {
            class => 'Koha::Items',
            value => { itemlost => 1, withdrawn => 0 }
        }
    );

    # Not checked out: blocker and NotIssued confirmation
    my $result = $item->checkin_availability(
        {
            library => $library->branchcode,
        }
    );

    is( $result->blockers->{BlockedLost},    1,              'BlockedLost blocker set' );
    is( $result->confirmations->{NotIssued}, $item->barcode, 'NotIssued confirmation set for non-checked-out item' );

    # Checked out: blocker but checkout context preserved
    my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );
    my $checkout = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => {
                itemnumber     => $item->itemnumber,
                borrowernumber => $patron->borrowernumber,
            }
        }
    );

    $result = $item->checkin_availability(
        {
            library => $library->branchcode,
        }
    );

    is( $result->blockers->{BlockedLost},    1,                'BlockedLost blocker set for checked-out item' );
    is( ref( $result->context->{checkout} ), 'Koha::Checkout', 'checkout context preserved when blocked' );

    $schema->storage->txn_rollback;
};

subtest 'check() - Wrongbranch blocker' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $homebranch    = $builder->build_object( { class => 'Koha::Libraries' } );
    my $holdingbranch = $builder->build_object( { class => 'Koha::Libraries' } );
    my $wrongbranch   = $builder->build_object( { class => 'Koha::Libraries' } );

    t::lib::Mocks::mock_preference( 'BlockReturnOfWithdrawnItems', 0 );
    t::lib::Mocks::mock_preference( 'BlockReturnOfLostItems',      0 );

    my $item = $builder->build_object(
        {
            class => 'Koha::Items',
            value => {
                homebranch    => $homebranch->branchcode,
                holdingbranch => $holdingbranch->branchcode,
                withdrawn     => 0,
                itemlost      => 0,
            }
        }
    );

    # Test homebranch restriction
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'homebranch' );
    my $result = $item->checkin_availability(
        {
            library => $wrongbranch->branchcode,
        }
    );

    is( ref( $result->blockers->{Wrongbranch} ),         'HASH',                   'Wrongbranch blocker is hashref' );
    is( $result->blockers->{Wrongbranch}->{Wrongbranch}, $wrongbranch->branchcode, 'wrong branch recorded' );
    is( $result->blockers->{Wrongbranch}->{Rightbranch}, $homebranch->branchcode,  'right branch recorded' );

    # Test holdingbranch restriction
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'holdingbranch' );
    $result = $item->checkin_availability(
        {
            library => $wrongbranch->branchcode,
        }
    );

    is(
        $result->blockers->{Wrongbranch}->{Wrongbranch}, $wrongbranch->branchcode,
        'wrong branch recorded for holdingbranch'
    );
    is(
        $result->blockers->{Wrongbranch}->{Rightbranch}, $holdingbranch->branchcode,
        'holding branch recorded as right branch'
    );

    # Test homeorholdingbranch restriction
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'homeorholdingbranch' );
    $result = $item->checkin_availability(
        {
            library => $wrongbranch->branchcode,
        }
    );

    is(
        $result->blockers->{Wrongbranch}->{Wrongbranch}, $wrongbranch->branchcode,
        'wrong branch recorded for homeorholdingbranch'
    );

    # Test anywhere - should not block
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'anywhere' );
    $result = $item->checkin_availability(
        {
            library => $wrongbranch->branchcode,
        }
    );

    is( $result->blockers->{Wrongbranch}, undef, 'no Wrongbranch blocker when anywhere allowed' );
    is( keys %{ $result->blockers },      0,     'no blockers when anywhere allowed' );

    $schema->storage->txn_rollback;
};

subtest 'check() - NotIssued confirmation' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item    = $builder->build_object(
        {
            class => 'Koha::Items',
            value => { withdrawn => 0, itemlost => 0 }
        }
    );

    my $result = $item->checkin_availability(
        {
            library => $library->branchcode,
        }
    );

    is( keys %{ $result->blockers },         0,              'no blockers for not issued item' );
    is( $result->confirmations->{NotIssued}, $item->barcode, 'NotIssued confirmation set with barcode' );
    is( $result->context->{checkout},        undef,          'checkout is undef when not checked out' );
    is( $result->context->{patron},          undef,          'patron is undef when not checked out' );

    $schema->storage->txn_rollback;
};

subtest 'check() - checked out item (no confirmations)' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item    = $builder->build_object(
        {
            class => 'Koha::Items',
            value => { withdrawn => 0, itemlost => 0 }
        }
    );
    my $issue = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => {
                itemnumber     => $item->itemnumber,
                borrowernumber => $patron->borrowernumber,
            }
        }
    );

    my $result = $item->checkin_availability(
        {
            library => $library->branchcode,
        }
    );

    is( keys %{ $result->blockers },      0, 'no blockers for checked out item' );
    is( keys %{ $result->confirmations }, 0, 'no confirmations for checked out item' );

    is( ref( $result->context->{checkout} ), 'Koha::Checkout', 'checkout object returned' );
    is( ref( $result->context->{patron} ),   'Koha::Patron',   'patron object returned' );
    is( $result->context->{patron}->id,      $patron->id,      'correct patron returned' );

    $schema->storage->txn_rollback;
};

subtest 'check() - multiple simultaneous blockers' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'BlockReturnOfWithdrawnItems', 1 );
    t::lib::Mocks::mock_preference( 'BlockReturnOfLostItems',      1 );
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch',         'homebranch' );

    my $homebranch  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $wrongbranch = $builder->build_object( { class => 'Koha::Libraries' } );

    my $item = $builder->build_object(
        {
            class => 'Koha::Items',
            value => {
                homebranch    => $homebranch->branchcode,
                holdingbranch => $homebranch->branchcode,
                withdrawn     => 1,
                itemlost      => 1,
            }
        }
    );

    my $result = $item->checkin_availability(
        {
            library          => $wrongbranch->branchcode,
            no_short_circuit => 1,
        }
    );

    ok( !$result->available, 'item is not available for check-in' );
    is( keys %{ $result->blockers },                     3, 'all three blockers reported simultaneously' );
    is( $result->blockers->{BlockedWithdrawn},           1, 'BlockedWithdrawn blocker present' );
    is( $result->blockers->{Wrongbranch}->{Rightbranch}, $homebranch->branchcode, 'Wrongbranch blocker present' );
    is( $result->blockers->{BlockedLost},                1,                       'BlockedLost blocker present' );

    $schema->storage->txn_rollback;
};

subtest 'check() - default short-circuits on first blocker' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'BlockReturnOfWithdrawnItems', 1 );
    t::lib::Mocks::mock_preference( 'BlockReturnOfLostItems',      1 );
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch',         'homebranch' );

    my $homebranch  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $wrongbranch = $builder->build_object( { class => 'Koha::Libraries' } );

    my $item = $builder->build_object(
        {
            class => 'Koha::Items',
            value => {
                homebranch    => $homebranch->branchcode,
                holdingbranch => $homebranch->branchcode,
                withdrawn     => 1,
                itemlost      => 1,
            }
        }
    );

    # Default behavior: short-circuit on first blocker
    my $result = $item->checkin_availability(
        {
            library => $wrongbranch->branchcode,
        }
    );

    ok( !$result->available, 'item is not available for check-in' );
    is( keys %{ $result->blockers },           1, 'only first blocker reported (short-circuited)' );
    is( $result->blockers->{BlockedWithdrawn}, 1, 'BlockedWithdrawn is the first blocker' );

    $schema->storage->txn_rollback;
};
