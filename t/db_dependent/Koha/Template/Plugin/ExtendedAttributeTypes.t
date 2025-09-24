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
# with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 6;

use C4::Context;
use Koha::Database;
use Koha::Patron::Attribute::Types;

use t::lib::TestBuilder;
use t::lib::Mocks;

BEGIN {
    use_ok('Koha::Template::Plugin::ExtendedAttributeTypes');
}

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

$schema->storage->txn_begin;

my $plugin = Koha::Template::Plugin::ExtendedAttributeTypes->new();
ok( $plugin, "initialized ExtendedAttributeTypes plugin" );

my $typeA = $builder->build_object(
    {
        class => 'Koha::Patron::Attribute::Types',
        value => {
            staff_searchable => 0,
            description      => "Desc type A",
        }
    }
);
my $typeB = $builder->build_object(
    {
        class => 'Koha::Patron::Attribute::Types',
        value => {
            staff_searchable => 1,
            description      => "Desc type B",
        }
    }
);

my $all_plugin  = $plugin->all();
my $all_objects = Koha::Patron::Attribute::Types->search();

is_deeply( $all_plugin->unblessed, $all_objects->unblessed, "all method returns all the types correctly" );

my $all_plugin_codes = $plugin->codes();
my $all_object_codes = Koha::Patron::Attribute::Types->search()->get_column('code');

is_deeply( $all_plugin_codes, $all_object_codes, "codes method returns the codes as expected" );

my $searchable_plugin_codes = $plugin->codes( { staff_searchable => 1 } );
my $searchable_object_codes = Koha::Patron::Attribute::Types->search( { staff_searchable => 1 } )->get_column('code');

is_deeply( $searchable_plugin_codes, $searchable_object_codes, "searching plugin method works as expected" );

$schema->storage->txn_rollback;

1;
