#!/usr/bin/perl

# Tests for Koha/SearchEngine/Search

use Modern::Perl;

use Test::More tests => 2;
use Test::Warn;

use MARC::Field;
use MARC::Record;
use Test::MockModule;
use Test::MockObject;

use t::lib::Mocks;

#use C4::Biblio qw//;
use C4::AuthoritiesMarc;
use C4::Biblio;
use C4::Circulation;
use Koha::Database;
use Koha::SearchEngine::Indexer;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

$schema->storage->txn_begin;

subtest 'Test indexer object creation' => sub {
    plan tests => 6;

    t::lib::Mocks::mock_preference( 'SearchEngine', 'Zebra' );
    my $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });
    is( ref $indexer, 'Koha::SearchEngine::Zebra::Indexer', 'We get the correct class for Zebra biblios');
    $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::AUTHORITIES_INDEX });
    is( ref $indexer, 'Koha::SearchEngine::Zebra::Indexer', 'We get the correct class for Zebra authorities');

    t::lib::Mocks::mock_preference( 'SearchEngine', 'Elasticsearch' );

    SKIP: {

        eval { Koha::SearchEngine::Elasticsearch->get_elasticsearch_params; };

        skip 'Elasticsearch configuration not available', 4
            if $@;

        $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });
        is( ref $indexer, 'Koha::SearchEngine::Elasticsearch::Indexer', 'We get the correct class for Elasticsearch biblios');
        ok( $indexer->index_name =~ /biblios$/, "The index is set correctly for biblios");
        $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::AUTHORITIES_INDEX });
        is( ref $indexer, 'Koha::SearchEngine::Elasticsearch::Indexer', 'We get the correct class for Elasticsearch authorities');
        ok( $indexer->index_name =~ /authorities$/, "The index is set correctly for authorities");

    }
};

subtest 'Test indexer calls' => sub {
    plan tests => 24;

    my @engines = ('Zebra');
    eval { Koha::SearchEngine::Elasticsearch->get_elasticsearch_params; };
    push @engines, 'Elasticsearch' unless $@;
    SKIP: {
    skip 'Elasticsearch configuration not available', 12
            if scalar @engines == 1;
    }

    for my $engine ( @engines ){
        t::lib::Mocks::mock_preference( 'SearchEngine', $engine );
        my $mock_index = Test::MockModule->new("Koha::SearchEngine::".$engine."::Indexer");

        my $biblionumber1 = $builder->build_sample_biblio()->biblionumber;
        my $biblionumber2 = $builder->build_sample_biblio()->biblionumber;

        my $mock_zebra = Test::MockModule->new("Koha::SearchEngine::Zebra::Indexer");
        $mock_zebra->mock( ModZebra => sub { warn "ModZebra"; } );
        my $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });
        warnings_are{
            $indexer->index_records([$biblionumber1,$biblionumber1],"specialUpdate","biblioserver",undef);
        } ["ModZebra","ModZebra"],"ModZebra called for each record being indexed for $engine";

        $mock_index->mock( index_records => sub {
            warn $engine;
            my ($package, undef, undef) = caller;
            warn $package;
        });

        my $auth = MARC::Record->new;
        my $authid;
        warnings_are{
            $authid = AddAuthority( $auth, undef, 'TOPIC_TERM' );
        } [$engine,"C4::AuthoritiesMarc"], "index_records is called for $engine is called when adding authority";

        warnings_are{
            $authid = DelAuthority({ authid => $authid });
        } [$engine,"C4::AuthoritiesMarc"], "index_records is called for $engine is called when adding authority";

        my $biblio;
        my $biblio2;
        warnings_are{
            $biblio = $builder->build_sample_biblio();
            $biblio2 = $builder->build_sample_biblio();
        } [$engine,'C4::Biblio',$engine,'C4::Biblio'], "index_records is called for $engine when adding a biblio (ModBiblioMarc)";


        my $item;
        my $item2;
        warnings_are{
            $item = $builder->build_sample_item({biblionumber => $biblio->biblionumber});
            $item2 = $builder->build_sample_item({biblionumber => $biblio->biblionumber});
        } [$engine,"Koha::Item",$engine,"Koha::Item"], "index_records is called for $engine when adding an item (Item->store)";
        warnings_are{
            $item->store({ skip_modzebra_update => 1 });
        } undef, "index_records is not called for $engine when adding an item (Item->store) if skip_modzebra_update passed";

        $builder->build({
            source => 'Branchtransfer',
            value => {
                itemnumber => $item->itemnumber,
                datearrived => undef}
        });
        warnings_are{
            LostItem( $item->itemnumber, "tests");
        } [$engine,"Koha::Item"], "index_records is called for $engine when calling LostItem and transfer exists";
        $builder->build({
            source => 'Branchtransfer',
            value => {
                itemnumber => $item2->itemnumber,
                datearrived => undef}
        });
        warnings_are{
            LostItem( $item->itemnumber, "tests", undef, { skip_modzebra_update => 1 });
        } undef, "index_records is not called for $engine when calling LostItem and transfer exists if skip_modzebra_update";

        warnings_are{
            $item->delete();
        } [$engine,"Koha::Item"], "index_records is called for $engine when deleting an item (Item->delete)";
        warnings_are{
            $item2->delete({ skip_modzebra_update => 1 });
        } undef, "index_records is not called for $engine when adding an item (Item->store) if skip_modzebra_update passed";

        warnings_are{
            DelBiblio( $biblio->biblionumber );
        } [$engine, "C4::Biblio"], "index_records is called for $engine when calling DelBiblio";
        warnings_are{
            DelBiblio( $biblio->biblionumber, { skip_record_index =>1 });
        } undef, "index_records is not called for $engine when calling DelBiblio if skip_record_index passed";

    }

};

$schema->storage->txn_rollback;
