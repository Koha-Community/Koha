use Test::More;
use FindBin qw($Bin);

use t::lib::::Mocks;

use Koha::SearchEngine::Index;

t::lib::Mocks::mock_preference('SearchEngine', 'Solr');
my $index_service = Koha::SearchEngine::Index->new;
system( qq{/bin/cp $FindBin::Bin/../indexes.yaml /tmp/indexes.yaml} );
$index_service->searchengine->config->set_config_filename( "/tmp/indexes.yaml" );
is ($index_service->index_record("biblio", [2]), 1, 'test search') ;
is ($index_service->optimize, 1, 'test search') ;

done_testing;
