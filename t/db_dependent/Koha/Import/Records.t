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

use Test::More tests => 10;

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

my $matches = $retrieved_record_1->get_import_record_matches();
is( $matches->count, 0, "No matches returned if none set");

my $biblio = $builder->build_sample_biblio;
my $biblio_1 = $builder->build_sample_biblio;
my $biblio_2 = $builder->build_sample_biblio;
my $match_1 = $builder->build_object({ class => 'Koha::Import::Record::Matches',
                  value => {
                      score => 100,
                      chosen => 0,
                      candidate_match_id => $biblio->biblionumber,
                      import_record_id => $retrieved_record_1->import_record_id
                  }
              });
my $match_2 = $builder->build_object({ class => 'Koha::Import::Record::Matches',
                  value => {
                      score => 50,
                      chosen => 1,
                      candidate_match_id => $biblio_1->biblionumber,
                      import_record_id => $retrieved_record_1->import_record_id
                  }
              });
my $match_3 = $builder->build_object({ class => 'Koha::Import::Record::Matches',
                  value => {
                      score => 100,
                      chosen => 0,
                      candidate_match_id => $biblio_2->biblionumber,
                      import_record_id => $retrieved_record_1->import_record_id
                  }
              });

$matches = $retrieved_record_1->get_import_record_matches();
is( $matches->count, 3, 'We get three matches');

is_deeply( $matches->next->unblessed, $match_3->unblessed, "Match order is score desc, biblionumber desc, so 3 is first");

is_deeply( $matches->next->unblessed, $match_1->unblessed, "Match order is score desc, biblionumber desc, so 1 is second");
is_deeply( $matches->next->unblessed, $match_2->unblessed, "Match order is score desc, biblionumber desc, so 2 is third");

$matches = $retrieved_record_1->get_import_record_matches({ chosen => 1 });
is( $matches->count, 1, 'We get only the chosen match when requesting chosen');
is_deeply( $matches->next->unblessed, $match_2->unblessed, "Match 2 is the chosen match");

$retrieved_record_1->delete;
is( Koha::Import::Records->search->count, $nb_of_records + 1, 'Delete should have deleted the record' );

$schema->storage->txn_rollback;
