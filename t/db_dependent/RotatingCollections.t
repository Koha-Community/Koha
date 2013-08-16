#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 41;
use C4::Context;
use C4::Branch;
use C4::Biblio;

BEGIN {
    use_ok('C4::RotatingCollections');
}

can_ok(
    'C4::RotatingCollections',
    qw(
      AddItemToCollection
      CreateCollection
      DeleteCollection
      GetCollection
      GetCollectionItemBranches
      GetCollections
      GetItemsInCollection
      RemoveItemFromCollection
      TransferCollection
      UpdateCollection
      isItemInAnyCollection
      isItemInThisCollection
      )
);

#Start transaction
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

#Start Tests
$dbh->do(q|DELETE FROM issues |);
$dbh->do(q|DELETE FROM borrowers |);
$dbh->do(q|DELETE FROM items |);
$dbh->do(q|DELETE FROM collections_tracking |);
$dbh->do(q|DELETE FROM collections |);
$dbh->do(q|DELETE FROM branches |);
$dbh->do(q|DELETE FROM categories|);
$dbh->do(q|DELETE FROM branchcategories|);

#Test CreateCollection
my $collections     = GetCollections();
my $countcollection = scalar(@$collections);

is( CreateCollection( 'Collection1', 'Description1' ),
    1, "All parameters have been given - Collection 1 added" );
my $collection_id1 = $dbh->last_insert_id( undef, undef, 'collections', undef );
is( CreateCollection( 'Collection2', 'Description2' ),
    1, "All parameters have been given - Collection 2 added" );
my $collection_id2 = $dbh->last_insert_id( undef, undef, 'collections', undef );
$collections = GetCollections();
is(
    scalar(@$collections),
    $countcollection + 2,
    "Collection1 and Collection2 have been added"
);
my $collection = CreateCollection('Collection');
is( $collection, 'No Description Given', "The field description is missing" );
$collection = CreateCollection();
is(
    $collection,
    'No Title Given',
    "The field description and title is missing"
);
$collections = GetCollections();
is( scalar(@$collections), $countcollection + 2, "No collection added" );

#FIXME, as the id is auto incremented, two similar Collections (same title /same description) can be created
#$collection1 = CreateCollection('Collection1','Description1');

#Test GetCollections
$collection = GetCollections();
is_deeply(
    $collections,
    [
        {
            colId         => $collection_id1,
            colTitle      => 'Collection1',
            colDesc       => 'Description1',
            colBranchcode => undef
        },
        {
            colId         => $collection_id2,
            colTitle      => 'Collection2',
            colDesc       => 'Description2',
            colBranchcode => undef
        }
    ],
    'All Collections'
);

#Test UpdateCollection
is(
    UpdateCollection(
        $collection_id2,
        'Collection2 modified',
        'Description2 modified'
    ),
    1,
    "Collection2 has been modified"
);

#FIXME : The following test should pass, currently, with a wrong id UpdateCollection returns 1 even if nothing has been modified
#is(UpdateCollection(-1,'Collection2 modified','Description2 modified'),
#   0,
#   "UpdateCollection with a wrong id");
is(
    UpdateCollection( 'Collection', 'Description' ),
    'No Description Given',
    "UpdateCollection without description"
);
is(
    UpdateCollection( 'Description' ),
    'No Title Given',
    "UpdateCollection without title"
);
is( UpdateCollection(), 'No Id Given', "UpdateCollection without params" );

#Test GetCollection
my @collection1 = GetCollection($collection_id1);
is_deeply(
    \@collection1,
    [ $collection_id1, 'Collection1', 'Description1', undef ],
    "Collection1's informations"
);
my @collection2 = GetCollection($collection_id2);
is_deeply(
    \@collection2,
    [ $collection_id2, 'Collection2 modified', 'Description2 modified', undef ],
    "Collection2's informations"
);
my @undef_collection = GetCollection();
is_deeply(
    \@undef_collection,
    [ undef, undef, undef, undef ],
    "GetCollection without id given"
);
@undef_collection = GetCollection(-1);
is_deeply(
    \@undef_collection,
    [ undef, undef, undef, undef ],
    "GetCollection with a wrong id"
);

#Test TransferCollection
my $samplebranch = {
    add            => 1,
    branchcode     => 'SAB',
    branchname     => 'Sample Branch',
    branchaddress1 => 'sample adr1',
    branchaddress2 => 'sample adr2',
    branchaddress3 => 'sample adr3',
    branchzip      => 'sample zip',
    branchcity     => 'sample city',
    branchstate    => 'sample state',
    branchcountry  => 'sample country',
    branchphone    => 'sample phone',
    branchfax      => 'sample fax',
    branchemail    => 'sample email',
    branchurl      => 'sample url',
    branchip       => 'sample ip',
    branchprinter  => undef,
    branchnotes    => 'sample note',
    opac_info      => 'sample opac',
};
ModBranch($samplebranch);
is( TransferCollection( $collection_id1, $samplebranch->{branchcode} ),
    1, "Collection1 has been transfered in the branch SAB" );
@collection1 = GetCollection($collection_id1);
is_deeply(
    \@collection1,
    [
        $collection_id1, 'Collection1',
        'Description1',  $samplebranch->{branchcode}
    ],
    "Collection1 belongs to the sample branch (SAB)"
);
is( TransferCollection, "No Id Given", "TransferCollection without ID" );
is(
    TransferCollection($collection_id1),
    "No Branchcode Given",
    "TransferCollection without branchcode"
);

#Test AddItemToCollection
my $record = MARC::Record->new();
$record->append_fields(
    MARC::Field->new(
        '952', '0', '0',
        a => $samplebranch->{branchcode},
        b => $samplebranch->{branchcode}
    )
);
my ( $biblionumber, $biblioitemnumber ) = C4::Biblio::AddBiblio( $record, '', );
my @sampleitem1 = C4::Items::AddItem(
    {
        barcode        => 1,
        itemcallnumber => 'callnumber1',
        homebranch     => $samplebranch->{branchcode},
        holdingbranch  => $samplebranch->{branchcode}
    },
    $biblionumber
);
my $item_id1    = $sampleitem1[2];
my @sampleitem2 = C4::Items::AddItem(
    {
        barcode        => 2,
        itemcallnumber => 'callnumber2',
        homebranch     => $samplebranch->{branchcode},
        holdingbranch  => $samplebranch->{branchcode}
    },
    $biblionumber
);
my $item_id2 = $sampleitem2[2];
is( AddItemToCollection( $collection_id1, $item_id1 ),
    1, "Sampleitem1 has been added to Collection1" );
is( AddItemToCollection( $collection_id1, $item_id2 ),
    1, "Sampleitem2 has been added to Collection1" );

#Test GetItemsInCollection
my $itemsincollection1 = GetItemsInCollection($collection_id1);
is( scalar @$itemsincollection1, 2, "Collection1 has 2 items" );
is_deeply(
    $itemsincollection1,
    [
        {
            title          => undef,
            itemcallnumber => 'callnumber1',
            barcode        => 1
        },
        {
            title          => undef,
            itemcallnumber => 'callnumber2',
            barcode        => 2
        }
    ],
    "Collection1 has Item1 and Item2"
);

#Test RemoveItemFromCollection
is( RemoveItemFromCollection( $collection_id1, $item_id2 ),
    1, "Item2 has been removed from collection 1" );
$itemsincollection1 = GetItemsInCollection($collection_id1);
is( scalar @$itemsincollection1, 1, "Collection1 has 1 items" );

#Test isItemInAnyCollection
is( C4::RotatingCollections::isItemInAnyCollection($item_id1),
    1, "Item1 is in a collection" );
is( C4::RotatingCollections::isItemInAnyCollection($item_id2),
    0, "Item2 is not in a collection" );
is( C4::RotatingCollections::isItemInAnyCollection(),
    0, "isItemInAnyCollection returns 0 if no itemid given " );
is( C4::RotatingCollections::isItemInAnyCollection(-1),
    0, "isItemInAnyCollection returns 0 if a wrong id is given" );

#Test isItemInThisCollection
is(
    C4::RotatingCollections::isItemInThisCollection(
        $item_id1, $collection_id1
    ),
    1,
    "Item1 is in the Collection1"
);
is(
    C4::RotatingCollections::isItemInThisCollection(
        $item_id1, $collection_id2
    ),
    0,
    "Item1 is not in the Collection2"
);
is(
    C4::RotatingCollections::isItemInThisCollection(
        $item_id2, $collection_id2
    ),
    0,
    "Item2 is not in the Collection2"
);
is( C4::RotatingCollections::isItemInThisCollection($collection_id1),
    0, "isItemInThisCollection returns 0 is ItemId is missing" );
is( C4::RotatingCollections::isItemInThisCollection($item_id1),
    0, "isItemInThisCollection returns 0 is Collectionid if missing" );
is( C4::RotatingCollections::isItemInThisCollection(),
    0, "isItemInThisCollection returns 0 if no params given" );

#Test DeleteCollection
is( DeleteCollection($collection_id2), 1, "Collection2 deleted" );
is( DeleteCollection($collection_id1), 1, "Collection1 deleted" );
is(
    DeleteCollection(),
    'No Collection Id Given',
    "DeleteCollection without id"
);
$collections = GetCollections();
is(
    scalar(@$collections),
    $countcollection + 0,
    "Two Collections have been deleted"
);

#End transaction
$dbh->rollback;
