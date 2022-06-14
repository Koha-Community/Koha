#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 8;

use C4::Context;
use Koha::Database;
use Koha::ItemTypes;

use t::lib::TestBuilder;
use t::lib::Mocks;

BEGIN {
    use_ok('Koha::Template::Plugin::ItemTypes');
}

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

$schema->storage->txn_begin;

my $plugin = Koha::Template::Plugin::ItemTypes->new();
ok( $plugin, "initialized ItemTypes plugin" );

my $GetDescriptionUndef = $plugin->GetDescription(undef);
is($GetDescriptionUndef, q{}, "GetDescription call with undef");

my $GetDescriptionUnknown = $plugin->GetDescription("deliriumtremenssyndrome");
is($GetDescriptionUnknown, q{}, "GetDescription call with unknown type");

my $itemtypeA = $builder->build_object(
    {
        class => 'Koha::ItemTypes',
        value => {
            parent_type => undef,
            description => "Desc itemtype A",
        }
    }
);
Koha::Localization->new(
    {
        entity      => 'itemtypes',
        code        => $itemtypeA->itemtype,
        lang        => 'en',
        translation => 'Translated itemtype A'
    }
)->store;
my $itemtypeB = $builder->build_object(
    {
        class  => 'Koha::ItemTypes',
        value => {
            parent_type => $itemtypeA->itemtype,
            description => "Desc itemtype B",
        }
    }
);
Koha::Localization->new(
    {
        entity      => 'itemtypes',
        code        => $itemtypeB->itemtype,
        lang        => 'en',
        translation => 'Translated itemtype B'
    }
)->store;

my $GetDescriptionA1 = $plugin->GetDescription($itemtypeA->itemtype);
is($GetDescriptionA1, "Translated itemtype A", "ItemType without parent - GetDescription without want parent");
my $GetDescriptionA2 = $plugin->GetDescription($itemtypeA->itemtype, 1);
is($GetDescriptionA2, "Translated itemtype A", "ItemType without parent - GetDescription with want parent");

my $GetDescriptionB1 = $plugin->GetDescription($itemtypeB->itemtype);
is($GetDescriptionB1, "Translated itemtype B", "ItemType with parent - GetDescription without want parent");
my $GetDescriptionB2 = $plugin->GetDescription($itemtypeB->itemtype, 1);
is($GetDescriptionB2, "Translated itemtype A->Translated itemtype B", "ItemType with parent - GetDescription with want parent");

$schema->storage->txn_rollback;

1;
