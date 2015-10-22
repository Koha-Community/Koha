use Modern::Perl;

use MARC::Record;
use C4::Biblio;
use C4::Circulation;
use C4::Members;
use t::lib::Mocks;


use Test::More tests => 10;

*C4::Context::userenv = \&Mock_userenv;

BEGIN {
    use_ok('C4::Items');
}

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my ( $biblionumber, $bibitemnum ) = get_biblio();

# book_on_loan

my ( $borrowernumber, $borrower ) = get_borrower();
my ( $itemnumber, $item )         = get_item( $biblionumber );
AddIssue( $borrower, 'i_dont_exist' );

is(
    ItemSafeToDelete($dbh, $biblionumber, $itemnumber),
    'book_on_loan',
    'ItemSafeToDelete reports item on loan',
);

is(
    DelItemCheck($dbh, $biblionumber, $itemnumber),
    'book_on_loan',
    'item that is on loan cannot be deleted',
);

AddReturn('i_dont_exist', 'CPL');

# book_reserved is tested in t/db_dependent/Reserves.t

# not_same_branch
t::lib::Mocks::mock_preference('IndependentBranches', 1);
ModItem( { homebranch => 'FPL', holdingbranch => 'FPL' }, $biblionumber, $itemnumber );

is(
    ItemSafeToDelete($dbh, $biblionumber, $itemnumber),
    'not_same_branch',
    'ItemSafeToDelete reports IndependentBranches restriction',
);

is(
    DelItemCheck($dbh, $biblionumber, $itemnumber),
    'not_same_branch',
    'IndependentBranches prevents deletion at another branch',
);

ModItem( { homebranch => 'CPL', holdingbranch => 'CPL' }, $biblionumber, $itemnumber );

# linked_analytics

{ # codeblock to limit scope of $module->mock

    my $module = Test::MockModule->new('C4::Items');
    $module->mock( GetAnalyticsCount => sub { return 1 } );

    is(
        ItemSafeToDelete($dbh, $biblionumber, $itemnumber),
        'linked_analytics',
        'ItemSafeToDelete reports linked analytics',
    );

    is(
        DelItemCheck($dbh, $biblionumber, $itemnumber),
        'linked_analytics',
        'Linked analytics prevents deletion of item',
    );

}

is(
    ItemSafeToDelete($dbh, $biblionumber, $itemnumber),
    1,
    'ItemSafeToDelete shows item safe to delete'
);

DelItemCheck($dbh, $biblionumber, $itemnumber, { do_not_commit => 1 } );

my $testitem = GetItem( $itemnumber );

is( $testitem->{itemnumber} ,  $itemnumber,
    "DelItemCheck should not delete item if 'do_not_commit' is set"
);

DelItemCheck( $dbh, $biblionumber, $itemnumber );

$testitem = GetItem( $itemnumber );

is( $testitem->{itemnumber}, undef,
    "DelItemCheck should delete item if 'do_not_commit' not set"
);

# End of testing

# Helper methods to set up Biblio, Item, and Borrower.
sub get_biblio {
    my $bib = MARC::Record->new();
    $bib->append_fields(
        MARC::Field->new( '100', ' ', ' ', a => 'Moffat, Steven' ),
        MARC::Field->new( '245', ' ', ' ', a => 'Silence in the library' ),
    );
    my ( $bibnum, $bibitemnum ) = AddBiblio( $bib, '' );
    return ( $bibnum, $bibitemnum );
}

sub get_item {
    my $biblionumber = shift;
    my ( $item_bibnum, $item_bibitemnum, $itemnumber ) =
      AddItem( { homebranch => 'CPL', holdingbranch => 'CPL', barcode => 'i_dont_exist' }, $biblionumber );
    my $item = GetItem( $itemnumber );
    return ( $itemnumber, $item );
}

sub get_borrower {
    my $borrowernumber = AddMember(
        firstname =>  'my firstname',
        surname => 'my surname',
        categorycode => 'S',
        branchcode => 'CPL',
    );

    my $borrower = GetMember( borrowernumber => $borrowernumber );
    return ( $borrowernumber, $borrower );
}

# C4::Context->userenv
sub Mock_userenv {
        return { flags => 0, branch => 'CPL' };
}

$dbh->rollback;
