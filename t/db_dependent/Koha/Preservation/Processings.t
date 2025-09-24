#!/usr/bin/perl

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
use Test::More tests => 3;
use Test::Exception;
use Test::Warn;

use Koha::Preservation::Processings;
use Koha::Database;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'attributes' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $processing = $builder->build_object( { class => 'Koha::Preservation::Processings' } );

    my $attributes = [
        { name => 'color', type => 'authorised_value', option_source => 'COLORS' },
        { name => 'title', type => 'db_column',        option_source => '245$a' },
        {
            name => 'height',
            type => 'free_text'
        },
    ];
    $processing->attributes($attributes);
    my $fetched_attributes = $processing->attributes;
    is( ref($fetched_attributes),   'Koha::Preservation::Processing::Attributes' );
    is( $fetched_attributes->count, 3 );
    $processing->attributes( [] );
    is( ref($fetched_attributes),   'Koha::Preservation::Processing::Attributes' );
    is( $fetched_attributes->count, 0 );

    $schema->storage->txn_rollback;
};

subtest 'can_be_deleted' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $processing         = $builder->build_object( { class => 'Koha::Preservation::Processings' } );
    my $another_processing = $builder->build_object( { class => 'Koha::Preservation::Processings' } );

    is( $processing->can_be_deleted, 1, 'processing is not used, it can be deleted' );

    my $train = $builder->build_object(
        {
            class => 'Koha::Preservation::Trains',
            value => {
                not_for_loan          => 42,
                default_processing_id => $processing->processing_id,
                closed_on             => undef,
                sent_on               => undef,
                received_on           => undef
            }
        }
    );

    is( $processing->can_be_deleted,         0, 'processing is used, it cannot be deleted' );
    is( $another_processing->can_be_deleted, 1, 'processing is not used, it can be deleted' );

    my $item = $builder->build_sample_item;
    $train->add_item(
        { item_id                 => $item->itemnumber, processing_id => $another_processing->processing_id },
        { skip_waiting_list_check => 1 }
    );
    is( $processing->can_be_deleted,         0, 'processing is used, it cannot be deleted' );
    is( $another_processing->can_be_deleted, 0, 'processing is used, it cannot be deleted' );

    $schema->storage->txn_rollback;
};
