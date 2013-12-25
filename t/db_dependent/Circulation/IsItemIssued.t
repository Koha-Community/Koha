use Modern::Perl;
use Test::More tests => 5;

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

my $borrowernumber = AddMember(
    firstname =>  'my firstname',
    surname => 'my surname',
    categorycode => 'S',
    branchcode => 'CPL',
);


my $borrower = GetMember( borrowernumber => $borrowernumber );
my $record = MARC::Record->new();
my ( $biblionumber, $biblioitemnumber ) = AddBiblio( $record, '' );

my ( undef, undef, $itemnumber ) = AddItem( { homebranch => 'CPL', holdingbranch => 'CPL', barcode => 'i_dont_exist' }, $biblionumber );
my $item = GetItem( $itemnumber );

is ( IsItemIssued( $item->{itemnumber} ), 0, "item is not on loan at first" );

AddIssue($borrower, 'i_dont_exist');
is ( IsItemIssued( $item->{itemnumber} ), 1, "item is now on loan" );

is(
    DelItemCheck($dbh, $biblionumber, $itemnumber),
    'book_on_loan',
    'item that is on loan cannot be deleted',
);

AddReturn('i_dont_exist', 'CPL');
is ( IsItemIssued( $item->{itemnumber} ), 0, "item has been returned" );

is(
    DelItemCheck($dbh, $biblionumber, $itemnumber),
    1,
    'item that is not on loan can be deleted',
);

$dbh->rollback;

# C4::Context->userenv
sub Mock_userenv {
    return { branch => 'CPL' };
}
