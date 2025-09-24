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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 2;

use Koha::Database;

use t::lib::TestBuilder;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'ill_batch() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $batch   = $builder->build_object( { class => 'Koha::ILL::Batches' } );
    my $request = $builder->build_object( { class => 'Koha::ILL::Requests', value => { batch_id => undef } } );

    is( $request->ill_batch, undef, 'Not having a linked batch makes the method return undef' );

    $request->batch_id( $batch->id )->store;

    my $linked_batch = $request->ill_batch;
    is( ref($linked_batch), 'Koha::ILL::Batch' );
    is( $linked_batch->id, $batch->id, 'Correct batch linked' );

    $schema->storage->txn_rollback;
};
