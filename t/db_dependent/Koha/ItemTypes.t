#!/usr/bin/perl
#
# Copyright 2014 Catalyst IT
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Test::More tests => 24;
use Data::Dumper;
use Koha::Database;
use t::lib::Mocks;
use Koha::Items;
use Koha::Biblioitems;
use t::lib::TestBuilder;

BEGIN {
    use_ok('Koha::ItemType');
    use_ok('Koha::ItemTypes');
}

my $database = Koha::Database->new();
my $schema   = $database->schema();
$schema->txn_begin;
Koha::ItemTypes->delete;

Koha::ItemType->new(
    {
        itemtype       => 'type1',
        description    => 'description',
        rentalcharge   => '0.00',
        imageurl       => 'imageurl',
        summary        => 'summary',
        checkinmsg     => 'checkinmsg',
        checkinmsgtype => 'checkinmsgtype',
    }
)->store;

Koha::ItemType->new(
    {
        itemtype       => 'type2',
        description    => 'description',
        rentalcharge   => '0.00',
        imageurl       => 'imageurl',
        summary        => 'summary',
        checkinmsg     => 'checkinmsg',
        checkinmsgtype => 'checkinmsgtype',
    }
)->store;

Koha::ItemType->new(
    {
        itemtype       => 'type3',
        description    => 'description',
        rentalcharge   => '0.00',
        imageurl       => 'imageurl',
        summary        => 'summary',
        checkinmsg     => 'checkinmsg',
        checkinmsgtype => 'checkinmsgtype',
    }
)->store;

Koha::Localization->new(
    {
        entity      => 'itemtypes',
        code        => 'type1',
        lang        => 'en',
        translation => 'b translated itemtype desc'
    }
)->store;
Koha::Localization->new(
    {
        entity      => 'itemtypes',
        code        => 'type2',
        lang        => 'en',
        translation => 'a translated itemtype desc'
    }
)->store;
Koha::Localization->new(
    {
        entity      => 'something_else',
        code        => 'type2',
        lang        => 'en',
        translation => 'another thing'
    }
)->store;

my $type = Koha::ItemTypes->find('type1');
ok( defined($type), 'first result' );
is( $type->itemtype,       'type1',          'itemtype/code' );
is( $type->description,    'description',    'description' );
is( $type->rentalcharge,   '0.0000',             'rentalcharge' );
is( $type->imageurl,       'imageurl',       'imageurl' );
is( $type->summary,        'summary',        'summary' );
is( $type->checkinmsg,     'checkinmsg',     'checkinmsg' );
is( $type->checkinmsgtype, 'checkinmsgtype', 'checkinmsgtype' );

$type = Koha::ItemTypes->find('type2');
ok( defined($type), 'second result' );
is( $type->itemtype,       'type2',          'itemtype/code' );
is( $type->description,    'description',    'description' );
is( $type->rentalcharge,   '0.0000',             'rentalcharge' );
is( $type->imageurl,       'imageurl',       'imageurl' );
is( $type->summary,        'summary',        'summary' );
is( $type->checkinmsg,     'checkinmsg',     'checkinmsg' );
is( $type->checkinmsgtype, 'checkinmsgtype', 'checkinmsgtype' );

t::lib::Mocks::mock_preference('language', 'en');
t::lib::Mocks::mock_preference('opaclanguages', 'en');
my $itemtypes = Koha::ItemTypes->search_with_localization;
is( $itemtypes->count, 3, 'There are 3 item types' );
my $first_itemtype = $itemtypes->next;
is(
    $first_itemtype->translated_description,
    'a translated itemtype desc',
    'item types should be sorted by translated description'
);

my $builder = t::lib::TestBuilder->new;
my $item_type = $builder->build_object({ class => 'Koha::ItemTypes' });

is( $item_type->can_be_deleted, 1, 'An item type that is not used can be deleted');

my $item = $builder->build_object({ class => 'Koha::Items', value => { itype => $item_type->itemtype }});
is( $item_type->can_be_deleted, 0, 'An item type that is used by an item cannot be deleted' );
$item->delete;

my $biblioitem = $builder->build_object({ class => 'Koha::Biblioitems', value => { itemtype => $item_type->itemtype }});
is ( $item_type->can_be_deleted, 0, 'An item type that is used by an item and a biblioitem cannot be deleted' );
$biblioitem->delete;

is ( $item_type->can_be_deleted, 1, 'The item type that was being used by the removed item and biblioitem can now be deleted' );

$schema->txn_rollback;
