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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 3;

use Koha::Import::Records;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $nb_of_records = Koha::Import::Records->search->count;

my $record_1 = $builder->build({ source => 'ImportRecord' });
my $record_2 = $builder->build({ source => 'ImportRecord' });

is( Koha::Import::Records->search->count, $nb_of_records + 2, 'The 2 records should have been added' );

my $retrieved_record_1 = Koha::Import::Records->search({ import_record_id => $record_1->{import_record_id}})->next;
is_deeply( $retrieved_record_1->unblessed, $record_1, 'Find a record by import record id should return the correct record' );

$retrieved_record_1->delete;
is( Koha::Import::Records->search->count, $nb_of_records + 1, 'Delete should have deleted the record' );

$schema->storage->txn_rollback;
