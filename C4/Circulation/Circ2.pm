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

use C4::Context;
use C4::Stats;
use C4::Reserves2;
use C4::Koha;
use C4::Accounts2;
use C4::Biblio;
use C4::Calendar::Calendar;
use C4::Search;
use C4::Members;

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
@EXPORT = qw(
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
	&listitemsforinventory 
	&itemseen 
	&itemseenbarcode
	&fixdate 
	&itemissues 
	&patronflags
	 get_current_return_date_of
                get_transfert_infos
		&checktransferts
		&GetReservesForBranch
		&GetReservesToBranch
		&GetTransfersFromBib
		&getBranchIp);

# &getbranches &getprinters &getbranch &getprinter => moved to C4::Koha.pm
=item itemissues

  @issues = &itemissues($biblionumber, $biblio);

Looks up information about who has borrowed the bookZ<>(s) with the
given biblionumber.

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
    my ($dbh,$data, $itemnumber)=@_;
    
      
    my $i     = 0;
    my @results;


        # Find out who currently has this item.
        # FIXME - Wouldn't it be better to do this as a left join of
        # some sort? Currently, this code assumes that if
        # fetchrow_hashref() fails, then the book is on the shelf.
        # fetchrow_hashref() can fail for any number of reasons (e.g.,
        # database server crash), not just because no items match the
        # search criteria.
        my $sth2   = $dbh->prepare("select * from issues,borrowers
where itemnumber = ?
and returndate is NULL
and issues.borrowernumber = borrowers.borrowernumber");

        $sth2->execute($itemnumber);
        if (my $data2 = $sth2->fetchrow_hashref) {

  	$data->{'date_due'}=$data2->{'date_due'};
	$data->{'datelastborrowed'} = $data2->{'issue_date'};
            $data->{'card'}     = $data2->{'cardnumber'};
	    $data->{'borrower'}     = $data2->{'borrowernumber'};
        } 

        $sth2->finish;

        # Find the last 2 people who borrowed this item.
        $sth2 = $dbh->prepare("select * from issues, borrowers
						where itemnumber = ?
									and issues.borrowernumber = borrowers.borrowernumber
									and returndate is not NULL
									order by returndate desc,timestamp desc limit 2") ;
        $sth2->execute($itemnumber) ;
#        for (my $i2 = 0; $i2 < 2; $i2++) { # FIXME : error if there is less than 3 pple borrowing this item
my $i2=0;
          while (my $data2  = $sth2->fetchrow_hashref) {
                $data->{"timestamp$i2"} = $data2->{'timestamp'};
                $data->{"card$i2"}      = $data2->{'cardnumber'};
                $data->{"borrower$i2"}  = $data2->{'borrowernumber'};
$data->{'datelastborrowed'} = $data2->{'issue_date'} unless $data->{'datelastborrowed'};
	$i2++;
            } # while
#       } # for

        $sth2->finish;
    return($data);
}



=head2 itemseen

&itemseen($dbh,$itemnum)
Mark item as seen. Is called when an item is issued, returned or manually marked during inventory/stocktaking
C<$itemnum> is the item number

=cut

sub itemseen {
	my ($dbh,$itemnumber) = @_;
my $sth=$dbh->prepare("select biblionumber from items where itemnumber=?");
	$sth->execute($itemnumber);
my ($biblionumber)=$sth->fetchrow; 
XMLmoditemonefield($dbh,$biblionumber,$itemnumber,'itemlost',"0",1);
# find today's date
my ($sec,$min,$hour,$mday,$mon,$year) = localtime();
	$year += 1900;
	$mon += 1;
	my $timestamp = sprintf("%4d%02d%02d%02d%02d%02d.0",
		$year,$mon,$mday,$hour,$min,$sec);
XMLmoditemonefield($dbh,$biblionumber,$itemnumber,'datelastseen', $timestamp);	
}
sub itemseenbarcode {
	my ($dbh,$barcode) = @_;
my $sth=$dbh->prepare("select biblionumber,itemnumber from items where barcode=$barcode");
	$sth->execute();
my ($biblionumber,$itemnumber)=$sth->fetchrow; 
XMLmoditemonefield($dbh,$biblionumber,$itemnumber,'itemlost',"0",1);
my ($sec,$min,$hour,$mday,$mon,$year) = localtime();
	$year += 1900;
	$mon += 1;
my $timestamp = sprintf("%4d%02d%02d%02d%02d%02d.0",$year,$mon,$mday,$hour,$min,$sec);
XMLmoditemonefield($dbh,$biblionumber,$itemnumber,'datelastseen', $timestamp);	
}

sub listitemsforinventory {
	my ($minlocation,$datelastseen,$offset,$size) = @_;
	my $count=0;
	my @results;
	my @kohafields;
	my @values;
	my @relations;
	my $sort;
	my @and_or;
	if ($datelastseen){
		push @kohafields, "classification","datelastseen";
		push @values,$minlocation,$datelastseen;
		push @relations,"\@attr 5=1  \@attr 6=3 \@attr 4=1 ","\@attr 2=1 ";
		push @and_or,"\@and";
		$sort="lcsort";
		($count,@results)=ZEBRAsearch_kohafields(\@kohafields,\@values,\@relations,$sort,\@and_or,0,"",$offset,$size);
	}else{
	push @kohafields, "classification";
		push @values,$minlocation;
		push @relations,"\@attr 5=1  \@attr 6=3 \@attr 4=1 ";
		push @and_or,"";
		$sort="lcsort";
		($count,@results)=ZEBRAsearch_kohafields(\@kohafields,\@values,\@relations,$sort,\@and_or,0,"",$offset,$size);
	}
	
	return @results;
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
# returns a hash of item information together with biblio given either the itemnumber or the barcode
	my ($env, $itemnumber, $barcode) = @_;
	my $dbh=C4::Context->dbh;
	my ($itemrecord)=XMLgetitem($dbh,$itemnumber,$barcode);
	 my $itemhash=XML_xml2hash_onerecord($itemrecord);	
	my $iteminformation=XMLmarc2koha_onerecord($dbh,$itemhash,"holdings");
##Now get full biblio details from MARC
	if ($iteminformation) {
my ($record)=XMLgetbiblio($dbh,$iteminformation->{'biblionumber'});
	my $recordhash=XML_xml2hash_onerecord($record);
my $biblio=XMLmarc2koha_onerecord($dbh,$recordhash,"biblios");
		foreach my $field (keys %$biblio){
		$iteminformation->{$field}=$biblio->{$field};
		} 
	$iteminformation->{'date_due'}="" if $iteminformation->{'date_due'} eq "0000-00-00";
	($iteminformation->{'dewey'} == 0) && ($iteminformation->{'dewey'}='');	
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

##This routine is reverted to origional state
##This routine is used when a book physically arrives at a branch due to user returning it there
## so record the fact that holdingbranch is changed.
sub transferbook {
# transfer book code....
	my ($tbr, $barcode, $ignoreRs,$user) = @_;
	my $messages;
	my %env;
	my $dbh=C4::Context->dbh;
	my $dotransfer = 1;
	my $branches = GetBranches();

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
	if ($hbr && $branches->{$hbr}->{'PE'}) {
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
		dotransfer($iteminformation->{'itemnumber'}, $fbr, $tbr,$user);
		$messages->{'WasTransfered'} = 1;
	}
	return ($dotransfer, $messages, $iteminformation);
}

# Not exported

sub dotransfer {
## The book has arrived at this branch because it has been returned there
## So we update the fact the book is in that branch not that we want to send the book to that branch

	my ($itm, $fbr, $tbr,$user) = @_;
	my $dbh = C4::Context->dbh;
	
	#new entry in branchtransfers....
	my $sth=$dbh->prepare("INSERT INTO branchtransfers (itemnumber, frombranch, datearrived, tobranch,comments) VALUES (?, ?, now(), ?,?)");
	$sth->execute($itm, $fbr,  $tbr,$user);
	#update holdingbranch in items .....
	&domarctransfer($dbh,$itm,$tbr);
## Item seen taken out of this loop to optimize ZEBRA updates
#	&itemseen($dbh,$itm);	
	return;
}

sub domarctransfer{
my ($dbh,$itemnumber,$holdingbranch) = @_; 
$itemnumber=~s /\'//g;
my $sth=$dbh->prepare("select biblionumber from items where itemnumber=$itemnumber");
	$sth->execute();
my ($biblionumber)=$sth->fetchrow; 
XMLmoditemonefield($dbh,$biblionumber,$itemnumber,'holdingbranch',$holdingbranch,1);
	$sth->finish;
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
	my $sth = $dbh->prepare('select itemtype from biblio where biblionumber = ?');
	$sth->execute($iteminformation->{'biblionumber'});
	my $type = $sth->fetchrow;
	$sth = $dbh->prepare('select * from issuingrules where categorycode = ? and itemtype = ? and branchcode = ?');
	my $sth2 = $dbh->prepare("select COUNT(*) from issues i,  items it, biblio b where i.borrowernumber = ? and i.returndate is null and i.itemnumber = it.itemnumber  and b.biblionumber=it.biblionumber and b.itemtype  like ?");
	my $sth3 = $dbh->prepare('select COUNT(*) from issues where borrowernumber = ? and returndate is null');
	my $alreadyissued;

	# check the 3 parameters
	#print "content-type: text/plain \n\n";
	#print "$cat_borrower, $type, $branch_borrower";
	$sth->execute($cat_borrower, $type, $branch_borrower);
	my $result = $sth->fetchrow_hashref;
	if (defined($result->{maxissueqty})) {
	#	print "content-type: text/plain \n\n";
	#print "$cat_borrower, $type, $branch_borrower";
		$sth2->execute($borrower->{'borrowernumber'}, $type);
		my $alreadyissued = $sth2->fetchrow;	
	#	print "***" . $alreadyissued;
	#print "----". $result->{'maxissueqty'};
	  if ($result->{'maxissueqty'} <= $alreadyissued) {
			return ("a $alreadyissued /",($result->{'maxissueqty'}+0));
	  }else {
	        return;
	  }
	}

	# check for branch=*
	$sth->execute($cat_borrower, $type, "");
	 $result = $sth->fetchrow_hashref;
	if (defined($result->{maxissueqty})) {
		$sth2->execute($borrower->{'borrowernumber'}, $type);
		my $alreadyissued = $sth2->fetchrow;
	  if ($result->{'maxissueqty'} <= $alreadyissued){
		return ("b $alreadyissued / ".($result->{maxissueqty}+0));
	     } else {
	        return;
	     }
	}

	# check for itemtype=*
	$sth->execute($cat_borrower, "*", $branch_borrower);
	$result = $sth->fetchrow_hashref;
        if (defined($result->{maxissueqty})) {
		$sth3->execute($borrower->{'borrowernumber'});
		my ($alreadyissued) = $sth3->fetchrow;
	     if ($result->{'maxissueqty'} <= $alreadyissued){
#		warn "HERE : $alreadyissued / ($result->{maxissueqty} for $borrower->{'borrowernumber'}";
		return ("c $alreadyissued / ".($result->{maxissueqty}+0));
	     } else {
		return;
	     }
	}

	#check for borrowertype=*
	$sth->execute("*", $type, $branch_borrower);
	$result = $sth->fetchrow_hashref;
        if (defined($result->{maxissueqty})) {    
		$sth2->execute($borrower->{'borrowernumber'}, "%$type%");
		my $alreadyissued = $sth2->fetchrow;
	    if ($result->{'maxissueqty'} <= $alreadyissued){	    
		return ("d $alreadyissued / ".($result->{maxissueqty}+0));
	    } else {
		return;
	    }
	}

	#check for borrowertype=*;itemtype=*
	$sth->execute("*", "*", $branch_borrower);
	$result = $sth->fetchrow_hashref;
        if (defined($result->{maxissueqty})) {    
		$sth3->execute($borrower->{'borrowernumber'});
		my $alreadyissued = $sth3->fetchrow;
	    if ($result->{'maxissueqty'} <= $alreadyissued){
		return ("e $alreadyissued / ".($result->{maxissueqty}+0));
	    } else {
		return;
	    }
	}

	$sth->execute("*", $type, "");
	$result = $sth->fetchrow_hashref;
	if (defined($result->{maxissueqty}) && $result->{maxissueqty}>=0) {
		$sth2->execute($borrower->{'borrowernumber'}, "%$type%");
		my $alreadyissued = $sth2->fetchrow;
	     if ($result->{'maxissueqty'} <= $alreadyissued){
		return ("f $alreadyissued / ".($result->{maxissueqty}+0));
	     } else {
		return;
	     }
	}

	$sth->execute($cat_borrower, "*", "");
	$result = $sth->fetchrow_hashref;
        if (defined($result->{maxissueqty})) {    
		$sth2->execute($borrower->{'borrowernumber'}, "%$type%");
		my $alreadyissued = $sth2->fetchrow;
	     if ($result->{'maxissueqty'} <= $alreadyissued){
		return ("g $alreadyissued / ".($result->{maxissueqty}+0));
	     } else {
		return;
	     }
	}

	$sth->execute("*", "*", "");
	$result = $sth->fetchrow_hashref;
        if (defined($result->{maxissueqty})) {    
		$sth3->execute($borrower->{'borrowernumber'});
		my $alreadyissued = $sth3->fetchrow;
	     if ($result->{'maxissueqty'} <= $alreadyissued){
		return ("h $alreadyissued / ".($result->{maxissueqty}+0));
	     } else {
		return;
	     }
	}
	return;
}




sub canbookbeissued {
	my ($env,$borrower,$barcode,$year,$month,$day,$inprocess) = @_;
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
	if (DATE_diff($borrower->{expiry},'CURRENT_DATE')<0) {
		$issuingimpossible{EXPIRED} = 1;
	}
#
# BORROWER STATUS
#

# DEBTS
	my $amount = checkaccount($env,$borrower->{'borrowernumber'}, $dbh,$duedate);
        if(C4::Context->preference("IssuingInProcess")){
	    my $amountlimit = C4::Context->preference("noissuescharge");
	    	if ($amount > $amountlimit && !$inprocess) {
			$issuingimpossible{DEBT} = sprintf("%.2f",$amount);
	    	} elsif ($amount <= $amountlimit && !$inprocess) {
			$needsconfirmation{DEBT} = sprintf("%.2f",$amount);
	    	}
        } else {
	   		 if ($amount >0) {
			$needsconfirmation{DEBT} = $amount;
	    	}
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
	if ($iteminformation->{'notforloan'} > 0) {
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
	if ($iteminformation->{'shelf'} eq 'Res') {
		$issuingimpossible{IN_RESERVE} = 1;
	}
if (C4::Context->preference("IndependantBranches")){
		my $userenv = C4::Context->userenv;
		if (($userenv)&&($userenv->{flags} != 1)){
			$issuingimpossible{NOTSAMEBRANCH} = 1 if ($iteminformation->{'holdingbranch'} ne $userenv->{branch} ) ;
		}
	}

#
# CHECK IF BOOK ALREADY ISSUED TO THIS BORROWER
#
	my ($currentborrower) = currentborrower($iteminformation->{'itemnumber'});
	if ($currentborrower eq $borrower->{'borrowernumber'}) {
# Already issued to current borrower. Ask whether the loan should
# be renewed.
		my ($renewstatus) = renewstatus($env, $borrower->{'borrowernumber'}, $iteminformation->{'itemnumber'});
		if ($renewstatus == 0) { # no more renewals allowed
			$issuingimpossible{NO_MORE_RENEWALS} = 1;
		} else {
			if (C4::Context->preference("strictrenewals")){
			###if this is set do not allow automatic renewals
			##the new renew script will do same strict checks as issues and return error codes
			$needsconfirmation{RENEW_ISSUE} = 1;
			}	
			
		}
	} elsif ($currentborrower) {
# issued to someone else
		my $currborinfo = getpatroninformation(0,$currentborrower);
#		warn "=>.$currborinfo->{'firstname'} $currborinfo->{'surname'} ($currborinfo->{'cardnumber'})";
		$needsconfirmation{ISSUED_TO_ANOTHER} = "$currborinfo->{'reservedate'} : $currborinfo->{'firstname'} $currborinfo->{'surname'} ($currborinfo->{'cardnumber'})";
	}
# See if the item is on RESERVE
	my ($restype, $res) = CheckReserves($iteminformation->{'itemnumber'});
	if ($restype) {
		my $resbor = $res->{'borrowernumber'};
		if ($resbor ne $borrower->{'borrowernumber'} && $restype eq "Waiting") {
			# The item is on reserve and waiting, but has been
			# reserved by some other patron.
			my ($resborrower, $flags)=getpatroninformation($env, $resbor,0);
			my $branches = GetBranches();
			my $branchname = $branches->{$res->{'branchcode'}}->{'branchname'};
			$needsconfirmation{RESERVE_WAITING} = "$resborrower->{'firstname'} $resborrower->{'surname'} ($resborrower->{'cardnumber'}, $branchname)";
		#	CancelReserve(0, $res->{'itemnumber'}, $res->{'borrowernumber'});
		} elsif ($restype eq "Reserved") {
			# The item is on reserve for someone else.
			my ($resborrower, $flags)=getpatroninformation($env, $resbor,0);
			my $branches = GetBranches();
			my $branchname = $branches->{$res->{'branchcode'}}->{'branchname'};
			$needsconfirmation{RESERVED} = "$res->{'reservedate'} : $resborrower->{'firstname'} $resborrower->{'surname'} ($resborrower->{'cardnumber'})";
		}
	}
        	if(C4::Context->preference("LibraryName") eq "Horowhenua Library Trust"){
	   			 if ($borrower->{'categorycode'} eq 'W'){
		        my %issuingimpossible;
		        	return(\%issuingimpossible,\%needsconfirmation);
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
### fix me STOP using koha hashes, change so that XML hash is used
	my ($env,$borrower,$barcode,$date,$cancelreserve) = @_;
	my $dbh = C4::Context->dbh;
	my ($itemrecord)=XMLgetitem($dbh,"",$barcode);
	 $itemrecord=XML_xml2hash_onerecord($itemrecord);
	my $iteminformation=XMLmarc2koha_onerecord($dbh,$itemrecord,"holdings");
	my $error;
#
# check if we just renew the issue.
#
	my ($currentborrower) = currentborrower($iteminformation->{'itemnumber'});
	if ($currentborrower eq $borrower->{'borrowernumber'}) {
		my ($charge,$itemtype) = calc_charges($env, $iteminformation->{'itemnumber'}, $borrower->{'borrowernumber'});
		if ($charge > 0) {
			createcharge($env, $dbh, $iteminformation->{'itemnumber'}, $borrower->{'borrowernumber'}, $charge);
			$iteminformation->{'charge'} = $charge;
		}
		&UpdateStats($env,$env->{'branchcode'},'renew',$charge,'',$iteminformation->{'itemnumber'},$iteminformation->{'itemtype'},$borrower->{'borrowernumber'});
			if (C4::Context->preference("strictrenewals")){
		 	$error=renewstatus($env, $borrower->{'borrowernumber'}, $iteminformation->{'itemnumber'});
		 	renewbook($env, $borrower->{'borrowernumber'}, $iteminformation->{'itemnumber'}) if ($error>1);
		 	}else{
		 renewbook($env, $borrower->{'borrowernumber'}, $iteminformation->{'itemnumber'});
			}
	} else {
#
# NOT a renewal
#
		if ($currentborrower ne '') {
			# This book is currently on loan, but not to the person
			# who wants to borrow it now. mark it returned before issuing to the new borrower
			returnbook($iteminformation->{'barcode'}, $env->{'branchcode'});
#warn "return : ".$borrower->{borrowernumber}." / I : ".$iteminformation->{'itemnumber'};

		}
		# See if the item is on reserve.
		my ($restype, $res) = CheckReserves($iteminformation->{'itemnumber'});
#warn "$restype,$res";
		if ($restype) {
			my $resbor = $res->{'borrowernumber'};
			if ($resbor eq $borrower->{'borrowernumber'}) {
				# The item is on reserve to the current patron
				FillReserve($res);
#				warn "FillReserve";
			} elsif ($restype eq "Waiting") {
#				warn "Waiting";
				# The item is on reserve and waiting, but has been
				# reserved by some other patron.
				my ($resborrower, $flags)=getpatroninformation($env, $resbor,0);
				my $branches = GetBranches();
				my $branchname = $branches->{$res->{'branchcode'}}->{'branchname'};
                 if ($cancelreserve){
    				    CancelReserve(0, $res->{'itemnumber'}, $res->{'borrowernumber'});
                  } else {
				    # set waiting reserve to first in reserve queue as book isn't waiting now
				    UpdateReserve(1, $res->{'biblionumber'}, $res->{'borrowernumber'}, $res->{'branchcode'});
				}
			} elsif ($restype eq "Reserved") {
#warn "Reserved";
				# The item is on reserve for someone else.
				my ($resborrower, $flags)=getpatroninformation($env, $resbor,0);
				my $branches = GetBranches();
				my $branchname = $branches->{$res->{'branchcode'}}->{'branchname'};
				if ($cancelreserve) {
					# cancel reserves on this item
					CancelReserve(0, $res->{'itemnumber'}, $res->{'borrowernumber'});
					# also cancel reserve on biblio related to this item
				#	my $st_Fbiblio = $dbh->prepare("select biblionumber from items where itemnumber=?");
				#	$st_Fbiblio->execute($res->{'itemnumber'});
				#	my $biblionumber = $st_Fbiblio->fetchrow;
#					CancelReserve($iteminformation->{'biblionumber'},0,$res->{'borrowernumber'});
#					warn "CancelReserve $res->{'itemnumber'}, $res->{'borrowernumber'}";
				} else {
					my $tobrcd = ReserveWaiting($res->{'itemnumber'}, $res->{'borrowernumber'});
					transferbook($tobrcd,$barcode, 1);
					warn "transferbook";
				}
			}
		}
		
		my $sth=$dbh->prepare("insert into issues (borrowernumber, itemnumber, date_due, branchcode,issue_date) values (?,?,?,?,NOW())");
		my $loanlength = getLoanLength($borrower->{'categorycode'},$iteminformation->{'itemtype'},$borrower->{'branchcode'});
		my $dateduef;
		 my @datearr = localtime();
		$dateduef = (1900+$datearr[5])."-".($datearr[4]+1)."-". $datearr[3];

		my $calendar = C4::Calendar::Calendar->new(branchcode => $borrower->{'branchcode'});
		my ($yeardue, $monthdue, $daydue) = split /-/, $dateduef;
		($daydue, $monthdue, $yeardue) = $calendar->addDate($daydue, $monthdue, $yeardue, $loanlength);
		$dateduef = "$yeardue-".sprintf ("%0.2d", $monthdue)."-". sprintf("%0.2d",$daydue);
	
#warn $dateduef;
		if ($date) {
			$dateduef=$date;
		}
		# if ReturnBeforeExpiry ON the datedue can't be after borrower expirydate
		if (C4::Context->preference('ReturnBeforeExpiry') && $dateduef gt $borrower->{expiry}) {
			$dateduef=$borrower->{expiry};
		}
		$sth->execute($borrower->{'borrowernumber'}, $iteminformation->{'itemnumber'}, $dateduef, $env->{'branchcode'});
		$sth->finish;
		$iteminformation->{'issues'}++;
##Record in MARC the new data ,date_due as due date,issue count and the borrowernumber
		$itemrecord=XML_writeline($itemrecord, "issues", $iteminformation->{'issues'},"holdings");
		$itemrecord=XML_writeline($itemrecord, "date_due", $dateduef,"holdings");
		$itemrecord=XML_writeline($itemrecord, "borrowernumber", $borrower->{'borrowernumber'},"holdings");
		$itemrecord=XML_writeline($itemrecord, "itemlost", "0","holdings");
		# find today's date as timestamp
		my ($sec,$min,$hour,$mday,$mon,$year) = localtime();
		$year += 1900;
		$mon += 1;
		my $timestamp = sprintf("%4d%02d%02d%02d%02d%02d.0",
		$year,$mon,$mday,$hour,$min,$sec);
		$itemrecord=XML_writeline($itemrecord, "datelastseen", $timestamp,"holdings");
		##Now update the zebradb
		NEWmoditem($dbh,$itemrecord,$iteminformation->{'biblionumber'},$iteminformation->{'itemnumber'});
		# If it costs to borrow this book, charge it to the patron's account.
		my ($charge,$itemtype)=calc_charges($env, $iteminformation->{'itemnumber'}, $borrower->{'borrowernumber'});
		if ($charge > 0) {
			createcharge($env, $dbh, $iteminformation->{'itemnumber'}, $borrower->{'borrowernumber'}, $charge);
			$iteminformation->{'charge'}=$charge;
		}
		# Record the fact that this book was issued in SQL
		&UpdateStats($env,$env->{'branchcode'},'issue',$charge,'',$iteminformation->{'itemnumber'},$iteminformation->{'itemtype'},$borrower->{'borrowernumber'});
	}
return($error);
}

=head2 getLoanLength

Get loan length for an itemtype, a borrower type and a branch

my $loanlength = &getLoanLength($borrowertype,$itemtype,branchcode)

=cut

sub getLoanLength {
	my ($borrowertype,$itemtype,$branchcode) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("select issuelength from issuingrules where categorycode=? and itemtype=? and branchcode=?");
	# try to find issuelength & return the 1st available.
	# check with borrowertype, itemtype and branchcode, then without one of those parameters
	$sth->execute($borrowertype,$itemtype,$branchcode);
	my $loanlength = $sth->fetchrow_hashref;
	return $loanlength->{issuelength} if defined($loanlength);
	
	$sth->execute($borrowertype,$itemtype,"");
	$loanlength = $sth->fetchrow_hashref;
	return $loanlength->{issuelength} if defined($loanlength) && $loanlength->{issuelength} ne 'NULL';
	
	$sth->execute($borrowertype,"*",$branchcode);
	$loanlength = $sth->fetchrow_hashref;
	return $loanlength->{issuelength} if defined($loanlength) && $loanlength->{issuelength} ne 'NULL';

	$sth->execute("*",$itemtype,$branchcode);
	$loanlength = $sth->fetchrow_hashref;
	return $loanlength->{issuelength} if defined($loanlength) && $loanlength->{issuelength} ne 'NULL';

	$sth->execute($borrowertype,"*","");
	$loanlength = $sth->fetchrow_hashref;
	return $loanlength->{issuelength} if defined($loanlength) && $loanlength->{issuelength} ne 'NULL';

	$sth->execute("*","*",$branchcode);
	$loanlength = $sth->fetchrow_hashref;
	return $loanlength->{issuelength} if defined($loanlength) && $loanlength->{issuelength} ne 'NULL';

	$sth->execute("*",$itemtype,"");
	$loanlength = $sth->fetchrow_hashref;
	return $loanlength->{issuelength} if defined($loanlength) && $loanlength->{issuelength} ne 'NULL';

	$sth->execute("*","*","");
	$loanlength = $sth->fetchrow_hashref;
	return $loanlength->{issuelength} if defined($loanlength) && $loanlength->{issuelength} ne 'NULL';

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
	my ($barcode, $branch) = @_;
	my %env;
	my $messages;
	my $dbh = C4::Context->dbh;
	my $doreturn = 1;
	die '$branch not defined' unless defined $branch; # just in case (bug 170)
	# get information on item
	my ($itemrecord)=XMLgetitem($dbh,"",$barcode);
	$itemrecord=XML_xml2hash_onerecord($itemrecord);
	my $iteminformation=XMLmarc2koha_onerecord($dbh,$itemrecord,"holdings");
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
	my $branches = GetBranches();
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
	
		$sth->finish;
	$itemrecord=XML_writeline($itemrecord, "date_due", "","holdings");
	$itemrecord=XML_writeline($itemrecord, "borrowernumber", "","holdings");
	}
	my ($transfered, $mess, $item) = transferbook($branch, $barcode, 1);
	my ($sec,$min,$hour,$mday,$mon,$year) = localtime();
		$year += 1900;
		$mon += 1;
		my $timestamp = sprintf("%4d%02d%02d%02d%02d%02d.0",
		$year,$mon,$mday,$hour,$min,$sec);
		$itemrecord=XML_writeline($itemrecord, "datelastseen", $timestamp,"holdings");
		
		
	($borrower) = getpatroninformation(\%env, $currentborrower, 0);
	# transfer book to the current branch
	
	if ($transfered) {
		$messages->{'WasTransfered'} = 1; # FIXME is the "= 1" right?
	}
	# fix up the accounts.....
	if ($iteminformation->{'itemlost'}) {
		fixaccountforlostandreturned($iteminformation, $borrower);
		$messages->{'WasLost'} = 1; # FIXME is the "= 1" right?
		$itemrecord=XML_writeline($itemrecord, "itemlost", "","holdings");
	}
####WARNING-- FIXME#########	
### The following new script is commented out
## 	I did not understand what it is supposed to do.
## If a book is returned at one branch it is automatically recorded being in that branch by
## transferbook script. This scrip tries to find out whether it was sent thre
## Well whether sent or not it is physically there and transferbook records this fact in MARCrecord as well
## If this script is trying to do something else it should be uncommented and also add support for updating MARC record --TG
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 	check if we have a transfer for this document
#	my $checktransfer = checktransferts($iteminformation->{'itemnumber'});
# 	if we have a return, we update the line of transfers with the datearrived
#	if ($checktransfer){
#		my $sth = $dbh->prepare("update branchtransfers set datearrived = now() where itemnumber= ? AND datearrived IS NULL");
#		$sth->execute($iteminformation->{'itemnumber'});
#		$sth->finish;
# 		now we check if there is a reservation with the validate of transfer if we have one, we can 		set it with the status 'W'
#		my $updateWaiting = SetWaitingStatus($iteminformation->{'itemnumber'});
#	}
#	if we don't have a transfer on run, we check if the document is not in his homebranch and there is not a reservation, we transfer this one to his home branch directly if system preference Automaticreturn is turn on .
#	else {
#		my $checkreserves = CheckReserves($iteminformation->{'itemnumber'});
#		if (($iteminformation->{'homebranch'} ne $iteminformation->{'holdingbranch'}) and (not $checkreserves) and (C4::Context->preference("AutomaticItemReturn") == 1)){
#				my $automatictransfer = dotransfer($iteminformation->{'itemnumber'},$iteminformation->{'holdingbranch'},$iteminformation->{'homebranch'});
#				$messages->{'WasTransfered'} = 1;
#		}
#	}
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
	# fix up the overdues in accounts...
	fixoverduesonreturn($borrower->{'borrowernumber'}, $iteminformation->{'itemnumber'});
	$itemrecord=XML_writeline($itemrecord, "itemoverdue", "","holdings");
	# find reserves.....
	my ($resfound, $resrec) = CheckReserves($iteminformation->{'itemnumber'});
	if ($resfound) {
	#	my $tobrcd = ReserveWaiting($resrec->{'itemnumber'}, $resrec->{'borrowernumber'});
		$resrec->{'ResFound'} = $resfound;
		$messages->{'ResFound'} = $resrec;
	}
	##Now update the zebradb
		NEWmoditem($dbh,$itemrecord,$iteminformation->{'biblionumber'},$iteminformation->{'itemnumber'});
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
#		$usth = $dbh->prepare("update items set paidfor='' where itemnumber=?");
#		$usth->execute($itm);
#		$usth->finish;
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
		my $usth=$dbh->prepare("update accountlines set accounttype='F' where (borrowernumber = ?) and (itemnumber = ?) and (accountno = ?)");
		$usth->execute($brn,$itm,$data->{'accountno'});
		$usth->finish();
	}
	$sth->finish();
	return;
}


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
	my $amount = C4::Accounts2::checkaccount($env, $patroninformation->{'borrowernumber'}, $dbh);
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
	my $today = (1900+$datearr[5]).sprintf ("%02d", ($datearr[4]+1)).sprintf ("%02d", $datearr[3]);
	my @overdueitems;
	my $count = 0;
	my $sth = $dbh->prepare("SELECT issues.* , i.biblionumber as biblionumber,b.* FROM issues, items i,biblio b
			WHERE  i.itemnumber=issues.itemnumber
				AND i.biblionumber=b.biblionumber
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
sub checkreserve_to_delete {
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
		and (items.itemnumber=? )");
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
		my $today = (1900+$datearr[5]).sprintf ("%02d", ($datearr[4]+1)).sprintf ("%02d", $datearr[3]);
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
		my $today = (1900+$datearr[5]).sprintf ("%02d", ($datearr[4]+1)).sprintf ("%02d", $datearr[3]);
		# FIXME - MySQL knows about dates. Just use
		#	and issues.timestamp < curdate();
		$crit=" and !(issues.timestamp like '$today%') ";
	}

	# FIXME - Does the caller really need every single field from all
	# four tables?
	my $sth=$dbh->prepare("select * from issues,items where
	borrowernumber=? and issues.itemnumber=items.itemnumber and
	 returndate is null
	$crit order by issues.date_due");
	$sth->execute($borrowernumber);
	while (my $data = $sth->fetchrow_hashref) {

		my @datearr = localtime(time());
		my $todaysdate = (1900+$datearr[5]).sprintf ("%02d", ($datearr[4]+1)).sprintf ("%02d", $datearr[3]);
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
	my ($borrower) = @_;
	my $dbh = C4::Context->dbh;
	my $borrowernumber = $borrower->{'borrowernumber'};
	my %currentissues;
	my $bibliodata;
	my @results;
	my @datearr = localtime(time());
	my $todaysdate = (1900+$datearr[5])."-".sprintf ("%0.2d", ($datearr[4]+1))."-".sprintf ("%0.2d", $datearr[3]);
	my $counter = 0;
	my $select = "SELECT *
			FROM issues,items,biblio
			WHERE issues.borrowernumber  = ?
			AND issues.itemnumber      = items.itemnumber
			AND items.biblionumber      = biblio.biblionumber
			AND issues.returndate      IS NULL
			ORDER BY issues.date_due";
	#    print $select;
	my $sth=$dbh->prepare($select);
	$sth->execute($borrowernumber);
	while (my $data = $sth->fetchrow_hashref) { 	
		if ($data->{'date_due'}  lt $todaysdate) {
			$data->{'overdue'} = 1;
		}
		$currentissues{$counter} = $data;
		$counter++;
	}
	$sth->finish;
	
	return(\%currentissues);
}

# Not exported
sub checkwaiting {
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
	##If system preference "strictrenewals" is used This script will try to return $renewok=2 or $renewok=3 as error messages
	## 
	my ($env,$bornum,$itemnumber)=@_;
	my $dbh=C4::Context->dbh;
	my $renews = 1;
	my $resfound;
	my $resrec;
	my $renewokay; ##
	# Look in the issues table for this item, lent to this borrower,
	# and not yet returned.
my $borrower=getpatroninformation($dbh,$bornum,undef);
	if (C4::Context->preference("LibraryName") eq "NEU Grand Library"){
		## faculty members and privileged get renewal whatever the case may be
		if ($borrower->{'categorycode'} eq 'F' ||$borrower->{'categorycode'} eq 'P'){
		$renewokay = 1;
		return $renewokay;
		}
	}
	# FIXME - I think this function could be redone to use only one SQL call.
	my $sth1 = $dbh->prepare("select * from issues,items,biblio
								where (borrowernumber = ?)
								and (issues.itemnumber = ?)
								and items.biblionumber=biblio.biblionumber
								and returndate is null
								and items.itemnumber=issues.itemnumber");
	$sth1->execute($bornum,$itemnumber);
	if (my $data1 = $sth1->fetchrow_hashref) {
		# Found a matching item
	
		# See if this item may be renewed. 
		my $sth2 = $dbh->prepare("select renewalsallowed from itemtypes	where itemtypes.itemtype=?");
		$sth2->execute($data1->{itemtype});
		if (my $data2=$sth2->fetchrow_hashref) {
		$renews = $data2->{'renewalsallowed'};
		}
		if ($renews > $data1->{'renewals'}) {
			$renewokay= 1;
		}else{
			if (C4::Context->preference("strictrenewals")){
			$renewokay=3 ;
			}
		}
		$sth2->finish;
		 ($resfound, $resrec) = CheckReserves($itemnumber);
		if ($resfound) {
			if (C4::Context->preference("strictrenewals")){
			$renewokay=4;
			}else{
			       $renewokay = 0;
         			 }
		}
	}## item found
		 ($resfound, $resrec) = CheckReserves($itemnumber);
               		 if ($resfound) {
              		 	 if (C4::Context->preference("strictrenewals")){
						$renewokay=4;
						}else{
			   	   		 $renewokay = 0;
          				  }
					}	
#	}
	$sth1->finish;
if (C4::Context->preference("strictrenewals")){
	### A new system pref "allowRenewalsBefore" prevents the renewal before a set amount of days left before expiry
	## Try to find whether book can be renewed at this date
	my $loanlength;

	my $allowRenewalsBefore = C4::Context->preference("allowRenewalsBefore");
	my @nowarr = localtime(time);
	my $now = (1900+$nowarr[5])."-".($nowarr[4]+1)."-".$nowarr[3]; 

	# Find the issues record for this book### 
	my $sth=$dbh->prepare("select date_due  from issues where itemnumber=? and returndate is null");
	$sth->execute($itemnumber);
	my $issuedata=$sth->fetchrow;
	$sth->finish;

	#calculates the date on the we are  allowed to renew the item
	 $sth = $dbh->prepare("SELECT (DATE_SUB( ?, INTERVAL ? DAY))");
	$sth->execute($issuedata, $allowRenewalsBefore);
	my $startdate = $sth->fetchrow;

	$sth->finish;
	### Fixme we have a Date_diff function use that
	$sth = $dbh->prepare("SELECT DATEDIFF(CURRENT_DATE,?)");
	$sth->execute($startdate);
	my $difference = $sth->fetchrow;
	$sth->finish;
	if  ($difference < 0) {
	$renewokay=2 ;
	}
}##strictrenewals
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
	my ($env,$bornum,$itemnumber,$datedue)=@_;
	# mark book as renewed

	my $loanlength;
my $dbh=C4::Context->dbh;
my  $iteminformation = getiteminformation($env, $itemnumber,0);
	my $sth=$dbh->prepare("select date_due  from issues where itemnumber=? and returndate is null ");
	$sth->execute($itemnumber);
	my $issuedata=$sth->fetchrow;
	$sth->finish;
		

## We find a new datedue either from today or from the due_date of the book- if "strictrenewals" is in effect

if ($datedue eq "" ) {

		my  $borrower = getpatroninformation($env,$bornum,0);
		 $loanlength = getLoanLength($borrower->{'categorycode'},$iteminformation->{'itemtype'},$borrower->{'branchcode'});
	if (C4::Context->preference("strictrenewals")){
	my @nowarr = localtime(time);
	my $now = (1900+$nowarr[5])."-".($nowarr[4]+1)."-".$nowarr[3]; 
		if ($issuedata<=$now){
	
		$datedue=$issuedata;
		my $calendar = C4::Calendar::Calendar->new(branchcode => $borrower->{'branchcode'});
		my ($yeardue, $monthdue, $daydue) = split /-/, $datedue;
		($daydue, $monthdue, $yeardue) = $calendar->addDate($daydue, $monthdue, $yeardue, $loanlength);
		$datedue = "$yeardue-".sprintf ("%0.2d", $monthdue)."-". sprintf("%0.2d",$daydue);
		}
	}## stricrenewals	
		
	if ($datedue eq "" ){## incase $datedue chnaged above
		
		my  @datearr = localtime();
		$datedue = (1900+$datearr[5]).sprintf ("%02d", ($datearr[4]+1)).sprintf ("%02d", $datearr[3]);
		my $calendar = C4::Calendar::Calendar->new(branchcode => $borrower->{'branchcode'});
		my ($yeardue, $monthdue, $daydue) = split /-/, $datedue;
		($daydue, $monthdue, $yeardue) = $calendar->addDate($daydue, $monthdue, $yeardue, $loanlength);
		$datedue = "$yeardue-".sprintf ("%0.2d", $monthdue)."-". sprintf("%0.2d",$daydue);
		
	}




	# Update the issues record to have the new due date, and a new count
	# of how many times it has been renewed.
	#my $renews = $issuedata->{'renewals'} +1;
	$sth=$dbh->prepare("update issues set date_due = ?, renewals = renewals+1
		where borrowernumber=? and itemnumber=? and returndate is null");
	$sth->execute($datedue,$bornum,$itemnumber);
	$sth->finish;

	## Update items and marc record with new date -T.G
	my $iteminformation = getiteminformation($env, $itemnumber,0);
	&XMLmoditemonefield($dbh,$iteminformation->{'biblionumber'},$iteminformation->{'itemnumber'},'date_due',$datedue);
		
	# Log the renewal
	UpdateStats($env,$env->{'branchcode'},'renew','','',$itemnumber);

	# Charge a new rental fee, if applicable?
	my ($charge,$type)=calc_charges($env, $itemnumber, $bornum);
	if ($charge > 0){
		my $accountno=getnextacctno($env,$bornum,$dbh);
		$sth=$dbh->prepare("Insert into accountlines (borrowernumber,accountno,date,amount,description,accounttype,amountoutstanding,itemnumber)
							values (?,?,now(),?,?,?,?,?)");
		$sth->execute($bornum,$accountno,$charge,"Renewal of Rental Item $iteminformation->{'title'} $iteminformation->{'barcode'}",'Rent',$charge,$itemnumber);
		$sth->finish;
	#     print $account;
	}# end of rental charge
	

	}

 
	
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
	my ($env, $itemnumber, $bornum)=@_;
	my $charge=0;
	my $dbh = C4::Context->dbh;
	my $item_type;
	my $sth= $dbh->prepare("select itemtype from biblio,items where items.biblionumber=biblio.biblionumber and itemnumber=?");
	$sth->execute($itemnumber);
	my $itemtype=$sth->fetchrow;
	$sth->finish;
	
	my $sth1= $dbh->prepare("select rentalcharge from itemtypes where  itemtypes.itemtype=?");
	$sth1->execute($itemtype);
	
	$charge = $sth1->fetchrow;
	my $q2 = "select rentaldiscount from issuingrules,borrowers
              where (borrowers.borrowernumber = ?)
              and (borrowers.categorycode = issuingrules.categorycode)
              and (issuingrules.itemtype = ?)";
            my $sth2=$dbh->prepare($q2);
            $sth2->execute($bornum,$itemtype);
    if (my $data2=$sth2->fetchrow_hashref) {
		my $discount = $data2->{'rentaldiscount'};
		if ($discount eq 'NULL') {
		    $discount=0;
		}
		$charge = ($charge *(100 - $discount)) / 100;
		#               warn "discount is $discount";
	 }
        $sth2->finish;
        
	$sth1->finish;
	return ($charge,$itemtype);
}



sub createcharge {

    my ($env,$dbh,$itemnumber,$bornum,$charge) = @_;
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
    $sth->execute($bornum, $itemnumber, $nextaccntno, $charge, $charge);
    $sth->finish;
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

sub find_reserves {
    my ($itemnumber) = @_;
    my $dbh = C4::Context->dbh;
    my ($itemdata) = getiteminformation("", $itemnumber,0);
    my $sth = $dbh->prepare("select * from reserves where ((found = 'W') or (found is null)) and biblionumber = ? and cancellationdate is NULL order by priority, reservedate");
    $sth->execute($itemdata->{'biblionumber'});
    my $resfound = 0;
    my $resrec;
    my $lastrec;

    # FIXME - I'm not really sure what's going on here, but since we
    # only want one result, wouldn't it be possible (and far more
    # efficient) to do something clever in SQL that only returns one
    # set of values?
while ($resrec = $sth->fetchrow_hashref) {
	$lastrec = $resrec;
      if ($resrec->{'found'} eq "W") {
	    if ($resrec->{'itemnumber'} eq $itemnumber) {
		$resfound = 1;
	    }
        } else {
	    # FIXME - Use 'elsif' to avoid unnecessary indentation.
	    if ($resrec->{'constrainttype'} eq "a") {
		$resfound = 1;	
	    } else {
			my $consth = $dbh->prepare("select * from reserveconstraints where borrowernumber = ? and reservedate = ? and biblionumber = ? ");
			$consth->execute($resrec->{'borrowernumber'},$resrec->{'reservedate'},$resrec->{'biblionumber'});
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
	    $updsth->execute($itemnumber,$resrec->{'borrowernumber'},$resrec->{'reservedate'},$resrec->{'biblionumber'});
	    $updsth->finish;
	    last;
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

sub get_current_return_date_of {
    my (@itemnumbers) = @_;

    my $query = '
SELECT date_due,
       itemnumber
  FROM issues
  WHERE itemnumber IN ('.join(',', @itemnumbers).') AND returndate IS NULL
';
    return get_infos_of($query, 'itemnumber', 'date_due');
}

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


sub DeleteTransfer {
	my($itemnumber) = @_;
	my $dbh = C4::Context->dbh;
    	my $sth=$dbh->prepare("DELETE FROM branchtransfers
	where itemnumber=?
	AND datearrived is null ");
	$sth->execute($itemnumber);
	$sth->finish;
}

sub GetTransfersFromBib {
	my($frombranch,$tobranch) = @_;
	my $dbh = C4::Context->dbh;
    	my $sth=$dbh->prepare("SELECT itemnumber,datesent,frombranch FROM
	 branchtransfers 
	where frombranch=?
	AND tobranch=? 
	AND datearrived is null ");
	$sth->execute($frombranch,$tobranch);
	my @gettransfers;
	my $i=0;
	while (my $data=$sth->fetchrow_hashref){
		$gettransfers[$i]=$data;
		$i++;
    	}
    	$sth->finish;
    	return(@gettransfers);	
}

sub GetReservesToBranch {
	my($frombranch,$default) = @_;
	my $dbh = C4::Context->dbh;
    	my $sth=$dbh->prepare("SELECT borrowernumber,reservedate,itemnumber,timestamp FROM
	 reserves 
	where priority='0' AND cancellationdate is null  
	AND branchcode=?
	AND branchcode!=?
	AND found is null ");
	$sth->execute($frombranch,$default);
	my @transreserv;
	my $i=0;
	while (my $data=$sth->fetchrow_hashref){
		$transreserv[$i]=$data;
		$i++;
    	}
    	$sth->finish;
    	return(@transreserv);	
}

sub GetReservesForBranch {
	my($frombranch) = @_;
	my $dbh = C4::Context->dbh;
    	my $sth=$dbh->prepare("SELECT borrowernumber,reservedate,itemnumber,waitingdate FROM
	 reserves 
	where priority='0' AND cancellationdate is null 
	AND found='W' 
	AND branchcode=? order by reservedate");
	$sth->execute($frombranch);
	my @transreserv;
	my $i=0;
	while (my $data=$sth->fetchrow_hashref){
		$transreserv[$i]=$data;
		$i++;
    	}
    	$sth->finish;
    	return(@transreserv);	
}

sub checktransferts{
	my($itemnumber) = @_;
	my $dbh = C4::Context->dbh;
    	my $sth=$dbh->prepare("SELECT datesent,frombranch,tobranch FROM branchtransfers
        WHERE itemnumber = ? AND datearrived IS NULL");
	$sth->execute($itemnumber);
	my @tranferts = $sth->fetchrow_array;
	$sth->finish;

	return (@tranferts);
}
##Utility date function to prevent dependency on Date::Manip
sub DATE_diff {
my ($date1,$date2)=@_;
my $dbh=C4::Context->dbh;
my $sth = $dbh->prepare("SELECT DATEDIFF(?,?)");
	$sth->execute($date1,$date2);
	my $difference = $sth->fetchrow;
	$sth->finish;
return $difference;
}

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
