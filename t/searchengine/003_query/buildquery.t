use Modern::Perl;
use Test::More;
use C4::Context;

use Koha::SearchEngine;
use Koha::SearchEngine::QueryBuilder;
use t::lib::Mocks;

my $titleindex = "title";
my $authorindex = "author";
#my $eanindex = "str_ean";
#my $pubdateindex = "date_pubdate";

my ($operands, $indexes, $operators);


# === Solr part ===
@$operands = ('cup', 'rowling');
@$indexes = ('ti', 'au');
@$operators = ('AND');

t::lib::Mocks::mock_preference('SearchEngine', 'Solr');
my $qs = Koha::SearchEngine::QueryBuilder->new;

my $se = Koha::SearchEngine->new;
is( $se->name, "Solr", "Test searchengine name eq Solr" );

my $gotsolr = $qs->build_advanced_query($indexes, $operands, $operators);
my $expectedsolr = "ti:cup AND au:rowling";
is($gotsolr, $expectedsolr, "Test build_query Solr");


# === Zebra part ===
t::lib::Mocks::mock_preference('SearchEngine', 'Zebra');
$se = Koha::SearchEngine->new;
is( $se->name, "Zebra", "Test searchengine name eq Zebra" );
$qs = Koha::SearchEngine::QueryBuilder->new;
my ( $builterror, $builtquery, $simple_query, $query_cgi, $query_desc, $limit, $limit_cgi, $limit_desc, $stopwords_removed, $query_type ) = $qs->build_query($operators, $operands, $indexes);
my $gotzebra = $builtquery;
my $expectedzebra = qq{ti,wrdl= cup AND au,wrdl= rowling };
is($gotzebra, $expectedzebra, "Test Zebra indexes in 'normal' search");


done_testing;
