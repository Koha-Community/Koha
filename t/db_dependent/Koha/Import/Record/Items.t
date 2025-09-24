#!/usr/bin/perl

# Copyright 2020 Koha Development team
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
use Test::More tests => 4;

use Koha::Import::Record::Items;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder            = t::lib::TestBuilder->new;
my $nb_of_record_items = Koha::Import::Record::Items->search->count;

my $record_item_1 = $builder->build( { source => 'ImportItem' } );
my $record_item_2 = $builder->build( { source => 'ImportItem' } );

is( Koha::Import::Record::Items->search->count, $nb_of_record_items + 2, 'The 2 record items should have been added' );

my $retrieved_record_item_1 =
    Koha::Import::Record::Items->search( { import_items_id => $record_item_1->{import_items_id} } )->next;
is_deeply(
    $retrieved_record_item_1->unblessed, $record_item_1,
    'Find a record item by import items id should return the correct record item'
);

$retrieved_record_item_1->delete;
is( Koha::Import::Record::Items->search->count, $nb_of_record_items + 1, 'Delete should have deleted the record item' );

$schema->storage->txn_rollback;
