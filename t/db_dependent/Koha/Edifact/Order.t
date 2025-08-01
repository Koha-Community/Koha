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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 6;

use Koha::Edifact::Order;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;

my $builder = t::lib::TestBuilder->new;

subtest 'beggining_of_message tests' => sub {
    plan tests => 3;

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

    # Test BGM with purchase order number
    my $purchase_order_number = 'PO123456789';
    $bgm =
        Koha::Edifact::Order::beginning_of_message( $basketno, $dbic_edi_vendor->standard, 1, $purchase_order_number );
    is(
        $bgm, qq{BGM+22V+$purchase_order_number+9'},
        "When purchase order number provided, it's used in BGM segment instead of basketno"
    );

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

    # Ensure EdifactLSL is empty to maintain backwards compatibility
    t::lib::Mocks::mock_preference( 'EdifactLSL', '' );

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

    # Ensure EdifactLSL is empty to maintain backwards compatibility
    t::lib::Mocks::mock_preference( 'EdifactLSL', '' );

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

    my $dbic_vendor = $schema->resultset('VendorEdiAccount')->find( $vendor->{id} );

    my $edi_order = Koha::Edifact::Order->new(
        {
            orderlines => \@orders,
            vendor     => $dbic_vendor,
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

subtest 'RFF+ON purchase order number generation' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    # Create vendor with po_is_basketname set to true
    my $vendor_po = $builder->build(
        {
            source => 'VendorEdiAccount',
            value  => {
                description      => 'Test vendor PO mode',
                po_is_basketname => 1,
                standard         => 'EUR',
            }
        }
    );

    # Create vendor with po_is_basketname set to false (default)
    my $vendor_filename = $builder->build(
        {
            source => 'VendorEdiAccount',
            value  => {
                description      => 'Test vendor filename mode',
                po_is_basketname => 0,
                standard         => 'EUR',
            }
        }
    );

    # Create baskets with different naming schemes
    my $basket_po = $builder->build(
        {
            source => 'Aqbasket',
            value  => {
                basketname   => 'PO123456789',             # Purchase order number
                booksellerid => $vendor_po->{vendor_id},
            }
        }
    );

    my $basket_filename = $builder->build(
        {
            source => 'Aqbasket',
            value  => {
                basketname   => 'quote_file.ceq',                # Filename
                booksellerid => $vendor_filename->{vendor_id},
            }
        }
    );

    # Create biblio records for the orders
    my $biblio_po       = $builder->build_sample_biblio();
    my $biblio_filename = $builder->build_sample_biblio();

    # Create orders for the baskets
    my $order_po = $builder->build(
        {
            source => 'Aqorder',
            value  => {
                basketno     => $basket_po->{basketno},
                biblionumber => $biblio_po->biblionumber,
                orderstatus  => 'new',
                quantity     => 1,
                listprice    => '10.00',
            }
        }
    );

    my $order_filename = $builder->build(
        {
            source => 'Aqorder',
            value  => {
                basketno     => $basket_filename->{basketno},
                biblionumber => $biblio_filename->biblionumber,
                orderstatus  => 'new',
                quantity     => 1,
                listprice    => '10.00',
            }
        }
    );

    # Create EAN object
    my $ean = $builder->build(
        {
            source => 'EdifactEan',
            value  => { ean => '1234567890123' }
        }
    );

    # Get database objects
    my $dbic_vendor_po       = $schema->resultset('VendorEdiAccount')->find( $vendor_po->{id} );
    my $dbic_vendor_filename = $schema->resultset('VendorEdiAccount')->find( $vendor_filename->{id} );
    my $dbic_ean             = $schema->resultset('EdifactEan')->find( $ean->{ee_id} );
    my @orderlines_po        = $schema->resultset('Aqorder')->search( { basketno => $basket_po->{basketno} } );
    my @orderlines_filename  = $schema->resultset('Aqorder')->search( { basketno => $basket_filename->{basketno} } );

    # Test order generation with purchase order number
    my $order_obj_po = Koha::Edifact::Order->new(
        {
            orderlines => \@orderlines_po,
            vendor     => $dbic_vendor_po,
            ean        => $dbic_ean,
        }
    );

    # Test order generation with filename
    my $order_obj_filename = Koha::Edifact::Order->new(
        {
            orderlines => \@orderlines_filename,
            vendor     => $dbic_vendor_filename,
            ean        => $dbic_ean,
        }
    );

    # Test that purchase order number is extracted correctly
    is(
        $order_obj_po->purchase_order_number, 'PO123456789',
        'Purchase order number extracted from basket name when vendor configured for PO mode'
    );

    # Test that no purchase order number is extracted when vendor uses filename mode
    is(
        $order_obj_filename->purchase_order_number, undef,
        'No purchase order number when vendor configured for filename mode'
    );

    # Test that purchase order number is included in BGM segment when purchase order number present
    my $transmission = $order_obj_po->encode();
    like(
        $transmission, qr/BGM\+220\+PO123456789\+9'/,
        'Purchase order number included in BGM segment when purchase order number present'
    );

    $schema->storage->txn_rollback;
};

subtest 'gir_segments() with LSL and LSQ preferences' => sub {
    plan tests => 20;

    $schema->storage->txn_begin;

    # Test LSL and LSQ preferences
    t::lib::Mocks::mock_preference( 'EdifactLSQ', 'location' );
    t::lib::Mocks::mock_preference( 'EdifactLSL', 'ccode' );

    # Create test items with both location and ccode
    my @test_items = (
        {
            branchcode     => 'BRANCH1',
            itype          => 'BOOK',
            itemcallnumber => 'CALL1',
            location       => 'FICTION',    # Will be used for LSQ
            ccode          => 'ADULT',      # Will be used for LSL
        },
        {
            branchcode     => 'BRANCH2',
            itype          => 'DVD',
            itemcallnumber => 'CALL2',
            location       => 'MEDIA',      # Will be used for LSQ
            ccode          => 'CHILD',      # Will be used for LSL
        }
    );

    my $params = {
        ol_fields => { budget_code => 'FUND123' },
        items     => \@test_items
    };

    my @segments = Koha::Edifact::Order::gir_segments($params);

    ok( scalar @segments >= 2, 'At least two segments created for two items' );

    # Check first item's GIR segment (segments are strings in EDI format)
    my $first_gir = $segments[0];
    ok( $first_gir, 'First segment exists' );

    # Check that the segment contains expected data
    like( $first_gir, qr/GIR/,         'Segment contains GIR tag' );
    like( $first_gir, qr/FUND123:LFN/, 'Budget code included in first segment' );
    like( $first_gir, qr/BRANCH1:LLO/, 'Branch code included in first segment' );
    like( $first_gir, qr/BOOK:LST/,    'Item type included in first segment' );
    like( $first_gir, qr/FICTION:LSQ/, 'LSQ field contains location value' );
    like( $first_gir, qr/ADULT:LSL/,   'LSL field contains collection code value' );

    # Test reversed preferences
    t::lib::Mocks::mock_preference( 'EdifactLSQ', 'ccode' );       # LSQ -> collection
    t::lib::Mocks::mock_preference( 'EdifactLSL', 'location' );    # LSL -> location

    my @test_items_rev = (
        {
            branchcode     => 'BRANCH3',
            itype          => 'BOOK',
            itemcallnumber => 'CALL3',
            location       => 'REFERENCE',    # Will be used for LSL
            ccode          => 'RARE',         # Will be used for LSQ
        }
    );

    my $params_rev = {
        ol_fields => { budget_code => 'FUND456' },
        items     => \@test_items_rev
    };

    @segments = Koha::Edifact::Order::gir_segments($params_rev);
    my $gir_rev = $segments[0];

    # Check that the segment contains expected reversed mappings
    like( $gir_rev, qr/RARE:LSQ/,      'LSQ field contains collection code when preference is ccode' );
    like( $gir_rev, qr/REFERENCE:LSL/, 'LSL field contains location when preference is location' );

    # Test with one preference empty
    t::lib::Mocks::mock_preference( 'EdifactLSQ', 'location' );
    t::lib::Mocks::mock_preference( 'EdifactLSL', '' );           # Empty = ignore

    @segments = Koha::Edifact::Order::gir_segments($params);
    my $gir_partial = $segments[0];

    like( $gir_partial, qr/FICTION:LSQ/, 'LSQ field included when preference is set' );
    unlike( $gir_partial, qr/:LSL/, 'LSL field not included when preference is empty' );

    # Test with both preferences empty
    t::lib::Mocks::mock_preference( 'EdifactLSQ', '' );
    t::lib::Mocks::mock_preference( 'EdifactLSL', '' );

    @segments = Koha::Edifact::Order::gir_segments($params);
    my $gir_empty = $segments[0];

    unlike( $gir_empty, qr/:LSQ/, 'LSQ field not included when preference is empty' );
    unlike( $gir_empty, qr/:LSL/, 'LSL field not included when preference is empty' );

    # Test with LSQ empty but LSL set
    t::lib::Mocks::mock_preference( 'EdifactLSQ', '' );         # Empty = ignore
    t::lib::Mocks::mock_preference( 'EdifactLSL', 'ccode' );    # LSL -> collection

    @segments = Koha::Edifact::Order::gir_segments($params);
    my $gir_lsl_only = $segments[0];

    unlike( $gir_lsl_only, qr/:LSQ/, 'LSQ field not included when preference is empty' );
    like( $gir_lsl_only, qr/ADULT:LSL/, 'LSL field included when preference is set' );

    # Test with both preferences set to same field (location)
    t::lib::Mocks::mock_preference( 'EdifactLSQ', 'location' );    # LSQ -> location
    t::lib::Mocks::mock_preference( 'EdifactLSL', 'location' );    # LSL -> location

    @segments = Koha::Edifact::Order::gir_segments($params);
    my $gir_both_location = $segments[0];

    like( $gir_both_location, qr/FICTION:LSQ/, 'LSQ field contains location value when both map to location' );
    like( $gir_both_location, qr/FICTION:LSL/, 'LSL field contains location value when both map to location' );

    # Test with both preferences set to same field (ccode)
    t::lib::Mocks::mock_preference( 'EdifactLSQ', 'ccode' );       # LSQ -> collection
    t::lib::Mocks::mock_preference( 'EdifactLSL', 'ccode' );       # LSL -> collection

    @segments = Koha::Edifact::Order::gir_segments($params);
    my $gir_both_ccode = $segments[0];

    like( $gir_both_ccode, qr/ADULT:LSQ/, 'LSQ field contains collection code value when both map to ccode' );
    like( $gir_both_ccode, qr/ADULT:LSL/, 'LSL field contains collection code value when both map to ccode' );

    $schema->storage->txn_rollback;
};
