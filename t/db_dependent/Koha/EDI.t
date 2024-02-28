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

use Test::More tests => 1;
use Test::Warn;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::EDI qw(process_quote);
use Koha::Edifact::Transport;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

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
    $builder->build({
        source => 'Stockrotationstage',
        value  => { rota_id => $rota->rota_id },
    });

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
    my $on_rota = Koha::StockRotationItems->search({ itemnumber_id => $item->itemnumber });
    is($on_rota->count, 1, "Item added to stockrotation rota");

    my $rota_item = $on_rota->next;
    is($rota_item->stage->rota->id, $rota->id, "Item is on correct rota");

    $schema->storage->txn_rollback;
};
