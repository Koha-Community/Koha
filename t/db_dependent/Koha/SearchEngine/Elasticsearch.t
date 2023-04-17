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

use Test::More tests => 8;
use Test::Exception;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Test::MockModule;

use MARC::Record;
use Try::Tiny;
use List::Util qw( any );

use C4::AuthoritiesMarc qw( AddAuthority );
use C4::Biblio;

use Koha::SearchEngine::Elasticsearch;
use Koha::SearchEngine::Elasticsearch::Search;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

subtest '_read_configuration() tests' => sub {

    plan tests => 16;

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
        "Missing <elasticsearch> entry in koha-conf.xml",
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
        "Missing <elasticsearch>/<server> entry in koha-conf.xml",
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
        "Missing <elasticsearch>/<index_name> entry in koha-conf.xml",
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
    is( $configuration->{cxn_pool}, 'Static', 'cxn_pool configuration set correctly to Static if not specified' );
    is_deeply( $configuration->{nodes}, \@servers , 'Server configuration parsed correctly' );

    t::lib::Mocks::mock_config( 'elasticsearch', { server => \@servers, index_name => 'index', cxn_pool => 'Sniff' } );

    $configuration = Koha::SearchEngine::Elasticsearch::_read_configuration;
    is( $configuration->{cxn_pool}, 'Sniff', 'cxn_pool configuration parsed correctly' );
    isnt( defined $configuration->{trace_to}, 'trace_to is not defined if not set' );

    my $params = Koha::SearchEngine::Elasticsearch::get_elasticsearch_params;
    is_deeply( $configuration->{nodes}, \@servers , 'get_elasticsearch_params is just a wrapper for _read_configuration' );

    t::lib::Mocks::mock_config( 'elasticsearch', { server => \@servers, index_name => 'index', cxn_pool => 'Sniff', trace_to => 'Stderr', request_timeout => 42 } );

    $configuration = Koha::SearchEngine::Elasticsearch::_read_configuration;
    is( $configuration->{trace_to}, 'Stderr', 'trace_to configuration parsed correctly' );
    is( $configuration->{request_timeout}, '42', 'additional configuration (request_timeout) parsed correctly' );
};

subtest 'get_elasticsearch_settings() tests' => sub {

    plan tests => 1;

    my $settings;

    # test reading index settings
    my $es = Koha::SearchEngine::Elasticsearch->new( {index => $Koha::SearchEngine::Elasticsearch::BIBLIOS_INDEX} );
    $settings = $es->get_elasticsearch_settings();
    is( $settings->{index}{analysis}{analyzer}{analyzer_phrase}{tokenizer}, 'keyword', 'Index settings parsed correctly' );
};

subtest 'get_elasticsearch_mappings() tests' => sub {

    plan tests => 3;

    my $mappings;

    my @mappings = (
        {
            name => 'cn-sort',
            type => 'callnumber',
            facet => 0,
            suggestible => 0,
            searchable => 1,
            sort => 1,
            marc_type => 'marc21',
            marc_field => '001',
        },
        {
            name => 'isbn',
            type => 'string',
            facet => 0,
            suggestible => 0,
            searchable => 1,
            sort => 1,
            marc_type => 'marc21',
            marc_field => '020a',
        },
    );
    my $search_engine_module = Test::MockModule->new('Koha::SearchEngine::Elasticsearch');
    $search_engine_module->mock('_foreach_mapping', sub {
        my ($self, $sub) = @_;

        foreach my $map (@mappings) {
            $sub->(
                $map->{name},
                $map->{type},
                $map->{facet},
                $map->{suggestible},
                $map->{sort},
                $map->{searchable},
                $map->{marc_type},
                $map->{marc_field}
            );
        }
    });

    my $search_engine_elasticsearch = Koha::SearchEngine::Elasticsearch::Search->new({ index => $Koha::SearchEngine::Elasticsearch::BIBLIOS_INDEX });
    $mappings = $search_engine_elasticsearch->get_elasticsearch_mappings();

    is( $mappings->{properties}{"cn-sort__sort"}{index}, 'false', 'Field mappings parsed correctly for sort for callnumber type' );
    is( $mappings->{properties}{"cn-sort__sort"}{numeric}, 'false', 'Field mappings parsed correctly for sort for callnumber type' );
    is( $mappings->{properties}{isbn__sort}{index}, 'false', 'Field mappings parsed correctly' );

};

subtest 'Koha::SearchEngine::Elasticsearch::marc_records_to_documents () tests' => sub {

    plan tests => 65;

    t::lib::Mocks::mock_preference('marcflavour', 'MARC21');
    t::lib::Mocks::mock_preference('ElasticsearchMARCFormat', 'ISO2709');

    my @mappings = (
        {
            name => 'control_number',
            type => 'string',
            facet => 0,
            suggestible => 0,
            searchable => 1,
            sort => undef,
            marc_type => 'marc21',
            marc_field => '001',
        },
        {
            name => 'isbn',
            type => 'isbn',
            facet => 0,
            suggestible => 0,
            searchable => 1,
            sort => 0,
            marc_type => 'marc21',
            marc_field => '020a',
        },
        {
            name => 'author',
            type => 'string',
            facet => 1,
            suggestible => 1,
            searchable => 1,
            sort => undef,
            marc_type => 'marc21',
            marc_field => '100a',
        },
        {
            name => 'author',
            type => 'string',
            facet => 1,
            suggestible => 1,
            searchable => 1,
            sort => 1,
            marc_type => 'marc21',
            marc_field => '110a',
        },
        {
            name => 'title',
            type => 'string',
            facet => 0,
            suggestible => 1,
            searchable => 1,
            sort => 1,
            marc_type => 'marc21',
            marc_field => '245(ab)ab',
        },
        {
            name => 'unimarc_title',
            type => 'string',
            facet => 0,
            suggestible => 1,
            searchable => 1,
            sort => 1,
            marc_type => 'unimarc',
            marc_field => '245a',
        },
        {
            name => 'title',
            type => 'string',
            facet => 0,
            suggestible => undef,
            searchable => 1,
            sort => 0,
            marc_type => 'marc21',
            marc_field => '220',
        },
        {
            name => 'uniform_title',
            type => 'string',
            facet => 0,
            suggestible => 0,
            searchable => 1,
            sort => 1,
            marc_type => 'marc21',
            marc_field => '240a',
        },
        {
            name => 'title_wildcard',
            type => 'string',
            facet => 0,
            suggestible => 0,
            searchable => 1,
            sort => undef,
            marc_type => 'marc21',
            marc_field => '245',
        },
        {
            name => 'sum_item_price',
            type => 'sum',
            facet => 0,
            suggestible => 0,
            searchable => 1,
            sort => 0,
            marc_type => 'marc21',
            marc_field => '952g',
        },
        {
            name => 'items_withdrawn_status',
            type => 'boolean',
            facet => 0,
            suggestible => 0,
            searchable => 1,
            sort => 0,
            marc_type => 'marc21',
            marc_field => '9520',
        },
        {
            name => 'local_classification',
            type => 'string',
            facet => 0,
            suggestible => 0,
            searchable => 1,
            sort => 1,
            marc_type => 'marc21',
            marc_field => '952o',
        },
        {
            name => 'type_of_record',
            type => 'string',
            facet => 0,
            suggestible => 0,
            searchable => 1,
            sort => 0,
            marc_type => 'marc21',
            marc_field => 'leader_/6',
        },
        {
            name => 'type_of_record_and_bib_level',
            type => 'string',
            facet => 0,
            suggestible => 0,
            searchable => 1,
            sort => 0,
            marc_type => 'marc21',
            marc_field => 'leader_/6-7',
        },
        {
            name => 'ff7-00',
            type => 'string',
            facet => 0,
            suggestible => 0,
            searchable => 1,
            sort => 0,
            marc_type => 'marc21',
            marc_field => '007_/0',
        },
        {
            name => 'issues',
            type => 'sum',
            facet => 0,
            suggestible => 0,
            searchable => 1,
            sort => 1,
            marc_type => 'marc21',
            marc_field => '952l',
          },
          {
            name => 'copydate',
            type => 'year',
            facet => 0,
            suggestible => 0,
            searchable => 1,
            sort => 1,
            marc_type => 'marc21',
            marc_field => '260c',
          },
          {
            name => 'date-of-publication',
            type => 'year',
            facet => 0,
            suggestible => 0,
            searchable => 1,
            sort => 1,
            marc_type => 'marc21',
            marc_field => '008_/7-10',
        },
        {
            name => 'subject',
            type => 'string',
            facet => 0,
            suggestible => 0,
            searchable => 1,
            sort => 1,
            marc_type => 'marc21',
            marc_field => '650(avxyz)',
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
                $map->{searchable},
                $map->{marc_type},
                $map->{marc_field}
            );
        }
    });

    my $see = Koha::SearchEngine::Elasticsearch::Search->new({ index => $Koha::SearchEngine::Elasticsearch::BIBLIOS_INDEX });

    my $callno = 'ABC123';
    my $callno2 = 'ABC456';
    my $long_callno = '1234567890' x 30;

    my $marc_record_1 = MARC::Record->new();
    $marc_record_1->leader('     cam  22      a 4500');
    $marc_record_1->append_fields(
        MARC::Field->new('001', '123'),
        MARC::Field->new('007', 'ku'),
        MARC::Field->new('008', '901111s1962 xxk|||| |00| ||eng c'),
        MARC::Field->new('020', '', '', a => '1-56619-909-3'),
        MARC::Field->new('100', '', '', a => 'Author 1'),
        MARC::Field->new('110', '', '', a => 'Corp Author'),
        MARC::Field->new('210', '', '', a => 'Title 1'),
        MARC::Field->new('240', '', '4', a => 'The uniform title with nonfiling indicator'),
        MARC::Field->new('245', '', '', a => 'Title:', b => 'first record'),
        MARC::Field->new('260', '', '', a => 'New York :', b => 'Ace ,', c => 'c1962'),
        MARC::Field->new('650', '', '', a => 'Heading', z => 'Geohead', v => 'Formhead'),
        MARC::Field->new('650', '', '', a => 'Heading', x => 'Gensubhead', z => 'Geohead'),
        MARC::Field->new('999', '', '', c => '1234567'),
        # '  ' for testing trimming of white space in boolean value callback:
        MARC::Field->new('952', '', '', 0 => '  ', g => '123.30', o => $callno, l => 3),
        MARC::Field->new('952', '', '', 0 => 0, g => '127.20', o => $callno2, l => 2),
        MARC::Field->new('952', '', '', 0 => 1, g => '0.00', o => $long_callno, l => 1),
    );
    my $marc_record_2 = MARC::Record->new();
    $marc_record_2->leader('     cam  22      a 4500');
    $marc_record_2->append_fields(
        MARC::Field->new('008', '901111s19uu xxk|||| |00| ||eng c'),
        MARC::Field->new('100', '', '', a => 'Author 2'),
        # MARC::Field->new('210', '', '', a => 'Title 2'),
        # MARC::Field->new('245', '', '', a => 'Title: second record'),
        MARC::Field->new('260', '', '', a => 'New York :', b => 'Ace ,', c => '1963-2003'),
        MARC::Field->new('999', '', '', c => '1234568'),
        MARC::Field->new('952', '', '', 0 => 1, g => 'string where should be numeric', o => $long_callno),
    );

    my $marc_record_3 = MARC::Record->new();
    $marc_record_3->leader('     cam  22      a 4500');
    $marc_record_3->append_fields(
        MARC::Field->new('008', '901111s19uu xxk|||| |00| ||eng c'),
        MARC::Field->new('100', '', '', a => 'Author 2'),
        # MARC::Field->new('210', '', '', a => 'Title 3'),
        # MARC::Field->new('245', '', '', a => 'Title: third record'),
        MARC::Field->new('260', '', '', a => 'New York :', b => 'Ace ,', c => ' 89 '),
        MARC::Field->new('999', '', '', c => '1234568'),
        MARC::Field->new('952', '', '', 0 => 1, g => 'string where should be numeric', o => $long_callno),
    );

    my $marc_record_4 = MARC::Record->new();
    $marc_record_4->leader('     cam  22      a 4500');
    $marc_record_4->append_fields(
        MARC::Field->new('008', '901111s19uu xxk|||| |00| ||eng c'),
        MARC::Field->new('100', '', '', a => 'Author 2'),
        MARC::Field->new('245', '', '4', a => 'The Title :', b => 'fourth record'),
        MARC::Field->new('260', '', '', a => 'New York :', b => 'Ace ,', c => ' 89 '),
        MARC::Field->new('999', '', '', c => '1234568'),
    );

    my $records = [$marc_record_1, $marc_record_2, $marc_record_3, $marc_record_4];

    $see->get_elasticsearch_mappings(); #sort_fields will call this and use the actual db values unless we call it first

    my $docs = $see->marc_records_to_documents($records);

    # First record:
    is(scalar @{$docs}, 4, 'Four records converted to documents');

    is_deeply($docs->[0]->{control_number}, ['123'], 'First record control number should be set correctly');

    is_deeply($docs->[0]->{'ff7-00'}, ['k'], 'First record ff7-00 should be set correctly');

    is(scalar @{$docs->[0]->{author}}, 2, 'First document author field should contain two values');
    is_deeply($docs->[0]->{author}, ['Author 1', 'Corp Author'], 'First document author field should be set correctly');

    is(scalar @{$docs->[0]->{subject}}, 2, 'First document subject field should contain two values');
    is_deeply($docs->[0]->{subject}, ['Heading Geohead Formhead', 'Heading Gensubhead Geohead'], 'First document asubject field should be set correctly, record order preserved for grouped subfield mapping');

    is(scalar @{$docs->[0]->{author__sort}}, 1, 'First document author__sort field should have a single value');
    is_deeply($docs->[0]->{author__sort}, ['Author 1 Corp Author'], 'First document author__sort field should be set correctly');

    is(scalar @{$docs->[0]->{title__sort}}, 1, 'First document title__sort field should have a single');
    is_deeply($docs->[0]->{title__sort}, ['Title: first record Title: first record'], 'First document title__sort field should be set correctly');

    is(scalar @{$docs->[3]->{title__sort}}, 1, 'First document title__sort field should have a single');
    is_deeply($docs->[3]->{title__sort}, ['Title : fourth record The Title : fourth record'], 'Fourth document title__sort field should be set correctly');

    is($docs->[0]->{issues}, 6, 'Issues field should be sum of the issues for each item');
    is($docs->[0]->{issues__sort}, 6, 'Issues sort field should also be a sum of the issues');

    is(scalar @{$docs->[0]->{title_wildcard}}, 2, 'First document title_wildcard field should have two values');
    is_deeply($docs->[0]->{title_wildcard}, ['Title:', 'first record'], 'First document title_wildcard field should be set correctly');


    is(scalar @{$docs->[0]->{author__suggestion}}, 2, 'First document author__suggestion field should contain two values');
    is_deeply(
        $docs->[0]->{author__suggestion},
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

    is(scalar @{$docs->[0]->{title__suggestion}}, 3, 'First document title__suggestion field should contain three values');
    is_deeply(
        $docs->[0]->{title__suggestion},
        [
            { 'input' => 'Title:' },
            { 'input' => 'first record' },
            { 'input' => 'Title: first record' }
        ],
        'First document title__suggestion field should be set correctly'
    );

    ok(!(defined $docs->[0]->{title__facet}), 'First document should have no title__facet field');

    is(scalar @{$docs->[0]->{author__facet}}, 2, 'First document author__facet field should have two values');
    is_deeply(
        $docs->[0]->{author__facet},
        ['Author 1', 'Corp Author'],
        'First document author__facet field should be set correctly'
    );

    is(scalar @{$docs->[0]->{items_withdrawn_status}}, 2, 'First document items_withdrawn_status field should have two values');
    is_deeply(
        $docs->[0]->{items_withdrawn_status},
        ['false', 'true'],
        'First document items_withdrawn_status field should be set correctly'
    );

    is(
        $docs->[0]->{sum_item_price},
        '250.5',
        'First document sum_item_price field should be set correctly'
    );

    ok(defined $docs->[0]->{marc_data}, 'First document marc_data field should be set');
    ok(defined $docs->[0]->{marc_format}, 'First document marc_format field should be set');
    is($docs->[0]->{marc_format}, 'base64ISO2709', 'First document marc_format should be set correctly');

    my $decoded_marc_record = $see->decode_record_from_result($docs->[0]);

    ok($decoded_marc_record->isa('MARC::Record'), "base64ISO2709 record successfully decoded from result");
    is($decoded_marc_record->as_usmarc(), $marc_record_1->as_usmarc(), "Decoded base64ISO2709 record has same data as original record");

    is(scalar @{$docs->[0]->{type_of_record}}, 1, 'First document type_of_record field should have one value');
    is_deeply(
        $docs->[0]->{type_of_record},
        ['a'],
        'First document type_of_record field should be set correctly'
    );

    is(scalar @{$docs->[0]->{type_of_record_and_bib_level}}, 1, 'First document type_of_record_and_bib_level field should have one value');
    is_deeply(
        $docs->[0]->{type_of_record_and_bib_level},
        ['am'],
        'First document type_of_record_and_bib_level field should be set correctly'
    );

    is(scalar @{$docs->[0]->{isbn}}, 4, 'First document isbn field should contain four values');
    is_deeply($docs->[0]->{isbn}, ['978-1-56619-909-4', '9781566199094', '1-56619-909-3', '1566199093'], 'First document isbn field should be set correctly');

    is_deeply(
        $docs->[0]->{'local_classification'},
        [$callno, $callno2, $long_callno],
        'First document local_classification field should be set correctly'
    );

    # Nonfiling characters for sort fields
    is_deeply(
        $docs->[0]->{uniform_title},
        ['The uniform title with nonfiling indicator'],
        'First document uniform_title field should contain the title verbatim'
    );
    is_deeply(
        $docs->[0]->{uniform_title__sort},
        ['uniform title with nonfiling indicator'],
        'First document uniform_title__sort field should contain the title with the first four initial characters removed'
    );

    # Tests for 'year' type
    is(scalar @{$docs->[0]->{'date-of-publication'}}, 1, 'First document date-of-publication field should contain one value');
    is_deeply($docs->[0]->{'date-of-publication'}, ['1962'], 'First document date-of-publication field should be set correctly');

    is_deeply(
      $docs->[0]->{'copydate'},
      ['1962'],
      'First document copydate field should be set correctly'
    );

    # Second record:

    is(scalar @{$docs->[1]->{author}}, 1, 'Second document author field should contain one value');
    is_deeply($docs->[1]->{author}, ['Author 2'], 'Second document author field should be set correctly');

    is(scalar @{$docs->[1]->{items_withdrawn_status}}, 1, 'Second document items_withdrawn_status field should have one value');
    is_deeply(
        $docs->[1]->{items_withdrawn_status},
        ['true'],
        'Second document items_withdrawn_status field should be set correctly'
    );

    is(
        $docs->[1]->{sum_item_price},
        0,
        'Second document sum_item_price field should be set correctly'
    );

    is_deeply(
        $docs->[1]->{local_classification__sort},
        [substr($long_callno, 0, 255)],
        'Second document local_classification__sort field should be set correctly'
    );

    # Tests for 'year' type
    is_deeply(
      $docs->[1]->{'copydate'},
      ['1963', '2003'],
      'Second document copydate field should be set correctly'
    );
    is_deeply(
      $docs->[1]->{'date-of-publication'},
      ['1900'],
      'Second document date-of-publication field should be set correctly'
    );

    # Third record:

    is_deeply(
      $docs->[2]->{'copydate'},
      ['0890'],
      'Third document copydate field should be set correctly'
    );

    # Mappings marc_type:

    ok(!(defined $docs->[0]->{unimarc_title}), "No mapping when marc_type doesn't match marc flavour");

    # Marc serialization format fallback for records exceeding ISO2709 max record size

    my $large_marc_record = MARC::Record->new();
    $large_marc_record->leader('     cam  22      a 4500');

    $large_marc_record->append_fields(
        MARC::Field->new('100', '', '', a => 'Author 1'),
        MARC::Field->new('110', '', '', a => 'Corp Author'),
        MARC::Field->new('210', '', '', a => 'Title 1'),
        MARC::Field->new('245', '', '', a => 'Title:', b => 'large record'),
        MARC::Field->new('999', '', '', c => '1234567'),
    );

    my $item_field = MARC::Field->new('952', '', '', o => '123456789123456789123456789', p => '123456789', z => 'test');
    my $items_count = 1638;
    while(--$items_count) {
        $large_marc_record->append_fields($item_field);
    }

    $docs = $see->marc_records_to_documents([$large_marc_record]);

    is($docs->[0]->{marc_format}, 'MARCXML', 'For record exceeding max record size marc_format should be set correctly');

    $decoded_marc_record = $see->decode_record_from_result($docs->[0]);

    ok($decoded_marc_record->isa('MARC::Record'), "MARCXML record successfully decoded from result");
    is($decoded_marc_record->as_xml_record(), $large_marc_record->as_xml_record(), "Decoded MARCXML record has same data as original record");

    push @mappings, {
        name => 'title',
        type => 'string',
        facet => 0,
        suggestible => 1,
        sort => 1,
        marc_type => 'marc21',
        marc_field => '245((ab)ab',
    };

    my $exception = try {
        $see->marc_records_to_documents($records);
    }
    catch {
        return $_;
    };

    ok(defined $exception, "Exception has been thrown when processing mapping with unmatched opening parenthesis");
    ok($exception->isa("Koha::Exceptions::Elasticsearch::MARCFieldExprParseError"), "Exception is of correct class");
    ok($exception->message =~ /Unmatched opening parenthesis/, "Exception has the correct message");

    pop @mappings;
    push @mappings, {
        name => 'title',
        type => 'string',
        facet => 0,
        suggestible => 1,
        sort => 1,
        marc_type => 'marc21',
        marc_field => '245(ab))ab',
    };

    $exception = try {
        $see->marc_records_to_documents($records);
    }
    catch {
        return $_;
    };

    ok(defined $exception, "Exception has been thrown when processing mapping with unmatched closing parenthesis");
    ok($exception->isa("Koha::Exceptions::Elasticsearch::MARCFieldExprParseError"), "Exception is of correct class");
    ok($exception->message =~ /Unmatched closing parenthesis/, "Exception has the correct message");

    pop @mappings;
    my $marc_record_with_blank_field = MARC::Record->new();
    $marc_record_with_blank_field->leader('     cam  22      a 4500');

    $marc_record_with_blank_field->append_fields(
        MARC::Field->new('100', '', '', a => ''),
        MARC::Field->new('210', '', '', a => 'Title 1'),
        MARC::Field->new('245', '', '', a => 'Title:', b => 'large record'),
        MARC::Field->new('999', '', '', c => '1234567'),
    );
    $docs = $see->marc_records_to_documents([$marc_record_with_blank_field]);
    is_deeply( $docs->[0]->{author},[],'No value placed into field if mapped marc field is blank');
    is_deeply( $docs->[0]->{author__suggestion},[],'No value placed into suggestion if mapped marc field is blank');

};

subtest 'Koha::SearchEngine::Elasticsearch::marc_records_to_documents_array () tests' => sub {

    plan tests => 5;

    t::lib::Mocks::mock_preference('marcflavour', 'MARC21');
    t::lib::Mocks::mock_preference('ElasticsearchMARCFormat', 'ARRAY');

    my @mappings = (
        {
            name => 'control_number',
            type => 'string',
            facet => 0,
            suggestible => 0,
            sort => undef,
            searchable => 1,
            marc_type => 'marc21',
            marc_field => '001',
        }
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
                $map->{searchable},
                $map->{marc_type},
                $map->{marc_field}
            );
        }
    });

    my $see = Koha::SearchEngine::Elasticsearch::Search->new({ index => $Koha::SearchEngine::Elasticsearch::BIBLIOS_INDEX });

    my $marc_record_1 = MARC::Record->new();
    $marc_record_1->leader('     cam  22      a 4500');
    $marc_record_1->append_fields(
        MARC::Field->new('001', '123'),
        MARC::Field->new('020', '', '', a => '1-56619-909-3'),
        MARC::Field->new('100', '', '', a => 'Author 1'),
        MARC::Field->new('110', '', '', a => 'Corp Author'),
        MARC::Field->new('210', '', '', a => 'Title 1'),
        MARC::Field->new('245', '', '', a => 'Title:', b => 'first record'),
        MARC::Field->new('999', '', '', c => '1234567'),
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
    my $records = [ $marc_record_1, $marc_record_2 ];

    $see->get_elasticsearch_mappings(); #sort_fields will call this and use the actual db values unless we call it first

    my $docs = $see->marc_records_to_documents($records);

    # First record:
    is(scalar @{$docs}, 2, 'Two records converted to documents');

    is_deeply($docs->[0]->{control_number}, ['123'], 'First record control number should be set correctly');

    is($docs->[0]->{marc_format}, 'ARRAY', 'First document marc_format should be set correctly');

    my $decoded_marc_record = $see->decode_record_from_result($docs->[0]);

    ok($decoded_marc_record->isa('MARC::Record'), "ARRAY record successfully decoded from result");
    is($decoded_marc_record->as_usmarc(), $marc_record_1->as_usmarc(), "Decoded ARRAY record has same data as original record");
};

subtest 'Koha::SearchEngine::Elasticsearch::marc_records_to_documents () authority tests' => sub {

    plan tests => 5;

    t::lib::Mocks::mock_preference('marcflavour', 'MARC21');
    t::lib::Mocks::mock_preference('ElasticsearchMARCFormat', 'ISO2709');

    my $builder = t::lib::TestBuilder->new;
    my $auth_type = $builder->build_object({ class => 'Koha::Authority::Types', value =>{
            auth_tag_to_report => '150'
        }
    });

    my @mappings = (
        {
            name => 'match',
            type => 'string',
            facet => 0,
            suggestible => 0,
            searchable => 1,
            sort => 0,
            marc_type => 'marc21',
            marc_field => '150(aevxyz)',
        },
        {
            name => 'match',
            type => 'string',
            facet => 0,
            suggestible => 0,
            searchable => 1,
            sort => 0,
            marc_type => 'marc21',
            marc_field => '185v',
        }
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
                $map->{searchable},
                $map->{marc_type},
                $map->{marc_field}
            );
        }
    });

    my $see = Koha::SearchEngine::Elasticsearch::Search->new({ index => $Koha::SearchEngine::Elasticsearch::AUTHORITIES_INDEX });
    my $marc_record_1 = MARC::Record->new();
    $marc_record_1->append_fields(
        MARC::Field->new('001', '123'),
        MARC::Field->new('007', 'ku'),
        MARC::Field->new('020', '', '', a => '1-56619-909-3'),
        MARC::Field->new('150', '', '', a => 'Subject', v => 'Genresubdiv', x => 'Generalsubdiv', z => 'Geosubdiv'),
    );
    my $marc_record_2 = MARC::Record->new();
    $marc_record_2->append_fields(
        MARC::Field->new('150', '', '', a => 'Subject', v => 'Genresubdiv', z => 'Geosubdiv', x => 'Generalsubdiv', e => 'wrongsubdiv' ),
    );
    my $marc_record_3 = MARC::Record->new();
    $marc_record_3->append_fields(
        MARC::Field->new('185', '', '', v => 'Formsubdiv' ),
    );
    my $records = [ $marc_record_1, $marc_record_2, $marc_record_3 ];

    $see->get_elasticsearch_mappings(); #sort_fields will call this and use the actual db values unless we call it first

    my $docs = $see->marc_records_to_documents($records);

    is_deeply(
        [ "Subject formsubdiv Genresubdiv generalsubdiv Generalsubdiv geographicsubdiv Geosubdiv" ],
        $docs->[0]->{'match-heading'},
        "First record match-heading should contain the correctly formatted heading"
    );
    is_deeply(
        [ "Subject formsubdiv Genresubdiv geographicsubdiv Geosubdiv generalsubdiv Generalsubdiv" ],
        $docs->[1]->{'match-heading'},
        "Second record match-heading should contain the correctly formatted heading without wrong subfield"
    );
    is_deeply(
        [ "Subject Genresubdiv Geosubdiv Generalsubdiv wrongsubdiv" ],
        $docs->[1]->{'match'} ,
        "Second record heading should contain the subfields with record order retained"
    );
    ok( !exists $docs->[2]->{'match-heading'}, "No match heading defined for subdivision record");
    is_deeply(
        [ "Formsubdiv" ],
        $docs->[2]->{'match'} ,
        "Third record heading should contain the subfield"
    );

};

subtest 'Koha::SearchEngine::Elasticsearch::marc_records_to_documents with IncludeSeeFromInSearches' => sub {

    plan tests => 4;

    t::lib::Mocks::mock_preference('marcflavour', 'MARC21');
    t::lib::Mocks::mock_preference('IncludeSeeFromInSearches', '1');
    my $dbh = C4::Context->dbh;

    my $builder = t::lib::TestBuilder->new;
    my $auth_type = $builder->build_object({
        class => 'Koha::Authority::Types',
        value => {
            auth_tag_to_report => '150'
        }
    });
    my $authority_record = MARC::Record->new();
    $authority_record->append_fields(
        MARC::Field->new(150, '', '', a => 'Foo'),
        MARC::Field->new(450, '', '', a => 'Bar'),
    );
    $dbh->do( "INSERT INTO auth_header (datecreated,marcxml) values (NOW(),?)", undef, ($authority_record->as_xml_record('MARC21') ) );
    my $authid = $dbh->last_insert_id( undef, undef, 'auth_header', 'authid' );

    my @mappings = (
        {
            name => 'subject',
            type => 'string',
            facet => 1,
            suggestible => 1,
            sort => undef,
            searchable => 1,
            marc_type => 'marc21',
            marc_field => '650a',
        }
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
                $map->{searchable},
                $map->{marc_type},
                $map->{marc_field}
            );
        }
    });

    my $see = Koha::SearchEngine::Elasticsearch::Search->new({ index => $Koha::SearchEngine::Elasticsearch::BIBLIOS_INDEX });

    my $marc_record_1 = MARC::Record->new();
    $marc_record_1->leader('     cam  22      a 4500');
    $marc_record_1->append_fields(
        MARC::Field->new('001', '123'),
        MARC::Field->new('245', '', '', a => 'Title'),
        MARC::Field->new('650', '', '', a => 'Foo', 9 => $authid),
        MARC::Field->new('999', '', '', c => '1234567'),
    );

    # sort_fields will call this and use the actual db values unless we call it first
    $see->get_elasticsearch_mappings();

    my $docs = $see->marc_records_to_documents([$marc_record_1]);

    is_deeply($docs->[0]->{subject}, ['Foo', 'Bar'], 'subject should include "See from"');
    is_deeply($docs->[0]->{subject__facet}, ['Foo'], 'subject__facet should not include "See from"');
    is_deeply($docs->[0]->{subject__suggestion}, [{ input => 'Foo' }], 'subject__suggestion should not include "See from"');
    is_deeply($docs->[0]->{subject__sort}, ['Foo'], 'subject__sort should not include "See from"');
};

subtest 'marc_records_to_documents should set the "available" field' => sub {
    plan tests => 8;

    t::lib::Mocks::mock_preference('marcflavour', 'MARC21');
    my $dbh = C4::Context->dbh;

    my $se = Test::MockModule->new('Koha::SearchEngine::Elasticsearch');
    $se->noop('_foreach_mapping');

    my $see = Koha::SearchEngine::Elasticsearch::Search->new({ index => $Koha::SearchEngine::Elasticsearch::BIBLIOS_INDEX });

    # sort_fields will call this and use the actual db values unless we call it first
    $see->get_elasticsearch_mappings();

    my $marc_record_1 = MARC::Record->new();
    $marc_record_1->leader('     cam  22      a 4500');
    $marc_record_1->append_fields(
        MARC::Field->new('245', '', '', a => 'Title'),
    );
    my ($biblionumber) = C4::Biblio::AddBiblio($marc_record_1, '', { defer_marc_save => 1 });

    my $docs = $see->marc_records_to_documents([$marc_record_1]);
    is_deeply($docs->[0]->{available}, \0, 'a biblio without items is not available');

    my $item = Koha::Item->new({
        biblionumber => $biblionumber,
    })->store();

    $docs = $see->marc_records_to_documents([$marc_record_1]);
    is_deeply($docs->[0]->{available}, \1, 'a biblio with one item that has no particular status is available');

    $item->notforloan(1)->store();
    $docs = $see->marc_records_to_documents([$marc_record_1]);
    is_deeply($docs->[0]->{available}, \1, 'a biblio with one item that is "notforloan" is available');

    $item->set({ notforloan => 0, onloan => '2022-03-03' })->store();
    $docs = $see->marc_records_to_documents([$marc_record_1]);
    is_deeply($docs->[0]->{available}, \0, 'a biblio with one item that is on loan is not available');

    $item->set({ onloan => undef, withdrawn => 1 })->store();
    $docs = $see->marc_records_to_documents([$marc_record_1]);
    is_deeply($docs->[0]->{available}, \1, 'a biblio with one item that is withdrawn is available');

    $item->set({ withdrawn => 0, itemlost => 1 })->store();
    $docs = $see->marc_records_to_documents([$marc_record_1]);
    is_deeply($docs->[0]->{available}, \0, 'a biblio with one item that is lost is not available');

    $item->set({ itemlost => 0, damaged => 1 })->store();
    $docs = $see->marc_records_to_documents([$marc_record_1]);
    is_deeply($docs->[0]->{available}, \1, 'a biblio with one item that is damaged is available');

    my $item2 = Koha::Item->new({
        biblionumber => $biblionumber,
    })->store();
    $docs = $see->marc_records_to_documents([$marc_record_1]);
    is_deeply($docs->[0]->{available}, \1, 'a biblio with at least one item that has no particular status is available');
};

$schema->storage->txn_rollback;
