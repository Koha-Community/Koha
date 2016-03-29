#!/usr/bin/perl
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
use Test::More tests => 8;

use C4::Items;
use C4::Reserves;
use Koha::Database;

use t::lib::TestBuilder;
use Data::Dumper qw|Dumper|;

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

# NOTE This is a trick, if we want to populate the biblioitems table, we should not create a Biblio but a Biblioitem
my $param = { source => 'Biblioitem' };
my $from_biblio = {
    biblionumber => $builder->build($param)->{biblionumber},
};
my $to_biblio = {
    biblionumber => $builder->build($param)->{biblionumber},
};

my $item1       = $builder->build(
    {   source => 'Item',
        value  => { biblionumber => $from_biblio->{biblionumber}, },
    }
);
my $item2 = $builder->build(
    {   source => 'Item',
        value  => { biblionumber => $from_biblio->{biblionumber}, },
    }
);
my $item3 = $builder->build(
    {   source => 'Item',
        value  => { biblionumber => $to_biblio->{biblionumber}, },
    }
);

my $bib_level_hold_not_to_move = $builder->build(
    {   source => 'Reserve',
        value  => { biblionumber => $from_biblio->{biblionumber}, },
    }
);
my $item_level_hold_not_to_move = $builder->build(
    {   source => 'Reserve',
        value  => { biblionumber => $from_biblio->{biblionumber}, itemnumber => $item1->{itemnumber} },
    }
);
my $item_level_hold_to_move = $builder->build(
    {   source => 'Reserve',
        value  => { biblionumber => $from_biblio->{biblionumber}, itemnumber => $item2->{itemnumber} },
    }
);

my $to_biblionumber_after_moved = C4::Items::MoveItemFromBiblio( $item2->{itemnumber}, $from_biblio->{biblionumber}, $to_biblio->{biblionumber} );

is( $to_biblionumber_after_moved, $to_biblio->{biblionumber}, 'MoveItemFromBiblio should return the to_biblionumber if success' );

$to_biblionumber_after_moved = C4::Items::MoveItemFromBiblio( $item2->{itemnumber}, $from_biblio->{biblionumber}, $to_biblio->{biblionumber} );

is( $to_biblionumber_after_moved, undef, 'MoveItemFromBiblio should return undef if the move has failed. If called twice, the item is not attached to the first biblio anymore' );

my $get_item1 = C4::Items::GetItem( $item1->{itemnumber} );
is( $get_item1->{biblionumber}, $from_biblio->{biblionumber}, 'The item1 should not have been moved' );
my $get_item2 = C4::Items::GetItem( $item2->{itemnumber} );
is( $get_item2->{biblionumber}, $to_biblio->{biblionumber}, 'The item2 should have been moved' );
my $get_item3 = C4::Items::GetItem( $item3->{itemnumber} );
is( $get_item3->{biblionumber}, $to_biblio->{biblionumber}, 'The item3 should not have been moved' );

my $get_bib_level_hold    = C4::Reserves::GetReserve( $bib_level_hold_not_to_move->{reserve_id} );
my $get_item_level_hold_1 = C4::Reserves::GetReserve( $item_level_hold_not_to_move->{reserve_id} );
my $get_item_level_hold_2 = C4::Reserves::GetReserve( $item_level_hold_to_move->{reserve_id} );

is( $get_bib_level_hold->{biblionumber},    $from_biblio->{biblionumber}, 'MoveItemFromBiblio should not have moved the biblio-level hold' );
is( $get_item_level_hold_1->{biblionumber}, $from_biblio->{biblionumber}, 'MoveItemFromBiblio should not have moved the item-level hold placed on item 1' );
is( $get_item_level_hold_2->{biblionumber}, $to_biblio->{biblionumber},   'MoveItemFromBiblio should have moved the item-level hold placed on item 2' );

$schema->storage->txn_rollback;

1;
