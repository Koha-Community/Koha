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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 20;
use Test::NoWarnings;

use Koha::Database;
use Koha::SearchFields;
use Koha::SearchMarcMaps;

use_ok('Koha::SearchEngine::Elasticsearch');

my $schema = Koha::Database->new->schema;

$schema->storage->txn_begin;

Koha::SearchFields->search->delete;
Koha::SearchMarcMaps->search->delete;
$schema->resultset('SearchMarcToField')->search->delete;

my $search_field = Koha::SearchFields->find_or_create(
    {
        name         => 'title',
        label        => 'Title',
        type         => 'string',
        weight       => 17,
        staff_client => 0,
        opac         => 1,
        mandatory    => 1
    },
    { key => 'name' }
);

my $marc_field = Koha::SearchMarcMaps->find_or_create(
    {
        index_name => 'biblios',
        marc_type  => 'marc21',
        marc_field => '247'
    }
);

$search_field->add_to_search_marc_maps(
    $marc_field,
    {
        facet       => 0,
        suggestible => 0,
        sort        => 0,
        filter      => '',
    }
);

$marc_field = Koha::SearchMarcMaps->find_or_create(
    {
        index_name => 'biblios',
        marc_type  => 'marc21',
        marc_field => '212'
    }
);

$search_field->add_to_search_marc_maps(
    $marc_field,
    {
        facet       => 0,
        suggestible => 0,
        sort        => 0,
        filter      => '',
    }
);

$marc_field = Koha::SearchMarcMaps->find_or_create(
    {
        index_name => 'biblios',
        marc_type  => 'unimarc',
        marc_field => '200a'
    }
);

$search_field->add_to_search_marc_maps(
    $marc_field,
    {
        facet       => 0,
        suggestible => 1,
        sort        => 0,
        filter      => '',
    }
);

my $mappings = Koha::SearchEngine::Elasticsearch::raw_elasticsearch_mappings();

is( $mappings->{biblios}{title}{type},         'string', 'Title is of type string' );
is( $mappings->{biblios}{title}{label},        'Title',  'title has label Title' );
is( $mappings->{biblios}{title}{facet_order},  undef,    'Facet order is undef' );
is( $mappings->{biblios}{title}{opac},         1,        'title is opac searchable' );
is( $mappings->{biblios}{title}{staff_client}, 0,        'title is not staff searchable' );
is( $mappings->{biblios}{title}{mandatory},    1,        'title is mandatory' );

is( scalar( @{ $mappings->{biblios}{title}{mappings} } ), 3, 'Title has 3 mappings' );

my $f212_map = $mappings->{biblios}{title}{mappings}[0];
is( $f212_map->{marc_field},  212,      'First mapping is on field 212' );
is( $f212_map->{marc_type},   'marc21', 'First mapping is for marc21' );
is( $f212_map->{facet},       '',       'First mapping facet is empty' );
is( $f212_map->{suggestible}, '',       'First mapping is not suggestible' );
is( $f212_map->{sort},        0,        'First mapping is not sortable' );

my $f247_map = $mappings->{biblios}{title}{mappings}[1];
is( $f247_map->{marc_field},  247,      'Second mapping is on field 247' );
is( $f247_map->{marc_type},   'marc21', 'Second mapping is for marc21' );
is( $f247_map->{facet},       '',       'Second mapping facet is empty' );
is( $f247_map->{suggestible}, '',       'Second mapping is not suggestible' );
is( $f247_map->{sort},        0,        'Second mapping is not sortable' );

$mappings = Koha::SearchEngine::Elasticsearch::raw_elasticsearch_mappings('unimarc');

is( scalar( @{ $mappings->{biblios}{title}{mappings} } ), 1, 'Title has 1 mappings' );

$schema->storage->txn_rollback;
