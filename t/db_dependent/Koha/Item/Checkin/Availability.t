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

use Test::More tests => 7;
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
    my $item    = $builder->build_object( { class => 'Koha::Items' } );

    my $result = $item->checkin_availability( { library => $library->branchcode } );

    isa_ok( $result, 'Koha::Availability::Result', 'Returns Result object' );
    ok( $result->available, 'Item is available for check-in' );

    $schema->storage->txn_rollback;
};

subtest 'check() - BlockedWithdrawn blocker' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'BlockReturnOfWithdrawnItems', 1 );

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item    = $builder->build_object(
        {
            class => 'Koha::Items',
            value => { withdrawn => 1 }
        }
    );

    my $result = $item->checkin_availability( { library => $library->branchcode } );

    is( $result->blockers->{BlockedWithdrawn}, 1, 'BlockedWithdrawn blocker set' );
    is( keys %{ $result->confirmations },      0, 'no confirmations when blocked' );

    $schema->storage->txn_rollback;
};

subtest 'check() - BlockedLost blocker' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'BlockReturnOfLostItems', 1 );

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item    = $builder->build_object(
        {
            class => 'Koha::Items',
            value => { itemlost => 1 }
        }
    );

    my $result = $item->checkin_availability(
        {
            library => $library->branchcode,
        }
    );

    is( $result->blockers->{BlockedLost}, 1, 'BlockedLost blocker set' );

    is( keys %{ $result->confirmations }, 0, 'no confirmations when blocked' );

    $schema->storage->txn_rollback;
};

subtest 'check() - Wrongbranch blocker' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $homebranch    = $builder->build_object( { class => 'Koha::Libraries' } );
    my $holdingbranch = $builder->build_object( { class => 'Koha::Libraries' } );
    my $wrongbranch   = $builder->build_object( { class => 'Koha::Libraries' } );

    my $item = $builder->build_object(
        {
            class => 'Koha::Items',
            value => {
                homebranch    => $homebranch->branchcode,
                holdingbranch => $holdingbranch->branchcode,
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
    my $item    = $builder->build_object( { class => 'Koha::Items' } );

    my $result = $item->checkin_availability(
        {
            library => $library->branchcode,
        }
    );

    is( keys %{ $result->blockers },         0,              'no blockers for not issued item' );
    is( $result->confirmations->{NotIssued}, $item->barcode, 'NotIssued confirmation set with barcode' );
    is( $result->{issue},                    undef,          'checkout is undef when not checked out' );
    is( $result->context->{patron},          undef,          'patron is undef when not checked out' );

    $schema->storage->txn_rollback;
};

subtest 'check() - checked out item (no confirmations)' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item    = $builder->build_object( { class => 'Koha::Items' } );
    my $issue   = $builder->build_object(
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
