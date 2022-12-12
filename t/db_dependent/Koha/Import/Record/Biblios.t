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

use Koha::Import::Record::Biblios;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $nb_of_record_biblios = Koha::Import::Record::Biblios->search->count;

my $record_biblio_1 = $builder->build({ source => 'ImportBiblio' });
my $record_biblio_2 = $builder->build({ source => 'ImportBiblio' });

is( Koha::Import::Record::Biblios->search->count, $nb_of_record_biblios + 2, 'The 2 record biblios should have been added' );

my $retrieved_record_biblio_1 = Koha::Import::Record::Biblios->search({ import_record_id => $record_biblio_1->{import_record_id}})->next;
is_deeply( $retrieved_record_biblio_1->unblessed, $record_biblio_1, 'Find a record biblio by import record id should return the correct record biblio' );

$retrieved_record_biblio_1->delete;
is( Koha::Import::Record::Biblios->search->count, $nb_of_record_biblios + 1, 'Delete should have deleted the record biblio' );

$schema->storage->txn_rollback;
