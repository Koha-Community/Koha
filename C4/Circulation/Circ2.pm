# -*- tab-width: 8 -*-
# Please use 8-character tabs for this file (indents are every 4 characters)

package C4::Circulation::Circ2;

# $Id$

#package to deal with Returns
#written 3/11/99 by olwen@katipo.co.nz


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
# use warnings;
require Exporter;
use DBI;
use C4::Context;
use C4::Stats;
use C4::Reserves2;
use C4::Koha;
use C4::Accounts;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Circulation::Circ2 - Koha circulation module

=head1 SYNOPSIS

  use C4::Circulation::Circ2;

=head1 DESCRIPTION

The functions in this module deal with circulation, issues, and
returns, as well as general information about the library.
Also deals with stocktaking.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&getpatroninformation
	&currentissues &getissues &getiteminformation &renewstatus
	&canbookbeissued &issuebook &returnbook &find_reserves &transferbook &decode
	&calc_charges &listitemsforinventory &itemseen &fixdate);

# &getbranches &getprinters &getbranch &getprinter => moved to C4::Koha.pm

=head2 itemseen

&itemseen($itemnum)
Mark item as seen. Is called when an item is issued, returned or manually marked during inventory/stocktaking
C<$itemnum> is the item number

=cut

sub itemseen {
	my ($itemnum) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("update items set itemlost=0, datelastseen  = now() where items.itemnumber = ?");
	$sth->execute($itemnum);
	return;
}

sub listitemsforinventory {
	my ($minlocation,$maxlocation,$datelastseen,$offset,$size) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("select itemnumber,barcode,itemcallnumber,title,author from items,biblio where items.biblionumber=biblio.biblionumber and itemcallnumber>= ? and itemcallnumber <=? and (datelastseen< ? or datelastseen is null) order by itemcallnumber,title");
	$sth->execute($minlocation,$maxlocation,$datelastseen);
	my @results;
	while (my $row = $sth->fetchrow_hashref) {
		$offset-- if ($offset);
		if ((!$offset) && $size) {
			push @results,$row;
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

Shows the patron's credit or debt, if any.

=back

=head3 GNA

=over 4

(Gone, no address.) Set if the patron has left without giving a
forwarding address.

=back

=head3 LOST

=over 4

Set if the patron's card has been reported as lost.

=back

=head3 DBARRED

=over 4

Set if the patron has been debarred.

=back

=head3 NOTES

=over 4

Any additional notes about the patron.

=back

=head3 ODUES

=over 4

Set if the patron has overdue items. This flag has several keys:

C<$flags-E<gt>{ODUES}{itemlist}> is a reference-to-array listing the
overdue items. Its elements are references-to-hash, each describing an
overdue item. The keys are selected fields from the issues, biblio,
biblioitems, and items tables of the Koha database.

C<$flags-E<gt>{ODUES}{itemlist}> is a string giving a text listing of
the overdue items, one per line.

=back

=head3 WAITING

=over 4

Set if any items that the patron has reserved are available.

C<$flags-E<gt>{WAITING}{itemlist}> is a reference-to-array listing the
available items. Each element is a reference-to-hash whose keys are
fields from the reserves table of the Koha database.

=back

=back

=cut


sub getpatroninformation {
# returns
	my ($env, $borrowernumber,$cardnumber) = @_;
	my $dbh = C4::Context->dbh;
	my $query;
	my $sth;
	if ($borrowernumber) {
		$sth = $dbh->prepare("select * from borrowers where borrowernumber=?");
		$sth->execute($borrowernumber);
	} elsif ($cardnumber) {
		$sth = $dbh->prepare("select * from borrowers where cardnumber=?");
		$sth->execute($cardnumber);
	} else {
		$env->{'apierror'} = "invalid borrower information passed to getpatroninformation subroutine";
		return();
	}
	my $borrower = $sth->fetchrow_hashref;
	my $amount = checkaccount($env, $borrowernumber, $dbh);
	$borrower->{'amountoutstanding'} = $amount;
	my $flags = patronflags($env, $borrower, $dbh);
	my $accessflagshash;
 
	$sth=$dbh->prepare("select bit,flag from userflags");
	$sth->execute;
	while (my ($bit, $flag) = $sth->fetchrow) {
		if ($borrower->{'flags'} & 2**$bit) {
		$accessflagshash->{$flag}=1;
		}
	}
	$sth->finish;
	$borrower->{'flags'}=$flags;
	$borrower->{'authflags'} = $accessflagshash;
	return ($borrower); #, $flags, $accessflagshash);
}

=head2 decode

=over 4

=head3 $str = &decode($chunk);

=over 4

Decodes a segment of a string emitted by a CueCat barcode scanner and
returns it.

=back

=back

=cut

# FIXME - At least, I'm pretty sure this is for decoding CueCat stuff.
sub decode {
	my ($encoded) = @_;
	my $seq = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+-';
	my @s = map { index($seq,$_); } split(//,$encoded);
	my $l = ($#s+1) % 4;
	if ($l)
	{
		if ($l == 1)
		{
			print "Error!";
			return;
		}
		$l = 4-$l;
		$#s += $l;
	}
	my $r = '';
	while ($#s >= 0)
	{
		my $n = (($s[0] << 6 | $s[1]) << 6 | $s[2]) << 6 | $s[3];
		$r .=chr(($n >> 16) ^ 67) .
		chr(($n >> 8 & 255) ^ 67) .
		chr(($n & 255) ^ 67);
		@s = @s[4..$#s];
	}
	$r = substr($r,0,length($r)-$l);
	return $r;
}

=head2 getiteminformation

=over 4

$item = &getiteminformation($env, $itemnumber, $barcode);

Looks up information about an item, given either its item number or
its barcode. If C<$itemnumber> is a nonzero value, it is used;
otherwise, C<$barcode> is used.

C<$env> is effectively ignored, but should be a reference-to-hash.

C<$item> is a reference-to-hash whose keys are fields from the biblio,
items, and biblioitems tables of the Koha database. It may also
contain the following keys:

=head3 date_due

=over 4

The due date on this item, if it has been borrowed and not returned
yet. The date is in YYYY-MM-DD format.

=back

=head3 notforloan

=over 4

True if the item may not be borrowed.

=back

=back

=cut


sub getiteminformation {
# returns a hash of item information given either the itemnumber or the barcode
	my ($env, $itemnumber, $barcode) = @_;
	my $dbh = C4::Context->dbh;
	my $sth;
	if ($itemnumber) {
		$sth=$dbh->prepare("select * from biblio,items,biblioitems where items.itemnumber=? and biblio.biblionumber=items.biblionumber and biblioitems.biblioitemnumber = items.biblioitemnumber");
		$sth->execute($itemnumber);
	} elsif ($barcode) {
		$sth=$dbh->prepare("select * from biblio,items,biblioitems where items.barcode=? and biblio.biblionumber=items.biblionumber and biblioitems.biblioitemnumber = items.biblioitemnumber");
		$sth->execute($barcode);
	} else {
		$env->{'apierror'}="getiteminformation() subroutine must be called with either an itemnumber or a barcode";
		# Error condition.
		return();
	}
	my $iteminformation=$sth->fetchrow_hashref;
	$sth->finish;
	if ($iteminformation) {
		$sth=$dbh->prepare("select date_due from issues where itemnumber=? and isnull(returndate)");
		$sth->execute($iteminformation->{'itemnumber'});
		my ($date_due) = $sth->fetchrow;
		$iteminformation->{'date_due'}=$date_due;
		$sth->finish;
		($iteminformation->{'dewey'} == 0) && ($iteminformation->{'dewey'}='');
		$sth=$dbh->prepare("select * from itemtypes where itemtype=?");
		$sth->execute($iteminformation->{'itemtype'});
		my $itemtype=$sth->fetchrow_hashref;
		# if specific item notforloan, don't use itemtype notforloan field.
		# otherwise, use itemtype notforloan value to see if item can be issued.
		$iteminformation->{'notforloan'}=$itemtype->{'notforloan'} unless $iteminformation->{'notforloan'};
		$sth->finish;
	}
	return($iteminformation);
}

=head2 transferbook

=over 4

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

C<BadBarcode>

There is no item in the catalog with the given barcode. The value is C<$barcode>.

C<IsPermanent>

The item's home branch is permanent. This doesn't prevent the item from being transferred, though. The value is the code of the item's home branch.

C<DestinationEqualsHolding>

The item is already at the branch to which it is being transferred. The transfer is nonetheless considered to have failed. The value should be ignored.

C<WasReturned>

The item was on loan, and C<&transferbook> automatically returned it before transferring it. The value is the borrower number of the patron who had the item.

C<ResFound>

The item was reserved. The value is a reference-to-hash whose keys are fields from the reserves table of the Koha database, and C<biblioitemnumber>. It also has the key C<ResFound>, whose value is either C<Waiting> or C<Reserved>.

C<WasTransferred>

The item was eligible to be transferred. Barring problems communicating with the database, the transfer should indeed have succeeded. The value should be ignored.

=back

=back

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
# transfer book code....
	my ($tbr, $barcode, $ignoreRs) = @_;
	my $messages;
	my %env;
	my $dotransfer = 1;
	my $branches = getbranches();
	my $iteminformation = getiteminformation(\%env, 0, $barcode);
	# bad barcode..
	if (not $iteminformation) {
		$messages->{'BadBarcode'} = $barcode;
		$dotransfer = 0;
	}
	# get branches of book...
	my $hbr = $iteminformation->{'homebranch'};
	my $fbr = $iteminformation->{'holdingbranch'};
	# if is permanent...
	if ($branches->{$hbr}->{'PE'}) {
		$messages->{'IsPermanent'} = $hbr;
	}
	# can't transfer book if is already there....
	# FIXME - Why not? Shouldn't it trivially succeed?
	if ($fbr eq $tbr) {
		$messages->{'DestinationEqualsHolding'} = 1;
		$dotransfer = 0;
	}
	# check if it is still issued to someone, return it...
	my ($currentborrower) = currentborrower($iteminformation->{'itemnumber'});
	if ($currentborrower) {
		returnbook($barcode, $fbr);
		$messages->{'WasReturned'} = $currentborrower;
	}
	# find reserves.....
	# FIXME - Don't call &CheckReserves unless $ignoreRs is true.
	# That'll save a database query.
	my ($resfound, $resrec) = CheckReserves($iteminformation->{'itemnumber'});
	if ($resfound and not $ignoreRs) {
		$resrec->{'ResFound'} = $resfound;
		$messages->{'ResFound'} = $resrec;
		$dotransfer = 0;
	}
	#actually do the transfer....
	if ($dotransfer) {
		dotransfer($iteminformation->{'itemnumber'}, $fbr, $tbr);
		$messages->{'WasTransfered'} = 1;
	}
	return ($dotransfer, $messages, $iteminformation);
}

# Not exported
# FIXME - This is only used in &transferbook. Why bother making it a
# separate function?
sub dotransfer {
	my ($itm, $fbr, $tbr) = @_;
	my $dbh = C4::Context->dbh;
	$itm = $dbh->quote($itm);
	$fbr = $dbh->quote($fbr);
	$tbr = $dbh->quote($tbr);
	#new entry in branchtransfers....
	$dbh->do("INSERT INTO	branchtransfers (itemnumber, frombranch, datearrived, tobranch)
					VALUES ($itm, $fbr, now(), $tbr)");
	#update holdingbranch in items .....
	$dbh->do("UPDATE items set holdingbranch = $tbr WHERE	items.itemnumber = $itm");
	&itemseen($itm);
	return;
}

=head2 canbookbeissued

Check if a book can be issued.

my ($issuingimpossible,$needsconfirmation) = canbookbeissued($env,$borrower,$barcode,$year,$month,$day);

=over 4

C<$env> Environment variable. Should be empty usually, but used by other subs. Next code cleaning could drop it.

C<$borrower> hash with borrower informations (from getpatroninformation)

C<$barcode> is the bar code of the book being issued.

C<$year> C<$month> C<$day> contains the date of the return (in case it's forced by "stickyduedate".

=back

Returns :

=over 4

C<$issuingimpossible> a reference to a hash. It contains reasons why issuing is impossible.
Possible values are :

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

=back

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

sub TooMany ($$){
	my $borrower = shift;
	my $iteminformation = shift;
	my $cat_borrower = $borrower->{'categorycode'};
	my $branch_borrower = $borrower->{'branchcode'};
	my $dbh = C4::Context->dbh;
	

	my $sth = $dbh->prepare('select itemtype from biblioitems where biblionumber = ?');
	$sth->execute($iteminformation->{'biblionumber'});
	my $type = $sth->fetchrow;
	$sth = $dbh->prepare('select * from issuingrules where categorycode = ? and itemtype = ? and branchcode = ?');
	my $sth2 = $dbh->prepare("select COUNT(*) from issues i, biblioitems s where i.borrowernumber = ? and i.returndate is null and i.itemnumber = s.biblioitemnumber and s.itemtype like ?");
	my $sth3 = $dbh->prepare('select COUNT(*) from issues where borrowernumber = ? and returndate is null');
	my $alreadyissued;
	# check the 3 parameters
	$sth->execute($cat_borrower, $type, $branch_borrower);
	my $result = $sth->fetchrow_hashref;
# 	warn "==>".$result->{maxissueqty};
	if (defined($result)) {
		$sth2->execute($borrower->{'borrowernumber'}, "%$type%");
		my $alreadyissued = $sth2->fetchrow;
		return ("$alreadyissued / ".($result->{maxissueqty}+0)) if ($result->{'maxissueqty'} <= $alreadyissued);
	}
	# check for branch=*
	$sth->execute($cat_borrower, $type, "");
	my $result = $sth->fetchrow_hashref;
	if (defined($result)) {
		$sth2->execute($borrower->{'borrowernumber'}, "%$type%");
		my $alreadyissued = $sth2->fetchrow;
		return ("$alreadyissued / ".($result->{maxissueqty}+0)) if ($result->{'maxissueqty'} <= $alreadyissued);
	}
	# check for itemtype=*
	$sth->execute($cat_borrower, "*", $branch_borrower);
	my $result = $sth->fetchrow_hashref;
	if (defined($result)) {
		$sth3->execute($borrower->{'borrowernumber'});
		my $alreadyissued = $sth2->fetchrow;
		return ("$alreadyissued / ".($result->{maxissueqty}+0)) if ($result->{'maxissueqty'} <= $alreadyissued);
	}
	#check for borrowertype=*
	$sth->execute("*", $type, $branch_borrower);
	my $result = $sth->fetchrow_hashref;
	if (defined($result)) {
		$sth2->execute($borrower->{'borrowernumber'}, "%$type%");
		my $alreadyissued = $sth2->fetchrow;
		return ("$alreadyissued / ".($result->{maxissueqty}+0)) if ($result->{'maxissueqty'} <= $alreadyissued);
	}

	$sth->execute("*", "*", $branch_borrower);
	my $result = $sth->fetchrow_hashref;
	if (defined($result)) {
		$sth3->execute($borrower->{'borrowernumber'});
		my $alreadyissued = $sth2->fetchrow;
		return ("$alreadyissued / ".($result->{maxissueqty}+0)) if ($result->{'maxissueqty'} <= $alreadyissued);
	}

	$sth->execute("*", $type, "");
	my $result = $sth->fetchrow_hashref;
	if (defined($result)) {
		$sth2->execute($borrower->{'borrowernumber'}, "%$type%");
		my $alreadyissued = $sth2->fetchrow;
		return ("$alreadyissued / ".($result->{maxissueqty}+0)) if ($result->{'maxissueqty'} <= $alreadyissued);
	}

	$sth->execute($cat_borrower, "*", "");
	my $result = $sth->fetchrow_hashref;
	if (defined($result)) {
		$sth2->execute($borrower->{'borrowernumber'}, "%$type%");
		my $alreadyissued = $sth2->fetchrow;
		return ("$alreadyissued / ".($result->{maxissueqty}+0)) if ($result->{'maxissueqty'} <= $alreadyissued);
	}

	$sth->execute("*", "*", "");
	my $result = $sth->fetchrow_hashref;
	if (defined($result)) {
		$sth3->execute($borrower->{'borrowernumber'});
		my $alreadyissued = $sth2->fetchrow;
		return ("$alreadyissued / ".($result->{maxissueqty}+0)) if ($result->{'maxissueqty'} <= $alreadyissued);
	}
	return;
}


sub canbookbeissued {
	my ($env,$borrower,$barcode,$year,$month,$day) = @_;
	my %needsconfirmation; # filled with problems that needs confirmations
	my %issuingimpossible; # filled with problems that causes the issue to be IMPOSSIBLE
	my $iteminformation = getiteminformation($env, 0, $barcode);
	my $dbh = C4::Context->dbh;
#
# DUE DATE is OK ?
#
	my ($duedate, $invalidduedate) = fixdate($year, $month, $day);
	$issuingimpossible{INVALID_DATE} = 1 if ($invalidduedate);

#
# BORROWER STATUS
#
	if ($borrower->{flags}->{GNA}) {
		$issuingimpossible{GNA} = 1;
	}
	if ($borrower->{flags}->{'LOST'}) {
		$issuingimpossible{CARD_LOST} = 1;
	}
	if ($borrower->{flags}->{'DBARRED'}) {
		$issuingimpossible{DEBARRED} = 1;
	}
#
# BORROWER STATUS
#

# DEBTS
	my $amount = checkaccount($env,$borrower->{'borrowernumber'}, $dbh,$duedate);
	if ($amount >0) {
		$needsconfirmation{DEBT} = $amount;
	}


#
# JB34 CHECKS IF BORROWERS DONT HAVE ISSUE TOO MANY BOOKS
#
	my $toomany = TooMany($borrower, $iteminformation);
	$needsconfirmation{TOO_MANY} =  $toomany if $toomany;

#
# ITEM CHECKING
#
	unless ($iteminformation->{barcode}) {
		$issuingimpossible{UNKNOWN_BARCODE} = 1;
	}
	if ($iteminformation->{'notforloan'} == 1) {
		$issuingimpossible{NOT_FOR_LOAN} = 1;
	}
	if ($iteminformation->{'itemtype'} eq 'REF') {
		$issuingimpossible{NOT_FOR_LOAN} = 1;
	}
	if ($iteminformation->{'wthdrawn'} == 1) {
		$issuingimpossible{WTHDRAWN} = 1;
	}
	if ($iteminformation->{'restricted'} == 1) {
		$issuingimpossible{RESTRICTED} = 1;
	}



#
# CHECK IF BOOK ALREADY ISSUED TO THIS BORROWER
#
	my ($currentborrower) = currentborrower($iteminformation->{'itemnumber'});
	if ($currentborrower eq $borrower->{'borrowernumber'}) {
# Already issued to current borrower. Ask whether the loan should
# be renewed.
		my ($renewstatus) = renewstatus($env,$dbh,$borrower->{'borrowernumber'}, $iteminformation->{'itemnumber'});
		if ($renewstatus == 0) { # no more renewals allowed
			$issuingimpossible{NO_MORE_RENEWALS} = 1;
		} else {
			$needsconfirmation{RENEW_ISSUE} = 1;
		}
	} elsif ($currentborrower) {
# issued to someone else
		my $currborinfo = getpatroninformation(0,$currentborrower);
#		warn "=>.$currborinfo->{'firstname'} $currborinfo->{'surname'} ($currborinfo->{'cardnumber'})";
		$needsconfirmation{ISSUED_TO_ANOTHER} = "$currborinfo->{'reservedate'} : $currborinfo->{'firstname'} $currborinfo->{'surname'} ($currborinfo->{'cardnumber'})";
	}
# See if the item is on reserve.
	my ($restype, $res) = CheckReserves($iteminformation->{'itemnumber'});
	if ($restype) {
		my $resbor = $res->{'borrowernumber'};
		if ($resbor ne $borrower->{'borrowernumber'} && $restype eq "Waiting") {
			# The item is on reserve and waiting, but has been
			# reserved by some other patron.
			my ($resborrower, $flags)=getpatroninformation($env, $resbor,0);
			my $branches = getbranches();
			my $branchname = $branches->{$res->{'branchcode'}}->{'branchname'};
			$needsconfirmation{RESERVE_WAITING} = "$resborrower->{'firstname'} $resborrower->{'surname'} ($resborrower->{'cardnumber'}, $branchname)";
		} elsif ($restype eq "Reserved") {
			# The item is on reserve for someone else.
			my ($resborrower, $flags)=getpatroninformation($env, $resbor,0);
			my $branches = getbranches();
			my $branchname = $branches->{$res->{'branchcode'}}->{'branchname'};
			$needsconfirmation{RESERVED} = "$res->{'reservedate'} : $resborrower->{'firstname'} $resborrower->{'surname'} ($resborrower->{'cardnumber'})";
		}
	}
	return(\%issuingimpossible,\%needsconfirmation);
}

=head2 issuebook

Issue a book. Does no check, they are done in canbookbeissued. If we reach this sub, it means the user confirmed if needed.

&issuebook($env,$borrower,$barcode,$date)

=over 4

C<$env> Environment variable. Should be empty usually, but used by other subs. Next code cleaning could drop it.

C<$borrower> hash with borrower informations (from getpatroninformation)

C<$barcode> is the bar code of the book being issued.

C<$date> contains the max date of return. calculated if empty.

=cut

#
# issuing book. We already have checked it can be issued, so, just issue it !
#
sub issuebook {
	my ($env,$borrower,$barcode,$date) = @_;
	my $dbh = C4::Context->dbh;
#	my ($borrower, $flags) = &getpatroninformation($env, $borrowernumber, 0);
	my $iteminformation = getiteminformation($env, 0, $barcode);
#		warn "B : ".$borrower->{borrowernumber}." / I : ".$iteminformation->{'itemnumber'};
#
# check if we just renew the issue.
#
	my ($currentborrower) = currentborrower($iteminformation->{'itemnumber'});
	if ($currentborrower eq $borrower->{'borrowernumber'}) {
		my ($charge,$itemtype) = calc_charges($env, $dbh, $iteminformation->{'itemnumber'}, $borrower->{'borrowernumber'});
		if ($charge > 0) {
			createcharge($env, $dbh, $iteminformation->{'itemnumber'}, $borrower->{'borrowernumber'}, $charge);
			$iteminformation->{'charge'} = $charge;
		}
		&UpdateStats($env,$env->{'branchcode'},'renew',$charge,'',$iteminformation->{'itemnumber'},$iteminformation->{'itemtype'},$borrower->{'borrowernumber'});
		renewbook($env,$dbh, $borrower->{'borrowernumber'}, $iteminformation->{'itemnumber'});
	} else {
#
# NOT a renewal
#
		if ($currentborrower ne '') {
			# This book is currently on loan, but not to the person
			# who wants to borrow it now. mark it returned before issuing to the new borrower
			returnbook($iteminformation->{'barcode'}, $env->{'branchcode'});
		}
		# See if the item is on reserve.
		my ($restype, $res) = CheckReserves($iteminformation->{'itemnumber'});
		if ($restype) {
			my $resbor = $res->{'borrowernumber'};
			if ($resbor eq $borrower->{'borrowernumber'}) {
				# The item is on reserve to the current patron
				FillReserve($res);
			} elsif ($restype eq "Waiting") {
				# The item is on reserve and waiting, but has been
				# reserved by some other patron.
				my ($resborrower, $flags)=getpatroninformation($env, $resbor,0);
				my $branches = getbranches();
				my $branchname = $branches->{$res->{'branchcode'}}->{'branchname'};
				CancelReserve(0, $res->{'itemnumber'}, $res->{'borrowernumber'});
			} elsif ($restype eq "Reserved") {
				# The item is on reserve for someone else.
				my ($resborrower, $flags)=getpatroninformation($env, $resbor,0);
				my $branches = getbranches();
				my $branchname = $branches->{$res->{'branchcode'}}->{'branchname'};
				my $tobrcd = ReserveWaiting($res->{'itemnumber'}, $res->{'borrowernumber'});
				transferbook($tobrcd,$barcode, 1);
			}
		}
		# Record in the database the fact that the book was issued.
		my $sth=$dbh->prepare("insert into issues (borrowernumber, itemnumber, date_due, branchcode) values (?,?,?,?)");
		my $loanlength = $iteminformation->{loanlength} || 21;
		my $datedue=time+($loanlength)*86400;
		my @datearr = localtime($datedue);
		my $dateduef = (1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
		if ($env->{'datedue'}) {
			$dateduef=$env->{'datedue'};
		}
		$sth->execute($borrower->{'borrowernumber'}, $iteminformation->{'itemnumber'}, $dateduef, $env->{'branchcode'});
		$sth->finish;
		$iteminformation->{'issues'}++;
		$sth=$dbh->prepare("update items set issues=? where itemnumber=?");
		$sth->execute($iteminformation->{'issues'},$iteminformation->{'itemnumber'});
		$sth->finish;
		&itemseen($iteminformation->{'itemnumber'});
		# If it costs to borrow this book, charge it to the patron's account.
		my ($charge,$itemtype)=calc_charges($env, $dbh, $iteminformation->{'itemnumber'}, $borrower->{'borrowernumber'});
		if ($charge > 0) {
			createcharge($env, $dbh, $iteminformation->{'itemnumber'}, $borrower->{'borrowernumber'}, $charge);
			$iteminformation->{'charge'}=$charge;
		}
		# Record the fact that this book was issued.
		&UpdateStats($env,$env->{'branchcode'},'issue',$charge,'',$iteminformation->{'itemnumber'},$iteminformation->{'itemtype'},$borrower->{'borrowernumber'});
	}
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
	my ($barcode, $branch) = @_;
	my %env;
	my $messages;
	my $dbh = C4::Context->dbh;
	my $doreturn = 1;
	die '$branch not defined' unless defined $branch; # just in case (bug 170)
	# get information on item
	my ($iteminformation) = getiteminformation(\%env, 0, $barcode);
	if (not $iteminformation) {
		$messages->{'BadBarcode'} = $barcode;
		$doreturn = 0;
	}
	# find the borrower
	my ($currentborrower) = currentborrower($iteminformation->{'itemnumber'});
	if ((not $currentborrower) && $doreturn) {
		$messages->{'NotIssued'} = $barcode;
		$doreturn = 0;
	}
	# check if the book is in a permanent collection....
	my $hbr = $iteminformation->{'homebranch'};
	my $branches = getbranches();
	if ($branches->{$hbr}->{'PE'}) {
		$messages->{'IsPermanent'} = $hbr;
	}
	# check that the book has been cancelled
	if ($iteminformation->{'wthdrawn'}) {
		$messages->{'wthdrawn'} = 1;
		$doreturn = 0;
	}
	# update issues, thereby returning book (should push this out into another subroutine
	my ($borrower) = getpatroninformation(\%env, $currentborrower, 0);
	if ($doreturn) {
		my $sth = $dbh->prepare("update issues set returndate = now() where (borrowernumber = ?) and (itemnumber = ?) and (returndate is null)");
		$sth->execute($borrower->{'borrowernumber'}, $iteminformation->{'itemnumber'});
		$messages->{'WasReturned'} = 1; # FIXME is the "= 1" right?
	}
	($borrower) = getpatroninformation(\%env, $currentborrower, 0);
	# transfer book to the current branch
	my ($transfered, $mess, $item) = transferbook($branch, $barcode, 1);
	if ($transfered) {
		$messages->{'WasTransfered'} = 1; # FIXME is the "= 1" right?
	}
	# fix up the accounts.....
	if ($iteminformation->{'itemlost'}) {
		fixaccountforlostandreturned($iteminformation, $borrower);
		$messages->{'WasLost'} = 1; # FIXME is the "= 1" right?
	}
	# fix up the overdues in accounts...
	fixoverduesonreturn($borrower->{'borrowernumber'}, $iteminformation->{'itemnumber'});
	# find reserves.....
	my ($resfound, $resrec) = CheckReserves($iteminformation->{'itemnumber'});
	if ($resfound) {
	#	my $tobrcd = ReserveWaiting($resrec->{'itemnumber'}, $resrec->{'borrowernumber'});
		$resrec->{'ResFound'} = $resfound;
	 	$messages->{'ResFound'} = $resrec;
	}
	# update stats?
	# Record the fact that this book was returned.
	UpdateStats(\%env, $branch ,'return','0','',$iteminformation->{'itemnumber'},$iteminformation->{'itemtype'},$borrower->{'borrowernumber'});
	return ($doreturn, $messages, $iteminformation, $borrower);
}

=head2 fixaccountforlostandreturned

	&fixaccountforlostandreturned($iteminfo,$borrower);

Calculates the charge for a book lost and returned (Not exported & used only once)

C<$iteminfo> is a hashref to iteminfo. Only {itemnumber} is used.

C<$borrower> is a hashref to borrower. Only {borrowernumber is used.

=cut

sub fixaccountforlostandreturned {
	my ($iteminfo, $borrower) = @_;
	my %env;
	my $dbh = C4::Context->dbh;
	my $itm = $iteminfo->{'itemnumber'};
	# check for charge made for lost book
	my $sth = $dbh->prepare("select * from accountlines where (itemnumber = ?) and (accounttype='L' or accounttype='Rep') order by date desc");
	$sth->execute($itm);
	if (my $data = $sth->fetchrow_hashref) {
	# writeoff this amount
		my $offset;
		my $amount = $data->{'amount'};
		my $acctno = $data->{'accountno'};
		my $amountleft;
		if ($data->{'amountoutstanding'} == $amount) {
		$offset = $data->{'amount'};
		$amountleft = 0;
		} else {
		$offset = $amount - $data->{'amountoutstanding'};
		$amountleft = $data->{'amountoutstanding'} - $amount;
		}
		my $usth = $dbh->prepare("update accountlines set accounttype = 'LR',amountoutstanding='0'
			where (borrowernumber = ?)
			and (itemnumber = ?) and (accountno = ?) ");
		$usth->execute($data->{'borrowernumber'},$itm,$acctno);
		$usth->finish;
	#check if any credit is left if so writeoff other accounts
		my $nextaccntno = getnextacctno(\%env,$data->{'borrowernumber'},$dbh);
		if ($amountleft < 0){
		$amountleft*=-1;
		}
		if ($amountleft > 0){
		my $msth = $dbh->prepare("select * from accountlines where (borrowernumber = ?)
							and (amountoutstanding >0) order by date");
		$msth->execute($data->{'borrowernumber'});
	# offset transactions
		my $newamtos;
		my $accdata;
		while (($accdata=$msth->fetchrow_hashref) and ($amountleft>0)){
			if ($accdata->{'amountoutstanding'} < $amountleft) {
			$newamtos = 0;
			$amountleft -= $accdata->{'amountoutstanding'};
			}  else {
			$newamtos = $accdata->{'amountoutstanding'} - $amountleft;
			$amountleft = 0;
			}
			my $thisacct = $accdata->{'accountno'};
			my $usth = $dbh->prepare("update accountlines set amountoutstanding= ?
					where (borrowernumber = ?)
					and (accountno=?)");
			$usth->execute($newamtos,$data->{'borrowernumber'},'$thisacct');
			$usth->finish;
			$usth = $dbh->prepare("insert into accountoffsets
				(borrowernumber, accountno, offsetaccount,  offsetamount)
				values
				(?,?,?,?)");
			$usth->execute($data->{'borrowernumber'},$accdata->{'accountno'},$nextaccntno,$newamtos);
			$usth->finish;
		}
		$msth->finish;
		}
		if ($amountleft > 0){
			$amountleft*=-1;
		}
		my $desc="Book Returned ".$iteminfo->{'barcode'};
		$usth = $dbh->prepare("insert into accountlines
			(borrowernumber,accountno,date,amount,description,accounttype,amountoutstanding)
			values (?,?,now(),?,?,'CR',?)");
		$usth->execute($data->{'borrowernumber'},$nextaccntno,0-$amount,$desc,$amountleft);
		$usth->finish;
		$usth = $dbh->prepare("insert into accountoffsets
			(borrowernumber, accountno, offsetaccount,  offsetamount)
			values (?,?,?,?)");
		$usth->execute($borrower->{'borrowernumber'},$data->{'accountno'},$nextaccntno,$offset);
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

??

C<$brn> borrowernumber

C<$itm> itemnumber

=cut

sub fixoverduesonreturn {
	my ($brn, $itm) = @_;
	my $dbh = C4::Context->dbh;
	# check for overdue fine
	my $sth = $dbh->prepare("select * from accountlines where (borrowernumber = ?) and (itemnumber = ?) and (accounttype='FU' or accounttype='O')");
	$sth->execute($brn,$itm);
	# alter fine to show that the book has been returned
	if (my $data = $sth->fetchrow_hashref) {
		my $usth=$dbh->prepare("update accountlines set accounttype='F' where (borrowernumber = ?) and (itemnumber = ?) and (acccountno = ?)");
		$usth->execute($brn,$itm,$data->{'accountno'});
		$usth->finish();
	}
	$sth->finish();
	return;
}

# Not exported
#
# NOTE!: If you change this function, be sure to update the POD for
# &getpatroninformation.
#
# $flags = &patronflags($env, $patron, $dbh);
#
# $flags->{CHARGES}
#		{message}	Message showing patron's credit or debt
#		{noissues}	Set if patron owes >$5.00
#         {GNA}			Set if patron gone w/o address
#		{message}	"Borrower has no valid address"
#		{noissues}	Set.
#         {LOST}		Set if patron's card reported lost
#		{message}	Message to this effect
#		{noissues}	Set.
#         {DBARRED}		Set is patron is debarred
#		{message}	Message to this effect
#		{noissues}	Set.
#         {NOTES}		Set if patron has notes
#		{message}	Notes about patron
#         {ODUES}		Set if patron has overdue books
#		{message}	"Yes"
#		{itemlist}	ref-to-array: list of overdue books
#		{itemlisttext}	Text list of overdue items
#         {WAITING}		Set if there are items available that the
#				patron reserved
#		{message}	Message to this effect
#		{itemlist}	ref-to-array: list of available items
sub patronflags {
# Original subroutine for Circ2.pm
	my %flags;
	my ($env, $patroninformation, $dbh) = @_;
	my $amount = checkaccount($env, $patroninformation->{'borrowernumber'}, $dbh);
	if ($amount > 0) {
		my %flaginfo;
		my $noissuescharge = C4::Context->preference("noissuescharge");
		$flaginfo{'message'}= sprintf "Patron owes \$%.02f", $amount;
		if ($amount > $noissuescharge) {
		$flaginfo{'noissues'} = 1;
		}
		$flags{'CHARGES'} = \%flaginfo;
	} elsif ($amount < 0){
	my %flaginfo;
	$flaginfo{'message'} = sprintf "Patron has credit of \$%.02f", -$amount;
		$flags{'CHARGES'} = \%flaginfo;
	}
	if ($patroninformation->{'gonenoaddress'} == 1) {
		my %flaginfo;
		$flaginfo{'message'} = 'Borrower has no valid address.';
		$flaginfo{'noissues'} = 1;
		$flags{'GNA'} = \%flaginfo;
	}
	if ($patroninformation->{'lost'} == 1) {
		my %flaginfo;
		$flaginfo{'message'} = 'Borrower\'s card reported lost.';
		$flaginfo{'noissues'} = 1;
		$flags{'LOST'} = \%flaginfo;
	}
	if ($patroninformation->{'debarred'} == 1) {
		my %flaginfo;
		$flaginfo{'message'} = 'Borrower is Debarred.';
		$flaginfo{'noissues'} = 1;
		$flags{'DBARRED'} = \%flaginfo;
	}
	if ($patroninformation->{'borrowernotes'}) {
		my %flaginfo;
		$flaginfo{'message'} = "$patroninformation->{'borrowernotes'}";
		$flags{'NOTES'} = \%flaginfo;
	}
	my ($odues, $itemsoverdue)
			= checkoverdues($env, $patroninformation->{'borrowernumber'}, $dbh);
	if ($odues > 0) {
		my %flaginfo;
		$flaginfo{'message'} = "Yes";
		$flaginfo{'itemlist'} = $itemsoverdue;
		foreach (sort {$a->{'date_due'} cmp $b->{'date_due'}} @$itemsoverdue) {
		$flaginfo{'itemlisttext'}.="$_->{'date_due'} $_->{'barcode'} $_->{'title'} \n";
		}
		$flags{'ODUES'} = \%flaginfo;
	}
	my ($nowaiting, $itemswaiting)
			= CheckWaiting($patroninformation->{'borrowernumber'});
	if ($nowaiting > 0) {
		my %flaginfo;
		$flaginfo{'message'} = "Reserved items available";
		$flaginfo{'itemlist'} = $itemswaiting;
		$flags{'WAITING'} = \%flaginfo;
	}
	return(\%flags);
}


# Not exported
sub checkoverdues {
# From Main.pm, modified to return a list of overdueitems, in addition to a count
  #checks whether a borrower has overdue items
	my ($env, $bornum, $dbh)=@_;
	my @datearr = localtime;
	my $today = ($datearr[5] + 1900)."-".($datearr[4]+1)."-".$datearr[3];
	my @overdueitems;
	my $count = 0;
	my $sth = $dbh->prepare("SELECT * FROM issues,biblio,biblioitems,items
			WHERE items.biblioitemnumber = biblioitems.biblioitemnumber
				AND items.biblionumber     = biblio.biblionumber
				AND issues.itemnumber      = items.itemnumber
				AND issues.borrowernumber  = ?
				AND issues.returndate is NULL
				AND issues.date_due < ?");
	$sth->execute($bornum,$today);
	while (my $data = $sth->fetchrow_hashref) {
	push (@overdueitems, $data);
	$count++;
	}
	$sth->finish;
	return ($count, \@overdueitems);
}

# Not exported
sub currentborrower {
# Original subroutine for Circ2.pm
	my ($itemnumber) = @_;
	my $dbh = C4::Context->dbh;
	my $q_itemnumber = $dbh->quote($itemnumber);
	my $sth=$dbh->prepare("select borrowers.borrowernumber from
	issues,borrowers where issues.itemnumber=$q_itemnumber and
	issues.borrowernumber=borrowers.borrowernumber and issues.returndate is
	NULL");
	$sth->execute;
	my ($borrower) = $sth->fetchrow;
	return($borrower);
}

# FIXME - Not exported, but used in 'updateitem.pl' anyway.
sub checkreserve {
# Stolen from Main.pm
# Check for reserves for biblio
	my ($env,$dbh,$itemnum)=@_;
	my $resbor = "";
	my $sth = $dbh->prepare("select * from reserves,items
	where (items.itemnumber = ?)
	and (reserves.cancellationdate is NULL)
	and (items.biblionumber = reserves.biblionumber)
	and ((reserves.found = 'W')
	or (reserves.found is null))
	order by priority");
	$sth->execute($itemnum);
	my $resrec;
	my $data=$sth->fetchrow_hashref;
	while ($data && $resbor eq '') {
	$resrec=$data;
	my $const = $data->{'constrainttype'};
	if ($const eq "a") {
	$resbor = $data->{'borrowernumber'};
	} else {
	my $found = 0;
	my $csth = $dbh->prepare("select * from reserveconstraints,items
		where (borrowernumber=?)
		and reservedate=?
		and reserveconstraints.biblionumber=?
		and (items.itemnumber=? and
		items.biblioitemnumber = reserveconstraints.biblioitemnumber)");
	$csth->execute($data->{'borrowernumber'},$data->{'biblionumber'},$data->{'reservedate'},$itemnum);
	if (my $cdata=$csth->fetchrow_hashref) {$found = 1;}
	if ($const eq 'o') {
		if ($found eq 1) {$resbor = $data->{'borrowernumber'};}
	} else {
		if ($found eq 0) {$resbor = $data->{'borrowernumber'};}
	}
	$csth->finish();
	}
	$data=$sth->fetchrow_hashref;
	}
	$sth->finish;
	return ($resbor,$resrec);
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
	my ($env, $borrower) = @_;
	my $dbh = C4::Context->dbh;
	my %currentissues;
	my $counter=1;
	my $borrowernumber = $borrower->{'borrowernumber'};
	my $crit='';

	# Figure out whether to get the books issued today, or earlier.
	# FIXME - $env->{todaysissues} and $env->{nottodaysissues} can
	# both be specified, but are mutually-exclusive. This is bogus.
	# Make this a flag. Or better yet, return everything in (reverse)
	# chronological order and let the caller figure out which books
	# were issued today.
	if ($env->{'todaysissues'}) {
		# FIXME - Could use
		#	$today = POSIX::strftime("%Y%m%d", localtime);
		# FIXME - Since $today will be used in either case, move it
		# out of the two if-blocks.
		my @datearr = localtime(time());
		my $today = (1900+$datearr[5]).sprintf "%02d", ($datearr[4]+1).sprintf "%02d", $datearr[3];
		# FIXME - MySQL knows about dates. Just use
		#	and issues.timestamp = curdate();
		$crit=" and issues.timestamp like '$today%' ";
	}
	if ($env->{'nottodaysissues'}) {
		# FIXME - Could use
		#	$today = POSIX::strftime("%Y%m%d", localtime);
		# FIXME - Since $today will be used in either case, move it
		# out of the two if-blocks.
		my @datearr = localtime(time());
		my $today = (1900+$datearr[5]).sprintf "%02d", ($datearr[4]+1).sprintf "%02d", $datearr[3];
		# FIXME - MySQL knows about dates. Just use
		#	and issues.timestamp < curdate();
		$crit=" and !(issues.timestamp like '$today%') ";
	}

	# FIXME - Does the caller really need every single field from all
	# four tables?
	my $sth=$dbh->prepare("select * from issues,items,biblioitems,biblio where
	borrowernumber=? and issues.itemnumber=items.itemnumber and
	items.biblionumber=biblio.biblionumber and
	items.biblioitemnumber=biblioitems.biblioitemnumber and returndate is null
	$crit order by issues.date_due");
	$sth->execute($borrowernumber);
	while (my $data = $sth->fetchrow_hashref) {
		# FIXME - The Dewey code is a string, not a number.
		$data->{'dewey'}=~s/0*$//;
		($data->{'dewey'} == 0) && ($data->{'dewey'}='');
		# FIXME - Could use
		#	$todaysdate = POSIX::strftime("%Y%m%d", localtime)
		# or better yet, just reuse $today which was calculated above.
		# This function isn't going to run until midnight, is it?
		# Alternately, use
		#	$todaysdate = POSIX::strftime("%Y-%m-%d", localtime)
		#	if ($data->{'date_due'} lt $todaysdate)
		#		...
		# Either way, the date should be be formatted outside of the
		# loop.
		my @datearr = localtime(time());
		my $todaysdate = (1900+$datearr[5]).sprintf ("%0.2d", ($datearr[4]+1)).sprintf ("%0.2d", $datearr[3]);
		my $datedue=$data->{'date_due'};
		$datedue=~s/-//g;
		if ($datedue < $todaysdate) {
			$data->{'overdue'}=1;
		}
		my $itemnumber=$data->{'itemnumber'};
		# FIXME - Consecutive integers as hash keys? You have GOT to
		# be kidding me! Use an array, fercrissakes!
		$currentissues{$counter}=$data;
		$counter++;
	}
	$sth->finish;
	return(\%currentissues);
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
	my ($borrower) = @_;
	my $dbh = C4::Context->dbh;
	my $borrowernumber = $borrower->{'borrowernumber'};
	my %currentissues;
	my $select = "SELECT items.*,issues.timestamp      AS timestamp,
				issues.date_due       AS date_due,
				items.barcode         AS barcode,
				biblio.title          AS title,
				biblio.author         AS author,
				biblioitems.dewey     AS dewey,
				itemtypes.description AS itemtype,
				biblioitems.subclass  AS subclass,
				biblioitems.classification AS classification
			FROM issues,items,biblioitems,biblio, itemtypes
			WHERE issues.borrowernumber  = ?
			AND issues.itemnumber      = items.itemnumber
			AND items.biblionumber     = biblio.biblionumber
			AND items.biblioitemnumber = biblioitems.biblioitemnumber
			AND itemtypes.itemtype     = biblioitems.itemtype
			AND issues.returndate      IS NULL
			ORDER BY issues.date_due";
	#    print $select;
	my $sth=$dbh->prepare($select);
	$sth->execute($borrowernumber);
	my $counter = 0;
	while (my $data = $sth->fetchrow_hashref) {
		$data->{'dewey'} =~ s/0*$//;
		($data->{'dewey'} == 0) && ($data->{'dewey'} = '');
			# FIXME - The Dewey code is a string, not a number.
		# FIXME - Use POSIX::strftime to get a text version of today's
		# date. That's what it's for.
		# FIXME - Move the date calculation outside of the loop.
		my @datearr = localtime(time());
		my $todaysdate = (1900+$datearr[5]).sprintf ("%0.2d", ($datearr[4]+1)).sprintf ("%0.2d", $datearr[3]);

		# FIXME - Instead of converting the due date to YYYYMMDD, just
		# use
		#	$todaysdate = POSIX::strftime("%Y-%m-%d", localtime);
		#	...
		#	if ($date->{date_due} lt $todaysdate)
		my $datedue = $data->{'date_due'};
		$datedue =~ s/-//g;
		if ($datedue < $todaysdate) {
			$data->{'overdue'} = 1;
		}
		$currentissues{$counter} = $data;
		$counter++;
			# FIXME - This is ludicrous. If you want to return an
			# array of values, just use an array. That's what
			# they're there for.
	}
	$sth->finish;
	return(\%currentissues);
}

# Not exported
sub checkwaiting {
#Stolen from Main.pm
# check for reserves waiting
	my ($env,$dbh,$bornum)=@_;
	my @itemswaiting;
	my $sth = $dbh->prepare("select * from reserves where (borrowernumber = ?) and (reserves.found='W') and cancellationdate is NULL");
	$sth->execute($bornum);
	my $cnt=0;
	if (my $data=$sth->fetchrow_hashref) {
		$itemswaiting[$cnt] =$data;
		$cnt ++
	}
	$sth->finish;
	return ($cnt,\@itemswaiting);
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
  # FIXME - Two people can't borrow the same book at once, so
  # presumably we can get $bornum from $itemno.
  my ($env,$bornum,$itemno)=@_;
  my $dbh = C4::Context->dbh;
  my $renews = 1;
  my $renewokay = 0;
  # Look in the issues table for this item, lent to this borrower,
  # and not yet returned.

  # FIXME - I think this function could be redone to use only one SQL
  # call.
  my $sth1 = $dbh->prepare("select * from issues
    where (borrowernumber = ?)
    and (itemnumber = ?')
    and returndate is null");
  $sth1->execute($bornum,$itemno);
  if (my $data1 = $sth1->fetchrow_hashref) {
    # Found a matching item

    # See if this item may be renewed. This query is convoluted
    # because it's a bit messy: given the item number, we need to find
    # the biblioitem, which gives us the itemtype, which tells us
    # whether it may be renewed.
    my $sth2 = $dbh->prepare("select renewalsallowed from items,biblioitems,itemtypes
       where (items.itemnumber = ?)
       and (items.biblioitemnumber = biblioitems.biblioitemnumber)
       and (biblioitems.itemtype = itemtypes.itemtype)");
    $sth2->execute($itemno);
    if (my $data2=$sth2->fetchrow_hashref) {
      $renews = $data2->{'renewalsallowed'};
    }
    if ($renews > $data1->{'renewals'}) {
      $renewokay = 1;
    }
    $sth2->finish;
  }
  $sth1->finish;
  return($renewokay);
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
  # FIXME - A book can't be on loan to two people at once, so
  # presumably we can get $bornum from $itemno.
  my ($env,$bornum,$itemno,$datedue)=@_;
  my $dbh = C4::Context->dbh;

  # If the due date wasn't specified, calculate it by adding the
  # book's loan length to today's date.
  if ($datedue eq "" ) {
    #debug_msg($env, "getting date");
    my $loanlength=21;		# Default loan length?
				# FIXME - This is bogus. If there's no
				# loan length defined for some book
				# type or whatever, then that should
				# be an error
    # Find this item's item type, via its biblioitem.
    my $sth=$dbh->prepare("Select * from biblioitems,items,itemtypes
       where (items.itemnumber = ?)
       and (biblioitems.biblioitemnumber = items.biblioitemnumber)
       and (biblioitems.itemtype = itemtypes.itemtype)");
    $sth->execute($itemno);
    if (my $data=$sth->fetchrow_hashref) {
      $loanlength = $data->{'loanlength'}
    }
    $sth->finish;
    my $ti = time;		# FIXME - Unused
    # FIXME - Use
    #	POSIX::strftime("%Y-%m-%d", localtime(time + ...));
    my $datedu = time + ($loanlength * 86400);
    my @datearr = localtime($datedu);
    $datedue = (1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
  }

  # Find the issues record for this book
  my $sth=$dbh->prepare("select * from issues where borrowernumber=? and
    itemnumber=? and returndate is null");
  $sth->execute($bornum,$itemno);
  my $issuedata=$sth->fetchrow_hashref;
	# FIXME - Error-checking
  $sth->finish;

  # Update the issues record to have the new due date, and a new count
  # of how many times it has been renewed.
  my $renews = $issuedata->{'renewals'} +1;
  $sth=$dbh->prepare("update issues
    set date_due = ?, renewals = ?
    where borrowernumber=? and
    itemnumber=? and returndate is null");
  $sth->execute($datedue,$renews,$bornum,$itemno);
  $sth->finish;

  # Log the renewal
  UpdateStats($env,$env->{'branchcode'},'renew','','',$itemno);

  # Charge a new rental fee, if applicable?
  my ($charge,$type)=calc_charges($env, $itemno, $bornum);
  if ($charge > 0){
    my $accountno=getnextacctno($env,$bornum,$dbh);
    my $item=getiteminformation($env, $itemno);
    $sth=$dbh->prepare("Insert into accountlines (borrowernumber,accountno,date,amount,description,accounttype,amountoutstanding,itemnumber)
						values (?,?,now(),?,?,?,?,?)");
    $sth->execute($bornum,$accountno,$charge,"Renewal of Rental Item $item->{'title'} $item->{'barcode'}",'Rent',$charge,$itemno);
    $sth->finish;
#     print $account;
  }

#  return();
}



=item calc_charges

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
  my ($env, $itemno, $bornum)=@_;
  my $charge=0;
  my $dbh = C4::Context->dbh;
  my $item_type;

  # Get the book's item type and rental charge (via its biblioitem).
  my $sth1= $dbh->prepare("select itemtypes.itemtype,rentalcharge from items,biblioitems,itemtypes
  						 where (items.itemnumber =?)
						 		and (biblioitems.biblioitemnumber = items.biblioitemnumber)
								and (biblioitems.itemtype = itemtypes.itemtype)");
  $sth1->execute($itemno);
  # FIXME - Why not just use fetchrow_array?
  if (my $data1=$sth1->fetchrow_hashref) {
    $item_type = $data1->{'itemtype'};
    $charge = $data1->{'rentalcharge'};

    # Figure out the applicable rental discount
    my $sth2=$dbh->prepare("select rentaldiscount from
    borrowers,categoryitem
    where (borrowers.borrowernumber = ?)
    and (borrowers.categorycode = categoryitem.categorycode)
    and (categoryitem.itemtype = ?)");
    $sth2->execute($bornum,$item_type);
    if (my$data2=$sth2->fetchrow_hashref) {
      my $discount = $data2->{'rentaldiscount'};
      $charge *= (100 - $discount) / 100;
    }
    $sth2->finish;
  }
  $sth1->finish;
#  print "item $item_type";
  return ($charge,$item_type);
}


# FIXME - A virtually identical function appears in
# C4::Circulation::Issues. Pick one and stick with it.
sub createcharge {
#Stolen from Issues.pm
    my ($env,$dbh,$itemno,$bornum,$charge) = @_;
    my $nextaccntno = getnextacctno($env,$bornum,$dbh);
    my $sth = $dbh->prepare(<<EOT);
	INSERT INTO	accountlines
			(borrowernumber, itemnumber, accountno,
			 date, amount, description, accounttype,
			 amountoutstanding)
	VALUES		(?, ?, ?,
			 now(), ?, 'Rental', 'Rent',
			 ?)
EOT
    $sth->execute($bornum, $itemno, $nextaccntno, $charge, $charge);
    $sth->finish;
}


sub getnextacctno {
# Stolen from Accounts.pm
    my ($env,$bornumber,$dbh)=@_;
    my $nextaccntno = 1;
    my $sth = $dbh->prepare("select * from accountlines where (borrowernumber = ?) order by accountno desc");
    $sth->execute($bornumber);
    if (my $accdata=$sth->fetchrow_hashref){
	$nextaccntno = $accdata->{'accountno'} + 1;
    }
    $sth->finish;
    return($nextaccntno);
}

=item find_reserves

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
    my ($itemno) = @_;
    my %env;
    my $dbh = C4::Context->dbh;
    my ($itemdata) = getiteminformation(\%env, $itemno,0);
    my $bibno = $dbh->quote($itemdata->{'biblionumber'});
    my $bibitm = $dbh->quote($itemdata->{'biblioitemnumber'});
    my $sth = $dbh->prepare("select * from reserves where ((found = 'W') or (found is null)) and biblionumber = ? and cancellationdate is NULL order by priority, reservedate");
    $sth->execute($bibno);
    my $resfound = 0;
    my $resrec;
    my $lastrec;
# print $query;

    # FIXME - I'm not really sure what's going on here, but since we
    # only want one result, wouldn't it be possible (and far more
    # efficient) to do something clever in SQL that only returns one
    # set of values?
    while (($resrec = $sth->fetchrow_hashref) && (not $resfound)) {
		# FIXME - Unlike Pascal, Perl allows you to exit loops
		# early. Take out the "&& (not $resfound)" and just
		# use "last" at the appropriate point in the loop.
		# (Oh, and just in passing: if you'd used "!" instead
		# of "not", you wouldn't have needed the parentheses.)
	$lastrec = $resrec;
	my $brn = $dbh->quote($resrec->{'borrowernumber'});
	my $rdate = $dbh->quote($resrec->{'reservedate'});
	my $bibno = $dbh->quote($resrec->{'biblionumber'});
	if ($resrec->{'found'} eq "W") {
	    if ($resrec->{'itemnumber'} eq $itemno) {
		$resfound = 1;
	    }
        } else {
	    # FIXME - Use 'elsif' to avoid unnecessary indentation.
	    if ($resrec->{'constrainttype'} eq "a") {
		$resfound = 1;
	    } else {
			my $consth = $dbh->prepare("select * from reserveconstraints where borrowernumber = ? and reservedate = ? and biblionumber = ? and biblioitemnumber = ?");
			$consth->execute($brn,$rdate,$bibno,$bibitm);
			if (my $conrec = $consth->fetchrow_hashref) {
				if ($resrec->{'constrainttype'} eq "o") {
				$resfound = 1;
				}
			}
		$consth->finish;
		}
	}
	if ($resfound) {
	    my $updsth = $dbh->prepare("update reserves set found = 'W', itemnumber = ? where borrowernumber = ? and reservedate = ? and biblionumber = ?");
	    $updsth->execute($itemno,$brn,$rdate,$bibno);
	    $updsth->finish;
	    # FIXME - "last;" here to break out of the loop early.
	}
    }
    $sth->finish;
    return ($resfound,$lastrec);
}

sub fixdate {
    my ($year, $month, $day) = @_;
    my $invalidduedate;
    my $date;
    if (($year eq 0) && ($month eq 0) && ($year eq 0)) {
#	$env{'datedue'}='';
    } else {
	if (($year eq 0) || ($month eq 0) || ($year eq 0)) {
	    $invalidduedate=1;
	} else {
	    if (($day>30) && (($month==4) || ($month==6) || ($month==9) || ($month==11))) {
		$invalidduedate = 1;
	    } elsif (($day > 29) && ($month == 2)) {
		$invalidduedate=1;
	    } elsif (($month == 2) && ($day > 28) && (($year%4) && ((!($year%100) || ($year%400))))) {
		$invalidduedate=1;
	    } else {
		$date="$year-$month-$day";
	    }
	}
    }
    return ($date, $invalidduedate);
}

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
