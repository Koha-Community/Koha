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

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&getpatroninformation
	&currentissues &getissues &getiteminformation
	&issuebook &returnbook &find_reserves &transferbook &decode
	&calc_charges);

# &getbranches &getprinters &getbranch &getprinter => moved to C4::Koha.pm

=item getpatroninformation

  ($borrower, $flags) = &getpatroninformation($env, $borrowernumber,
					$cardnumber);

Looks up a patron and returns information about him or her. If
C<$borrowernumber> is true (nonzero), C<&getpatroninformation> looks
up the borrower by number; otherwise, it looks up the borrower by card
number.

C<$env> is effectively ignored, but should be a reference-to-hash.

C<$borrower> is a reference-to-hash whose keys are the fields of the
borrowers table in the Koha database. In addition,
C<$borrower-E<gt>{flags}> is the same as C<$flags>.

C<$flags> is a reference-to-hash giving more detailed information
about the patron. Its keys act as flags: if they are set, then the key
is a reference-to-hash that gives further details:

  if (exists($flags->{LOST}))
  {
	  # Patron's card was reported lost
	  print $flags->{LOST}{message}, "\n";
  }

Each flag has a C<message> key, giving a human-readable explanation of
the flag. If the state of a flag means that the patron should not be
allowed to borrow any more books, then it will have a C<noissues> key
with a true value.

The possible flags are:

=over 4

=item CHARGES

Shows the patron's credit or debt, if any.

=item GNA

(Gone, no address.) Set if the patron has left without giving a
forwarding address.

=item LOST

Set if the patron's card has been reported as lost.

=item DBARRED

Set if the patron has been debarred.

=item NOTES

Any additional notes about the patron.

=item ODUES

Set if the patron has overdue items. This flag has several keys:

C<$flags-E<gt>{ODUES}{itemlist}> is a reference-to-array listing the
overdue items. Its elements are references-to-hash, each describing an
overdue item. The keys are selected fields from the issues, biblio,
biblioitems, and items tables of the Koha database.

C<$flags-E<gt>{ODUES}{itemlist}> is a string giving a text listing of
the overdue items, one per line.

=item WAITING

Set if any items that the patron has reserved are available.

C<$flags-E<gt>{WAITING}{itemlist}> is a reference-to-array listing the
available items. Each element is a reference-to-hash whose keys are
fields from the reserves table of the Koha database.

=back

=cut
#'
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
	$env->{'mess'} = $query;
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
	return ($borrower, $flags, $accessflagshash);
}

=item decode

  $str = &decode($chunk);

Decodes a segment of a string emitted by a CueCat barcode scanner and
returns it.

=cut
#'
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

=item getiteminformation

  $item = &getiteminformation($env, $itemnumber, $barcode);

Looks up information about an item, given either its item number or
its barcode. If C<$itemnumber> is a nonzero value, it is used;
otherwise, C<$barcode> is used.

C<$env> is effectively ignored, but should be a reference-to-hash.

C<$item> is a reference-to-hash whose keys are fields from the biblio,
items, and biblioitems tables of the Koha database. It may also
contain the following keys:

=over 4

=item C<date_due>

The due date on this item, if it has been borrowed and not returned
yet. The date is in YYYY-MM-DD format.

=item C<loanlength>

The length of time for which the item can be borrowed, in days.

=item C<notforloan>

True if the item may not be borrowed.

=back

=cut
#'
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
	# FIXME - Style: instead of putting the entire rest of the
	# function in a block, just say
	#	return undef unless $iteminformation;
	# That way, the rest of the function needn't be indented as much.
	if ($iteminformation) {
		$sth=$dbh->prepare("select date_due from issues where itemnumber=? and isnull(returndate)");
		$sth->execute($iteminformation->{'itemnumber'});
		my ($date_due) = $sth->fetchrow;
		$iteminformation->{'date_due'}=$date_due;
		$sth->finish;
		# FIXME - The Dewey code is a string, not a number. Besides,
		# "000" is a perfectly valid Dewey code.
		#$iteminformation->{'dewey'}=~s/0*$//;
		($iteminformation->{'dewey'} == 0) && ($iteminformation->{'dewey'}='');
		# FIXME - fetchrow_hashref is documented as being inefficient.
		# Perhaps this should be rewritten as
		#	$sth = $dbh->prepare("select loanlength, notforloan ...");
		#	$sth->execute;
		#	($iteminformation->{loanlength},
		#	 $iteminformation->{notforloan}) = fetchrow_array;
		$sth=$dbh->prepare("select * from itemtypes where itemtype=?");
		$sth->execute($iteminformation->{'itemtype'});
		my $itemtype=$sth->fetchrow_hashref;
		$iteminformation->{'loanlength'}=$itemtype->{'loanlength'};
		$iteminformation->{'notforloan'}=$itemtype->{'notforloan'};
		$sth->finish;
	}
	return($iteminformation);
}

=item transferbook

  ($dotransfer, $messages, $iteminformation) =
	&transferbook($newbranch, $barcode, $ignore_reserves);

Transfers an item to a new branch. If the item is currently on loan,
it is automatically returned before the actual transfer.

C<$newbranch> is the code for the branch to which the item should be
transferred.

C<$barcode> is the barcode of the item to be transferred.

If C<$ignore_reserves> is true, C<&transferbook> ignores reserves.
Otherwise, if an item is reserved, the transfer fails.

Returns three values:

C<$dotransfer> is true iff the transfer was successful.

C<$messages> is a reference-to-hash which may have any of the
following keys:

=over 4

=item C<BadBarcode>

There is no item in the catalog with the given barcode. The value is
C<$barcode>.

=item C<IsPermanent>

The item's home branch is permanent. This doesn't prevent the item
from being transferred, though. The value is the code of the item's
home branch.

=item C<DestinationEqualsHolding>

The item is already at the branch to which it is being transferred.
The transfer is nonetheless considered to have failed. The value
should be ignored.

=item C<WasReturned>

The item was on loan, and C<&transferbook> automatically returned it
before transferring it. The value is the borrower number of the patron
who had the item.

=item C<ResFound>

The item was reserved. The value is a reference-to-hash whose keys are
fields from the reserves table of the Koha database, and
C<biblioitemnumber>. It also has the key C<ResFound>, whose value is
either C<Waiting> or C<Reserved>.

=item C<WasTransferred>

The item was eligible to be transferred. Barring problems
communicating with the database, the transfer should indeed have
succeeded. The value should be ignored.

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
	$dbh->do("UPDATE items SET	datelastseen  = now(), holdingbranch = $tbr WHERE	items.itemnumber = $itm");
	return;
}

=item issuebook

  ($iteminformation, $datedue, $rejected, $question, $questionnumber,
   $defaultanswer, $message) =
	&issuebook($env, $patroninformation, $barcode, $responses, $date);

Issue a book to a patron.

C<$env-E<gt>{usercode}> will be used in the usercode field of the
statistics table of the Koha database when this transaction is
recorded.

C<$env-E<gt>{datedue}>, if given, specifies the date on which the book
is due back. This should be a string of the form "YYYY-MM-DD".

C<$env-E<gt>{branchcode}> is the code of the branch where this
transaction is taking place.

C<$patroninformation> is a reference-to-hash giving information about
the person borrowing the book. This is the first value returned by
C<&getpatroninformation>.

C<$barcode> is the bar code of the book being issued.

C<$responses> is a reference-to-hash. It represents the answers to the
questions asked by the C<$question>, C<$questionnumber>, and
C<$defaultanswer> return values (see below). The keys are numbers, and
the values can be "Y" or "N".

C<$date> is an optional date in the form "YYYY-MM-DD". If specified,
then only fines and charges up to that date will be considered when
checking to see whether the patron owes too much money to be lent a
book.

C<&issuebook> returns an array of seven values:

C<$iteminformation> is a reference-to-hash describing the item just
issued. This in a form similar to that returned by
C<&getiteminformation>.

C<$datedue> is a string giving the date when the book is due, in the
form "YYYY-MM-DD".

C<$rejected> is either a string, or -1. If it is defined and is a
string, then the book may not be issued, and C<$rejected> gives the
reason for this. If C<$rejected> is -1, then the book may not be
issued, but no reason is given.

If there is a problem or question (e.g., the book is reserved for
another patron), then C<$question>, C<$questionnumber>, and
C<$defaultanswer> will be set. C<$questionnumber> indicates the
problem. C<$question> is a text string asking how to resolve the
problem, as a yes-or-no question, and C<$defaultanswer> is either "Y"
or "N", giving the default answer. The questions, their numbers, and
default answers are:

=over 4

=item 1: "Issued to <name>. Mark as returned?" (Y)

=item 2: "Waiting for <patron> at <branch>. Allow issue?" (N)

=item 3: "Cancel reserve for <patron>?" (N)

=item 4: "Book is issued to this borrower. Renew?" (Y)

=item 5: "Reserved for <patron> at <branch> since <date>. Allow issue?" (N)

=item 6: "Set reserve for <patron> to waiting and transfer to <branch>?" (Y)

This is asked if the answer to question 5 was "N".

=item 7: "Cancel reserve for <patron>?" (N)

=back

C<$message>, if defined, is an additional information message, e.g., a
rental fee notice.

=cut
#'
# FIXME - The business with $responses is absurd. For one thing, these
# questions should have names, not numbers. For another, it'd be
# better to have the last argument be %extras. Then scripts can call
# this function with
#	&issuebook(...,
#		-renew		=> 1,
#		-mark_returned	=> 0,
#		-cancel_reserve	=> 1,
#		...
#		);
# and the script can use
#	if (defined($extras{"-mark_returned"}) && $extras{"-mark_returned"})
# Heck, the $date argument should go in there as well.
#
# Also, there might be several reasons why a book can't be issued, but
# this API only supports asking one question at a time. Perhaps it'd
# be better to return a ref-to-list of problem IDs. Then the calling
# script can display a list of all of the problems at once.
#
# Is it this function's place to decide the default answer to the
# various questions? Why not document the various problems and allow
# the caller to decide?
sub issuebook {
	my ($env, $patroninformation, $barcode, $responses, $date) = @_;
	my $dbh = C4::Context->dbh;
	my $iteminformation = getiteminformation($env, 0, $barcode);
	my ($datedue);
	my ($rejected,$question,$defaultanswer,$questionnumber, $noissue);
	my $message;

	# See if there's any reason this book shouldn't be issued to this
	# patron.
	SWITCH: {	# FIXME - Yes, we know it's a switch. Tell us what it's for.
		if ($patroninformation->{'gonenoaddress'}) {
			$rejected="Patron is gone, with no known address.";
			last SWITCH;
		}
		if ($patroninformation->{'lost'}) {
			$rejected="Patron's card has been reported lost.";
			last SWITCH;
		}
		if ($patroninformation->{'debarred'}) {
			$rejected="Patron is Debarred";
			last SWITCH;
		}
		my $amount = checkaccount($env,$patroninformation->{'borrowernumber'}, $dbh,$date);
		# FIXME - "5" shouldn't be hardcoded. An Italian library might
		# be generous enough to lend a book to a patron even if he
		# does still owe them 5 lire.
		if ($amount > 5 && $patroninformation->{'categorycode'} ne 'L' &&
								$patroninformation->{'categorycode'} ne 'W' &&
								$patroninformation->{'categorycode'} ne 'I' &&
								$patroninformation->{'categorycode'} ne 'B' &&
								$patroninformation->{'categorycode'} ne 'P') {
		# FIXME - What do these category codes mean?
		$rejected = sprintf "Patron owes \$%.02f.", $amount;
		last SWITCH;
		}
		# FIXME - This sort of error-checking should be placed closer
		# to the test; in this case, this error-checking should be
		# done immediately after the call to &getiteminformation.
		unless ($iteminformation) {
			$rejected = "$barcode is not a valid barcode.";
			last SWITCH;
		}
		if ($iteminformation->{'notforloan'} == 1) {
			$rejected="Item not for loan.";
			last SWITCH;
		}
		if ($iteminformation->{'wthdrawn'} == 1) {
			$rejected="Item withdrawn.";
			last SWITCH;
		}
		if ($iteminformation->{'restricted'} == 1) {
			$rejected="Restricted item.";
			last SWITCH;
		}
		if ($iteminformation->{'itemtype'} eq 'REF') {
			$rejected="Reference item:  Not for loan.";
			last SWITCH;
		}
		my ($currentborrower) = currentborrower($iteminformation->{'itemnumber'});
		if ($currentborrower eq $patroninformation->{'borrowernumber'}) {
	# Already issued to current borrower. Ask whether the loan should
	# be renewed.
			my ($renewstatus) = renewstatus($env,$dbh,$patroninformation->{'borrowernumber'}, $iteminformation->{'itemnumber'});
			if ($renewstatus == 0) {
				$rejected="No more renewals allowed for this item.";
				last SWITCH;
			} else {
				if ($responses->{4} eq '') {
					$questionnumber = 4;
					$question = "Book is issued to this borrower.\nRenew?";
					$defaultanswer = 'Y';
					last SWITCH;
				} elsif ($responses->{4} eq 'Y') {
					my ($charge,$itemtype) = calc_charges($env, $dbh, $iteminformation->{'itemnumber'}, $patroninformation->{'borrowernumber'});
					if ($charge > 0) {
						createcharge($env, $dbh, $iteminformation->{'itemnumber'}, $patroninformation->{'borrowernumber'}, $charge);
						$iteminformation->{'charge'} = $charge;
					}
					&UpdateStats($env,$env->{'branchcode'},'renew',$charge,'',$iteminformation->{'itemnumber'},$iteminformation->{'itemtype'},$patroninformation->{'borrowernumber'});
					renewbook($env,$dbh, $patroninformation->{'borrowernumber'}, $iteminformation->{'itemnumber'});
					$noissue=1;
				} else {
					$rejected=-1;
					last SWITCH;
				}
			}
		} elsif ($currentborrower ne '') {
			# This book is currently on loan, but not to the person
			# who wants to borrow it now.
			my ($currborrower, $cbflags) = getpatroninformation($env,$currentborrower,0);
			if ($responses->{1} eq '') {
				$questionnumber=1;
				$question = "Issued to $currborrower->{'firstname'} $currborrower->{'surname'} ($currborrower->{'cardnumber'}).\nMark as returned?";
				$defaultanswer='Y';
				last SWITCH;
			} elsif ($responses->{1} eq 'Y') {
				returnbook($iteminformation->{'barcode'}, $env->{'branchcode'});
			} else {
				$rejected=-1;
				last SWITCH;
			}
		}

		# See if the item is on reserve.
		my ($restype, $res) = CheckReserves($iteminformation->{'itemnumber'});
		if ($restype) {
			my $resbor = $res->{'borrowernumber'};
			if ($resbor eq $patroninformation->{'borrowernumber'}) {
				# The item is on reserve to the current patron
				FillReserve($res);
			} elsif ($restype eq "Waiting") {
				# The item is on reserve and waiting, but has been
				# reserved by some other patron.
				my ($resborrower, $flags)=getpatroninformation($env, $resbor,0);
				my $branches = getbranches();
				my $branchname = $branches->{$res->{'branchcode'}}->{'branchname'};
				if ($responses->{2} eq '') {
					$questionnumber=2;
					# FIXME - Assumes HTML
					$question="<font color=red>Waiting</font> for $resborrower->{'firstname'} $resborrower->{'surname'} ($resborrower->{'cardnumber'}) at $branchname \nAllow issue?";
					$defaultanswer='N';
					last SWITCH;
				} elsif ($responses->{2} eq 'N') {
					$rejected=-1;
					last SWITCH;
				} else {
					if ($responses->{3} eq '') {
						$questionnumber=3;
						$question="Cancel reserve for $resborrower->{'firstname'} $resborrower->{'surname'} ($resborrower->{'cardnumber'})?";
						$defaultanswer='N';
						last SWITCH;
					} elsif ($responses->{3} eq 'Y') {
						CancelReserve(0, $res->{'itemnumber'}, $res->{'borrowernumber'});
					}

}
			} elsif ($restype eq "Reserved") {
				# The item is on reserve for someone else.
				my ($resborrower, $flags)=getpatroninformation($env, $resbor,0);
				my $branches = getbranches();
				my $branchname = $branches->{$res->{'branchcode'}}->{'branchname'};
				if ($responses->{5} eq '' && $responses->{7} eq '') {
					$questionnumber=5;
					$question="Reserved for $resborrower->{'firstname'} $resborrower->{'surname'} ($resborrower->{'cardnumber'}) since $res->{'reservedate'} \nAllow issue?";
					$defaultanswer='N';
					if ($responses->{6} eq 'Y') {
					   my $tobrcd = ReserveWaiting($res->{'itemnumber'}, $res->{'borrowernumber'});
					   transferbook($tobrcd,$barcode, 1);
					   $message = "Item should now be waiting at $branchname";
                                        }
					last SWITCH;
				} elsif ($responses->{5} eq 'N') {
					if ($responses->{6} eq '') {
						$questionnumber=6;
						$question="Set reserve for $resborrower->{'firstname'} $resborrower->{'surname'} ($resborrower->{'cardnumber'}) to waiting and transfer to $branchname?";
						$defaultanswer='N';
					} elsif ($responses->{6} eq 'Y') {
						my $tobrcd = ReserveWaiting($res->{'itemnumber'}, $res->{'borrowernumber'});
						transferbook($tobrcd, $barcode, 1);
						$message = "Item should now be waiting at $branchname";
					}
					$rejected=-1;
					last SWITCH;
				} else {
					if ($responses->{7} eq '') {
						$questionnumber=7;
						$question="Cancel reserve for $resborrower->{'firstname'} $resborrower->{'surname'} ($resborrower->{'cardnumber'})?";
						$defaultanswer='N';
						last SWITCH;
					} elsif ($responses->{7} eq 'Y') {
						CancelReserve(0, $res->{'itemnumber'}, $res->{'borrowernumber'});
					}
				}
			}
		}
	}
    my $dateduef;
    unless (($question) || ($rejected) || ($noissue)) {
		# There's no reason why the item can't be issued.
		# FIXME - my $loanlength = $iteminformation->{loanlength} || 21;
		my $loanlength=21;
		if ($iteminformation->{'loanlength'}) {
			$loanlength=$iteminformation->{'loanlength'};
		}
		my $ti=time;		# FIXME - Never used
		my $datedue=time+($loanlength)*86400;
		# FIXME - Could just use POSIX::strftime("%Y-%m-%d", localtime);
		# That's what it's for. Or, in this case:
		#	$dateduef = $env->{datedue} ||
		#		strftime("%Y-%m-%d", localtime(time +
		#				     $loanlength * 86400));
		my @datearr = localtime($datedue);
		$dateduef = (1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
		if ($env->{'datedue'}) {
			$dateduef=$env->{'datedue'};
		}
		$dateduef=~ s/2001\-4\-25/2001\-4\-26/;
			# FIXME - What's this for? Leftover from debugging?

		# Record in the database the fact that the book was issued.
		my $sth=$dbh->prepare("insert into issues (borrowernumber, itemnumber, date_due, branchcode) values (?,?,?,?)");
		$sth->execute($patroninformation->{'borrowernumber'}, $iteminformation->{'itemnumber'}, $dateduef, $env->{'branchcode'});
		$sth->finish;
		$iteminformation->{'issues'}++;
		$sth=$dbh->prepare("update items set issues=?,datelastseen=now() where itemnumber=?");
		$sth->execute($iteminformation->{'issues'},$iteminformation->{'itemnumber'});
		$sth->finish;
		# If it costs to borrow this book, charge it to the patron's account.
		my ($charge,$itemtype)=calc_charges($env, $dbh, $iteminformation->{'itemnumber'}, $patroninformation->{'borrowernumber'});
		if ($charge > 0) {
			createcharge($env, $dbh, $iteminformation->{'itemnumber'}, $patroninformation->{'borrowernumber'}, $charge);
			$iteminformation->{'charge'}=$charge;
		}
		# Record the fact that this book was issued.
		&UpdateStats($env,$env->{'branchcode'},'issue',$charge,'',$iteminformation->{'itemnumber'},$iteminformation->{'itemtype'},$patroninformation->{'borrowernumber'});
	}

	if ($iteminformation->{'charge'}) {
		$message=sprintf "Rental charge of \$%.02f applies.", $iteminformation->{'charge'};
	}
	return ($iteminformation, $dateduef, $rejected, $question, $questionnumber, $defaultanswer, $message);
}



=item returnbook

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
#'
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
		doreturn($borrower->{'borrowernumber'}, $iteminformation->{'itemnumber'});
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
		# Mark the item as not being lost.
		updateitemlost($iteminformation->{'itemnumber'});
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

# doreturn
# Takes a borrowernumber and an itemnuber.
# Updates the 'issues' table to mark the item as returned (assuming
# that it's currently on loan to the given borrower. Otherwise, the
# item remains on loan.
# Updates items.datelastseen for the item.
# Not exported
# FIXME - This is only used in &returnbook. Why make it into a
# separate function? (is this a recognizable step in the return process? - acli)
sub doreturn {
	my ($brn, $itm) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("update issues set returndate = now() where (borrowernumber = ?)
		and (itemnumber = ?) and (returndate is null)");
	$sth->execute($brn,$itm);
	$sth->finish;
	$sth=$dbh->prepare("update items set datelastseen=now() where itemnumber=?");
	$sth->execute($itm);
	$sth->finish;
	return;
}

# updateitemlost
# Marks an item as not being lost.
# Not exported
sub updateitemlost{
	my ($itemno)=@_;
	my $dbh = C4::Context->dbh;

	my $sth = $dbh->prepare("UPDATE items SET itemlost = 0 WHERE	itemnumber =?");
	$sth->execute($itemno);
	$sth->finish();
}

# Not exported
sub fixaccountforlostandreturned {
	my ($iteminfo, $borrower) = @_;
	my %env;
	my $dbh = C4::Context->dbh;
	my $itm = $iteminfo->{'itemnumber'};
	# check for charge made for lost book
	my $sth = $dbh->prepare("select * from accountlines where (itemnumber = ?)
				and (accounttype='L' or accounttype='Rep') order by date desc");
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

# Not exported
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

=item currentissues

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

=item getissues

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
	my $select = "SELECT issues.timestamp      AS timestamp,
				issues.date_due       AS date_due,
				items.biblionumber    AS biblionumber,
				items.itemnumber    AS itemnumber,
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

# Not exported
# FIXME - This is nearly-identical to &C4::Accounts::checkaccount
sub checkaccount  {
# Stolen from Accounts.pm
  #take borrower number
  #check accounts and list amounts owing
	my ($env,$bornumber,$dbh,$date)=@_;
	my $select="SELECT SUM(amountoutstanding) AS total
			FROM accountlines
		WHERE borrowernumber = ?
			AND amountoutstanding<>0";
	my @bind = ($bornumber);
	if ($date ne ''){
	$select.=" AND date < ?";
	push(@bind,$date);
	}
	#  print $select;
	my $sth=$dbh->prepare($select);
	$sth->execute(@bind);
	my $data=$sth->fetchrow_hashref;
	my $total = $data->{'total'};
	$sth->finish;
	# output(1,2,"borrower owes $total");
	#if ($total > 0){
	#  # output(1,2,"borrower owes $total");
	#  if ($total > 5){
	#    reconcileaccount($env,$dbh,$bornumber,$total);
	#  }
	#}
	#  pause();
	return($total);
}

# FIXME - This is identical to &C4::Circulation::Renewals::renewstatus.
# Pick one and stick with it.
sub renewstatus {
# Stolen from Renewals.pm
  # check renewal status
  my ($env,$dbh,$bornum,$itemno)=@_;
  my $renews = 1;
  my $renewokay = 0;
  my $sth1 = $dbh->prepare("select * from issues
    where (borrowernumber = ?)
    and (itemnumber = ?)
    and returndate is null");
  $sth1->execute($bornum,$itemno);
  if (my $data1 = $sth1->fetchrow_hashref) {
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

sub renewbook {
# Stolen from Renewals.pm
  # mark book as renewed
  my ($env,$dbh,$bornum,$itemno,$datedue)=@_;
  $datedue=$env->{'datedue'};
  if ($datedue eq "" ) {
    my $loanlength=21;
    my $sth=$dbh->prepare("Select * from biblioitems,items,itemtypes
       where (items.itemnumber = ?)
       and (biblioitems.biblioitemnumber = items.biblioitemnumber)
       and (biblioitems.itemtype = itemtypes.itemtype)");
    $sth->execute($itemno);
    if (my $data=$sth->fetchrow_hashref) {
      $loanlength = $data->{'loanlength'}
    }
    $sth->finish;
    my $ti = time;
    my $datedu = time + ($loanlength * 86400);
    my @datearr = localtime($datedu);
    $datedue = (1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
  }
  my @date = split("-",$datedue);
  my $odatedue = ($date[2]+0)."-".($date[1]+0)."-".$date[0];
  my $sth=$dbh->prepare("select * from issues where borrowernumber=? and
    itemnumber=? and returndate is null");
  $sth->execute($bornum,$itemno);
  my $issuedata=$sth->fetchrow_hashref;
  $sth->finish;
  my $renews = $issuedata->{'renewals'} +1;
  $sth=$dbh->prepare("update issues
    set date_due = ?, renewals = ?
    where borrowernumber=? and
    itemnumber=? and returndate is null");

  $sth->execute($datedue,$renews,$bornum,$itemno);
  $sth->finish;
  return($odatedue);
}

# FIXME - This is almost, but not quite, identical to
# &C4::Circulation::Issues::calc_charges and
# &C4::Circulation::Renewals2::calc_charges.
# Pick one and stick with it.
sub calc_charges {
# Stolen from Issues.pm
# calculate charges due
    my ($env, $dbh, $itemno, $bornum)=@_;
#    if (!$dbh){
#      $dbh=C4Connect();
#    }
    my $charge=0;
#    open (FILE,">>/tmp/charges");
    my $item_type;
    my $sth1= $dbh->prepare("select itemtypes.itemtype,rentalcharge from items,biblioitems,itemtypes
    where (items.itemnumber =?)
    and (biblioitems.biblioitemnumber = items.biblioitemnumber)
    and (biblioitems.itemtype = itemtypes.itemtype)");
#    print FILE "$q1\n";
    $sth1->execute($itemno);
    if (my $data1=$sth1->fetchrow_hashref) {
	$item_type = $data1->{'itemtype'};
	$charge = $data1->{'rentalcharge'};
#	print FILE "charge is $charge\n";
	my $sth2=$dbh->prepare("select rentaldiscount from borrowers,categoryitem
	where (borrowers.borrowernumber = ?)
	and (borrowers.categorycode = categoryitem.categorycode)
	and (categoryitem.itemtype = ?)");
#	warn $q2;
	$sth2->execute($bornum,$item_type);
	if (my $data2=$sth2->fetchrow_hashref) {
	    my $discount = $data2->{'rentaldiscount'};
#	    print FILE "discount is $discount";
	    if ($discount eq 'NULL') {
	      $discount=0;
	    }
	    $charge = ($charge *(100 - $discount)) / 100;
	}
	$sth2->finish;
    }
    $sth1->finish;
#    close FILE;
    return ($charge, $item_type);
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

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
