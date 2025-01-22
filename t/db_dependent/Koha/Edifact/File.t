#!/usr/bin/perl

# Copyright 2023 Koha Development team
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
# along with Koha; if not, see <http://www.gnu.org/licenses>

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 3;

use Koha::Edifact::Files;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'vendor() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $file = $builder->build_object( { class => 'Koha::Edifact::Files' } );

    my $vendor = $file->vendor;
    is(
        ref($vendor), 'Koha::Acquisition::Bookseller',
        'Koha::Edifact::File->vendor should return a Koha::Acquisition::Bookseller'
    );

    $file->vendor_id(undef)->store;
    is( $file->vendor, undef, 'Koha::Edifact::File->vendor should return undef if no vendor linked' );

    $schema->storage->txn_rollback;
};

subtest 'basket() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $file = $builder->build_object( { class => 'Koha::Edifact::Files' } );

    my $basket = $file->basket;
    is(
        ref($basket), 'Koha::Acquisition::Basket',
        'Koha::Edifact::File->basket should return a Koha::Acquisition::Basket'
    );

    $file->basketno(undef)->store;
    is( $file->basket, undef, 'Koha::Edifact::File->basket should return undef if no basket linked' );

    $schema->storage->txn_rollback;
};

1;
