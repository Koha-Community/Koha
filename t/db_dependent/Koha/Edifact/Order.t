#!/usr/bin/perl

# Copyright 2021 Joonas Kylmälä <joonas.kylmala@iki.fi>
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 4;

use Koha::Edifact::Order;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;

my $builder = t::lib::TestBuilder->new;

subtest 'beggining_of_message tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $basketno   = sprintf '%011d', '123456';
    my $edi_vendor = $builder->build(
        {
            source => 'VendorEdiAccount',
            value  => {
                standard => 'EUR',
            }
        }
    );
    my $dbic_edi_vendor = $schema->resultset('VendorEdiAccount')->find( $edi_vendor->{id} );

    my $bgm = Koha::Edifact::Order::beginning_of_message( $basketno, $dbic_edi_vendor->standard, 1 );
    is( $bgm, qq{BGM+220+$basketno+9'}, "When vendor is set to EDItEUR standard we use 220 in BGM segment" );

    $dbic_edi_vendor->update( { standard => 'BIC' } );
    $bgm = Koha::Edifact::Order::beginning_of_message( $basketno, $dbic_edi_vendor->standard, 1 );
    is( $bgm, qq{BGM+22V+$basketno+9'}, "When vendor is set to BiC standard we use 22V in BGM segment" );

    $schema->storage->txn_rollback;
};

subtest 'order_line() tests' => sub {

    # TODO: Split up order_line() to smaller methods in order
    #       to allow better testing
    plan tests => 27;

    $schema->storage->txn_begin;

    my $biblio     = $builder->build_sample_biblio();
    my $biblioitem = $biblio->biblioitem;
    $biblioitem->update( { isbn => '979-8572072303' } );
    my $biblioitem_itype = $biblioitem->itemtype;

    my $item1 = $builder->build_sample_item(
        {
            biblionumber   => $biblio->biblionumber,
            location       => 'PROCESSING',
            ccode          => 'COLLECTION',
            itemcallnumber => '000.101'
        }
    );
    my $item1_homebranch = $item1->homebranch;
    my $item1_itype      = $item1->effective_itemtype;
    my $item2            = $builder->build_sample_item(
        {
            biblionumber   => $biblio->biblionumber,
            location       => 'PROCESSING',
            ccode          => 'COLLECTION',
            itemcallnumber => '000.102'
        }
    );
    my $item2_homebranch = $item2->homebranch;
    my $item2_itype      = $item2->effective_itemtype;

    my $ean      = $builder->build( { source => 'EdifactEan' } );
    my $dbic_ean = $schema->resultset('EdifactEan')->find( $ean->{ee_id} );
    my $order    = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                biblionumber     => $biblio->biblionumber,
                quantity         => 2,
                line_item_id     => 'EDILINEID1',
                order_vendornote => 'A not so pretty note',
                listprice        => '1.50'
            }
        }
    );
    my $ordernumber          = $order->ordernumber;
    my $supplier_qualifier   = $order->suppliers_reference_qualifier;
    my $supplier_ordernumber = $order->suppliers_reference_number;
    my $budgetcode           = $order->fund->budget_code;
    my $deliveryplace        = $order->basket->deliveryplace;
    $order->add_item( $item1->itemnumber );
    $order->add_item( $item2->itemnumber );

    my $vendor = $builder->build(
        {
            source => 'VendorEdiAccount',
            value  => {
                vendor_id => $order->basket->bookseller->id,
            }
        }
    );
    my $dbic_vendor = $schema->resultset('VendorEdiAccount')->find( $vendor->{id} );

    my @orders = $schema->resultset('Aqorder')->search( { basketno => $order->basket->basketno } )->all;

    my $edi_order = Koha::Edifact::Order->new(
        {
            orderlines => \@orders,
            vendor     => $dbic_vendor,
            ean        => $dbic_ean
        }
    );

    # FIXME: Add test for an order where the attached biblio has been deleted.

    # Set EdifactLSQ field to default
    t::lib::Mocks::mock_preference( 'EdifactLSQ', 'location' );

    $order->basket->create_items('ordering')->store;
    is(
        $edi_order->order_line( 1, $orders[0] ),
        undef, 'order_line run for message formed with effective_create_items = "ordering"'
    );

    my $segs = $edi_order->{segs};
    is( $segs->[0], 'LIN+1++EDILINEID1:EN\'',            'LIN segment added containing order->line_item_id' );
    is( $segs->[1], 'PIA+5+8572072303:IB\'',             'PIA segment added with example biblioitem->isbn13' );
    is( $segs->[2], 'IMD+L+009+:::Some boring author\'', 'IMD segment added containing demo data author' );
    is( $segs->[3], 'IMD+L+050+:::Some boring read\'',   'IMD segment added containing demo data title' );
    is( $segs->[4], 'QTY+21:2\'',                        'QTY segment added containing the number of items expected' );
    is(
        $segs->[5],
        'GIR+001'
            . "+$budgetcode:LFN"
            . "+$item1_homebranch:LLO"
            . "+$item1_itype:LST"
            . "+PROCESSING:LSQ"
            . "+000.101:LSM" . "'",
        'GIR segment added for first item and contains item record data'
    );
    is(
        $segs->[6],
        'GIR+002'
            . "+$budgetcode:LFN"
            . "+$item2_homebranch:LLO"
            . "+$item2_itype:LST"
            . "+PROCESSING:LSQ"
            . "+000.102:LSM" . "'",
        'GIR segment added for second item and contains item record data'
    );
    is( $segs->[7], 'FTX+LIN+++A not so pretty note\'', 'FTX segment added containing data from vendor_note' );
    is( $segs->[8], 'PRI+AAE:1.50:CA\'',                'PRI segment added containing data orderline listprice' );
    is( $segs->[9], "RFF+LI:$ordernumber'",             'RFF segment added containing koha orderline id' );
    is(
        $segs->[10], "RFF+$supplier_qualifier:$supplier_ordernumber'",
        'RFF segment added containing supplier orderline id'
    );

    # Reset segments for effective_create_items = 'receiving'
    $edi_order->{segs} = [];

    $order->basket->create_items('receiving')->store;
    is(
        $edi_order->order_line( 1, $orders[0] ),
        undef, 'order_line run for message formed with effective_create_items = "receiving"'
    );

    $segs = $edi_order->{segs};
    is( $segs->[0], 'LIN+1++EDILINEID1:EN\'',            'LIN segment added containing order->line_item_id' );
    is( $segs->[1], 'PIA+5+8572072303:IB\'',             'PIA segment added with example biblioitem->isbn13' );
    is( $segs->[2], 'IMD+L+009+:::Some boring author\'', 'IMD segment added containing demo data author' );
    is( $segs->[3], 'IMD+L+050+:::Some boring read\'',   'IMD segment added containing demo data title' );
    is( $segs->[4], 'QTY+21:2\'',                        'QTY segment added containing the number of items expected' );
    is(
        $segs->[5],
        'GIR+001' . "+$budgetcode:LFN" . "+$deliveryplace:LLO" . "+$biblioitem_itype:LST" . "'",
        'GIR segment added for first item and contains biblioitem data'
    );
    is(
        $segs->[6],
        'GIR+002' . "+$budgetcode:LFN" . "+$deliveryplace:LLO" . "+$biblioitem_itype:LST" . "'",
        'GIR segment added for second item and contains biblioitem data'
    );
    is( $segs->[7], 'FTX+LIN+++A not so pretty note\'', 'FTX segment added containing data from vendor_note' );
    is( $segs->[8], 'PRI+AAE:1.50:CA\'',                'PRI segment added containing data orderline listprice' );
    is( $segs->[9], "RFF+LI:$ordernumber'",             'RFF segment added containing koha orderline id' );
    is(
        $segs->[10], "RFF+$supplier_qualifier:$supplier_ordernumber'",
        'RFF segment added containing supplier orderline id'
    );

    # Reset segments for testing EdifactLSQ preference
    $edi_order->{segs} = [];

    # Set EdifactLSQ field to ccode
    t::lib::Mocks::mock_preference( 'EdifactLSQ', 'ccode' );

    $order->basket->create_items('ordering')->store;
    is(
        $edi_order->order_line( 1, $orders[0] ),
        undef, 'order_line run for message formed with EdifactLSQ = "ccode"'
    );

    $segs = $edi_order->{segs};
    is(
        $segs->[5],
        'GIR+001'
            . "+$budgetcode:LFN"
            . "+$item1_homebranch:LLO"
            . "+$item1_itype:LST"
            . "+COLLECTION:LSQ"
            . "+000.101:LSM" . "'",
        'GIR segment added for first item and contains item ccode data'
    );
    is(
        $segs->[6],
        'GIR+002'
            . "+$budgetcode:LFN"
            . "+$item2_homebranch:LLO"
            . "+$item2_itype:LST"
            . "+COLLECTION:LSQ"
            . "+000.102:LSM" . "'",
        'GIR segment added for second item and contains item ccode data'
    );

    $schema->storage->txn_rollback;
};

subtest 'filename() tests' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my $ean    = $builder->build( { source => 'EdifactEan' } );
    my $order  = $builder->build_object( { class => 'Koha::Acquisition::Orders' } );
    my $vendor = $builder->build(
        {
            source => 'VendorEdiAccount',
            value  => { vendor_id => $order->basket->bookseller->id }
        }
    );

    my @orders = $schema->resultset('Aqorder')->search( { basketno => $order->basket->basketno } )->all;

    my $edi_order = Koha::Edifact::Order->new(
        {
            orderlines => \@orders,
            vendor     => $vendor,
            ean        => $ean
        }
    );

    my $expected_filename = 'ordr' . $order->basket->basketno . '.CEP';
    is(
        $edi_order->filename, $expected_filename,
        'Filename is formed from the basket number'
    );

    $schema->storage->txn_rollback;
};
