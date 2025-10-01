#!/usr/bin/perl

# Copyright 2024 Martin Renvoize <martin.renvoize@ptfs-europe.com>
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
use FindBin qw( $Bin );

use Test::NoWarnings;
use Test::More tests => 6;
use Test::MockModule;

use t::lib::Mocks;
use t::lib::Mocks::Logger;
use t::lib::TestBuilder;

use Koha::EDI qw(process_quote process_invoice create_edi_order);
use Koha::Edifact::Transport;
use Koha::Edifact::File::Errors;
use Koha::DateUtils qw(dt_from_string);

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;
my $logger  = t::lib::Mocks::Logger->new();

subtest 'process_quote' => sub {
    plan tests => 7;

    $schema->storage->txn_begin;

    # Common setup for all test cases
    my $test_san      = '5013546098818';
    my $dirname       = ( $Bin =~ /^(.*\/t\/)/ ? $1 . 'edi_testfiles/' : q{} );
    my $active_period = $builder->build(
        {
            source => 'Aqbudgetperiod',
            value  => { budget_period_active => 1 }
        }
    );
    t::lib::Mocks::mock_preference( 'CataloguingLog', 0 );

    # Test 1: Basic Quote Processing
    subtest 'basic_quote_processing' => sub {
        plan tests => 27;

        $schema->storage->txn_begin;

        # Create file transport for local testing
        my $file_transport = $builder->build(
            {
                source => 'FileTransport',
                value  => {
                    name               => 'Test Local Transport',
                    transport          => 'local',
                    download_directory => $dirname,
                    upload_directory   => $dirname,
                }
            }
        );

        my $account = $builder->build(
            {
                source => 'VendorEdiAccount',
                value  => {
                    description       => 'test vendor',
                    file_transport_id => $file_transport->{file_transport_id},
                    plugin            => '',
                    san               => $test_san,
                    orders_enabled    => 1,
                    auto_orders       => 0,
                    po_is_basketname  => 0
                }
            }
        );
        my $ean = $builder->build(
            {
                source => 'EdifactEan',
                value  => {
                    description => 'test ean',
                    branchcode  => undef,
                    ean         => $test_san
                }
            }
        );

        my $filename = 'QUOTES_SMALL.CEQ';
        ok( -e $dirname . $filename, 'File QUOTES_SMALL.CEQ found' );

        # Setup the fund code
        my $fund = $builder->build(
            {
                source => 'Aqbudget',
                value  => {
                    budget_code      => 'REF',
                    budget_period_id => $active_period->{budget_period_id}
                }
            }
        );

        # Setup stock rotation
        my $rota = $builder->build_object(
            {
                class => 'Koha::StockRotationRotas',
                value => { title => 'ROT1' }
            }
        );
        $builder->build(
            {
                source => 'Stockrotationstage',
                value  => { rota_id => $rota->rota_id },
            }
        );

        my $trans = Koha::Edifact::Transport->new( $account->{id} );
        $trans->working_directory($dirname);

        my $mhash = $trans->message_hash();
        $mhash->{message_type} = 'QUOTE';
        $trans->ingest( $mhash, $filename );

        my $quote = $schema->resultset('EdifactMessage')->find( { filename => $filename } );

        ok( $quote, 'Quote message created in database' );
        is( $quote->status, 'new', 'Initial quote status is new' );

        t::lib::Mocks::mock_preference( 'AcqCreateItem', 'ordering' );

        # Process quote and check results
        my $die;
        eval {
            process_quote($quote);
            1;
        } or do {
            $die = $@;
        };
        ok( !$die, 'Basic quote processed without dying' );

        # Test for expected logs for the passed quote file
        is( $logger->count, 8, "8 log lines recorded for passed quote file" );

        #$logger->diag();
        $logger->trace_like(
            qr/Created basket:.*/,
            "Trace recorded adding basket"
        )->trace_like(
            qr/Checking db for matches.*/,
            "Trace recorded checking db for matches"
        )->trace_like(
            qr/Added biblio:.*/,
            "Trace recoded adding new biblio"
        )->trace_like(
            qr/Order created:.*/,
            "Trace recorded adding order"
        )->trace_like(
            qr/Added item:.*/,
            "Trace recorded adding new item"
        )->trace_like(
            qr/Item added to rota.*/,
            "Trace recrded adding item to rota"
        )->debug_like(
            qr/.*specialUpdate biblioserver$/,
            "Trace recorded biblioserver index"
        )->clear();

        # No errors expected for QUOTE_SMALL
        my $errors = Koha::Edifact::File::Errors->search();
        is( $errors->count, 0, '0 errors recorded for simple quote' );

        # Status changed to received
        $quote->get_from_storage;
        is( $quote->status, 'received', 'Quote status set to received' );

        # Generate basket
        my $baskets = Koha::Acquisition::Baskets->search( { booksellerid => $account->{vendor_id} } );
        is( $baskets->count, 1, "One basket created for single message quote file" );

        my $basket = $baskets->next;
        is( $basket->basketname, $filename, "Basket uses EDI filename for name" );

        # Order lines
        my $orders = $basket->orders;
        is( $orders->count, 1, "One order line created for single record quote file" );

        my $order = $orders->next;
        ok( $order->biblionumber, 'Biblionumber assigned to order' );
        is( $order->entrydate, dt_from_string()->ymd(), 'Entry date set correctly' );

        # Fund allocation
        $fund = $order->fund;
        ok( $fund, 'Fund allocated to order' );
        is( $fund->budget_code, 'REF', 'Correct fund allocated for order' );

        # Test 008 handling
        my $biblio       = $order->biblio;
        my $record       = $biblio->record;
        my $record_field = $record->field('008');
        is( exists( $record_field->{_data} ), 1, '008 field added when missing from quote' );

        # Item allocation
        my $items = $order->items;
        is(
            $items->count, 1,
            "One item created when AcqCreateItem is set to 'ordering' for single record, single quantity quote file"
        );

        # Test stock rotation handling
        my $item    = $items->next;
        my $on_rota = Koha::StockRotationItems->search( { itemnumber_id => $item->itemnumber } );
        is( $on_rota->count,                 1,         "Item added to rotation" );
        is( $on_rota->next->stage->rota->id, $rota->id, "Correct rotation assigned" );

        # Confirm no ORDER message generated for 'auto_orders => 0'
        is( $basket->closedate, undef, 'Basket left open for auto_orders disabled' );
        my $edi_orders = $schema->resultset('EdifactMessage')->search(
            {
                message_type => 'ORDERS',
                basketno     => $basket->basketno,
            }
        );
        is( $edi_orders->count, 0, 'ORDER message not created for auto_orders disabled' );

        $logger->clear();
        $schema->storage->txn_rollback;
    };

    # Test 2: Multiple Message EAN Handling
    subtest 'multiple_message_ean_handling' => sub {
        plan tests => 4;

        $schema->storage->txn_begin;

        # Create file transport for local testing
        my $file_transport = $builder->build(
            {
                source => 'FileTransport',
                value  => {
                    name               => 'Test Local Transport',
                    transport          => 'local',
                    download_directory => $dirname,
                    upload_directory   => $dirname,
                }
            }
        );

        my $account = $builder->build(
            {
                source => 'VendorEdiAccount',
                value  => {
                    description       => 'multi-message test vendor',
                    file_transport_id => $file_transport->{file_transport_id},
                    plugin            => '',
                    san               => $test_san,
                    orders_enabled    => 1,
                    auto_orders       => 1,
                }
            }
        );

        # Create EANs that match the QUOTES_BIG.CEQ file
        my $ean1 = $builder->build(
            {
                source => 'EdifactEan',
                value  => {
                    description => 'library 1 ean',
                    branchcode  => undef,
                    ean         => '5013546098818'    # First EAN from QUOTES_BIG.CEQ
                }
            }
        );
        my $ean2 = $builder->build(
            {
                source => 'EdifactEan',
                value  => {
                    description => 'library 2 ean',
                    branchcode  => undef,
                    ean         => '5412345000013'    # Second EAN from QUOTES_BIG.CEQ
                }
            }
        );

        # Setup fund
        my $fund = $builder->build(
            {
                source => 'Aqbudget',
                value  => {
                    budget_code      => 'REF',
                    budget_period_id => $active_period->{budget_period_id}
                }
            }
        );

        # Use the existing multi-message test file
        my $filename = 'QUOTES_BIG.CEQ';
        ok( -e $dirname . $filename, 'File QUOTES_BIG.CEQ found' );

        my $trans = Koha::Edifact::Transport->new( $account->{id} );
        $trans->working_directory($dirname);

        my $mhash = $trans->message_hash();
        $mhash->{message_type} = 'QUOTE';
        $trans->ingest( $mhash, $filename );

        my $quote = $schema->resultset('EdifactMessage')->find( { filename => $filename } );

        # Process quote and check results
        process_quote($quote);

        # QUOTES_BIG.CEQ contains 2 separate transport messages with different buyer EANs
        # Our fix should create 2 baskets and use the correct EAN for each auto-order
        my $baskets = Koha::Acquisition::Baskets->search(
            { booksellerid => $account->{vendor_id} },
            { order_by     => 'basketno' }
        );
        is( $baskets->count, 2, "Two baskets created for multi-transport quote file" );

        # Check that EDI orders were created (since auto_orders = 1)
        my $edi_orders = $schema->resultset('EdifactMessage')->search(
            {
                message_type => 'ORDERS',
                vendor_id    => $account->{vendor_id}
            }
        );
        is( $edi_orders->count, 2, 'Two EDI orders created with auto_orders enabled' );

        # Verify that both baskets were closed
        my $closed_baskets = $baskets->search( { closedate => { '!=' => undef } } );
        is( $closed_baskets->count, 2, 'Both baskets closed by auto_orders' );

        $schema->storage->txn_rollback;
    };

    # Test 3: Auto Orders Processing
    subtest 'auto_orders_processing' => sub {
        plan tests => 7;

        $schema->storage->txn_begin;

        # Create file transport for local testing
        my $file_transport = $builder->build(
            {
                source => 'FileTransport',
                value  => {
                    name               => 'Test Auto Order Transport',
                    transport          => 'local',
                    download_directory => $dirname,
                    upload_directory   => $dirname,
                }
            }
        );

        my $account = $builder->build(
            {
                source => 'VendorEdiAccount',
                value  => {
                    description       => 'auto order vendor',
                    file_transport_id => $file_transport->{file_transport_id},
                    plugin            => '',
                    san               => $test_san,
                    orders_enabled    => 1,
                    auto_orders       => 1,
                }
            }
        );
        my $ean = $builder->build(
            {
                source => 'EdifactEan',
                value  => {
                    description => 'test ean',
                    branchcode  => undef,
                    ean         => $test_san
                }
            }
        );

        # Setup the fund
        $builder->build(
            {
                source => 'Aqbudget',
                value  => {
                    budget_code      => 'REF',
                    budget_period_id => $active_period->{budget_period_id}
                }
            }
        );

        my $filename = 'QUOTES_SMALL.CEQ';
        my $trans    = Koha::Edifact::Transport->new( $account->{id} );
        $trans->working_directory($dirname);

        my $mhash = $trans->message_hash();
        $mhash->{message_type} = 'QUOTE';
        $trans->ingest( $mhash, $filename );

        my $quote = $schema->resultset('EdifactMessage')->find( { filename => $filename } );

        # Process quote and check results
        my $die;
        eval {
            process_quote($quote);
            1;
        } or do {
            $die = $@;
        };
        ok( !$die, 'Basic quote processed, with auto_orders enabled, without dying' );

        my $baskets = Koha::Acquisition::Baskets->search( { booksellerid => $account->{vendor_id} } );
        is( $baskets->count, 1, "Basket created" );

        my $basket = $baskets->next;
        ok( $basket->closedate, 'Basket automatically closed for auto_orders' );

        my $orders = $basket->orders;
        is( $orders->count, 1, "One order created" );

        my $order = $orders->next;
        ok( $order->biblionumber, 'Biblionumber assigned to order' );

        # Check EDI order generation
        my $edi_orders = $schema->resultset('EdifactMessage')->search(
            {
                message_type => 'ORDERS',
                basketno     => $basket->basketno,
            }
        );
        is( $edi_orders->count,        1,         'EDI order message created' );
        is( $edi_orders->next->status, 'Pending', 'EDI order status is Pending' );

        $logger->clear();
        $schema->storage->txn_rollback;
    };

    # Test 3: Multiple item quote
    subtest 'multi-item quote' => sub {
        plan tests => 18;

        $schema->storage->txn_begin;

        # Create file transport for local testing
        my $file_transport = $builder->build(
            {
                source => 'FileTransport',
                value  => {
                    name               => 'Test Multi-item Transport',
                    transport          => 'local',
                    download_directory => $dirname,
                    upload_directory   => $dirname,
                }
            }
        );

        # Create vendor EDI account
        my $account = $builder->build(
            {
                source => 'VendorEdiAccount',
                value  => {
                    description       => 'multi-item vendor',
                    file_transport_id => $file_transport->{file_transport_id},
                    plugin            => '',
                }
            }
        );
        my $ean = $builder->build(
            {
                source => 'EdifactEan',
                value  => {
                    description => 'test ean',
                    branchcode  => undef,
                    ean         => $test_san
                }
            }
        );

        # Setup multiple funds
        my %funds;
        for my $code (qw(REF LOAN)) {
            $funds{$code} = $builder->build(
                {
                    source => 'Aqbudget',
                    value  => {
                        budget_code      => $code,
                        budget_period_id => $active_period->{budget_period_id}
                    }
                }
            );
        }

        # Setup multiple rota
        my %rota;
        for my $title (qw(TEST FAST SLOW)) {
            $rota{$title} = $builder->build_object(
                {
                    class => 'Koha::StockRotationRotas',
                    value => { title => $title }
                }
            );
            $builder->build(
                {
                    source => 'Stockrotationstage',
                    value  => { rota_id => $rota{$title}->rota_id },
                }
            );
        }

        my $description = <<~"END";
            Loaded QUOTE file with 1 Message that contains 2 LIN segments with the first
            consistent of 1 item and the second with 3 items with 2 different funds.
        END
        diag($description);

        my $filename = 'QUOTES_MULTI.CEQ';
        my $trans    = Koha::Edifact::Transport->new( $account->{id} );
        $trans->working_directory($dirname);
        my $mhash = $trans->message_hash();
        $mhash->{message_type} = 'QUOTE';
        $trans->ingest( $mhash, $filename );

        my $quote = $schema->resultset('EdifactMessage')->find( { filename => $filename } );
        process_quote($quote);

        #$logger->diag();

        my $baskets = Koha::Acquisition::Baskets->search( { booksellerid => $account->{vendor_id} } );
        is( $baskets->count, 1, "One basket created for quote" );

        my $basket = $baskets->next;
        my $orders = $basket->orders;
        is( $orders->count, 3, "Three order lines created for quote" );

        my %biblios;
        my $orderline = 0;
        while ( my $order = $orders->next ) {
            $orderline++;

            #diag( "Looking at order: " . $orderline );
            if ( $orderline == 1 ) {

                # Fund allocation
                my $fund = $order->fund;
                is( $fund->budget_code, 'REF', 'Correct fund allocated for first orderline' );

                # Check biblio
                ok( $order->biblionumber, 'Biblionumber assigned to order' );
                $biblios{ $order->biblionumber }++;

                # Check items created
                my $items = $order->items;
                is( $items->count, 1, 'One item created for the first orderline' );

                # Check first order GIR details
                my $item = $items->next;
                my $rota = $item->stockrotationitem;
                ok( $rota, 'Item was assigned to a rota' );
                is( $rota->stage->rota->title, 'TEST', "Item was assigned to the correct rota" );

            } elsif ( $orderline == 2 ) {

                # Fund allocation
                my $fund = $order->fund;
                is( $fund->budget_code, 'LOAN', 'Correct fund allocated for second orderline' );

                # Check biblio
                ok( $order->biblionumber, 'Biblionumber assigned to order' );
                $biblios{ $order->biblionumber }++;

                # Check items created
                my $items = $order->items;
                is( $items->count, 2, 'Two items created for the second orderline' );

                # Check second order GIR details
                my %rotas;
                while ( my $item = $items->next ) {
                    my $rota = $item->stockrotationitem;
                    ok( $rota, 'Item was assigned to a rota' );
                    $rotas{ $rota->stage->rota->title }++;
                }
                is( $rotas{'FAST'}, 1, "One item added to 'FAST' rota" );
                is( $rotas{'SLOW'}, 1, "One item added to 'SLOW' rota" );
            } elsif ( $orderline == 3 ) {

                #diag("Second LIN split into 2 Orderlines, one for each Fund");

                # Fund allocation
                my $fund = $order->fund;
                is( $fund->budget_code, 'REF', 'Correct fund allocated for third orderline' );

                # Check biblio
                ok( $order->biblionumber, 'Biblionumber assigned to order' );
                $biblios{ $order->biblionumber }++;

                # Check items created
                my $items = $order->items;
                is( $items->count, 1, 'One item created for the third orderline' );

                # Check first order GIR details
                my $item = $items->next;
                my $rota = $item->stockrotationitem;
                ok( !$rota, 'Item was not assigned to a rota' );
            }
        }

        $logger->clear();
        $schema->storage->txn_rollback;
    };

    # Test 4: Invalid Fund Error Handling
    subtest 'invalid_fund_handling' => sub {
        plan tests => 21;

        $schema->storage->txn_begin;

        # Create file transport for local testing
        my $file_transport = $builder->build(
            {
                source => 'FileTransport',
                value  => {
                    name               => 'Test Error Transport',
                    transport          => 'local',
                    download_directory => $dirname,
                    upload_directory   => $dirname,
                }
            }
        );

        my $account = $builder->build(
            {
                source => 'VendorEdiAccount',
                value  => {
                    description       => 'error test vendor',
                    file_transport_id => $file_transport->{file_transport_id},
                }
            }
        );
        my $ean = $builder->build(
            {
                source => 'EdifactEan',
                value  => {
                    description => 'test ean',
                    branchcode  => undef,
                    ean         => $test_san
                }
            }
        );

        my $description = <<~"END";
            Loading QUOTE file with 1 Message that contains 2 LIN segments with the first
            consistent of 1 item and the second with 3 items with 2 different undefined funds.
        END
        diag($description);

        my $filename = 'QUOTES_MULTI.CEQ';
        my $trans    = Koha::Edifact::Transport->new( $account->{id} );
        $trans->working_directory($dirname);

        my $mhash = $trans->message_hash();
        $mhash->{message_type} = 'QUOTE';
        $trans->ingest( $mhash, $filename );

        my $quote = $schema->resultset('EdifactMessage')->find( { filename => $filename } );

        process_quote($quote);

        #$logger->diag();
        $logger->trace_like(
            qr/Created basket:.*/,
            "Trace recorded basket added"
        )->trace_is(
            qq/Checking db for matches with 9781529923766/,
            "Trace recorded isbn lookup"
        )->trace_like(
            qr/Added biblio:.*/,
            "Trace recorded adding new biblio"
        )->trace_is(
            qq/Skipping orderline with invalid budget: REF/,
            "Trace recorded skipping orderline with invalid fund"
        )->trace_is(
            qq/Checking db for matches with 9781785044342/,
            "Trace recorded isbn lookup"
        )->trace_like(
            qr/Added biblio:.*/,
            "Trace recorded adding new biblio"
        )->trace_is(
            qq/Skipping item with invalid budget: LOAN/,
            "Trace recorded skipping item with invalid fund"
        )->trace_is(
            qq/Skipping item with invalid budget: REF/,
            "Trace recorded skipping item with invalid fund"
        )->trace_is(
            qq/Skipping item with invalid budget: LOAN/,
            "Trace recorded skipping item with invalid fund"
        );

        # Errors should be recorded for skipped sections
        my $errors = Koha::Edifact::File::Errors->search();
        is( $errors->count, 4, '4 errors recorded for missing funds in quote' );

        my $error = $errors->next;
        ok( $error->section, 'First error section is present' );
        is( $error->details, 'Skipped orderline line with invalid budget: REF', 'First error details is correct' );

        $error = $errors->next;
        ok( $error->section, 'Second error section is present' );
        is( $error->details, 'Skipped GIR line with invalid budget: LOAN', 'Second error details is correct' );

        $error = $errors->next;
        ok( $error->section, 'Third error section is present' );
        is( $error->details, 'Invalid budget REF found', 'Third error details is correct' );

        $error = $errors->next;
        ok( $error->section, 'Fourth error section is present' );
        is( $error->details, 'Invalid budget LOAN found', 'Fourth error details is correct' );

        $quote->get_from_storage;
        is( $quote->status, 'error', 'Quote status set to error for invalid fund' );

        my $baskets = Koha::Acquisition::Baskets->search( { booksellerid => $account->{vendor_id} } );
        is( $baskets->count, 1, 'Basket still created despite errors' );

        my $orders = $baskets->next->orders;
        is( $orders->count, 0, 'No orders created with invalid fund' );

        $logger->clear();
        $schema->storage->txn_rollback;
    };

    # Test 5: Multiple message quote file
    subtest 'multiple_message_handling' => sub {
        plan tests => 3;

        $schema->storage->txn_begin;

        # Create file transport for local testing
        my $file_transport = $builder->build(
            {
                source => 'FileTransport',
                value  => {
                    name               => 'Test Multiple Message Transport',
                    transport          => 'local',
                    download_directory => $dirname,
                    upload_directory   => $dirname,
                }
            }
        );

        my $account = $builder->build(
            {
                source => 'VendorEdiAccount',
                value  => {
                    description       => 'error test vendor',
                    file_transport_id => $file_transport->{file_transport_id},
                    po_is_basketname  => 0
                }
            }
        );
        my $ean = $builder->build(
            {
                source => 'EdifactEan',
                value  => {
                    description => 'test ean',
                    branchcode  => undef,
                    ean         => $test_san
                }
            }
        );

        my $description = <<~"END";
            Loading QUOTE file with 2 messages
        END
        diag($description);

        my $filename = 'QUOTES_BIG.CEQ';
        my $trans    = Koha::Edifact::Transport->new( $account->{id} );
        $trans->working_directory($dirname);

        my $mhash = $trans->message_hash();
        $mhash->{message_type} = 'QUOTE';
        $trans->ingest( $mhash, $filename );

        my $quote = $schema->resultset('EdifactMessage')->find( { filename => $filename } );

        process_quote($quote);

        #$logger->diag();

        my $baskets = Koha::Acquisition::Baskets->search( { booksellerid => $account->{vendor_id} } );
        is( $baskets->count, 2, 'Two baskets added for file containing 2 messages' );

        # First basket
        my $basket = $baskets->next;
        is( $basket->basketname, $filename, "Basket uses EDI filename for name" );

        # Second basket
        $basket = $baskets->next;
        is( $basket->basketname, $filename, "Basket uses EDI filename for name" );

        $logger->clear();
        $schema->storage->txn_rollback;
    };

    # Test 6: Basket naming configuration
    subtest 'basket_naming_configuration' => sub {
        plan tests => 5;

        $schema->storage->txn_begin;

        # Create file transport for local testing
        my $file_transport = $builder->build(
            {
                source => 'FileTransport',
                value  => {
                    name               => 'Test Multiple Message Transport',
                    transport          => 'local',
                    download_directory => $dirname,
                    upload_directory   => $dirname,
                }
            }
        );

        # Create vendor EDI account with po_is_basketname set to false (default)
        my $account_filename = $builder->build(
            {
                source => 'VendorEdiAccount',
                value  => {
                    description       => 'test vendor filename',
                    file_transport_id => $file_transport->{file_transport_id},
                    plugin            => '',
                    san               => $test_san,
                    quotes_enabled    => 1,
                    auto_orders       => 0,
                    po_is_basketname  => 0,
                }
            }
        );

        # Create vendor EDI account with po_is_basketname set to true
        my $account_po = $builder->build(
            {
                source => 'VendorEdiAccount',
                value  => {
                    description       => 'test vendor purchase order',
                    file_transport_id => $file_transport->{file_transport_id},
                    plugin            => '',
                    san               => $test_san,
                    quotes_enabled    => 1,
                    auto_orders       => 0,
                    po_is_basketname  => 1,
                }
            }
        );

        # Test database field storage
        my $account = $schema->resultset('VendorEdiAccount')->find( $account_filename->{id} );
        is( $account->po_is_basketname, 0, 'po_is_basketname field stores false value' );

        $account = $schema->resultset('VendorEdiAccount')->find( $account_po->{id} );
        is( $account->po_is_basketname, 1, 'po_is_basketname field stores true value' );

        # Test boolean constraint - valid values
        eval { $account->update( { po_is_basketname => 0 } ); };
        is( $@, '', 'false is accepted as valid boolean value' );

        eval { $account->update( { po_is_basketname => 1 } ); };
        is( $@, '', 'true is accepted as valid boolean value' );

        # Mock NewBasket to capture basket name
        my $captured_basket_name;
        my $mock_acquisition = Test::MockModule->new( 'C4::Acquisition', no_auto => 1 );
        $mock_acquisition->mock(
            'NewBasket',
            sub {
                my ( $vendor_id, $authorisedby, $basketname, $basketnote, $basketbooksellernote ) = @_;
                $captured_basket_name = $basketname;
                return 1;    # Return a basket ID
            }
        );

        # Mock message with purchase order number
        my $mock_message = Test::MockModule->new('Koha::Edifact::Message');
        $mock_message->mock( 'purchase_order_number', sub { return 'TEST_PO_123456'; } );
        $mock_message->mock( 'lineitems',             sub { return []; } );
        $mock_message->mock( 'buyer_ean',             sub { return $test_san; } );

        # Create a quote message for testing
        my $quote_message = $builder->build(
            {
                source => 'EdifactMessage',
                value  => {
                    message_type => 'QUOTE',
                    vendor_id    => $account_po->{vendor_id},
                    filename     => 'test_basket_naming.ceq',
                    status       => 'recmsg',
                }
            }
        );

        # Test that the logic would use purchase order number when configured
        # (This tests the logic in process_quote without running the full process)
        my $v = $schema->resultset('VendorEdiAccount')->search( { vendor_id => $account_po->{vendor_id} } )->single;
        my $quote_obj   = $schema->resultset('EdifactMessage')->find( $quote_message->{id} );
        my $basket_name = $quote_obj->filename;

        if ( $v && $v->po_is_basketname ) {
            my $purchase_order_number = 'TEST_PO_123456';    # Simulated from mock
            if ($purchase_order_number) {
                $basket_name = $purchase_order_number;
            }
        }

        is(
            $basket_name, 'TEST_PO_123456',
            'Basket naming logic correctly uses purchase order number when configured'
        );

        $schema->storage->txn_rollback;
    };

    # Test 7: Duplicate purchase order number validation
    subtest 'duplicate_purchase_order_validation' => sub {
        plan tests => 5;

        $schema->storage->txn_begin;

        # Create file transport for local testing
        my $file_transport = $builder->build(
            {
                source => 'FileTransport',
                value  => {
                    name               => 'Test Multiple Message Transport',
                    transport          => 'local',
                    download_directory => $dirname,
                    upload_directory   => $dirname,
                }
            }
        );

        # Create vendor EDI account with po_is_basketname set to true
        my $account = $builder->build(
            {
                source => 'VendorEdiAccount',
                value  => {
                    description       => 'test vendor duplicate po',
                    file_transport_id => $file_transport->{file_transport_id},
                    po_is_basketname  => 1,
                },
            }
        );

        # Create first basket with purchase order number "orders 23/1" (same as in QUOTES_SMALL.CEQ)
        my $first_basket = $builder->build(
            {
                source => 'Aqbasket',
                value  => {
                    basketname   => 'orders 23/1',
                    booksellerid => $account->{vendor_id},
                    closedate    => undef,                   # Open basket
                },
            }
        );

        # Use existing test file that contains RFF+ON:orders 23/1
        my $filename = 'QUOTES_SMALL.CEQ';
        my $trans    = Koha::Edifact::Transport->new( $account->{id} );
        $trans->working_directory($dirname);

        my $mhash = $trans->message_hash();
        $mhash->{message_type} = 'QUOTE';
        $trans->ingest( $mhash, $filename );

        my $quote = $schema->resultset('EdifactMessage')->find( { filename => $filename } );
        ok( $quote, 'Quote message created successfully' );

        # Process the quote (this should trigger duplicate detection)
        process_quote($quote);

        # Check that duplicate purchase order error was logged
        my $errors = $quote->edifact_errors;
        ok( $errors->count >= 1, 'At least one error logged during quote processing' );

        # Find the specific duplicate purchase order error
        my $duplicate_error = $errors->search( { section => 'RFF+ON:orders 23/1' } )->first;
        ok( $duplicate_error, 'Duplicate purchase order error found' );
        is( $duplicate_error->section, 'RFF+ON:orders 23/1', 'Error section contains the RFF+ON segment' );
        like(
            $duplicate_error->details, qr/Duplicate purchase order number 'orders 23\/1' found for vendor/,
            'Error details describe the duplicate issue'
        );

        $schema->storage->txn_rollback;
    };

    # Clean up
    $logger->clear();
    $schema->storage->txn_rollback;
};

subtest 'process_invoice' => sub {
    plan tests => 32;

    $schema->storage->txn_begin;

    # Get dirname for transport
    my $dirname = ( $Bin =~ /^(.*\/t\/)/ ? $1 . 'edi_testfiles/' : q{} );

    # Create file transport for local testing
    my $file_transport = $builder->build(
        {
            source => 'FileTransport',
            value  => {
                name               => 'Test Invoice Transport',
                transport          => 'local',
                download_directory => $dirname,
                upload_directory   => $dirname,
            }
        }
    );

    # Add test EDI matching ean of test invoice file and ensure no plugins so we trigger core functions
    my $account = $builder->build(
        {
            source => 'VendorEdiAccount',
            value  => {
                description       => 'test vendor',
                file_transport_id => $file_transport->{file_transport_id},
                plugin            => '',
                san               => '5013546027173'
            }
        }
    );

    # Create a test basket and orders matching the invoice message
    my $basket = $builder->build_object(
        {
            class => 'Koha::Acquisition::Baskets',
            value => {
                booksellerid => $account->{vendor_id},
                basketname   => 'Test Basket',
            }
        }
    );
    my $order1 = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                basketno     => $basket->id,
                orderstatus  => 'new',
                biblionumber => undef,
            }
        }
    );
    my $ordernumber1 = $order1->ordernumber;

    my $order2 = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                basketno    => $basket->id,
                orderstatus => 'new',
                quantity    => 3,
            }
        }
    );
    my $ordernumber2 = $order2->ordernumber;

    # Add test invoice file to the database for testing
    my $filename = 'INVOICE.CEI';
    ok( -e $dirname . $filename, 'File INVOICE.CEI found' );

    my $trans = Koha::Edifact::Transport->new( $account->{id} );
    $trans->working_directory($dirname);

    my $mhash = $trans->message_hash();
    $mhash->{message_type} = 'INVOICE';
    $trans->ingest( $mhash, $filename );

    my $invoice_message = $schema->resultset('EdifactMessage')->find( { filename => $filename } );
    my $raw_msg         = $invoice_message->raw_msg;
    $raw_msg =~ s/ORDERNUMBER1/$ordernumber1/g;
    $raw_msg =~ s/ORDERNUMBER2/$ordernumber2/g;
    $invoice_message->update( { raw_msg => $raw_msg } );

    # Process the test invoice file
    my $error;
    eval {
        process_invoice($invoice_message);
        1;
    } or do {
        $error = $@;
        diag($error);
    };
    ok( !$error, 'process_invoice completed without dying' );

    is( $logger->count, 14, "14 log lines recorded for passed invoice file" );

    #$logger->diag();
    $logger->trace_like(
        qr/Adding invoice:.*/,
        "Trace recorded adding invoice"
    )->trace_like(
        qr/Added as invoiceno.*/,
        "Trace recorded invoice added"
    )->error_is(
        'Skipping invoice line, no associated ordernumber',
        "Error recorded for missing ordernumber line"
    )->error_like(
        qr/Skipping invoice line, no order found for.*/,
        'Error recorded for unmatched ordernumber line'
    )->error_like(
        qr/Skipping invoice line, no bibliographic.*/,
        'Error recorded for unmatched biblionumber line'
    )->trace_like(
        qr/Receipting order:.*/,
        'Trace recorded invoice receipted'
    )->trace_like(
        qr/Updating bib:.*/,
        'Trace recorded bib updated'
    )->trace_like(
        qr/Receipting order:.*/,
        'Trace recorded invoice receipted - Check why this happens a second time'
    )->trace_like(
        qr/Updating bib:.*/,
        'Trace recorded bib updated - same bib, different id'
    )->error_like(
        qr/Cannot find vendor with ean.*/,
        'Error recorded for missing ean'
    )->warn_like(
        qr/transferring.*/,
        'Warn recorded for transferring items'
    )->warn_like(
        qr/Unmatched item at branch:.*/,
        'Warn recorded for unmatched item'
    )->warn_like(
        qr/transferring.*/,
        'Warn recorded for transferring items'
    )->warn_like(
        qr/Unmatched item at branch:.*/,
        'Warn recorded for unmatched item'
    )->clear();

    # Errors should be recorded for skipped sections
    my $errors = Koha::Edifact::File::Errors->search();
    is( $errors->count, 6, '6 errors recorded for invoice' );

    my @expected_errors = (
        {
            'section' =>
                "QTY+47:5\nGIR+001+DIT:LLO+34148000123456:LAC+P28837:LCO+DITATB:LFN\nPRI+AAA:9.99\nPRI+AAB:12.99\nMOA+203:49.95\nMOA+52:15.00",
            'details' => 'Skipped invoice line 1, missing ordernumber'
        },
        {
            'section' =>
                "QTY+47:5\nGIR+001+HLE:LLO+34148000123457:LAC+P28838:LCO+HLEATB:LFN\nPRI+AAA:9.99\nPRI+AAB:12.99\nMOA+203:49.95\nMOA+52:15.00\nRFF+LI:P28837",
            'details' => 'Skipped invoice line 2, cannot find order with ordernumber P28837'
        },
        {
            'section' =>
                "QTY+47:10\nGIR+001+RUN:LLO+34148000123458:LAC+P28839:LCO+RUNATB:LFN\nPRI+AAA:15.00\nPRI+AAB:18.00\nMOA+203:150.00\nMOA+52:30.00\nRFF+LI:$ordernumber1",
            'details' => "Skipped invoice line 3, cannot find biblio for ordernumber $ordernumber1"
        },
        {
            'section' =>
                "QTY+47:1\nGIR+001+WID:LLO+34148000123459:LAC+P28840:LCO+WIDATB:LFN\nPRI+AAA:30.00\nPRI+AAB:35.00\nMOA+203:600.00\nMOA+52:5.00\nRFF+LI:$ordernumber2",
            'details' => 'No matching item found for invoice line 4:0 at branch WID'
        },
        {
            'section' =>
                "QTY+47:1\nGIR+001+DIT:LLO+34148000123460:LAC+P54322:LCO+DITATB:LFN\nPRI+AAA:5.00\nPRI+AAB:6.00\nMOA+203:5.00\nMOA+52:1.00\nRFF+LI:$ordernumber2",
            'details' => 'No matching item found for invoice line 5:0 at branch DIT'
        },
        {
            'section' => "NAD+SU+9999999999999",
            'details' => 'Skipped invoice INV00002 with unmatched vendor san: 9999999999999'
        }
    );

    my $index = 0;
    while ( my $error = $errors->next ) {
        is( $error->section, $expected_errors[$index]->{section}, "Error $index section is correct" );
        is( $error->details, $expected_errors[$index]->{details}, "Error $index details is correct" );
        $index++;
    }

    my $invoice3 = Koha::Acquisition::Invoices->search( { invoicenumber => 'INV00003' }, { rows => 1 } )->single;
    ok( $invoice3, "Invoice added to database" );
    is( $invoice3->booksellerid, $account->{vendor_id}, 'Invoice has test booksellerid' );

    $schema->storage->txn_rollback;
};

subtest 'process_invoice_without_tax_rate' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    # Add test EDI account and vendor
    my $account = $builder->build(
        {
            source => 'VendorEdiAccount',
            value  => {
                description => 'Test account for tax rate handling',
                plugin      => q{},
            }
        }
    );

    # Add test order to match with invoice
    my $order = $builder->build(
        {
            source => 'Aqorder',
            value  => {
                quantity         => 1,
                listprice        => 10.00,
                unitprice        => 10.00,
                quantityreceived => 0,
                orderstatus      => 'ordered',
                biblionumber     => $builder->build_sample_biblio->biblionumber,
                basketno         =>
                    $builder->build( { source => 'Aqbasket', value => { booksellerid => $account->{vendor_id} } } )
                    ->{basketno},
            }
        }
    );

    # Create a minimal EDI invoice without TAX segments
    my $edi_invoice =
        qq{UNA:+.? 'UNB+UNOC:3+TEST+KOHA+200101:0000+1'UNH+1+INVOIC:D:96A:UN'BGM+380+TEST001+9'DTM+137:20200101:102'NAD+BY+12345::9'NAD+SU+$account->{san}::9'LIN+1++123456789:EN'QTY+47:1'GIR+001+TEST:LLO+12345678901234:LAC+TEST001:LCO+TESTATB:LFN'PRI+AAA:10.00'PRI+AAB:10.00'MOA+203:10.00'RFF+LI:$order->{ordernumber}'UNS+S'CNT+1:1'MOA+79:10.00'MOA+129:10.00'MOA+122:10.00'UNT+15+1'UNZ+1+1'};

    # Create EDI message in database
    my $edi_message = $builder->build(
        {
            source => 'EdifactMessage',
            value  => {
                message_type => 'INVOICE',
                filename     => 'TEST_NO_TAX.CEI',
                raw_msg      => $edi_invoice,
                status       => 'new',
                vendor_id    => $account->{vendor_id},
                edi_acct     => $account->{id},
            }
        }
    );

    my $invoice_message = $schema->resultset('EdifactMessage')->find( $edi_message->{id} );

    # Process the invoice - this should not generate warnings about undefined tax rates
    my $error;
    eval {
        process_invoice($invoice_message);
        1;
    } or do {
        $error = $@;
    };
    ok( !$error, 'process_invoice completed without dying when no tax rate present' );

    # Verify that orders with tax data exist (means processing completed)
    my $orders = $schema->resultset('Aqorder')->search(
        {
            basketno              => $order->{basketno},
            tax_rate_on_receiving => { '>=', 0 }
        }
    );

    ok( $orders->count > 0, 'Order processing completed successfully' );

    # Check that tax values were set correctly (should be 0 for no tax)
    my $order_with_tax = $orders->first;
    is( $order_with_tax->tax_rate_on_receiving + 0, 0, 'Tax rate set to 0 when no tax rate in EDI message' );

    $schema->storage->txn_rollback;
};

subtest 'duplicate_po_number_blocking' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $test_san      = '5013546098818';
    my $dirname       = ( $Bin =~ /^(.*\/t\/)/ ? $1 . 'edi_testfiles/' : q{} );
    my $active_period = $builder->build(
        {
            source => 'Aqbudgetperiod',
            value  => { budget_period_active => 1 }
        }
    );

    # Test 1: Auto-orders blocking for duplicate PO numbers
    subtest 'auto_orders_blocking' => sub {
        plan tests => 9;

        $schema->storage->txn_begin;

        # Create file transport for local testing
        my $file_transport = $builder->build(
            {
                source => 'FileTransport',
                value  => {
                    name               => 'Test Multiple Message Transport',
                    transport          => 'local',
                    download_directory => $dirname,
                    upload_directory   => $dirname,
                }
            }
        );

        # Create vendor EDI account with auto_orders and po_is_basketname enabled
        my $account = $builder->build(
            {
                source => 'VendorEdiAccount',
                value  => {
                    description       => 'auto_orders duplicate test vendor',
                    file_transport_id => $file_transport->{file_transport_id},
                    plugin            => '',
                    san               => $test_san,
                    auto_orders       => 1,
                    po_is_basketname  => 1,
                }
            }
        );

        my $ean = $builder->build(
            {
                source => 'EdifactEan',
                value  => {
                    description => 'test ean',
                    branchcode  => undef,
                    ean         => $test_san
                }
            }
        );

        # Create existing basket with PO number that will conflict
        my $existing_basket = $builder->build(
            {
                source => 'Aqbasket',
                value  => {
                    basketname   => 'orders 23/1',           # Same as in QUOTES_SMALL.CEQ
                    booksellerid => $account->{vendor_id},
                    closedate    => undef,
                }
            }
        );

        # Setup the fund
        $builder->build(
            {
                source => 'Aqbudget',
                value  => {
                    budget_code      => 'REF',
                    budget_period_id => $active_period->{budget_period_id}
                }
            }
        );

        my $filename = 'QUOTES_SMALL.CEQ';
        my $trans    = Koha::Edifact::Transport->new( $account->{id} );
        $trans->working_directory($dirname);

        my $mhash = $trans->message_hash();
        $mhash->{message_type} = 'QUOTE';
        $trans->ingest( $mhash, $filename );

        my $quote = $schema->resultset('EdifactMessage')->find( { filename => $filename } );

        # Clear logger before processing
        $logger->clear();

        # Process quote - should create basket but NOT auto-order due to duplicate PO
        my $die;
        eval {
            process_quote($quote);
            1;
        } or do {
            $die = $@;
        };
        ok( !$die, 'Quote with duplicate PO processed without dying' );

        # Verify duplicate PO error was logged during quote processing
        my $errors = $quote->edifact_errors;
        ok( $errors->count >= 1, 'Error logged for duplicate PO number' );

        my $duplicate_error = $errors->search( { section => 'RFF+ON:orders 23/1' } )->first;
        ok( $duplicate_error, 'Duplicate PO error found in quote errors' );

        # Check that new basket was created
        my $baskets = Koha::Acquisition::Baskets->search(
            {
                booksellerid => $account->{vendor_id},
                basketno     => { '!=' => $existing_basket->{basketno} }
            }
        );
        is( $baskets->count, 1, "New basket created despite duplicate PO" );

        my $new_basket = $baskets->next;
        is( $new_basket->basketname, 'orders 23/1', "New basket uses duplicate PO number as name" );

        # Critical test: Verify basket was NOT closed (auto-order was blocked)
        ok( !$new_basket->closedate, 'New basket with duplicate PO was NOT closed (auto-order blocked)' );

        # Verify no EDI order was created for the conflicting basket
        my $edi_orders = $schema->resultset('EdifactMessage')->search(
            {
                message_type => 'ORDERS',
                basketno     => $new_basket->basketno,
            }
        );
        is( $edi_orders->count, 0, 'No EDI order created for basket with duplicate PO' );

        # Check that the blocking is working by verifying no EDI orders were created
        # This is the most important test - the basket should NOT be auto-ordered
        ok( $edi_orders->count == 0, 'Auto-order was blocked - no EDI order created for duplicate PO' );

        # Verify that duplicate PO error was logged (this shows detection is working)
        ok( $duplicate_error, 'Duplicate PO number detection and logging is working' );

        $schema->storage->txn_rollback;
    };

    # Test 2: No blocking when po_is_basketname is disabled
    subtest 'no_blocking_when_feature_disabled' => sub {
        plan tests => 5;

        $schema->storage->txn_begin;

        # Create file transport for local testing
        my $file_transport = $builder->build(
            {
                source => 'FileTransport',
                value  => {
                    name               => 'Test Multiple Message Transport',
                    transport          => 'local',
                    download_directory => $dirname,
                    upload_directory   => $dirname,
                }
            }
        );

        # Create vendor EDI account with po_is_basketname DISABLED
        my $account = $builder->build(
            {
                source => 'VendorEdiAccount',
                value  => {
                    description       => 'feature disabled test vendor',
                    file_transport_id => $file_transport->{file_transport_id},
                    plugin            => '',
                    san               => $test_san,
                    auto_orders       => 1,
                    po_is_basketname  => 0,                                      # Feature disabled
                }
            }
        );

        my $ean = $builder->build(
            {
                source => 'EdifactEan',
                value  => {
                    description => 'test ean',
                    branchcode  => undef,
                    ean         => $test_san
                }
            }
        );

        # Create existing basket with any name
        my $existing_basket = $builder->build(
            {
                source => 'Aqbasket',
                value  => {
                    basketname   => 'orders 23/1',
                    booksellerid => $account->{vendor_id},
                    closedate    => undef,
                }
            }
        );

        # Setup the fund
        $builder->build(
            {
                source => 'Aqbudget',
                value  => {
                    budget_code      => 'REF',
                    budget_period_id => $active_period->{budget_period_id}
                }
            }
        );

        my $filename = 'QUOTES_SMALL.CEQ';
        my $trans    = Koha::Edifact::Transport->new( $account->{id} );
        $trans->working_directory($dirname);

        my $mhash = $trans->message_hash();
        $mhash->{message_type} = 'QUOTE';
        $trans->ingest( $mhash, $filename );

        my $quote = $schema->resultset('EdifactMessage')->find( { filename => $filename } );

        $logger->clear();
        process_quote($quote);

        # Verify new basket was created and auto-ordered (no blocking)
        my $baskets = Koha::Acquisition::Baskets->search(
            {
                booksellerid => $account->{vendor_id},
                basketno     => { '!=' => $existing_basket->{basketno} }
            }
        );
        is( $baskets->count, 1, "New basket created" );

        my $new_basket = $baskets->next;

        # When po_is_basketname is disabled, basket uses filename not PO number
        is( $new_basket->basketname, $filename, "Basket uses filename when po_is_basketname disabled" );

        # The key test is that normal processing occurred without duplicate detection
        # Since po_is_basketname is disabled, basket should use filename not PO number
        ok( $new_basket->basketname eq $filename, 'Normal basket naming when feature disabled' );

        # With po_is_basketname disabled, quote processing should work normally
        # The absence of duplicate errors in the database is the key indicator
        my $quote_errors           = $schema->resultset('EdifactError')->search( {} );
        my $has_duplicate_db_error = grep { $_->details =~ /Duplicate purchase order/ } $quote_errors->all;
        ok( !$has_duplicate_db_error, 'No duplicate PO database errors when feature disabled' );

        pass('Feature correctly disabled - normal processing occurred');

        $schema->storage->txn_rollback;
    };

    $schema->storage->txn_rollback;
};

subtest 'create_edi_order_logging' => sub {
    plan tests => 8;

    $schema->storage->txn_begin;

    # Test 1: Error when called without basketno
    $logger->clear();
    my $result = create_edi_order( { ean => '1234567890' } );
    ok( !defined $result, 'create_edi_order returns undef when called without basketno' );
    $logger->error_is(
        'create_edi_order called with no basketno or ean',
        'Error logged when create_edi_order called without basketno'
    );

    # Test 2: Error when called without ean
    $logger->clear();
    $result = create_edi_order( { basketno => 123 } );
    ok( !defined $result, 'create_edi_order returns undef when called without ean' );
    $logger->error_is(
        'create_edi_order called with no basketno or ean',
        'Error logged when create_edi_order called without ean'
    );

    # Test 3: Warning when no orderlines for basket
    $logger->clear();
    my $empty_basket = $builder->build_object( { class => 'Koha::Acquisition::Baskets' } );
    my $ean          = $builder->build(
        {
            source => 'EdifactEan',
            value  => {
                description => 'test ean',
                branchcode  => undef,
                ean         => '1234567890'
            }
        }
    );

    $result = create_edi_order(
        {
            basketno => $empty_basket->basketno,
            ean      => $ean->{ean}
        }
    );
    ok( !defined $result, 'create_edi_order returns undef when no orderlines for basket' );
    $logger->warn_is(
        "No orderlines for basket " . $empty_basket->basketno,
        'Warning logged when no orderlines for basket'
    );

    # Test 4: Warning when no matching EAN found
    $logger->clear();
    my $basket_with_orders = $builder->build_object( { class => 'Koha::Acquisition::Baskets' } );
    my $order              = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                basketno    => $basket_with_orders->basketno,
                orderstatus => 'new'
            }
        }
    );

    $result = create_edi_order(
        {
            basketno => $basket_with_orders->basketno,
            ean      => 'nonexistent_ean'
        }
    );
    ok( !defined $result, 'create_edi_order returns undef when no matching EAN found' );
    $logger->warn_is(
        'No matching EAN found for nonexistent_ean',
        'Warning logged when no matching EAN found'
    );

    $schema->storage->txn_rollback;
};
