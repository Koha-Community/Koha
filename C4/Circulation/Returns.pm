package C4::Circulation::Returns;

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

# FIXME - None of the functions (certainly none of the exported
# functions) are used anywhere anymore. Presumably this module is
# obsolete.

use strict;
require Exporter;
use DBI;
use C4::Context;
use C4::Accounts;
use C4::InterfaceCDK;
use C4::Circulation::Main;
	# FIXME - C4::Circulation::Main and C4::Circulation::Returns
	# use each other, so functions get redefined.
use C4::Scan;
use C4::Stats;
use C4::Search;
use C4::Print;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&returnrecord &calc_odues &Returns);

# FIXME - This is only used in C4::Circmain and C4::Circulation, both
# of which appear to be obsolete. Presumably this function is obsolete
# as well.
# Otherwise, it needs a POD.
sub Returns {
  my ($env)=@_;
  my $dbh = C4::Context->dbh;
  my @items;
  @items[0]=" "x50;
  my $reason;
  my $item;
  my $reason;
  my $borrower;
  my $itemno;
  my $itemrec;
  my $bornum;
  my $amt_owing;
  my $odues;
  my $issues;
  my $resp;
# until (($reason eq "Circ") || ($reason eq "Quit")) {
  until ($reason ne "") {
    ($reason,$item) =
      returnwindow($env,"Enter Returns",
      $item,\@items,$borrower,$amt_owing,$odues,$dbh,$resp); #C4::Circulation
    #debug_msg($env,"item = $item");
    #if (($reason ne "Circ") && ($reason ne "Quit")) {
    if ($reason eq "")  {
      $resp = "";
      ($resp,$bornum,$borrower,$itemno,$itemrec,$amt_owing) =
         checkissue($env,$dbh,$item);
      if ($bornum ne "") {
         ($issues,$odues,$amt_owing) = borrdata2($env,$bornum);
      } else {
        $issues = "";
	$odues = "";
	$amt_owing = "";
      }
      if ($resp ne "") {
        #if ($resp eq "Returned") {
	if ($itemno ne "" ) {
	  my $item = itemnodata($env,$dbh,$itemno);
	  # FIXME - This relies on C4::Circulation::Main to have a
	  # "use C4::Circulation::Issues;" line, which is bogus.
	  my $fmtitem = C4::Circulation::Issues::formatitem($env,$item,"",$amt_owing);
          unshift @items,$fmtitem;
	  if ($items[20] > "") {
	    pop @items;
	  }
	}
  	#} elsif ($resp ne "") {
	#  error_msg($env,"$resp");
	#}
	#if ($resp ne "Returned") {
	#  error_msg($env,"$resp");
	#  $bornum = "";
	#}
      }
    }
  }
#  clearscreen;
  return($reason);
  }

# FIXME - Only used in &Returns and in telnet/doreturns.pl, both of
# which appear obsolete. Presumably this function is obsolete as well.
# Otherwise, it needs a POD.
sub checkissue {
  my ($env,$dbh, $item) = @_;
  my $reason='Circ';
  my $bornum;
  my $borrower;
  my $itemno;
  my $itemrec;
  my $amt_owing;
  $item = uc $item;
  my $sth=$dbh->prepare("select * from items,biblio
    where barcode = ?
    and (biblio.biblionumber=items.biblionumber)");
  $sth->execute($item);
  if ($itemrec=$sth->fetchrow_hashref) {
     $sth->finish;
     $itemno = $itemrec->{'itemnumber'};
     my $sth=$dbh->prepare("select * from issues
       where (itemnumber=?)
       and (returndate is null)");
     $sth->execute($itemrec->{'itemnumber'});
     if (my $issuerec=$sth->fetchrow_hashref) {
       $sth->finish;
       my $sth= $dbh->prepare("select * from borrowers where
       (borrowernumber = ?)");
       $sth->execute($issuerec->{'borrowernumber'});
       $env->{'bornum'}=$issuerec->{'borrowernumber'};
       $borrower = $sth->fetchrow_hashref;
       $bornum = $issuerec->{'borrowernumber'};
       $itemno = $issuerec->{'itemnumber'};
       $amt_owing = returnrecord($env,$dbh,$bornum,$itemno);
       $reason = "Returned";
     } else {
       $sth->finish;
       updatelastseen($env,$dbh,$itemrec->{'itemnumber'});
       $reason = "Item not issued";
     }
     my ($resfound,$resrec) = find_reserves($env,$dbh,$itemrec->{'itemnumber'});
     if ($resfound eq "y") {
       my $btsh = $dbh->prepare("select * from borrowers
          where borrowernumber = ?");
       $btsh->execute($resrec->{'borrowernumber'});
       my $resborrower = $btsh->fetchrow_hashref;
       #printreserve($env,$resrec,$resborrower,$itemrec);
       my $mess = "Reserved for collection at branch $resrec->{'branchcode'}";
       C4::InterfaceCDK::error_msg($env,$mess);
       $btsh->finish;
     }
   } else {
     $sth->finish;
     $reason = "Item not found";
  }
  return ($reason,$bornum,$borrower,$itemno,$itemrec,$amt_owing);
  # end checkissue
  }

# FIXME - Only used in &C4::Circulation::Main::previousissue,
# &checkissue, C4/Circulation.pm, and tkperl/tkcirc, all of which
# appear to be obsolete. Presumably this function is obsolete as well.
# Otherwise, it needs a POD.
sub returnrecord {
  # mark items as returned
  my ($env,$dbh,$bornum,$itemno)=@_;
  #my $amt_owing = calc_odues($env,$dbh,$bornum,$itemno);
  my @datearr = localtime(time);
  my $dateret = (1900+$datearr[5])."-".$datearr[4]."-".$datearr[3];
  my $sth = $dbh->prepare("update issues set returndate = now(), branchcode = ? where
    (borrowernumber = ?) and (itemnumber = ?)
    and (returndate is null)");
  $sth->execute($env->{'branchcode'},$bornum,$itemno);
  $sth->finish;
  updatelastseen($env,$dbh,$itemno);
  # check for overdue fine
  my $oduecharge;
  my $sth = $dbh->prepare("select * from accountlines
    where (borrowernumber = ?)
    and (itemnumber = ?)
    and (accounttype = 'FU' or accounttype='O')");
    $sth->execute($bornum,$itemno);
    if (my $data = $sth->fetchrow_hashref) {
       # alter fine to show that the book has been returned.
       my $usth = $dbh->prepare("update accountlines
         set accounttype = 'F'
         where (borrowernumber = ?)
         and (itemnumber = ?)
         and (accountno = ?) ");
       $usth->execute($bornum,$itemno,$data->{'accountno'});
       $usth->finish();
       $oduecharge = $data->{'amountoutstanding'};
    }
    $sth->finish;
  # check for charge made for lost book
  my $sth = $dbh->prepare("select * from accountlines
    where (borrowernumber = ?)
    and (itemnumber = ?)
    and (accounttype = 'L')");
  $sth->execute($bornum,$itemno);
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
    my $usth = $dbh->prepare("update accountlines
      set accounttype = 'LR',amountoutstanding='0'
      where (borrowernumber = ?)
      and (itemnumber = ?)
      and (accountno = ?) ");
    $usth->execute($bornum,$itemno,$acctno);
    $usth->finish;
    my $nextaccntno = C4::Accounts::getnextacctno($env,$bornum,$dbh);
    $usth = $dbh->prepare("insert into accountlines
      (borrowernumber,accountno,date,amount,description,accounttype,amountoutstanding)
      values (?,?,now(),?,'Book Returned','CR',?)");
    $usth->execute($bornum,$nextaccntno,0-$amount,$amountleft);
    $usth->finish;
    $uquery = "insert into accountoffsets
      (borrowernumber, accountno, offsetaccount,  offsetamount)
      values (?,?,?,?)";
    $usth = $dbh->prepare("");
    $usth->execute($bornum,$data->{'accountno'},$nextaccntno,$offset);
    $usth->finish;
  }
  $sth->finish;
  UpdateStats($env,'branch','return','0','',$itemno);
  return($oduecharge);
}

# FIXME - Only used in tkperl/tkcirc. Presumably this function is
# obsolete.
# Otherwise, it needs a POD.
sub calc_odues {
  # calculate overdue fees
  my ($env,$dbh,$bornum,$itemno)=@_;
  my $amt_owing;
  return($amt_owing);
}

# This function is only used in &checkissue and &returnrecord, both of
# which appear to be obsolete. So presumably this function is obsolete
# too.
# Otherwise, it needs a POD.
sub updatelastseen {
  my ($env,$dbh,$itemnumber)= @_;
  my $br = $env->{'branchcode'};
  my $sth = $dbh->prepare("update items
    set datelastseen = now(), holdingbranch = ?
    where (itemnumber = ?)");
  $sth->execute($br,$itemnumber);
  $sth->finish;

}


# FIXME - There's also a &C4::Circulation::Circ2::find_reserves, but
# that one looks rather different.
# FIXME - This is only used in &checkissue, which appears to be
# obsolete. So presumably this function is obsolete too.
sub find_reserves {
  my ($env,$dbh,$itemno) = @_;
  my $itemdata = itemnodata($env,$dbh,$itemno);
  my $sth = $dbh->prepare("select * from reserves where found is null
  and biblionumber = ? and cancellationdate is NULL
  order by priority,reservedate ");
  $sth->execute($itemdata->{'biblionumber'};
  my $resfound = "n";
  my $resrec;
  while (($resrec=$sth->fetchrow_hashref) && ($resfound eq "n")) {
    if ($resrec->{'found'} eq "W") {
      if ($resrec->{'itemnumber'} eq $itemno) {
        $resfound = "y";
      }
    } elsif ($resrec->{'constrainttype'} eq "a") {
      $resfound = "y";
    } else {
      my $consth = $dbh->prepare("select * from reserveconstraints where borrowernumber = ? and reservedate = ? and biblionumber = ? and biblioitemnumber = ?");
      $consth->execute($resrec->{'borrowernumber'},$resrec->{'reservedate'},$resrec->{'biblionumber'},$itemdata->{'biblioitemnumber'});
      if (my $conrec=$consth->fetchrow_hashref) {
        if ($resrec->{'constrainttype'} eq "o") {
	   $resfound = "y";
	 }
      } else {
        if ($resrec->{'constrainttype'} eq "e") {
	  $resfound = "y";
	}
      }
      $consth->finish;
    }
    if ($resfound eq "y") {
      my $updsth = $dbh->prepare("update reserves
        set found = 'W',itemnumber = ?
        where borrowernumber = ?
        and reservedate = ?
        and biblionumber = ?");
      $updsth->execute($itemno,$resrec->{'borrowernumber'},$resrec->{'reservedate'},$resrec->{'biblionumber'});
      $updsth->finish;
      my $itbr = $resrec->{'branchcode'};
      if ($resrec->{'branchcode'} ne $env->{'branchcode'}) {
        my $updsth = $dbh->prepare("update items
          set holdingbranch = 'TR'
	  where itemnumber = ?");
        $updsth->execute($itemno);
        $updsth->finish;
      }
    }
  }
  $sth->finish;
  return ($resfound,$resrec);
}
