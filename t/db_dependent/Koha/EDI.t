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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use FindBin qw( $Bin );

use Test::More tests => 2;
use Test::Warn;
use Test::MockModule;

use t::lib::Mocks;
use t::lib::Mocks::Logger;
use t::lib::TestBuilder;

use Koha::EDI qw(process_quote process_invoice);
use Koha::Edifact::Transport;
use Koha::Edifact::File::Errors;
use Koha::DateUtils qw(dt_from_string);

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;
my $logger  = t::lib::Mocks::Logger->new();

subtest 'process_quote' => sub {
    plan tests => 5;

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

        my $account = $builder->build(
            {
                source => 'VendorEdiAccount',
                value  => {
                    description    => 'test vendor',
                    transport      => 'FILE',
                    plugin         => '',
                    san            => $test_san,
                    orders_enabled => 1,
                    auto_orders    => 0,
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

    # Test 2: Auto Orders Processing
    subtest 'auto_orders_processing' => sub {
        plan tests => 7;

        $schema->storage->txn_begin;
        my $account = $builder->build(
            {
                source => 'VendorEdiAccount',
                value  => {
                    description    => 'auto order vendor',
                    transport      => 'FILE',
                    plugin         => '',
                    san            => $test_san,
                    orders_enabled => 1,
                    auto_orders    => 1,
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

        # Create vendor EDI account
        my $account = $builder->build(
            {
                source => 'VendorEdiAccount',
                value  => {
                    description => 'multi-item vendor',
                    transport   => 'FILE',
                    plugin      => '',
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
            diag( "Looking at order: " . $orderline );
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
                diag("Second LIN split into 2 Orderlines, one for each Fund");

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

        my $account = $builder->build(
            {
                source => 'VendorEdiAccount',
                value  => {
                    description => 'error test vendor',
                    transport   => 'FILE',
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

        my $account = $builder->build(
            {
                source => 'VendorEdiAccount',
                value  => {
                    description => 'error test vendor',
                    transport   => 'FILE',
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

    # Clean up
    $logger->clear();
    $schema->storage->txn_rollback;
};

subtest 'process_invoice' => sub {
    plan tests => 32;

    $schema->storage->txn_begin;

    # Add test EDI matching ean of test invoice file and ensure no plugins so we trigger core functions
    my $account = $builder->build(
        {
            source => 'VendorEdiAccount',
            value  => {
                description => 'test vendor',
                transport   => 'FILE',
                plugin      => '',
                san         => '5013546027173'
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
            }
        }
    );
    my $ordernumber2 = $order2->ordernumber;

    # Add test invoice file to the database for testing
    my $dirname  = ( $Bin =~ /^(.*\/t\/)/ ? $1 . 'edi_testfiles/' : q{} );
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
