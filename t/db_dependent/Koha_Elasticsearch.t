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
# along with Koha; if not, see <http://www.gnu.org/licenses>

use Modern::Perl;

use Test::More tests => 2;
use Test::MockModule;

use t::lib::Mocks;
use MARC::Record;

my $schema = Koha::Database->schema;

use_ok('Koha::SearchEngine::Elasticsearch');

subtest 'get_fixer_rules() tests' => sub {

    plan tests => 49;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );

    my @mappings;

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

    my $see = Koha::SearchEngine::Elasticsearch->new({ index => 'biblios' });

    @mappings = (
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
    );

    $see->get_elasticsearch_mappings(); #sort_fields will call this and use the actual db values unless we call it first
    my $result = $see->get_fixer_rules();
    is( $result->[0], q{marc_map('} . $mappings[0]->{marc_field} . q{','} . $mappings[0]->{name} . q{.$append', )});
    is( $result->[1], q{marc_map('} . $mappings[0]->{marc_field} . q{','} . $mappings[0]->{name} . q{__facet.$append', )});
    is( $result->[2], q{marc_map('} . $mappings[0]->{marc_field} . q{','} . $mappings[0]->{name} . q{__suggestion.input.$append')});
    is( $result->[3], q{marc_map('} . $mappings[0]->{marc_field} . q{','} . $mappings[0]->{name} . q{__sort.$append', )});
    is( $result->[4], q{marc_map('} . $mappings[1]->{marc_field} . q{','} . $mappings[1]->{name} . q{.$append', )});
    is( $result->[5], q{marc_map('} . $mappings[1]->{marc_field} . q{','} . $mappings[1]->{name} . q{__facet.$append', )});
    is( $result->[6], q{marc_map('} . $mappings[1]->{marc_field} . q{','} . $mappings[1]->{name} . q{__suggestion.input.$append')});
    is( $result->[7], q{marc_map('} . $mappings[1]->{marc_field} . q{','} . $mappings[1]->{name} . q{__sort.$append', )});
    is( $result->[8], q{move_field(_id,es_id)});

    $mappings[0]->{type}  = 'boolean';
    $mappings[1]->{type}  = 'boolean';
    $result = $see->get_fixer_rules();
    is( $result->[0], q{marc_map('} . $mappings[0]->{marc_field} . q{','} . $mappings[0]->{name} . q{.$append', )});
    is( $result->[1], q{marc_map('} . $mappings[0]->{marc_field} . q{','} . $mappings[0]->{name} . q{__facet.$append', )});
    is( $result->[2], q{marc_map('} . $mappings[0]->{marc_field} . q{','} . $mappings[0]->{name} . q{__suggestion.input.$append')});
    is( $result->[3], q{unless exists('} . $mappings[0]->{name} . q{') add_field('} . $mappings[0]->{name} . q{', 0) end});
    is( $result->[4], q{marc_map('} . $mappings[0]->{marc_field} . q{','} . $mappings[0]->{name} . q{__sort.$append', )});
    is( $result->[5], q{marc_map('} . $mappings[1]->{marc_field} . q{','} . $mappings[1]->{name} . q{.$append', )});
    is( $result->[6], q{marc_map('} . $mappings[1]->{marc_field} . q{','} . $mappings[1]->{name} . q{__facet.$append', )});
    is( $result->[7], q{marc_map('} . $mappings[1]->{marc_field} . q{','} . $mappings[1]->{name} . q{__suggestion.input.$append')});
    is( $result->[8], q{unless exists('} . $mappings[1]->{name} . q{') add_field('} . $mappings[1]->{name} . q{', 0) end});
    is( $result->[9], q{marc_map('} . $mappings[1]->{marc_field} . q{','} . $mappings[1]->{name} . q{__sort.$append', )});
    is( $result->[10], q{move_field(_id,es_id)});

    $mappings[0]->{type}  = 'sum';
    $mappings[1]->{type}  = 'sum';
    $result = $see->get_fixer_rules();
    is( $result->[0], q{marc_map('} . $mappings[0]->{marc_field} . q{','} . $mappings[0]->{name} . q{.$append', )});
    is( $result->[1], q{marc_map('} . $mappings[0]->{marc_field} . q{','} . $mappings[0]->{name} . q{__facet.$append', )});
    is( $result->[2], q{marc_map('} . $mappings[0]->{marc_field} . q{','} . $mappings[0]->{name} . q{__suggestion.input.$append')});
    is( $result->[3], q{sum('} . $mappings[0]->{name} . q{')});
    is( $result->[4], q{marc_map('} . $mappings[0]->{marc_field} . q{','} . $mappings[0]->{name} . q{__sort.$append', )});
    is( $result->[5], q{marc_map('} . $mappings[1]->{marc_field} . q{','} . $mappings[1]->{name} . q{.$append', )});
    is( $result->[6], q{marc_map('} . $mappings[1]->{marc_field} . q{','} . $mappings[1]->{name} . q{__facet.$append', )});
    is( $result->[7], q{marc_map('} . $mappings[1]->{marc_field} . q{','} . $mappings[1]->{name} . q{__suggestion.input.$append')});
    is( $result->[8], q{sum('} . $mappings[1]->{name} . q{')});
    is( $result->[9], q{marc_map('} . $mappings[1]->{marc_field} . q{','} . $mappings[1]->{name} . q{__sort.$append', )});
    is( $result->[10], q{move_field(_id,es_id)});

    $mappings[0]->{type}  = 'string';
    $mappings[0]->{facet} = 0;
    $mappings[1]->{type}  = 'string';
    $mappings[1]->{facet} = 0;

    $result = $see->get_fixer_rules();
    is( $result->[0], q{marc_map('} . $mappings[0]->{marc_field} . q{','} . $mappings[0]->{name} . q{.$append', )});
    is( $result->[1], q{marc_map('} . $mappings[0]->{marc_field} . q{','} . $mappings[0]->{name} . q{__suggestion.input.$append')});
    is( $result->[2], q{marc_map('} . $mappings[0]->{marc_field} . q{','} . $mappings[0]->{name} . q{__sort.$append', )});
    is( $result->[3], q{marc_map('} . $mappings[1]->{marc_field} . q{','} . $mappings[1]->{name} . q{.$append', )});
    is( $result->[4], q{marc_map('} . $mappings[1]->{marc_field} . q{','} . $mappings[1]->{name} . q{__suggestion.input.$append')});
    is( $result->[5], q{marc_map('} . $mappings[1]->{marc_field} . q{','} . $mappings[1]->{name} . q{__sort.$append', )});
    is( $result->[6], q{move_field(_id,es_id)});

    $mappings[0]->{suggestible}  = 0;
    $mappings[1]->{suggestible}  = 0;

    $result = $see->get_fixer_rules();
    is( $result->[0], q{marc_map('} . $mappings[0]->{marc_field} . q{','} . $mappings[0]->{name} . q{.$append', )});
    is( $result->[1], q{marc_map('} . $mappings[0]->{marc_field} . q{','} . $mappings[0]->{name} . q{__sort.$append', )});
    is( $result->[2], q{marc_map('} . $mappings[1]->{marc_field} . q{','} . $mappings[1]->{name} . q{.$append', )});
    is( $result->[3], q{marc_map('} . $mappings[1]->{marc_field} . q{','} . $mappings[1]->{name} . q{__sort.$append', )});
    is( $result->[4], q{move_field(_id,es_id)});

    $mappings[0]->{sort}  = 0;
    $mappings[1]->{sort}  = undef;

    $see->get_elasticsearch_mappings(); #sort_fields will call this and use the actual db values unless we call it first
    $result = $see->get_fixer_rules();
    is( $result->[0], q{marc_map('} . $mappings[0]->{marc_field} . q{','} . $mappings[0]->{name} . q{.$append', )});
    is( $result->[1], q{marc_map('} . $mappings[1]->{marc_field} . q{','} . $mappings[1]->{name} . q{.$append', )});
    is( $result->[2], q{marc_map('} . $mappings[1]->{marc_field} . q{','} . $mappings[1]->{name} . q{__sort.$append', )});
    is( $result->[3], q{move_field(_id,es_id)});

    t::lib::Mocks::mock_preference( 'marcflavour', 'UNIMARC' );

    $result = $see->get_fixer_rules();
    is( $result->[0], q{move_field(_id,es_id)});
    is( $result->[1], undef, q{No mapping when marc_type doesn't match marchflavour} );

    $schema->storage->txn_rollback;

};
