use Modern::Perl;

use MARC::Record;
use C4::Items;
use C4::Biblio;

use t::lib::TestBuilder;

use Test::More tests => 6;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

my $library = $builder->build({
    source => 'Branch',
});

my $biblio = $builder->build_sample_biblio();

my ( $item_bibnum, $item_bibitemnum, $itemnumber );
( $item_bibnum, $item_bibitemnum, $itemnumber ) =
  AddItem( { homebranch => $library->{branchcode}, holdingbranch => $library->{branchcode} }, $biblio->biblionumber );

my $deleted = DelItem( { biblionumber => $biblio->biblionumber, itemnumber => $itemnumber } );
is( $deleted, 1, "DelItem should return 1 if the item has been deleted" );
my $deleted_item = GetItem($itemnumber);
is( $deleted_item->{itemnumber}, undef, "DelItem with biblionumber parameter - the item should be deleted." );

( $item_bibnum, $item_bibitemnum, $itemnumber ) =
  AddItem( { homebranch => $library->{branchcode}, holdingbranch => $library->{branchcode} }, $biblio->biblionumber );
$deleted = DelItem( { biblionumber => $biblio->biblionumber, itemnumber => $itemnumber } );
is( $deleted, 1, "DelItem should return 1 if the item has been deleted" );
$deleted_item = GetItem($itemnumber);
is( $deleted_item->{itemnumber}, undef, "DelItem without biblionumber parameter - the item should be deleted." );

$deleted = DelItem( { itemnumber => $itemnumber + 1} );
is ( $deleted, 0, "DelItem should return 0 if no item has been deleted" );

$deleted = DelItem( { itemnumber => $itemnumber + 1, biblionumber => $biblio->biblionumber } );
is ( $deleted, 0, "DelItem should return 0 if no item has been deleted" );
