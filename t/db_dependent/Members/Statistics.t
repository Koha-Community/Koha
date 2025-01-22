use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 3;

# Please add more tests here !!

use t::lib::Mocks;

use C4::Members::Statistics qw( get_fields );
use Koha::Database;    # we need the db here; get_fields looks for the item columns

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;

t::lib::Mocks::mock_preference( 'StatisticsFields', undef );
is( C4::Members::Statistics::get_fields(), 'location|itype|ccode', 'Check default' );

t::lib::Mocks::mock_preference( 'StatisticsFields', 'barcode|garbagexxx|itemcallnumber|notexistent' );
is(
    C4::Members::Statistics::get_fields(), 'barcode|itemcallnumber',
    'Check if wrong item fields were removed by get_fields'
);

$schema->storage->txn_rollback;
