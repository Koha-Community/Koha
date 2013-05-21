use Test::More;

use t::lib::Mocks;

t::lib::Mocks::mock_preference('SearchEngine', 'Solr');
use Koha::SearchEngine::Search;
my $search_service = Koha::SearchEngine::Search->new;
isnt (scalar $search_service->search("fort"), 0, 'test search') ;

#$search_service->search($query_service->build_query(@,@,@));

done_testing;
