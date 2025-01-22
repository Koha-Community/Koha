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

use Test::NoWarnings;
use Test::More tests => 8;
use Test::MockModule;

use Koha::Database;
use Koha::Caches;

my $indexes = {
    'authorities' => {
        'Match' => {
            'label'     => 'Match',
            'type'      => '',
            'weight'    => 15,
            'mandatory' => 0,
            'mappings'  => []
        }
    },
    'biblios' => {
        'title' => {
            'label'     => 'title',
            'type'      => '',
            'weight'    => 20,
            'mandatory' => 1,
            'mapping'   => []
        }
    }
};

my $yaml = Test::MockModule->new('YAML::XS');
$yaml->mock( 'LoadFile', sub { return $indexes; } );

use_ok('Koha::SearchEngine::Elasticsearch');

my $schema = Koha::Database->new->schema;

$schema->storage->txn_begin;

Koha::SearchFields->search->delete;
Koha::SearchMarcMaps->search->delete;
$schema->resultset('SearchMarcToField')->search->delete;

Koha::SearchEngine::Elasticsearch->reset_elasticsearch_mappings;

my $cache = Koha::Caches->get_instance();
is(
    $cache->get_from_cache('elasticsearch_search_fields_staff_client'), undef,
    'Cache has been flushed by reset_elasticsearch_mappings'
);

my $search_fields = Koha::SearchFields->search( {} );
is( $search_fields->count, 2, 'There is 2 search fields after reset' );

my $match_sf = Koha::SearchFields->search( { name => 'Match' } )->next;
is( $match_sf->weight,    '15.00', 'Match search field is weighted with 15' );
is( $match_sf->mandatory, '0',     'Match search field is not mandatory' );

my $title_sf = Koha::SearchFields->search( { name => 'title' } )->next;
is( $title_sf->weight,    '20.00', 'Title search field is weighted with 20' );
is( $title_sf->mandatory, '1',     'Title search field is mandatory' );

$schema->storage->txn_rollback;

Koha::SearchEngine::Elasticsearch->clear_search_fields_cache();
