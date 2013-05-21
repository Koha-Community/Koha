use Modern::Perl;
use Test::More;
use FindBin qw($Bin);

use C4::Context;
use Koha::SearchEngine;
use t::lib::Mocks;

t::lib::Mocks::mock_preference('SearchEngine', 'Solr');
my $se = Koha::SearchEngine->new;
is( $se->name, "Solr", "Test searchengine name eq Solr" );

my $config = $se->config;
$config->set_config_filename( "$FindBin::Bin/../indexes.yaml" );
my $ressource_types = $config->ressource_types;
is ( grep ( /^biblio$/, @$ressource_types ), 1, "Ressource type biblio must to be defined" );
is ( grep ( /^authority$/, @$ressource_types ), 1, "Ressource type authority must to be defined" );

my $indexes = $config->indexes;
is ( scalar(@$indexes), 3, "There are 3 indexes configured" );

my $index1 = @$indexes[0];
is ( $index1->{code}, 'title', "My index first have code=title");
is ( $index1->{label}, 'Title', "My index first have label=Title");
is ( $index1->{type}, 'ste', "My index first have type=ste");
is ( $index1->{ressource_type}, 'biblio', "My index first have ressource_type=biblio");
is ( $index1->{sortable}, '1', "My index first have sortable=1");
is ( $index1->{mandatory}, '1', "My index first have mandatory=1");
eq_array ( $index1->{mappings}, ["200\$a", "4..\$t"], "My first index have mappings=[200\$a,4..\$t]");

system( qq{/bin/cp $FindBin::Bin/../indexes.yaml /tmp/indexes.yaml} );
$config->set_config_filename( "/tmp/indexes.yaml" );
$indexes = $config->indexes;
my $new_index = {
    code => 'isbn',
    label => 'ISBN',
    type => 'str',
    ressource_type => 'biblio',
    sortable => 0,
    mandatory => 0
};
push @$indexes, $new_index;
$config->indexes( $indexes );

$indexes = $config->indexes;

my $isbn_index = $config->index( 'isbn' );
is( $isbn_index->{code}, 'isbn', 'Index isbn has been written' );

my $sortable_indexes = $config->sortable_indexes;
is ( @$sortable_indexes, 2, "There are 2 sortable indexes" );

done_testing;
