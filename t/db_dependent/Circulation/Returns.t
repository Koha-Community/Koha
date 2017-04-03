use Modern::Perl;

use Test::More tests => 3;

use t::lib::Mocks;
use C4::Biblio;
use C4::Circulation;
use C4::Items;
use C4::Members;
use Koha::Database;
use Koha::DateUtils;
use Koha::OldIssues;

use t::lib::TestBuilder;

use MARC::Record;

*C4::Context::userenv = \&Mock_userenv;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

my $library = $builder->build({
    source => 'Branch',
});

my $record = MARC::Record->new();
my ( $biblionumber, $biblioitemnumber ) = AddBiblio( $record, '' );

my ( undef, undef, $itemnumber ) = AddItem(
    {
        homebranch         => $library->{branchcode},
        holdingbranch      => $library->{branchcode},
        barcode            => 'i_dont_exist',
        location           => 'PROC',
        permanent_location => 'TEST'
    },
    $biblionumber
);

my $item;

t::lib::Mocks::mock_preference( "InProcessingToShelvingCart", 1 );
AddReturn( 'i_dont_exist', $library->{branchcode} );
$item = GetItem($itemnumber);
is( $item->{location}, 'CART', "InProcessingToShelvingCart functions as intended" );

$item->{location} = 'PROC';
ModItem( $item, undef, $itemnumber );

t::lib::Mocks::mock_preference( "InProcessingToShelvingCart", 0 );
AddReturn( 'i_dont_exist', $library->{branchcode} );
$item = GetItem($itemnumber);
is( $item->{location}, 'TEST', "InProcessingToShelvingCart functions as intended" );

# C4::Context->userenv
sub Mock_userenv {
    return { branch => $library->{branchcode} };
}

subtest 'Handle ids duplication' => sub {
    plan tests => 1;

    my $biblio = $builder->build( { source => 'Biblio' } );
    my $item = $builder->build(
        {
            source => 'Item',
            value  => {
                biblionumber => $biblio->{biblionumber},
                notforloan => 0,
                itemlost   => 0,
                withdrawn  => 0,

            }
        }
    );
    my $patron = $builder->build({source => 'Borrower'});

    my $checkout = AddIssue( $patron, $item->{barcode} );
    $builder->build({ source => 'OldIssue', value => { issue_id => $checkout->issue_id } });

    my @a = AddReturn( $item->{barcode} );
    my $old_checkout = Koha::OldIssues->find( $checkout->issue_id );
    isnt( $old_checkout->itemnumber, $item->{itemnumber}, 'If an item is checked-in, it should be moved to old_issues even if the issue_id already existed in the table' );
};

1;
