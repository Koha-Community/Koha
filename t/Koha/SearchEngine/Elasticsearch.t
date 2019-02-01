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
use Try::Tiny;

use Koha::SearchEngine::Elasticsearch;
use Koha::SearchEngine::Elasticsearch::Search;

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

    plan tests => 49;

    t::lib::Mocks::mock_preference('marcflavour', 'MARC21');

    my @mappings = (
        {
            name => 'control_number',
            type => 'string',
            facet => 0,
            suggestible => 0,
            sort => undef,
            marc_type => 'marc21',
            marc_field => '001',
        },
        {
            name => 'isbn',
            type => 'isbn',
            facet => 0,
            suggestible => 0,
            sort => 0,
            marc_type => 'marc21',
            marc_field => '020a',
        },
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
            name => 'title_wildcard',
            type => 'string',
            facet => 0,
            suggestible => 0,
            sort => undef,
            marc_type => 'marc21',
            marc_field => '245',
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
            name => 'local_classification',
            type => 'string',
            facet => 0,
            suggestible => 0,
            sort => 1,
            marc_type => 'marc21',
            marc_field => '952o',
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

    my $see = Koha::SearchEngine::Elasticsearch::Search->new({ index => $Koha::SearchEngine::Elasticsearch::BIBLIOS_INDEX });

    my $callno = 'ABC123';
    my $callno2 = 'ABC456';
    my $long_callno = '1234567890' x 30;

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
        # '  ' for testing trimming of white space in boolean value callback:
        MARC::Field->new('952', '', '', 0 => '  ', g => '123.30', o => $callno),
        MARC::Field->new('952', '', '', 0 => 0, g => '127.20', o => $callno2),
        MARC::Field->new('952', '', '', 0 => 1, g => '0.00', o => $long_callno),
    );
    my $marc_record_2 = MARC::Record->new();
    $marc_record_2->leader('     cam  22      a 4500');
    $marc_record_2->append_fields(
        MARC::Field->new('100', '', '', a => 'Author 2'),
        # MARC::Field->new('210', '', '', a => 'Title 2'),
        # MARC::Field->new('245', '', '', a => 'Title: second record'),
        MARC::Field->new('999', '', '', c => '1234568'),
        MARC::Field->new('952', '', '', 0 => 1, g => 'string where should be numeric', o => $long_callno),
    );
    my $records = [$marc_record_1, $marc_record_2];

    $see->get_elasticsearch_mappings(); #sort_fields will call this and use the actual db values unless we call it first

    my $docs = $see->marc_records_to_documents($records);

    # First record:
    is(scalar @{$docs}, 2, 'Two records converted to documents');

    is($docs->[0][0], '1234567', 'First document biblionumber should be set as first element in document touple');

    is_deeply($docs->[0][1]->{control_number}, ['123'], 'First record control number should be set correctly');

    is(scalar @{$docs->[0][1]->{author}}, 2, 'First document author field should contain two values');
    is_deeply($docs->[0][1]->{author}, ['Author 1', 'Corp Author'], 'First document author field should be set correctly');

    is(scalar @{$docs->[0][1]->{author__sort}}, 1, 'First document author__sort field should have a single value');
    is_deeply($docs->[0][1]->{author__sort}, ['Author 1 Corp Author'], 'First document author__sort field should be set correctly');

    is(scalar @{$docs->[0][1]->{title__sort}}, 1, 'First document title__sort field should have a single');
    is_deeply($docs->[0][1]->{title__sort}, ['Title: first record Title: first record'], 'First document title__sort field should be set correctly');

    is(scalar @{$docs->[0][1]->{title_wildcard}}, 2, 'First document title_wildcard field should have two values');
    is_deeply($docs->[0][1]->{title_wildcard}, ['Title:', 'first record'], 'First document title_wildcard field should be set correctly');

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
        ['false', 'true'],
        'First document items_withdrawn_status field should be set correctly'
    );

    is(
        $docs->[0][1]->{sum_item_price},
        '250.5',
        'First document sum_item_price field should be set correctly'
    );

    ok(defined $docs->[0][1]->{marc_data}, 'First document marc_data field should be set');
    ok(defined $docs->[0][1]->{marc_format}, 'First document marc_format field should be set');
    is($docs->[0][1]->{marc_format}, 'base64ISO2709', 'First document marc_format should be set correctly');

    my $decoded_marc_record = $see->decode_record_from_result($docs->[0][1]);

    ok($decoded_marc_record->isa('MARC::Record'), "base64ISO2709 record successfully decoded from result");
    is($decoded_marc_record->as_usmarc(), $marc_record_1->as_usmarc(), "Decoded base64ISO2709 record has same data as original record");

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

    is(scalar @{$docs->[0][1]->{isbn}}, 4, 'First document isbn field should contain four values');
    is_deeply($docs->[0][1]->{isbn}, ['978-1-56619-909-4', '9781566199094', '1-56619-909-3', '1566199093'], 'First document isbn field should be set correctly');

    is_deeply(
        $docs->[0][1]->{'local_classification'},
        [$callno, $callno2, $long_callno],
        'First document local_classification field should be set correctly'
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

    is_deeply(
        $docs->[1][1]->{local_classification__sort},
        [substr($long_callno, 0, 255)],
        'Second document local_classification__sort field should be set correctly'
    );

    # Mappings marc_type:

    ok(!(defined $docs->[0][1]->{unimarc_title}), "No mapping when marc_type doesn't match marc flavour");

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

    is($docs->[0][1]->{marc_format}, 'MARCXML', 'For record exceeding max record size marc_format should be set correctly');

    $decoded_marc_record = $see->decode_record_from_result($docs->[0][1]);

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
};
