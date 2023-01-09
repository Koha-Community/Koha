#!/usr/bin/perl

# Tests for Koha/SearchEngine/Search

use Modern::Perl;

use Test::More tests => 3;
use Test::Warn;

use MARC::Field;
use MARC::Record;
use Test::MockModule;
use Test::MockObject;

use t::lib::Mocks;

#use C4::Biblio qw//;
use C4::AuthoritiesMarc qw( AddAuthority DelAuthority merge );
use C4::Biblio qw( ModZebra ModBiblio ModBiblioMarc DelBiblio );
use C4::Circulation qw( MarkIssueReturned AddReturn LostItem AddRenewal );
use C4::Items qw( ModDateLastSeen ModItemTransfer );
use Koha::Database;
use Koha::SearchEngine::Elasticsearch;
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
    plan tests => 48;

    my @engines = ('Zebra');
    eval { Koha::SearchEngine::Elasticsearch->get_elasticsearch_params; };
    push @engines, 'Elasticsearch' unless $@;
    SKIP: {
    skip 'Elasticsearch configuration not available', 20
            if scalar @engines == 1;
    }

    t::lib::Mocks::mock_preference( 'AutoLinkBiblios', 0 );

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
            $authid = DelAuthority({ authid => $authid, skip_merge => 1 });
        } [$engine,"C4::AuthoritiesMarc"], "index_records is called for $engine is called when adding authority";

        my $biblio;
        my $biblio2;
        my $biblio3;
        warnings_are{
            $biblio = $builder->build_sample_biblio();
            $biblio2 = $builder->build_sample_biblio();
            $biblio3 = $builder->build_sample_biblio();
        } [$engine,'C4::Biblio',$engine,'C4::Biblio',$engine,'C4::Biblio'], "index_records is called for $engine when adding a biblio (ModBiblioMarc)";

        my $item;
        my $item2;
        my $item3;
        my $item4;
        my $item5;
        my $item6;
        warnings_are{
            $item = $builder->build_sample_item({
                biblionumber => $biblio->biblionumber,
                onloan => '2020-02-02',
                datelastseen => '2020-01-01',
                replacementprice => 0
            });
            $item2 = $builder->build_sample_item({
                biblionumber => $biblio->biblionumber,
                onloan => '2020-12-12',
                datelastseen => '2020-11-11',
                replacementprice => 0
            });
            $item3 = $builder->build_sample_item({biblionumber => $biblio->biblionumber});
            $item4 = $builder->build_sample_item({biblionumber => $biblio->biblionumber});
            $item5 = $builder->build_sample_item({biblionumber => $biblio3->biblionumber});
            $item6 = $builder->build_sample_item({biblionumber => $biblio3->biblionumber});
        } [$engine,"Koha::Item",
           $engine,"Koha::Item",
           $engine,"Koha::Item",
           $engine,"Koha::Item",
           $engine,"Koha::Item",
           $engine,"Koha::Item"], "index_records is called for $engine when adding an item (Item->store)";
        warnings_are{
            $item->store({ skip_record_index => 1 });
        } undef, "index_records is not called for $engine when adding an item (Item->store) if skip_record_index passed";

        my $issue = $builder->build({
            source => 'Issue',
            value  => {
                itemnumber => $item->itemnumber
            }
        });
        my $issue2 = $builder->build({
            source => 'Issue',
            value  => {
                itemnumber => $item2->itemnumber
            }
        });
        warnings_are{
            MarkIssueReturned( $issue->{borrowernumber}, $item->itemnumber);
        } [$engine,"Koha::Item"], "index_records is called for $engine when calling MarkIssueReturned";
        warnings_are{
            MarkIssueReturned( $issue2->{borrowernumber}, $item2->itemnumber, undef, undef, { skip_record_index => 1});
        } undef, "index_records is not called for $engine when calling MarkIssueReturned if skip_record_index passed";

        warnings_are{
            AddReturn($item->barcode, $item->homebranch, 0, undef);
        } [$engine,'C4::Circulation'], "index_records is called once for $engine when calling AddReturn if item not issued";
        $issue = $builder->build({
            source => 'Issue',
            value  => {
                itemnumber => $item->itemnumber
            }
        });
        warnings_are{
            AddReturn($item->barcode, $item->homebranch, 0, undef);
        } [$engine,'C4::Circulation'], "index_records is called once for $engine when calling AddReturn if item not issued";

        warnings_are{
            $item3->move_to_biblio($biblio2);
        } [$engine,"Koha::Item",$engine,"Koha::Item"], "index_records is called twice for $engine when moving an item to another biblio (Item->move_to_biblio)";
        warnings_are{
            $item4->move_to_biblio($biblio2, { skip_record_index => 1 });
        } undef, "index_records is not called for $engine when moving an item to another biblio (Item->move_to_biblio) if skip_record_index passed";

        warnings_are{
            $biblio->items->move_to_biblio($biblio2);
        } [$engine,"Koha::Items",$engine,"Koha::Items"], "index_records is called for from and to biblios for $engine when adopting items (Biblio->items->move_to_biblio(Biblio)";

        my $items = Koha::Items->search({ itemnumber => [ $item2->itemnumber, $item5->itemnumber, $item6->itemnumber ] });
        warnings_are{
            $items->move_to_biblio($biblio);
        } [$engine,"Koha::Items",$engine,"Koha::Items",$engine,"Koha::Items"], "index_records is called for all from and to biblios for $engine when adopting items (Items->move_to_biblio(Biblio)";

        $builder->build({
            source => 'Issue',
            value  => {
                itemnumber => $item->itemnumber
            }
        });
        $item->onloan('2000-01-01')->store({ skip_record_index => 1 });
        warnings_are{
            LostItem( $item->itemnumber, "tests", 1);
        } [$engine,"Koha::Item"], "index_records is called for $engine when calling LostItem with 'force_mark_returned'";
        $builder->build({
            source => 'Issue',
            value  => {
                itemnumber => $item->itemnumber
            }
        });
        $item->onloan('2000-01-01')->store({ skip_record_index => 1 });
        warnings_are{
            LostItem( $item->itemnumber, "tests", 1, { skip_record_index => 1 });
        } undef, "index_records is not called for $engine when calling LostItem with 'force_mark_returned' if skip_record_index";

        $item->datelastseen('2001-01-01')->store({skip_record_index=>1});
        warnings_are{
            my $t1 = ModDateLastSeen( $item->itemnumber, 1, undef );
        } [$engine, "Koha::Item"], "index_records is called for $engine when calling ModDateLastSeen";
        warnings_are{
            ModDateLastSeen( $item->itemnumber, 1, { skip_record_index =>1 } );
        } undef, "index_records is not called for $engine when calling ModDateLastSeen if skip_record_index";

        warnings_are{
            ModItemTransfer( $item->itemnumber, $item2->homebranch, $item->homebranch,'Manual');
        } [$engine,"Koha::Item"], "index_records is called for $engine when calling ModItemTransfer";
        warnings_are{
            ModItemTransfer( $item->itemnumber, $item->homebranch, $item2->homebranch,'Manual',{skip_record_index=>1});
        } undef, "index_records is not called for $engine when calling ModItemTransfer with skip_record_index";

        warnings_are{
            $item->delete();
        } [$engine,"Koha::Item"], "index_records is called for $engine when deleting an item (Item->delete)";
        warnings_are{
            $item2->delete({ skip_record_index => 1 });
        } undef, "index_records is not called for $engine when adding an item (Item->store) if skip_record_index passed";

        warnings_are{
            DelBiblio( $biblio3->biblionumber );
        } [$engine, "C4::Biblio"], "index_records is called for $engine when calling DelBiblio";
        warnings_are{
            DelBiblio( $biblio3->biblionumber, { skip_record_index =>1 });
        } undef, "index_records is not called for $engine when calling DelBiblio if skip_record_index passed";

    }

};

subtest 'Test AddRenewal indexer call' => sub {
    plan tests => 4;

    my @engines = ('Zebra');
    eval { Koha::SearchEngine::Elasticsearch->get_elasticsearch_params; };
    push @engines, 'Elasticsearch' unless $@;
    SKIP: {
    skip 'Elasticsearch configuration not available', 20
            if scalar @engines == 1;
    }

    for my $engine ( @engines ){
        t::lib::Mocks::mock_preference( 'SearchEngine', $engine );
        my $mock_index = Test::MockModule->new("Koha::SearchEngine::".$engine."::Indexer");

        my $biblio = $builder->build_sample_biblio();
        my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
        my $item = $builder->build_sample_item({
            biblionumber => $biblio->biblionumber,
            onloan => '2020-02-02',
            datelastseen => '2020-01-01',
            replacementprice => 0
        });
        my $issue = $builder->build({
            source => 'Issue',
            value  => {
                itemnumber => $item->itemnumber
            }
        });

        $mock_index->mock( index_records => sub {
            warn $engine;
            my ($package, undef, undef) = caller;
            warn $package;
        });


        warnings_are{
            AddRenewal($patron->borrowernumber, $item->itemnumber, $item->homebranch, undef, undef, undef, 0);
        } [$engine,"Koha::Item"], "index_records is called for $engine when adding a renewal (AddRenewal())";
        warnings_are{
            AddRenewal($patron->borrowernumber, $item->itemnumber, undef, undef, undef, undef, 0, 1);
        } undef, "index_records is not called for $engine when adding a renewal (AddRenewal()) with skip_record_index";

    }
};

$schema->storage->txn_rollback;
