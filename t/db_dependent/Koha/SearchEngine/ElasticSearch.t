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

use Modern::Perl qw(2014);
use utf8;
use Test::More;

use Koha::SearchEngine::Elasticsearch;
use Koha::SearchMappingManager;


subtest "Reset Elasticsearch mappings", \&reset_elasticsearch_mappings;
sub reset_elasticsearch_mappings {
    my ($rv, $mappings, $count, $mapping);

    ok(1, 'Scenario: Reset Elasticsearch mappings to an empty database');
    #There might or might not be any mappings. Whatever the initial status is, make sure we start from empty tables
    $rv = Koha::SearchMappingManager::flush();
    ok($rv, 'Given empty search mapping tables');
    eval {
        $rv = Koha::SearchEngine::Elasticsearch->reset_elasticsearch_mappings();
    };
    if ($@){
        ok(0, $@);
    }
    ok(not($@), 'When reset_elasticsearch_mappings() has been ran');

    $mappings = Koha::SearchMappingManager::get_search_mappings({index_name => 'biblios'});
    $count = $mappings->count();
    ok($count, 'Then search mapping tables have been populated');



    ok(1, 'Scenario: Reset Elasticsearch mappings when custom mappings already exist');
    $rv = Koha::SearchMappingManager::add_mapping({name => 'ln-test',
                                                   label => 'original language',
                                                   type => 'keyword',
                                                   index_name => 'biblios',
                                                   marc_type => 'marc21',
                                                   marc_field => '024a',
                                                   facet => 1,
                                                   suggestible => 1,
                                                   sort => 1});
    ok($rv, 'Given a mapping table with a custom search field');
    eval {
        $rv = Koha::SearchEngine::Elasticsearch->reset_elasticsearch_mappings();
    };
    if ($@){
        ok(0, $@);
    }
    ok(not($@), 'When reset_elasticsearch_mappings() has been ran');

    $mappings = Koha::SearchMappingManager::get_search_mappings({index_name => 'biblios'});
    $count = $mappings->count();
    ok($count > 10, 'Then search mapping tables have been populated');
}

subtest "Get Elasticsearch mappings", \&get_search_mappings;
sub get_search_mappings {
    my ($mappings, $mapping);

    ok(1, 'Scenario: Get a single search mapping by name');
    $mappings = Koha::SearchMappingManager::get_search_mappings({index_name => 'biblios', name => 'ff7-00'});
    ok($mappings, 'When a search mappings is fetched');
    $mapping = $mappings->next();
    is($mapping->get_column('name'),       'ff7-00', 'Then the search mapping "name" matches');
    is($mapping->get_column('type'),       '',       'And the search mapping "type" matches');
    is($mapping->get_column('facet'),      '0',      'And the search mapping "facet" matches');
    is($mapping->get_column('suggestible'), '0',     'And the search mapping "suggestible" matches');
    is($mapping->get_column('sort'),        undef,   'And the search mapping "sort" matches');
    is($mapping->get_column('marc_type'),  'marc21', 'And the search mapping "marc_type" matches');
    is($mapping->get_column('marc_field'), '007_/1', 'And the search mapping "marc_field" matches');

    ok(1, 'Scenario: Get all search mappings');
    $mappings = Koha::SearchMappingManager::get_search_mappings({index_name => 'biblios'});
    ok($mappings, 'When search mappings are fetched');
    ok($mappings->count() > 10, 'Then we have "'.$mappings->count().'" search mappings :)')
}

subtest "Add a search mapping", \&add_mapping;
sub add_mapping {
    my ($rv, $mappings, $mapping, $count);

    ok(1, "Scenario: Add the same mapping twice and hope for no duplicate mappings");
    $rv = Koha::SearchMappingManager::add_mapping({name => 'ln-test',
                                                   label => 'original language',
                                                   type => 'keyword',
                                                   index_name => 'biblios',
                                                   marc_type => 'marc21',
                                                   marc_field => '024a',
                                                   facet => 1,
                                                   suggestible => 1,
                                                   sort => 1});
    $rv = Koha::SearchMappingManager::add_mapping({name => 'ln-test',
                                                   label => 'original language',
                                                   type => 'keyword',
                                                   index_name => 'biblios',
                                                   marc_type => 'marc21',
                                                   marc_field => '024a',
                                                   facet => 1,
                                                   suggestible => 1,
                                                   sort => 1});
    ok(1, "When the same search mapping is added twice");

    $mappings = Koha::SearchMappingManager::get_search_mappings({index_name => 'biblios', name => 'ln-test'});
    $count = $mappings->count();
    is($count, 1, "Then we received only one mapping from the database");
}

done_testing;
