use Modern::Perl;

use MARC::Record;
use C4::Biblio;

use Test::More tests => 7;

BEGIN {
    use_ok('C4::Items');
}

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my ( $biblionumber, $bibitemnum ) = get_biblio();

my ( $item_bibnum, $item_bibitemnum, $itemnumber );
( $item_bibnum, $item_bibitemnum, $itemnumber ) =
  AddItem( { homebranch => 'CPL', holdingbranch => 'CPL' }, $biblionumber );

my $deleted = DelItem( { biblionumber => $biblionumber, itemnumber => $itemnumber } );
is( $deleted, 1, "DelItem should return 1 if the item has been deleted" );
my $deleted_item = GetItem($itemnumber);
is( $deleted_item->{itemnumber}, undef, "DelItem with biblionumber parameter - the item should be deleted." );

( $item_bibnum, $item_bibitemnum, $itemnumber ) =
  AddItem( { homebranch => 'CPL', holdingbranch => 'CPL' }, $biblionumber );
$deleted = DelItem( { biblionumber => $biblionumber, itemnumber => $itemnumber } );
is( $deleted, 1, "DelItem should return 1 if the item has been deleted" );
$deleted_item = GetItem($itemnumber);
is( $deleted_item->{itemnumber}, undef, "DelItem without biblionumber parameter - the item should be deleted." );

$deleted = DelItem( { itemnumber => $itemnumber + 1} );
is ( $deleted, 0, "DelItem should return 0 if no item has been deleted" );

$deleted = DelItem( { itemnumber => $itemnumber + 1, biblionumber => $biblionumber } );
is ( $deleted, 0, "DelItem should return 0 if no item has been deleted" );

# Helper method to set up a Biblio.
sub get_biblio {
    my $bib = MARC::Record->new();
    $bib->append_fields(
        MARC::Field->new( '100', ' ', ' ', a => 'Moffat, Steven' ),
        MARC::Field->new( '245', ' ', ' ', a => 'Silence in the library' ),
    );
    my ( $bibnum, $bibitemnum ) = AddBiblio( $bib, '' );
    return ( $bibnum, $bibitemnum );
}
