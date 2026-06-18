#!/usr/bin/env perl

# This file is part of Koha.
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
use Test::More tests => 5;
use Test::MockModule;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Context;
use Koha::Database;

BEGIN { use_ok('Koha::Policy::Circulation'); }

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'circ_control_library() - PickupLibrary' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'CircControl', 'PickupLibrary' );

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item    = $builder->build_sample_item();

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );

    is(
        Koha::Policy::Circulation->circ_control_library( $item, $patron ),
        $library->branchcode,
        'Uses userenv branch when CircControl is PickupLibrary'
    );

    my $other_library = $builder->build_object( { class => 'Koha::Libraries' } );
    is(
        Koha::Policy::Circulation->circ_control_library(
            $item, $patron, { pickup_library_id => $other_library->branchcode }
        ),
        $other_library->branchcode,
        'Uses explicit pickup_library_id when provided'
    );

    # No userenv and no pickup_library_id: falls back to ItemHomeLibrary behaviour
    C4::Context->unset_userenv;
    t::lib::Mocks::mock_preference( 'HomeOrHoldingBranch', 'homebranch' );

    is(
        Koha::Policy::Circulation->circ_control_library( $item, $patron ),
        $item->homebranch,
        'Falls back to item home library when no userenv and no pickup_library_id'
    );

    $schema->storage->txn_rollback;
};

subtest 'circ_control_library() - PatronLibrary' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'CircControl', 'PatronLibrary' );

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item   = $builder->build_sample_item();

    is(
        Koha::Policy::Circulation->circ_control_library( $item, $patron ),
        $patron->branchcode,
        'Uses patron branchcode when CircControl is PatronLibrary'
    );

    $schema->storage->txn_rollback;
};

subtest 'circ_control_library() - ItemHomeLibrary' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'CircControl', 'ItemHomeLibrary' );

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    # homebranch
    t::lib::Mocks::mock_preference( 'HomeOrHoldingBranch', 'homebranch' );
    my $item = $builder->build_sample_item();

    is(
        Koha::Policy::Circulation->circ_control_library( $item, $patron ),
        $item->homebranch,
        'Uses item homebranch when HomeOrHoldingBranch is homebranch'
    );

    # holdingbranch
    t::lib::Mocks::mock_preference( 'HomeOrHoldingBranch', 'holdingbranch' );
    my $holding_library = $builder->build_object( { class => 'Koha::Libraries' } );
    $item->holdingbranch( $holding_library->branchcode )->store;

    is(
        Koha::Policy::Circulation->circ_control_library( $item, $patron ),
        $holding_library->branchcode,
        'Uses item holdingbranch when HomeOrHoldingBranch is holdingbranch'
    );

    # holdingbranch fallback to homebranch when null
    $item->holdingbranch(undef)->store;

    is(
        Koha::Policy::Circulation->circ_control_library( $item, $patron ),
        $item->homebranch,
        'Falls back to homebranch when holdingbranch is null'
    );

    $schema->storage->txn_rollback;
};
