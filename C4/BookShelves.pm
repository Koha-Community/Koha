# -*- tab-width: 8 -*-
# Please use 8-character tabs for this file (indents are every 4 characters)

package C4::BookShelves;

# $Id$

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
require Exporter;
use C4::Context;
use C4::Circulation::Circ2;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = do { my @v = '$Revision$' =~ /\d+/g; shift(@v) . "." . join( "_", map { sprintf "%03d", $_ } @v ); };

=head1 NAME

C4::BookShelves - Functions for manipulating Koha virtual bookshelves

=head1 SYNOPSIS

  use C4::BookShelves;

=head1 DESCRIPTION

This module provides functions for manipulating virtual bookshelves,
including creating and deleting bookshelves, and adding and removing
items to and from bookshelves.

=head1 FUNCTIONS

=over 2

=cut

@ISA    = qw(Exporter);
@EXPORT = qw(
        &GetShelves &GetShelfContents &GetShelf

        &AddToShelf &AddToShelfFromBiblio &AddShelf

        &ModShelf
        &ShelfPossibleAction
        &DelFromShelf &DelShelf
);

my $dbh = C4::Context->dbh;

=item GetShelves

  $shelflist = &GetShelves($owner, $mincategory);
  ($shelfnumber, $shelfhash) = each %{$shelflist};

Looks up the virtual bookshelves, and returns a summary. C<$shelflist>
is a reference-to-hash. The keys are the bookshelf numbers
(C<$shelfnumber>, above), and the values (C<$shelfhash>, above) are
themselves references-to-hash, with the following keys:

C<mincategory> : 2 if the list is for "look". 3 if the list is for "Select bookshelf for adding a book".
bookshelves of the owner are always selected, whatever the category

=over 4

=item C<$shelfhash-E<gt>{shelfname}>

A string. The name of the shelf.

=item C<$shelfhash-E<gt>{count}>

The number of books on that bookshelf.

=back

=cut

#'
# FIXME - Wouldn't it be more intuitive to return a list, rather than
# a reference-to-hash? The shelf number can be just another key in the
# hash.

sub GetShelves {
    my ( $owner, $mincategory ) = @_;

    my $query = qq(
        SELECT bookshelf.shelfnumber, bookshelf.shelfname,owner,surname,firstname,bookshelf.category,
               count(shelfcontents.itemnumber) as count
        FROM   bookshelf
            LEFT JOIN   shelfcontents ON bookshelf.shelfnumber = shelfcontents.shelfnumber
            LEFT JOIN   borrowers ON bookshelf.owner = borrowers.borrowernumber
        WHERE  owner=? OR category>=?
        GROUP BY bookshelf.shelfnumber
        ORDER BY bookshelf.category, bookshelf.shelfname, borrowers.firstname, borrowers.surname
    );
    my $sth = $dbh->prepare($query);
    $sth->execute( $owner, $mincategory );
    my %shelflist;
    while (
        my (
            $shelfnumber, $shelfname, $owner, $surname,
            $firstname,   $category,  $count
        )
        = $sth->fetchrow
      )
    {
        $shelflist{$shelfnumber}->{'shelfname'} = $shelfname;
        $shelflist{$shelfnumber}->{'count'}     = $count;
        $shelflist{$shelfnumber}->{'category'}  = $category;
        $shelflist{$shelfnumber}->{'owner'}     = $owner;
        $shelflist{$shelfnumber}->{'surname'}     = $surname;
        $shelflist{$shelfnumber}->{'firstname'}   = $firstname;
    }
    return ( \%shelflist );
}

=item GetShef

  (shelfnumber,shelfname,owner,category) = &GetShelf($shelfnumber);

Looks up information about the contents of virtual bookshelf number
C<$shelfnumber>

Returns the database's information on 'bookshelf' table.

=cut

sub GetShelf {
    my ($shelfnumber) = @_;
    my $query = qq(
        SELECT shelfnumber,shelfname,owner,category
        FROM   bookshelf
        WHERE  shelfnumber=?
    );
    my $sth = $dbh->prepare($query);
    $sth->execute($shelfnumber);
    return $sth->fetchrow;
}

=item GetShelfContents

  $itemlist = &GetShelfContents($shelfnumber);

Looks up information about the contents of virtual bookshelf number
C<$shelfnumber>.

Returns a reference-to-array, whose elements are references-to-hash,
as returned by C<C4::Circ2::getiteminformation>.

=cut

#'
sub GetShelfContents {
    my ( $shelfnumber ) = @_;
    my @itemlist;
    my $query =
       " SELECT itemnumber
         FROM   shelfcontents
         WHERE  shelfnumber=?
         ORDER BY itemnumber
       ";
    my $sth = $dbh->prepare($query);
    $sth->execute($shelfnumber);
    my $sth2 = $dbh->prepare("
        SELECT biblio.*,biblioitems.* FROM items 
            LEFT JOIN biblio on items.biblionumber=biblio.biblionumber
            LEFT JOIN biblioitems on items.biblionumber=biblioitems.biblionumber
        WHERE items.itemnumber=?"
    );
    while ( my ($itemnumber) = $sth->fetchrow ) {
        $sth2->execute($itemnumber);
        my $item = $sth2->fetchrow_hashref;
        $item->{'itemnumber'}=$itemnumber;
        push( @itemlist, $item );
    }
    return ( \@itemlist );
}

=item AddShelf

  $shelfnumber = &AddShelf( $shelfname, $owner, $category);

Creates a new virtual bookshelf with name C<$shelfname>, owner C<$owner> and category
C<$category>.

Returns a code to know what's happen.
    * -1 : if this bookshelf already exist.
    * $shelfnumber : if success.

=cut

sub AddShelf {
    my ( $shelfname, $owner, $category ) = @_;
    my $query = qq(
        SELECT *
        FROM   bookshelf
        WHERE  shelfname=? AND owner=?
    );
    my $sth = $dbh->prepare($query);
    $sth->execute($shelfname,$owner);
    if ( $sth->rows ) {
        return (-1);
    }
    else {
        my $query = qq(
            INSERT INTO bookshelf
                (shelfname,owner,category)
            VALUES (?,?,?)
        );
        $sth = $dbh->prepare($query);
        $sth->execute( $shelfname, $owner, $category );
        my $shelfnumber = $dbh->{'mysql_insertid'};
        return ($shelfnumber);
    }
}

=item AddToShelf

  &AddToShelf($itemnumber, $shelfnumber);

Adds item number C<$itemnumber> to virtual bookshelf number
C<$shelfnumber>, unless that item is already on that shelf.

=cut

#'
sub AddToShelf {
    my ( $itemnumber, $shelfnumber ) = @_;
    return unless $itemnumber;
    my $query = qq(
        SELECT *
        FROM   shelfcontents
        WHERE  shelfnumber=? AND itemnumber=?
    );
    my $sth = $dbh->prepare($query);

    $sth->execute( $shelfnumber, $itemnumber );
    unless ( $sth->rows ) {
        # already on shelf
        my $query = qq(
            INSERT INTO shelfcontents
                (shelfnumber, itemnumber, flags)
            VALUES
                (?, ?, 0)
        );
        $sth = $dbh->prepare($query);
        $sth->execute( $shelfnumber, $itemnumber );
    }
}

=item AddToShelfFromBiblio
 
    &AddToShelfFromBiblio($biblionumber, $shelfnumber)

    this function allow to add a book into the shelf number $shelfnumber
    from biblionumber.

=cut

sub AddToShelfFromBiblio {
    my ( $biblionumber, $shelfnumber ) = @_;
    return unless $biblionumber;
    my $query = qq(
        SELECT itemnumber
        FROM   items
        WHERE  biblionumber=?
    );
    my $sth = $dbh->prepare($query);
    $sth->execute($biblionumber);
    my ($itemnumber) = $sth->fetchrow;
    $query = qq(
        SELECT *
        FROM   shelfcontents
        WHERE  shelfnumber=? AND itemnumber=?
    );
    $sth = $dbh->prepare($query);
    $sth->execute( $shelfnumber, $itemnumber );
    unless ( $sth->rows ) {
        # "already on shelf";
        my $query =qq(
            INSERT INTO shelfcontents
                (shelfnumber, itemnumber, flags)
            VALUES
                (?, ?, 0)
        );
        $sth = $dbh->prepare($query);
        $sth->execute( $shelfnumber, $itemnumber );
    }
}

=item ModShelf

ModShelf($shelfnumber, $shelfname, $owner, $category )

Modify the value into bookshelf table with values given on input arg.

=cut

sub ModShelf {
    my ( $shelfnumber, $shelfname, $owner, $category ) = @_;
    my $query = qq(
        UPDATE bookshelf
        SET    shelfname=?,owner=?,category=?
        WHERE  shelfnumber=?
    );
    my $sth = $dbh->prepare($query);
    $sth->execute( $shelfname, $owner, $category, $shelfnumber );
}

=item DelShelf

  ($status) = &DelShelf($shelfnumber);

Deletes virtual bookshelf number C<$shelfnumber>. The bookshelf must
be empty.

Returns a two-element array, where C<$status> is 0 if the operation
was successful, or non-zero otherwise. C<$msg> is "Done" in case of
success, or an error message giving the reason for failure.

=cut


=item ShelfPossibleAction

ShelfPossibleAction($loggedinuser, $shelfnumber, $action);

C<$loggedinuser,$shelfnumber,$action>

$action can be "view" or "manage".

Returns 1 if the user can do the $action in the $shelfnumber shelf.
Returns 0 otherwise.

=cut

sub ShelfPossibleAction {
    my ( $user, $shelfnumber, $action ) = @_;
    my $query = qq(
        SELECT owner,category
        FROM   bookshelf
        WHERE  shelfnumber=?
    );
    my $sth = $dbh->prepare($query);
    $sth->execute($shelfnumber);
    my ( $owner, $category ) = $sth->fetchrow;
    return 1 if (($category >= 3 or $owner eq $user) && $action eq 'manage' );
    return 1 if (($category >= 2 or $owner eq $user) && $action eq 'view' );
    return 0;
}

=item DelFromShelf

  &DelFromShelf( $itemnumber, $shelfnumber);

Removes item number C<$itemnumber> from virtual bookshelf number
C<$shelfnumber>. If the item wasn't on that bookshelf to begin with,
nothing happens.

=cut

#'
sub DelFromShelf {
    my ( $itemnumber, $shelfnumber ) = @_;
    my $query = qq(
        DELETE FROM shelfcontents
        WHERE  shelfnumber=? AND itemnumber=?
    );
    my $sth = $dbh->prepare($query);
    $sth->execute( $shelfnumber, $itemnumber );
}

=head2 DelShelf

  $Number = DelShelf($shelfnumber);

    this function delete the shelf number, and all of it's content

=cut

#'
sub DelShelf {
    my ( $shelfnumber ) = @_;
        my $sth = $dbh->prepare("DELETE FROM bookshelf WHERE shelfnumber=?");
        $sth->execute($shelfnumber);
        return 0;
}

END { }    # module clean-up code here (global destructor)

1;

__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=head1 SEE ALSO

C4::Circulation::Circ2(3)

=cut

#
# $Log$
# Revision 1.20  2007/03/09 14:31:47  tipaul
# rel_3_0 moved to HEAD
#
# Revision 1.15.8.10  2007/01/25 13:18:15  tipaul
# checking that a bookshelf with the same name AND OWNER does not exist before creating it
#
# Revision 1.15.8.9  2006/12/15 17:37:52  toins
# removing a function used only once.
#
# Revision 1.15.8.8  2006/12/14 17:22:55  toins
# bookshelves work perfectly with mod_perl and are cleaned.
#
# Revision 1.15.8.7  2006/12/13 19:46:41  hdl
# Some bug fixing.
#
# Revision 1.15.8.6  2006/12/11 17:10:06  toins
# fixing some bugs on bookshelves.
#
# Revision 1.15.8.5  2006/12/07 16:45:43  toins
# removing warn compilation. (perl -wc)
#
# Revision 1.15.8.4  2006/11/23 09:05:01  tipaul
# enable removal of a bookshelf even if there are items inside
#
# Revision 1.15.8.3  2006/10/30 09:50:20  tipaul
# removing getiteminformations (using direct SQL, as we are in a .pm, so it's "legal")
#
# Revision 1.15.8.2  2006/08/31 16:03:52  toins
# Add Pod to DelShelf
#
# Revision 1.15.8.1  2006/08/30 15:59:14  toins
# Code cleaned according to coding guide lines.
#
# Revision 1.15  2004/12/16 11:30:58  tipaul
# adding bookshelf features :
# * create bookshelf on the fly
# * modify a bookshelf name & status
#
# Revision 1.14  2004/12/15 17:28:23  tipaul
# adding bookshelf features :
# * create bookshelf on the fly
# * modify a bookshelf (this being not finished, will commit the rest soon)
