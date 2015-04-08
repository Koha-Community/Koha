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
            &GetShelves &GetShelfContents &GetShelf
            &AddToShelf &AddShelf
            &ModShelf
            &ShelfPossibleAction
            &DelFromShelf &DelShelf
            &GetBibliosShelves
            &AddShare &AcceptShare &RemoveShare &IsSharedList
    );
        @EXPORT_OK = qw(
            &GetAllShelves &ShelvesMax
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

=head2 GetShelves

  ($shelflist, $totshelves) = &GetShelves($category, $row_count, $offset, $owner);
  ($shelfnumber, $shelfhash) = each %{$shelflist};

Returns the number of shelves specified by C<$row_count> and C<$offset> as well as the total
number of shelves that meet the C<$owner> and C<$category> criteria.  C<$category>,
C<$row_count>, and C<$offset> are required. C<$owner> must be supplied when C<$category> == 1.
When C<$category> is 2, supply undef as argument for C<$owner>.

This function is used by shelfpage in VirtualShelves/Page.pm when listing all shelves for lists management in opac or staff client. Order is by shelfname.

C<$shelflist>is a reference-to-hash. The keys are the virtualshelves numbers (C<$shelfnumber>, above),
and the values (C<$shelfhash>, above) are themselves references-to-hash, with the following keys:

=over

=item C<$shelfhash-E<gt>{shelfname}>

A string. The name of the shelf.

=item C<$shelfhash-E<gt>{count}>

The number of virtuals on that virtualshelves.

=back

=cut

sub GetShelves {
    my ($category, $row_count, $offset, $owner) = @_;
    my @params;
    my $total = _shelf_count($owner, $category);
    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT vs.shelfnumber, vs.shelfname,vs.owner,
        bo.surname,bo.firstname,vs.category,vs.sortfield,
        count(vc.biblionumber) as count
        FROM virtualshelves vs
        LEFT JOIN borrowers bo ON vs.owner=bo.borrowernumber
        LEFT JOIN virtualshelfcontents vc USING (shelfnumber) };
    if($category==1) {
        $query.= qq{
            LEFT JOIN virtualshelfshares sh ON sh.shelfnumber=vs.shelfnumber
            AND sh.borrowernumber=?
        WHERE category=1 AND (vs.owner=? OR sh.borrowernumber=?) };
        @params= ($owner, $owner, $owner, $offset||0, $row_count);
    }
    else {
        $query.= 'WHERE category=2 ';
        @params= ($offset||0, $row_count);
    }
    $query.= qq{
        GROUP BY vs.shelfnumber
        ORDER BY vs.shelfname
        LIMIT ?, ?};

    my $sth2 = $dbh->prepare($query);
    $sth2->execute(@params);
    my %shelflist;
    while( my ($shelfnumber, $shelfname, $owner, $surname, $firstname, $category, $sortfield, $count)= $sth2->fetchrow) {
        $shelflist{$shelfnumber}->{'shelfname'} = $shelfname;
        $shelflist{$shelfnumber}->{'count'}     = $count;
        $shelflist{$shelfnumber}->{'single'}    = $count==1;
        $shelflist{$shelfnumber}->{'sortfield'} = $sortfield;
        $shelflist{$shelfnumber}->{'category'}  = $category;
        $shelflist{$shelfnumber}->{'owner'}     = $owner;
        $shelflist{$shelfnumber}->{'surname'}   = $surname;
        $shelflist{$shelfnumber}->{'firstname'} = $firstname;
    }
    return ( \%shelflist, $total );
}

=head2 GetAllShelves

    $shelflist = GetAllShelves($category, $owner)

This function returns a reference to an array of hashrefs containing all shelves
sorted by the shelf name.

This function is intended to return a dataset reflecting all the shelves for
the submitted parameters.

=cut

sub GetAllShelves {
    my ($category,$owner,$adding_allowed) = @_;
    my @params;
    my $dbh = C4::Context->dbh;
    my $query = 'SELECT vs.* FROM virtualshelves vs ';
    if($category==1) {
        $query.= qq{
            LEFT JOIN virtualshelfshares sh ON sh.shelfnumber=vs.shelfnumber
            AND sh.borrowernumber=?
        WHERE category=1 AND (vs.owner=? OR sh.borrowernumber=?) };
        @params = ($owner, $owner, $owner);
    }
    else {
    $query.='WHERE category=2 ';
        @params = ();
    }
    $query.='AND (allow_add=1 OR owner=?) ' if $adding_allowed;
    push @params, $owner if $adding_allowed;
    $query.= 'ORDER BY shelfname ASC';
    my $sth = $dbh->prepare( $query );
    $sth->execute(@params);
    return $sth->fetchall_arrayref({});
}

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

=head2 GetShelf

  (shelfnumber,shelfname,owner,category,sortfield,allow_add,allow_delete_own,allow_delete_other) = &GetShelf($shelfnumber);

Returns the above-mentioned fields for passed virtual shelf number.

=cut

sub GetShelf {
    my ($shelfnumber) = @_;
    my $dbh = C4::Context->dbh;
    my $query = qq(
        SELECT shelfnumber, shelfname, owner, category, sortfield,
            allow_add, allow_delete_own, allow_delete_other
        FROM   virtualshelves
        WHERE  shelfnumber=?
    );
    my $sth = $dbh->prepare($query);
    $sth->execute($shelfnumber);
    return $sth->fetchrow;
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

=head2 AddShelf

  $shelfnumber = &AddShelf($hashref, $owner);

Creates a new virtual shelf. Params passed in a hash like ModShelf.

Returns a code to know what's happen.
    * -1 : if this virtualshelves already exists.
    * $shelfnumber : if success.

=cut

sub AddShelf {
    my ($hashref, $owner)= @_;
    my $dbh = C4::Context->dbh;

    #initialize missing hash values to silence warnings
    foreach('shelfname','category', 'sortfield', 'allow_add', 'allow_delete_own', 'allow_delete_other' ) {
        $hashref->{$_}= undef unless exists $hashref->{$_};
    }

    return -1 unless _CheckShelfName($hashref->{shelfname}, $hashref->{category}, $owner, 0);

    my $query = qq(INSERT INTO virtualshelves
        (shelfname,owner,category,sortfield,allow_add,allow_delete_own,allow_delete_other)
        VALUES (?,?,?,?,?,?,?));

    my $sth = $dbh->prepare($query);
    $sth->execute(
        $hashref->{shelfname},
        $owner,
        $hashref->{category},
        $hashref->{sortfield},
        $hashref->{allow_add}//0,
        $hashref->{allow_delete_own}//1,
        $hashref->{allow_delete_other}//0 );
    return if $sth->err;
    my $shelfnumber = $dbh->{'mysql_insertid'};
    return $shelfnumber;
}

=head2 AddToShelf

  &AddToShelf($biblionumber, $shelfnumber, $borrower);

Adds bib number C<$biblionumber> to virtual virtualshelves number
C<$shelfnumber>, unless that bib is already on that shelf.

=cut

sub AddToShelf {
    my ($biblionumber, $shelfnumber, $borrowernumber) = @_;
    return unless $biblionumber;
    my $dbh = C4::Context->dbh;
    my $query = qq(
        SELECT *
        FROM   virtualshelfcontents
        WHERE  shelfnumber=? AND biblionumber=?
    );
    my $sth = $dbh->prepare($query);

    $sth->execute( $shelfnumber, $biblionumber );
    ($sth->rows) and return; # already on shelf
    $query = qq(
        INSERT INTO virtualshelfcontents
            (shelfnumber, biblionumber, flags, borrowernumber)
        VALUES (?, ?, 0, ?));
    $sth = $dbh->prepare($query);
    $sth->execute( $shelfnumber, $biblionumber, $borrowernumber);
    $query = qq(UPDATE virtualshelves
                SET lastmodified = CURRENT_TIMESTAMP
                WHERE shelfnumber = ?);
    $sth = $dbh->prepare($query);
    $sth->execute( $shelfnumber );
}

=head2 ModShelf

my $result= ModShelf($shelfnumber, $hashref)

Where $hashref->{column} = param

Modify the value into virtualshelves table with values given 
from hashref, which each key of the hashref should be
the name of a column of virtualshelves.
Fields like shelfnumber or owner cannot be changed.

Returns 1 if the action seemed to be successful.

=cut

sub ModShelf {
    my ($shelfnumber,$hashref) = @_;
    my $dbh = C4::Context->dbh;

    my $query= "SELECT * FROM virtualshelves WHERE shelfnumber=?";
    my $sth = $dbh->prepare($query);
    $sth->execute($shelfnumber);
    my $oldrecord= $sth->fetchrow_hashref;
    return 0 unless $oldrecord; #not found?

    #initialize missing hash values to silence warnings
    foreach('shelfname','category', 'sortfield', 'allow_add', 'allow_delete_own', 'allow_delete_other' ) {
        $hashref->{$_}= undef unless exists $hashref->{$_};
    }

    #if name or category changes, the name should be tested
    if($hashref->{shelfname} || $hashref->{category}) {
        unless(_CheckShelfName(
            $hashref->{shelfname}//$oldrecord->{shelfname},
            $hashref->{category}//$oldrecord->{category},
            $oldrecord->{owner},
            $shelfnumber )) {
                return 0; #name check failed
        }
    }

    #only the following fields from the hash may be changed
    $query= "UPDATE virtualshelves SET shelfname=?, category=?, sortfield=?, allow_add=?, allow_delete_own=?, allow_delete_other=? WHERE shelfnumber=?";
    $sth = $dbh->prepare($query);
    $sth->execute(
        $hashref->{shelfname}//$oldrecord->{shelfname},
        $hashref->{category}//$oldrecord->{category},
        $hashref->{sortfield}//$oldrecord->{sortfield},
        $hashref->{allow_add}//$oldrecord->{allow_add},
        $hashref->{allow_delete_own}//$oldrecord->{allow_delete_own},
        $hashref->{allow_delete_other}//$oldrecord->{allow_delete_other},
        $shelfnumber );
    return $@? 0: 1;
}

=head2 ShelfPossibleAction

ShelfPossibleAction($loggedinuser, $shelfnumber, $action);

C<$loggedinuser,$shelfnumber,$action>

$action can be "view", "add", "delete", "manage", "new_public", "new_private".
New additional actions are: invite, acceptshare.
Note that add/delete here refers to adding/deleting entries from the list. Deleting the list itself falls under manage.
new_public and new_private refers to creating a new public or private list.
The distinction between deleting your own entries from the list or entries from
others is made in DelFromShelf.

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

    my $dbh = C4::Context->dbh;
    my $query = qq/
        SELECT COALESCE(owner,0) AS owner, category, allow_add, allow_delete_own, allow_delete_other, COALESCE(sh.borrowernumber,0) AS borrowernumber
        FROM virtualshelves vs
        LEFT JOIN virtualshelfshares sh ON sh.shelfnumber=vs.shelfnumber
        AND sh.borrowernumber=?
        WHERE vs.shelfnumber=?
    /;
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
        #DelFromShelf checks the situation per biblio
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
        #the key for accepting is checked later in AcceptShare
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
    elsif($action eq 'manage') {
        return 1 if $user && $shelf->{owner}==$user;
    }
    return 0;
}

=head2 DelFromShelf

    $result= &DelFromShelf( $bibref, $shelfnumber, $user);

Removes biblionumbers in passed arrayref from shelf C<$shelfnumber>.
If the bib wasn't on that virtualshelves to begin with, nothing happens.

Returns 0 if no items have been deleted.

=cut

sub DelFromShelf {
    my ($bibref, $shelfnumber, $user) = @_;
    my $dbh = C4::Context->dbh;
    my $query = qq(SELECT allow_delete_own, allow_delete_other FROM virtualshelves WHERE shelfnumber=?);
    my $sth= $dbh->prepare($query);
    $sth->execute($shelfnumber);
    my ($del_own, $del_oth)= $sth->fetchrow;
    my $r; my $t=0;

    if($del_own) {
        $query = qq(DELETE FROM virtualshelfcontents
            WHERE shelfnumber=? AND biblionumber=? AND borrowernumber=?);
        $sth= $dbh->prepare($query);
        foreach my $biblionumber (@$bibref) {
            $sth->execute($shelfnumber, $biblionumber, $user);
            $r= $sth->rows; #Expect -1, 0 or 1 (-1 means Don't know; count as 1)
            $t+= ($r==-1)? 1: $r;
        }
    }
    if($del_oth) {
        #includes a check if borrowernumber is null (deleted patron)
        $query = qq/DELETE FROM virtualshelfcontents
            WHERE shelfnumber=? AND biblionumber=? AND
            (borrowernumber IS NULL OR borrowernumber<>?)/;
        $sth= $dbh->prepare($query);
        foreach my $biblionumber (@$bibref) {
            $sth->execute($shelfnumber, $biblionumber, $user);
            $r= $sth->rows;
            $t+= ($r==-1)? 1: $r;
        }
    }
    return $t;
}

=head2 DelShelf

  $Number = DelShelf($shelfnumber);

This function deletes the shelf number, and all of it's content.
Authorization to do so MUST have been checked before calling, while using
ShelfPossibleAction with manage parameter.

=cut

sub DelShelf {
    my ($shelfnumber)= @_;
    return unless $shelfnumber && $shelfnumber =~ /^\d+$/;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("DELETE FROM virtualshelves WHERE shelfnumber=?");
    return $sth->execute($shelfnumber);
}

=head2 GetBibliosShelves

This finds all the public lists that this bib record is in.

=cut

sub GetBibliosShelves {
    my ( $biblionumber )  = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare('
        SELECT vs.shelfname, vs.shelfnumber 
        FROM virtualshelves vs 
        JOIN virtualshelfcontents vc ON (vs.shelfnumber= vc.shelfnumber) 
        WHERE vs.category=2
        AND vc.biblionumber= ?
    ');
    $sth->execute( $biblionumber );
    return $sth->fetchall_arrayref({});
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
    #This pref should then govern the results of other routines such as
    #DelShelf too.
}

=head2 AddShare

     AddShare($shelfnumber, $key);

Adds a share request to the virtualshelves table.
Authorization must have been checked, and a key must be supplied. See script
opac-shareshelf.pl for an example.
This request is not yet confirmed. So it has no borrowernumber, it does have an
expiry date.

=cut

sub AddShare {
    my ($shelfnumber, $key)= @_;
    return if !$shelfnumber || !$key;

    my $dbh = C4::Context->dbh;
    my $sql = "INSERT INTO virtualshelfshares (shelfnumber, invitekey, sharedate) VALUES (?, ?, NOW())";
    $dbh->do($sql, undef, ($shelfnumber, $key));
    return !$dbh->err;
}

=head2 AcceptShare

     my $result= AcceptShare($shelfnumber, $key, $borrowernumber);

Checks acceptation of a share request.
Key must be found for this shelf. Invitation must not have expired.
Returns true when accepted, false otherwise.

=cut

sub AcceptShare {
    my ($shelfnumber, $key, $borrowernumber)= @_;
    return if !$shelfnumber || !$key || !$borrowernumber;

    my $sql;
    my $dbh = C4::Context->dbh;
    $sql="
UPDATE virtualshelfshares
SET invitekey=NULL, sharedate=NOW(), borrowernumber=?
WHERE shelfnumber=? AND invitekey=? AND (sharedate + INTERVAL ? DAY) >NOW()
    ";
    my $i= $dbh->do($sql, undef, ($borrowernumber, $shelfnumber, $key,  SHARE_INVITATION_EXPIRY_DAYS));
    return if !defined($i) || !$i || $i eq '0E0'; #not found
    return 1;
}

=head2 IsSharedList

     my $bool= IsSharedList( $shelfnumber );

IsSharedList checks if a (private) list has shares.
Note that such a check would not be useful for public lists. A public list has
no shares, but is visible for anyone by nature..
Used to determine the list type in the display of Your lists (all private).
Returns boolean value.

=cut

sub IsSharedList {
    my ($shelfnumber) = @_;
    my $dbh = C4::Context->dbh;
    my $sql="SELECT id FROM virtualshelfshares WHERE shelfnumber=? AND borrowernumber IS NOT NULL";
    my $sth = $dbh->prepare($sql);
    $sth->execute($shelfnumber);
    my ($rv)= $sth->fetchrow_array;
    return defined($rv);
}

=head2 RemoveShare

     RemoveShare( $user, $shelfnumber );

RemoveShare removes a share for specific shelf and borrower.
Returns true if a record could be deleted.

=cut

sub RemoveShare {
    my ($user, $shelfnumber)= @_;
    my $dbh = C4::Context->dbh;
    my $sql="
DELETE FROM virtualshelfshares
WHERE borrowernumber=? AND shelfnumber=?
    ";
    my $n= $dbh->do($sql,undef,($user, $shelfnumber));
    return if !defined($n) || !$n || $n eq '0E0'; #nothing removed
    return 1;
}

# internal subs

sub _shelf_count {
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

sub _CheckShelfName {
    my ($name, $cat, $owner, $number)= @_;

    my $dbh = C4::Context->dbh;
    my @pars;
    my $query = qq(
        SELECT DISTINCT shelfnumber
        FROM   virtualshelves
        LEFT JOIN virtualshelfshares sh USING (shelfnumber)
        WHERE  shelfname=? AND shelfnumber<>?);
    if($cat==1 && defined($owner)) {
        $query.= ' AND (sh.borrowernumber=? OR owner=?) AND category=1';
        @pars=($name, $number, $owner, $owner);
    }
    elsif($cat==1 && !defined($owner)) { #owner is null (exceptional)
        $query.= ' AND owner IS NULL AND category=1';
        @pars=($name, $number);
    }
    else { #public list
        $query.= ' AND category=2';
        @pars=($name, $number);
    }
    my $sth = $dbh->prepare($query);
    $sth->execute(@pars);
    return $sth->rows>0? 0: 1;
}

1;

__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=head1 SEE ALSO

C4::Circulation::Circ2(3)

=cut
