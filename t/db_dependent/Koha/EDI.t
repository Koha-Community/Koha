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

use Test::More tests => 3;
use Test::Warn;
use Test::MockModule;

use t::lib::Mocks;
use t::lib::Mocks::Logger;
use t::lib::TestBuilder;

use Koha::EDI qw(process_quote process_invoice);
use Koha::Edifact::Transport;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;
my $logger  = t::lib::Mocks::Logger->new();

subtest 'process_quote' => sub {
    plan tests => 7;

    $schema->storage->txn_begin;

    # Add our test quote file to the database for testing against
    my $account = $builder->build(
        {
            source => 'VendorEdiAccount',
            value  => {
                description => 'test vendor', transport => 'FILE',
            }
        }
    );
    my $dirname  = ( $Bin =~ /^(.*\/t\/)/ ? $1 . 'edi_testfiles/' : q{} );
    my $filename = 'QUOTES_SMALL.CEQ';
    ok( -e $dirname . $filename, 'File QUOTES_SMALL.CEQ found' );

    my $trans = Koha::Edifact::Transport->new( $account->{id} );
    $trans->working_directory($dirname);

    my $mhash = $trans->message_hash();
    $mhash->{message_type} = 'QUOTE';
    $trans->ingest( $mhash, $filename );

    my $quote = $schema->resultset('EdifactMessage')->find( { filename => $filename } );

    # Test quote expects REF to be a valid and active fund code
    my $active_period = $builder->build(
        {
            source => 'Aqbudgetperiod',
            value  => { budget_period_active => 1 }
        }
    );
    my $fund = $builder->build(
        {
            source => 'Aqbudget',
            value  => {
                budget_code      => 'REF',
                budget_period_id => $active_period->{budget_period_id}
            }
        }
    );

    # The quote expects a ROT1 stock rotation roata to exist
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

    # Process the test quote file
    process_quote($quote);

    # Test for expected warnings for the passed quote file
    #
    # Test for quote status change
    $quote->get_from_storage;
    is( $quote->status, 'received', 'Quote status was set to received' );

    # Tests for generated basket for passed quote file
    my $baskets = Koha::Acquisition::Baskets->search( { booksellerid => $account->{vendor_id} } );
    is( $baskets->count, 1, "1 basket created for a single quote file" );
    my $basket = $baskets->next;

    my $orders = $basket->orders;
    is( $orders->count, 1, "1 order line attached to basket when only 1 order is in the edi message" );
    my $order = $orders->next;

    my $biblio = $order->biblio;

    my $items = $order->items;
    is( $items->count, 1, "1 item added when AcqCreateItem eq ordering and 1 item is in the EDI quote" );
    my $item = $items->next;

    # Test that item is added to rota appropriately
    my $on_rota = Koha::StockRotationItems->search( { itemnumber_id => $item->itemnumber } );
    is( $on_rota->count, 1, "Item added to stockrotation rota" );

    my $rota_item = $on_rota->next;
    is( $rota_item->stage->rota->id, $rota->id, "Item is on correct rota" );

    $schema->storage->txn_rollback;
};

subtest '_handle_008_field' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    # Add our test quote file to the database for testing against
    my $account = $builder->build(
        {
            source => 'VendorEdiAccount',
            value  => {
                description => 'test vendor', transport => 'FILE',
            }
        }
    );
    my $dirname  = ( $Bin =~ /^(.*\/t\/)/ ? $1 . 'edi_testfiles/' : q{} );
    my $filename = 'QUOTES_SMALL.CEQ';
    ok( -e $dirname . $filename, 'File QUOTES_SMALL.CEQ found' );

    my $trans = Koha::Edifact::Transport->new( $account->{id} );
    $trans->working_directory($dirname);

    my $mhash = $trans->message_hash();
    $mhash->{message_type} = 'QUOTE';
    $trans->ingest( $mhash, $filename );

    my $quote = $schema->resultset('EdifactMessage')->find( { filename => $filename } );

    # Test quote expects REF to be a valid and active fund code
    my $active_period = $builder->build(
        {
            source => 'Aqbudgetperiod',
            value  => { budget_period_active => 1 }
        }
    );
    my $fund = $builder->build(
        {
            source => 'Aqbudget',
            value  => {
                budget_code      => 'REF',
                budget_period_id => $active_period->{budget_period_id}
            }
        }
    );

    # The quote expects a ROT1 stock rotation roata to exist
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

    # Process the test quote file
    process_quote($quote);

    $quote->get_from_storage;

    # Tests for generated basket for passed quote file
    my $baskets = Koha::Acquisition::Baskets->search( { booksellerid => $account->{vendor_id} } );
    my $basket  = $baskets->next;

    my $orders = $basket->orders;
    my $order  = $orders->next;

    my $biblio       = $order->biblio;
    my $record       = $biblio->record;
    my $record_field = $record->field('008');

    is( exists( $record_field->{_data} ), 1, 'Field has been added' );

    # Test without calling the 008 handler
    $account = $builder->build(
        {
            source => 'VendorEdiAccount',
            value  => {
                description => 'test vendor', transport => 'FILE',
            }
        }
    );
    $dirname  = ( $Bin =~ /^(.*\/t\/)/ ? $1 . 'edi_testfiles/' : q{} );
    $filename = 'QUOTES_SMALL_2.CEQ';
    ok( -e $dirname . $filename, 'File QUOTES_SMALL_2.CEQ found' );

    $trans = Koha::Edifact::Transport->new( $account->{id} );
    $trans->working_directory($dirname);

    $mhash = $trans->message_hash();
    $mhash->{message_type} = 'QUOTE';
    $trans->ingest( $mhash, $filename );

    $quote = $schema->resultset('EdifactMessage')->find( { filename => $filename } );

    # Test quote expects REF to be a valid and active fund code
    $active_period = $builder->build(
        {
            source => 'Aqbudgetperiod',
            value  => { budget_period_active => 1 }
        }
    );
    $fund = $builder->build(
        {
            source => 'Aqbudget',
            value  => {
                budget_code      => 'REF2',
                budget_period_id => $active_period->{budget_period_id}
            }
        }
    );

    # The quote expects a ROT1 stock rotation roata to exist
    $rota = $builder->build_object(
        {
            class => 'Koha::StockRotationRotas',
            value => { title => 'ROT2' }
        }
    );
    $builder->build(
        {
            source => 'Stockrotationstage',
            value  => { rota_id => $rota->rota_id },
        }
    );

    # Process the test quote file
    my $edi_module = Test::MockModule->new('Koha::EDI');
    $edi_module->mock(
        '_check_for_existing_bib',
        sub {
            my $bib_record = shift;
            return;
        }
    );
    $edi_module->mock(
        '_handle_008_field',
        sub {
            my $bib_record = shift;
            return $bib_record;
        }
    );
    process_quote($quote);

    $quote->get_from_storage;

    # Tests for generated basket for passed quote file
    $baskets = Koha::Acquisition::Baskets->search( { booksellerid => $account->{vendor_id} } );
    $basket  = $baskets->next;

    $orders = $basket->orders;
    $order  = $orders->next;

    $biblio       = $order->biblio;
    $record       = $biblio->record;
    $record_field = $record->field('008');

    is( $record_field->{_data}, undef, 'Field has not been added' );

    $logger->clear();
    $schema->storage->txn_rollback;
};

subtest 'process_invoice' => sub {
    plan tests => 11;

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
    $raw_msg =~ s/P12345/$ordernumber1/g;
    $raw_msg =~ s/P54321/$ordernumber2/g;
    $invoice_message->update( { raw_msg => $raw_msg } );

    # Process the test invoice file
    warnings_exist { process_invoice($invoice_message) }
    [
        { carped => qr/Cannot find vendor with ean.*/i },
    ],
        'Invoice processed, with warnings, without dieing';

    $logger->trace_like( qr/Adding invoice:.*/, "Trace recorded adding invoice" )
        ->trace_like( qr/Added as invoiceno.*/, "Trace recorded invoice added" )->error_is(
        'Skipping invoice line, no associated ordernumber',
        "Received expected log line for missing ordernumber line"
    )->error_like(
        qr/Skipping invoice line, no order found for.*/,
        'Received expected log line for unmatched ordernumber line'
    )->error_like(
        qr/Skipping invoice line, no bibliographic.*/,
        'Received expected log line for unmatched biblionumber line'
    )->trace_like(
        qr/Receipting order:.*/,
        'Trace recorded invoice receipted'
    )->trace_like(
        qr/Updating bib:.*/,
        'Trace recorded bib updated'
    )->clear();

    my $invoice3 = Koha::Acquisition::Invoices->search( { invoicenumber => 'INV00003' }, { rows => 1 } )->single;
    ok( $invoice3, "Invoice added to database" );
    is( $invoice3->booksellerid, $account->{vendor_id}, 'Invoice has test booksellerid' );

    $schema->storage->txn_rollback;
};
