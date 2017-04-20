package C4::RotatingCollections;

# $Id: RotatingCollections.pm,v 0.1 2007/04/20 kylemhall

# This package is inteded to keep track of what library
# Items of a certain collection should be at.

# Copyright 2007 Kyle Hall
#
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use C4::Context;
use C4::Circulation;
use C4::Reserves qw(CheckReserves GetReserveStatus);
use Koha::DateUtils qw( output_pref dt_from_string );
use C4::Biblio;
use C4::Items;
use Koha::Database;

use DBI;

use Data::Dumper;

use vars qw(@ISA @EXPORT);


=head1 NAME

C4::RotatingCollections - Functions for managing rotating collections

=head1 FUNCTIONS

=cut

BEGIN {
    require Exporter;
    @ISA    = qw( Exporter );
    @EXPORT = qw(
      CreateCollection
      UpdateCollection
      DeleteCollection

      GetItemsInCollection

      GetCollection
      GetCollectionByTitle
      GetCollections

      AddItemToCollection
      RemoveItemFromCollection
      TransferCollection
      TransferCollectionItem
      ReturnCollectionItemToOrigin
      ReturnCollectionToOrigin

      GetCollectionItemBranches

      GetItemOriginBranch
      GetItemsCollection

      isItemInAnyCollection
    );
}

=head2  CreateCollection
 ( $success, $errorcode, $errormessage ) = CreateCollection( $title, $description );
 Creates a new collection

 Input:
   $title: short description of the club or service
   $description: long description of the club or service

 Output:
   $success: 1 if all database operations were successful, 0 otherwise
   $errorCode: Code for reason of failure, good for translating errors in templates
   $errorMessage: English description of error

=cut

sub CreateCollection {
    my ( $title, $description, $owningbranch ) = @_;

    my $schema = Koha::Database->new()->schema();
    my $duplicate_titles = $schema->resultset('Collection')->count({ colTitle => $title });

    ## Check for all necessary parameters
    if ( !$title ) {
        return ( 0, 1, "NO_TITLE" );
    } elsif ( $duplicate_titles ) {
        return ( 0, 2, "DUPLICATE_TITLE" );
    }

    $description ||= q{};

    if ( !$owningbranch ) {
        return ( 0, 3, "No owning branch given" );
    }

    my $success = 1;

    my $dbh = C4::Context->dbh;

    my $sth;
    $sth = $dbh->prepare(
        "INSERT INTO collections ( colId, colTitle, colDesc, owningBranchcode )
                        VALUES ( NULL, ?, ?, ? )"
    );
    $sth->execute( $title, $description, $owningbranch ) or return ( 0, 4, $sth->errstr() );

    return 1;

}

=head2 UpdateCollection

 ( $success, $errorcode, $errormessage ) = UpdateCollection( $colId, $title, $description );

Updates a collection

 Input:
   $colId: id of the collection to be updated
   $title: short description of the club or service
   $description: long description of the club or service

 Output:
   $success: 1 if all database operations were successful, 0 otherwise
   $errorCode: Code for reason of failure, good for translating errors in templates
   $errorMessage: English description of error

=cut

sub UpdateCollection {
    my ( $colId, $title, $description ) = @_;

    my $schema = Koha::Database->new()->schema();
    my $duplicate_titles = $schema->resultset('Collection')->count({ colTitle => $title,  -not => { colId => $colId } });

    ## Check for all necessary parameters
    if ( !$colId ) {
        return ( 0, 1, "NO_ID" );
    }
    if ( !$title ) {
        return ( 0, 2, "NO_TITLE" );
    }
    if ( $duplicate_titles ) {
        return ( 0, 3, "DUPLICATE_TITLE" );
    }

    my $dbh = C4::Context->dbh;

    $description ||= q{};

    my $sth;
    $sth = $dbh->prepare(
        "UPDATE collections
                        SET 
                        colTitle = ?, colDesc = ? 
                        WHERE colId = ?"
    );
    $sth->execute( $title, $description, $colId )
      or return ( 0, 4, $sth->errstr() );

    return 1;

}

=head2 DeleteCollection

 ( $success, $errorcode, $errormessage ) = DeleteCollection( $colId );
 Deletes a collection of the given id

 Input:
   $colId : id of the Archetype to be deleted

 Output:
   $success: 1 if all database operations were successful, 0 otherwise
   $errorCode: Code for reason of failure, good for translating errors in templates
   $errorMessage: English description of error

=cut

sub DeleteCollection {
    my ($colId) = @_;

    ## Parameter check
    if ( !$colId ) {
        return ( 0, 1, "NO_ID" );
    }

    my $collectionItems = GetItemsInCollection($colId);
    # KD-139: Actually remove all items from the collection before removing the collection itself.
    for my $item (@$collectionItems) {
        my $itembiblio = C4::Biblio::GetBiblioFromItemNumber(undef, $item->{'barcode'});
        my $itemnumber = $itembiblio->{'itemnumber'};
        RemoveItemFromCollection($colId, $itemnumber);
    }

    my $dbh = C4::Context->dbh;

    my $sth;

    $sth = $dbh->prepare("DELETE FROM collections WHERE colId = ?");
    $sth->execute($colId) or return ( 0, 4, $sth->errstr() );

    return 1;
}

=head2 GetCollections

 $collections = GetCollections();
 Returns data about all collections

 Output:
  On Success:
   $results: Reference to an array of associated arrays
  On Failure:
   $errorCode: Code for reason of failure, good for translating errors in templates
   $errorMessage: English description of error

=cut

sub GetCollections {

    my $dbh = C4::Context->dbh;
    my $query = '
    SELECT *
    FROM collections
    LEFT JOIN branches ON owningBranchcode = branches.branchcode
    ';

    my $sth = $dbh->prepare($query);
    $sth->execute() or return ( 1, $sth->errstr() );

    my @results;
    while ( my $row = $sth->fetchrow_hashref ) {
        my $colItemCount = GetCollectionItemCount($row->{'colId'});
        my $itemsTransferred = GetTransferredItemCount($row->{'colId'});
        $row->{'colItemsCount'} = $colItemCount;
        $row->{'itemsTransferred'} = $itemsTransferred;
        push( @results, $row );
    }

    return \@results;
}

=head2 GetItemsInCollection

 ( $results, $success, $errorcode, $errormessage ) = GetItemsInCollection( $colId );

 Returns information about the items in the given collection
 
 Input:
   $colId: The id of the collection

 Output:
   $results: Reference to an array of associated arrays
   $success: 1 if all database operations were successful, 0 otherwise
   $errorCode: Code for reason of failure, good for translating errors in templates
   $errorMessage: English description of error

=cut

sub GetItemsInCollection {
    my ($colId) = @_;

    ## Parameter check
    if ( !$colId ) {
        return ( 0, 0, 1, "NO_ID" );
    }

    my $dbh = C4::Context->dbh;

    my $sth = $dbh->prepare(
        "SELECT
                            biblio.title,
                            biblio.biblionumber,
                            items.itemcallnumber,
                            items.barcode,
                            items.itemnumber,
                            items.holdingbranch,
                            items.homebranch,
                            branches.branchname,
                            collections_tracking.*
                           FROM collections, collections_tracking, items, biblio, branches
                           WHERE items.homebranch = branches.branchcode
                           AND collections.colId = collections_tracking.colId
                           AND collections_tracking.itemnumber = items.itemnumber
                           AND items.biblionumber = biblio.biblionumber
                           AND collections.colId = ?
                           ORDER BY biblio.title"
    );
    $sth->execute($colId) or return ( 0, 0, 2, $sth->errstr() );

    my @results;
    while ( my $row = $sth->fetchrow_hashref ) {
        my $originbranchname = Koha::Libraries->find( $row->{'origin_branchcode'} );
        my $holdingbranchname = Koha::Libraries->find( $row->{'holdingbranch'} );
        $row->{'holdingbranchname'} = $holdingbranchname->branchname;
        $row->{'origin_branchname'} = $originbranchname->branchname;
        $row->{'intransit'} = C4::Circulation::GetTransfers($row->{'itemnumber'});
        $row->{'date_added_format'} = output_pref({ dt => dt_from_string($row->{'date_added'}), dateonly => 1 });
        push( @results, $row );
    }

    return \@results;
}

=head2 GetCollection

 ( $colId, $colTitle, $colDesc, $colBranchcode ) = GetCollection( $colId );

Returns information about a collection

 Input:
   $colId: Id of the collection
 Output:
   $colId, $colTitle, $colDesc, $colBranchcode

=cut

sub GetCollection {
    my ($colId) = @_;

    my $dbh = C4::Context->dbh;

    my ( $sth, @results );
    $sth = $dbh->prepare("SELECT * FROM collections WHERE colId = ?");
    $sth->execute($colId) or return 0;

    my $row = $sth->fetchrow_hashref;

    return (
        $$row{'colId'},   $$row{'colTitle'},
        $$row{'colDesc'}, $$row{'colBranchcode'}
    );

}

=head2 GetCollectionByTitle

 ($colId, $colTitle, $colDesc, $colBranchcode) = GetCollectionByTitle($colTitle);

Returns information about a collection

 Input:
   $colTitle: Title of the collection
 Output:
   $colId, $colTitle, $colDesc, $colBranchcode

=cut

sub GetCollectionByTitle {
    my ($colId) = @_;

    my $dbh = C4::Context->dbh;

    my ( $sth, @results );
    $sth = $dbh->prepare("SELECT * FROM collections WHERE colTitle = ?");
    $sth->execute($colId) or return 0;

    my $row = $sth->fetchrow_hashref;

    return (
        $$row{'colId'},   $$row{'colTitle'},
        $$row{'colDesc'}, $$row{'colBranchcode'}
    );

}

=head2 GetItemsCollection

$itemsCollection = GetItemsCollection($itemnumber)

Returns an item's collection if it exists

 Input:
   $itemnumber: itemnumber of the item
 Output:
   $colId of the item's collection or 0 if the item is not in a collection

=cut

sub GetItemsCollection {
    my $itemnumber = shift;

    if (!isItemInAnyCollection($itemnumber)) {
        return 0;
    }

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT * FROM collections_tracking WHERE itemnumber = ?");
    $sth->execute($itemnumber) or return 0;

    my $colItem = $sth->fetchrow_hashref;
    if ($colItem) {
        return $colItem->{'colId'};
    }
    return 0;
}

=head2 AddItemToCollection

 ( $success, $errorcode, $errormessage ) = AddItemToCollection( $colId, $itemnumber );

Adds an item to a rotating collection.

 Input:
   $colId: Collection to add the item to.
   $itemnumber: Item to be added to the collection
 Output:
   $success: 1 if all database operations were successful, 0 otherwise
   $errorCode: Code for reason of failure, good for translating errors in templates
   $errorMessage: English description of error

=cut

sub AddItemToCollection {
    my ( $colId, $itemnumber ) = @_;

    ## Check for all necessary parameters
    if ( !$colId ) {
        return ( 0, 1, "NO_ID" );
    }
    if ( !$itemnumber ) {
        return ( 0, 2, "NO_ITEM" );
    }

    if ( isItemInThisCollection( $itemnumber, $colId ) ) {
        return ( 0, 2, "IN_COLLECTION" );
    }
    elsif ( isItemInAnyCollection($itemnumber) ) {
        return ( 0, 3, "IN_COLLECTION_OTHER" );
    }

    my $itembiblio = C4::Biblio::GetBiblioFromItemNumber($itemnumber, undef);
    my $originbranchcode = $itembiblio->{'homebranch'};
    my $transferred = 0;

    my $dbh = C4::Context->dbh;

    my $sth;
    $sth = $dbh->prepare("
        INSERT INTO collections_tracking (
            colId,
            itemnumber,
            origin_branchcode,
            date_added
        ) VALUES ( ?, ?, ?, NOW() )
    ");
    $sth->execute( $colId, $itemnumber, $originbranchcode ) or return ( 0, 3, $sth->errstr() );

    return 1;

}

=head2  RemoveItemFromCollection

 ( $success, $errorcode, $errormessage ) = RemoveItemFromCollection( $colId, $itemnumber );

Removes an item to a collection

 Input:
   $colId: Collection to add the item to.
   $itemnumber: Item to be removed from collection

 Output:
   $success: 1 if all database operations were successful, 0 otherwise
   $errorCode: Code for reason of failure, good for translating errors in templates
   $errorMessage: English description of error

=cut

sub RemoveItemFromCollection {
    my ( $colId, $itemnumber ) = @_;

    ## Check for all necessary parameters
    if ( !$itemnumber ) {
        return ( 0, 2, "NO_ITEM" );
    }

    if ( !isItemInThisCollection( $itemnumber, $colId ) ) {
        return ( 0, 2, "NOT_IN_COLLECTION" );
    }

    # KD-139: Attempt to transfer the item being removed if it has its origin branch
    # set up.
    my $itembiblio = C4::Biblio::GetBiblioFromItemNumber($itemnumber, undef);
    my $currenthomebranchcode = $itembiblio->{'homebranch'};
    my $originbranchcode = GetItemOriginBranch($itemnumber);
    my $barcode = $itembiblio->{'barcode'};
    my ($dotransfer, $messages, $iteminformation);

    if ($originbranchcode && $barcode) {
        if (C4::Circulation::GetTransfers($itemnumber)) {
            C4::Circulation::DeleteTransfer($itemnumber)
        }
        ($dotransfer, $messages, $iteminformation) = C4::Circulation::transferbook($originbranchcode, $barcode, 1);
    }

    my $dbh = C4::Context->dbh;
    my $sth;
    $sth = $dbh->prepare(
        "DELETE FROM collections_tracking
                        WHERE itemnumber = ?"
    );
    $sth->execute($itemnumber) or return ( 0, 3, $sth->errstr() );
    C4::Items::ModItem({ homebranch => $originbranchcode }, undef, $itemnumber);

    return (1, 4, $messages);
}
=head2  ReturnCollectionToOrigin

 ($success, $errorcode, $errormessage) = ReturnCollectionToOrigin($colId);

Marks a collection to be returned to their origin branch, e.g. the branch that was
the item's home branch when it was first added to the collection

 Input:
   $colId: Collection the returned item belongs to

 Output:
   $success: 1 if all database operations were successful, 0 otherwise
   $errorcode: Code for reason of failure, good for translating errors in templates
   $errormessages: English description of any errors with return operations
=cut

sub ReturnCollectionToOrigin {
    my $colId = shift;

    if (!$colId) {
        return (0, 1, "No collection id given");
    }

    my $collectionItems = GetItemsInCollection($colId);
    my $collectionItemsCount = scalar(@$collectionItems);
    my ($colSuccess, $errorcode, @errormessages);

    for my $item (@$collectionItems) {
        my $itemOriginBranch = GetItemOriginBranch($item->{'itemnumber'});
        my ($success, $errocode, $errormessage);
        if ($itemOriginBranch) {
            ($success, $errorcode, $errormessage) =
                ReturnCollectionItemToOrigin($colId, $item->{'itemnumber'});
            if (!$success) {
                push(@errormessages, $item->{'itemnumber'} . ": " . $errormessage);
            }
        }
    }
    my $errorCount = scalar(@errormessages);
    if ($errorCount == $collectionItemsCount) {
        return (0, 2, "No items in collection transferred");
    }
    else {
        # Some items were succesfully returned - return info about failed transfers for template usage
        return (1, 0, \@errormessages);
    }
}

=head2  ReturnCollectionItemToOrigin

 ($success, $errorcode, $errormessage) = ReturnCollectionItemToOrigin($colId, $itemnumber);

Marks a collection item to be returned to their origin branch, e.g. the branch that was
the item's home branch when it was first added to the collection

 Input:
   $colId: Collection the returned item belongs to
   $itemnumber: Item in the collection to be returned to their origin branch

 Output:
   $success: 1 if all database operations were successful, 0 otherwise
   $errorCode: Code for reason of failure, good for translating errors in templates
   $errorMessage: English description of error

=cut

sub ReturnCollectionItemToOrigin {
    my ($colId, $itemnumber) = @_;
    my $originBranch = GetItemOriginBranch($itemnumber);
    my @errorlist;

    ## Check for all neccessary parameters
    if (!$colId) {
        return (0, 1, "No collection id given");
    }
    if (!$itemnumber) {
        return (0, 2, "No itemnumber given");
    }

    if (!$originBranch) {
        return (0, 3, "Item has no origin branch set");
    }

    if (!isItemTransferred($itemnumber)) {
        return (0, 4, "Cannot return an item that is not transferred");
    }

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(q{
        SELECT items.itemnumber, items.barcode, items.homebranch, items.holdingbranch FROM collections_tracking
        LEFT JOIN items ON collections_tracking.itemnumber = items.itemnumber
        LEFT JOIN issues ON items.itemnumber = issues.itemnumber
        WHERE issues.borrowernumber IS NULL
          AND collections_tracking.colId = ? AND collections_tracking.itemnumber = ?
    });

    $sth->execute($colId, $itemnumber) or return (0, 5, $sth->errstr);
    my ($dotransfer, $messages, $iteminformation);
    if (my $item = $sth->fetchrow_hashref) {
        unless (C4::Reserves::GetReserveStatus($item->{itemnumber}) eq "Waiting") {
            ($dotransfer, $messages, $iteminformation)
                = C4::Circulation::transferbook($originBranch, $item->{barcode}, 1);
        }
    }
    # Push all issues with the transfer into a list for template usage.
    if (!$dotransfer) {
        for my $message (keys %$messages) {
            push(@errorlist, $itemnumber . ": " .  $message);
        }
    }

    $sth = $dbh->prepare(q{
        UPDATE collections_tracking
        SET
        transfer_branch = NULL,
        transferred = 0
        WHERE itemnumber = ?
    });
    $sth->execute($itemnumber) or return (0, 7, $sth->errstr);
    C4::Items::ModItem({ homebranch => $originBranch }, undef, $itemnumber);

    return (1, 6, \@errorlist);
}

=head2 TransferCollection

 ( $success, $errorcode, $errormessage ) = TransferCollection( $colId, $colBranchcode );

Transfers a collection to another branch

 Input:
   $colId: id of the collection to be updated
   $colBranchcode: branch where collection is moving to

 Output:
   $success: 1 if all database operations were successful, 0 otherwise
   $errorCode: Code for reason of failure, good for translating errors in templates
   $errorMessage: English description of error

=cut

sub TransferCollection {
    my ( $colId, $colBranchcode ) = @_;

    ## Check for all necessary parameters
    if ( !$colId ) {
        return ( 0, 1, "NO_ID" );
    }
    if ( !$colBranchcode ) {
        return ( 0, 2, "NO_BRANCHCODE" );
    }

    my $colItems = GetItemsInCollection($colId);
    my $colItemsCount = scalar(@$colItems);
    my ($transfersuccess, $error, @errorlist);
    my $problemItemCount = 0;

    for my $item (@$colItems) {
        my $itemOriginBranch = GetItemOriginBranch($item->{'itemnumber'});
    my $itemCurHomeBranch = $item->{'homebranch'};
        my ($dotransfer, $errorcode, $errormessage) = TransferCollectionItem($colId, $item->{'itemnumber'}, $colBranchcode);
        if (!$dotransfer) {
            $problemItemCount++;
            push(@errorlist, $item->{'title'} . ":");
            if (ref $errormessage eq "ARRAY") {
                for my $message (@$errormessage) {
                    push(@errorlist, $message);
                }
            }
            else {
                push (@errorlist, $errormessage);
            }
        }
    }

    if ($problemItemCount == $colItemsCount) {
        return (0, 3, \@errorlist);
    }
    elsif ($problemItemCount < $colItemsCount) {
        return (1, 0, \@errorlist);
    }
    else {
        return 1;
    }

}

=head2 TransferItem

 ($success, $errorcode, $errormessage) = TransferCollection($colId, $itemnumber, $transferBranch);

Transfers an item to another branch

 Input:
   $colId: id of the collection to be updated
   $itemnumber: the itemnumber of the item in the collection being transferred
   $transferBranch: branch where item is moving to

 Output:
   $success: 1 if all database operations were successful, 0 otherwise
   $errorCode: Code for reason of failure, good for translating errors in templates
   $errorMessage: English description of error

=cut

sub TransferCollectionItem {
    my ($colId, $itemnumber, $transferBranch) = @_;
    my @errorlist;

    if (!$colId) {
        return (0, 1, "No collection id given");
    }

    if (!$itemnumber) {
        return (0, 2, "No itemnumber given");
    }

    if (!$transferBranch) {
        return (0, 3, "No transfer branch given");
    }

    if (isItemTransferred($itemnumber)) {
        return (0, 4, "Item is already transferred");
    }

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(q{
        SELECT items.itemnumber, items.barcode, items.homebranch FROM collections_tracking
        LEFT JOIN items ON collections_tracking.itemnumber = items.itemnumber
        LEFT JOIN issues ON items.itemnumber = issues.itemnumber
        WHERE issues.borrowernumber IS NULL
          AND collections_tracking.colId = ? AND collections_tracking.itemnumber = ?
    });

    $sth->execute($colId, $itemnumber) or return ( 0, 5, $sth->errstr );
    my ($dotransfer, $messages, $iteminformation);
    if (my $item = $sth->fetchrow_hashref) {
        unless (C4::Reserves::GetReserveStatus($item->{itemnumber}) eq "Waiting") {
            ($dotransfer, $messages, $iteminformation)
                = C4::Circulation::transferbook($transferBranch, $item->{barcode}, 1);
        }
    }

    # Push all issues with the transfer into a list for template usage.
    if (!$dotransfer) {
        for my $message (keys %$messages) {
            push(@errorlist, $message);
        }
    }
    my $transferred = 1;

    $sth = $dbh->prepare(q{
        UPDATE collections_tracking
        SET
        transfer_branch = ?,
        transferred = ?
        WHERE itemnumber = ?
    });
    $sth->execute($transferBranch, $transferred, $itemnumber) or return (0, 7, $sth->errstr);
    C4::Items::ModItem({ homebranch => $transferBranch }, undef, $itemnumber);

    return (1, 6, \@errorlist);
}

=head2 GetCollectionItemBranches

  my ( $holdingBranch, $collectionBranch ) = GetCollectionItemBranches( $itemnumber );

=cut

sub GetCollectionItemBranches {
    my ($itemnumber) = @_;

    if ( !$itemnumber ) {
        return;
    }

    my $dbh = C4::Context->dbh;

    my ( $sth, @results );
    $sth = $dbh->prepare(
"SELECT holdingbranch, transfer_branch FROM items, collections, collections_tracking
                        WHERE items.itemnumber = collections_tracking.itemnumber
                        AND collections.colId = collections_tracking.colId
                        AND items.itemnumber = ?"
    );
    $sth->execute($itemnumber);

    my $row = $sth->fetchrow_hashref;

    return ( $$row{'holdingbranch'}, $$row{'transfer_branch'}, );
}

=head2 GetTransferredItemCount

  $transferredCount = GetTransferredItemCount($colId);

=cut

sub GetTransferredItemCount {
  my $colId = shift;

  my $dbh = C4::Context->dbh;
  my $query = "SELECT COUNT(*)
              FROM collections_tracking
              WHERE colId = ? AND transferred = 1
              ";
  my $sth = $dbh->prepare($query);
  $sth->execute($colId) or die $sth->errstr();

  my $result = $sth->fetchrow();
  return $result;
}

=head2 GetCollectionItemCount

  $colItemCount = GetCollectionItemCount($colId);

=cut

sub GetCollectionItemCount {
  my $colId = shift;

  my $dbh = C4::Context->dbh;
  my $query = "SELECT COUNT(colId)
              FROM collections_tracking
              WHERE colId = ?
              ";
  my $sth = $dbh->prepare($query);
  $sth->execute($colId) or die $sth->errstr();

  my $result = $sth->fetchrow();
  return $result;
}

=head2 isItemInThisCollection

  $inCollection = isItemInThisCollection( $itemnumber, $colId );

=cut

sub isItemInThisCollection {
    my ( $itemnumber, $colId ) = @_;

    my $dbh = C4::Context->dbh;

    my $sth = $dbh->prepare(
"SELECT COUNT(*) as inCollection FROM collections_tracking WHERE itemnumber = ? AND colId = ?"
    );
    $sth->execute( $itemnumber, $colId ) or return (0);

    my $row = $sth->fetchrow_hashref;

    return $$row{'inCollection'};
}

=head2 isItemInAnyCollection

$inCollection = isItemInAnyCollection( $itemnumber );

=cut

sub isItemInAnyCollection {
    my ($itemnumber) = @_;

    my $dbh = C4::Context->dbh;

    my $sth = $dbh->prepare(
        "SELECT itemnumber FROM collections_tracking WHERE itemnumber = ?");
    $sth->execute($itemnumber) or return (0);

    my $row = $sth->fetchrow_hashref;

    $itemnumber = $row->{itemnumber};
    if ($itemnumber) {
        return 1;
    }
    else {
        return 0;
    }
}

=head2 isItemTramsferred

($transferred, $errorcode, $errormessage) = isItemTransferred($itemnumber);

=cut

sub isItemTransferred {
    my $itemnumber = shift;

    my $dbh = C4::Context->dbh;
    my $sth;

    my $query = '
    Select * FROM collections_tracking
    WHERE itemnumber = ?
    ';

    $sth = $dbh->prepare($query);
    $sth->execute($itemnumber) or return (0, 1, $sth->errstr);
    my $resultrow = $sth->fetchrow_hashref;
    if (!$resultrow) {
        return (0, 2, "Item is not in a collection");
    }

    if ($resultrow->{'transfer_branch'}) {
        return 1;
    }
    else {
        return 0;
    }

}



=head2 GetItemOriginBranch

$originBranch = GetItemOriginBranch($itemnumber);

Kd-139: Returns the given item's origin branch, e.g. the home branch at the time it was
being added to a collection or 0 the item has no origin

=cut

sub GetItemOriginBranch {
    my $itemnumber = shift;

    my $dbh = C4::Context->dbh;
    my $sth;

    my $query = '
    SELECT *
    FROM collections_tracking
    WHERE itemnumber = ?
    ';
    $sth = $dbh->prepare($query);
    $sth->execute($itemnumber);
    my $resultrow = $sth->fetchrow_hashref;

    if (!$resultrow) {
        return 0;
    }

    my $originBranchCode = $resultrow->{'origin_branchcode'};
    if ($originBranchCode) {
        return $originBranchCode;
    }
    else {
        return 0;
    }
}

1;

__END__

=head1 AUTHOR

Kyle Hall <kylemhall@gmail.com>

=cut
