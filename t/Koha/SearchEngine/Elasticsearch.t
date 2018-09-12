#!/usr/bin/perl
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

use Test::More tests => 4;
use Test::Exception;

use t::lib::Mocks;

use Test::MockModule;

use MARC::Record;

use Koha::SearchEngine::Elasticsearch;

subtest '_read_configuration() tests' => sub {

    plan tests => 10;

    my $configuration;
    t::lib::Mocks::mock_config( 'elasticsearch', undef );

    # 'elasticsearch' missing in configuration
    throws_ok {
        $configuration = Koha::SearchEngine::Elasticsearch::_read_configuration;
    }
    'Koha::Exceptions::Config::MissingEntry',
      'Configuration problem, exception thrown';
    is(
        $@->message,
        "Missing 'elasticsearch' block in config file",
        'Exception message is correct'
    );

    # 'elasticsearch' present but no 'server' entry
    t::lib::Mocks::mock_config( 'elasticsearch', {} );
    throws_ok {
        $configuration = Koha::SearchEngine::Elasticsearch::_read_configuration;
    }
    'Koha::Exceptions::Config::MissingEntry',
      'Configuration problem, exception thrown';
    is(
        $@->message,
        "Missing 'server' entry in config file for elasticsearch",
        'Exception message is correct'
    );

    # 'elasticsearch' and 'server' entries present, but no 'index_name'
    t::lib::Mocks::mock_config( 'elasticsearch', { server => 'a_server' } );
    throws_ok {
        $configuration = Koha::SearchEngine::Elasticsearch::_read_configuration;
    }
    'Koha::Exceptions::Config::MissingEntry',
      'Configuration problem, exception thrown';
    is(
        $@->message,
        "Missing 'index_name' entry in config file for elasticsearch",
        'Exception message is correct'
    );

    # Correct configuration, only one server
    t::lib::Mocks::mock_config( 'elasticsearch',  { server => 'a_server', index_name => 'index' } );

    $configuration = Koha::SearchEngine::Elasticsearch::_read_configuration;
    is( $configuration->{index_name}, 'index', 'Index configuration parsed correctly' );
    is_deeply( $configuration->{nodes}, ['a_server'], 'Server configuration parsed correctly' );

    # Correct configuration, two servers
    my @servers = ('a_server', 'another_server');
    t::lib::Mocks::mock_config( 'elasticsearch', { server => \@servers, index_name => 'index' } );

    $configuration = Koha::SearchEngine::Elasticsearch::_read_configuration;
    is( $configuration->{index_name}, 'index', 'Index configuration parsed correctly' );
    is_deeply( $configuration->{nodes}, \@servers , 'Server configuration parsed correctly' );
};

subtest 'get_elasticsearch_settings() tests' => sub {

    plan tests => 1;

    my $settings;

    # test reading index settings
    my $es = Koha::SearchEngine::Elasticsearch->new( {index => $Koha::SearchEngine::Elasticsearch::BIBLIOS_INDEX} );
    $settings = $es->get_elasticsearch_settings();
    is( $settings->{index}{analysis}{analyzer}{analyser_phrase}{tokenizer}, 'keyword', 'Index settings parsed correctly' );
};

subtest 'get_elasticsearch_mappings() tests' => sub {

    plan tests => 1;

    my $mappings;

    # test reading mappings
    my $es = Koha::SearchEngine::Elasticsearch->new( {index => $Koha::SearchEngine::Elasticsearch::BIBLIOS_INDEX} );
    $mappings = $es->get_elasticsearch_mappings();
    is( $mappings->{data}{_all}{type}, 'string', 'Field mappings parsed correctly' );
};

subtest 'Koha::SearchEngine::Elasticsearch::marc_records_to_documents () tests' => sub {

    plan tests => 30;

    t::lib::Mocks::mock_preference('marcflavour', 'MARC21');

    my @mappings = (
        {
            name => 'author',
            type => 'string',
            facet => 1,
            suggestible => 1,
            sort => undef,
            marc_type => 'marc21',
            marc_field => '100a',
        },
        {
            name => 'author',
            type => 'string',
            facet => 1,
            suggestible => 1,
            sort => 1,
            marc_type => 'marc21',
            marc_field => '110a',
        },
        {
            name => 'title',
            type => 'string',
            facet => 0,
            suggestible => 1,
            sort => 1,
            marc_type => 'marc21',
            marc_field => '245(ab)ab',
        },
        {
            name => 'unimarc_title',
            type => 'string',
            facet => 0,
            suggestible => 1,
            sort => 1,
            marc_type => 'unimarc',
            marc_field => '245a',
        },
        {
            name => 'title',
            type => 'string',
            facet => 0,
            suggestible => undef,
            sort => 0,
            marc_type => 'marc21',
            marc_field => '220',
        },
        {
            name => 'sum_item_price',
            type => 'sum',
            facet => 0,
            suggestible => 0,
            sort => 0,
            marc_type => 'marc21',
            marc_field => '952g',
        },
        {
            name => 'items_withdrawn_status',
            type => 'boolean',
            facet => 0,
            suggestible => 0,
            sort => 0,
            marc_type => 'marc21',
            marc_field => '9520',
        },
        {
            name => 'type_of_record',
            type => 'string',
            facet => 0,
            suggestible => 0,
            sort => 0,
            marc_type => 'marc21',
            marc_field => 'leader_/6',
        },
        {
            name => 'type_of_record_and_bib_level',
            type => 'string',
            facet => 0,
            suggestible => 0,
            sort => 0,
            marc_type => 'marc21',
            marc_field => 'leader_/6-7',
        },
    );

    my $se = Test::MockModule->new('Koha::SearchEngine::Elasticsearch');
    $se->mock('_foreach_mapping', sub {
        my ($self, $sub) = @_;

        foreach my $map (@mappings) {
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

    my $see = Koha::SearchEngine::Elasticsearch->new({ index => 'biblios' });

    my $marc_record_1 = MARC::Record->new();
    $marc_record_1->leader('     cam  22      a 4500');
    $marc_record_1->append_fields(
        MARC::Field->new('100', '', '', a => 'Author 1'),
        MARC::Field->new('110', '', '', a => 'Corp Author'),
        MARC::Field->new('210', '', '', a => 'Title 1'),
        MARC::Field->new('245', '', '', a => 'Title:', b => 'first record'),
        MARC::Field->new('999', '', '', c => '1234567'),
        # '  ' for testing trimming of white space in boolean value callback:
        MARC::Field->new('952', '', '', 0 => '  ', g => '123.30'),
        MARC::Field->new('952', '', '', 0 => 0, g => '127.20'),
    );
    my $marc_record_2 = MARC::Record->new();
    $marc_record_2->leader('     cam  22      a 4500');
    $marc_record_2->append_fields(
        MARC::Field->new('100', '', '', a => 'Author 2'),
        # MARC::Field->new('210', '', '', a => 'Title 2'),
        # MARC::Field->new('245', '', '', a => 'Title: second record'),
        MARC::Field->new('999', '', '', c => '1234568'),
        MARC::Field->new('952', '', '', 0 => 1, g => 'string where should be numeric'),
    );
    my $records = [$marc_record_1, $marc_record_2];

    $see->get_elasticsearch_mappings(); #sort_fields will call this and use the actual db values unless we call it first

    my $docs = $see->marc_records_to_documents($records);

    # First record:

    is(scalar @{$docs}, 2, 'Two records converted to documents');

    is($docs->[0][0], '1234567', 'First document biblionumber should be set as first element in document touple');

    is(scalar @{$docs->[0][1]->{author}}, 2, 'First document author field should contain two values');
    is_deeply($docs->[0][1]->{author}, ['Author 1', 'Corp Author'], 'First document author field should be set correctly');

    is(scalar @{$docs->[0][1]->{author__sort}}, 2, 'First document author__sort field should have two values');
    is_deeply($docs->[0][1]->{author__sort}, ['Author 1', 'Corp Author'], 'First document author__sort field should be set correctly');

    is(scalar @{$docs->[0][1]->{title__sort}}, 3, 'First document title__sort field should have three values');
    is_deeply($docs->[0][1]->{title__sort}, ['Title:', 'first record', 'Title: first record'], 'First document title__sort field should be set correctly');

    is(scalar @{$docs->[0][1]->{author__suggestion}}, 2, 'First document author__suggestion field should contain two values');
    is_deeply(
        $docs->[0][1]->{author__suggestion},
        [
            {
                'input' => 'Author 1'
            },
            {
                'input' => 'Corp Author'
            }
        ],
        'First document author__suggestion field should be set correctly'
    );

    is(scalar @{$docs->[0][1]->{title__suggestion}}, 3, 'First document title__suggestion field should contain three values');
    is_deeply(
        $docs->[0][1]->{title__suggestion},
        [
            { 'input' => 'Title:' },
            { 'input' => 'first record' },
            { 'input' => 'Title: first record' }
        ],
        'First document title__suggestion field should be set correctly'
    );

    ok(!(defined $docs->[0][1]->{title__facet}), 'First document should have no title__facet field');

    is(scalar @{$docs->[0][1]->{author__facet}}, 2, 'First document author__facet field should have two values');
    is_deeply(
        $docs->[0][1]->{author__facet},
        ['Author 1', 'Corp Author'],
        'First document author__facet field should be set correctly'
    );

    is(scalar @{$docs->[0][1]->{items_withdrawn_status}}, 2, 'First document items_withdrawn_status field should have two values');
    is_deeply(
        $docs->[0][1]->{items_withdrawn_status},
        ['false', 'false'],
        'First document items_withdrawn_status field should be set correctly'
    );

    is(
        $docs->[0][1]->{sum_item_price},
        '250.5',
        'First document sum_item_price field should be set correctly'
    );

    ok(defined $docs->[0][1]->{marc_data}, 'First document marc_data field should be set');

    ok(defined $docs->[0][1]->{marc_format}, 'First document marc_format field should be set');

    is(scalar @{$docs->[0][1]->{type_of_record}}, 1, 'First document type_of_record field should have one value');
    is_deeply(
        $docs->[0][1]->{type_of_record},
        ['a'],
        'First document type_of_record field should be set correctly'
    );

    is(scalar @{$docs->[0][1]->{type_of_record_and_bib_level}}, 1, 'First document type_of_record_and_bib_level field should have one value');
    is_deeply(
        $docs->[0][1]->{type_of_record_and_bib_level},
        ['am'],
        'First document type_of_record_and_bib_level field should be set correctly'
    );

    # Second record:

    is(scalar @{$docs->[1][1]->{author}}, 1, 'Second document author field should contain one value');
    is_deeply($docs->[1][1]->{author}, ['Author 2'], 'Second document author field should be set correctly');

    is(scalar @{$docs->[1][1]->{items_withdrawn_status}}, 1, 'Second document items_withdrawn_status field should have one value');
    is_deeply(
        $docs->[1][1]->{items_withdrawn_status},
        ['true'],
        'Second document items_withdrawn_status field should be set correctly'
    );

    is(
        $docs->[1][1]->{sum_item_price},
        0,
        'Second document sum_item_price field should be set correctly'
    );

    # Mappings marc_type:

    ok(!(defined $docs->[0][1]->{unimarc_title}), "No mapping when marc_type doesn't match marc flavour");

};
