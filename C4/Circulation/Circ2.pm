package C4::Circulation::Circ2;

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

# $Id$

use strict;
require Exporter;
use C4::Context;
use C4::Stats;
use C4::Reserves2;
use C4::Koha;
use C4::Biblio;
use C4::Accounts;
use Date::Calc qw(
  Today
  Today_and_Now
  Add_Delta_YM
  Add_Delta_DHMS
  Date_to_Days
);
use POSIX qw(strftime);
use C4::Branch; # GetBranches
use C4::Log; # logaction

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = do { my @v = '$Revision$' =~ /\d+/g; shift(@v).".".join( "_", map { sprintf "%03d", $_ } @v ); };

=head1 NAME

C4::Circulation::Circ2 - Koha circulation module

=head1 SYNOPSIS

use C4::Circulation::Circ2;

=head1 DESCRIPTION

The functions in this module deal with circulation, issues, and
returns, as well as general information about the library.
Also deals with stocktaking.

=head1 FUNCTIONS

=cut

@ISA    = qw(Exporter);
@EXPORT = qw(
  &getpatroninformation
  &currentissues
  &getissues
  &getiteminformation
  &renewstatus
  &renewbook
  &canbookbeissued
  &issuebook
  &returnbook
  &find_reserves
  &transferbook
  &decode
  &calc_charges
  &GetItemsForInventory
  &itemseen
  &fixdate
  &get_current_return_date_of
  &get_transfert_infos
  &checktransferts
  &GetReservesForBranch
  &GetReservesToBranch
  &GetTransfersFromBib
  &getBranchIp
  &dotransfer
  &GetOverduesForBranch
  &AddNotifyLine
  &RemoveNotifyLine
  &GetIssuesFromBiblio
  &AnonymiseIssueHistory
  &GetLostItems
  &itemissues
  &updateWrongTransfer
);

=head2 itemseen

&itemseen($itemnum)
Mark item as seen. Is called when an item is issued, returned or manually marked during inventory/stocktaking
C<$itemnum> is the item number

=cut

sub itemseen {
    my ($itemnum) = @_;
    my $dbh       = C4::Context->dbh;
    my $sth       =
      $dbh->prepare(
          "update items set itemlost=0, datelastseen  = now() where items.itemnumber = ?"
      );
    $sth->execute($itemnum);
    return;
}

=head2 itemborrowed

&itemseen($itemnum)
Mark item as borrowed. Is called when an item is issued.
C<$itemnum> is the item number

=cut

sub itemborrowed {
    my ($itemnum) = @_;
    my $dbh       = C4::Context->dbh;
    my $sth       =
      $dbh->prepare(
          "update items set itemlost=0, datelastborrowed  = now() where items.itemnumber = ?"
      );
    $sth->execute($itemnum);
    return;
}

=head2 GetItemsForInventory

$itemlist = GetItemsForInventory($minlocation,$maxlocation,$datelastseen,$offset,$size)

Retrieve a list of title/authors/barcode/callnumber, for biblio inventory.

The sub returns a list of hashes, containing itemnumber, author, title, barcode & item callnumber.
It is ordered by callnumber,title.

The minlocation & maxlocation parameters are used to specify a range of item callnumbers
the datelastseen can be used to specify that you want to see items not seen since a past date only.
offset & size can be used to retrieve only a part of the whole listing (defaut behaviour)

=cut

sub GetItemsForInventory {
    my ( $minlocation, $maxlocation, $datelastseen, $branch, $offset, $size ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth;
    if ($datelastseen) {
        my $query =
                "SELECT itemnumber,barcode,itemcallnumber,title,author,datelastseen
                 FROM items
                   LEFT JOIN biblio ON items.biblionumber=biblio.biblionumber 
                 WHERE itemcallnumber>= ?
                   AND itemcallnumber <=?
                   AND (datelastseen< ? OR datelastseen IS NULL)";
        $query.= " AND items.homebranch=".$dbh->quote($branch) if $branch;
        $query .= " ORDER BY itemcallnumber,title";
        $sth = $dbh->prepare($query);
        $sth->execute( $minlocation, $maxlocation, $datelastseen );
    }
    else {
        my $query ="
                SELECT itemnumber,barcode,itemcallnumber,title,author,datelastseen
                FROM items 
                  LEFT JOIN biblio ON items.biblionumber=biblio.biblionumber 
                WHERE itemcallnumber>= ?
                  AND itemcallnumber <=?";
        $query.= " AND items.homebranch=".$dbh->quote($branch) if $branch;
        $query .= " ORDER BY itemcallnumber,title";
        $sth = $dbh->prepare($query);
        $sth->execute( $minlocation, $maxlocation );
    }
    my @results;
    while ( my $row = $sth->fetchrow_hashref ) {
        $offset-- if ($offset);
        if ( ( !$offset ) && $size ) {
            push @results, $row;
            $size--;
        }
    }
    return \@results;
}

=head2 getpatroninformation

($borrower, $flags) = &getpatroninformation($env, $borrowernumber, $cardnumber);

Looks up a patron and returns information about him or her. If
C<$borrowernumber> is true (nonzero), C<&getpatroninformation> looks
up the borrower by number; otherwise, it looks up the borrower by card
number.

C<$env> is effectively ignored, but should be a reference-to-hash.

C<$borrower> is a reference-to-hash whose keys are the fields of the
borrowers table in the Koha database. In addition,
C<$borrower-E<gt>{flags}> is a hash giving more detailed information
about the patron. Its keys act as flags :

    if $borrower->{flags}->{LOST} {
        # Patron's card was reported lost
    }

Each flag has a C<message> key, giving a human-readable explanation of
the flag. If the state of a flag means that the patron should not be
allowed to borrow any more books, then it will have a C<noissues> key
with a true value.

The possible flags are:

=head3 CHARGES

=over 4

=item Shows the patron's credit or debt, if any.

=back

=head3 GNA

=over 4

=item (Gone, no address.) Set if the patron has left without giving a
forwarding address.

=back

=head3 LOST

=over 4

=item Set if the patron's card has been reported as lost.

=back

=head3 DBARRED

=over 4

=item Set if the patron has been debarred.

=back

=head3 NOTES

=over 4

=item Any additional notes about the patron.

=back

=head3 ODUES

=over 4

=item Set if the patron has overdue items. This flag has several keys:

C<$flags-E<gt>{ODUES}{itemlist}> is a reference-to-array listing the
overdue items. Its elements are references-to-hash, each describing an
overdue item. The keys are selected fields from the issues, biblio,
biblioitems, and items tables of the Koha database.

C<$flags-E<gt>{ODUES}{itemlist}> is a string giving a text listing of
the overdue items, one per line.

=back

=head3 WAITING

=over 4

=item Set if any items that the patron has reserved are available.

C<$flags-E<gt>{WAITING}{itemlist}> is a reference-to-array listing the
available items. Each element is a reference-to-hash whose keys are
fields from the reserves table of the Koha database.

=back

=cut

sub getpatroninformation {
    my ( $env, $borrowernumber, $cardnumber ) = @_;
    my $dbh = C4::Context->dbh;
    my $query;
    my $sth;
    if ($borrowernumber) {
        $sth = $dbh->prepare("select * from borrowers where borrowernumber=?");
        $sth->execute($borrowernumber);
    }
    elsif ($cardnumber) {
        $sth = $dbh->prepare("select * from borrowers where cardnumber=?");
        $sth->execute($cardnumber);
    }
    else {
        return undef;
    }
    my $borrower = $sth->fetchrow_hashref;
    my $amount = checkaccount( $env, $borrowernumber, $dbh );
    $borrower->{'amountoutstanding'} = $amount;
    my $flags = patronflags( $env, $borrower, $dbh );
    my $accessflagshash;

    $sth = $dbh->prepare("select bit,flag from userflags");
    $sth->execute;
    while ( my ( $bit, $flag ) = $sth->fetchrow ) {
        if ( $borrower->{'flags'} && $borrower->{'flags'} & 2**$bit ) {
            $accessflagshash->{$flag} = 1;
        }
    }
    $sth->finish;
    $borrower->{'flags'}     = $flags;
    $borrower->{'authflags'} = $accessflagshash;

    # find out how long the membership lasts
    $sth =
      $dbh->prepare(
        "select enrolmentperiod from categories where categorycode = ?");
    $sth->execute( $borrower->{'categorycode'} );
    my $enrolment = $sth->fetchrow;
    $borrower->{'enrolmentperiod'} = $enrolment;
    return ($borrower);    #, $flags, $accessflagshash);
}

=head2 decode

=head3 $str = &decode($chunk);

=over 4

=item Decodes a segment of a string emitted by a CueCat barcode scanner and
returns it.

=back

=cut

# FIXME - At least, I'm pretty sure this is for decoding CueCat stuff.
sub decode {
    my ($encoded) = @_;
    my $seq =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+-';
    my @s = map { index( $seq, $_ ); } split( //, $encoded );
    my $l = ( $#s + 1 ) % 4;
    if ($l) {
        if ( $l == 1 ) {
            warn "Error!";
            return;
        }
        $l = 4 - $l;
        $#s += $l;
    }
    my $r = '';
    while ( $#s >= 0 ) {
        my $n = ( ( $s[0] << 6 | $s[1] ) << 6 | $s[2] ) << 6 | $s[3];
        $r .=
            chr( ( $n >> 16 ) ^ 67 )
         .chr( ( $n >> 8 & 255 ) ^ 67 )
         .chr( ( $n & 255 ) ^ 67 );
        @s = @s[ 4 .. $#s ];
    }
    $r = substr( $r, 0, length($r) - $l );
    return $r;
}

=head2 getiteminformation

$item = &getiteminformation($itemnumber, $barcode);

Looks up information about an item, given either its item number or
its barcode. If C<$itemnumber> is a nonzero value, it is used;
otherwise, C<$barcode> is used.

C<$item> is a reference-to-hash whose keys are fields from the biblio,
items, and biblioitems tables of the Koha database. It may also
contain the following keys:

=head3 date_due

=over 4

=item The due date on this item, if it has been borrowed and not returned
yet. The date is in YYYY-MM-DD format.

=back

=head3 notforloan

=over 4

=item True if the item may not be borrowed.

=back

=cut

sub getiteminformation {

 # returns a hash of item information given either the itemnumber or the barcode
    my ( $itemnumber, $barcode ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth;
    if ($itemnumber) {
        $sth =
          $dbh->prepare(
        "select *
        from  biblio,items,biblioitems
        where items.itemnumber=? and biblio.biblionumber=items.biblionumber and biblioitems.biblioitemnumber = items.biblioitemnumber"
          );
        $sth->execute($itemnumber);
    }
    elsif ($barcode) {
        $sth =
          $dbh->prepare(
        "select * from biblio,items,biblioitems where items.barcode=? and biblio.biblionumber=items.biblionumber and biblioitems.biblioitemnumber = items.biblioitemnumber"
          );
        $sth->execute($barcode);
    }
    else {
        return undef;
    }
    my $iteminformation = $sth->fetchrow_hashref;
    $sth->finish;
    if ($iteminformation) {
        $sth =
          $dbh->prepare("select date_due from issues where itemnumber=? and isnull(returndate)");
        $sth->execute( $iteminformation->{'itemnumber'} );
        my ($date_due) = $sth->fetchrow;
        $iteminformation->{'date_due'} = $date_due;
        $sth->finish;
        ( $iteminformation->{'dewey'} == 0 )
          && ( $iteminformation->{'dewey'} = '' );
        $sth = $dbh->prepare("select * from itemtypes where itemtype=?");
        $sth->execute( $iteminformation->{'itemtype'} );
        my $itemtype = $sth->fetchrow_hashref;

        # if specific item notforloan, don't use itemtype notforloan field.
        # otherwise, use itemtype notforloan value to see if item can be issued.
        $iteminformation->{'notforloan'} = $itemtype->{'notforloan'}
          unless $iteminformation->{'notforloan'};
        $sth->finish;
    }
    return ($iteminformation);
}

=head2 transferbook

($dotransfer, $messages, $iteminformation) = &transferbook($newbranch, $barcode, $ignore_reserves);

Transfers an item to a new branch. If the item is currently on loan, it is automatically returned before the actual transfer.

C<$newbranch> is the code for the branch to which the item should be transferred.

C<$barcode> is the barcode of the item to be transferred.

If C<$ignore_reserves> is true, C<&transferbook> ignores reserves.
Otherwise, if an item is reserved, the transfer fails.

Returns three values:

=head3 $dotransfer 

is true if the transfer was successful.

=head3 $messages

is a reference-to-hash which may have any of the following keys:

=over 4

=item C<BadBarcode>

There is no item in the catalog with the given barcode. The value is C<$barcode>.

=item C<IsPermanent>

The item's home branch is permanent. This doesn't prevent the item from being transferred, though. The value is the code of the item's home branch.

=item C<DestinationEqualsHolding>

The item is already at the branch to which it is being transferred. The transfer is nonetheless considered to have failed. The value should be ignored.

=item C<WasReturned>

The item was on loan, and C<&transferbook> automatically returned it before transferring it. The value is the borrower number of the patron who had the item.

=item C<ResFound>

The item was reserved. The value is a reference-to-hash whose keys are fields from the reserves table of the Koha database, and C<biblioitemnumber>. It also has the key C<ResFound>, whose value is either C<Waiting> or C<Reserved>.

=item C<WasTransferred>

The item was eligible to be transferred. Barring problems communicating with the database, the transfer should indeed have succeeded. The value should be ignored.

=back

=cut

#'
# FIXME - This function tries to do too much, and its API is clumsy.
# If it didn't also return books, it could be used to change the home
# branch of a book while the book is on loan.
#
# Is there any point in returning the item information? The caller can
# look that up elsewhere if ve cares.
#
# This leaves the ($dotransfer, $messages) tuple. This seems clumsy.
# If the transfer succeeds, that's all the caller should need to know.
# Thus, this function could simply return 1 or 0 to indicate success
# or failure, and set $C4::Circulation::Circ2::errmsg in case of
# failure. Or this function could return undef if successful, and an
# error message in case of failure (this would feel more like C than
# Perl, though).
sub transferbook {
    my ( $tbr, $barcode, $ignoreRs ) = @_;
    my $messages;
    my %env;
    my $dotransfer      = 1;
    my $branches        = GetBranches();
    my $iteminformation = getiteminformation( 0, $barcode );

    # bad barcode..
    if ( not $iteminformation ) {
        $messages->{'BadBarcode'} = $barcode;
        $dotransfer = 0;
    }

    # get branches of book...
    my $hbr = $iteminformation->{'homebranch'};
    my $fbr = $iteminformation->{'holdingbranch'};

    # if is permanent...
    if ( $hbr && $branches->{$hbr}->{'PE'} ) {
        $messages->{'IsPermanent'} = $hbr;
    }

    # can't transfer book if is already there....
    # FIXME - Why not? Shouldn't it trivially succeed?
    if ( $fbr eq $tbr ) {
        $messages->{'DestinationEqualsHolding'} = 1;
        $dotransfer = 0;
    }

    # check if it is still issued to someone, return it...
    my ($currentborrower) = currentborrower( $iteminformation->{'itemnumber'} );
    if ($currentborrower) {
        returnbook( $barcode, $fbr );
        $messages->{'WasReturned'} = $currentborrower;
    }

    # find reserves.....
    # FIXME - Don't call &CheckReserves unless $ignoreRs is true.
    # That'll save a database query.
    my ( $resfound, $resrec ) =
      CheckReserves( $iteminformation->{'itemnumber'} );
    if ( $resfound and not $ignoreRs ) {
        $resrec->{'ResFound'} = $resfound;

        #         $messages->{'ResFound'} = $resrec;
        $dotransfer = 1;
    }

    #actually do the transfer....
    if ($dotransfer) {
        dotransfer( $iteminformation->{'itemnumber'}, $fbr, $tbr );

        # don't need to update MARC anymore, we do it in batch now
        $messages->{'WasTransfered'} = 1;
    }
    return ( $dotransfer, $messages, $iteminformation );
}

# Not exported
# FIXME - This is only used in &transferbook. Why bother making it a
# separate function?
sub dotransfer {
    my ( $itm, $fbr, $tbr ) = @_;
    
    my $dbh = C4::Context->dbh;
    $itm = $dbh->quote($itm);
    $fbr = $dbh->quote($fbr);
    $tbr = $dbh->quote($tbr);
    
    #new entry in branchtransfers....
    $dbh->do(
"INSERT INTO branchtransfers (itemnumber, frombranch, datesent, tobranch)
                    VALUES ($itm, $fbr, now(), $tbr)"
    );

    #update holdingbranch in items .....
      $dbh->do(
          "UPDATE items set holdingbranch = $tbr WHERE items.itemnumber = $itm");
    &itemseen($itm);
    &domarctransfer( $dbh, $itm );
    return;
}

##New sub to dotransfer in marc tables as well. Not exported -TG 10/04/2006
sub domarctransfer {
    my ( $dbh, $itemnumber ) = @_;
    $itemnumber =~ s /\'//g;    ##itemnumber seems to come with quotes-TG
    my $sth =
      $dbh->prepare(
        "select biblionumber,holdingbranch from items where itemnumber=$itemnumber"
      );
    $sth->execute();
    while ( my ( $biblionumber, $holdingbranch ) = $sth->fetchrow ) {
        &ModItemInMarconefield( $biblionumber, $itemnumber,
            'items.holdingbranch', $holdingbranch );
    }
    return;
}

=head2 canbookbeissued

Check if a book can be issued.

my ($issuingimpossible,$needsconfirmation) = canbookbeissued($env,$borrower,$barcode,$year,$month,$day);

=over 4

=item C<$env> Environment variable. Should be empty usually, but used by other subs. Next code cleaning could drop it.

=item C<$borrower> hash with borrower informations (from getpatroninformation)

=item C<$barcode> is the bar code of the book being issued.

=item C<$year> C<$month> C<$day> contains the date of the return (in case it's forced by "stickyduedate".

=back

Returns :

=over 4

=item C<$issuingimpossible> a reference to a hash. It contains reasons why issuing is impossible.
Possible values are :

=back

=head3 INVALID_DATE 

sticky due date is invalid

=head3 GNA

borrower gone with no address

=head3 CARD_LOST

borrower declared it's card lost

=head3 DEBARRED

borrower debarred

=head3 UNKNOWN_BARCODE

barcode unknown

=head3 NOT_FOR_LOAN

item is not for loan

=head3 WTHDRAWN

item withdrawn.

=head3 RESTRICTED

item is restricted (set by ??)

C<$issuingimpossible> a reference to a hash. It contains reasons why issuing is impossible.
Possible values are :

=head3 DEBT

borrower has debts.

=head3 RENEW_ISSUE

renewing, not issuing

=head3 ISSUED_TO_ANOTHER

issued to someone else.

=head3 RESERVED

reserved for someone else.

=head3 INVALID_DATE

sticky due date is invalid

=head3 TOO_MANY

if the borrower borrows to much things

=cut

# check if a book can be issued.
# returns an array with errors if any

sub TooMany ($$) {
    my $borrower        = shift;
    my $iteminformation = shift;
    my $cat_borrower    = $borrower->{'categorycode'};
    my $branch_borrower = $borrower->{'branchcode'};
    my $dbh             = C4::Context->dbh;

    my $sth =
      $dbh->prepare('select itemtype from biblioitems where biblionumber = ?');
    $sth->execute( $iteminformation->{'biblionumber'} );
    my $type = $sth->fetchrow;
    $sth =
      $dbh->prepare(
'select * from issuingrules where categorycode = ? and itemtype = ? and branchcode = ?'
      );

#     my $sth2 = $dbh->prepare("select COUNT(*) from issues i, biblioitems s where i.borrowernumber = ? and i.returndate is null and i.itemnumber = s.biblioitemnumber and s.itemtype like ?");
    my $sth2 =
      $dbh->prepare(
"select COUNT(*) from issues i, biblioitems s1, items s2 where i.borrowernumber = ? and i.returndate is null and i.itemnumber = s2.itemnumber and s1.itemtype like ? and s1.biblioitemnumber = s2.biblioitemnumber"
      );
    my $sth3 =
      $dbh->prepare(
'select COUNT(*) from issues where borrowernumber = ? and returndate is null'
      );
    my $alreadyissued;

    # check the 3 parameters
    $sth->execute( $cat_borrower, $type, $branch_borrower );
    my $result = $sth->fetchrow_hashref;

    #    warn "==>".$result->{maxissueqty};

# Currently, using defined($result) ie on an entire hash reports whether memory
# for that aggregate has ever been allocated. As $result is used all over the place
# it would rarely return as undefined.
    if ( defined( $result->{maxissueqty} ) ) {
        $sth2->execute( $borrower->{'borrowernumber'}, "%$type%" );
        my $alreadyissued = $sth2->fetchrow;
        if ( $result->{'maxissueqty'} <= $alreadyissued ) {
            return ( "a $alreadyissued / ".( $result->{maxissueqty} + 0 ) );
        }
        else {
            return;
        }
    }

    # check for branch=*
    $sth->execute( $cat_borrower, $type, "" );
    $result = $sth->fetchrow_hashref;
    if ( defined( $result->{maxissueqty} ) ) {
        $sth2->execute( $borrower->{'borrowernumber'}, "%$type%" );
        my $alreadyissued = $sth2->fetchrow;
        if ( $result->{'maxissueqty'} <= $alreadyissued ) {
            return ( "b $alreadyissued / ".( $result->{maxissueqty} + 0 ) );
        }
        else {
            return;
        }
    }

    # check for itemtype=*
    $sth->execute( $cat_borrower, "*", $branch_borrower );
    $result = $sth->fetchrow_hashref;
    if ( defined( $result->{maxissueqty} ) ) {
        $sth3->execute( $borrower->{'borrowernumber'} );
        my ($alreadyissued) = $sth3->fetchrow;
        if ( $result->{'maxissueqty'} <= $alreadyissued ) {

#        warn "HERE : $alreadyissued / ($result->{maxissueqty} for $borrower->{'borrowernumber'}";
            return ( "c $alreadyissued / " . ( $result->{maxissueqty} + 0 ) );
        }
        else {
            return;
        }
    }

    # check for borrowertype=*
    $sth->execute( "*", $type, $branch_borrower );
    $result = $sth->fetchrow_hashref;
    if ( defined( $result->{maxissueqty} ) ) {
        $sth2->execute( $borrower->{'borrowernumber'}, "%$type%" );
        my $alreadyissued = $sth2->fetchrow;
        if ( $result->{'maxissueqty'} <= $alreadyissued ) {
            return ( "d $alreadyissued / " . ( $result->{maxissueqty} + 0 ) );
        }
        else {
            return;
        }
    }

    $sth->execute( "*", "*", $branch_borrower );
    $result = $sth->fetchrow_hashref;
    if ( defined( $result->{maxissueqty} ) ) {
        $sth3->execute( $borrower->{'borrowernumber'} );
        my $alreadyissued = $sth3->fetchrow;
        if ( $result->{'maxissueqty'} <= $alreadyissued ) {
            return ( "e $alreadyissued / " . ( $result->{maxissueqty} + 0 ) );
        }
        else {
            return;
        }
    }

    $sth->execute( "*", $type, "" );
    $result = $sth->fetchrow_hashref;
    if ( defined( $result->{maxissueqty} ) && $result->{maxissueqty} >= 0 ) {
        $sth2->execute( $borrower->{'borrowernumber'}, "%$type%" );
        my $alreadyissued = $sth2->fetchrow;
        if ( $result->{'maxissueqty'} <= $alreadyissued ) {
            return ( "f $alreadyissued / " . ( $result->{maxissueqty} + 0 ) );
        }
        else {
            return;
        }
    }

    $sth->execute( $cat_borrower, "*", "" );
    $result = $sth->fetchrow_hashref;
    if ( defined( $result->{maxissueqty} ) ) {
        $sth2->execute( $borrower->{'borrowernumber'}, "%$type%" );
        my $alreadyissued = $sth2->fetchrow;
        if ( $result->{'maxissueqty'} <= $alreadyissued ) {
            return ( "g $alreadyissued / " . ( $result->{maxissueqty} + 0 ) );
        }
        else {
            return;
        }
    }

    $sth->execute( "*", "*", "" );
    $result = $sth->fetchrow_hashref;
    if ( defined( $result->{maxissueqty} ) ) {
        $sth3->execute( $borrower->{'borrowernumber'} );
        my $alreadyissued = $sth3->fetchrow;
        if ( $result->{'maxissueqty'} <= $alreadyissued ) {
            return ( "h $alreadyissued / " . ( $result->{maxissueqty} + 0 ) );
        }
        else {
            return;
        }
    }
    return;
}

=head2 itemissues

  @issues = &itemissues($biblioitemnumber, $biblio);

Looks up information about who has borrowed the bookZ<>(s) with the
given biblioitemnumber.

C<$biblio> is ignored.

C<&itemissues> returns an array of references-to-hash. The keys
include the fields from the C<items> table in the Koha database.
Additional keys include:

=over 4

=item C<date_due>

If the item is currently on loan, this gives the due date.

If the item is not on loan, then this is either "Available" or
"Cancelled", if the item has been withdrawn.

=item C<card>

If the item is currently on loan, this gives the card number of the
patron who currently has the item.

=item C<timestamp0>, C<timestamp1>, C<timestamp2>

These give the timestamp for the last three times the item was
borrowed.

=item C<card0>, C<card1>, C<card2>

The card number of the last three patrons who borrowed this item.

=item C<borrower0>, C<borrower1>, C<borrower2>

The borrower number of the last three patrons who borrowed this item.

=back

=cut

#'
sub itemissues {
    my ( $bibitem, $biblio ) = @_;
    my $dbh = C4::Context->dbh;

    # FIXME - If this function die()s, the script will abort, and the
    # user won't get anything; depending on how far the script has
    # gotten, the user might get a blank page. It would be much better
    # to at least print an error message. The easiest way to do this
    # is to set $SIG{__DIE__}.
    my $sth =
      $dbh->prepare("Select * from items where items.biblioitemnumber = ?")
      || die $dbh->errstr;
    my $i = 0;
    my @results;

    $sth->execute($bibitem) || die $sth->errstr;

    while ( my $data = $sth->fetchrow_hashref ) {

        # Find out who currently has this item.
        # FIXME - Wouldn't it be better to do this as a left join of
        # some sort? Currently, this code assumes that if
        # fetchrow_hashref() fails, then the book is on the shelf.
        # fetchrow_hashref() can fail for any number of reasons (e.g.,
        # database server crash), not just because no items match the
        # search criteria.
        my $sth2 = $dbh->prepare(
            "select * from issues,borrowers
where itemnumber = ?
and returndate is NULL
and issues.borrowernumber = borrowers.borrowernumber"
        );

        $sth2->execute( $data->{'itemnumber'} );
        if ( my $data2 = $sth2->fetchrow_hashref ) {
            $data->{'date_due'} = $data2->{'date_due'};
            $data->{'card'}     = $data2->{'cardnumber'};
            $data->{'borrower'} = $data2->{'borrowernumber'};
        }
        else {
            if ( $data->{'wthdrawn'} eq '1' ) {
                $data->{'date_due'} = 'Cancelled';
            }
            else {
                $data->{'date_due'} = 'Available';
            }    # else
        }    # else

        $sth2->finish;

        # Find the last 3 people who borrowed this item.
        $sth2 = $dbh->prepare(
            "select * from issues, borrowers
                        where itemnumber = ?
                                    and issues.borrowernumber = borrowers.borrowernumber
                                    and returndate is not NULL
                                    order by returndate desc,timestamp desc"
        );

#        $sth2 = $dbh->prepare("
#            SELECT *
#            FROM issues
#                LEFT JOIN borrowers ON issues.borrowernumber = borrowers.borrowernumber
#            WHERE   itemnumber = ?
#                AND returndate is not NULL
#            ORDER BY returndate DESC,timestamp DESC
#        ");

        $sth2->execute( $data->{'itemnumber'} );
        for ( my $i2 = 0 ; $i2 < 2 ; $i2++ )
        {    # FIXME : error if there is less than 3 pple borrowing this item
            if ( my $data2 = $sth2->fetchrow_hashref ) {
                $data->{"timestamp$i2"} = $data2->{'timestamp'};
                $data->{"card$i2"}      = $data2->{'cardnumber'};
                $data->{"borrower$i2"}  = $data2->{'borrowernumber'};
            }    # if
        }    # for

        $sth2->finish;
        $results[$i] = $data;
        $i++;
    }

    $sth->finish;
    return (@results);
}

=head2 canbookbeissued

$issuingimpossible, $needsconfirmation = 
        canbookbeissued( $env, $borrower, $barcode, $year, $month, $day, $inprocess );

C<$issuingimpossible> and C<$needsconfirmation> are some hashref.

=cut

sub canbookbeissued {
    my ( $env, $borrower, $barcode, $year, $month, $day, $inprocess ) = @_;
    my %needsconfirmation;    # filled with problems that needs confirmations
    my %issuingimpossible
      ;    # filled with problems that causes the issue to be IMPOSSIBLE
    my $iteminformation = getiteminformation( 0, $barcode );
    my $dbh             = C4::Context->dbh;

    #
    # DUE DATE is OK ?
    #
    my ( $duedate, $invalidduedate ) = fixdate( $year, $month, $day );
    $issuingimpossible{INVALID_DATE} = 1 if ($invalidduedate);

    #
    # BORROWER STATUS
    #
    if ( $borrower->{flags}->{GNA} ) {
        $issuingimpossible{GNA} = 1;
    }
    if ( $borrower->{flags}->{'LOST'} ) {
        $issuingimpossible{CARD_LOST} = 1;
    }
    if ( $borrower->{flags}->{'DBARRED'} ) {
        $issuingimpossible{DEBARRED} = 1;
    }
    if ( Date_to_Days(Today) > 
        Date_to_Days( split "-", $borrower->{'dateexpiry'} ) )
    {

        #
        #if (&Date_Cmp(&ParseDate($borrower->{expiry}),&ParseDate("today"))<0) {
        $issuingimpossible{EXPIRED} = 1;
    }

    #
    # BORROWER STATUS
    #

    # DEBTS
    my $amount =
      checkaccount( $env, $borrower->{'borrowernumber'}, $dbh, $duedate );
    if ( C4::Context->preference("IssuingInProcess") ) {
        my $amountlimit = C4::Context->preference("noissuescharge");
        if ( $amount > $amountlimit && !$inprocess ) {
            $issuingimpossible{DEBT} = sprintf( "%.2f", $amount );
        }
        elsif ( $amount <= $amountlimit && !$inprocess ) {
            $needsconfirmation{DEBT} = sprintf( "%.2f", $amount );
        }
    }
    else {
        if ( $amount > 0 ) {
            $needsconfirmation{DEBT} = $amount;
        }
    }

    #
    # JB34 CHECKS IF BORROWERS DONT HAVE ISSUE TOO MANY BOOKS
    #
    my $toomany = TooMany( $borrower, $iteminformation );
    $needsconfirmation{TOO_MANY} = $toomany if $toomany;

    #
    # ITEM CHECKING
    #
    unless ( $iteminformation->{barcode} ) {
        $issuingimpossible{UNKNOWN_BARCODE} = 1;
    }
    if (   $iteminformation->{'notforloan'}
        && $iteminformation->{'notforloan'} > 0 )
    {
        $issuingimpossible{NOT_FOR_LOAN} = 1;
    }
    if (   $iteminformation->{'itemtype'}
        && $iteminformation->{'itemtype'} eq 'REF' )
    {
        $issuingimpossible{NOT_FOR_LOAN} = 1;
    }
    if ( $iteminformation->{'wthdrawn'} && $iteminformation->{'wthdrawn'} == 1 )
    {
        $issuingimpossible{WTHDRAWN} = 1;
    }
    if (   $iteminformation->{'restricted'}
        && $iteminformation->{'restricted'} == 1 )
    {
        $issuingimpossible{RESTRICTED} = 1;
    }
    if ( C4::Context->preference("IndependantBranches") ) {
        my $userenv = C4::Context->userenv;
        if ( ($userenv) && ( $userenv->{flags} != 1 ) ) {
            $issuingimpossible{NOTSAMEBRANCH} = 1
              if ( $iteminformation->{'holdingbranch'} ne $userenv->{branch} );
        }
    }

    #
    # CHECK IF BOOK ALREADY ISSUED TO THIS BORROWER
    #
    my ($currentborrower) = currentborrower( $iteminformation->{'itemnumber'} );
    if ( $currentborrower && $currentborrower eq $borrower->{'borrowernumber'} )
    {

        # Already issued to current borrower. Ask whether the loan should
        # be renewed.
        my ($renewstatus) = renewstatus(
            $env,
            $borrower->{'borrowernumber'},
            $iteminformation->{'itemnumber'}
        );
        if ( $renewstatus == 0 ) {    # no more renewals allowed
            $issuingimpossible{NO_MORE_RENEWALS} = 1;
        }
        else {

            #        $needsconfirmation{RENEW_ISSUE} = 1;
        }
    }
    elsif ($currentborrower) {

        # issued to someone else
        my $currborinfo = getpatroninformation( 0, $currentborrower );

#        warn "=>.$currborinfo->{'firstname'} $currborinfo->{'surname'} ($currborinfo->{'cardnumber'})";
        $needsconfirmation{ISSUED_TO_ANOTHER} =
"$currborinfo->{'reservedate'} : $currborinfo->{'firstname'} $currborinfo->{'surname'} ($currborinfo->{'cardnumber'})";
    }

    # See if the item is on reserve.
    my ( $restype, $res ) = CheckReserves( $iteminformation->{'itemnumber'} );
    if ($restype) {
        my $resbor = $res->{'borrowernumber'};
        if ( $resbor ne $borrower->{'borrowernumber'} && $restype eq "Waiting" )
        {

            # The item is on reserve and waiting, but has been
            # reserved by some other patron.
            my ( $resborrower, $flags ) =
              getpatroninformation( $env, $resbor, 0 );
            my $branches   = GetBranches();
            my $branchname =
              $branches->{ $res->{'branchcode'} }->{'branchname'};
            $needsconfirmation{RESERVE_WAITING} =
"$resborrower->{'firstname'} $resborrower->{'surname'} ($resborrower->{'cardnumber'}, $branchname)";

# CancelReserve(0, $res->{'itemnumber'}, $res->{'borrowernumber'}); Doesn't belong in a checking subroutine.
        }
        elsif ( $restype eq "Reserved" ) {

            # The item is on reserve for someone else.
            my ( $resborrower, $flags ) =
              getpatroninformation( $env, $resbor, 0 );
            my $branches   = GetBranches();
            my $branchname =
              $branches->{ $res->{'branchcode'} }->{'branchname'};
            $needsconfirmation{RESERVED} =
"$res->{'reservedate'} : $resborrower->{'firstname'} $resborrower->{'surname'} ($resborrower->{'cardnumber'})";
        }
    }
    if ( C4::Context->preference("LibraryName") eq "Horowhenua Library Trust" )
    {
        if ( $borrower->{'categorycode'} eq 'W' ) {
            my %issuingimpossible;
            return ( \%issuingimpossible, \%needsconfirmation );
        }
        else {
            return ( \%issuingimpossible, \%needsconfirmation );
        }
    }
    else {
        return ( \%issuingimpossible, \%needsconfirmation );
    }
}

=head2 issuebook

Issue a book. Does no check, they are done in canbookbeissued. If we reach this sub, it means the user confirmed if needed.

&issuebook($env,$borrower,$barcode,$date)

=over 4

=item C<$env> Environment variable. Should be empty usually, but used by other subs. Next code cleaning could drop it.

=item C<$borrower> hash with borrower informations (from getpatroninformation)

=item C<$barcode> is the bar code of the book being issued.

=item C<$date> contains the max date of return. calculated if empty.

=back

=cut

sub issuebook {
    my ( $env, $borrower, $barcode, $date, $cancelreserve ) = @_;
    my $dbh = C4::Context->dbh;

#   my ($borrower, $flags) = &getpatroninformation($env, $borrowernumber, 0);
    my $iteminformation = getiteminformation( 0, $barcode );

#
# check if we just renew the issue.
#
    my ($currentborrower) = currentborrower( $iteminformation->{'itemnumber'} );
    if ( $currentborrower eq $borrower->{'borrowernumber'} ) {
        my ( $charge, $itemtype ) = calc_charges(
            $env,
            $iteminformation->{'itemnumber'},
            $borrower->{'borrowernumber'}
        );
        if ( $charge > 0 ) {
            createcharge(
                $env, $dbh,
                $iteminformation->{'itemnumber'},
                $borrower->{'borrowernumber'}, $charge
            );
            $iteminformation->{'charge'} = $charge;
        }
        &UpdateStats(
            $env,                           $env->{'branchcode'},
            'renew',                        $charge,
            '',                             $iteminformation->{'itemnumber'},
            $iteminformation->{'itemtype'}, $borrower->{'borrowernumber'}
        );
        renewbook(
            $env,
            $borrower->{'borrowernumber'},
            $iteminformation->{'itemnumber'}
        );
    }
    else {

        #
        # NOT a renewal
        #
        if ( $currentborrower ne '' ) {

# This book is currently on loan, but not to the person
# who wants to borrow it now. mark it returned before issuing to the new borrower
            returnbook(
                $iteminformation->{'barcode'},
                C4::Context->userenv->{'branch'}
            );
        }

        # See if the item is on reserve.
        my ( $restype, $res ) =
          CheckReserves( $iteminformation->{'itemnumber'} );
        if ($restype) {
            my $resbor = $res->{'borrowernumber'};
            if ( $resbor eq $borrower->{'borrowernumber'} ) {

                # The item is on reserve to the current patron
                FillReserve($res);
            }
            elsif ( $restype eq "Waiting" ) {

                #                 warn "Waiting";
                # The item is on reserve and waiting, but has been
                # reserved by some other patron.
                my ( $resborrower, $flags ) =
                  getpatroninformation( $env, $resbor, 0 );
                my $branches   = GetBranches();
                my $branchname =
                  $branches->{ $res->{'branchcode'} }->{'branchname'};
                if ($cancelreserve) {
                    CancelReserve( 0, $res->{'itemnumber'},
                        $res->{'borrowernumber'} );
                }
                else {

       # set waiting reserve to first in reserve queue as book isn't waiting now
                    UpdateReserve(
                        1,
                        $res->{'biblionumber'},
                        $res->{'borrowernumber'},
                        $res->{'branchcode'}
                    );
                }
            }
            elsif ( $restype eq "Reserved" ) {

                #                 warn "Reserved";
                # The item is on reserve for someone else.
                my ( $resborrower, $flags ) =
                  getpatroninformation( $env, $resbor, 0 );
                my $branches   = GetBranches();
                my $branchname =
                  $branches->{ $res->{'branchcode'} }->{'branchname'};
                if ($cancelreserve) {

                    # cancel reserves on this item
                    CancelReserve( 0, $res->{'itemnumber'},
                        $res->{'borrowernumber'} );

# also cancel reserve on biblio related to this item
#my $st_Fbiblio = $dbh->prepare("select biblionumber from items where itemnumber=?");
#$st_Fbiblio->execute($res->{'itemnumber'});
#my $biblionumber = $st_Fbiblio->fetchrow;
#CancelReserve($biblionumber,0,$res->{'borrowernumber'});
#warn "CancelReserve $res->{'itemnumber'}, $res->{'borrowernumber'}";
                }
                else {

#                     my $tobrcd = ReserveWaiting($res->{'itemnumber'}, $res->{'borrowernumber'});
#                     transferbook($tobrcd,$barcode, 1);
#                     warn "transferbook";
                }
            }
        }
# END OF THE RESTYPE WORK

# Starting process for transfer job (checking transfert and validate it if we have one)

	my ($datesent) = get_transfert_infos($iteminformation->{'itemnumber'});
	
	if ($datesent) {
# 	updating line of branchtranfert to finish it, and changing the to branch value, implement a comment for lisibility of this case (maybe for stats ....)
	my $sth =
          	$dbh->prepare(
			"update branchtransfers set datearrived = now(),
			tobranch = ?,
			comments = 'Forced branchtransfert'
			 where
			 itemnumber= ? AND datearrived IS NULL"
          	);
        	$sth->execute(C4::Context->userenv->{'branch'},$iteminformation->{'itemnumber'});
        	$sth->finish;
	}
	
# Ending process for transfert check

        # Record in the database the fact that the book was issued.
        my $sth =
          $dbh->prepare(
"insert into issues (borrowernumber, itemnumber,issuedate, date_due, branchcode) values (?,?,?,?,?)"
          );
        my $loanlength = getLoanLength(
            $borrower->{'categorycode'},
            $iteminformation->{'itemtype'},
            $borrower->{'branchcode'}
        );
        my $datedue  = time + ($loanlength) * 86400;
        my @datearr  = localtime($datedue);
        my $dateduef =
            ( 1900 + $datearr[5] ) . "-"
          . ( $datearr[4] + 1 ) . "-"
          . $datearr[3];
        if ($date) {
            $dateduef = $date;
        }

       # if ReturnBeforeExpiry ON the datedue can't be after borrower expirydate
        if ( C4::Context->preference('ReturnBeforeExpiry')
            && $dateduef gt $borrower->{dateexpiry} )
        {
            $dateduef = $borrower->{dateexpiry};
        }
        $sth->execute(
            $borrower->{'borrowernumber'},
            $iteminformation->{'itemnumber'},
            strftime( "%Y-%m-%d", localtime ),$dateduef, $env->{'branchcode'}
        );
        $sth->finish;
        $iteminformation->{'issues'}++;
        $sth =
          $dbh->prepare(
            "update items set issues=?, holdingbranch=? where itemnumber=?");
        $sth->execute(
            $iteminformation->{'issues'},
            C4::Context->userenv->{'branch'},
            $iteminformation->{'itemnumber'}
        );
        $sth->finish;
        &itemseen( $iteminformation->{'itemnumber'} );
        itemborrowed( $iteminformation->{'itemnumber'} );

        # If it costs to borrow this book, charge it to the patron's account.
        my ( $charge, $itemtype ) = calc_charges(
            $env,
            $iteminformation->{'itemnumber'},
            $borrower->{'borrowernumber'}
        );
        if ( $charge > 0 ) {
            createcharge(
                $env, $dbh,
                $iteminformation->{'itemnumber'},
                $borrower->{'borrowernumber'}, $charge
            );
            $iteminformation->{'charge'} = $charge;
        }

        # Record the fact that this book was issued.
        &UpdateStats(
            $env,                           $env->{'branchcode'},
            'issue',                        $charge,
            '',                             $iteminformation->{'itemnumber'},
            $iteminformation->{'itemtype'}, $borrower->{'borrowernumber'}
        );
    }
    
    &logaction(C4::Context->userenv->{'number'},"CIRCULATION","ISSUE",$borrower->{'borrowernumber'},$iteminformation->{'biblionumber'}) 
        if C4::Context->preference("IssueLog");
    
}

=head2 getLoanLength

Get loan length for an itemtype, a borrower type and a branch

my $loanlength = &getLoanLength($borrowertype,$itemtype,branchcode)

=cut

sub getLoanLength {
    my ( $borrowertype, $itemtype, $branchcode ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth =
      $dbh->prepare(
"select issuelength from issuingrules where categorycode=? and itemtype=? and branchcode=?"
      );

# try to find issuelength & return the 1st available.
# check with borrowertype, itemtype and branchcode, then without one of those parameters
    $sth->execute( $borrowertype, $itemtype, $branchcode );
    my $loanlength = $sth->fetchrow_hashref;
    return $loanlength->{issuelength}
      if defined($loanlength) && $loanlength->{issuelength} ne 'NULL';

    $sth->execute( $borrowertype, $itemtype, "" );
    $loanlength = $sth->fetchrow_hashref;
    return $loanlength->{issuelength}
      if defined($loanlength) && $loanlength->{issuelength} ne 'NULL';

    $sth->execute( $borrowertype, "*", $branchcode );
    $loanlength = $sth->fetchrow_hashref;
    return $loanlength->{issuelength}
      if defined($loanlength) && $loanlength->{issuelength} ne 'NULL';

    $sth->execute( "*", $itemtype, $branchcode );
    $loanlength = $sth->fetchrow_hashref;
    return $loanlength->{issuelength}
      if defined($loanlength) && $loanlength->{issuelength} ne 'NULL';

    $sth->execute( $borrowertype, "*", "" );
    $loanlength = $sth->fetchrow_hashref;
    return $loanlength->{issuelength}
      if defined($loanlength) && $loanlength->{issuelength} ne 'NULL';

    $sth->execute( "*", "*", $branchcode );
    $loanlength = $sth->fetchrow_hashref;
    return $loanlength->{issuelength}
      if defined($loanlength) && $loanlength->{issuelength} ne 'NULL';

    $sth->execute( "*", $itemtype, "" );
    $loanlength = $sth->fetchrow_hashref;
    return $loanlength->{issuelength}
      if defined($loanlength) && $loanlength->{issuelength} ne 'NULL';

    $sth->execute( "*", "*", "" );
    $loanlength = $sth->fetchrow_hashref;
    return $loanlength->{issuelength}
      if defined($loanlength) && $loanlength->{issuelength} ne 'NULL';

    # if no rule is set => 21 days (hardcoded)
    return 21;
}

=head2 returnbook

($doreturn, $messages, $iteminformation, $borrower) =
    &returnbook($barcode, $branch);

Returns a book.

C<$barcode> is the bar code of the book being returned. C<$branch> is
the code of the branch where the book is being returned.

C<&returnbook> returns a list of four items:

C<$doreturn> is true iff the return succeeded.

C<$messages> is a reference-to-hash giving the reason for failure:

=over 4

=item C<BadBarcode>

No item with this barcode exists. The value is C<$barcode>.

=item C<NotIssued>

The book is not currently on loan. The value is C<$barcode>.

=item C<IsPermanent>

The book's home branch is a permanent collection. If you have borrowed
this book, you are not allowed to return it. The value is the code for
the book's home branch.

=item C<wthdrawn>

This book has been withdrawn/cancelled. The value should be ignored.

=item C<ResFound>

The item was reserved. The value is a reference-to-hash whose keys are
fields from the reserves table of the Koha database, and
C<biblioitemnumber>. It also has the key C<ResFound>, whose value is
either C<Waiting>, C<Reserved>, or 0.

=back

C<$borrower> is a reference-to-hash, giving information about the
patron who last borrowed the book.

=cut

# FIXME - This API is bogus. There's no need to return $borrower and
# $iteminformation; the caller can ask about those separately, if it
# cares (it'd be inefficient to make two database calls instead of
# one, but &getpatroninformation and &getiteminformation can be
# memoized if this is an issue).
#
# The ($doreturn, $messages) tuple is redundant: if the return
# succeeded, that's all the caller needs to know. So &returnbook can
# return 1 and 0 on success and failure, and set
# $C4::Circulation::Circ2::errmsg to indicate the error. Or it can
# return undef for success, and an error message on error (though this
# is more C-ish than Perl-ish).

sub returnbook {
    my ( $barcode, $branch ) = @_;
    my %env;
    my $messages;
    my $dbh      = C4::Context->dbh;
    my $doreturn = 1;
    my $validTransfert = 0;
    my $reserveDone = 0;
    
    die '$branch not defined' unless defined $branch;  # just in case (bug 170)
                                                       # get information on item
    my ($iteminformation) = getiteminformation( 0, $barcode );

    if ( not $iteminformation ) {
        $messages->{'BadBarcode'} = $barcode;
        $doreturn = 0;
    }

    # find the borrower
    my ($currentborrower) = currentborrower( $iteminformation->{'itemnumber'} );
    if ( ( not $currentborrower ) && $doreturn ) {
        $messages->{'NotIssued'} = $barcode;
        $doreturn = 0;
    }

    # check if the book is in a permanent collection....
    my $hbr      = $iteminformation->{'homebranch'};
    my $branches = GetBranches();
    if ( $hbr && $branches->{$hbr}->{'PE'} ) {
        $messages->{'IsPermanent'} = $hbr;
    }

    # check that the book has been cancelled
    if ( $iteminformation->{'wthdrawn'} ) {
        $messages->{'wthdrawn'} = 1;itemnumber
        $doreturn = 0;
    }

#     new op dev : if the book returned in an other branch update the holding branch

# update issues, thereby returning book (should push this out into another subroutine
    my ($borrower) = getpatroninformation( \%env, $currentborrower, 0 );

# case of a return of document (deal with issues and holdingbranch)

    if ($doreturn) {
        my $sth =
          $dbh->prepare(
"update issues set returndate = now() where (borrowernumber = ?) and (itemnumber = ?) and (returndate is null)"
          );
        $sth->execute( $borrower->{'borrowernumber'},
            $iteminformation->{'itemnumber'} );
        $messages->{'WasReturned'} = 1;    # FIXME is the "= 1" right?
    }

# continue to deal with returns cases, but not only if we have an issue

# the holdingbranch is updated if the document is returned in an other location .
if ( $iteminformation->{'holdingbranch'} ne C4::Context->userenv->{'branch'} )
        {
        	UpdateHoldingbranch(C4::Context->userenv->{'branch'},$iteminformation->{'itemnumber'});	
#         	reload iteminformation holdingbranch with the userenv value
        	$iteminformation->{'holdingbranch'} = C4::Context->userenv->{'branch'};
        }
    itemseen( $iteminformation->{'itemnumber'} );
    ($borrower) = getpatroninformation( \%env, $currentborrower, 0 );
    
    # fix up the accounts.....
    if ( $iteminformation->{'itemlost'} ) {
        fixaccountforlostandreturned( $iteminformation, $borrower );
        $messages->{'WasLost'} = 1;    # FIXME is the "= 1" right?
    }

   # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
   #     check if we have a transfer for this document
    my ($datesent,$frombranch,$tobranch) = checktransferts( $iteminformation->{'itemnumber'} );

 #     if we have a return, we update the line of transfers with the datearrived
    if ($datesent) {
    	if ( $tobranch eq C4::Context->userenv->{'branch'} ) {
        	my $sth =
          	$dbh->prepare(
			"update branchtransfers set datearrived = now() where itemnumber= ? AND datearrived IS NULL"
          	);
        	$sth->execute( $iteminformation->{'itemnumber'} );
        	$sth->finish;
#         now we check if there is a reservation with the validate of transfer if we have one, we can         set it with the status 'W'
        SetWaitingStatus( $iteminformation->{'itemnumber'} );
        }
     else {
     	$messages->{'WrongTransfer'} = $tobranch;
     	$messages->{'WrongTransferItem'} = $iteminformation->{'itemnumber'};
     }
     $validTransfert = 1;
    }

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# fix up the overdues in accounts...
    fixoverduesonreturn( $borrower->{'borrowernumber'},
        $iteminformation->{'itemnumber'} );

# find reserves.....
#     if we don't have a reserve with the status W, we launch the Checkreserves routine
    my ( $resfound, $resrec ) =
      CheckReserves( $iteminformation->{'itemnumber'} );
    if ($resfound) {

#    my $tobrcd = ReserveWaiting($resrec->{'itemnumber'}, $resrec->{'borrowernumber'});
        $resrec->{'ResFound'}   = $resfound;
        $messages->{'ResFound'} = $resrec;
        $reserveDone = 1;
    }

    # update stats?
    # Record the fact that this book was returned.
    UpdateStats(
        \%env, $branch, 'return', '0', '',
        $iteminformation->{'itemnumber'},
        $iteminformation->{'itemtype'},
        $borrower->{'borrowernumber'}
    );
    
    &logaction(C4::Context->userenv->{'number'},"CIRCULATION","RETURN",$currentborrower,$iteminformation->{'biblionumber'}) 
        if C4::Context->preference("ReturnLog");
     
    #adding message if holdingbranch is non equal a userenv branch to return the document to homebranch
    #we check, if we don't have reserv or transfert for this document, if not, return it to homebranch .
    
    if ( ($iteminformation->{'holdingbranch'} ne $iteminformation->{'homebranch'}) and not $messages->{'WrongTransfer'} and ($validTransfert ne 1) and ($reserveDone ne 1) ){
		if (C4::Context->preference("AutomaticItemReturn") == 1) {
        	dotransfer($iteminformation->{'itemnumber'}, C4::Context->userenv->{'branch'}, $iteminformation->{'homebranch'});
        	$messages->{'WasTransfered'} = 1;
        	warn "was transfered";
        	}
    }
        
    return ( $doreturn, $messages, $iteminformation, $borrower );
}

=head2 fixaccountforlostandreturned

    &fixaccountforlostandreturned($iteminfo,$borrower);

Calculates the charge for a book lost and returned (Not exported & used only once)

C<$iteminfo> is a hashref to iteminfo. Only {itemnumber} is used.

C<$borrower> is a hashref to borrower. Only {borrowernumber is used.

=cut

sub fixaccountforlostandreturned {
    my ( $iteminfo, $borrower ) = @_;
    my %env;
    my $dbh = C4::Context->dbh;
    my $itm = $iteminfo->{'itemnumber'};

    # check for charge made for lost book
    my $sth =
      $dbh->prepare(
"select * from accountlines where (itemnumber = ?) and (accounttype='L' or accounttype='Rep') order by date desc"
      );
    $sth->execute($itm);
    if ( my $data = $sth->fetchrow_hashref ) {

        # writeoff this amount
        my $offset;
        my $amount = $data->{'amount'};
        my $acctno = $data->{'accountno'};
        my $amountleft;
        if ( $data->{'amountoutstanding'} == $amount ) {
            $offset     = $data->{'amount'};
            $amountleft = 0;
        }
        else {
            $offset     = $amount - $data->{'amountoutstanding'};
            $amountleft = $data->{'amountoutstanding'} - $amount;
        }
        my $usth = $dbh->prepare(
            "update accountlines set accounttype = 'LR',amountoutstanding='0'
            where (borrowernumber = ?)
            and (itemnumber = ?) and (accountno = ?) "
        );
        $usth->execute( $data->{'borrowernumber'}, $itm, $acctno );
        $usth->finish;

        #check if any credit is left if so writeoff other accounts
        my $nextaccntno =
          getnextacctno( \%env, $data->{'borrowernumber'}, $dbh );
        if ( $amountleft < 0 ) {
            $amountleft *= -1;
        }
        if ( $amountleft > 0 ) {
            my $msth = $dbh->prepare(
                "select * from accountlines where (borrowernumber = ?)
                            and (amountoutstanding >0) order by date"
            );
            $msth->execute( $data->{'borrowernumber'} );

            # offset transactions
            my $newamtos;
            my $accdata;
            while ( ( $accdata = $msth->fetchrow_hashref )
                and ( $amountleft > 0 ) )
            {
                if ( $accdata->{'amountoutstanding'} < $amountleft ) {
                    $newamtos = 0;
                    $amountleft -= $accdata->{'amountoutstanding'};
                }
                else {
                    $newamtos   = $accdata->{'amountoutstanding'} - $amountleft;
                    $amountleft = 0;
                }
                my $thisacct = $accdata->{'accountno'};
                my $usth     = $dbh->prepare(
                    "update accountlines set amountoutstanding= ?
                    where (borrowernumber = ?)
                    and (accountno=?)"
                );
                $usth->execute( $newamtos, $data->{'borrowernumber'},
                    '$thisacct' );
                $usth->finish;
                $usth = $dbh->prepare(
                    "insert into accountoffsets
                (borrowernumber, accountno, offsetaccount,  offsetamount)
                values
                (?,?,?,?)"
                );
                $usth->execute(
                    $data->{'borrowernumber'},
                    $accdata->{'accountno'},
                    $nextaccntno, $newamtos
                );
                $usth->finish;
            }
            $msth->finish;
        }
        if ( $amountleft > 0 ) {
            $amountleft *= -1;
        }
        my $desc = "Book Returned " . $iteminfo->{'barcode'};
        $usth = $dbh->prepare(
            "insert into accountlines
            (borrowernumber,accountno,date,amount,description,accounttype,amountoutstanding)
            values (?,?,now(),?,?,'CR',?)"
        );
        $usth->execute(
            $data->{'borrowernumber'},
            $nextaccntno, 0 - $amount,
            $desc, $amountleft
        );
        $usth->finish;
        $usth = $dbh->prepare(
            "insert into accountoffsets
            (borrowernumber, accountno, offsetaccount,  offsetamount)
            values (?,?,?,?)"
        );
        $usth->execute( $borrower->{'borrowernumber'},
            $data->{'accountno'}, $nextaccntno, $offset );
        $usth->finish;
        $usth = $dbh->prepare("update items set paidfor='' where itemnumber=?");
        $usth->execute($itm);
        $usth->finish;
    }
    $sth->finish;
    return;
}

=head2 fixoverdueonreturn

    &fixoverdueonreturn($brn,$itm);

C<$brn> borrowernumber

C<$itm> itemnumber

=cut

sub fixoverduesonreturn {
    my ( $brn, $itm ) = @_;
    my $dbh = C4::Context->dbh;

    # check for overdue fine
    my $sth =
      $dbh->prepare(
"select * from accountlines where (borrowernumber = ?) and (itemnumber = ?) and (accounttype='FU' or accounttype='O')"
      );
    $sth->execute( $brn, $itm );

    # alter fine to show that the book has been returned
    if ( my $data = $sth->fetchrow_hashref ) {
        my $usth =
          $dbh->prepare(
"update accountlines set accounttype='F' where (borrowernumber = ?) and (itemnumber = ?) and (accountno = ?)"
          );
        $usth->execute( $brn, $itm, $data->{'accountno'} );
        $usth->finish();
    }
    $sth->finish();
    return;
}

=head2 patronflags

 Not exported

 NOTE!: If you change this function, be sure to update the POD for
 &getpatroninformation.

 $flags = &patronflags($env, $patron, $dbh);

 $flags->{CHARGES}
        {message}    Message showing patron's credit or debt
       {noissues}    Set if patron owes >$5.00
         {GNA}            Set if patron gone w/o address
        {message}    "Borrower has no valid address"
        {noissues}    Set.
        {LOST}        Set if patron's card reported lost
        {message}    Message to this effect
        {noissues}    Set.
        {DBARRED}        Set is patron is debarred
        {message}    Message to this effect
        {noissues}    Set.
         {NOTES}        Set if patron has notes
        {message}    Notes about patron
         {ODUES}        Set if patron has overdue books
        {message}    "Yes"
        {itemlist}    ref-to-array: list of overdue books
        {itemlisttext}    Text list of overdue items
         {WAITING}        Set if there are items available that the
                patron reserved
        {message}    Message to this effect
        {itemlist}    ref-to-array: list of available items

=cut

sub patronflags {

    # Original subroutine for Circ2.pm
    my %flags;
    my ( $env, $patroninformation, $dbh ) = @_;
    my $amount =
      checkaccount( $env, $patroninformation->{'borrowernumber'}, $dbh );
    if ( $amount > 0 ) {
        my %flaginfo;
        my $noissuescharge = C4::Context->preference("noissuescharge");
        $flaginfo{'message'} = sprintf "Patron owes \$%.02f", $amount;
        if ( $amount > $noissuescharge ) {
            $flaginfo{'noissues'} = 1;
        }
        $flags{'CHARGES'} = \%flaginfo;
    }
    elsif ( $amount < 0 ) {
        my %flaginfo;
        $flaginfo{'message'} = sprintf "Patron has credit of \$%.02f", -$amount;
        $flags{'CHARGES'} = \%flaginfo;
    }
    if (   $patroninformation->{'gonenoaddress'}
        && $patroninformation->{'gonenoaddress'} == 1 )
    {
        my %flaginfo;
        $flaginfo{'message'}  = 'Borrower has no valid address.';
        $flaginfo{'noissues'} = 1;
        $flags{'GNA'}         = \%flaginfo;
    }
    if ( $patroninformation->{'lost'} && $patroninformation->{'lost'} == 1 ) {
        my %flaginfo;
        $flaginfo{'message'}  = 'Borrower\'s card reported lost.';
        $flaginfo{'noissues'} = 1;
        $flags{'LOST'}        = \%flaginfo;
    }
    if (   $patroninformation->{'debarred'}
        && $patroninformation->{'debarred'} == 1 )
    {
        my %flaginfo;
        $flaginfo{'message'}  = 'Borrower is Debarred.';
        $flaginfo{'noissues'} = 1;
        $flags{'DBARRED'}     = \%flaginfo;
    }
    if (   $patroninformation->{'borrowernotes'}
        && $patroninformation->{'borrowernotes'} )
    {
        my %flaginfo;
        $flaginfo{'message'} = "$patroninformation->{'borrowernotes'}";
        $flags{'NOTES'}      = \%flaginfo;
    }
    my ( $odues, $itemsoverdue ) =
      checkoverdues( $env, $patroninformation->{'borrowernumber'}, $dbh );
    if ( $odues > 0 ) {
        my %flaginfo;
        $flaginfo{'message'}  = "Yes";
        $flaginfo{'itemlist'} = $itemsoverdue;
        foreach ( sort { $a->{'date_due'} cmp $b->{'date_due'} }
            @$itemsoverdue )
        {
            $flaginfo{'itemlisttext'} .=
              "$_->{'date_due'} $_->{'barcode'} $_->{'title'} \n";
        }
        $flags{'ODUES'} = \%flaginfo;
    }
    my $itemswaiting =
      C4::Reserves2::GetWaitingReserves( $patroninformation->{'borrowernumber'} );
    my $nowaiting = scalar @$itemswaiting;
    if ( $nowaiting > 0 ) {
        my %flaginfo;
        $flaginfo{'message'}  = "Reserved items available";
        $flaginfo{'itemlist'} = $itemswaiting;
        $flags{'WAITING'}     = \%flaginfo;
    }
    return ( \%flags );
}

=head2 checkoverdues

( $count, $overdueitems )=checkoverdues( $env, $borrowernumber, $dbh );

Not exported

=cut

sub checkoverdues {

# From Main.pm, modified to return a list of overdueitems, in addition to a count
#checks whether a borrower has overdue items
    my ( $env, $borrowernumber, $dbh ) = @_;
    my @datearr = localtime;
    my $today   =
      ( $datearr[5] + 1900 ) . "-" . ( $datearr[4] + 1 ) . "-" . $datearr[3];
    my @overdueitems;
    my $count = 0;
    my $sth   = $dbh->prepare(
        "SELECT * FROM issues,biblio,biblioitems,items
            WHERE items.biblioitemnumber = biblioitems.biblioitemnumber
                AND items.biblionumber     = biblio.biblionumber
                AND issues.itemnumber      = items.itemnumber
                AND issues.borrowernumber  = ?
                AND issues.returndate is NULL
                AND issues.date_due < ?"
    );
    $sth->execute( $borrowernumber, $today );
    while ( my $data = $sth->fetchrow_hashref ) {
        push( @overdueitems, $data );
        $count++;
    }
    $sth->finish;
    return ( $count, \@overdueitems );
}

=head2 currentborrower

$borrower=currentborrower($itemnumber)

Not exported

=cut

sub currentborrower {

    # Original subroutine for Circ2.pm
    my ($itemnumber) = @_;
    my $dbh          = C4::Context->dbh;
    my $q_itemnumber = $dbh->quote($itemnumber);
    my $sth          = $dbh->prepare(
        "select borrowers.borrowernumber from
    issues,borrowers where issues.itemnumber=$q_itemnumber and
    issues.borrowernumber=borrowers.borrowernumber and issues.returndate is
    NULL"
    );
    $sth->execute;
    my ($borrower) = $sth->fetchrow;
    return ($borrower);
}

=head2 checkreserve_to_delete

( $resbor, $resrec ) = &checkreserve_to_delete($env,$dbh,$itemnum);

=cut

sub checkreserve_to_delete {

    # Stolen from Main.pm
    # Check for reserves for biblio
    my ( $env, $dbh, $itemnum ) = @_;
    my $resbor = "";
    my $sth    = $dbh->prepare(
        "select * from reserves,items
    where (items.itemnumber = ?)
    and (reserves.cancellationdate is NULL)
    and (items.biblionumber = reserves.biblionumber)
    and ((reserves.found = 'W')
    or (reserves.found is null))
    order by priority"
    );
    $sth->execute($itemnum);
    my $resrec;
    my $data = $sth->fetchrow_hashref;
    while ( $data && $resbor eq '' ) {
        $resrec = $data;
        my $const = $data->{'constrainttype'};
        if ( $const eq "a" ) {
            $resbor = $data->{'borrowernumber'};
        }
        else {
            my $found = 0;
            my $csth  = $dbh->prepare(
                "select * from reserveconstraints,items
        where (borrowernumber=?)
        and reservedate=?
        and reserveconstraints.biblionumber=?
        and (items.itemnumber=? and
        items.biblioitemnumber = reserveconstraints.biblioitemnumber)"
            );
            $csth->execute(
                $data->{'borrowernumber'},
                $data->{'biblionumber'},
                $data->{'reservedate'}, $itemnum
            );
            if ( my $cdata = $csth->fetchrow_hashref ) { $found = 1; }
            if ( $const eq 'o' ) {
                if ( $found eq 1 ) { $resbor = $data->{'borrowernumber'}; }
            }
            else {
                if ( $found eq 0 ) { $resbor = $data->{'borrowernumber'}; }
            }
            $csth->finish();
        }
        $data = $sth->fetchrow_hashref;
    }
    $sth->finish;
    return ( $resbor, $resrec );
}

=head2 currentissues

$issues = &currentissues($env, $borrower);

Returns a list of books currently on loan to a patron.

If C<$env-E<gt>{todaysissues}> is set and true, C<&currentissues> only
returns information about books issued today. If
C<$env-E<gt>{nottodaysissues}> is set and true, C<&currentissues> only
returns information about books issued before today. If both are
specified, C<$env-E<gt>{todaysissues}> is ignored. If neither is
specified, C<&currentissues> returns all of the patron's issues.

C<$borrower->{borrowernumber}> is the borrower number of the patron
whose issues we want to list.

C<&currentissues> returns a PHP-style array: C<$issues> is a
reference-to-hash whose keys are integers in the range 1...I<n>, where
I<n> is the number of items on issue (either today or before today).
C<$issues-E<gt>{I<n>}> is a reference-to-hash whose keys are all of
the fields of the biblio, biblioitems, items, and issues fields of the
Koha database for that particular item.

=cut

#'
sub currentissues {

    # New subroutine for Circ2.pm
    my ( $env, $borrower ) = @_;
    my $dbh = C4::Context->dbh;
    my %currentissues;
    my $counter        = 1;
    my $borrowernumber = $borrower->{'borrowernumber'};
    my $crit           = '';

    # Figure out whether to get the books issued today, or earlier.
    # FIXME - $env->{todaysissues} and $env->{nottodaysissues} can
    # both be specified, but are mutually-exclusive. This is bogus.
    # Make this a flag. Or better yet, return everything in (reverse)
    # chronological order and let the caller figure out which books
    # were issued today.
    if ( $env->{'todaysissues'} ) {

        # FIXME - Could use
        #    $today = POSIX::strftime("%Y%m%d", localtime);
        # FIXME - Since $today will be used in either case, move it
        # out of the two if-blocks.
        my @datearr = localtime( time() );
        my $today   = ( 1900 + $datearr[5] ) . sprintf "%02d",
          ( $datearr[4] + 1 ) . sprintf "%02d", $datearr[3];

        # FIXME - MySQL knows about dates. Just use
        #    and issues.timestamp = curdate();
        $crit = " and issues.timestamp like '$today%' ";
    }
    if ( $env->{'nottodaysissues'} ) {

        # FIXME - Could use
        #    $today = POSIX::strftime("%Y%m%d", localtime);
        # FIXME - Since $today will be used in either case, move it
        # out of the two if-blocks.
        my @datearr = localtime( time() );
        my $today   = ( 1900 + $datearr[5] ) . sprintf "%02d",
          ( $datearr[4] + 1 ) . sprintf "%02d", $datearr[3];

        # FIXME - MySQL knows about dates. Just use
        #    and issues.timestamp < curdate();
        $crit = " and !(issues.timestamp like '$today%') ";
    }

    # FIXME - Does the caller really need every single field from all
    # four tables?
    my $sth = $dbh->prepare(
        "select * from issues,items,biblioitems,biblio where
    borrowernumber=? and issues.itemnumber=items.itemnumber and
    items.biblionumber=biblio.biblionumber and
    items.biblioitemnumber=biblioitems.biblioitemnumber and returndate is null
    $crit order by issues.date_due"
    );
    $sth->execute($borrowernumber);
    while ( my $data = $sth->fetchrow_hashref ) {

        # FIXME - The Dewey code is a string, not a number.
        $data->{'dewey'} =~ s/0*$//;
        ( $data->{'dewey'} == 0 ) && ( $data->{'dewey'} = '' );

        # FIXME - Could use
        #    $todaysdate = POSIX::strftime("%Y%m%d", localtime)
        # or better yet, just reuse $today which was calculated above.
        # This function isn't going to run until midnight, is it?
        # Alternately, use
        #    $todaysdate = POSIX::strftime("%Y-%m-%d", localtime)
        #    if ($data->{'date_due'} lt $todaysdate)
        #        ...
        # Either way, the date should be be formatted outside of the
        # loop.
        my @datearr    = localtime( time() );
        my $todaysdate =
            ( 1900 + $datearr[5] )
          . sprintf( "%0.2d", ( $datearr[4] + 1 ) )
          . sprintf( "%0.2d", $datearr[3] );
        my $datedue = $data->{'date_due'};
        $datedue =~ s/-//g;
        if ( $datedue < $todaysdate ) {
            $data->{'overdue'} = 1;
        }
        my $itemnumber = $data->{'itemnumber'};

        # FIXME - Consecutive integers as hash keys? You have GOT to
        # be kidding me! Use an array, fercrissakes!
        $currentissues{$counter} = $data;
        $counter++;
    }
    $sth->finish;
    return ( \%currentissues );
}

=head2 getissues

$issues = &getissues($borrowernumber);

Returns the set of books currently on loan to a patron.

C<$borrowernumber> is the patron's borrower number.

C<&getissues> returns a PHP-style array: C<$issues> is a
reference-to-hash whose keys are integers in the range 0..I<n>-1,
where I<n> is the number of books the patron currently has on loan.

The values of C<$issues> are references-to-hash whose keys are
selected fields from the issues, items, biblio, and biblioitems tables
of the Koha database.

=cut

#'
sub getissues {

    # New subroutine for Circ2.pm
    my ($borrower)     = @_;
    my $dbh            = C4::Context->dbh;
    my $borrowernumber = $borrower->{'borrowernumber'};
    my %currentissues;
    my $select = "
        SELECT  items.*,
                issues.timestamp           AS timestamp,
                issues.date_due            AS date_due,
                items.barcode              AS barcode,
                biblio.title               AS title,
                biblio.author              AS author,
                biblioitems.dewey          AS dewey,
                itemtypes.description      AS itemtype,
                biblioitems.subclass       AS subclass,
                biblioitems.ccode          AS ccode,
                biblioitems.isbn           AS isbn,
                biblioitems.classification AS classification
        FROM    items
            LEFT JOIN issues ON issues.itemnumber = items.itemnumber
            LEFT JOIN biblio ON biblio.biblionumber = items.biblionumber
            LEFT JOIN biblioitems ON items.biblioitemnumber = biblioitems.biblioitemnumber
            LEFT JOIN itemtypes ON itemtypes.itemtype     = biblioitems.itemtype
        WHERE   issues.borrowernumber  = ?
            AND issues.returndate IS NULL
        ORDER BY issues.date_due DESC
    ";
    my $sth = $dbh->prepare($select);
    $sth->execute($borrowernumber);
    my $counter = 0;

    while ( my $data = $sth->fetchrow_hashref ) {
        $data->{'dewey'} =~ s/0*$//;
        ( $data->{'dewey'} == 0 ) && ( $data->{'dewey'} = '' );

        # FIXME - The Dewey code is a string, not a number.
        # FIXME - Use POSIX::strftime to get a text version of today's
        # date. That's what it's for.
        # FIXME - Move the date calculation outside of the loop.
        my @datearr    = localtime( time() );
        my $todaysdate =
            ( 1900 + $datearr[5] )
          . sprintf( "%0.2d", ( $datearr[4] + 1 ) )
          . sprintf( "%0.2d", $datearr[3] );

        # FIXME - Instead of converting the due date to YYYYMMDD, just
        # use
        #    $todaysdate = POSIX::strftime("%Y-%m-%d", localtime);
        #    ...
        #    if ($date->{date_due} lt $todaysdate)
        my $datedue = $data->{'date_due'};
        $datedue =~ s/-//g;
        if ( $datedue < $todaysdate ) {
            $data->{'overdue'} = 1;
        }
        $currentissues{$counter} = $data;
        $counter++;

        # FIXME - This is ludicrous. If you want to return an
        # array of values, just use an array. That's what
        # they're there for.
    }
    $sth->finish;
    return ( \%currentissues );
}

=head2 GetIssuesFromBiblio

$issues = GetIssuesFromBiblio($biblionumber);

this function get all issues from a biblionumber.

Return:
C<$issues> is a reference to array which each value is ref-to-hash. This ref-to-hash containts all column from
tables issues and the firstname,surname & cardnumber from borrowers.

=cut

sub GetIssuesFromBiblio {
    my $biblionumber = shift;
    return undef unless $biblionumber;
    my $dbh   = C4::Context->dbh;
    my $query = "
        SELECT issues.*,biblio.biblionumber,biblio.title, biblio.author,borrowers.cardnumber,borrowers.surname,borrowers.firstname
        FROM issues
            LEFT JOIN borrowers ON borrowers.borrowernumber = issues.borrowernumber
            LEFT JOIN items ON issues.itemnumber = items.itemnumber
            LEFT JOIN biblioitems ON items.itemnumber = biblioitems.biblioitemnumber
            LEFT JOIN biblio ON biblio.biblionumber = items.biblioitemnumber
        WHERE biblio.biblionumber = ?
        ORDER BY issues.timestamp
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute($biblionumber);

    my @issues;
    while ( my $data = $sth->fetchrow_hashref ) {
        push @issues, $data;
    }
    return \@issues;
}

=head2 renewstatus

$ok = &renewstatus($env, $dbh, $borrowernumber, $itemnumber);

Find out whether a borrowed item may be renewed.

C<$env> is ignored.

C<$dbh> is a DBI handle to the Koha database.

C<$borrowernumber> is the borrower number of the patron who currently
has the item on loan.

C<$itemnumber> is the number of the item to renew.

C<$renewstatus> returns a true value iff the item may be renewed. The
item must currently be on loan to the specified borrower; renewals
must be allowed for the item's type; and the borrower must not have
already renewed the loan.

=cut

sub renewstatus {

    # check renewal status
    my ( $env, $borrowernumber, $itemno ) = @_;
    my $dbh       = C4::Context->dbh;
    my $renews    = 1;
    my $renewokay = 0;

    # Look in the issues table for this item, lent to this borrower,
    # and not yet returned.

    # FIXME - I think this function could be redone to use only one SQL call.
    my $sth1 = $dbh->prepare(
        "select * from issues
                                where (borrowernumber = ?)
                                and (itemnumber = ?)
                                and returndate is null"
    );
    $sth1->execute( $borrowernumber, $itemno );
    if ( my $data1 = $sth1->fetchrow_hashref ) {

        # Found a matching item

        # See if this item may be renewed. This query is convoluted
        # because it's a bit messy: given the item number, we need to find
        # the biblioitem, which gives us the itemtype, which tells us
        # whether it may be renewed.
        my $sth2 = $dbh->prepare(
            "SELECT renewalsallowed from items,biblioitems,itemtypes
        where (items.itemnumber = ?)
        and (items.biblioitemnumber = biblioitems.biblioitemnumber)
        and (biblioitems.itemtype = itemtypes.itemtype)"
        );
        $sth2->execute($itemno);
        if ( my $data2 = $sth2->fetchrow_hashref ) {
            $renews = $data2->{'renewalsallowed'};
        }
        if ( $renews && $renews > $data1->{'renewals'} ) {
            $renewokay = 1;
        }
        $sth2->finish;
        my ( $resfound, $resrec ) = CheckReserves($itemno);
        if ($resfound) {
            $renewokay = 0;
        }
        ( $resfound, $resrec ) = CheckReserves($itemno);
        if ($resfound) {
            $renewokay = 0;
        }

    }
    $sth1->finish;
    return ($renewokay);
}

=head2 renewbook

&renewbook($env, $borrowernumber, $itemnumber, $datedue);

Renews a loan.

C<$env-E<gt>{branchcode}> is the code of the branch where the
renewal is taking place.

C<$env-E<gt>{usercode}> is the value to log in C<statistics.usercode>
in the Koha database.

C<$borrowernumber> is the borrower number of the patron who currently
has the item.

C<$itemnumber> is the number of the item to renew.

C<$datedue> can be used to set the due date. If C<$datedue> is the
empty string, C<&renewbook> will calculate the due date automatically
from the book's item type. If you wish to set the due date manually,
C<$datedue> should be in the form YYYY-MM-DD.

=cut

sub renewbook {

    # mark book as renewed
    my ( $env, $borrowernumber, $itemno, $datedue ) = @_;
    my $dbh = C4::Context->dbh;

    # If the due date wasn't specified, calculate it by adding the
    # book's loan length to today's date.
    if ( $datedue eq "" ) {

        #debug_msg($env, "getting date");
        my $iteminformation = getiteminformation( $itemno, 0 );
        my $borrower = getpatroninformation( $env, $borrowernumber, 0 );
        my $loanlength = getLoanLength(
            $borrower->{'categorycode'},
            $iteminformation->{'itemtype'},
            $borrower->{'branchcode'}
        );
        my ( $due_year, $due_month, $due_day ) =
          Add_Delta_DHMS( Today_and_Now(), $loanlength, 0, 0, 0 );
        $datedue = "$due_year-$due_month-$due_day";

        #$datedue = UnixDate(DateCalc("today","$loanlength days"),"%Y-%m-%d");
    }

    # Find the issues record for this book
    my $sth =
      $dbh->prepare(
"select * from issues where borrowernumber=? and itemnumber=? and returndate is null"
      );
    $sth->execute( $borrowernumber, $itemno );
    my $issuedata = $sth->fetchrow_hashref;
    $sth->finish;

    # Update the issues record to have the new due date, and a new count
    # of how many times it has been renewed.
    my $renews = $issuedata->{'renewals'} + 1;
    $sth = $dbh->prepare(
        "update issues set date_due = ?, renewals = ?
        where borrowernumber=? and itemnumber=? and returndate is null"
    );
    $sth->execute( $datedue, $renews, $borrowernumber, $itemno );
    $sth->finish;

    # Log the renewal
    UpdateStats( $env, $env->{'branchcode'}, 'renew', '', '', $itemno );

    # Charge a new rental fee, if applicable?
    my ( $charge, $type ) = calc_charges( $env, $itemno, $borrowernumber );
    if ( $charge > 0 ) {
        my $accountno = getnextacctno( $env, $borrowernumber, $dbh );
        my $item = getiteminformation($itemno);
        $sth = $dbh->prepare(
"Insert into accountlines (borrowernumber,accountno,date,amount,description,accounttype,amountoutstanding,itemnumber)
                            values (?,?,now(),?,?,?,?,?)"
        );
        $sth->execute( $borrowernumber, $accountno, $charge,
            "Renewal of Rental Item $item->{'title'} $item->{'barcode'}",
            'Rent', $charge, $itemno );
        $sth->finish;
    }

    #  return();
}

=head2 calc_charges

($charge, $item_type) = &calc_charges($env, $itemnumber, $borrowernumber);

Calculate how much it would cost for a given patron to borrow a given
item, including any applicable discounts.

C<$env> is ignored.

C<$itemnumber> is the item number of item the patron wishes to borrow.

C<$borrowernumber> is the patron's borrower number.

C<&calc_charges> returns two values: C<$charge> is the rental charge,
and C<$item_type> is the code for the item's item type (e.g., C<VID>
if it's a video).

=cut

sub calc_charges {

    # calculate charges due
    my ( $env, $itemno, $borrowernumber ) = @_;
    my $charge = 0;
    my $dbh    = C4::Context->dbh;
    my $item_type;

    # Get the book's item type and rental charge (via its biblioitem).
    my $sth1 = $dbh->prepare(
        "select itemtypes.itemtype,rentalcharge from items,biblioitems,itemtypes
                                where (items.itemnumber =?)
                                and (biblioitems.biblioitemnumber = items.biblioitemnumber)
                                and (biblioitems.itemtype = itemtypes.itemtype)"
    );
    $sth1->execute($itemno);
    if ( my $data1 = $sth1->fetchrow_hashref ) {
        $item_type = $data1->{'itemtype'};
        $charge    = $data1->{'rentalcharge'};
        my $q2 = "select rentaldiscount from issuingrules,borrowers
            where (borrowers.borrowernumber = ?)
            and (borrowers.categorycode = issuingrules.categorycode)
            and (issuingrules.itemtype = ?)";
        my $sth2 = $dbh->prepare($q2);
        $sth2->execute( $borrowernumber, $item_type );
        if ( my $data2 = $sth2->fetchrow_hashref ) {
            my $discount = $data2->{'rentaldiscount'};
            if ( $discount eq 'NULL' ) {
                $discount = 0;
            }
            $charge = ( $charge * ( 100 - $discount ) ) / 100;
        }
        $sth2->finish;
    }

    $sth1->finish;
    return ( $charge, $item_type );
}

=head2 createcharge

&createcharge( $env, $dbh, $itemno, $borrowernumber, $charge )

=cut

# FIXME - A virtually identical function appears in
# C4::Circulation::Issues. Pick one and stick with it.
sub createcharge {

    #Stolen from Issues.pm
    my ( $env, $dbh, $itemno, $borrowernumber, $charge ) = @_;
    my $nextaccntno = getnextacctno( $env, $borrowernumber, $dbh );
    my $query ="
        INSERT INTO accountlines
            (borrowernumber, itemnumber, accountno,
            date, amount, description, accounttype,
            amountoutstanding)
        VALUES (?, ?, ?,now(), ?, 'Rental', 'Rent',?)
    ";
    my $sth         = $dbh->prepare($query);
    $sth->execute( $borrowernumber, $itemno, $nextaccntno, $charge, $charge );
    $sth->finish;
}

=head2 find_reserves

($status, $record) = &find_reserves($itemnumber);

Looks up an item in the reserves.

C<$itemnumber> is the itemnumber to look up.

C<$status> is true iff the search was successful.

C<$record> is a reference-to-hash describing the reserve. Its keys are
the fields from the reserves table of the Koha database.

=cut

#'
# FIXME - This API is bogus: just return the record, or undef if none
# was found.
# FIXME - There's also a &C4::Circulation::Returns::find_reserves, but
# that one looks rather different.
sub find_reserves {

    # Stolen from Returns.pm
    warn "!!!!! SHOULD NOT BE HERE : Circ2::find_reserves is deprecated !!!";
    my ($itemno) = @_;
    my %env;
    my $dbh = C4::Context->dbh;
    my ($itemdata) = getiteminformation( $itemno, 0 );
    my $bibno  = $dbh->quote( $itemdata->{'biblionumber'} );
    my $bibitm = $dbh->quote( $itemdata->{'biblioitemnumber'} );
    my $sth    =
      $dbh->prepare(
"select * from reserves where ((found = 'W') or (found is null)) and biblionumber = ? and cancellationdate is NULL order by priority, reservedate"
      );
    $sth->execute($bibno);
    my $resfound = 0;
    my $resrec;
    my $lastrec;

    # print $query;

    # FIXME - I'm not really sure what's going on here, but since we
    # only want one result, wouldn't it be possible (and far more
    # efficient) to do something clever in SQL that only returns one
    # set of values?
    while ( ( $resrec = $sth->fetchrow_hashref ) && ( not $resfound ) ) {

        # FIXME - Unlike Pascal, Perl allows you to exit loops
        # early. Take out the "&& (not $resfound)" and just
        # use "last" at the appropriate point in the loop.
        # (Oh, and just in passing: if you'd used "!" instead
        # of "not", you wouldn't have needed the parentheses.)
        $lastrec = $resrec;
        my $brn   = $dbh->quote( $resrec->{'borrowernumber'} );
        my $rdate = $dbh->quote( $resrec->{'reservedate'} );
        my $bibno = $dbh->quote( $resrec->{'biblionumber'} );
        if ( $resrec->{'found'} eq "W" ) {
            if ( $resrec->{'itemnumber'} eq $itemno ) {
                $resfound = 1;
            }
        }
        else {
            # FIXME - Use 'elsif' to avoid unnecessary indentation.
            if ( $resrec->{'constrainttype'} eq "a" ) {
                $resfound = 1;
            }
            else {
                my $consth =
                  $dbh->prepare(
                        "SELECT * FROM reserveconstraints
                         WHERE borrowernumber = ?
                           AND reservedate = ?
                           AND biblionumber = ?
                           AND biblioitemnumber = ?"
                  );
                $consth->execute( $brn, $rdate, $bibno, $bibitm );
                if ( my $conrec = $consth->fetchrow_hashref ) {
                    if ( $resrec->{'constrainttype'} eq "o" ) {
                        $resfound = 1;
                    }
                }
                $consth->finish;
            }
        }
        if ($resfound) {
            my $updsth =
              $dbh->prepare(
                "UPDATE reserves
                 SET found = 'W',
                     itemnumber = ?
                 WHERE borrowernumber = ?
                   AND reservedate = ?
                   AND biblionumber = ?"
              );
            $updsth->execute( $itemno, $brn, $rdate, $bibno );
            $updsth->finish;

            # FIXME - "last;" here to break out of the loop early.
        }
    }
    $sth->finish;
    return ( $resfound, $lastrec );
}

=head2 fixdate

( $date, $invalidduedate ) = fixdate( $year, $month, $day );

=cut

sub fixdate {
    my ( $year, $month, $day ) = @_;
    my $invalidduedate;
    my $date;
    if ( $year && $month && $day ) {
        if ( ( $year eq 0 ) && ( $month eq 0 ) && ( $year eq 0 ) ) {

            #    $env{'datedue'}='';
        }
        else {
            if ( ( $year eq 0 ) || ( $month eq 0 ) || ( $year eq 0 ) ) {
                $invalidduedate = 1;
            }
            else {
                if (
                    ( $day > 30 )
                    && (   ( $month == 4 )
                        || ( $month == 6 )
                        || ( $month == 9 )
                        || ( $month == 11 ) )
                  )
                {
                    $invalidduedate = 1;
                }
                elsif ( ( $day > 29 ) && ( $month == 2 ) ) {
                    $invalidduedate = 1;
                }
                elsif (
                       ( $month == 2 )
                    && ( $day > 28 )
                    && (   ( $year % 4 )
                        && ( ( !( $year % 100 ) || ( $year % 400 ) ) ) )
                  )
                {
                    $invalidduedate = 1;
                }
                else {
                    $date = "$year-$month-$day";
                }
            }
        }
    }
    return ( $date, $invalidduedate );
}

=head2 get_current_return_date_of

&get_current_return_date_of(@itemnumber);

=cut

sub get_current_return_date_of {
    my (@itemnumbers) = @_;
    my $query = '
        SELECT
            date_due,
            itemnumber
        FROM issues
        WHERE itemnumber IN (' . join( ',', @itemnumbers ) . ')
        AND returndate IS NULL
    ';
    return get_infos_of( $query, 'itemnumber', 'date_due' );
}

=head2 get_transfert_infos

get_transfert_infos($itemnumber);

=cut

sub get_transfert_infos {
    my ($itemnumber) = @_;

    my $dbh = C4::Context->dbh;

    my $query = '
        SELECT datesent,
               frombranch,
               tobranch
        FROM branchtransfers
        WHERE itemnumber = ?
          AND datearrived IS NULL
        ';
    my $sth = $dbh->prepare($query);
    $sth->execute($itemnumber);
    my @row = $sth->fetchrow_array();
    $sth->finish;
    return @row;
}

=head2 DeleteTransfer

&DeleteTransfer($itemnumber);

=cut

sub DeleteTransfer {
    my ($itemnumber) = @_;
    my $dbh          = C4::Context->dbh;
    my $sth          = $dbh->prepare(
        "DELETE FROM branchtransfers
         WHERE itemnumber=?
         AND datearrived IS NULL "
    );
    $sth->execute($itemnumber);
    $sth->finish;
}

=head2 GetTransfersFromBib

@results = GetTransfersFromBib($frombranch,$tobranch);

=cut

sub GetTransfersFromBib {
    my ( $frombranch, $tobranch ) = @_;
    return unless ( $frombranch && $tobranch );
    my $dbh   = C4::Context->dbh;
    my $query = "
        SELECT itemnumber,datesent,frombranch
        FROM   branchtransfers
        WHERE  frombranch=?
          AND  tobranch=?
          AND datearrived IS NULL
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute( $frombranch, $tobranch );
    my @gettransfers;
    my $i = 0;

    while ( my $data = $sth->fetchrow_hashref ) {
        $gettransfers[$i] = $data;
        $i++;
    }
    $sth->finish;
    return (@gettransfers);
}

=head2 GetReservesToBranch

@transreserv = GetReservesToBranch( $frombranch, $default );

=cut

sub GetReservesToBranch {
    my ( $frombranch, $default ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
        "SELECT borrowernumber,reservedate,itemnumber,timestamp
         FROM reserves 
         WHERE priority='0' AND cancellationdate is null  
           AND branchcode=?
           AND branchcode!=?
           AND found IS NULL "
    );
    $sth->execute( $frombranch, $default );
    my @transreserv;
    my $i = 0;
    while ( my $data = $sth->fetchrow_hashref ) {
        $transreserv[$i] = $data;
        $i++;
    }
    $sth->finish;
    return (@transreserv);
}

=head2 GetReservesForBranch

@transreserv = GetReservesForBranch($frombranch);

=cut

sub GetReservesForBranch {
    my ($frombranch) = @_;
    my $dbh          = C4::Context->dbh;
    my $sth          = $dbh->prepare( "
        SELECT borrowernumber,reservedate,itemnumber,waitingdate
        FROM   reserves 
        WHERE   priority='0'
            AND cancellationdate IS NULL 
            AND found='W' 
            AND branchcode=?
        ORDER BY waitingdate" );
    $sth->execute($frombranch);
    my @transreserv;
    my $i = 0;
    while ( my $data = $sth->fetchrow_hashref ) {
        $transreserv[$i] = $data;
        $i++;
    }
    $sth->finish;
    return (@transreserv);
}

=head2 checktransferts

@tranferts = checktransferts($itemnumber);

=cut

sub checktransferts {
    my ($itemnumber) = @_;
    my $dbh          = C4::Context->dbh;
    my $sth          = $dbh->prepare(
        "SELECT datesent,frombranch,tobranch FROM branchtransfers
        WHERE itemnumber = ? AND datearrived IS NULL"
    );
    $sth->execute($itemnumber);
    my @tranferts = $sth->fetchrow_array;
    $sth->finish;

    return (@tranferts);
}

=head2 CheckItemNotify

Sql request to check if the document has alreday been notified
this function is not exported, only used with GetOverduesForBranch

=cut

sub CheckItemNotify {
	my ($notify_id,$notify_level,$itemnumber) = @_;
	my $dbh = C4::Context->dbh;
 	my $sth = $dbh->prepare("
	  SELECT COUNT(*) FROM notifys
 WHERE notify_id  = ?
 AND notify_level  = ? 
  AND  itemnumber  =  ? ");
 $sth->execute($notify_id,$notify_level,$itemnumber);
	my $notified = $sth->fetchrow;
$sth->finish;
return ($notified);
}

=head2 GetOverduesForBranch

Sql request for display all information for branchoverdues.pl
2 possibilities : with or without department .
display is filtered by branch

=cut

sub GetOverduesForBranch {
    my ( $branch, $department) = @_;
    if ( not $department ) {
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("
            SELECT 
                borrowers.surname,
                borrowers.firstname,
                biblio.title,
                itemtypes.description,
                issues.date_due,
                issues.returndate,
                branches.branchname,
                items.barcode,
                borrowers.phone,
                borrowers.email,
                items.itemcallnumber,
                borrowers.borrowernumber,
                items.itemnumber,
                biblio.biblionumber,
                issues.branchcode,
                accountlines.notify_id,
                accountlines.notify_level,
                items.location,
                accountlines.amountoutstanding
            FROM  issues,borrowers,biblio,biblioitems,itemtypes,items,branches,accountlines
            WHERE ( issues.returndate  is null)
              AND ( accountlines.amountoutstanding  != '0.000000')
              AND ( accountlines.accounttype  = 'FU')
              AND ( issues.borrowernumber = accountlines.borrowernumber )
              AND ( issues.itemnumber = accountlines.itemnumber )
              AND ( borrowers.borrowernumber = issues.borrowernumber )
              AND ( biblio.biblionumber = biblioitems.biblionumber )
              AND ( biblioitems.biblionumber = items.biblionumber )
              AND ( itemtypes.itemtype = biblioitems.itemtype )
              AND ( items.itemnumber = issues.itemnumber )
              AND ( branches.branchcode = issues.branchcode )
              AND (issues.branchcode = ?)
              AND (issues.date_due <= NOW())
            ORDER BY  borrowers.surname
        ");
	$sth->execute($branch);
        my @getoverdues;
        my $i = 0;
        while ( my $data = $sth->fetchrow_hashref ) {
	#check if the document has already been notified
	my $countnotify = CheckItemNotify($data->{'notify_id'},$data->{'notify_level'},$data->{'itemnumber'});
	if ($countnotify eq '0'){
            $getoverdues[$i] = $data;
            $i++;
	 }
        }
        return (@getoverdues);
	$sth->finish;
    }
    else {
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare( "
            SELECT  borrowers.surname,
                    borrowers.firstname,
                    biblio.title,
                    itemtypes.description,
                    issues.date_due,
                    issues.returndate,
                    branches.branchname,
                    items.barcode,
                    borrowers.phone,
                    borrowers.email,
                    items.itemcallnumber,
                    borrowers.borrowernumber,
                    items.itemnumber,
                    biblio.biblionumber,
                    issues.branchcode,
                    accountlines.notify_id,
                    accountlines.notify_level,
                    items.location,
                    accountlines.amountoutstanding
           FROM  issues,borrowers,biblio,biblioitems,itemtypes,items,branches,accountlines
           WHERE ( issues.returndate  is null )
             AND ( accountlines.amountoutstanding  != '0.000000')
             AND ( accountlines.accounttype  = 'FU')
             AND ( issues.borrowernumber = accountlines.borrowernumber )
             AND ( issues.itemnumber = accountlines.itemnumber )
             AND ( borrowers.borrowernumber = issues.borrowernumber )
             AND ( biblio.biblionumber = biblioitems.biblionumber )
             AND ( biblioitems.biblionumber = items.biblionumber )
             AND ( itemtypes.itemtype = biblioitems.itemtype )
             AND ( items.itemnumber = issues.itemnumber )
             AND ( branches.branchcode = issues.branchcode )
             AND (issues.branchcode = ? AND items.location = ?)
             AND (issues.date_due <= NOW())
           ORDER BY  borrowers.surname
        " );
        $sth->execute( $branch, $department);
        my @getoverdues;
	my $i = 0;
        while ( my $data = $sth->fetchrow_hashref ) {
	#check if the document has already been notified
	  my $countnotify = CheckItemNotify($data->{'notify_id'},$data->{'notify_level'},$data->{'itemnumber'});
	  if ($countnotify eq '0'){	                
		$getoverdues[$i] = $data;
		 $i++;
	 }
        }
        $sth->finish;
        return (@getoverdues); 
    }
}


=head2 AddNotifyLine

&AddNotifyLine($borrowernumber, $itemnumber, $overduelevel, $method, $notifyId)

Creat a line into notify, if the method is phone, the notification_send_date is implemented to

=cut

sub AddNotifyLine {
    my ( $borrowernumber, $itemnumber, $overduelevel, $method, $notifyId ) = @_;
    if ( $method eq "phone" ) {
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare(
            "INSERT INTO notifys (borrowernumber,itemnumber,notify_date,notify_send_date,notify_level,method,notify_id)
        VALUES (?,?,now(),now(),?,?,?)"
        );
        $sth->execute( $borrowernumber, $itemnumber, $overduelevel, $method,
            $notifyId );
        $sth->finish;
    }
    else {
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare(
            "INSERT INTO notifys (borrowernumber,itemnumber,notify_date,notify_level,method,notify_id)
        VALUES (?,?,now(),?,?,?)"
        );
        $sth->execute( $borrowernumber, $itemnumber, $overduelevel, $method,
            $notifyId );
        $sth->finish;
    }
    return 1;
}

=head2 RemoveNotifyLine

&RemoveNotifyLine( $borrowernumber, $itemnumber, $notify_date );

Cancel a notification

=cut

sub RemoveNotifyLine {
    my ( $borrowernumber, $itemnumber, $notify_date ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
        "DELETE FROM notifys 
            WHERE
            borrowernumber=?
            AND itemnumber=?
            AND notify_date=?"
    );
    $sth->execute( $borrowernumber, $itemnumber, $notify_date );
    $sth->finish;
    return 1;
}

=head2 AnonymiseIssueHistory

$rows = AnonymiseIssueHistory($borrowernumber,$date)

This function write NULL instead of C<$borrowernumber> given on input arg into the table issues.
if C<$borrowernumber> is not set, it will delete the issue history for all borrower older than C<$date>.

return the number of affected rows.

=cut

sub AnonymiseIssueHistory {
    my $date           = shift;
    my $borrowernumber = shift;
    my $dbh            = C4::Context->dbh;
    my $query          = "
        UPDATE issues
        SET    borrowernumber = NULL
        WHERE  returndate < '".$date."'
          AND borrowernumber IS NOT NULL
    ";
    $query .= " AND borrowernumber = '".$borrowernumber."'" if defined $borrowernumber;
    my $rows_affected = $dbh->do($query);
    return $rows_affected;
}

=head2 GetItemsLost

$items = GetItemsLost($where,$orderby);

This function get the items lost into C<$items>.

=over 2

=item input:
C<$where> is a hashref. it containts a field of the items table as key
and the value to match as value.
C<$orderby> is a field of the items table.

=item return:
C<$items> is a reference to an array full of hasref which keys are items' table column.

=item usage in the perl script:

my %where;
$where{barcode} = 0001548;
my $items = GetLostItems( \%where, "homebranch" );
$template->param(itemsloop => $items);

=back

=cut

sub GetLostItems {
    # Getting input args.
    my $where   = shift;
    my $orderby = shift;
    my $dbh     = C4::Context->dbh;

    my $query   = "
        SELECT *
        FROM   items
        WHERE  itemlost IS NOT NULL
          AND  itemlost <> 0
    ";
    foreach my $key (keys %$where) {
        $query .= " AND " . $key . " LIKE '%" . $where->{$key} . "%'";
    }
    $query .= " ORDER BY ".$orderby if defined $orderby;

    my $sth = $dbh->prepare($query);
    $sth->execute;
    my @items;
    while ( my $row = $sth->fetchrow_hashref ){
        push @items, $row;
    }
    return \@items;
}

=head2 updateWrongTransfer

$items = updateWrongTransfer($itemNumber,$borrowernumber,$waitingAtLibrary,$FromLibrary);

This function validate the line of brachtransfer but with the wrong destination (mistake from a librarian ...), and create a new line in branchtransfer from the actual library to the original library of reservation 

=cut

sub updateWrongTransfer {
	my ( $itemNumber,$waitingAtLibrary,$FromLibrary ) = @_;
	my $dbh = C4::Context->dbh;	
# first step validate the actual line of transfert .
	my $sth =
        	$dbh->prepare(
			"update branchtransfers set datearrived = now(),tobranch=?,comments='wrongtransfer' where itemnumber= ? AND datearrived IS NULL"
          	);
        	$sth->execute($FromLibrary,$itemNumber);
        	$sth->finish;

# second step create a new line of branchtransfer to the right location .
	dotransfer($itemNumber, $FromLibrary, $waitingAtLibrary);

#third step changing holdingbranch of item
	UpdateHoldingbranch($FromLibrary,$itemNumber);
}

=head2 UpdateHoldingbranch

$items = UpdateHoldingbranch($branch,$itmenumber);
Simple methode for updating hodlingbranch in items BDD line
=cut

sub UpdateHoldingbranch {
	my ( $branch,$itmenumber ) = @_;
	my $dbh = C4::Context->dbh;	
# first step validate the actual line of transfert .
	my $sth =
        	$dbh->prepare(
			"update items set holdingbranch = ? where itemnumber= ?"
          	);
        	$sth->execute($branch,$itmenumber);
        	$sth->finish;
        
	
}

1;

__END__

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut

