#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 54;
use C4::Context;
use C4::RotatingCollections
    qw( AddItemToCollection CreateCollection DeleteCollection GetCollection GetCollectionItemBranches GetCollections GetItemsInCollection RemoveItemFromCollection TransferCollection UpdateCollection isItemInAnyCollection isItemInThisCollection );
use C4::Biblio qw( AddBiblio );
use Koha::Database;
use Koha::Library;

use t::lib::TestBuilder;

BEGIN {
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

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

#Start Tests
$dbh->do(q|DELETE FROM issues |);
$dbh->do(q|DELETE FROM borrowers |);
$dbh->do(q|DELETE FROM items |);
$dbh->do(q|DELETE FROM collections_tracking |);
$dbh->do(q|DELETE FROM collections |);
$dbh->do(q|DELETE FROM branches |);
$dbh->do(q|DELETE FROM categories|);

my $builder = t::lib::TestBuilder->new;

#Test CreateCollection
my $collections     = GetCollections();
my $countcollection = scalar(@$collections);

my ( $success, $errorCode, $errorMessage );

( $success, $errorCode, $errorMessage ) = CreateCollection( 'Collection1', 'Description1' );
is( $success, 1, "All parameters have been given - Collection 1 added" );
ok(
    !defined $errorCode && !defined $errorMessage,
    "Collection added, no error code or message"
);
my $collection_id1 = $dbh->last_insert_id( undef, undef, 'collections', undef );

( $success, $errorCode, $errorMessage ) = CreateCollection( 'Collection2', 'Description2' );
is( $success, 1, "All parameters have been given - Collection 2 added" );
ok(
    !defined $errorCode && !defined $errorMessage,
    "Collection added, no error code or message"
);
my $collection_id2 = $dbh->last_insert_id( undef, undef, 'collections', undef );

$collections = GetCollections();
is(
    scalar(@$collections), $countcollection + 2,
    "Collection1 and Collection2 have been added"
);

( $success, $errorCode, $errorMessage ) = CreateCollection('Collection3');
is( $success, 1, "Collections can be created without description" );
ok(
    !defined $errorCode && !defined $errorMessage,
    "Collection added, no error code or message"
);
my $collection_id3 = $dbh->last_insert_id( undef, undef, 'collections', undef );

( $success, $errorCode, $errorMessage ) = CreateCollection();
is( $success,      0,          "Title missing, fails to create collection" );
is( $errorCode,    1,          "Title missing, error code is 1" );
is( $errorMessage, 'NO_TITLE', "Title missing, error message is NO_TITLE" );

$collections = GetCollections();
is( scalar(@$collections), $countcollection + 3, "Only one collection added" );

#FIXME, as the id is auto incremented, two similar Collections (same title /same description) can be created
#$collection1 = CreateCollection('Collection1','Description1');

#Test GetCollections
my $collection = GetCollections();
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
        },
        {
            colId         => $collection_id3,
            colTitle      => 'Collection3',
            colDesc       => '',
            colBranchcode => undef
        }

    ],
    'All Collections'
);

#Test UpdateCollection
( $success, $errorCode, $errorMessage ) = UpdateCollection( $collection_id2, 'Collection2bis', undef );
is( $success, 1, "UpdateCollection succeeds without description" );

( $success, $errorCode, $errorMessage ) =
    UpdateCollection( $collection_id2, 'Collection2 modified', 'Description2 modified' );
is( $success, 1, "Collection2 has been modified" );
ok(
    !defined $errorCode && !defined $errorMessage,
    "Collection2 modified, no error code or message"
);

( $success, $errorCode, $errorMessage ) =
    UpdateCollection( $collection_id2, undef, 'Description' ),
    ok( !$success, "UpdateCollection fails without title" );
is( $errorCode,    2,          "Title missing, error code is 2" );
is( $errorMessage, 'NO_TITLE', "Title missing, error message is NO_TITLE" );

is( UpdateCollection(), 'NO_ID', "UpdateCollection without params" );

#Test GetCollection
my @collection1 = GetCollection($collection_id1);
is_deeply(
    \@collection1,
    [ $collection_id1, 'Collection1', 'Description1', undef ],
    "Collection1's information"
);
my @collection2 = GetCollection($collection_id2);
is_deeply(
    \@collection2,
    [ $collection_id2, 'Collection2 modified', 'Description2 modified', undef ],
    "Collection2's information"
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
    branchnotes    => 'sample note',
};
Koha::Library->new($samplebranch)->store;
my ( $transferred, $messages ) = TransferCollection( $collection_id1, $samplebranch->{branchcode} );
is(
    $transferred,
    1, "Collection1 has been transferred in the branch SAB"
);
@collection1 = GetCollection($collection_id1);
is_deeply(
    \@collection1,
    [
        $collection_id1, 'Collection1',
        'Description1',  $samplebranch->{branchcode}
    ],
    "Collection1 belongs to the sample branch (SAB)"
);
( $transferred, $messages ) = TransferCollection();
is( $messages->[0]->{code}, "NO_ID", "TransferCollection without ID" );
( $transferred, $messages ) = TransferCollection($collection_id1);
is(
    $messages->[0]->{code},
    'NO_BRANCHCODE', "TransferCollection without branchcode"
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
my $item_id1 = $builder->build_sample_item(
    {
        biblionumber   => $biblionumber,
        library        => $samplebranch->{branchcode},
        barcode        => 1,                             # FIXME This must not be hardcoded!
        itemcallnumber => 'callnumber1',
    }
)->itemnumber;
my $item_id2 = $builder->build_sample_item(
    {
        biblionumber   => $biblionumber,
        library        => $samplebranch->{branchcode},
        barcode        => 2,                             # FIXME This must not be hardcoded!
        itemcallnumber => 'callnumber2',
    }
)->itemnumber;

is(
    AddItemToCollection( $collection_id1, $item_id1 ),
    1, "Sampleitem1 has been added to Collection1"
);
is(
    AddItemToCollection( $collection_id1, $item_id2 ),
    1, "Sampleitem2 has been added to Collection1"
);

#Test GetItemsInCollection
my $itemsincollection1;
( $itemsincollection1, $success, $errorCode, $errorMessage ) = GetItemsInCollection($collection_id1);
is( scalar @$itemsincollection1, 2, "Collection1 has 2 items" );
is_deeply(
    $itemsincollection1,
    [
        {
            title          => undef,
            itemcallnumber => 'callnumber1',
            biblionumber   => $biblionumber,
            barcode        => 1
        },
        {
            title          => undef,
            itemcallnumber => 'callnumber2',
            biblionumber   => $biblionumber,
            barcode        => 2
        }
    ],
    "Collection1 has Item1 and Item2"
);
( $itemsincollection1, $success, $errorCode, $errorMessage ) = GetItemsInCollection();
ok( !$success, "GetItemsInCollection fails without a collection ID" );
is( $errorCode,    1,       "Title missing, error code is 2" );
is( $errorMessage, 'NO_ID', "Collection ID missing, error message is NO_ID" );

#Test RemoveItemFromCollection
is(
    RemoveItemFromCollection( $collection_id1, $item_id2 ),
    1, "Item2 has been removed from collection 1"
);
$itemsincollection1 = GetItemsInCollection($collection_id1);
is( scalar @$itemsincollection1, 1, "Collection1 has 1 items" );

#Test isItemInAnyCollection
is(
    C4::RotatingCollections::isItemInAnyCollection($item_id1),
    1, "Item1 is in a collection"
);
is(
    C4::RotatingCollections::isItemInAnyCollection($item_id2),
    0, "Item2 is not in a collection"
);
is(
    C4::RotatingCollections::isItemInAnyCollection(),
    0, "isItemInAnyCollection returns 0 if no itemid given "
);
is(
    C4::RotatingCollections::isItemInAnyCollection(-1),
    0, "isItemInAnyCollection returns 0 if a wrong id is given"
);

#Test isItemInThisCollection
is(
    C4::RotatingCollections::isItemInThisCollection( $item_id1, $collection_id1 ),
    1,
    "Item1 is in the Collection1"
);
is(
    C4::RotatingCollections::isItemInThisCollection( $item_id1, $collection_id2 ),
    0,
    "Item1 is not in the Collection2"
);
is(
    C4::RotatingCollections::isItemInThisCollection( $item_id2, $collection_id2 ),
    0,
    "Item2 is not in the Collection2"
);
is(
    C4::RotatingCollections::isItemInThisCollection($collection_id1),
    0, "isItemInThisCollection returns 0 is ItemId is missing"
);
is(
    C4::RotatingCollections::isItemInThisCollection($item_id1),
    0, "isItemInThisCollection returns 0 is Collectionid if missing"
);
is(
    C4::RotatingCollections::isItemInThisCollection(),
    0, "isItemInThisCollection returns 0 if no params given"
);

#Re-add item to test deletion of collection
AddItemToCollection( $collection_id1, $item_id1 );

#Test DeleteCollection
is( DeleteCollection($collection_id2), 1, "Collection2 deleted" );
is( DeleteCollection($collection_id1), 1, "Collection1 deleted" );
is(
    DeleteCollection(),
    'NO_ID',
    "DeleteCollection without id"
);
$collections = GetCollections();
is(
    scalar(@$collections),
    $countcollection + 1,
    "Two Collections have been deleted"
);

is(
    C4::RotatingCollections::isItemInAnyCollection($item_id1),
    0, "Item1 is no longer in a collection after it is deleted"
);
is(
    C4::RotatingCollections::isItemInThisCollection( $item_id1, $collection_id1 ),
    0,
    "Item1 is not in the deleted Collection1"
);

$schema->storage->txn_rollback;
