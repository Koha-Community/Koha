#!/usr/bin/perl
#
# Copyright 2014 Catalyst IT
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

use Test::More tests => 15;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Calendar qw( new );
use Koha::Biblioitems;
use Koha::Libraries;
use Koha::Database;
use Koha::DateUtils qw(dt_from_string);;
use Koha::Items;

BEGIN {
    use_ok('Koha::ItemType');
    use_ok('Koha::ItemTypes');
}

my $database = Koha::Database->new();
my $schema   = $database->schema();
$schema->txn_begin;

my $builder     = t::lib::TestBuilder->new;
my $initial_count = Koha::ItemTypes->search->count;

my $parent1 = $builder->build_object({ class => 'Koha::ItemTypes', value => { description => 'description' } });
my $child1  = $builder->build_object({
        class => 'Koha::ItemTypes',
        value => {
            parent_type => $parent1->itemtype,
            description => 'description',
        }
    });
my $child2  = $builder->build_object({
        class => 'Koha::ItemTypes',
        value => {
            parent_type => $parent1->itemtype,
            description => 'description',
        }
    });
my $child3  = $builder->build_object({
        class => 'Koha::ItemTypes',
        value => {
            parent_type => $parent1->itemtype,
            description => 'description',
        }
    });

Koha::Localization->new(
    {
        entity      => 'itemtypes',
        code        => $child1->itemtype,
        lang        => 'en',
        translation => 'b translated itemtype desc'
    }
)->store;
Koha::Localization->new(
    {
        entity      => 'itemtypes',
        code        => $child2->itemtype,
        lang        => 'en',
        translation => 'a translated itemtype desc'
    }
)->store;
Koha::Localization->new(
    {
        entity      => 'something_else',
        code        => $child2->itemtype,
        lang        => 'en',
        translation => 'another thing'
    }
)->store;

my $type = Koha::ItemTypes->find($child1->itemtype);
ok( defined($type), 'first result' );
is_deeply( $type->unblessed, $child1->unblessed, "We got back the same object" );
is_deeply( $type->parent->unblessed, $parent1->unblessed, 'The parent method returns the correct object');

$type = Koha::ItemTypes->find($child2->itemtype);
ok( defined($type), 'second result' );
is_deeply( $type->unblessed, $child2->unblessed, "We got back the same object" );

t::lib::Mocks::mock_preference('language', 'en');
t::lib::Mocks::mock_preference('OPACLanguages', 'en');
my $itemtypes = Koha::ItemTypes->search_with_localization;
is( $itemtypes->count, $initial_count + 4, 'We added 4 item types' );
my $first_itemtype = $itemtypes->next;
is(
    $first_itemtype->translated_description,
    'a translated itemtype desc',
    'item types should be sorted by translated description'
);

my $children = $parent1->children_with_localization;
my $first_child = $children->next;
is(
    $first_child->translated_description,
    'a translated itemtype desc',
    'item types should be sorted by translated description'
);

my $item_type = $builder->build_object({ class => 'Koha::ItemTypes' });

is( $item_type->can_be_deleted, 1, 'An item type that is not used can be deleted');

my $item = $builder->build_sample_item({ itype => $item_type->itemtype });
is( $item_type->can_be_deleted, 0, 'An item type that is used by an item cannot be deleted' );
$item->delete;

my $biblio = $builder->build_sample_biblio({ itemtype => $item_type->itemtype });
is ( $item_type->can_be_deleted, 0, 'An item type that is used by an item and a biblioitem cannot be deleted' );
$biblio->delete;

is ( $item_type->can_be_deleted, 1, 'The item type that was being used by the removed item and biblioitem can now be deleted' );

subtest 'image_location' => sub {
    plan tests => 3;

    my $item_type = $builder->build_object( { class => 'Koha::ItemTypes' } );
    $item_type->imageurl('https://myserver.org/image01');
    is( $item_type->image_location, 'https://myserver.org/image01', 'Check URL' );
    $item_type->imageurl('bridge/newthing.png');
    is(
        $item_type->image_location('opac'), '/opac-tmpl/bootstrap/itemtypeimg/bridge/newthing.png',
        'Check path for opac'
    );
    is(
        $item_type->image_location('intranet'), '/intranet-tmpl/prog/img/itemtypeimg/bridge/newthing.png',
        'Check path for intranet'
    );
};

$schema->txn_rollback;
