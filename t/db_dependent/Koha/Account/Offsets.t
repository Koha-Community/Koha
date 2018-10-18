#!/usr/bin/perl

# Copyright 2018 Koha Development team
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

use Test::More tests => 1;
use Test::Exception;

use Koha::Account::Offsets;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'total_outstanding() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $line = $builder->build_object( { class => 'Koha::Account::Lines' } );

    my $amount_1 = 100;
    my $amount_2 = 200;
    my $amount_3 = -100;
    my $amount_4 = -300;
    my $amount_5 = 500;

    my $offset_1 = Koha::Account::Offset->new(
        { type => 'Fine', amount => $amount_1, credit_id => $line->id } )->store;
    my $offset_2 = Koha::Account::Offset->new(
        { type => 'Fine', amount => $amount_2, credit_id => $line->id } )->store;
    my $offset_3 = Koha::Account::Offset->new(
        { type => 'Payment', amount => $amount_3, credit_id => $line->id } )->store;
    my $offset_4 = Koha::Account::Offset->new(
        { type => 'Payment', amount => $amount_4, credit_id => $line->id } )->store;
    my $offset_5 = Koha::Account::Offset->new(
        { type => 'Fine', amount => $amount_5, credit_id => $line->id } )->store;

    my $debits = Koha::Account::Offsets->search( { type => 'Fine', credit_id => $line->id } );
    is( $debits->total, $amount_1 + $amount_2 + $amount_5 );

    my $credits = Koha::Account::Offsets->search( { type => 'Payment', credit_id => $line->id } );
    is( $credits->total, $amount_3 + $amount_4 );

    my $all = Koha::Account::Offsets->search( { credit_id => $line->id } );
    is( $all->total, $amount_1 + $amount_2 + $amount_3 + $amount_4 + $amount_5 );

    my $none = Koha::Account::Offsets->search( { credit_id => $line->id + 1 } );
    is( $none->total, 0, 'No offsets, returns 0' );

    $schema->storage->txn_rollback;
};
