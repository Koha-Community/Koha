#!/usr/bin/perl

# Copyright 2016 Koha Development team
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

use Test::More tests => 15;

use Test::MockModule;
use Test::Exception;

use C4::Circulation;
use C4::Context;
use Koha::Item;
use Koha::Item::Transfer::Limits;
use Koha::Items;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use t::lib::TestBuilder;
use t::lib::Mocks;
use t::lib::Dates;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $dbh     = C4::Context->dbh;

my $builder     = t::lib::TestBuilder->new;
my $library     = $builder->build( { source => 'Branch' } );
my $nb_of_items = Koha::Items->search->count;
my $biblio      = $builder->build_sample_biblio();
my $new_item_1   = $builder->build_sample_item({
    biblionumber => $biblio->biblionumber,
    homebranch       => $library->{branchcode},
    holdingbranch    => $library->{branchcode},
});
my $new_item_2   = $builder->build_sample_item({
    biblionumber => $biblio->biblionumber,
    homebranch       => $library->{branchcode},
    holdingbranch    => $library->{branchcode},
});


t::lib::Mocks::mock_userenv({ branchcode => $library->{branchcode} });

like( $new_item_1->itemnumber, qr|^\d+$|, 'Adding a new item should have set the itemnumber' );
is( Koha::Items->search->count, $nb_of_items + 2, 'The 2 items should have been added' );

my $retrieved_item_1 = Koha::Items->find( $new_item_1->itemnumber );
is( $retrieved_item_1->barcode, $new_item_1->barcode, 'Find a item by id should return the correct item' );

subtest 'store' => sub {
    plan tests => 5;

    my $biblio = $builder->build_sample_biblio;
    my $today = dt_from_string->set( hour => 0, minute => 0, second => 0 );
    my $item = Koha::Item->new(
        {
            homebranch    => $library->{branchcode},
            holdingbranch => $library->{branchcode},
            biblionumber  => $biblio->biblionumber,
            location      => 'my_loc',
        }
    )->store
    ->get_from_storage;

    is( t::lib::Dates::compare($item->replacementpricedate, $today), 0, 'replacementpricedate must have been set to today if not given');
    is( t::lib::Dates::compare($item->datelastseen,         $today), 0, 'datelastseen must have been set to today if not given');
    is( $item->itype, $biblio->biblioitem->itemtype, 'items.itype must have been set to biblioitem.itemtype is not given');
    is( $item->permanent_location, $item->location, 'permanent_location must have been set to location if not given' );
    $item->delete;

    subtest 'log_action' => sub {
        plan tests => 2;
        t::lib::Mocks::mock_preference( 'CataloguingLog', 1 );

        my $item = Koha::Item->new(
            {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                biblionumber  => $biblio->biblionumber,
                location      => 'my_loc',
            }
        )->store;
        is(
            Koha::ActionLogs->search(
                {
                    module => 'CATALOGUING',
                    action => 'ADD',
                    object => $item->itemnumber,
                    info   => 'item'
                }
            )->count,
            1,
            "Item creation logged"
        );

        $item->location('another_loc')->store;
        is(
            Koha::ActionLogs->search(
                {
                    module => 'CATALOGUING',
                    action => 'MODIFY',
                    object => $item->itemnumber
                }
            )->count,
            1,
            "Item modification logged"
        );
        $item->delete;
    };
};

subtest 'get_transfer' => sub {
    plan tests => 3;

    my $transfer = $new_item_1->get_transfer();
    is( $transfer, undef, 'Koha::Item->get_transfer should return undef if the item is not in transit' );

    my $library_to = $builder->build( { source => 'Branch' } );

    C4::Circulation::transferbook( $library_to->{branchcode}, $new_item_1->barcode );

    $transfer = $new_item_1->get_transfer();
    is( ref($transfer), 'Koha::Item::Transfer', 'Koha::Item->get_transfer should return a Koha::Item::Transfers object' );

    is( $transfer->itemnumber, $new_item_1->itemnumber, 'Koha::Item->get_transfer should return a valid Koha::Item::Transfers object' );
};

subtest 'holds' => sub {
    plan tests => 5;

    my $biblio = $builder->build_sample_biblio();
    my $item   = $builder->build_sample_item({
        biblionumber => $biblio->biblionumber,
    });
    $nb_of_items++;
    is($item->holds->count, 0, "Nothing returned if no holds");
    my $hold1 = $builder->build({ source => 'Reserve', value => { itemnumber=>$item->itemnumber, found => 'T' }});
    my $hold2 = $builder->build({ source => 'Reserve', value => { itemnumber=>$item->itemnumber, found => 'W' }});
    my $hold3 = $builder->build({ source => 'Reserve', value => { itemnumber=>$item->itemnumber, found => 'W' }});

    is($item->holds()->count,3,"Three holds found");
    is($item->holds({found => 'W'})->count,2,"Two waiting holds found");
    is_deeply($item->holds({found => 'T'})->next->unblessed,$hold1,"Found transit holds matches the hold");
    is($item->holds({found => undef})->count, 0,"Nothing returned if no matching holds");
};

subtest 'biblio' => sub {
    plan tests => 2;

    my $biblio = $retrieved_item_1->biblio;
    is( ref( $biblio ), 'Koha::Biblio', 'Koha::Item->biblio should return a Koha::Biblio' );
    is( $biblio->biblionumber, $retrieved_item_1->biblionumber, 'Koha::Item->biblio should return the correct biblio' );
};

subtest 'biblioitem' => sub {
    plan tests => 2;

    my $biblioitem = $retrieved_item_1->biblioitem;
    is( ref( $biblioitem ), 'Koha::Biblioitem', 'Koha::Item->biblioitem should return a Koha::Biblioitem' );
    is( $biblioitem->biblionumber, $retrieved_item_1->biblionumber, 'Koha::Item->biblioitem should return the correct biblioitem' );
};

subtest 'checkout' => sub {
    plan tests => 5;
    my $item = Koha::Items->find( $new_item_1->itemnumber );
    # No checkout yet
    my $checkout = $item->checkout;
    is( $checkout, undef, 'Koha::Item->checkout should return undef if there is no current checkout on this item' );

    # Add a checkout
    my $patron = $builder->build({ source => 'Borrower' });
    C4::Circulation::AddIssue( $patron, $item->barcode );
    $checkout = $retrieved_item_1->checkout;
    is( ref( $checkout ), 'Koha::Checkout', 'Koha::Item->checkout should return a Koha::Checkout' );
    is( $checkout->itemnumber, $item->itemnumber, 'Koha::Item->checkout should return the correct checkout' );
    is( $checkout->borrowernumber, $patron->{borrowernumber}, 'Koha::Item->checkout should return the correct checkout' );

    # Do the return
    C4::Circulation::AddReturn( $item->barcode );

    # There is no more checkout on this item, making sure it will not return old checkouts
    $checkout = $item->checkout;
    is( $checkout, undef, 'Koha::Item->checkout should return undef if there is no *current* checkout on this item' );
};

subtest 'can_be_transferred' => sub {
    plan tests => 5;

    t::lib::Mocks::mock_preference('UseBranchTransferLimits', 1);
    t::lib::Mocks::mock_preference('BranchTransferLimitsType', 'itemtype');

    my $biblio   = $builder->build_sample_biblio();
    my $library1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item  = $builder->build_sample_item({
        biblionumber     => $biblio->biblionumber,
        homebranch       => $library1->branchcode,
        holdingbranch    => $library1->branchcode,
    });
    $nb_of_items++;

    is(Koha::Item::Transfer::Limits->search({
        fromBranch => $library1->branchcode,
        toBranch => $library2->branchcode,
    })->count, 0, 'There are no transfer limits between libraries.');
    ok($item->can_be_transferred({ to => $library2 }),
       'Item can be transferred between libraries.');

    my $limit = Koha::Item::Transfer::Limit->new({
        fromBranch => $library1->branchcode,
        toBranch => $library2->branchcode,
        itemtype => $item->effective_itemtype,
    })->store;
    is(Koha::Item::Transfer::Limits->search({
        fromBranch => $library1->branchcode,
        toBranch => $library2->branchcode,
    })->count, 1, 'Given we have added a transfer limit,');
    is($item->can_be_transferred({ to => $library2 }), 0,
       'Item can no longer be transferred between libraries.');
    is($item->can_be_transferred({ to => $library2, from => $library1 }), 0,
       'We get the same result also if we pass the from-library parameter.');
};

$retrieved_item_1->delete;
is( Koha::Items->search->count, $nb_of_items + 1, 'Delete should have deleted the item' );

$schema->storage->txn_rollback;

subtest 'filter_by_visible_in_opac() tests' => sub {

    plan tests => 11;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    my $mocked_category = Test::MockModule->new('Koha::Patron::Category');
    my $exception = 1;
    $mocked_category->mock( 'override_hidden_items', sub {
        return $exception;
    });

    # have a fresh biblio
    my $biblio = $builder->build_sample_biblio;
    # have two itemtypes
    my $itype_1 = $builder->build_object({ class => 'Koha::ItemTypes' });
    my $itype_2 = $builder->build_object({ class => 'Koha::ItemTypes' });
    # have 5 items on that biblio
    my $item_1 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => -1,
            itype        => $itype_1->itemtype,
            withdrawn    => 1
        }
    );
    my $item_2 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => 0,
            itype        => $itype_2->itemtype,
            withdrawn    => 2
        }
    );
    my $item_3 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => 1,
            itype        => $itype_1->itemtype,
            withdrawn    => 3
        }
    );
    my $item_4 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => 0,
            itype        => $itype_2->itemtype,
            withdrawn    => 4
        }
    );
    my $item_5 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => 0,
            itype        => $itype_1->itemtype,
            withdrawn    => 5
        }
    );
    my $item_6 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => 2,
            itype        => $itype_1->itemtype,
            withdrawn    => 5
        }
    );

    my $rules = undef;

    my $mocked_context = Test::MockModule->new('C4::Context');
    $mocked_context->mock( 'yaml_preference', sub {
        return $rules;
    });

    t::lib::Mocks::mock_preference( 'hidelostitems', 0 );
    is( $biblio->items->filter_by_visible_in_opac->count,
        6, 'No rules passed, hidelostitems unset' );

    is( $biblio->items->filter_by_visible_in_opac({ patron => $patron })->count,
        6, 'No rules passed, hidelostitems unset, patron exception changes nothing' );

    $rules = {};

    t::lib::Mocks::mock_preference( 'hidelostitems', 1 );
    is(
        $biblio->items->filter_by_visible_in_opac->count,
        3,
        'No rules passed, hidelostitems set'
    );

    is(
        $biblio->items->filter_by_visible_in_opac({ patron => $patron })->count,
        3,
        'No rules passed, hidelostitems set, patron exception changes nothing'
    );

    $rules = { withdrawn => [ 1, 2 ] };
    is(
        $biblio->items->filter_by_visible_in_opac->count,
        2,
        'Rules on withdrawn, hidelostitems set'
    );

    is(
        $biblio->items->filter_by_visible_in_opac({ patron => $patron })->count,
        3,
        'hidelostitems set, rules on withdrawn but patron override passed'
    );

    $rules = { itype => [ $itype_1->itemtype ] };
    is(
        $biblio->items->filter_by_visible_in_opac->count,
        2,
        'Rules on itype, hidelostitems set'
    );

    $rules = { withdrawn => [ 1, 2 ], itype => [ $itype_1->itemtype ] };
    is(
        $biblio->items->filter_by_visible_in_opac->count,
        1,
        'Rules on itype and withdrawn, hidelostitems set'
    );
    is(
        $biblio->items->filter_by_visible_in_opac
          ->next->itemnumber,
        $item_4->itemnumber,
        'The right item is returned'
    );

    $rules = { withdrawn => [ 1, 2 ], itype => [ $itype_2->itemtype ] };
    is(
        $biblio->items->filter_by_visible_in_opac->count,
        1,
        'Rules on itype and withdrawn, hidelostitems set'
    );
    is(
        $biblio->items->filter_by_visible_in_opac
          ->next->itemnumber,
        $item_5->itemnumber,
        'The right item is returned'
    );

    $schema->storage->txn_rollback;
};

subtest 'filter_out_lost() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    # have a fresh biblio
    my $biblio = $builder->build_sample_biblio;
    # have 3 items on that biblio
    my $item_1 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => -1,
        }
    );
    my $item_2 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => 0,
        }
    );
    my $item_3 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => 1,
        }
    );

    is( $biblio->items->filter_out_lost->next->itemnumber, $item_2->itemnumber, 'Right item returned' );
    is( $biblio->items->filter_out_lost->count, 1, 'Only one item is not lost' );

    $schema->storage->txn_rollback;
};

subtest 'filter_out_opachiddenitems() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    # have a fresh biblio
    my $biblio = $builder->build_sample_biblio;
    # have two itemtypes
    my $itype_1 = $builder->build_object({ class => 'Koha::ItemTypes' });
    my $itype_2 = $builder->build_object({ class => 'Koha::ItemTypes' });
    # have 5 items on that biblio
    my $item_1 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itype        => $itype_1->itemtype,
            withdrawn    => 1
        }
    );
    my $item_2 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itype        => $itype_2->itemtype,
            withdrawn    => 2
        }
    );
    my $item_3 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itype        => $itype_1->itemtype,
            withdrawn    => 3
        }
    );
    my $item_4 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itype        => $itype_2->itemtype,
            withdrawn    => 4
        }
    );
    my $item_5 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itype        => $itype_1->itemtype,
            withdrawn    => 5
        }
    );
    my $item_6 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itype        => $itype_1->itemtype,
            withdrawn    => 5
        }
    );

    my $rules = undef;

    my $mocked_context = Test::MockModule->new('C4::Context');
    $mocked_context->mock( 'yaml_preference', sub {
        return $rules;
    });

    is( $biblio->items->filter_out_opachiddenitems->count, 6, 'No rules passed' );

    $rules = {};

    $rules = { withdrawn => [ 1, 2 ] };
    is( $biblio->items->filter_out_opachiddenitems->count, 4, 'Rules on withdrawn' );

    $rules = { itype => [ $itype_1->itemtype ] };
    is( $biblio->items->filter_out_opachiddenitems->count, 2, 'Rules on itype' );

    $rules = { withdrawn => [ 1, 2 ], itype => [ $itype_1->itemtype ] };
    is( $biblio->items->filter_out_opachiddenitems->count, 1, 'Rules on itype and withdrawn' );
    is( $biblio->items->filter_out_opachiddenitems->next->itemnumber,
        $item_4->itemnumber,
        'The right item is returned'
    );

    $rules = { withdrawn => [ 1, 2 ], itype => [ $itype_2->itemtype ] };
    is( $biblio->items->filter_out_opachiddenitems->count, 3, 'Rules on itype and withdrawn' );

    $schema->storage->txn_rollback;
};
