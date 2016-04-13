#
#===============================================================================
#
#         FILE: Koha_SearchEngine_Elasticsearch_Search.t
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Chris Cormack (rangi), chrisc@catalyst.net.nz
# ORGANIZATION: Koha Development Team
#      VERSION: 1.0
#      CREATED: 09/12/13 09:43:29
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 5;    # last test to print
use Koha::SearchEngine::Elasticsearch::QueryBuilder;

my $builder = Koha::SearchEngine::Elasticsearch::QueryBuilder->new( { index => 'mydb' } );

use_ok('Koha::SearchEngine::Elasticsearch::Search');

ok(
    my $searcher = Koha::SearchEngine::Elasticsearch::Search->new(
        { 'nodes' => ['localhost:9200'], 'index' => 'mydb' }
    ),
    'Creating a Koha::ElasticSearch::Search object'
);

is( $searcher->index, 'mydb', 'Testing basic accessor' );

ok( my $query = $builder->build_query('easy'), 'Build a search query');

ok( my $results = $searcher->search( $query) , 'Do a search ' );
