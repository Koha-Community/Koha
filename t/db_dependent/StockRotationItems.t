#!/usr/bin/perl

# Copyright PTFS Europe 2016
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use DateTime;
use DateTime::Duration;
use Koha::Database;
use Koha::Item::Transfer;
use t::lib::TestBuilder;

use Test::More tests => 8;

my $schema = Koha::Database->new->schema;

use_ok('Koha::StockRotationItems');
use_ok('Koha::StockRotationItem');

my $builder = t::lib::TestBuilder->new;

subtest 'Basic object tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $itm = $builder->build({ source => 'Item' });
    my $stage = $builder->build({ source => 'Stockrotationstage' });

    my $item = $builder->build({
        source => 'Stockrotationitem',
        value  => {
            itemnumber_id => $itm->{itemnumber},
            stage_id      => $stage->{stage_id},
        },
    });

    my $sritem = Koha::StockRotationItems->find($item->{itemnumber_id});
    isa_ok(
        $sritem,
        'Koha::StockRotationItem',
        "Correctly create and load a stock rotation item."
    );

    # Relationship to rota
    isa_ok( $sritem->itemnumber, 'Koha::Item', "Fetched related item." );
    is( $sritem->itemnumber->itemnumber, $itm->{itemnumber}, "Related rota OK." );

    # Relationship to stage
    isa_ok( $sritem->stage, 'Koha::StockRotationStage', "Fetched related stage." );
    is( $sritem->stage->stage_id, $stage->{stage_id}, "Related stage OK." );


    $schema->storage->txn_rollback;
};

subtest 'Tests for needs_repatriating' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    # Setup a pristine stockrotation context.
    my $sritem = $builder->build({ source => 'Stockrotationitem' });
    my $dbitem = Koha::StockRotationItems->find($sritem->{itemnumber_id});
    $dbitem->itemnumber->homebranch($dbitem->stage->branchcode_id);
    $dbitem->itemnumber->holdingbranch($dbitem->stage->branchcode_id);
    $dbitem->stage->position(1);

    my $dbrota = $dbitem->stage->rota;
    my $newstage = $builder->build({
        source => 'Stockrotationstage',
        value => {
            rota_id => $dbrota->rota_id,
            position => 2,
        }
    });

    # - homebranch == holdingbranch [0]
    is(
        $dbitem->needs_repatriating, 0,
        "Homebranch == Holdingbranch."
    );

    my $branch = $builder->build({ source => 'Branch' });
    $dbitem->itemnumber->holdingbranch($branch->{branchcode});

    # - homebranch != holdingbranch [1]
    is(
        $dbitem->needs_repatriating, 1,
        "Homebranch != holdingbranch."
    );

    # Set to incorrect homebranch.
    $dbitem->itemnumber->holdingbranch($dbitem->stage->branchcode_id);
    $dbitem->itemnumber->homebranch($branch->{branchcode});
    # - homebranch != stockrotationstage.branch & not in transit [1]
    is(
        $dbitem->needs_repatriating, 1,
        "Homebranch != StockRotationStage.Branchcode_id & not in transit."
    );

    # Set to in transit (by implication).
    $dbitem->stage($newstage->{stage_id});
    # - homebranch != stockrotaitonstage.branch & in transit [0]
    is(
        $dbitem->needs_repatriating, 1,
        "homebranch != stockrotaitonstage.branch & in transit."
    );

    $schema->storage->txn_rollback;
};

subtest "Tests for repatriate." => sub {
    plan tests => 3;
    $schema->storage->txn_begin;
    my $sritem = $builder->build({ source => 'Stockrotationitem' });
    my $dbitem = Koha::StockRotationItems->find($sritem->{itemnumber_id});
    $dbitem->stage->position(1);
    $dbitem->stage->duration(50);
    my $branch = $builder->build({ source => 'Branch' });
    $dbitem->itemnumber->holdingbranch($branch->{branchcode});

    # Test a straight up repatriate
    ok($dbitem->repatriate, "Repatriation done.");
    my $intransfer = $dbitem->itemnumber->get_transfer;
    is($intransfer->frombranch, $branch->{branchcode}, "Origin correct.");
    is($intransfer->tobranch, $dbitem->stage->branchcode_id, "Target Correct.");

    $schema->storage->txn_rollback;
};

subtest "Tests for needs_advancing." => sub {
    plan tests => 6;
    $schema->storage->txn_begin;

    # Test behaviour of item freshly added to rota.
    my $sritem = $builder->build({
        source => 'Stockrotationitem',
        value  => { 'fresh' => 1, },
    });
    my $dbitem = Koha::StockRotationItems->find($sritem->{itemnumber_id});
    is($dbitem->needs_advancing, 1, "An item that is fresh will always need advancing.");

    # Setup a pristine stockrotation context.
    $sritem = $builder->build({
        source => 'Stockrotationitem',
        value => { 'fresh' => 0,}
    });
    $dbitem = Koha::StockRotationItems->find($sritem->{itemnumber_id});
    $dbitem->itemnumber->homebranch($dbitem->stage->branchcode_id);
    $dbitem->itemnumber->holdingbranch($dbitem->stage->branchcode_id);
    $dbitem->stage->position(1);
    $dbitem->stage->duration(50);

    my $dbtransfer = Koha::Item::Transfer->new({
        'itemnumber'  => $dbitem->itemnumber_id,
        'frombranch'  => $dbitem->stage->branchcode_id,
        'tobranch'    => $dbitem->stage->branchcode_id,
        'datesent'    => DateTime->now,
        'datearrived' => undef,
        'comments'    => "StockrotationAdvance",
    })->store;

    # Test item will not be advanced if in transit.
    is($dbitem->needs_advancing, 0, "Not ready to advance: in transfer.");
    # Test item will not be advanced if in transit even if fresh.
    $dbitem->fresh(1)->store;
    is($dbitem->needs_advancing, 0, "Not ready to advance: in transfer (fresh).");
    $dbitem->fresh(0)->store;

    # Test item will not be advanced if it has not spent enough time.
    $dbtransfer->datearrived(DateTime->now)->store;
    is($dbitem->needs_advancing, 0, "Not ready to advance: Not spent enough time.");
    # Test item will be advanced if it has not spent enough time, but is fresh.
    $dbitem->fresh(1)->store;
    is($dbitem->needs_advancing, 1, "Advance: Not spent enough time, but fresh.");
    $dbitem->fresh(0)->store;

    # Test item will be advanced if it has spent enough time.
    $dbtransfer->datesent(      # Item was sent 100 days ago...
        DateTime->now - DateTime::Duration->new( days => 100 )
    )->store;
    $dbtransfer->datearrived(   # And arrived 75 days ago.
        DateTime->now - DateTime::Duration->new( days => 75 )
    )->store;
    is($dbitem->needs_advancing, 1, "Ready to be advanced.");

    $schema->storage->txn_rollback;
};

subtest "Tests for advance." => sub {
    plan tests => 15;
    $schema->storage->txn_begin;

    my $sritem = $builder->build({
        source => 'Stockrotationitem',
        value => { 'fresh' => 1 }
    });
    my $dbitem = Koha::StockRotationItems->find($sritem->{itemnumber_id});
    $dbitem->itemnumber->holdingbranch($dbitem->stage->branchcode_id);
    my $dbstage = $dbitem->stage;
    $dbstage->position(1)->duration(50)->store; # Configure stage.
    # Configure item
    $dbitem->itemnumber->holdingbranch($dbstage->branchcode_id)->store;
    $dbitem->itemnumber->homebranch($dbstage->branchcode_id)->store;
    # Sanity check
    is($dbitem->stage->stage_id, $dbstage->stage_id, "Stage sanity check.");

    # Test if an item is fresh, always move to first stage.
    is($dbitem->fresh, 1, "Fresh is correct.");
    $dbitem->advance;
    is($dbitem->stage->stage_id, $dbstage->stage_id, "Stage is first stage after fresh advance.");
    is($dbitem->fresh, 0, "Fresh reset after advance.");

    # Test cases of single stage
    $dbstage->rota->cyclical(1)->store;         # Set Rota to cyclical.
    ok($dbitem->advance, "Single stage cyclical advance done.");
    ## Refetch dbitem
    $dbitem = Koha::StockRotationItems->find($sritem->{itemnumber_id});
    is($dbitem->stage->stage_id, $dbstage->stage_id, "Single stage cyclical stage OK.");

    # Test with indemand advance
    $dbitem->indemand(1)->store;
    ok($dbitem->advance, "Indemand item advance done.");
    ## Refetch dbitem
    $dbitem = Koha::StockRotationItems->find($sritem->{itemnumber_id});
    is($dbitem->indemand, 0, "Indemand OK.");
    is($dbitem->stage->stage_id, $dbstage->stage_id, "Indemand item advance stage OK.");

    # Multi stages
    my $srstage = $builder->build({
        source => 'Stockrotationstage',
        value => { duration => 50 }
    });
    my $dbstage2 = Koha::StockRotationStages->find($srstage->{stage_id});
    $dbstage2->move_to_group($dbitem->stage->rota_id);
    $dbstage2->move_last;

    # Test a straight up advance
    ok($dbitem->advance, "Advancement done.");
    ## Refetch dbitem
    $dbitem = Koha::StockRotationItems->find($sritem->{itemnumber_id});
    ## Test results
    is($dbitem->stage->stage_id, $dbstage2->stage_id, "Stage updated.");
    my $intransfer = $dbitem->itemnumber->get_transfer;
    is($intransfer->frombranch, $dbstage->branchcode_id, "Origin correct.");
    is($intransfer->tobranch, $dbstage2->branchcode_id, "Target Correct.");

    $dbstage->rota->cyclical(0)->store;         # Set Rota to non-cyclical.

    # Arrive at new branch
    $intransfer->datearrived(DateTime->now)->store;
    $dbitem->itemnumber->holdingbranch($srstage->{branchcode_id})->store;
    $dbitem->itemnumber->homebranch($srstage->{branchcode_id})->store;

    # Advance again, Remove from rota.
    ok($dbitem->advance, "Non-cyclical advance.");
    ## Refetch dbitem
    $dbitem = Koha::StockRotationItems->find($sritem->{itemnumber_id});
    is($dbitem, undef, "StockRotationItem has been removed.");

    $schema->storage->txn_rollback;
};

subtest "Tests for investigate (singular)." => sub {
    plan tests => 7;
    $schema->storage->txn_begin;

    # Test brand new item's investigation ['initiation']
    my $sritem = $builder->build({ source => 'Stockrotationitem', value => { fresh => 1 } });
    my $dbitem = Koha::StockRotationItems->find($sritem->{itemnumber_id});
    is($dbitem->investigate->{reason}, 'initiation', "fresh item initiates.");

    # Test brand new item at stagebranch ['initiation']
    $sritem = $builder->build({ source => 'Stockrotationitem', value => { fresh => 1 } });
    $dbitem = Koha::StockRotationItems->find($sritem->{itemnumber_id});
    $dbitem->itemnumber->homebranch($dbitem->stage->branchcode_id)->store;
    $dbitem->itemnumber->holdingbranch($dbitem->stage->branchcode_id)->store;
    is($dbitem->investigate->{reason}, 'initiation', "fresh item at stagebranch initiates.");

    # Test item not at stagebranch with branchtransfer history ['repatriation']
    $sritem = $builder->build({
        source => 'Stockrotationitem',
        value => { 'fresh'       => 0,}
    });
    $dbitem = Koha::StockRotationItems->find($sritem->{itemnumber_id});
    my $dbtransfer = Koha::Item::Transfer->new({
        'itemnumber'  => $dbitem->itemnumber_id,
        'frombranch'  => $dbitem->itemnumber->homebranch,
        'tobranch'    => $dbitem->itemnumber->homebranch,
        'datesent'    => DateTime->now,
        'datearrived' => DateTime->now,
        'comments'    => "StockrotationAdvance",
    })->store;
    is($dbitem->investigate->{reason}, 'repatriation', "older item repatriates.");

    # Test item at stagebranch with branchtransfer history ['not-ready']
    $sritem = $builder->build({
        source => 'Stockrotationitem',
        value => { 'fresh'       => 0,}
    });
    $dbitem = Koha::StockRotationItems->find($sritem->{itemnumber_id});
    $dbtransfer = Koha::Item::Transfer->new({
        'itemnumber'  => $dbitem->itemnumber_id,
        'frombranch'  => $dbitem->itemnumber->homebranch,
        'tobranch'    => $dbitem->stage->branchcode_id,
        'datesent'    => DateTime->now,
        'datearrived' => DateTime->now,
        'comments'    => "StockrotationAdvance",
    })->store;
    $dbitem->itemnumber->homebranch($dbitem->stage->branchcode_id)->store;
    $dbitem->itemnumber->holdingbranch($dbitem->stage->branchcode_id)->store;
    is($dbitem->investigate->{reason}, 'not-ready', "older item at stagebranch not-ready.");

    # Test item due for advancement ['advancement']
    $sritem = $builder->build({ source => 'Stockrotationitem', value => { fresh => 0 } });
    $dbitem = Koha::StockRotationItems->find($sritem->{itemnumber_id});
    $dbitem->indemand(0)->store;
    $dbitem->stage->duration(50)->store;
    my $sent_duration =  DateTime::Duration->new( days => 55);
    my $arrived_duration =  DateTime::Duration->new( days => 52);
    $dbtransfer = Koha::Item::Transfer->new({
        'itemnumber'  => $dbitem->itemnumber_id,
        'frombranch'  => $dbitem->itemnumber->homebranch,
        'tobranch'    => $dbitem->stage->branchcode_id,
        'datesent'    => DateTime->now - $sent_duration,
        'datearrived' => DateTime->now - $arrived_duration,
        'comments'    => "StockrotationAdvance",
    })->store;
    $dbitem->itemnumber->homebranch($dbitem->stage->branchcode_id)->store;
    $dbitem->itemnumber->holdingbranch($dbitem->stage->branchcode_id)->store;
    is($dbitem->investigate->{reason}, 'advancement',
       "Item ready for advancement.");

    # Test item due for advancement but in-demand ['in-demand']
    $sritem = $builder->build({ source => 'Stockrotationitem', value => { fresh => 0 } });
    $dbitem = Koha::StockRotationItems->find($sritem->{itemnumber_id});
    $dbitem->indemand(1)->store;
    $dbitem->stage->duration(50)->store;
    $sent_duration =  DateTime::Duration->new( days => 55);
    $arrived_duration =  DateTime::Duration->new( days => 52);
    $dbtransfer = Koha::Item::Transfer->new({
        'itemnumber'  => $dbitem->itemnumber_id,
        'frombranch'  => $dbitem->itemnumber->homebranch,
        'tobranch'    => $dbitem->stage->branchcode_id,
        'datesent'    => DateTime->now - $sent_duration,
        'datearrived' => DateTime->now - $arrived_duration,
        'comments'    => "StockrotationAdvance",
    })->store;
    $dbitem->itemnumber->homebranch($dbitem->stage->branchcode_id)->store;
    $dbitem->itemnumber->holdingbranch($dbitem->stage->branchcode_id)->store;
    is($dbitem->investigate->{reason}, 'in-demand',
       "Item advances, but in-demand.");

    # Test item ready for advancement, but at wrong library ['repatriation']
    $sritem = $builder->build({ source => 'Stockrotationitem', value => { fresh => 0 } });
    $dbitem = Koha::StockRotationItems->find($sritem->{itemnumber_id});
    $dbitem->indemand(0)->store;
    $dbitem->stage->duration(50)->store;
    $sent_duration =  DateTime::Duration->new( days => 55);
    $arrived_duration =  DateTime::Duration->new( days => 52);
    $dbtransfer = Koha::Item::Transfer->new({
        'itemnumber'  => $dbitem->itemnumber_id,
        'frombranch'  => $dbitem->itemnumber->homebranch,
        'tobranch'    => $dbitem->stage->branchcode_id,
        'datesent'    => DateTime->now - $sent_duration,
        'datearrived' => DateTime->now - $arrived_duration,
        'comments'    => "StockrotationAdvance",
    })->store;
    is($dbitem->investigate->{reason}, 'repatriation',
       "Item advances, but not at stage branch.");

    $schema->storage->txn_rollback;
};

1;
