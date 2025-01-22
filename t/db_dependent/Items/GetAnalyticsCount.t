use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 2;
use Test::MockModule;
use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Items;
use Koha::Database;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

subtest 'GetAnalyticsCount' => sub {
    plan tests => 2;

    my $itemnumber = '123456789';

    my $engine = C4::Context->preference("SearchEngine") // 'Zebra';
    my $search = Test::MockModule->new("Koha::SearchEngine::${engine}::Search");
    $search->mock(
        'simple_search_compat',
        sub {
            my ( $self, $query ) = @_;
            if ( $query and $query eq "hi=$itemnumber" ) {
                return ( undef, undef, 7 );
            }
            return ( undef, undef, 0 );
        }
    );

    t::lib::Mocks::mock_preference( 'EasyAnalyticalRecords', 0 );
    my $c = C4::Items::GetAnalyticsCount($itemnumber);
    is( $c, 0, 'GetAnalyticsCount returns 0 when pref is disabled' );

    t::lib::Mocks::mock_preference( 'EasyAnalyticalRecords', 1 );
    $c = C4::Items::GetAnalyticsCount($itemnumber);
    is( $c, 7, 'GetAnalyticsCount uses simple_search_compat("hi=<itemnumber>") when pref is enabled' );

};

$schema->storage->txn_rollback;
