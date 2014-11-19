use Modern::Perl;
use Test::More tests => 2;

use C4::Biblio;
use C4::Circulation;
use C4::Items;
use C4::Members;
use Koha::DateUtils;

use MARC::Record;

*C4::Context::userenv = \&Mock_userenv;

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my $record = MARC::Record->new();
my ( $biblionumber, $biblioitemnumber ) = AddBiblio( $record, '' );

my ( undef, undef, $itemnumber ) = AddItem(
    {
        homebranch         => 'CPL',
        holdingbranch      => 'CPL',
        barcode            => 'i_dont_exist',
        location           => 'PROC',
        permanent_location => 'TEST'
    },
    $biblionumber
);

my $item;

C4::Context->set_preference( "InProcessingToShelvingCart", 1 );
AddReturn( 'i_dont_exist', 'CPL' );
$item = GetItem($itemnumber);
is( $item->{location}, 'CART', "InProcessingToShelvingCart functions as intended" );

$item->{location} = 'PROC';
ModItem( $item, undef, $itemnumber );

C4::Context->set_preference( "InProcessingToShelvingCart", 0 );
AddReturn( 'i_dont_exist', 'CPL' );
$item = GetItem($itemnumber);
is( $item->{location}, 'TEST', "InProcessingToShelvingCart functions as intended" );

# C4::Context->userenv
sub Mock_userenv {
    return { branch => 'CPL' };
}
