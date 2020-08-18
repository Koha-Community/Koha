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

use Test::More tests => 11;
use Test::Exception;
use Time::Fake;

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

    subtest '*_on updates' => sub {
        plan tests => 9;

        # Once the '_on' value is set (triggered by the related field turning from false to true)
        # it should not be re-set for any changes outside of the related field being 'unset'.

        my @fields = qw( itemlost withdrawn damaged );
        my $today = dt_from_string();
        my $yesterday = $today->clone()->subtract( days => 1 );

        for my $field ( @fields ) {
            my $item = $builder->build_sample_item(
                {
                    itemlost     => 0,
                    itemlost_on  => undef,
                    withdrawn    => 0,
                    withdrawn_on => undef,
                    damaged      => 0,
                    damaged_on   => undef
                }
            );
            my $field_on = $field . '_on';

            # Set field for the first time
            Time::Fake->offset( $yesterday->epoch );
            $item->$field(1)->store;
            $item->get_from_storage;
            is($item->$field_on, DateTime::Format::MySQL->format_datetime($yesterday), $field_on . " was set upon first truthy setting");

            # Update the field to a new 'true' value
            Time::Fake->offset( $today->epoch );
            $item->$field(2)->store;
            $item->get_from_storage;
            is($item->$field_on, DateTime::Format::MySQL->format_datetime($yesterday), $field_on . " was not updated upon second truthy setting");

            # Update the field to a new 'false' value
            $item->$field(0)->store;
            $item->get_from_storage;
            is($item->$field_on, undef, $field_on . " was unset upon untruthy setting");

            Time::Fake->reset;
        }
    };

};

subtest 'get_transfer' => sub {
    plan tests => 3;

    my $transfer = $new_item_1->get_transfer();
    is( $transfer, undef, 'Koha::Item->get_transfer should return undef if the item is not in transit' );

    my $library_to = $builder->build( { source => 'Branch' } );

    C4::Circulation::transferbook({
        from_branch => $new_item_1->holdingbranch,
        to_branch => $library_to->{branchcode},
        barcode => $new_item_1->barcode,
    });

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

# Reset nb_of_items prior to testing delete
$nb_of_items = Koha::Items->search->count;

# Test delete
$retrieved_item_1->delete;
is( Koha::Items->search->count, $nb_of_items - 1, 'Delete should have deleted the item' );

$schema->storage->txn_rollback;
