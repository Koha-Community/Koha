#!/usr/bin/perl

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

use Test::More tests => 5;

use t::lib::TestBuilder;

use C4::Biblio;
use Koha::Database;

BEGIN {
    use_ok('Koha::Biblio');
    use_ok('Koha::Biblios');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'metadata() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $title = 'Oranges and Peaches';

    my $record = MARC::Record->new();
    my $field = MARC::Field->new('245','','','a' => $title);
    $record->append_fields( $field );
    my ($biblionumber) = C4::Biblio::AddBiblio($record, '');

    my $biblio = Koha::Biblios->find( $biblionumber );
    is( ref $biblio, 'Koha::Biblio', 'Found a Koha::Biblio object' );

    my $metadata = $biblio->metadata;
    is( ref $metadata, 'Koha::Biblio::Metadata', 'Method metadata() returned a Koha::Biblio::Metadata object' );

    my $record2 = $metadata->record;
    is( ref $record2, 'MARC::Record', 'Method record() returned a MARC::Record object' );

    is( $record2->field('245')->subfield("a"), $title, 'Title in 245$a matches title from original record object' );

    $schema->storage->txn_rollback;
};

subtest 'hidden_in_opac() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();
    my $item_1 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });
    my $item_2 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });

    $item_1->withdrawn( 1 )->store->discard_changes;
    $item_2->withdrawn( 1 )->store->discard_changes;

    ok( !$biblio->hidden_in_opac({ rules => { withdrawn => [ 2 ] } }), 'Biblio not hidden' );

    $item_2->withdrawn( 2 )->store->discard_changes;
    $biblio->discard_changes; # refresh

    ok( !$biblio->hidden_in_opac({ rules => { withdrawn => [ 2 ] } }), 'Biblio not hidden' );

    $item_1->withdrawn( 2 )->store->discard_changes;
    $biblio->discard_changes; # refresh

    ok( $biblio->hidden_in_opac({ rules => { withdrawn => [ 2 ] } }), 'Biblio hidden' );

    $schema->storage->txn_rollback;
};

subtest 'items() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();
    my $item_1 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });
    my $item_2 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });

    my $items = $biblio->items;
    is( ref($items), 'Koha::Items', 'Returns a Koha::Items resultset' );
    is( $items->count, 2, 'Two items in resultset' );

    my @items = $biblio->items->as_list;
    is( scalar @items, 2, 'Same result, but in list context' );

    $schema->storage->txn_rollback;

};
