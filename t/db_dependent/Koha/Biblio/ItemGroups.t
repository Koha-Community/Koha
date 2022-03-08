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

use Test::More tests => 3;

use Koha::Database;

use t::lib::TestBuilder;
use t::lib::Mocks;

BEGIN {
    use_ok('Koha::Biblio::ItemGroup');
    use_ok('Koha::Biblio::ItemGroups');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference('EnableItemGroups', 1);

subtest 'add_item() and items() tests' => sub {

    plan tests => 10;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();
    my $item_1 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });
    my $item_2 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });

    my $item_group = Koha::Biblio::ItemGroup->new( { biblio_id => $biblio->id } )->store();

    my $items = $item_group->items;
    is( $items->count, 0, 'Item group has no items');

    $item_group->add_item({ item_id => $item_1->id });
    my @items = $item_group->items->as_list();
    is( scalar(@items), 1, 'Item group has one item');
    is( $items[0]->id, $item_1->id, 'Item 1 is correct' );

    $item_group->add_item({ item_id => $item_2->id });
    @items = $item_group->items->as_list();
    is( scalar(@items), 2, 'Item group has two items');
    is( $items[0]->id, $item_1->id, 'Item 1 is correct' );
    is( $items[1]->id, $item_2->id, 'Item 2 is correct' );

    # Remove an item
    $item_1->delete;
    @items = $item_group->items->as_list();
    is( scalar(@items), 1, 'Item group now has only one item');
    is( $items[0]->id, $item_2->id, 'Item 2 is correct' );

    # Remove last item
    $item_2->delete;
    @items = $item_group->items->as_list();
    is( scalar(@items), 0, "Item group now has no items");
    $item_group = Koha::Biblio::ItemGroups->find( $item_group->id );
    is( $item_group, undef, 'ItemGroup is deleted when last item is deleted' );

    $schema->storage->txn_rollback;
};
