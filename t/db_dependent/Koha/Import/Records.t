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

use Test::More tests => 11;

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

subtest 'replace' => sub {
    plan tests => 4;


    # Replace biblio
    my $import_record = $builder->build_object({ class => 'Koha::Import::Records' });
    my $import_record_biblio = $builder->build_object({
        class => 'Koha::Import::Record::Biblios',
        value => {
            import_record_id => $import_record->id
        }
    });

    my $koha_biblio = $builder->build_sample_biblio({ title => "The before" });
    my $koha_xml = $koha_biblio->metadata->record->as_xml;
    my $import_biblio = $builder->build_sample_biblio({ title => "The after" });
    $import_record->marcxml( $import_biblio->metadata->record->as_xml )->store->discard_changes;

    $import_record->replace({ biblio => $koha_biblio });
    $koha_biblio->discard_changes;
    $import_record->discard_changes;
    is( $koha_biblio->title, "The after", "The Koha biblio is successfully updated" );
    is( $import_record->marcxml_old, $koha_xml, "The old marcxml in import records is correctly updated" );

    # Replace authority
    my $auth_record = MARC::Record->new;
    $auth_record->append_fields(
        MARC::Field->new( '100', '', '', a => 'Author' ),
    );
    my $auth_id = C4::AuthoritiesMarc::AddAuthority($auth_record, undef, 'PERSO_NAME');
    my $koha_auth = Koha::Authorities->find( $auth_id );
    $koha_xml = $koha_auth->marcxml;
    $import_record = $builder->build_object({ class => 'Koha::Import::Records' });
    my $import_record_auth = $builder->build_object({
        class => 'Koha::Import::Record::Auths',
        value => {
            import_record_id => $import_record->id
        }
    });


    my $field = $auth_record->field('100');
    $field->update( 'a' => 'Other author' );
    $import_record->marcxml( $auth_record->as_xml )->store->discard_changes;

    $import_record->replace({ authority => $koha_auth });
    $koha_auth->discard_changes;
    $import_record->discard_changes;
    my $updated_record = MARC::Record->new_from_xml( $koha_auth->marcxml, 'UTF-8');
    is( $updated_record->field('100')->as_string, $auth_record->field('100')->as_string, "The Koha auhtority record is correctly updated" );
    is( $import_record->marcxml_old, $koha_xml, "The old marcxml in import record is correctly updated" );

};

$schema->storage->txn_rollback;
