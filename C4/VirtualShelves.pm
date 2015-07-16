package C4::VirtualShelves;

# Copyright 2000-2002 Katipo Communications
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

use strict;
use warnings;

use Carp;
use C4::Context;
use C4::Debug;
use C4::Members;

use constant SHELVES_MASTHEAD_MAX => 10; #number under Lists button in masthead
use constant SHELVES_COMBO_MAX => 10; #add to combo in search
use constant SHELVES_MGRPAGE_MAX => 20; #managing page
use constant SHELVES_POPUP_MAX => 40; #addbybiblio popup

use constant SHARE_INVITATION_EXPIRY_DAYS => 14; #two weeks to accept

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

BEGIN {
    # set the version for version checking
    $VERSION = 3.07.00.049;
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT = qw(
            &GetShelfContents
            &ShelfPossibleAction
    );
        @EXPORT_OK = qw(
            &ShelvesMax
        );
}


=head1 NAME

C4::VirtualShelves - Functions for manipulating Koha virtual shelves

=head1 SYNOPSIS

  use C4::VirtualShelves;

=head1 DESCRIPTION

This module provides functions for manipulating virtual shelves,
including creating and deleting virtual shelves, and adding and removing
bibs to and from virtual shelves.

=head1 FUNCTIONS

=head2 GetSomeShelfNames

Returns shelf names and numbers for Add to combo of search results and Lists button of OPAC header.

=cut

sub GetSomeShelfNames {
    my ($owner, $purpose, $adding_allowed)= @_;
    my ($bar, $pub, @params);
    my $dbh = C4::Context->dbh;

    my $bquery = 'SELECT vs.shelfnumber, vs.shelfname FROM virtualshelves vs ';
    my $limit= ShelvesMax($purpose);

    my $qry1= $bquery."WHERE vs.category=2 ";
    $qry1.= "AND (allow_add=1 OR owner=?) " if $adding_allowed;
    push @params, $owner||0 if $adding_allowed;
    $qry1.= "ORDER BY vs.lastmodified DESC LIMIT $limit";

    unless($adding_allowed && (!defined($owner) || $owner<=0)) {
        #if adding items, user should be known
        $pub= $dbh->selectall_arrayref($qry1,{Slice=>{}},@params);
    }

    if($owner) {
        my $qry2= $bquery. qq{
            LEFT JOIN virtualshelfshares sh ON sh.shelfnumber=vs.shelfnumber AND sh.borrowernumber=?
            WHERE vs.category=1 AND (vs.owner=? OR sh.borrowernumber=?) };
        @params=($owner,$owner,$owner);
        $qry2.= "AND (allow_add=1 OR owner=?) " if $adding_allowed;
        push @params, $owner if $adding_allowed;
        $qry2.= "ORDER BY vs.lastmodified DESC ";
        $qry2.= "LIMIT $limit";
        $bar= $dbh->selectall_arrayref($qry2,{Slice=>{}},@params);
    }

    return ( { bartotal => $bar? scalar @$bar: 0, pubtotal => $pub? scalar @$pub: 0}, $pub, $bar);
}

=head2 GetShelfContents

  $biblist = &GetShelfContents($shelfnumber);

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

sub GetShelfContents {
    my ($shelfnumber, $row_count, $offset, $sortfield, $sort_direction ) = @_;
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
       " SELECT DISTINCT vc.biblionumber, vc.shelfnumber, vc.dateadded, itemtypes.*,
            biblio.*, biblioitems.itemtype, biblioitems.publicationyear as year, biblioitems.publishercode, biblioitems.place, biblioitems.size, biblioitems.pages
         FROM   virtualshelfcontents vc
         JOIN biblio      ON      vc.biblionumber =      biblio.biblionumber
         LEFT JOIN biblioitems ON  biblio.biblionumber = biblioitems.biblionumber
         LEFT JOIN items ON items.biblionumber=vc.biblionumber
         LEFT JOIN itemtypes   ON biblioitems.itemtype = itemtypes.itemtype
         WHERE  vc.shelfnumber=? ";
    my @params = ($shelfnumber);
    if($sortfield) {
        $query .= " ORDER BY " . $dbh->quote_identifier( $sortfield );
        $query .= " DESC " if ( $sort_direction eq 'desc' );
    }
    if($row_count){
       $query .= " LIMIT ?, ? ";
       push (@params, ($offset ? $offset : 0));
       push (@params, $row_count);
    }
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

=head2 ShelfPossibleAction

ShelfPossibleAction($loggedinuser, $shelfnumber, $action);

C<$loggedinuser,$shelfnumber,$action>

$action can be "view", "add", "delete", "manage", "new_public", "new_private".
New additional actions are: invite, acceptshare.
Note that add/delete here refers to adding/deleting entries from the list. Deleting the list itself falls under manage.
new_public and new_private refers to creating a new public or private list.
The distinction between deleting your own entries from the list or entries from
others is made when deleting a content from the shelf.

Returns 1 if the user can do the $action in the $shelfnumber shelf.
Returns 0 otherwise.
For the actions invite and acceptshare a second errorcode is returned if the
result is false. See opac-shareshelf.pl

=cut

sub ShelfPossibleAction {
    my ( $user, $shelfnumber, $action ) = @_;
    $action= 'view' unless $action;
    $user=0 unless $user;

    if($action =~ /^new/) { #no shelfnumber needed
        if($action eq 'new_private') {
            return $user>0;
        }
        elsif($action eq 'new_public') {
            return $user>0 && C4::Context->preference('OpacAllowPublicListCreation');
        }
        return 0;
    }

    return 0 unless defined($shelfnumber);

    if ( $user > 0 and $action eq 'delete_shelf' ) {
        my $borrower = C4::Members::GetMember( borrowernumber => $user );
        require C4::Auth;
        return 1
            if C4::Auth::haspermission( $borrower->{userid}, { lists => 'delete_public_lists' } );
    }

    my $dbh = C4::Context->dbh;
    my $query = q{
        SELECT COALESCE(owner,0) AS owner, category, allow_add, allow_delete_own, allow_delete_other, COALESCE(sh.borrowernumber,0) AS borrowernumber
        FROM virtualshelves vs
        LEFT JOIN virtualshelfshares sh ON sh.shelfnumber=vs.shelfnumber
        AND sh.borrowernumber=?
        WHERE vs.shelfnumber=?
        };
    my $sth = $dbh->prepare($query);
    $sth->execute($user, $shelfnumber);
    my $shelf= $sth->fetchrow_hashref;

    return 0 unless $shelf && ($shelf->{category}==2 || $shelf->{owner}==$user || ($user && $shelf->{borrowernumber}==$user));
    if($action eq 'view') {
        #already handled in the above condition
        return 1;
    }
    elsif($action eq 'add') {
        return 0 if $user<=0; #should be logged in
        return 1 if $shelf->{allow_add}==1 || $shelf->{owner}==$user;
        #owner may always add
    }
    elsif($action eq 'delete') {
        #this answer is just diplomatic: it says that you may be able to delete
        #some items from that shelf
        #it does not answer the question about a specific biblio
        #Koha::Virtualshelf->remove_biblios checks the situation per biblio
        return 1 if $user>0 && ($shelf->{allow_delete_own}==1 || $shelf->{allow_delete_other}==1);
    }
    elsif($action eq 'invite') {
        #for sharing you must be the owner and the list must be private
        if( $shelf->{category}==1 ) {
            return 1 if $shelf->{owner}==$user;
            return (0, 4); # code 4: should be owner
        }
        else {
            return (0, 5); # code 5: should be private list
        }
    }
    elsif($action eq 'acceptshare') {
        #the key for accepting is checked later in Koha::Virtualshelf->share
        #you must not be the owner, list must be private
        if( $shelf->{category}==1 ) {
            return (0, 8) if $shelf->{owner}==$user;
                #code 8: should not be owner
            return 1;
        }
        else {
            return (0, 5); # code 5: should be private list
        }
    }
    elsif($action eq 'manage' or $action eq 'delete_shelf') {
        return 1 if $user && $shelf->{owner}==$user;
    }
    return 0;
}

=head2 ShelvesMax

    $howmany= ShelvesMax($context);

Tells how much shelves are shown in which context.
POPUP refers to addbybiblionumber popup, MGRPAGE is managing page (in opac or
staff), COMBO refers to the Add to-combo of search results. MASTHEAD is the
main Koha toolbar with Lists button.

=cut

sub ShelvesMax {
    my $which= shift;
    return SHELVES_POPUP_MAX if $which eq 'POPUP';
    return SHELVES_MGRPAGE_MAX if $which eq 'MGRPAGE';
    return SHELVES_COMBO_MAX if $which eq 'COMBO';
    return SHELVES_MASTHEAD_MAX if $which eq 'MASTHEAD';
    return SHELVES_MASTHEAD_MAX;
}

=head2 HandleDelBorrower

     HandleDelBorrower($borrower);

When a member is deleted (DelMember in Members.pm), you should call me first.
This routine deletes/moves lists and entries for the deleted member/borrower.
Lists owned by the borrower are deleted, but entries from the borrower to
other lists are kept.

=cut

sub HandleDelBorrower {
    my ($borrower)= @_;
    my $query;
    my $dbh = C4::Context->dbh;

    #Delete all lists and all shares of this borrower
    #Consistent with the approach Koha uses on deleting individual lists
    #Note that entries in virtualshelfcontents added by this borrower to
    #lists of others will be handled by a table constraint: the borrower
    #is set to NULL in those entries.
    $query="DELETE FROM virtualshelves WHERE owner=?";
    $dbh->do($query,undef,($borrower));

    #NOTE:
    #We could handle the above deletes via a constraint too.
    #But a new BZ report 11889 has been opened to discuss another approach.
    #Instead of deleting we could also disown lists (based on a pref).
    #In that way we could save shared and public lists.
    #The current table constraints support that idea now.
    #This pref should then govern the results of other routines/methods such as
    #Koha::Virtualshelf->new->delete too.
}

sub GetShelfCount {
    my ($owner, $category) = @_;
    my @params;
    # Find out how many shelves total meet the submitted criteria...

    my $dbh = C4::Context->dbh;
    my $query = "SELECT count(*) FROM virtualshelves vs ";
    if($category==1) {
        $query.= qq{
            LEFT JOIN virtualshelfshares sh ON sh.shelfnumber=vs.shelfnumber
            AND sh.borrowernumber=?
        WHERE category=1 AND (vs.owner=? OR sh.borrowernumber=?) };
        @params= ($owner, $owner, $owner);
    }
    else {
        $query.='WHERE category=2';
        @params= ();
    }
    my $sth = $dbh->prepare($query);
    $sth->execute(@params);
    my ($total)= $sth->fetchrow;
    return $total;
}

1;

__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=head1 SEE ALSO

C4::Circulation::Circ2(3)

=cut
