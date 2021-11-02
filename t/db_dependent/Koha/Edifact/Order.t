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

use Test::More tests => 2;

use Koha::Edifact::Order;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;

my $builder = t::lib::TestBuilder->new;

subtest 'order_line() tests' => sub {
    # TODO: Split up order_line() to smaller methods in order
    #       to allow better testing
    plan tests => 2;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();
    my $ean    = $builder->build( { source => 'EdifactEan' } );
    my $order  = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => { biblionumber => $biblio->biblionumber }
        }
    );

    my $vendor = $builder->build(
        {
            source => 'VendorEdiAccount',
            value  => {
                vendor_id => $order->basket->bookseller->id,
            }
        }
    );

    my @orders = $schema->resultset('Aqorder')
      ->search( { basketno => $order->basket->basketno } )->all;

    my $edi_order = Koha::Edifact::Order->new(
        {
            orderlines => \@orders,
            vendor     => $vendor,
            ean        => $ean
        }
    );

    $order->basket->create_items('ordering')->store;

    is( $edi_order->order_line( 1, $orders[0] ),
        undef, 'Orderline message formed with with "ordering"' );

    $order->basket->create_items('receiving')->store;

    is( $edi_order->order_line( 1, $orders[0] ),
        undef, 'Orderline message formed with "receiving"' );

    $schema->storage->txn_rollback;
};

subtest 'filename() tests' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my $ean = $builder->build( { source => 'EdifactEan' } );
    my $order =
      $builder->build_object( { class => 'Koha::Acquisition::Orders' } );
    my $vendor = $builder->build(
        {
            source => 'VendorEdiAccount',
            value  => { vendor_id => $order->basket->bookseller->id }
        }
    );

    my @orders = $schema->resultset('Aqorder')
      ->search( { basketno => $order->basket->basketno } )->all;

    my $edi_order = Koha::Edifact::Order->new(
        {
            orderlines => \@orders,
            vendor     => $vendor,
            ean        => $ean
        }
    );

    my $expected_filename = 'ordr' . $order->basket->basketno . '.CEP';
    is( $edi_order->filename, $expected_filename,
        'Filename is formed from the basket number' );

    $schema->storage->txn_rollback;
};
