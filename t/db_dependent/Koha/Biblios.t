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

use Test::More tests => 6;
use Test::Exception;
use MARC::Field;

use C4::Items;
use C4::Biblio;
use C4::Reserves;

use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Biblios;
use Koha::Patrons;
use Koha::Subscriptions;
use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $dbh     = C4::Context->dbh;

my $builder = t::lib::TestBuilder->new;
my $patron = $builder->build( { source => 'Borrower' } );
$patron = Koha::Patrons->find( $patron->{borrowernumber} );

my $biblio = Koha::Biblio->new()->store();

my $biblioitem = $schema->resultset('Biblioitem')->new(
    {
        biblionumber => $biblio->id
    }
)->insert();

subtest 'store' => sub {
    plan tests => 1;
    is(
        Koha::Biblios->find( $biblio->biblionumber )->datecreated,
        output_pref(
            { dt => dt_from_string, dateformat => 'iso', dateonly => 1 }
        ),
        "datecreated must be set to today if not passed to the constructor"
    );
};

subtest 'holds + current_holds' => sub {
    plan tests => 5;
    C4::Reserves::AddReserve( $patron->branchcode, $patron->borrowernumber, $biblio->biblionumber );
    my $holds = $biblio->holds;
    is( ref($holds), 'Koha::Holds', '->holds should return a Koha::Holds object' );
    is( $holds->count, 1, '->holds should only return 1 hold' );
    is( $holds->next->borrowernumber, $patron->borrowernumber, '->holds should return the correct hold' );
    $holds->delete;

    # Add a hold in the future
    C4::Reserves::AddReserve( $patron->branchcode, $patron->borrowernumber, $biblio->biblionumber, undef, undef, dt_from_string->add( days => 2 ) );
    $holds = $biblio->holds;
    is( $holds->count, 1, '->holds should return future holds' );
    $holds = $biblio->current_holds;
    is( $holds->count, 0, '->current_holds should not return future holds' );
    $holds->delete;

};

subtest 'subscriptions' => sub {
    plan tests => 2;
    $builder->build(
        { source => 'Subscription', value => { biblionumber => $biblio->id } }
    );
    $builder->build(
        { source => 'Subscription', value => { biblionumber => $biblio->id } }
    );
    my $biblio        = Koha::Biblios->find( $biblio->id );
    my $subscriptions = $biblio->subscriptions;
    is( ref($subscriptions), 'Koha::Subscriptions',
        'Koha::Biblio->subscriptions should return a Koha::Subscriptions object'
    );
    is( $subscriptions->count, 2, 'Koha::Biblio->subscriptions should return the correct number of subscriptions');
};

subtest 'waiting_or_in_transit' => sub {
    plan tests => 4;
    my $biblio = $builder->build( { source => 'Biblio' } );
    my $item = $builder->build({
        source => 'Item',
        value => {
            biblionumber => $biblio->{biblionumber}
        }
    });
    my $reserve = $builder->build({
        source => 'Reserve',
        value => {
            biblionumber => $biblio->{biblionumber},
            found => undef
        }
    });

    $reserve = Koha::Holds->find($reserve->{reserve_id});
    $biblio = Koha::Biblios->find($biblio->{biblionumber});

    is($biblio->has_items_waiting_or_intransit, 0, 'Item is neither waiting nor in transit');

    $reserve->found('W')->store;
    is($biblio->has_items_waiting_or_intransit, 1, 'Item is waiting');

    $reserve->found('T')->store;
    is($biblio->has_items_waiting_or_intransit, 1, 'Item is in transit');

    my $transfer = $builder->build({
        source => 'Branchtransfer',
        value => {
            itemnumber => $item->{itemnumber},
            datearrived => undef
        }
    });
    my $t = Koha::Database->new()->schema()->resultset( 'Branchtransfer' )->find($transfer->{branchtransfer_id});
    $reserve->found(undef)->store;
    is($biblio->has_items_waiting_or_intransit, 1, 'Item has transfer');
};

subtest 'can_be_transferred' => sub {
    plan tests => 8;

    t::lib::Mocks::mock_preference('UseBranchTransferLimits', 1);
    t::lib::Mocks::mock_preference('BranchTransferLimitsType', 'itemtype');

    my $library1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library3 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $biblio = $builder->build_sample_biblio({ itemtype => 'ONLY1' });
    my ($item_bibnum, $item_bibitemnum, $itemnumber)
        = AddItem({ homebranch => $library1->branchcode, holdingbranch => $library1->branchcode }, $biblio->biblionumber);
    my $item  = Koha::Items->find($itemnumber);

    is(Koha::Item::Transfer::Limits->search({
        fromBranch => $library1->branchcode,
        toBranch => $library2->branchcode,
    })->count, 0, 'There are no transfer limits between libraries.');
    ok($biblio->can_be_transferred({ to => $library2 }),
        'Some items of this biblio can be transferred between libraries.');

    my $limit = Koha::Item::Transfer::Limit->new({
        fromBranch => $library1->branchcode,
        toBranch => $library2->branchcode,
        itemtype => $item->effective_itemtype,
    })->store;
    is(Koha::Item::Transfer::Limits->search({
        fromBranch => $library1->branchcode,
        toBranch => $library2->branchcode,
    })->count, 1, 'Given we have added a transfer limit that applies for all '
        .'of this biblio\s items,');
    is($biblio->can_be_transferred({ to => $library2 }), 0,
        'None of the items of biblio can no longer be transferred between '
        .'libraries.');
    is($biblio->can_be_transferred({ to => $library2, from => $library1 }), 0,
         'We get the same result also if we pass the from-library parameter.');
    $item->holdingbranch($library2->branchcode)->store;
    is($biblio->can_be_transferred({ to => $library2 }), 1, 'Given one of the '
         .'items is already located at to-library, then the transfer is possible.');
    $item->holdingbranch($library1->branchcode)->store;
    my ($item_bibnum2, $item_bibitemnum2, $itemnumber2)
        = AddItem({ homebranch => $library1->branchcode, holdingbranch => $library3->branchcode }, $biblio->biblionumber);
    my $item2  = Koha::Items->find($itemnumber2);
    is($biblio->can_be_transferred({ to => $library2 }), 1, 'Given we added '
        .'another item that should have no transfer limits applying on, then '
        .'the transfer is possible.');
    $item2->holdingbranch($library1->branchcode)->store;
    is($biblio->can_be_transferred({ to => $library2 }), 0, 'Given all of items'
        .' of the biblio are from same, transfer limited library, then transfer'
        .' is not possible.');
};

subtest 'custom_cover_image_url' => sub {
    plan tests => 3;

    t::lib::Mocks::mock_preference( 'CustomCoverImagesURL', 'https://my_url/{isbn}_{issn}.png' );

    my $isbn       = '0553573403 | 9780553573404 (pbk.).png';
    my $issn       = 'my_issn';
    my $marc_record = MARC::Record->new;
    my ( $biblionumber, undef ) = C4::Biblio::AddBiblio($marc_record, '');

    my $biblio = Koha::Biblios->find( $biblionumber );
    my $biblioitem = $biblio->biblioitem->set(
        { isbn => $isbn, issn => $issn });
    is( $biblio->custom_cover_image_url, "https://my_url/${isbn}_${issn}.png" );

    my $marc_024a = '710347104926';
    $marc_record->append_fields( MARC::Field->new( '024', '', '', a => $marc_024a ) );
    C4::Biblio::ModBiblio( $marc_record, $biblio->biblionumber );

    t::lib::Mocks::mock_preference( 'CustomCoverImagesURL', 'https://my_url/{024$a}.png' );
    is( $biblio->custom_cover_image_url, "https://my_url/$marc_024a.png" );

    t::lib::Mocks::mock_preference( 'CustomCoverImagesURL', 'https://my_url/{normalized_isbn}.png' );
    my $normalized_isbn = C4::Koha::GetNormalizedISBN($isbn);
    is( $biblio->custom_cover_image_url, "https://my_url/$normalized_isbn.png" );
};

$schema->storage->txn_rollback;


subtest 'pickup_locations' => sub {
    plan tests => 25;

    $schema->storage->txn_begin;

    # Cleanup database
    Koha::Holds->search->delete;
    Koha::Patrons->search->delete;
    Koha::Items->search->delete;
    Koha::Libraries->search->delete;
    $dbh->do('DELETE FROM issues');
    $dbh->do('DELETE FROM issuingrules');
    $dbh->do(
        q{INSERT INTO issuingrules (categorycode, branchcode, itemtype, reservesallowed)
        VALUES (?, ?, ?, ?)},
        {},
        '*', '*', '*', 25
    );
    $dbh->do('DELETE FROM branch_item_rules');
    $dbh->do('DELETE FROM default_branch_circ_rules');
    $dbh->do('DELETE FROM default_branch_item_rules');
    $dbh->do('DELETE FROM default_circ_rules');

    my $root1 = $builder->build_object( { class => 'Koha::Library::Groups', value => { ft_local_hold_group => 1 } } );
    my $root2 = $builder->build_object( { class => 'Koha::Library::Groups', value => { ft_local_hold_group => 1 } } );
    my $root3 = $builder->build_object( { class => 'Koha::Library::Groups', value => { ft_local_hold_group => 1 } } );

    my $library1 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );
    my $library2 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );
    my $library3 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 0 } } );
    my $library4 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );
    my $library5 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );
    my $library6 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );

    my $group1_1 = $builder->build_object( { class => 'Koha::Library::Groups', value => { parent_id => $root1->id, branchcode => $library1->branchcode } } );
    my $group1_2 = $builder->build_object( { class => 'Koha::Library::Groups', value => { parent_id => $root1->id, branchcode => $library2->branchcode } } );

    my $group2_3 = $builder->build_object( { class => 'Koha::Library::Groups', value => { parent_id => $root2->id, branchcode => $library3->branchcode } } );
    my $group2_4 = $builder->build_object( { class => 'Koha::Library::Groups', value => { parent_id => $root2->id, branchcode => $library4->branchcode } } );

    my $group3_5 = $builder->build_object( { class => 'Koha::Library::Groups', value => { parent_id => $root3->id, branchcode => $library5->branchcode } } );
    my $group3_6 = $builder->build_object( { class => 'Koha::Library::Groups', value => { parent_id => $root3->id, branchcode => $library6->branchcode } } );

    my $biblio1  = $builder->build_object( { class => 'Koha::Biblios' } );
    my $biblioitem1 = $builder->build_object( { class => 'Koha::Biblioitems', value => { biblionumber => $biblio1->biblionumber } } );
    my $biblio2  = $builder->build_object( { class => 'Koha::Biblios' } );
    my $biblioitem2 = $builder->build_object( { class => 'Koha::Biblioitems', value => { biblionumber => $biblio2->biblionumber } } );

    my $item1_1  = Koha::Item->new({
        biblionumber     => $biblio1->biblionumber,
        biblioitemnumber => $biblioitem1->biblioitemnumber,
        homebranch       => $library1->branchcode,
        holdingbranch    => $library2->branchcode,
        itype            => 'test',
        barcode          => "item11barcode",
    })->store;

    my $item1_3  = Koha::Item->new({
        biblionumber     => $biblio1->biblionumber,
        biblioitemnumber => $biblioitem1->biblioitemnumber,
        homebranch       => $library3->branchcode,
        holdingbranch    => $library4->branchcode,
        itype            => 'test',
        barcode          => "item13barcode",
    })->store;

    my $item2_2  = Koha::Item->new({
        biblionumber     => $biblio2->biblionumber,
        biblioitemnumber => $biblioitem2->biblioitemnumber,
        homebranch       => $library2->branchcode,
        holdingbranch    => $library1->branchcode,
        itype            => 'test',
        barcode          => "item22barcode",
    })->store;

    my $item2_3  = Koha::Item->new({
        biblionumber     => $biblio2->biblionumber,
        biblioitemnumber => $biblioitem2->biblioitemnumber,
        homebranch       => $library3->branchcode,
        holdingbranch    => $library3->branchcode,
        itype            => 'test',
        barcode          => "item23barcode",
    })->store;

    my $item2_4  = Koha::Item->new({
        biblionumber     => $biblio2->biblionumber,
        biblioitemnumber => $biblioitem2->biblioitemnumber,
        homebranch       => $library4->branchcode,
        holdingbranch    => $library4->branchcode,
        itype            => 'test',
        barcode          => "item24barcode",
    })->store;

    my $patron1 = $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $library1->branchcode } } );
    my $patron4 = $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $library4->branchcode } } );

    t::lib::Mocks::mock_preference('HomeOrHoldingBranch', 'homebranch');

    #Case 1: holdallowed any, hold_fulfillment_policy any
    $dbh->do(
        q{INSERT INTO default_circ_rules (holdallowed, hold_fulfillment_policy, returnbranch)
        VALUES (?,?,?)},
        {},
        2, 'any', 'any'
    );

    my @pl_1_1 = $biblio1->pickup_locations( { patron => $patron1 } );
    my @pl_1_4 = $biblio1->pickup_locations( { patron => $patron4 } );
    my @pl_2_1 = $biblio2->pickup_locations( { patron => $patron1 } );
    my @pl_2_4 = $biblio2->pickup_locations( { patron => $patron4 } );


    ok(scalar(@pl_1_1) == 5 && scalar(@pl_1_4) == 5 && scalar(@pl_2_1) == 5 && scalar(@pl_2_4) == 5, 'Returns all libraries that are pickup locations');

    #Case 2: holdallowed homebranch, hold_fulfillment_policy any, HomeOrHoldingBranch 'homebranch'
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        1, 'any'
    );

    @pl_1_1 = $biblio1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $biblio1->pickup_locations( { patron => $patron4 } );
    @pl_2_1 = $biblio2->pickup_locations( { patron => $patron1 } );
    @pl_2_4 = $biblio2->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_1) == 5 && scalar(@pl_2_4) == 5, 'Returns all libraries that are pickup locations, when item\'s hombebranch equals patron\' homebranch');
    ok(scalar(@pl_1_4) == 0 && scalar(@pl_2_1) == 0, 'Returns no pickup locations');

    #Case 3: holdallowed holdgroup, hold_fulfillment_policy any
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        3, 'any'
    );

    @pl_1_1 = $biblio1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $biblio1->pickup_locations( { patron => $patron4 } );
    @pl_2_1 = $biblio2->pickup_locations( { patron => $patron1 } );
    @pl_2_4 = $biblio2->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_1) == 5 && scalar(@pl_2_4) == 5 && scalar(@pl_1_4) == 5 && scalar(@pl_2_1) == 5, 'Returns all libraries that are pickup_locations, when item\'s hombebranch is in patron\' holdgroup');

    #Case 4: holdallowed any, hold_fulfillment_policy holdgroup
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        2, 'holdgroup'
    );

    @pl_1_1 = $biblio1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $biblio1->pickup_locations( { patron => $patron4 } );
    @pl_2_1 = $biblio2->pickup_locations( { patron => $patron1 } );
    @pl_2_4 = $biblio2->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_1) == 3 && scalar(@pl_2_4) == 3 && scalar(@pl_1_4) == 3 && scalar(@pl_2_1) == 3, 'Returns libraries in item\'s holdgroup, and that are pickup_locations');

    #Case 5: holdallowed homebranch, hold_fulfillment_policy holdgroup, HomeOrHoldingBranch 'homebranch'
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        1, 'holdgroup'
    );

    @pl_1_1 = $biblio1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $biblio1->pickup_locations( { patron => $patron4 } );
    @pl_2_1 = $biblio2->pickup_locations( { patron => $patron1 } );
    @pl_2_4 = $biblio2->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_1) == 2 && scalar(@pl_2_4) == 1, 'Returns libraries in item\'s holdgroup whose homebranch equals patron\'s homebranch, and that are pickup_locations');
    ok(scalar(@pl_1_4) == 0 && scalar(@pl_2_1) == 0, 'Returns no pickup locations');

    #Case 6: holdallowed holdgroup, hold_fulfillment_policy holdgroup
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        3, 'holdgroup'
    );

    @pl_1_1 = $biblio1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $biblio1->pickup_locations( { patron => $patron4 } );
    @pl_2_1 = $biblio2->pickup_locations( { patron => $patron1 } );
    @pl_2_4 = $biblio2->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_1) == 2 && scalar(@pl_2_1) == 2 && scalar(@pl_2_4) == 1 && scalar(@pl_1_4) == 1, 'Returns libraries in item\'s holdgroup whose homebranch is included patron\'s holdgroup, and that are pickup_locations');

    #Case 7: holdallowed any, hold_fulfillment_policy homebranch
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        2, 'homebranch'
    );

    @pl_1_1 = $biblio1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $biblio1->pickup_locations( { patron => $patron4 } );
    @pl_2_1 = $biblio2->pickup_locations( { patron => $patron1 } );
    @pl_2_4 = $biblio2->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_1) == 1 && scalar(@pl_1_4) == 1 && scalar(@pl_2_1) == 2 && scalar(@pl_2_4) == 2, 'Returns homebranch of items in biblio, that are pickup_locations');

    #Case 8: holdallowed homebranch, hold_fulfillment_policy homebranch, HomeOrHoldingBranch 'homebranch'
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        1, 'homebranch'
    );

    @pl_1_1 = $biblio1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $biblio1->pickup_locations( { patron => $patron4 } );
    @pl_2_1 = $biblio2->pickup_locations( { patron => $patron1 } );
    @pl_2_4 = $biblio2->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_1) == 1 && scalar(@pl_2_4) == 1 && $pl_1_1[0]->{branchcode} eq $library1->branchcode && $pl_2_4[0]->{branchcode} eq $library4->branchcode, 'Returns homebranch of items in biblio that equals patron\'s homebranch, and that are pickup_locations');
    ok(scalar(@pl_1_4) == 0 && scalar(@pl_2_1) == 0, 'No pickup locations returned');

    #Case 9: holdallowed holdgroup, hold_fulfillment_policy homebranch
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        3, 'homebranch'
    );

    @pl_1_1 = $biblio1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $biblio1->pickup_locations( { patron => $patron4 } );
    @pl_2_1 = $biblio2->pickup_locations( { patron => $patron1 } );
    @pl_2_4 = $biblio2->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_1) == 1 && scalar(@pl_2_1) == 1 && scalar(@pl_2_4) == 1, 'Returns homebranch of items in biblio that are within patron\'s holdgroup, and that are pickup_locations');
    ok(scalar(@pl_1_4) == 0, 'No pickup locations returned');

    #Case 10: holdallowed any, hold_fulfillment_policy holdingbranch
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        2, 'holdingbranch'
    );

    @pl_1_1 = $biblio1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $biblio1->pickup_locations( { patron => $patron4 } );
    @pl_2_1 = $biblio2->pickup_locations( { patron => $patron1 } );
    @pl_2_4 = $biblio2->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_1) == 2 && scalar(@pl_1_4) == 2 && scalar(@pl_2_1) == 2 && scalar(@pl_2_4) == 2, 'Returns holdingbranch of items in biblio, that are pickup_locations');

    #Case 11: holdallowed homebranch, hold_fulfillment_policy holdingbranch, HomeOrHoldingBranch 'homebranch'
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        1, 'holdingbranch'
    );

    @pl_1_1 = $biblio1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $biblio1->pickup_locations( { patron => $patron4 } );
    @pl_2_1 = $biblio2->pickup_locations( { patron => $patron1 } );
    @pl_2_4 = $biblio2->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_1) == 1 && scalar(@pl_2_4) == 1, 'Returns holdingbranch of items in biblio, whose homebranch equals patron\'s, and that are pickup_locations');
    ok(scalar(@pl_1_4) == 0 && scalar(@pl_2_1) == 0, 'No pickup locations returned');

    #Case 12: holdallowed holdgroup, hold_fulfillment_policy holdingbranch
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        3, 'holdingbranch'
    );

    @pl_1_1 = $biblio1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $biblio1->pickup_locations( { patron => $patron4 } );
    @pl_2_1 = $biblio2->pickup_locations( { patron => $patron1 } );
    @pl_2_4 = $biblio2->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_1) == 1 && scalar(@pl_2_4) == 1 && scalar(@pl_1_4) == 1 && scalar(@pl_2_1) == 1, 'Returns holdingbranch of items in biblio, whose homebranch are within patron\'s holdgroup, and that are pickup_locations');

    t::lib::Mocks::mock_preference('HomeOrHoldingBranch', 'holdingbranch');

    #Case 13: holdallowed homebranch, hold_fulfillment_policy any, HomeOrHoldingBranch 'holdingbranch'
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        1, 'any'
    );

    @pl_1_1 = $biblio1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $biblio1->pickup_locations( { patron => $patron4 } );
    @pl_2_1 = $biblio2->pickup_locations( { patron => $patron1 } );
    @pl_2_4 = $biblio2->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_4) == 5 && scalar(@pl_2_1) == 5 && scalar(@pl_2_4) == 5, 'Returns all libraries when item\'s holdingbranch equals patron\'s homebranch, and that are pickup_locations');
    ok(scalar(@pl_1_1) == 0, 'No pickup locations returned');

    #Case 14: holdallowed homebranch, hold_fulfillment_policy holdgroup, HomeOrHoldingBranch 'holdingbranch'
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        1, 'holdgroup'
    );

    @pl_1_1 = $biblio1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $biblio1->pickup_locations( { patron => $patron4 } );
    @pl_2_1 = $biblio2->pickup_locations( { patron => $patron1 } );
    @pl_2_4 = $biblio2->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_4) == 1 && scalar(@pl_2_1) == 2 && scalar(@pl_2_4) == 1, 'Returns libraries in item\'s holdgroup whose holdingbranch equals patron\'s homebranch, and that are pickup_locations');
    ok(scalar(@pl_1_1) == 0, 'No pickup locations returned');

    #Case 15: holdallowed homebranch, hold_fulfillment_policy homebranch, HomeOrHoldingBranch 'holdingbranch'
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        1, 'homebranch'
    );

    @pl_1_1 = $biblio1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $biblio1->pickup_locations( { patron => $patron4 } );
    @pl_2_1 = $biblio2->pickup_locations( { patron => $patron1 } );
    @pl_2_4 = $biblio2->pickup_locations( { patron => $patron4 } );

    #ok(scalar(@pl_2_4) == 1 && $pl_2_4[0]->{branchcode} eq $library4->branchcode, 'Pickup location for patron 4 and item 3 renders item\'s holding branch');
    ok(scalar(@pl_2_1) == 1 && scalar(@pl_2_4) == 1, 'Returns homebranch of items in biblio whose holdingbranch equals patron\'s homebranch, and that are pickup_locations');
    ok(scalar(@pl_1_1) == 0 && scalar(@pl_1_4) == 0, 'No pickup locations returned');

    #Case 16: holdallowed homebranch, hold_fulfillment_policy holdingbranch, HomeOrHoldingBranch 'holdingbranch'
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        1, 'holdingbranch'
    );

    @pl_1_1 = $biblio1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $biblio1->pickup_locations( { patron => $patron4 } );
    @pl_2_1 = $biblio2->pickup_locations( { patron => $patron1 } );
    @pl_2_4 = $biblio2->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_4) == 1 && scalar(@pl_2_1) == 1 && scalar(@pl_2_4) == 1, 'Returns holdingbranch of items in biblio that equals patron\'s homebranch, and that are pickup_locations');
    ok(scalar(@pl_1_1) == 0, 'No pickup locations returned');

    $schema->storage->txn_rollback;
};