package C4::Circulation::Renewals;

# $Id$

#package to deal with Renewals
#written 7/11/99 by olwen@katipo.co.nz


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
use C4::Format;
use C4::Accounts;
use C4::InterfaceCDK;
use C4::Interface::RenewalsCDK;
use C4::Circulation::Issues;
use C4::Circulation::Main;
	# FIXME - C4::Circulation::Main and C4::Circulation::Renewals
	# use each other, so functions get redefined.
use C4::Search;
use C4::Scan;
use C4::Stats;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Circulation::Renewals - Old Koha module dealing with renewals

=head1 SYNOPSIS

  use C4::Circulation::Renewals;

=head1 DESCRIPTION

This module contains a function for checking whether a book may be
renewed.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&renewstatus &renewbook &bulkrenew);

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
# FIXME - This is identical to &C4::Circulation::Circ2::renewstatus,
# and virtually identical to &C4::Circulation::Renewals2::renewstatus.
# Pick one and stick with it.
sub renewstatus {
  # check renewal status
  # FIXME - Two people can't borrow the same book at once, so
  # presumably we can get $bornum from $itemno.
  my ($env,$dbh,$bornum,$itemno)=@_;
  my $renews = 1;		# FIXME - I think this is the maximum
				# number of allowed renewals.
  # FIXME - I think this function could be redone to use only one SQL
  # call.
  my $renewokay = 0;
  # Look in the issues table for this item, lent to this borrower,
  # and not yet returned.
  my $sth1 = $dbh->prepare("select * from issues
    where (borrowernumber = '$bornum')
    and (itemnumber = '$itemno')
    and returndate is null");
  $sth1->execute($bornum,$itemno);
  # Found a matching item
  if (my $data1 = $sth1->fetchrow_hashref) {
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

# FIXME - A different version of this function appears in
# C4::Circulation::Renewals2. Pick one and stick with it.
# FIXME - This function doesn't appear to be used. Presumably it's
# obsolete.
# Otherwise, it needs a POD.
sub renewbook {
  # mark book as renewed
  # FIXME - Get $dbh from C4::Context->dbh, instead of requiring
  # an additional argument.
  my ($env,$dbh,$bornum,$itemno,$datedue)=@_;
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
  my $odatedue = (@date[2]+0)."-".(@date[1]+0)."-".@date[0];
  my $sth=$dbh->prepare("select * from issues where borrowernumber=? and
    itemnumber=? and returndate is null");
  $sth->execute($bornum,$itemno);
  my $issuedata=$sth->fetchrow_hashref;
  $sth->finish;
  my $renews = $issuedata->{'renewals'} +1;
  my $sth=$dbh->prepare("update issues
    set date_due = ?, renewals = ?
    where borrowernumber=? and
    itemnumber=? and returndate is null");

  $sth->execute($datedue,$renews,$bornum,$itemno);
  $sth->finish;
  return($odatedue);
}

# FIXME - Only used in C4:InterfaceCDK. Presumably this function is
# obsolete.
# Otherwise, it needs a POD.
sub bulkrenew {
  my ($env,$dbh,$bornum,$amount,$borrower,$odues) = @_;
  my $sth = $dbh->prepare("select * from issues where borrowernumber = ? and returndate is null order by date_due");
  $sth->execute($bornum);
  my @items;
  my @issues;
  my @renewdef;
  my $x;
  my @barcodes;
  my @rstatuses;
  while (my $issrec = $sth->fetchrow_hashref) {
     my $itemdata = C4::Search::itemnodata($env,$dbh,$issrec->{'itemnumber'});
     my @date = split("-",$issrec->{'date_due'});
     #my $line = $issrec->{'date_due'}." ";
     my $line = @date[2]."-".@date[1]."-".@date[0]." ";
     my $renewstatus = renewstatus($env,$dbh,$bornum,$issrec->{'itemnumber'});
     my ($resbor,$resrec) = C4::Circulation::Main::checkreserve($env,
        $dbh,$issrec->{'itemnumber'});
     if ($resbor ne "") {
       $line .= "R";
       $rstatuses[$x] ="R";
     } elsif ($renewstatus == 0) {
       $line .= "N";
       $rstatuses[$x] = "N";
     } else {
       $line .= "Y";
       $rstatuses[$x] = "Y";
     }
     $line .= fmtdec($env,$issrec->{'renewals'},"20")." ";
     $line .= $itemdata->{'barcode'}." ".$itemdata->{'itemtype'}." ".$itemdata->{'title'};
     $items[$x] = $line;
     #debug_msg($env,$line);
     $issues[$x] = $issrec;
     $barcodes[$x] = $itemdata->{'barcode'};
     my $rdef = 1;
     if ($issrec->{'renewals'} > 0) {
       $rdef = 0;
     }
     $renewdef[$x] = $rdef;
     $x++;
  }
  if ($x < 1) {
     return;
  }
  my $renews = C4::Interface::RenewalsCDK::renew_window($env,
     \@items,$borrower,$amount,$odues);
  my $isscnt = $x;
  $x =0;
  my $y = 0;
  my @renew_errors = "";
  while ($x < $isscnt) {
    if (@$renews[$x] == 1) {
      my $issrec = $issues[$x];
      if ($rstatuses[$x] eq "Y") {
        renewbook($env,$dbh,$issrec->{'borrowernumber'},$issrec->{'itemnumber'},"");
        my $charge = C4::Circulation::Issues::calc_charges($env,$dbh,
           $issrec->{'itemnumber'},$issrec->{'borrowernumber'});
        if ($charge > 0) {
          C4::Circulation::Issues::createcharge($env,$dbh,
	  $issrec->{'itemnumber'},$issrec->{'borrowernumber'},$charge);
        }
        &UpdateStats($env,$env->{'branchcode'},'renew',$charge,'',$issrec->{'itemnumber'});
      } elsif ($rstatuses[$x] eq "N") {
        C4::InterfaceCDK::info_msg($env,
	   "</S>$barcodes[$x] - can't renew");
      } else {
        C4::InterfaceCDK::info_msg($env,
	   "</S>$barcodes[$x] - on reserve");
      }
    }
    $x++;
  }
  $sth->finish();
}

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
