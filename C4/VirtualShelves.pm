# -*- tab-width: 8 -*-
# Please use 8-character tabs for this file (indents are every 4 characters)

package C4::VirtualShelves;


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
use C4::Circulation;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 3.00;

=head1 NAME

C4::VirtualShelves - Functions for manipulating Koha virtual virtualshelves

=head1 SYNOPSIS

  use C4::VirtualShelves;

=head1 DESCRIPTION

This module provides functions for manipulating virtual virtualshelves,
including creating and deleting virtualshelves, and adding and removing
items to and from virtualshelves.

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

Looks up the virtual virtualshelves, and returns a summary. C<$shelflist>
is a reference-to-hash. The keys are the virtualshelves numbers
(C<$shelfnumber>, above), and the values (C<$shelfhash>, above) are
themselves references-to-hash, with the following keys:

C<mincategory> : 2 if the list is for "look". 3 if the list is for "Select virtualshelves for adding a virtual".
virtualshelves of the owner are always selected, whatever the category

=over 4

=item C<$shelfhash-E<gt>{shelfname}>

A string. The name of the shelf.

=item C<$shelfhash-E<gt>{count}>

The number of virtuals on that virtualshelves.

=back

=cut

#'
# FIXME - Wouldn't it be more intuitive to return a list, rather than
# a reference-to-hash? The shelf number can be just another key in the
# hash.

sub GetShelves {
    my ( $owner, $mincategory ) = @_;

    my $query = qq(
        SELECT virtualshelves.shelfnumber, virtualshelves.shelfname,owner,surname,firstname,virtualshelves.category,virtualshelves.sortfield,
               count(virtualshelfcontents.biblionumber) as count
        FROM   virtualshelves
            LEFT JOIN   virtualshelfcontents ON virtualshelves.shelfnumber = virtualshelfcontents.shelfnumber
            LEFT JOIN   borrowers ON virtualshelves.owner = borrowers.borrowernumber
        WHERE  owner=? OR category>=?
        GROUP BY virtualshelves.shelfnumber
        ORDER BY virtualshelves.category, virtualshelves.shelfname, borrowers.firstname, borrowers.surname
    );
    my $sth = $dbh->prepare($query);
    $sth->execute( $owner, $mincategory );
    my %shelflist;
    while (
        my (
            $shelfnumber, $shelfname, $owner, $surname,
            $firstname,   $category,  $sortfield, $count
        )
        = $sth->fetchrow
      )
    {
        $shelflist{$shelfnumber}->{'shelfname'} = $shelfname;
        $shelflist{$shelfnumber}->{'count'}     = $count;
        $shelflist{$shelfnumber}->{'sortfield'}     = $sortfield;
        $shelflist{$shelfnumber}->{'category'}  = $category;
        $shelflist{$shelfnumber}->{'owner'}     = $owner;
        $shelflist{$shelfnumber}->{'surname'}     = $surname;
        $shelflist{$shelfnumber}->{'firstname'}   = $firstname;
    }
    return ( \%shelflist );
}

=item GetShelf

  (shelfnumber,shelfname,owner,category) = &GetShelf($shelfnumber);

Looks up information about the contents of virtual virtualshelves number
C<$shelfnumber>

Returns the database's information on 'virtualshelves' table.

=cut

sub GetShelf {
    my ($shelfnumber) = @_;
    my $query = qq(
        SELECT shelfnumber,shelfname,owner,category,sortfield
        FROM   virtualshelves
        WHERE  shelfnumber=?
    );
    my $sth = $dbh->prepare($query);
    $sth->execute($shelfnumber);
    return $sth->fetchrow;
}

=item GetShelfContents

  $itemlist = &GetShelfContents($shelfnumber);

Looks up information about the contents of virtual virtualshelves number
C<$shelfnumber>.  Sorted by a field in the biblio table.  copyrightdate 
gives a desc sort.

Returns a reference-to-array, whose elements are references-to-hash,
as returned by C<C4::Biblio::GetBiblioFromItemNumber>.

=cut

#'
sub GetShelfContents {
    my ( $shelfnumber ,$sortfield) = @_;
    my $dbh=C4::Context->dbh();
	if(!$sortfield) {
		my $sthsort = $dbh->prepare('select sortfield from virtualshelves where shelfnumber=?');
		$sthsort->execute($shelfnumber);
		($sortfield) = $sthsort->fetchrow_array;
	}
	my @itemlist;
    my $query =
       " SELECT vc.biblionumber,vc.shelfnumber,biblio.*
         FROM   virtualshelfcontents vc LEFT JOIN biblio on vc.biblionumber=biblio.biblionumber
         WHERE  vc.shelfnumber=? ";
    my @bind = ($shelfnumber);
	if($sortfield) {
		#$sortfield = $dbh->quote($sortfield);
		$query .= " ORDER BY `$sortfield` ";
		$query .= " DESC " if ($sortfield eq 'copyrightdate');
	}
    my $sth = $dbh->prepare($query);
    $sth->execute(@bind);
    while ( my $item = $sth->fetchrow_hashref ) {
        push( @itemlist, $item );
    }
   return ( \@itemlist );
}

=item AddShelf

  $shelfnumber = &AddShelf( $shelfname, $owner, $category);

Creates a new virtual virtualshelves with name C<$shelfname>, owner C<$owner> and category
C<$category>.

Returns a code to know what's happen.
    * -1 : if this virtualshelves already exist.
    * $shelfnumber : if success.

=cut

sub AddShelf {
    my ( $shelfname, $owner, $category ) = @_;
    my $query = qq(
        SELECT *
        FROM   virtualshelves
        WHERE  shelfname=? AND owner=?
    );
    my $sth = $dbh->prepare($query);
    $sth->execute($shelfname,$owner);
    ( $sth->rows ) and return (-1);
    $query = qq(
        INSERT INTO virtualshelves
            (shelfname,owner,category)
        VALUES (?,?,?)
    );
    $sth = $dbh->prepare($query);
    $sth->execute( $shelfname, $owner, $category );
    my $shelfnumber = $dbh->{'mysql_insertid'};
    return ($shelfnumber);
}

=item AddToShelf

  &AddToShelf($biblionumber, $shelfnumber);

Adds item number C<$biblionumber> to virtual virtualshelves number
C<$shelfnumber>, unless that item is already on that shelf.

=cut

#'
sub AddToShelf {
    my ( $biblionumber, $shelfnumber ) = @_;
    return unless $biblionumber;
    my $query = qq(
        SELECT *
        FROM   virtualshelfcontents
        WHERE  shelfnumber=? AND biblionumber=?
    );
    my $sth = $dbh->prepare($query);

    $sth->execute( $shelfnumber, $biblionumber );
    unless ( $sth->rows ) {
        # already on shelf
        my $query = qq(
            INSERT INTO virtualshelfcontents
                (shelfnumber, biblionumber, flags)
            VALUES
                (?, ?, 0)
        );
        $sth = $dbh->prepare($query);
        $sth->execute( $shelfnumber, $biblionumber );
    }
}

=item AddToShelfFromBiblio
 
    &AddToShelfFromBiblio($biblionumber, $shelfnumber)

    this function allow to add a virtual into the shelf number $shelfnumber
    from biblionumber.

=cut

sub AddToShelfFromBiblio {
    my ( $biblionumber, $shelfnumber ) = @_;
    return unless $biblionumber;
    my $query = qq(
        SELECT *
        FROM   virtualshelfcontents
        WHERE  shelfnumber=? AND biblionumber=?
    );
    my $sth = $dbh->prepare($query);
    $sth->execute( $shelfnumber, $biblionumber );
    unless ( $sth->rows ) {
        my $query =qq(
            INSERT INTO virtualshelfcontents
                (shelfnumber, biblionumber, flags)
            VALUES
                (?, ?, 0)
        );
        $sth = $dbh->prepare($query);
        $sth->execute( $shelfnumber, $biblionumber );
    }
}

=item ModShelf

ModShelf($shelfnumber, $shelfname, $owner, $category )

Modify the value into virtualshelves table with values given on input arg.

=cut

sub ModShelf {
    my ( $shelfnumber, $shelfname, $owner, $category, $sortfield ) = @_;
    my $query = qq(
        UPDATE virtualshelves
        SET    shelfname=?,owner=?,category=?,sortfield=?
        WHERE  shelfnumber=?
    );
	my $sth = $dbh->prepare($query);
    $sth->execute( $shelfname, $owner, $category, $sortfield, $shelfnumber );
}

=item DelShelf

  ($status) = &DelShelf($shelfnumber);

Deletes virtual virtualshelves number C<$shelfnumber>. The virtualshelves must
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
        FROM   virtualshelves
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

  &DelFromShelf( $biblionumber, $shelfnumber);

Removes item number C<$biblionumber> from virtual virtualshelves number
C<$shelfnumber>. If the item wasn't on that virtualshelves to begin with,
nothing happens.

=cut

#'
sub DelFromShelf {
    my ( $biblionumber, $shelfnumber ) = @_;
    my $query = qq(
        DELETE FROM virtualshelfcontents
        WHERE  shelfnumber=? AND biblionumber=?
    );
    my $sth = $dbh->prepare($query);
    $sth->execute( $shelfnumber, $biblionumber );
}

=head2 DelShelf

  $Number = DelShelf($shelfnumber);

    this function delete the shelf number, and all of it's content

=cut

#'
sub DelShelf {
	my ( $shelfnumber ) = @_;
	my $sth = $dbh->prepare("DELETE FROM virtualshelves WHERE shelfnumber=?");
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
