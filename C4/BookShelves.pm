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
use DBI;
use C4::Context;
use C4::Circulation::Circ2;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

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

@ISA = qw(Exporter);
@EXPORT = qw(&GetShelfList &GetShelfContents &AddToShelf &RemoveFromShelf &AddShelf &RemoveShelf);

my $dbh = C4::Context->dbh;

=item GetShelfList

  $shelflist = &GetShelfList();
  ($shelfnumber, $shelfhash) = each %{$shelflist};

Looks up the virtual bookshelves, and returns a summary. C<$shelflist>
is a reference-to-hash. The keys are the bookshelf numbers
(C<$shelfnumber>, above), and the values (C<$shelfhash>, above) are
themselves references-to-hash, with the following keys:

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
sub GetShelfList {
    # FIXME - These two database queries can be combined into one:
    #	SELECT		bookshelf.shelfnumber, bookshelf.shelfname,
    #			count(shelfcontents.itemnumber)
    #	FROM		bookshelf
    #	LEFT JOIN	shelfcontents
    #	ON		bookshelf.shelfnumber = shelfcontents.shelfnumber
    #	GROUP BY	bookshelf.shelfnumber
    my $sth=$dbh->prepare("select shelfnumber,shelfname from bookshelf");
    $sth->execute;
    my %shelflist;
    while (my ($shelfnumber, $shelfname) = $sth->fetchrow) {
	my $sti=$dbh->prepare("select count(*) from shelfcontents where shelfnumber=?");
		# FIXME - Should there be an "order by" in here somewhere?
	$sti->execute($shelfnumber);
	my ($count) = $sti->fetchrow;
	$shelflist{$shelfnumber}->{'shelfname'}=$shelfname;
	$shelflist{$shelfnumber}->{'count'}=$count;
    }
    return(\%shelflist);
}

=item GetShelfContents

  $itemlist = &GetShelfContents($env, $shelfnumber);

Looks up information about the contents of virtual bookshelf number
C<$shelfnumber>.

Returns a reference-to-array, whose elements are references-to-hash,
as returned by C<&getiteminformation>.

I don't know what C<$env> is.

=cut
#'
sub GetShelfContents {
    my ($env, $shelfnumber) = @_;
    my @itemlist;
    my $sth=$dbh->prepare("select itemnumber from shelfcontents where shelfnumber=? order by itemnumber");
    $sth->execute($shelfnumber);
    while (my ($itemnumber) = $sth->fetchrow) {
	my ($item) = getiteminformation($env, $itemnumber, 0);
	push (@itemlist, $item);
    }
    return (\@itemlist);
}

=item AddToShelf

  &AddToShelf($env, $itemnumber, $shelfnumber);

Adds item number C<$itemnumber> to virtual bookshelf number
C<$shelfnumber>, unless that item is already on that shelf.

C<$env> is ignored.

=cut
#'
sub AddToShelf {
    my ($env, $itemnumber, $shelfnumber) = @_;
    my $sth=$dbh->prepare("select * from shelfcontents
	where shelfnumber=? and itemnumber=?");

    $sth->execute($shelfnumber, $itemnumber);
    if ($sth->rows) {
# already on shelf
    } else {
	$sth=$dbh->prepare("insert into shelfcontents
		(shelfnumber, itemnumber, flags) values (?, ?, 0)");

			# FIXME - The default for 'flags' is NULL.
			# Why set it to 0?
	$sth->execute($shelfnumber, $itemnumber);
    }
}

=item RemoveFromShelf

  &RemoveFromShelf($env, $itemnumber, $shelfnumber);

Removes item number C<$itemnumber> from virtual bookshelf number
C<$shelfnumber>. If the item wasn't on that bookshelf to begin with,
nothing happens.

C<$env> is ignored.

=cut
#'
sub RemoveFromShelf {
    my ($env, $itemnumber, $shelfnumber) = @_;
    my $sth=$dbh->prepare("delete from shelfcontents where shelfnumber=? and itemnumber=?");
    $sth->execute($shelfnumber,$itemnumber);
}

=item AddShelf

  ($status, $msg) = &AddShelf($env, $shelfname);

Creates a new virtual bookshelf with name C<$shelfname>.

Returns a two-element array, where C<$status> is 0 if the operation
was successful, or non-zero otherwise. C<$msg> is "Done" in case of
success, or an error message giving the reason for failure.

C<$env> is ignored.

=cut
#'
# FIXME - Perhaps this could/should return the number of the new bookshelf
# as well?
sub AddShelf {
    my ($env, $shelfname) = @_;
    my $sth=$dbh->prepare("select * from bookshelf where shelfname=?");
	$sth->execute($shelfname);
    if ($sth->rows) {
	return(1, "Shelf \"$shelfname\" already exists");
    } else {
	$sth=$dbh->prepare("insert into bookshelf (shelfname) values (?)");
	$sth->execute($shelfname);
	return (0, "Done");
    }
}

=item RemoveShelf

  ($status, $msg) = &RemoveShelf($env, $shelfnumber);

Deletes virtual bookshelf number C<$shelfnumber>. The bookshelf must
be empty.

Returns a two-element array, where C<$status> is 0 if the operation
was successful, or non-zero otherwise. C<$msg> is "Done" in case of
success, or an error message giving the reason for failure.

C<$env> is ignored.

=cut
#'
sub RemoveShelf {
    my ($env, $shelfnumber) = @_;
    my $sth=$dbh->prepare("select count(*) from shelfcontents where shelfnumber=?");
	$sth->execute($shelfnumber);
    my ($count)=$sth->fetchrow;
    if ($count) {
	return (1, "Shelf has $count items on it.  Please remove all items before deleting this shelf.");
    } else {
	$sth=$dbh->prepare("delete from bookshelf where shelfnumber=?");
	$sth->execute($shelfnumber);
	return (0, "Done");
    }
}

END { }       # module clean-up code here (global destructor)

1;

#
# $Log$
# Revision 1.11  2003/12/15 10:57:08  slef
# DBI call fix for bug 662
#
# Revision 1.10  2003/02/05 10:05:02  acli
# Converted a few SQL statements to use ? to fix a few strange SQL errors
# Noted correct tab size
#
# Revision 1.9  2002/10/13 08:29:18  arensb
# Deleted unused variables.
# Removed trailing whitespace.
#
# Revision 1.8  2002/10/10 04:32:44  arensb
# Simplified references.
#
# Revision 1.7  2002/10/05 09:50:10  arensb
# Merged with arensb-context branch: use C4::Context->dbh instead of
# &C4Connect, and generally prefer C4::Context over C4::Database.
#
# Revision 1.6.2.1  2002/10/04 02:24:43  arensb
# Use C4::Connect instead of C4::Database, C4::Connect->dbh instead
# C4Connect.
#
# Revision 1.6  2002/09/23 13:50:30  arensb
# Fixed missing bit in POD.
#
# Revision 1.5  2002/09/22 17:29:17  arensb
# Added POD.
# Added some FIXME comments.
# Removed useless trailing whitespace.
#
# Revision 1.4  2002/08/14 18:12:51  tonnesen
# Added copyright statement to all .pl and .pm files
#
# Revision 1.3  2002/07/02 17:48:06  tonnesen
# Merged in updates from rel-1-2
#
# Revision 1.2.2.1  2002/06/26 20:46:48  tonnesen
# Inserting some changes I made locally a while ago.
#
#

__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=head1 SEE ALSO

C4::Circulation::Circ2(3)

=cut
