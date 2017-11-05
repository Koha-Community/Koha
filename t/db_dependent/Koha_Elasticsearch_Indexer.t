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

use Test::More tests => 6;
use Test::MockModule;
use t::lib::Mocks;

use MARC::Record;

use Koha::Database;

my $schema = Koha::Database->schema();

use_ok('Koha::SearchEngine::Elasticsearch::Indexer');

my $indexer;
ok(
    $indexer = Koha::SearchEngine::Elasticsearch::Indexer->new({ 'index' => 'biblio' }),
    'Creating new indexer object'
);

my $marc_record = MARC::Record->new();
$marc_record->append_fields(
    MARC::Field->new( '001', '1234567' ),
    MARC::Field->new( '020', '', '', 'a' => '1234567890123' ),
    MARC::Field->new( '245', '', '', 'a' => 'Title' )
);

my $records = [$marc_record];
ok( my $converted = $indexer->_convert_marc_to_json($records),
    'Convert some records' );

is( $converted->count, 1, 'One converted record' );

SKIP: {

    eval { $indexer->get_elasticsearch_params; };

    skip 'ElasticSeatch configuration not available', 1
        if $@;

    ok( $indexer->update_index(undef,$records), 'Update Index' );
}

subtest '_convert_marc_to_json() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );

    my @mappings = (
        {
            name => 'author',
            type => 'string',
            facet => 1,
            suggestible => 1,
            sort => '~',
            marc_type => 'marc21',
            marc_field => '100a',
        },
        {
            name => 'author',
            type => 'string',
            facet => 1,
            suggestible => 1,
            sort => '~',
            marc_type => 'marc21',
            marc_field => '110a',
        },
    );


    my $se = Test::MockModule->new( 'Koha::SearchEngine::Elasticsearch' );
    $se->mock( '_foreach_mapping', sub {
        my ($self, $sub ) = @_;

        foreach my $map ( @mappings ) {
            $sub->(
                $map->{name},
                $map->{type},
                $map->{facet},
                $map->{suggestible},
                $map->{sort},
                $map->{marc_type},
                $map->{marc_field}
            );
        }
    });

    my $marc_record = MARC::Record->new();
    $marc_record->append_fields(
        MARC::Field->new( '001', '1234567' ),
        MARC::Field->new( '020', '', '', 'a' => '1234567890123' ),
        MARC::Field->new( '100', '', '', 'a' => 'Author' ),
        MARC::Field->new( '110', '', '', 'a' => 'Corp Author' ),
        MARC::Field->new( '245', '', '', 'a' => 'Title' ),
    );
    my $marc_record_2 = MARC::Record->new();
    $marc_record_2->append_fields(
        MARC::Field->new( '001', '1234567' ),
        MARC::Field->new( '020', '', '', 'a' => '1234567890123' ),
        MARC::Field->new( '100', '', '', 'a' => 'Author' ),
        MARC::Field->new( '245', '', '', 'a' => 'Title' ),
    );
    my @records = ( $marc_record, $marc_record_2 );

    my $importer = Koha::SearchEngine::Elasticsearch::Indexer->new({ index => 'biblios' })->_convert_marc_to_json( \@records );
    my $conv = $importer->next();
    is( $conv->{author}[0], "Author", "First mapped author should be 100a");
    is( $conv->{author}[1], "Corp Author", "Second mapped author should be 110a");

    $conv = $importer->next();
    is( $conv->{author}[0], "Author", "First mapped author should be 100a");
    is( scalar @{$conv->{author}} , 1, "We should map field only if exists, shouldn't add extra nulls");

    $schema->storage->txn_rollback;
};
