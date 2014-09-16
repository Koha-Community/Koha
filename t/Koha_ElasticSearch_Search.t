#
#===============================================================================
#
#         FILE: Koha_ElasticSearch_Search.t
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

use_ok('Koha::ElasticSearch::Search');

ok(
    my $searcher = Koha::ElasticSearch::Search->new(
        { 'nodes' => ['localhost:9200'], 'index' => 'mydb' }
    ),
    'Creating a Koha::ElasticSearch::Search object'
);

is( $searcher->index, 'mydb', 'Testing basic accessor' );

ok( $searcher->connect, 'Connect to ElasticSearch server' );
ok( my $results = $searcher->search( { record => 'easy' } ), 'Do a search ' );

ok( my $marcresults = $searcher->marc_search( { record => 'Fish' } ),
    'Do a marc search' );
