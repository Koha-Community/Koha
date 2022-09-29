#!/usr/bin/perl

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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 6;
use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Circulation qw( transferbook AddIssue );
use C4::Reserves qw( AddReserve );
use Koha::DateUtils qw( dt_from_string );
use Koha::Item::Transfers;

my $builder = t::lib::TestBuilder->new;
my $schema = Koha::Database->new->schema;

$schema->storage->txn_begin;

subtest 'transfer a non-existant item' => sub {
    plan tests => 2;

    my $library = $builder->build( { source => 'Branch' } );

    #Transfert on unknown barcode
    my $item  = $builder->build_sample_item();
    my $badbc = $item->barcode;
    $item->delete;

    my $trigger = "Manual";
    my ( $dotransfer, $messages ) =
      C4::Circulation::transferbook({
          from_branch => $item->homebranch,
          to_branch => $library->{branchcode},
          barcode => $badbc,
          trigger => $trigger
      });
    is( $dotransfer, 0, "Can't transfer a bad barcode" );
    is_deeply(
        $messages,
        { BadBarcode => $badbc },
        "We got the expected barcode"
    );
};

subtest 'field population tests' => sub {
    plan tests => 6;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } )->store;
    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );

    my $library2 = $builder->build_object( { class => 'Koha::Libraries' } )->store;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode }
        }
    );

    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
        }
    );

    my $trigger = "Manual";
    my ($dotransfer, $messages ) = transferbook({
        from_branch => $item->homebranch,
        to_branch => $library2->branchcode,
        barcode => $item->barcode,
        trigger => $trigger
    });
    is( $dotransfer, 1, 'Transfer succeeded' );
    is_deeply(
        $messages,
        { 'WasTransfered' => $library2->branchcode },
        "WasTransfered was set correctly"
    );

    my $transfers = Koha::Item::Transfers->search({ itemnumber => $item->itemnumber, datearrived => undef });
    is( $transfers->count, 1, 'One transfer created');

    my $transfer = $transfers->next;
    is ($transfer->frombranch, $library->branchcode, 'frombranch set correctly');
    is ($transfer->tobranch, $library2->branchcode, 'tobranch set correctly');
    is ($transfer->reason, $trigger, 'reason set if passed');
};

#FIXME:'UseBranchTransferLimits tests missing

subtest 'transfer already at destination' => sub {
    plan tests => 9;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } )->store;
    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode }
        }
    );

    my $itemtype = $builder->build_object({ class => 'Koha::ItemTypes' })->store->itemtype;
    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
            itype => $itemtype
        }
    );

    my ($dotransfer, $messages ) = transferbook({
        from_branch => $item->homebranch,
        to_branch => $library->branchcode,
        barcode => $item->barcode,
        trigger => "Manual"
    });
    is( $dotransfer, 0, 'Transfer of item failed when destination equals holding branch' );
    is_deeply(
        $messages,
        { 'DestinationEqualsHolding' => 1 },
        "We got the expected failure message: DestinationEqualsHolding"
    );

    # We are making sure there is no regression, feel free to change the behavior if needed.
    # * Contrary to the POD, if ignore_reserves is not passed (or is false), any item reserve
    #   found will override all other measures that may prevent transfer and force a transfer.
    AddReserve({
        branchcode     => $item->homebranch,
        borrowernumber => $patron->borrowernumber,
        biblionumber   => $item->biblionumber,
        itemnumber     => $item->itemnumber,
    });

    ($dotransfer, $messages ) = transferbook({
        from_branch => $item->homebranch,
        to_branch => $library->branchcode,
        barcode => $item->barcode,
        trigger => "Manual"
    });
    is( $dotransfer, 0, 'Transfer of reserved item doesn\'t succeed without ignore_reserves' );
    is( $messages->{ResFound}->{ResFound}, 'Reserved', "We found the reserve");
    is( $messages->{ResFound}->{itemnumber}, $item->itemnumber, "We got the reserve info");

    # recalls
    t::lib::Mocks::mock_preference('UseRecalls', 1);
    my $recall = Koha::Recall->new(
        {   biblio_id         => $item->biblionumber,
            item_id           => $item->itemnumber,
            item_level        => 1,
            patron_id         => $patron->borrowernumber,
            pickup_library_id => $library->branchcode,
        }
    )->store;
    ( $recall, $dotransfer, $messages ) = $recall->start_transfer;
    is( $dotransfer, 0, 'Do not transfer recalled item, it has already arrived' );
    is( $messages->{RecallPlacedAtHoldingBranch}, 1, "We found the recall");

    $itemtype = $builder->build_object({ class => 'Koha::ItemTypes' })->store->itemtype;
    my $item2 = $builder->build_object({ class => 'Koha::Items', value => { itype => $itemtype } }); # this item will have a different holding branch to the pickup branch
    $recall = Koha::Recall->new(
        {   biblio_id         => $item2->biblionumber,
            item_id           => $item2->itemnumber,
            item_level        => 1,
            patron_id         => $patron->borrowernumber,
            pickup_library_id => $library->branchcode,
        }
    )->store;
    ( $recall, $dotransfer, $messages ) = $recall->start_transfer;
    is( $dotransfer, 1, 'Transfer of recalled item succeeded' );
    is( $messages->{RecallFound}->id, $recall->id, "We found the recall");
};

subtest 'transfer an issued item' => sub {
    plan tests => 5;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } )->store;
    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode }
        }
    );

    my $itemtype = $builder->build_object({ class => 'Koha::ItemTypes' })->store->itemtype;
    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
            itype => $itemtype
        }
    );

    my $dt_to = dt_from_string();
    my $issue = AddIssue( $patron, $item->barcode, $dt_to );

    # We are making sure there is no regression, feel free to change the behavior if needed.
    # * WasReturned does not seem like a variable that should contain a borrowernumber
    # * Should we return even if the transfer did not happen? (same branches)
    my ($dotransfer, $messages) = transferbook({
        from_branch => $item->homebranch,
        to_branch => $library->branchcode,
        barcode => $item->barcode,
        trigger => "Manual"
    });
    is( $messages->{WasReturned}, $patron->borrowernumber, 'transferbook should have return a WasReturned flag is the item was issued before the transferbook call');

    # Reset issue
    $issue = AddIssue( $patron, $item->barcode, $dt_to );

    # We are making sure there is no regression, feel free to change the behavior if needed.
    # * Contrary to the POD, if ignore_reserves is not passed (or is false), any item reserve
    #   found will override all other measures that may prevent transfer and force a transfer.
    AddReserve({
        branchcode     => $item->homebranch,
        borrowernumber => $patron->borrowernumber,
        biblionumber   => $item->biblionumber,
        itemnumber     => $item->itemnumber,
    });

    ($dotransfer, $messages ) = transferbook({
        from_branch => $item->homebranch,
        to_branch => $library->branchcode,
        barcode => $item->barcode,
        trigger => "Manual"
    });
    is( $dotransfer, 0, 'Transfer of reserved item doesn\'t succeed without ignore_reserves' );
    is( $messages->{ResFound}->{ResFound}, 'Reserved', "We found the reserve");
    is( $messages->{ResFound}->{itemnumber}, $item->itemnumber, "We got the reserve info");
    is( $messages->{WasReturned}, $patron->borrowernumber, "We got the return info");
};

subtest 'ignore_reserves flag' => sub {
    plan tests => 9;
    my $library = $builder->build_object( { class => 'Koha::Libraries' } )->store;
    my $library2 = $builder->build_object( { class => 'Koha::Libraries' } )->store;
    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode }
        }
    );

    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
        }
    );

    AddReserve({
        branchcode     => $item->homebranch,
        borrowernumber => $patron->borrowernumber,
        biblionumber   => $item->biblionumber,
        itemnumber     => $item->itemnumber,
    });

    # We are making sure there is no regression, feel free to change the behavior if needed.
    # * Contrary to the POD, if ignore_reserves is not passed (or is false), any item reserve
    #   found will override all other measures that may prevent transfer and force a transfer.
    my ($dotransfer, $messages ) = transferbook({
        from_branch => $item->homebranch,
        to_branch => $library2->branchcode,
        barcode => $item->barcode,
        trigger => "Manual"
    });
    is( $dotransfer, 0, 'Transfer of reserved item doesn\'t succeed without ignore_reserves' );
    is( $messages->{ResFound}->{ResFound}, 'Reserved', "We found the reserve");
    is( $messages->{ResFound}->{itemnumber}, $item->itemnumber, "We got the reserve info");

    my $ignore_reserves = 0;
    ($dotransfer, $messages ) = transferbook({
        from_branch => $item->homebranch,
        to_branch => $library2->branchcode,
        barcode => $item->barcode,
        ignore_reserves => $ignore_reserves,
        trigger => "Manual"
    });
    is( $dotransfer, 0, 'Transfer of reserved item doesn\'t succeed without ignore_reserves' );
    is( $messages->{ResFound}->{ResFound}, 'Reserved', "We found the reserve");
    is( $messages->{ResFound}->{itemnumber}, $item->itemnumber, "We got the reserve info");

    $ignore_reserves = 1;
    ($dotransfer, $messages ) = transferbook({
        from_branch => $item->homebranch,
        to_branch => $library2->branchcode,
        barcode => $item->barcode,
        ignore_reserves => $ignore_reserves,
        trigger => "Manual"
    });
    is( $dotransfer, 1, 'Transfer of reserved item succeed with ignore reserves: true' );
    is( $messages->{ResFound}->{ResFound}, 'Reserved', "We found the reserve");
    is( $messages->{ResFound}->{itemnumber}, $item->itemnumber, "We got the reserve info");
};

subtest 'transferbook test from branch' => sub {
    plan tests => 5;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item = $builder->build_sample_item();
    ok( $item->holdingbranch ne $library->branchcode && $item->homebranch ne $library->branchcode, "Item is not held or owned by library");
    C4::Circulation::transferbook({
        from_branch => $library->branchcode,
        to_branch => $item->homebranch,
        barcode   => $item->barcode,
        trigger => "Manual"
    });
    my $transfer = $item->get_transfer;
    is( $transfer->frombranch, $library->branchcode, 'The transfer is initiated from the specified branch, not the items home or holdingbranch');
    is( $transfer->tobranch, $item->homebranch, 'The transfer is initiated to the specified branch');
    C4::Circulation::transferbook({
        from_branch => $item->homebranch,
        to_branch => $library->branchcode,
        barcode   => $item->barcode,
        trigger => "Manual"
    });
    $transfer = $item->get_transfer;
    is( $transfer->frombranch, $item->homebranch, 'The transfer is initiated from the specified branch');
    is( $transfer->tobranch, $library->branchcode, 'The transfer is initiated to the specified branch');

};
$schema->storage->txn_rollback;
