package C4::Circulation::Renewals2;

# $Id$

#package to deal with Renewals
#written 7/11/99 by olwen@katipo.co.nz

#modified by chris@katipo.co.nz
#18/1/2000
#need to update stats with renewals


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
use C4::Stats;
use C4::Accounts2;
use C4::Circulation::Circ2;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Circulation::Renewals2 - Koha functions for renewals

=head1 SYNOPSIS

  use C4::Circulation::Renewals2;

=head1 DESCRIPTION

This module provides a few functions for handling loan renewals.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&renewstatus &renewbook &calc_charges);

=item renewstatus

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
#'
# FIXME - This is virtually identical to
# &C4::Circulation::Circ2::renewstatus and
# &C4::Circulation::Renewals::renewstatus. Pick one and stick with it.
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
  my $q1 = "select * from issues
    where (borrowernumber = '$bornum')
    and (itemnumber = '$itemno')
    and returndate is null";
  my $sth1 = $dbh->prepare($q1);
  $sth1->execute;
  if (my $data1 = $sth1->fetchrow_hashref) {
    # Found a matching item

    # See if this item may be renewed. This query is convoluted
    # because it's a bit messy: given the item number, we need to find
    # the biblioitem, which gives us the itemtype, which tells us
    # whether it may be renewed.
    my $q2 = "select renewalsallowed from items,biblioitems,itemtypes
       where (items.itemnumber = '$itemno')
       and (items.biblioitemnumber = biblioitems.biblioitemnumber)
       and (biblioitems.itemtype = itemtypes.itemtype)";
    my $sth2 = $dbh->prepare($q2);
    $sth2->execute;
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

=item renewbook

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
#'
# FIXME - A simpler version of this function appears in
# C4::Circulation::Renewals. Pick one and stick with it.
# There's also a &C4::Circulation::Circ2::renewbook.
# I think this function is only used in 'renewscript.pl'.
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
    my $query= "Select * from biblioitems,items,itemtypes
       where (items.itemnumber = '$itemno')
       and (biblioitems.biblioitemnumber = items.biblioitemnumber)
       and (biblioitems.itemtype = itemtypes.itemtype)";
    my $sth=$dbh->prepare($query);
    $sth->execute;
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
  my $issquery = "select * from issues where borrowernumber='$bornum' and
    itemnumber='$itemno' and returndate is null";
  my $sth=$dbh->prepare($issquery);
  $sth->execute;
  my $issuedata=$sth->fetchrow_hashref;
	# FIXME - Error-checking
  $sth->finish;

  # Update the issues record to have the new due date, and a new count
  # of how many times it has been renewed.
  my $renews = $issuedata->{'renewals'} +1;
  my $updquery = "update issues
    set date_due = '$datedue', renewals = '$renews'
    where borrowernumber='$bornum' and
    itemnumber='$itemno' and returndate is null";
		# FIXME - Use $dbh->do()
  $sth=$dbh->prepare($updquery);
  $sth->execute;
  $sth->finish;

  # Log the renewal
  UpdateStats($env,$env->{'branchcode'},'renew','','',$itemno);

  # Charge a new rental fee, if applicable?
  my ($charge,$type)=calc_charges($env, $itemno, $bornum);
  if ($charge > 0){
    my $accountno=getnextacctno($env,$bornum,$dbh);
    my $item=getiteminformation($env, $itemno);
    my $account="Insert into accountlines
    (borrowernumber,accountno,date,amount,description,accounttype,amountoutstanding,itemnumber)
    values
    (?,?,now(),?,?,?,?,?)";
    $sth=$dbh->prepare($account);
    $sth->execute($bornum,$accountno,$charge,"Renewal of Rental Item $item->{'title'} $item->{'barcode'}",
    'Rent',$charge,$itemno)";
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
#'
# FIXME - This is very similar to
# &C4::Circulation::Issues::calc_charges and
# &C4::Circulation::Circ2::calc_charges.
# Pick one and stick with it.
sub calc_charges {
  # calculate charges due
  my ($env, $itemno, $bornum)=@_;
  my $charge=0;
  my $dbh = C4::Context->dbh;
  my $item_type;

  # Get the book's item type and rental charge (via its biblioitem).
  my $q1 = "select itemtypes.itemtype,rentalcharge from
  items,biblioitems,itemtypes
  where (items.itemnumber ='$itemno')
  and (biblioitems.biblioitemnumber = items.biblioitemnumber)
  and (biblioitems.itemtype = itemtypes.itemtype)";
  my $sth1= $dbh->prepare($q1);
  $sth1->execute;
  # FIXME - Why not just use fetchrow_array?
  if (my $data1=$sth1->fetchrow_hashref) {
    $item_type = $data1->{'itemtype'};
    $charge = $data1->{'rentalcharge'};

    # Figure out the applicable rental discount
    my $q2 = "select rentaldiscount from
    borrowers,categoryitem
    where (borrowers.borrowernumber = '$bornum')
    and (borrowers.categorycode = categoryitem.categorycode)
    and (categoryitem.itemtype = '$item_type')";
    my $sth2=$dbh->prepare($q2);
    $sth2->execute;
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

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
