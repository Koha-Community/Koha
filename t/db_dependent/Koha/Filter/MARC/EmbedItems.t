#!/usr/bin/env perl

# Copyright 2026 Koha Development Team
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
use Test::More tests => 4;

use C4::Biblio qw( GetMarcFromKohaField );
use Koha::Biblios;
use Koha::Database;
use Koha::RecordProcessor;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my ($itemtag) = GetMarcFromKohaField("items.itemnumber");

subtest 'filter() embeds items' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio;
    $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );
    $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );

    my $record             = $biblio->metadata->record;
    my @item_fields_before = $record->field($itemtag);
    is( scalar @item_fields_before, 0, 'No item fields before filtering' );

    my $processor = Koha::RecordProcessor->new(
        {
            filters => ['EmbedItems'],
            options => {
                interface     => 'intranet',
                frameworkcode => $biblio->frameworkcode,
                items         => [ $biblio->items->as_list ],
            }
        }
    );
    $processor->process($record);

    my @item_fields_after = $record->field($itemtag);
    is(
        scalar @item_fields_after, $biblio->items->count,
        'One item field embedded per item'
    );

    $schema->storage->txn_rollback;
};

subtest 'filter() handles an empty items list' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio;
    my $record = $biblio->metadata->record;

    my $processor = Koha::RecordProcessor->new(
        {
            filters => ['EmbedItems'],
            options => {
                interface     => 'intranet',
                frameworkcode => $biblio->frameworkcode,
                items         => [],
            }
        }
    );
    $processor->process($record);

    my @item_fields = $record->field($itemtag);
    is( scalar @item_fields, 0, 'No item fields embedded for an empty items list' );

    $schema->storage->txn_rollback;
};

subtest 'filter() does not materialize the biblio object' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio;
    $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );
    $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );

    my $record = $biblio->metadata->record;
    my $items  = [ $biblio->items->as_list ];

    # Count the biblio SELECTs issued while filtering. The frameworkcode is
    # provided in the options, so the filter must not fetch the biblio.
    my $biblio_selects = 0;
    my $processor      = Koha::RecordProcessor->new(
        {
            filters => ['EmbedItems'],
            options => {
                interface     => 'intranet',
                frameworkcode => $biblio->frameworkcode,
                items         => $items,
            }
        }
    );

    my $orig = \&DBIx::Class::Storage::DBI::_query_start;
    no warnings 'redefine';
    local *DBIx::Class::Storage::DBI::_query_start = sub {
        my ( $self, $sql, @bind ) = @_;
        $biblio_selects++ if $sql =~ /FROM\s+`?biblio`?\s/i && $sql =~ /biblionumber/i;
        return $orig->( $self, $sql, @bind );
    };
    $processor->process($record);

    is( $biblio_selects, 0, 'No biblio object is materialized while embedding items' );

    $schema->storage->txn_rollback;
};
