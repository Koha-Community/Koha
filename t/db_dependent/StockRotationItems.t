#!/usr/bin/perl

# Copyright PTFS Europe 2016
#
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

use DateTime;
use DateTime::Duration;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Item::Transfer;

use Test::Warn;
use t::lib::TestBuilder;
use t::lib::Mocks;

use Test::NoWarnings;
use Test::More tests => 10;

my $schema = Koha::Database->new->schema;

use_ok('Koha::StockRotationItems');
use_ok('Koha::StockRotationItem');

my $builder = t::lib::TestBuilder->new;

subtest 'Basic object tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $itm   = $builder->build_sample_item;
    my $stage = $builder->build( { source => 'Stockrotationstage' } );

    my $item = $builder->build(
        {
            source => 'Stockrotationitem',
            value  => {
                itemnumber_id => $itm->itemnumber,
                stage_id      => $stage->{stage_id},
            },
        }
    );

    my $sritem = Koha::StockRotationItems->find( $item->{itemnumber_id} );
    isa_ok(
        $sritem,
        'Koha::StockRotationItem',
        "Correctly create and load a stock rotation item."
    );

    # Relationship to rota
    isa_ok( $sritem->item, 'Koha::Item', "Fetched related item." );
    is( $sritem->item->itemnumber, $itm->itemnumber, "Related rota OK." );

    # Relationship to stage
    isa_ok( $sritem->stage, 'Koha::StockRotationStage', "Fetched related stage." );
    is( $sritem->stage->stage_id, $stage->{stage_id}, "Related stage OK." );

    $schema->storage->txn_rollback;
};

subtest 'Tests for needs_repatriating' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    # Setup a pristine stockrotation context.
    my $sritem = $builder->build(
        {
            source => 'Stockrotationitem',
            value  => { itemnumber_id => $builder->build_sample_item->itemnumber }
        }
    );
    my $dbitem = Koha::StockRotationItems->find( $sritem->{itemnumber_id} );
    $dbitem->item->homebranch( $dbitem->stage->branchcode_id );
    $dbitem->item->holdingbranch( $dbitem->stage->branchcode_id );
    $dbitem->stage->position(1);

    my $dbrota   = $dbitem->stage->rota;
    my $newstage = $builder->build(
        {
            source => 'Stockrotationstage',
            value  => {
                rota_id  => $dbrota->rota_id,
                position => 2,
            }
        }
    );

    # - homebranch == holdingbranch [0]
    is(
        $dbitem->needs_repatriating, 0,
        "Homebranch == Holdingbranch."
    );

    my $branch = $builder->build( { source => 'Branch' } );
    $dbitem->item->holdingbranch( $branch->{branchcode} );

    # - homebranch != holdingbranch [1]
    is(
        $dbitem->needs_repatriating, 1,
        "Homebranch != holdingbranch."
    );

    # Set to incorrect homebranch.
    $dbitem->item->holdingbranch( $dbitem->stage->branchcode_id );
    $dbitem->item->homebranch( $branch->{branchcode} );

    # - homebranch != stockrotationstage.branch & not in transit [1]
    is(
        $dbitem->needs_repatriating, 1,
        "Homebranch != StockRotationStage.Branchcode_id & not in transit."
    );

    # Set to in transit (by implication).
    $dbitem->stage( $newstage->{stage_id} );

    # - homebranch != stockrotaitonstage.branch & in transit [0]
    is(
        $dbitem->needs_repatriating, 1,
        "homebranch != stockrotaitonstage.branch & in transit."
    );

    $schema->storage->txn_rollback;
};

subtest "Tests for repatriate." => sub {
    plan tests => 9;
    $schema->storage->txn_begin;

    my $sritem_1 = $builder->build_object(
        {
            class => 'Koha::StockRotationItems',
            value => { itemnumber_id => $builder->build_sample_item->itemnumber }
        }
    );
    my $item_id   = $sritem_1->item->itemnumber;
    my $srstage_1 = $sritem_1->stage;
    $sritem_1->discard_changes;
    $sritem_1->stage->position(1);
    $sritem_1->stage->duration(50);
    my $branch = $builder->build( { source => 'Branch' } );
    $sritem_1->item->holdingbranch( $branch->{branchcode} );

    # Test a straight up repatriate
    ok( $sritem_1->repatriate, "Repatriation done." );
    my $intransfer = $sritem_1->item->get_transfer;
    is( $intransfer->frombranch, $branch->{branchcode},           "Origin correct." );
    is( $intransfer->tobranch,   $sritem_1->stage->branchcode_id, "Target Correct." );

    # Reset
    $intransfer->datearrived( dt_from_string() )->store;
    $sritem_1->item->holdingbranch( $branch->{branchcode} );

    # Setup a conflicting manual transfer
    my $item = Koha::Items->find($item_id);
    $item->request_transfer( { to => $srstage_1->branchcode, reason => "Manual" } );
    $intransfer = $item->get_transfer;
    is( ref($intransfer),    'Koha::Item::Transfer', "Conflicting transfer added" );
    is( $intransfer->reason, 'Manual',               "Conflicting transfer reason is 'Manual'" );

    # Stockrotation should handle transfer clashes
    is( $sritem_1->repatriate, 0, "Repatriation skipped if transfer in progress." );

    # Reset
    $intransfer->datearrived( dt_from_string() )->store;
    $sritem_1->item->holdingbranch( $branch->{branchcode} );

    # Confirm that stockrotation ignores transfer limits
    t::lib::Mocks::mock_preference( 'UseBranchTransferLimits',  1 );
    t::lib::Mocks::mock_preference( 'BranchTransferLimitsType', 'itemtype' );
    my $limit = Koha::Item::Transfer::Limit->new(
        {
            fromBranch => $branch->{branchcode},
            toBranch   => $srstage_1->branchcode_id,
            itemtype   => $sritem_1->item->effective_itemtype,
        }
    )->store;

    # Stockrotation should overrule transfer limits
    ok( $sritem_1->repatriate, "Repatriation done regardless of transfer limits." );
    $intransfer = $sritem_1->item->get_transfer;
    is( $intransfer->frombranch, $branch->{branchcode},           "Origin correct." );
    is( $intransfer->tobranch,   $sritem_1->stage->branchcode_id, "Target Correct." );

    $schema->storage->txn_rollback;
};

subtest "Tests for needs_advancing." => sub {
    plan tests => 8;
    $schema->storage->txn_begin;

    # Test behaviour of item freshly added to rota.
    my $sritem = $builder->build(
        {
            source => 'Stockrotationitem',
            value  => {
                'fresh'       => 1,
                itemnumber_id => $builder->build_sample_item->itemnumber
            },
        }
    );
    my $dbitem = Koha::StockRotationItems->find( $sritem->{itemnumber_id} );
    is( $dbitem->needs_advancing, 1, "An item that is fresh will always need advancing." );

    # Setup a pristine stockrotation context.
    $sritem = $builder->build(
        {
            source => 'Stockrotationitem',
            value  => {
                'fresh'       => 0,
                itemnumber_id => $builder->build_sample_item->itemnumber
            }
        }
    );
    $dbitem = Koha::StockRotationItems->find( $sritem->{itemnumber_id} );
    $dbitem->item->homebranch( $dbitem->stage->branchcode_id );
    $dbitem->item->holdingbranch( $dbitem->stage->branchcode_id );
    $dbitem->stage->position(1);
    $dbitem->stage->duration(50);

    my $dbtransfer = Koha::Item::Transfer->new(
        {
            'itemnumber'  => $dbitem->itemnumber_id,
            'frombranch'  => $dbitem->stage->branchcode_id,
            'tobranch'    => $dbitem->stage->branchcode_id,
            'datesent'    => dt_from_string(),
            'datearrived' => undef,
            'reason'      => "StockrotationAdvance",
        }
    )->store;

    # Test item will not be advanced if in transit.
    is( $dbitem->needs_advancing, 0, "Not ready to advance: in transfer." );

    # Test item will not be advanced if in transit even if fresh.
    $dbitem->fresh(1)->store;
    is( $dbitem->needs_advancing, 0, "Not ready to advance: in transfer (fresh)." );
    $dbitem->fresh(0)->store;

    # Test item will not be advanced if it has not spent enough time.
    $dbtransfer->datearrived( dt_from_string() )->store;
    is( $dbitem->needs_advancing, 0, "Not ready to advance: Not spent enough time." );

    # Test item will be advanced if it has not spent enough time, but is fresh.
    $dbitem->fresh(1)->store;
    is( $dbitem->needs_advancing, 1, "Advance: Not spent enough time, but fresh." );
    $dbitem->fresh(0)->store;

    # Test item will be advanced if it has spent enough time.
    $dbtransfer->datesent(    # Item was sent 100 days ago...
        dt_from_string() - DateTime::Duration->new( days => 100 )
    )->store;
    $dbtransfer->datearrived(    # And arrived 75 days ago.
        dt_from_string() - DateTime::Duration->new( days => 75 )
    )->store;
    is( $dbitem->needs_advancing, 1, "Ready to be advanced." );

    # Bug 30518: Confirm that DST boundaries do not explode.
    # mock_config does not work here, because of tz vs timezone subroutines
    my $context = Test::MockModule->new('C4::Context');
    $context->mock(
        'tz',
        sub {
            'Europe/London';
        }
    );
    my $bad_date = dt_from_string( "2020-09-29T01:15:30", 'iso' );
    $dbtransfer->datesent($bad_date)->store;
    $dbtransfer->datearrived($bad_date)->store;
    $dbitem->stage->duration(180)->store;
    is( $dbitem->needs_advancing, 1, "DST boundary doesn't cause failure." );
    $context->unmock('tz');

    # Test that missing historical branch transfers do not crash
    $dbtransfer->delete;
    warning_is { $dbitem->needs_advancing }
    "We have no historical branch transfer for item " . $dbitem->item->itemnumber . "; This should not have happened!",
        "Missing transfer is warned.";

    $schema->storage->txn_rollback;
};

subtest "Tests for advance." => sub {
    plan tests => 48;
    $schema->storage->txn_begin;

    my $sritem_1 = $builder->build_object(
        {
            class => 'Koha::StockRotationItems',
            value => {
                'fresh'       => 1,
                itemnumber_id => $builder->build_sample_item->itemnumber
            }
        }
    );
    $sritem_1->discard_changes;
    $sritem_1->item->holdingbranch( $sritem_1->stage->branchcode_id );
    my $item_id   = $sritem_1->item->itemnumber;
    my $srstage_1 = $sritem_1->stage;
    $srstage_1->position(1)->duration(50)->store;    # Configure stage.
                                                     # Configure item
    $sritem_1->item->holdingbranch( $srstage_1->branchcode_id )->store;
    $sritem_1->item->homebranch( $srstage_1->branchcode_id )->store;

    # Sanity check
    is( $sritem_1->stage->stage_id, $srstage_1->stage_id, "Stage sanity check." );

    # Test if an item is fresh, always move to first stage.
    is( $sritem_1->fresh, 1, "Fresh is correct." );
    $sritem_1->advance;
    is( $sritem_1->stage->stage_id, $srstage_1->stage_id, "Stage is first stage after fresh advance." );
    is( $sritem_1->fresh,           0,                    "Fresh reset after advance." );

    # Test cases of single stage
    $srstage_1->rota->cyclical(1)->store;    # Set Rota to cyclical.
    ok( $sritem_1->advance, "Single stage cyclical advance done." );
    ## Refetch sritem_1
    $sritem_1->discard_changes;
    is( $sritem_1->stage->stage_id, $srstage_1->stage_id, "Single stage cyclical stage OK." );

    # Test with indemand advance
    $sritem_1->indemand(1)->store;
    ok( $sritem_1->advance, "Indemand item advance done." );
    ## Refetch sritem_1
    $sritem_1->discard_changes;
    is( $sritem_1->indemand,        0,                    "Indemand OK." );
    is( $sritem_1->stage->stage_id, $srstage_1->stage_id, "Indemand item advance stage OK." );

    # Multi stages
    my $srstage_2 = $builder->build_object(
        {
            class => 'Koha::StockRotationStages',
            value => { duration => 50 }
        }
    );
    $srstage_2->discard_changes;
    $srstage_2->move_to_group( $sritem_1->stage->rota_id );
    $srstage_2->move_last;

    # Test a straight up advance
    ok( $sritem_1->advance, "Advancement done." );
    ## Refetch sritem_1
    $sritem_1->discard_changes;
    ## Test results
    is( $sritem_1->stage->stage_id, $srstage_2->stage_id, "Stage updated." );
    is(
        $sritem_1->item->homebranch,
        $srstage_2->branchcode_id,
        "Item homebranch updated"
    );
    my $transfer_request = $sritem_1->item->get_transfer;
    is( $transfer_request->frombranch, $srstage_1->branchcode_id, "Origin correct." );
    is( $transfer_request->tobranch,   $srstage_2->branchcode_id, "Target Correct." );
    is( $transfer_request->datesent,   undef,                     "Transfer requested, but not sent." );

    # Arrive at new branch
    $transfer_request->datearrived( dt_from_string() )->store;
    $sritem_1->item->holdingbranch( $srstage_2->branchcode_id )->store;

    # Test a cyclical advance
    ok( $sritem_1->advance, "Cyclical advancement done." );
    ## Refetch sritem_1
    $sritem_1->discard_changes;
    ## Test results
    is( $sritem_1->stage->stage_id, $srstage_1->stage_id, "Stage updated." );
    is(
        $sritem_1->item->homebranch,
        $srstage_1->branchcode_id,
        "Item homebranch updated"
    );
    $transfer_request = $sritem_1->item->get_transfer;
    is( $transfer_request->frombranch, $srstage_2->branchcode_id, "Origin correct." );
    is( $transfer_request->tobranch,   $srstage_1->branchcode_id, "Target correct." );

    # Arrive at new branch
    $transfer_request->datearrived( dt_from_string() )->store;
    $sritem_1->item->holdingbranch( $srstage_1->branchcode_id )->store;

    # Confirm that stockrotation ignores transfer limits
    t::lib::Mocks::mock_preference( 'UseBranchTransferLimits',  1 );
    t::lib::Mocks::mock_preference( 'BranchTransferLimitsType', 'itemtype' );
    my $limit = Koha::Item::Transfer::Limit->new(
        {
            fromBranch => $srstage_1->branchcode_id,
            toBranch   => $srstage_2->branchcode_id,
            itemtype   => $sritem_1->item->effective_itemtype,
        }
    )->store;

    ok( $sritem_1->advance, "Advancement overrules transfer limits." );
    ## Refetch sritem_1
    $sritem_1->discard_changes;
    ## Test results
    is( $sritem_1->stage->stage_id, $srstage_2->stage_id, "Stage updated ignoring transfer limits." );
    is(
        $sritem_1->item->homebranch,
        $srstage_2->branchcode_id,
        "Item homebranch updated ignoring transfer limits"
    );
    $transfer_request = $sritem_1->item->get_transfer;
    is( $transfer_request->frombranch, $srstage_1->branchcode_id, "Origin correct ignoring transfer limits." );
    is( $transfer_request->tobranch,   $srstage_2->branchcode_id, "Target correct ignoring transfer limits." );

    # Arrive at new branch
    $transfer_request->datearrived( dt_from_string() )->store;
    $sritem_1->item->holdingbranch( $srstage_2->branchcode_id )->store;

    # Setup a conflicting manual transfer
    my $item = Koha::Items->find($item_id);
    $item->request_transfer( { to => $srstage_1->branchcode, reason => "Manual" } );
    $transfer_request = $item->get_transfer;
    is( ref($transfer_request),    'Koha::Item::Transfer', "Conflicting transfer added" );
    is( $transfer_request->reason, 'Manual',               "Conflicting transfer reason is 'Manual'" );

    # Advance item whilst conflicting manual transfer exists
    ok( $sritem_1->advance, "Advancement done." );
    ## Refetch sritem_1
    $sritem_1->discard_changes;

    ## Refetch conflicted transfer
    $transfer_request->discard_changes;

    # Conflicted transfer should have been cancelled
    isnt( $transfer_request->datecancelled, undef, "Conflicting manual transfer was cancelled" );

    # StockRotationAdvance transfer added
    $transfer_request = $sritem_1->item->get_transfer;
    is( $transfer_request->reason,     'StockrotationAdvance',    "StockrotationAdvance transfer added" );
    is( $transfer_request->frombranch, $srstage_2->branchcode_id, "Origin correct." );
    is( $transfer_request->tobranch,   $srstage_1->branchcode_id, "Target correct." );

    # Arrive at new branch
    $transfer_request->datearrived( dt_from_string() )->store;
    $sritem_1->item->holdingbranch( $srstage_1->branchcode_id )->store;

    # Setup a conflicting reserve transfer
    $item->request_transfer( { to => $srstage_2->branchcode, reason => "Reserve" } );
    $transfer_request = $item->get_transfer;
    is( ref($transfer_request),    'Koha::Item::Transfer', "Conflicting transfer added" );
    is( $transfer_request->reason, 'Reserve',              "Conflicting transfer reason is 'Reserve'" );

    # Advance item whilst conflicting reserve transfer exists
    ok( $sritem_1->advance, "Advancement done." );
    ## Refetch sritem_1
    $sritem_1->discard_changes;

    ## Refetch conflicted transfer
    $transfer_request->discard_changes;

    # Conflicted transfer should not been cancelled
    is( $transfer_request->datecancelled, undef, "Conflicting reserve transfer was not cancelled" );

    # StockRotationAdvance transfer added
    my $transfer_requests = Koha::Item::Transfers->search(
        {
            itemnumber    => $sritem_1->item->itemnumber,
            datearrived   => undef,
            datecancelled => undef
        }
    );
    is( $transfer_requests->count, '2', "StockrotationAdvance transfer queued" );

    # Arrive at new branch
    $transfer_request->datearrived( dt_from_string() )->store;
    $sritem_1->item->holdingbranch( $srstage_2->branchcode_id )->store;

    # StockRotationAdvance transfer added
    $transfer_request = $sritem_1->item->get_transfer;
    is(
        $transfer_request->reason, 'StockrotationAdvance',
        "StockrotationAdvance transfer remains after reserve is met"
    );
    is( $transfer_request->frombranch, $srstage_1->branchcode_id, "Origin correct." );
    is( $transfer_request->tobranch,   $srstage_2->branchcode_id, "Target correct." );

    # Arrive at new branch
    $transfer_request->datearrived( dt_from_string() )->store;
    $sritem_1->item->holdingbranch( $srstage_2->branchcode_id )->store;

    # Checked out item, advanced to next stage, checkedout from next stage
    # transfer should be generated, but not initiated
    my $issue = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => {
                branchcode => $srstage_1->branchcode_id,
                itemnumber => $sritem_1->item->itemnumber,
                returndate => undef
            }
        }
    );
    $sritem_1->item->holdingbranch( $srstage_1->branchcode_id )->store;
    ok( $sritem_1->advance, "Advancement done." );
    $transfer_request = $sritem_1->item->get_transfer;
    is( $transfer_request->frombranch, $srstage_1->branchcode_id, "Origin correct." );
    is( $transfer_request->tobranch,   $srstage_1->branchcode_id, "Target correct." );
    is( $transfer_request->datesent,   undef,                     "Transfer waiting to initiate until return." );

    $issue->delete;        #remove issue
    $sritem_1->advance;    #advance back to second stage
                           # Set arrived
    $transfer_request->datearrived( dt_from_string() )->store;
    $sritem_1->item->holdingbranch( $srstage_2->branchcode_id )->store;

    $srstage_1->rota->cyclical(0)->store;    # Set Rota to non-cyclical.

    my $srstage_3 = $builder->build_object(
        {
            class => 'Koha::StockRotationStages',
            value => { duration => 50 }
        }
    );
    $srstage_3->discard_changes;
    $srstage_3->move_to_group( $sritem_1->stage->rota_id );
    $srstage_3->move_last;

    # Advance again, to end of rota.
    ok( $sritem_1->advance, "Non-cyclical advance to last stage." );

    # Arrive at new branch
    $transfer_request->datearrived( dt_from_string() )->store;
    $sritem_1->item->holdingbranch( $srstage_3->branchcode_id )->store;

    # Advance again, Remove from rota.
    ok( $sritem_1->advance, "Non-cyclical advance." );
    ## Refetch sritem_1
    $sritem_1 = Koha::StockRotationItems->find( { itemnumber_id => $item_id } );
    is( $sritem_1, undef, "StockRotationItem has been removed." );
    $item = Koha::Items->find($item_id);
    is( $item->homebranch, $srstage_3->branchcode_id, "Item homebranch remains" );

    $schema->storage->txn_rollback;
};

subtest "Tests for investigate (singular)." => sub {
    plan tests => 7;
    $schema->storage->txn_begin;

    # Test brand new item's investigation ['initiation']
    my $sritem = $builder->build(
        {
            source => 'Stockrotationitem',
            value  => {
                fresh         => 1,
                itemnumber_id => $builder->build_sample_item->itemnumber
            }
        }
    );
    my $dbitem = Koha::StockRotationItems->find( $sritem->{itemnumber_id} );
    is( $dbitem->investigate->{reason}, 'initiation', "fresh item initiates." );

    # Test brand new item at stagebranch ['initiation']
    $sritem = $builder->build(
        {
            source => 'Stockrotationitem',
            value  => {
                fresh         => 1,
                itemnumber_id => $builder->build_sample_item->itemnumber
            }
        }
    );
    $dbitem = Koha::StockRotationItems->find( $sritem->{itemnumber_id} );
    $dbitem->item->homebranch( $dbitem->stage->branchcode_id )->store;
    $dbitem->item->holdingbranch( $dbitem->stage->branchcode_id )->store;
    is( $dbitem->investigate->{reason}, 'initiation', "fresh item at stagebranch initiates." );

    # Test item not at stagebranch with branchtransfer history ['repatriation']
    $sritem = $builder->build(
        {
            source => 'Stockrotationitem',
            value  => {
                'fresh'       => 0,
                itemnumber_id => $builder->build_sample_item->itemnumber
            }
        }
    );
    $dbitem = Koha::StockRotationItems->find( $sritem->{itemnumber_id} );
    my $dbtransfer = Koha::Item::Transfer->new(
        {
            'itemnumber'  => $dbitem->itemnumber_id,
            'frombranch'  => $dbitem->item->homebranch,
            'tobranch'    => $dbitem->item->homebranch,
            'datesent'    => dt_from_string(),
            'datearrived' => dt_from_string(),
            'reason'      => "StockrotationAdvance",
        }
    )->store;
    is( $dbitem->investigate->{reason}, 'repatriation', "older item repatriates." );

    # Test item at stagebranch with branchtransfer history ['not-ready']
    $sritem = $builder->build(
        {
            source => 'Stockrotationitem',
            value  => {
                'fresh'       => 0,
                itemnumber_id => $builder->build_sample_item->itemnumber
            }
        }
    );
    $dbitem     = Koha::StockRotationItems->find( $sritem->{itemnumber_id} );
    $dbtransfer = Koha::Item::Transfer->new(
        {
            'itemnumber'  => $dbitem->itemnumber_id,
            'frombranch'  => $dbitem->item->homebranch,
            'tobranch'    => $dbitem->stage->branchcode_id,
            'datesent'    => dt_from_string(),
            'datearrived' => dt_from_string(),
            'reason'      => "StockrotationAdvance",
        }
    )->store;
    $dbitem->item->homebranch( $dbitem->stage->branchcode_id )->store;
    $dbitem->item->holdingbranch( $dbitem->stage->branchcode_id )->store;
    is( $dbitem->investigate->{reason}, 'not-ready', "older item at stagebranch not-ready." );

    # Test item due for advancement ['advancement']
    $sritem = $builder->build(
        {
            source => 'Stockrotationitem',
            value  => {
                fresh         => 0,
                itemnumber_id => $builder->build_sample_item->itemnumber
            }
        }
    );
    $dbitem = Koha::StockRotationItems->find( $sritem->{itemnumber_id} );
    $dbitem->indemand(0)->store;
    $dbitem->stage->duration(50)->store;
    my $sent_duration    = DateTime::Duration->new( days => 55 );
    my $arrived_duration = DateTime::Duration->new( days => 52 );
    $dbtransfer = Koha::Item::Transfer->new(
        {
            'itemnumber'  => $dbitem->itemnumber_id,
            'frombranch'  => $dbitem->item->homebranch,
            'tobranch'    => $dbitem->stage->branchcode_id,
            'datesent'    => dt_from_string() - $sent_duration,
            'datearrived' => dt_from_string() - $arrived_duration,
            'reason'      => "StockrotationAdvance",
        }
    )->store;
    $dbitem->item->homebranch( $dbitem->stage->branchcode_id )->store;
    $dbitem->item->holdingbranch( $dbitem->stage->branchcode_id )->store;
    is(
        $dbitem->investigate->{reason}, 'advancement',
        "Item ready for advancement."
    );

    # Test item due for advancement but in-demand ['in-demand']
    $sritem = $builder->build(
        {
            source => 'Stockrotationitem',
            value  => {
                fresh         => 0,
                itemnumber_id => $builder->build_sample_item->itemnumber
            }
        }
    );
    $dbitem = Koha::StockRotationItems->find( $sritem->{itemnumber_id} );
    $dbitem->indemand(1)->store;
    $dbitem->stage->duration(50)->store;
    $sent_duration    = DateTime::Duration->new( days => 55 );
    $arrived_duration = DateTime::Duration->new( days => 52 );
    $dbtransfer       = Koha::Item::Transfer->new(
        {
            'itemnumber'  => $dbitem->itemnumber_id,
            'frombranch'  => $dbitem->item->homebranch,
            'tobranch'    => $dbitem->stage->branchcode_id,
            'datesent'    => dt_from_string() - $sent_duration,
            'datearrived' => dt_from_string() - $arrived_duration,
            'reason'      => "StockrotationAdvance",
        }
    )->store;
    $dbitem->item->homebranch( $dbitem->stage->branchcode_id )->store;
    $dbitem->item->holdingbranch( $dbitem->stage->branchcode_id )->store;
    is(
        $dbitem->investigate->{reason}, 'in-demand',
        "Item advances, but in-demand."
    );

    # Test item ready for advancement, but at wrong library ['repatriation']
    $sritem = $builder->build(
        {
            source => 'Stockrotationitem',
            value  => {
                fresh         => 0,
                itemnumber_id => $builder->build_sample_item->itemnumber
            }
        }
    );
    $dbitem = Koha::StockRotationItems->find( $sritem->{itemnumber_id} );
    $dbitem->indemand(0)->store;
    $dbitem->stage->duration(50)->store;
    $sent_duration    = DateTime::Duration->new( days => 55 );
    $arrived_duration = DateTime::Duration->new( days => 52 );
    $dbtransfer       = Koha::Item::Transfer->new(
        {
            'itemnumber'  => $dbitem->itemnumber_id,
            'frombranch'  => $dbitem->item->homebranch,
            'tobranch'    => $dbitem->stage->branchcode_id,
            'datesent'    => dt_from_string() - $sent_duration,
            'datearrived' => dt_from_string() - $arrived_duration,
            'reason'      => "StockrotationAdvance",
        }
    )->store;
    is(
        $dbitem->investigate->{reason}, 'repatriation',
        "Item advances, but not at stage branch."
    );

    $schema->storage->txn_rollback;
};

subtest "Tests for toggle_indemand" => sub {
    plan tests => 15;
    $schema->storage->txn_begin;

    my $sritem = $builder->build(
        {
            source => 'Stockrotationitem',
            value  => { 'fresh' => 0, 'indemand' => 0 }
        }
    );
    my $dbitem      = Koha::StockRotationItems->find( $sritem->{itemnumber_id} );
    my $firstbranch = $dbitem->stage->branchcode_id;
    $dbitem->item->holdingbranch($firstbranch)->store;
    my $dbstage = $dbitem->stage;
    $dbstage->position(1)->duration(50)->store;    # Configure stage.
                                                   # Configure item
    $dbitem->item->holdingbranch($firstbranch)->store;
    $dbitem->item->homebranch($firstbranch)->store;

    # Sanity check
    is( $dbitem->stage->stage_id, $dbstage->stage_id, "Stage sanity check." );

    # Test if an item is not in transfer, toggle always acts.
    is( $dbitem->indemand, 0, "Item not in transfer starts with indemand disabled." );
    $dbitem->toggle_indemand;
    is( $dbitem->indemand, 1, "Item not in transfer toggled correctly first time." );
    $dbitem->toggle_indemand;
    is( $dbitem->indemand, 0, "Item not in transfer toggled correctly second time." );

    # Add stages
    my $srstage = $builder->build(
        {
            source => 'Stockrotationstage',
            value  => { duration => 50 }
        }
    );
    my $dbstage2 = Koha::StockRotationStages->find( $srstage->{stage_id} );
    $dbstage2->move_to_group( $dbitem->stage->rota_id );
    $dbstage2->position(2)->store;
    my $secondbranch = $dbstage2->branchcode_id;

    # Test an item in transfer, toggle cancels transfer and resets indemand.
    ok( $dbitem->advance, "Advancement done." );
    $dbitem->get_from_storage;
    my $transfer = $dbitem->item->get_transfer;
    is( ref($transfer),         'Koha::Item::Transfer', 'Item set to in transfer as expected' );
    is( $transfer->frombranch,  $firstbranch,           'Transfer from set correctly' );
    is( $transfer->tobranch,    $secondbranch,          'Transfer to set correctly' );
    is( $transfer->datearrived, undef,                  'Transfer datearrived not set' );
    $dbitem->toggle_indemand;
    my $updated_transfer = $transfer->get_from_storage;
    is( $updated_transfer->frombranch, $firstbranch, 'Transfer from retained correctly' );
    is( $updated_transfer->tobranch,   $firstbranch, 'Transfer to updated correctly' );
    isnt( $updated_transfer->datearrived, undef, 'Transfer datearrived set as expected' );
    is( $dbitem->indemand,         0,            "Item retains indemand as expected." );
    is( $dbitem->stage_id,         $dbstage->id, 'Item stage reset as expected.' );
    is( $dbitem->item->homebranch, $firstbranch, 'Item homebranch reset as expected.' );

    $schema->storage->txn_rollback;
};

1;
