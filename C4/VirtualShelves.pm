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
use Carp;
use C4::Context;
use C4::Circulation;
use C4::Debug;
use C4::Members;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

BEGIN {
	# set the version for version checking
	$VERSION = 3.02;
	require Exporter;
	@ISA    = qw(Exporter);
	@EXPORT = qw(
        &GetShelves &GetShelfContents &GetShelf
		&GetRecentShelves &GetShelvesSummary

        &AddToShelf &AddToShelfFromBiblio &AddShelf

		&SetShelvesLimit
		&RefreshShelvesSummary

        &ModShelf
        &ShelfPossibleAction
        &DelFromShelf &DelShelf
	);
}

use C4::Auth qw(get_session);

my $dbh = C4::Context->dbh;

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

=item GetShelves

  ($shelflist, $totshelves) = &GetShelves($mincategory, $row_count, $offset, $owner);
  ($shelfnumber, $shelfhash) = each %{$shelflist};

Returns the number of shelves specified by C<$row_count> and C<$offset> as well as the total
number of shelves that meet the C<$owner> and C<$mincategory> criteria.  C<$mincategory>,
C<$row_count>, and C<$offset> are required. C<$owner> must be supplied when C<$mincategory> == 1.
When C<$mincategory> is 2 or 3, supply undef as argument for C<$owner>.
C<$shelflist>is a reference-to-hash. The keys are the virtualshelves numbers (C<$shelfnumber>, above),
and the values (C<$shelfhash>, above) are themselves references-to-hash, with the following keys:

=over 4

=item C<$shelfhash-E<gt>{shelfname}>

A string. The name of the shelf.

=item C<$shelfhash-E<gt>{count}>

The number of virtuals on that virtualshelves.

=back

=cut

sub GetShelves ($$$$) {
    my ($mincategory, $row_count, $offset, $owner) = @_;
	my @params = ($owner, $mincategory, ($offset ? $offset : 0), $row_count);
	my @params1 = ($owner, $mincategory);
	if ($mincategory > 1) {
		shift @params;
		shift @params1;
	}
	my $total = _shelf_count($owner, $mincategory);
    # grab only the shelves meeting the row_count/offset spec...
    my $query = qq(
        SELECT virtualshelves.shelfnumber, virtualshelves.shelfname,owner,surname,firstname,virtualshelves.category,virtualshelves.sortfield,
               count(virtualshelfcontents.biblionumber) as count
        FROM   virtualshelves
            LEFT JOIN   virtualshelfcontents ON virtualshelves.shelfnumber = virtualshelfcontents.shelfnumber
            LEFT JOIN   borrowers ON virtualshelves.owner = borrowers.borrowernumber );
    $query .= ($mincategory == 1) ? "WHERE  owner=? AND category=?" : "WHERE category>=?";
	$query .= qq(
        GROUP BY virtualshelves.shelfnumber
        ORDER BY virtualshelves.category
		DESC 
		LIMIT ?, ?);
    my $sth2 = $dbh->prepare($query);
    $sth2->execute(@params);
    my %shelflist;
    while ( my ( $shelfnumber, $shelfname, $owner, $surname,
           	$firstname,   $category,  $sortfield, $count ) = $sth2->fetchrow ) {
        $shelflist{$shelfnumber}->{'shelfname'} = $shelfname;
        $shelflist{$shelfnumber}->{'count'}     = $count;
        $shelflist{$shelfnumber}->{'sortfield'} = $sortfield;
        $shelflist{$shelfnumber}->{'category'}  = $category;
        $shelflist{$shelfnumber}->{'owner'}     = $owner;
        $shelflist{$shelfnumber}->{'surname'}   = $surname;
        $shelflist{$shelfnumber}->{'firstname'} = $firstname;
    }
    return ( \%shelflist, $total );
}

=item GetShelvesSummary

	($shelves, $total) = GetShelvesSummary($mincategory, $row_count, $offset, $owner)

Returns the number of shelves specified by C<$row_count> and C<$offset> as well as the total
number of shelves that meet the C<$owner> and/or C<$mincategory> criteria. C<$mincategory>,
C<$row_count>, and C<$offset> are required. C<$owner> must be supplied when C<$mincategory> == 1.
When C<$mincategory> is 2 or 3, supply undef as argument for C<$owner>.

=cut

sub GetShelvesSummary ($$$$) {
    my ($mincategory, $row_count, $offset, $owner) = @_;
	my @params = ($owner, $mincategory, ($offset ? $offset : 0), $row_count);
	my @params1 = ($owner, $mincategory);
	if ($mincategory > 1) {
		shift @params;
		shift @params1;
	}
	my $total = _shelf_count($owner, $mincategory);
    # grab only the shelves meeting the row_count/offset spec...
	my $query = qq(
		SELECT
			virtualshelves.shelfnumber,
			virtualshelves.shelfname,
			owner,
			CONCAT(firstname, ' ', surname) AS name,
			virtualshelves.category,
			count(virtualshelfcontents.biblionumber) AS count
		FROM   virtualshelves
			LEFT JOIN  virtualshelfcontents ON virtualshelves.shelfnumber = virtualshelfcontents.shelfnumber
			LEFT JOIN             borrowers ON virtualshelves.owner = borrowers.borrowernumber );
    $query .= ($mincategory == 1) ? "WHERE  owner=? AND category=?" : "WHERE category>=?";
	$query .= qq(
		GROUP BY virtualshelves.shelfnumber
		ORDER BY virtualshelves.category
		DESC 
		LIMIT ?, ?);
	my $sth2 = $dbh->prepare($query);
	$sth2->execute(@params);
    my $shelves = $sth2->fetchall_arrayref({});
    return ($shelves, $total);

	# Probably NOT the final implementation since it is still bulky (repeated hash keys).
	# might like an array of rows of delimited values:
	# 1|2||0|blacklist|112
	# 2|6|Josh Ferraro|51|en_fuego|106
}

=item GetRecentShelves

	($shelflist) = GetRecentShelves(1, $limit, $owner)

This function returns a references to an array of hashrefs containing specified shelves sorted
by the date the shelf was last modified in descending order limited to the number of records
specified by C<$row_count>. If calling with C<$mincategory> other than 1, use undef as C<$owner>.

This function is intended to return a dataset reflecting the most recently active shelves for
the submitted parameters.

=cut

sub GetRecentShelves ($$$) {
	my ($mincategory, $row_count, $owner) = @_;
    my (@shelflist);
	my $total = _shelf_count($owner, $mincategory);
	my @params = ($owner, $mincategory, 0, $row_count);	 #FIXME: offset is hardcoded here, but could be passed in for enhancements
	shift @params if !$owner;
	my $query = "SELECT * FROM virtualshelves";
	$query .= ($owner ? " WHERE owner = ? AND category = ?" : " WHERE category >= ? ");
	$query .= " ORDER BY lastmodified DESC LIMIT ?, ?";
	my $sth = $dbh->prepare($query);
	$sth->execute(@params);
	@shelflist = $sth->fetchall_arrayref({});
	return ( \@shelflist, $total );
}

=item GetShelf

  (shelfnumber,shelfname,owner,category,sortfield) = &GetShelf($shelfnumber);

Looks up information about the contents of virtual virtualshelves number
C<$shelfnumber>

Returns the database's information on 'virtualshelves' table.

=cut

sub GetShelf ($) {
    my ($shelfnumber) = @_;
    my $query = qq(
        SELECT shelfnumber, shelfname, owner, category, sortfield
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

Note: the notforloan status comes from the itemtype, and where it equals 0
it does not ensure that related items.notforloan status is likewise 0. The
caller has to check any items on their own, possibly with CanBookBeIssued
from C4::Circulation.

=cut

sub GetShelfContents ($$;$$) {
    my ($shelfnumber, $row_count, $offset, $sortfield) = @_;
    my $dbh=C4::Context->dbh();
	my $sth1 = $dbh->prepare("SELECT count(*) FROM virtualshelfcontents WHERE shelfnumber = ?");
	$sth1->execute($shelfnumber);
	my $total = $sth1->fetchrow;
	if(!$sortfield) {
		my $sth2 = $dbh->prepare('SELECT sortfield FROM virtualshelves WHERE shelfnumber=?');
		$sth2->execute($shelfnumber);
		($sortfield) = $sth2->fetchrow_array;
	}
    my $query =
       " SELECT vc.biblionumber, vc.shelfnumber, vc.dateadded,
	   			biblio.*, biblioitems.itemtype, itemtypes.*
         FROM   virtualshelfcontents vc
		 LEFT JOIN biblio      ON      vc.biblionumber =      biblio.biblionumber
		 LEFT JOIN biblioitems ON  biblio.biblionumber = biblioitems.biblionumber
		 LEFT JOIN itemtypes   ON biblioitems.itemtype = itemtypes.itemtype
         WHERE  vc.shelfnumber=? ";
	my @params = ($shelfnumber);
	if($sortfield) {
		$query .= " ORDER BY ? ";
		$query .= " DESC " if ($sortfield eq 'copyrightdate');
		push (@params, $sortfield);
	}
	$query .= " LIMIT ?, ? ";
	push (@params, ($offset ? $offset : 0));
	push (@params, $row_count);
    my $sth3 = $dbh->prepare($query);
	$sth3->execute(@params);
	return ($sth3->fetchall_arrayref({}), $total);
	# Like the perldoc says,
	# returns reference-to-array, where each element is reference-to-hash of the row:
	#   like [ $sth->fetchrow_hashref(), $sth->fetchrow_hashref() ... ] 
	# Suitable for use in TMPL_LOOP.
	# See http://search.cpan.org/~timb/DBI-1.601/DBI.pm#fetchall_arrayref
	# or newer, for your version of DBI.
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
    my ( $shelfname, $owner, $category, $sortfield ) = @_;
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
            (shelfname,owner,category,sortfield)
        VALUES (?,?,?,?)
    );
    $sth = $dbh->prepare($query);
    $sth->execute( $shelfname, $owner, $category, $sortfield );
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
    ($sth->rows) and return undef;	# already on shelf
	$query = qq(
		INSERT INTO virtualshelfcontents
			(shelfnumber, biblionumber, flags)
		VALUES
			(?, ?, 0)
	);
	$sth = $dbh->prepare($query);
	$sth->execute( $shelfnumber, $biblionumber );
	$query = qq(UPDATE virtualshelves
				SET lastmodified = CURRENT_TIMESTAMP
				WHERE shelfnumber = ?);
	$sth = $dbh->prepare($query);
	$sth->execute( $shelfnumber );
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
		$query = qq(UPDATE virtualshelves
					SET lastmodified = CURRENT_TIMESTAMP
					WHERE shelfnumber = ?);
		$sth = $dbh->prepare($query);
		$sth->execute( $shelfnumber );
    }
}

=item ModShelf

ModShelf($shelfnumber, $hashref)

Where $hashref->{column} = param

Modify the value into virtualshelves table with values given 
from hashref, which each key of the hashref should be
the name of a column of virtualshelves.

=cut

sub ModShelf {
    my $shelfnumber = shift;
    my $shelf = shift;

    if (exists $shelf->{shelfnumber}) {
        carp "Should not use ModShelf to change shelfnumber";
        return;
    }
    unless (defined $shelfnumber and $shelfnumber =~ /^\d+$/) {
        carp "Invalid shelfnumber passed to ModShelf: $shelfnumber";
        return;
    }

	my $query = "UPDATE virtualshelves SET ";
    my @bind_params = ();
    my @set_clauses = ();

	foreach my $column (keys %$shelf) {
        push @set_clauses, "$column = ?";
        push @bind_params, $shelf->{$column};
    }

    if ($#set_clauses == -1) {
        carp "No columns to update passed to ModShelf";
        return;
    }
    $query .= join(", ", @set_clauses);

    $query .= " WHERE shelfnumber = ? ";
    push @bind_params, $shelfnumber;

    $debug and warn "ModShelf query:\n $query\n",
	                "ModShelf query args: ", join(',', @bind_params), "\n";
	my $sth = $dbh->prepare($query);
   	$sth->execute( @bind_params );
}

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
	my $borrower = GetMemberDetails($user);
	return 1 if ( $category >= 3);							# open list
    return 1 if (($category >= 2) and
				defined($action) and $action eq 'view');	# public list, anybody can view
    return 1 if (($category >= 2) and defined($user) and ($borrower->{authflags}->{superlibrarian} || $user == 0));	# public list, superlibrarian can edit/delete
    return 1 if (defined($user)  and $owner  eq $user );	# user owns this list.  Check last.
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

=item DelShelf (old version)

  ($status, $msg) = &DelShelf($shelfnumber);

Deletes virtual virtualshelves number C<$shelfnumber>. The virtualshelves must
be empty.

Returns a two-element array, where C<$status> is 0 if the operation
was successful, or non-zero otherwise. C<$msg> is "Done" in case of
success, or an error message giving the reason for failure.

=item DelShelf (current version)

  $Number = DelShelf($shelfnumber);

This function deletes the shelf number, and all of it's content.

=cut

sub DelShelf {
	unless (@_) {
		carp "DelShelf called without valid argument (shelfnumber)";
		return undef;
	}
	my $sth = $dbh->prepare("DELETE FROM virtualshelves WHERE shelfnumber=?");
	return $sth->execute(shift);
}

=item RefreshShelvesSummary

	($total, $pubshelves, $barshelves) = RefreshShelvesSummary($sessionID, $loggedinuser, $row_count);

Updates the current session and userenv with the most recent shelves

Returns the total number of shelves stored in the session/userenv along with two references each to an
array of hashes, one containing the C<$loggedinuser>'s private shelves and one containing all public/open shelves.

This function is used in conjunction with the 'Lists' button in masthead.inc.

=cut

sub RefreshShelvesSummary ($$$) {
	
	my ($sessionID, $loggedinuser, $row_count) = @_;
	my $session = get_session($sessionID);
	my ($total, $totshelves, $barshelves, $pubshelves);

	($barshelves, $totshelves) = GetRecentShelves(1, $row_count, $loggedinuser);
	$total->{'bartotal'} = $totshelves;
	($pubshelves, $totshelves) = GetRecentShelves(2, $row_count, undef);
	$total->{'pubtotal'} = $totshelves;

	# Update the current session with the latest shelves...
	$session->param('barshelves', ${@$barshelves}[0]);
	$session->param('pubshelves', ${@$pubshelves}[0]);
	$session->param('totshelves', $total);

	# likewise the userenv...
	C4::Context->set_shelves_userenv('bar',${@$barshelves}[0]);
	C4::Context->set_shelves_userenv('pub',${@$pubshelves}[0]);
	C4::Context::set_shelves_userenv('tot',$total);

	return ($total, $pubshelves, $barshelves);
}

# internal subs

sub _shelf_count ($$) {
	my (@params) = @_;
	# Find out how many shelves total meet the submitted criteria...
	my $query = "SELECT count(*) FROM virtualshelves";
	$query .= ($params[1] > 1) ? " WHERE category >= ?" : " WHERE  owner=? AND category=?";
	shift @params if $params[1] > 1;
	my $sth = $dbh->prepare($query);
	$sth->execute(@params);
	my $total = $sth->fetchrow;
	return $total;
}

1;

__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=head1 SEE ALSO

C4::Circulation::Circ2(3)

=cut
