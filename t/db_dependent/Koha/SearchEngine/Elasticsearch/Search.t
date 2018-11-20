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

use Test::More tests => 11;
use t::lib::Mocks;

use Koha::SearchEngine::Elasticsearch::QueryBuilder;
use Koha::SearchEngine::Elasticsearch::Indexer;


my $se = Test::MockModule->new( 'Koha::SearchEngine::Elasticsearch' );
$se->mock( 'get_elasticsearch_mappings', sub {
    my ($self) = @_;

    my %all_mappings;

    my $mappings = {
        data => {
            properties => {
                title => {
                    type => 'text'
                },
                title__sort => {
                    type => 'text'
                },
                subject => {
                    type => 'text'
                },
                itemnumber => {
                    type => 'integer'
                },
                sortablenumber => {
                    type => 'integer'
                },
                sortablenumber__sort => {
                    type => 'integer'
                }
            }
        }
    };
    $all_mappings{$self->index} = $mappings;

    my $sort_fields = {
        $self->index => {
            title => 1,
            subject => 0,
            itemnumber => 0,
            sortablenumber => 1
        }
    };
    $self->sort_fields($sort_fields->{$self->index});

    return $all_mappings{$self->index};
});

my $builder = Koha::SearchEngine::Elasticsearch::QueryBuilder->new( { index => 'mydb' } );

use_ok('Koha::SearchEngine::Elasticsearch::Search');

ok(
    my $searcher = Koha::SearchEngine::Elasticsearch::Search->new(
        { 'nodes' => ['localhost:9200'], 'index' => 'mydb' }
    ),
    'Creating a Koha::SearchEngine::Elasticsearch::Search object'
);

is( $searcher->index, 'mydb', 'Testing basic accessor' );

ok( my $query = $builder->build_query('easy'), 'Build a search query');

SKIP: {

    eval { $builder->get_elasticsearch_params; };

    skip 'Elasticsearch configuration not available', 8
        if $@;

    Koha::SearchEngine::Elasticsearch::Indexer->new({ index => 'mydb' })->drop_index;
    Koha::SearchEngine::Elasticsearch::Indexer->new({ index => 'mydb' })->create_index;

    ok( my $results = $searcher->search( $query) , 'Do a search ' );

    is (my $count = $searcher->count( $query ), 0 , 'Get a count of the results, without returning results ');

    ok ($results = $searcher->search_compat( $query ), 'Test search_compat' );

    ok (($results,$count) = $searcher->search_auth_compat ( $query ), 'Test search_auth_compat' );

    is ( $count = $searcher->count_auth_use($searcher,1), 0, 'Testing count_auth_use');

    is ($searcher->max_result_window, 10000, 'By default, max_result_window is 10000');
    $searcher->store->es->indices->put_settings(index => $searcher->store->index_name, body => {
        'index' => {
            'max_result_window' => 12000,
        },
    });
    is ($searcher->max_result_window, 12000, 'max_result_window returns the correct value');
}
