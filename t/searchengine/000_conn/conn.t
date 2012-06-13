use Modern::Perl;
use Test::More;
use Koha::SearchEngine::Solr;
use Koha::SearchEngine::Zebra;
use Koha::SearchEngine::Search;
use t::lib::Mocks;

my $se_index = Koha::SearchEngine::Solr->new;
ok($se_index->isa('Data::SearchEngine::Solr'), 'Solr is a Solr data searchengine');

$se_index = Koha::SearchEngine::Zebra->new;
ok($se_index->isa('Data::SearchEngine::Zebra'), 'Zebra search engine');

set_solr();
$se_index = Koha::SearchEngine::Search->new;
ok($se_index->searchengine->isa('Data::SearchEngine::Solr'), 'Solr search engine');

set_zebra();
$se_index = Koha::SearchEngine::Search->new;
ok($se_index->searchengine->isa('Data::SearchEngine::Zebra'), 'Zebra search engine');


done_testing;
