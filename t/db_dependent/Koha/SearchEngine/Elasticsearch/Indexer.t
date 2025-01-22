#!/usr/bin/perl

# Copyright 2015 Catalyst IT
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

use Test::NoWarnings;
use Test::More tests => 5;
use Test::MockModule;
use Test::Warn;
use t::lib::Mocks;
use t::lib::TestBuilder;

use MARC::Record;

use Koha::Database;
use Koha::Biblios;

my $schema = Koha::Database->schema();

use_ok('Koha::SearchEngine::Elasticsearch::Indexer');

SKIP: {

    eval { Koha::SearchEngine::Elasticsearch->get_elasticsearch_params; };

    skip 'Elasticsearch configuration not available', 3
        if $@;

    $schema->storage->txn_begin;

    my $builder = t::lib::TestBuilder->new;
    my $biblio =
        $builder->build_sample_biblio;    # create biblio before we start mocking to avoid trouble indexing on creation

    subtest 'create_index() tests' => sub {
        plan tests => 6;
        my $se = Test::MockModule->new('Koha::SearchEngine::Elasticsearch');
        $se->mock(
            '_read_configuration',
            sub {
                my ( $self, $sub ) = @_;
                my $method = $se->original('_read_configuration');
                my $conf   = $method->($self);
                $conf->{index_name} .= '__test';
                return $conf;
            }
        );

        my $indexer;
        ok(
            $indexer = Koha::SearchEngine::Elasticsearch::Indexer->new( { 'index' => 'biblios' } ),
            'Creating a new indexer object'
        );

        is(
            $indexer->create_index(),
            Koha::SearchEngine::Elasticsearch::Indexer::INDEX_STATUS_OK(),
            'Creating an index'
        );

        my $marc_record = MARC::Record->new();
        $marc_record->append_fields(
            MARC::Field->new( '001', '1234567' ),
            MARC::Field->new( '020', '', '', 'a' => '1234567890123' ),
            MARC::Field->new( '245', '', '', 'a' => 'Title' )
        );
        my $records = [$marc_record];

        my $response = $indexer->update_index( [1], $records );
        is( $response->{errors},                   0,   "no error on update_index" );
        is( scalar( @{ $response->{items} } ),     1,   "1 item indexed" );
        is( $response->{items}[0]->{index}->{_id}, "1", "We should get a string matching the bibnumber passed in" );

        is(
            $indexer->drop_index(),
            Koha::SearchEngine::Elasticsearch::Indexer::INDEX_STATUS_RECREATE_REQUIRED(),
            'Dropping the index'
        );
    };

    subtest 'index_records() tests' => sub {
        plan tests => 4;
        my $mock_index = Test::MockModule->new("Koha::SearchEngine::Elasticsearch::Indexer");
        $mock_index->mock(
            update_index => sub {
                my ( $self, $record_ids, $records ) = @_;
                warn "Update " . $record_ids->[0] . $records->[0]->as_usmarc;
            }
        );
        $mock_index->mock(
            update_index_background => sub {
                my ( $self, $record_ids ) = @_;
                warn "Update background " . $record_ids->[0];
            }
        );

        my $indexer = Koha::SearchEngine::Elasticsearch::Indexer->new( { 'index' => 'authorities' } );

        my $marc_record = MARC::Record->new();
        $marc_record->append_fields(
            MARC::Field->new( '001', '1234567' ),
            MARC::Field->new( '100', '', '', 'a' => 'Rosenstock, Jeff' ),
        );
        warning_is {
            $indexer->index_records(
                [42], 'specialUpdate', 'authorityserver',
                [$marc_record]
            );
        }
        "Update 42" . $marc_record->as_usmarc,
            "When passing record and ids to index_records they are correctly passed through to update_index";

        $indexer     = Koha::SearchEngine::Elasticsearch::Indexer->new( { 'index' => 'biblios' } );
        $marc_record = $biblio->metadata->record( { embed_items => 1 } );
        warning_is {
            $indexer->index_records(
                [ $biblio->biblionumber ],
                'specialUpdate', 'biblioserver'
            );
        }
        "Update background " . $biblio->biblionumber,
            "When passing id only to index_records the marc record is fetched and passed through to update_index";

        my $chunks = 0;
        $mock_index->mock(
            update_index => sub {
                my ( $self, $record_ids, $records ) = @_;
                $chunks++;
            }
        );

        t::lib::Mocks::mock_config( 'elasticsearch', { server => 'false', index_name => 'pseudo' } );
        my @big_array = 1 .. 10000;
        $indexer->index_records( \@big_array, 'specialUpdate', 'biblioserver', \@big_array );
        is( $chunks, 2, "We split 10000 records into two chunks when chunk size not set" );

        $chunks = 0;
        t::lib::Mocks::mock_config(
            'elasticsearch',
            { server => 'false', index_name => 'pseudo', chunk_size => 10 }
        );
        $indexer->index_records( \@big_array, 'specialUpdate', 'biblioserver', \@big_array );
        is( $chunks, 1000, "We split 10000 records into 1000 chunks when chunk size is 10" );

    };

    $schema->storage->txn_rollback;

    subtest 'update_index' => sub {

        plan tests => 1;

        $schema->storage->txn_begin;

        my $biblio       = $builder->build_sample_biblio;
        my $biblionumber = $biblio->biblionumber;
        $biblio->delete;

        my $indexer = Koha::SearchEngine::Elasticsearch::Indexer->new( { 'index' => 'biblios' } );
        warning_is {
            $indexer->update_index( [$biblionumber] );

        }
        "", "update_index called with deleted biblionumber should not crash";

        $schema->storage->txn_rollback;
    };

}
