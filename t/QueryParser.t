#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Module::Load::Conditional qw(can_load);

BEGIN {
    use_ok( 'Koha::QueryParser::Driver::PQF' );
}

my $QParser = Koha::QueryParser::Driver::PQF->new();

ok(defined $QParser, 'Successfully created empty QP object');
ok($QParser->load_config('./etc/searchengine/queryparser.yaml'), 'Loaded QP config');

is($QParser->search_class_count, 4, 'Initialized 4 search classes');
is (scalar(@{$QParser->search_fields()->{'keyword'}}), 111, "Correct number of search fields for 'keyword' class");

# Set keyword search as the default
$QParser->default_search_class('keyword');

my $kwd_search = q/@attr 1=1016 @attr 4=6/;
my $weight1    = q/@attr 2=102 @attr 9=20 @attr 4=6/;
my $weight2    = q/@attr 2=102 @attr 9=34 @attr 4=6/;

like( $QParser->target_syntax('biblioserver', 'smith'),
    qr/\@or \@or $kwd_search "smith" ($weight1 "smith" $weight2 "smith"|$weight2 "smith" $weight1 "smith")/,
    'super simple keyword query');

is($QParser->target_syntax('biblioserver', 'au:smith'),
    '@attr 1=1003 @attr 4=6 "smith"', 'simple author query');

is($QParser->target_syntax('biblioserver', 'keyword|publisher:smith'),
    '@attr 1=1018 @attr 4=6 "smith"', 'fielded publisher query');

is($QParser->target_syntax('biblioserver', 'ti:"little engine that could"'),
    '@attr 1=4 @attr 4=1 "little engine that could"', 'phrase query');

is($QParser->target_syntax('biblioserver', 'keyword|titlekw:smith'),
    '@attr 1=4 @attr 2=102 @attr 9=20 @attr 4=6 "smith"',
    'relevance-bumped query');

is($QParser->target_syntax('biblioserver', 'au:smith && johnson'),
    '@and @attr 1=1003 @attr 4=6 "smith" @attr 1=1003 @attr 4=6 "johnson"',
    'query with boolean &&');

is($QParser->target_syntax('biblioserver', 'au:smith && ti:johnson'),
    '@and @attr 1=1003 @attr 4=6 "smith" @attr 1=4 @attr 4=6 "johnson"', 'query with boolean &&');

is($QParser->target_syntax('biblioserver', 'au:smith pubdate(-2008)'),
    '@and @attr 1=1003 @attr 4=6 "smith" @attr 1=31 @attr 4=4 @attr 2=2 "2008"',
    'keyword search with pubdate limited to -2008');

is($QParser->target_syntax('biblioserver', 'au:smith pubdate(2008-)'),
    '@and @attr 1=1003 @attr 4=6 "smith" @attr 1=31 @attr 4=4 @attr 2=4 "2008"',
    'keyword search with pubdate limited to 2008-');

is($QParser->target_syntax('biblioserver', 'au:smith pubdate(2008)'),
    '@and @attr 1=1003 @attr 4=6 "smith" @attr 1=31 @attr 4=4 "2008"',
    'keyword search with pubdate limited to 2008');

is($QParser->target_syntax('biblioserver', 'au:smith pubdate(1980,2008)'),
    '@and @attr 1=1003 @attr 4=6 "smith" @or @attr 1=31 @attr 4=4 "1980" @attr 1=31 @attr 4=4 "2008"',
    'keyword search with pubdate limited to 1980, 2008');

is($QParser->target_syntax('biblioserver', 'au:smith #acqdate_dsc'),
    '@or @attr 1=32 @attr 7=1 0 @attr 1=1003 @attr 4=6 "smith"',
    'keyword search sorted by acqdate descending');

is($QParser->bib1_mapping_by_attr('field', 'biblioserver', {'1' => '1004'})->{'field'},
    'personal', 'retrieve field by attr');

is($QParser->bib1_mapping_by_attr_string('field', 'biblioserver', '@attr 1=1004')->{'field'},
    'personal', 'retrieve field by attrstring');

is ($QParser->clear_all_mappings, $QParser, 'clear all mappings returns self');
is ($QParser->clear_all_configuration, $QParser, 'clear all configuration returns self');
is (scalar(keys(%{$QParser->search_fields})), 0, "All mapping erased");

$QParser->add_bib1_field_map('author' => 'personal' => 'biblioserver' => { '1' => '1004' } );
$QParser->add_bib1_modifier_map('relevance' => 'biblioserver' => { '2' => '102' } );
my $desired_config = {
  'field_mappings' => {
    'author' => {
      'personal' => {
        'aliases' => [ ],
        'bib1_mapping' => {
          'biblioserver' => {
            '1' => '1004'
          }
        },
        'enabled' => '1',
        'index' => 'personal',
        'label' => 'Personal'
      }
    }
  },
  'filter_mappings' => {},
  'modifier_mappings' => {
    'relevance' => {
      'bib1_mapping' => {
        'biblioserver' => {
          '2' => '102'
        }
      },
      'enabled' => 1,
      'label' => 'Relevance'
    }
  },
  'relevance_bumps' => {}
};

SKIP: {
    my $got_config;
    skip 'YAML is unavailable', 2 unless can_load('modules' => { 'YAML::Any' => undef });
    $got_config = YAML::Any::Load($QParser->serialize_mappings());
    ok(ref $got_config, 'serialized YAML valid');
    is_deeply($got_config, $desired_config, 'Mappings serialized correctly to YAML');

    skip 'JSON is unavailable', 2 unless can_load('modules' => { 'JSON' => undef });
    undef $got_config;
    eval {
        $got_config = JSON::from_json($QParser->serialize_mappings('json'));
    };
    is($@, '', 'serialized JSON valid');
    is_deeply($got_config, $desired_config, 'Mappings serialized correctly to JSON');
}

$QParser->clear_all_mappings;
is($QParser->TEST_SETUP, $QParser, 'TEST_SETUP returns self');
is($QParser->search_class_count, 4, 'Initialized 4 search classes in test setup');

done_testing();
