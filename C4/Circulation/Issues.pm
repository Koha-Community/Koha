package C4::Circulation::Issues;

# $Id$

#package to deal with Issues
#written 3/11/99 by chris@katipo.co.nz

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

# FIXME - AFAICT the only function here that's still being used is
# &formatitem, and I'm not convinced that it's really being used.

use strict;
require Exporter;
use DBI;
use C4::Context;
use C4::Accounts;
use C4::InterfaceCDK;
use C4::Circulation::Main;
	# FIXME - C4::Circulation::Main and C4::Circulation::Issues
	# use each other, so functions get redefined.
use C4::Circulation::Borrower;
	# FIXME - C4::Circulation::Issues and C4::Circulation::Borrower
	# use each other, so functions get redefined.
use C4::Scan;
use C4::Stats;
use C4::Print;
use C4::Format;
use C4::Input;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Circulation::Issues - Miscellaneous functions related to Koha issues

=head1 SYNOPSIS

  use C4::Circulation::Issues;

=head1 DESCRIPTION

This module provides a function for pretty-printing an item being
issued.

=head1 FUNCTIONS

=over 2

=cut
#'

@ISA = qw(Exporter);
@EXPORT = qw(&Issue &formatitem);

# FIXME - This is only used in C4::Circmain and C4::Circulation, both
# of which look obsolete. Is this function obsolete as well?
# If not, this needs a POD.
sub Issue  {
   my ($env) = @_;
   my $dbh = C4::Context->dbh;
   #clear help
   helptext('');
   #clearscreen();
   my $done;
   my ($items,$items2,$amountdue);
   my $itemsdet;
   $env->{'sysarea'} = "Issues";
   $done = "Issues";
   while ($done eq "Issues") {
     my ($bornum,$issuesallowed,$borrower,$reason,$amountdue) = &findborrower($env,$dbh);
     #C4::Circulation::Borrowers
     $env->{'loanlength'}="";
     if ($reason ne "") {
       $done = $reason;
     } elsif ($env->{'IssuesAllowed'} eq '0') {
       error_msg($env,"No Issues Allowed =$env->{'IssuesAllowed'}");
     } else {
       $env->{'bornum'} = $bornum;
       $env->{'bcard'}  = $borrower->{'cardnumber'};
       #deal with alternative loans
       #now check items
       ($items,$items2)=
       C4::Circulation::Main::pastitems($env,$bornum,$dbh); #from Circulation.pm
       $done = "No";
       my $it2p=0;
       while ($done eq 'No'){
         ($done,$items2,$it2p,$amountdue,$itemsdet) =
            &processitems($env,$bornum,$borrower,$items,
	    $items2,$it2p,$amountdue,$itemsdet);
       }
     #&endint($env);
     }
   }
   Cdk::refreshCdkScreen();
   return ($done);
}

# FIXME - Not exported, but called by "telnet/borrwraper.pl".
# Presumably this function is obsolete.
sub processitems {
  #process a users items
   my ($env,$bornum,$borrower,$items,$items2,$it2p,$amountdue,$itemsdet,$odues)=@_;
   my $dbh = C4::Context->dbh;
   $env->{'newborrower'} = "";
   my ($itemnum,$reason) =
     issuewindow($env,'Issues',$dbh,$items,$items2,$borrower,fmtdec($env,$amountdue,"32"));
   if ($itemnum eq ""){
     $reason = "Finished user";
   } else {
     my ($item,$charge,$datedue) = &issueitem($env,$dbh,$itemnum,$bornum,$items);
     if ($datedue ne "") {
       my $line = formatitem($env,$item,$datedue,$charge);
       unshift @$items2,$line;
       #$items2->[$it2p] = $line;
       $item->{'date_due'} = $datedue;
       $item->{'charge'} = $charge;
       $itemsdet->[$it2p] = $item;
       $it2p++;
       $amountdue += $charge;
     }
   }
   #check to see if more books to process for this user
   my @done;
   if ($env->{'newborrower'} ne "") {$reason = "Finished user";}
   if ($reason eq 'Finished user'){
     if (@$items2[0] ne "") {
       remoteprint($env,$itemsdet,$borrower);
       if ($amountdue > 0) {
         &reconcileaccount($env,$dbh,$borrower->{'borrowernumber'},$amountdue);
       }
     }
     @done = ("Issues");
   } elsif ($reason eq "Print"){
     remoteprint($env,$itemsdet,$borrower);
     @done = ("No",$items2,$it2p);
   } else {
     if ($reason ne 'Finished issues'){
       #return No to let them know that we wish to
       # process more Items for borrower
       @done = ("No",$items2,$it2p,$amountdue,$itemsdet);
     } else  {
       @done = ("Circ");
     }
   }
   #debug_msg($env, "return from issues $done[0]");
   return @done;
}

=item formatitem

  $line = &formatitem($env, $item, $datedue, $charge);

Pretty-prints a description of an item being issued, and returns the
pretty-printed string.

C<$env> is effectively ignored.

C<$item> is a reference-to-hash whose keys are fields from the items
table in the Koha database.

C<$datedue> is a string that will be prepended to the output.

C<$charge> is a number that will be appended to the output.

The return value C<$line> is a string of the form

I<$datedue $barcode $title: $author $type$dewey$subclass $charge>

where those values that are not passed in as arguments are obtained
from C<$item>.

=cut
#'
sub formatitem {
   my ($env,$item,$datedue,$charge) = @_;
   my $line = $datedue." ".$item->{'barcode'}." ".$item->{'title'}.": ".$item->{'author'};
	# FIXME - Use string interpolation or sprintf()
   my $iclass =  $item->{'itemtype'};
   # FIXME - The Dewey code is a string, not a number.
   if ($item->{'dewey'} > 0) {
     my $dewey = $item->{'dewey'};
     $dewey =~ s/0*$//;
     $dewey =~ s/\.$//;
     $iclass .= $dewey.$item->{'subclass'};
   };
   my $llen = 65 - length($iclass);
   my $line = fmtstr($env,$line,"L".$llen);
		# FIXME - Use sprintf() instead of &fmtstr.
   my $line .= " $iclass ";
   my $line .= fmtdec($env,$charge,"22");
   return $line;
}

# Only used internally
# FIXME - Only used by &processitems, which appears to be obsolete.
sub issueitem{
   my ($env,$dbh,$itemnum,$bornum,$items)=@_;
   $itemnum=uc $itemnum;
   my $canissue = 1;
   ##  my ($itemnum,$reason)=&scanbook();
   my $item;
   my $charge;
   my $datedue = $env->{'loanlength'};
   my $sth=$dbh->prepare("Select * from items,biblio,biblioitems where (barcode=?) and
      (items.biblionumber=biblio.biblionumber) and
      (items.biblioitemnumber=biblioitems.biblioitemnumber) ");
   $sth->execute($itemnum);
   if ($item=$sth->fetchrow_hashref) {
     $sth->finish;
     #check if item is restricted
     if ($item->{'notforloan'} == 1) {
       error_msg($env,"Item Not for Loan");
       $canissue = 0;
     } elsif ($item->{'wthdrawn'} == 1) {
       error_msg($env,"Item Withdrawn");
       $canissue = 0;
#     } elsif ($item->{'itemlost'} == 1) {
#       error_msg($env,"Item Lost");
#       $canissue = 0;
     } elsif ($item->{'restricted'} == 1 ){
       error_msg($env,"Restricted Item");
       #check borrowers status to take out restricted items
       # if borrower allowed {
       #  $canissue = 1
       # } else {
       $canissue = 0;
       # }
     } elsif ($item->{'itemtype'} eq 'REF'){
       error_msg($env,"Item Not for Loan");
       $canissue=0;
     }
     #check if item is on issue already
     if ($canissue == 1) {
       my ($currbor,$issuestat,$newdate) =
         &C4::Circulation::Main::previousissue($env,$item->{'itemnumber'},$dbh,$bornum);
       if ($issuestat eq "N") {
         $canissue = 0;
       } elsif ($issuestat eq "R") {
         $canissue = -1;
	 $datedue = $newdate;
         $charge = calc_charges($env,$dbh,$item->{'itemnumber'},$bornum);
         if ($charge > 0) {
           createcharge($env,$dbh,$item->{'itemnumber'},$bornum,$charge);
	 }
         &UpdateStats($env,$env->{'branchcode'},'renew',$charge,'',$item->{'itemnumber'},$item->{'itemtype'});
       }
     }
     if ($canissue == 1) {
       #check reserve
       my ($resbor,$resrec) =  &C4::Circulation::Main::checkreserve($env,$dbh,$item->{'itemnumber'});
       #debug_msg($env,$resbor);
       if ($resbor eq $bornum) {
	 my $rsth = $dbh->prepare("update reserves
	   set found = 'F'
	   where reservedate = ?
	   and borrowernumber = ?
	   and biblionumber = ?");
	 $rsth->execute($resrec->{'reservedate'},$resrec->{'borrowernumber'},$resrec->{'biblionumber'});
	 $rsth->finish;
       } elsif ($resbor ne "") {
	 my $btsh = $dbh->prepare("select * from borrowers where borrowernumber = ?");
	 $btsh->execute($resbor);
	 my $resborrower = $btsh->fetchrow_hashref;
	 my $msgtxt = chr(7)."Res for $resborrower->{'cardnumber'},";
         $msgtxt .= " $resborrower->{'initials'} $resborrower->{'surname'}";
         my $ans = msg_ny($env,$msgtxt,"Allow issue?");
	 if ($ans eq "N") {
	    # print a docket;
	    printreserve($env,$resrec,$resborrower,$item);
	    $canissue = 0;
	 } else {
	   my $ans = msg_ny($env,"Cancel reserve?");
	   if ($ans eq "Y") {
			my $rsth = $dbh->prepare("update reserves
	       set found = 'F'
	       where reservedate = ?
	       and borrowernumber = ?
	       and biblionumber = ?");
	 		$rsth->execute($resrec->{'reservedate'},$resrec->{'borrowernumber'},$resrec->{'biblionumber'});
			$rsth->finish;
		}
	 }
	 $btsh->finish();
       };
     }
     #if charge deal with it

     if ($canissue == 1) {
       $charge = calc_charges($env,$dbh,$item->{'itemnumber'},$bornum);
     }
     if ($canissue == 1) {
       #now mark as issued
       $datedue=&updateissues($env,$item->{'itemnumber'},$item->{'biblioitemnumber'},$dbh,$bornum);
       #debug_msg("","date $datedue");
       &UpdateStats($env,$env->{'branchcode'},'issue',$charge,'',$item->{'itemnumber'},$item->{'itemtype'});
       if ($charge > 0) {
         createcharge($env,$dbh,$item->{'itemnumber'},$bornum,$charge);
       }
     } elsif ($canissue == 0) {
       info_msg($env,"Can't issue $item->{'cardnumber'}");
     }
   } else {
     my $valid = checkdigit($env,$itemnum, 1);
     if ($valid ==1) {
       if (substr($itemnum,0,1) = "V") {
         #this is a borrower
	 $env->{'newborrower'} = $itemnum;
       } else {
         error_msg($env,"$itemnum not found - rescan");
       }
     } else {
       error_msg($env,"Invalid Number");
     }
   }
   $sth->finish;
   #debug_msg($env,"date $datedue");
   return($item,$charge,$datedue);
}

# FIXME - A virtually identical function appears in
# C4::Circulation::Circ2. Pick one and stick with it.
sub createcharge {
  my ($env,$dbh,$itemno,$bornum,$charge) = @_;
  my $nextaccntno = getnextacctno($env,$bornum,$dbh);
  my $sth = $dbh->prepare("insert into accountlines
     (borrowernumber,itemnumber,accountno,date,amount,
     description,accounttype,amountoutstanding)
     values (?,?,?,now(),?,'Rental','Rent',?)");
  $sth->execute($bornum,$itemno,$nextaccntno,$charge,$charge);
  $sth->finish;
}


# Only used internally
sub updateissues{
  # issue the book
  my ($env,$itemno,$bitno,$dbh,$bornum)=@_;
  my $loanlength=21;
  my $sth=$dbh->prepare("Select *  from biblioitems,itemtypes
  where (biblioitems.biblioitemnumber=?)
  and (biblioitems.itemtype = itemtypes.itemtype)");
  $sth->execute($bitno);
  if (my $data=$sth->fetchrow_hashref) {
    $loanlength = $data->{'loanlength'}
  }
  $sth->finish;
  my $dateduef;
  if ($env->{'loanlength'} eq "") {
    my $ti = time;
    my $datedue = time + ($loanlength * 86400);
    my @datearr = localtime($datedue);
    $dateduef = (1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
  } else {
    $dateduef = $env->{'loanlength'};
  }
  #FIXME: what is going on above? Replaces with MySQL function or strftime?
  my $sth=$dbh->prepare("Insert into issues (borrowernumber,itemnumber, date_due,branchcode)
  values (?,?,?,?)");
  $sth->execute($bornum,$itemno,$dateduef,$env->{'branchcode'});
  $sth->finish;
  $sth=$dbh->prepare("Select * from items where itemnumber=?");
  $sth->execute($itemno);
  my $item=$sth->fetchrow_hashref;
  $sth->finish;
  $item->{'issues'}++;
  $sth=$dbh->prepare("Update items set issues=? where itemnumber=?");
  $sth->execute($item->{'issues'},$itemno);
  $sth->finish;
  #my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($datedue);
  my @datearr = split('-',$dateduef);
  my $dateret = join('-',$datearr[2],$datearr[1],$datearr[0]);
#  debug_msg($env,"query $query");
  return($dateret);
}

# FIXME - This is very similar to
# &C4::Circulation::Renewals2::calc_charges and
# &C4::Circulation::Circ2::calc_charges.
# Pick one and stick with it.

# Only used internally
sub calc_charges {
  # calculate charges due
  my ($env, $dbh, $itemno, $bornum)=@_;
  my $charge=0;
  my $item_type;
  my $sth1= $dbh->prepare("select itemtypes.itemtype,rentalcharge from items,biblioitems,itemtypes
    where (items.itemnumber =?)
    and (biblioitems.biblioitemnumber = items.biblioitemnumber)
    and (biblioitems.itemtype = itemtypes.itemtype)");
  $sth1->execute($itemno);
  if (my $data1=$sth1->fetchrow_hashref) {
     $item_type = $data1->{'itemtype'};
     $charge = $data1->{'rentalcharge'};
     my $sth2=$dbh->prepare("select rentaldiscount from borrowers,categoryitem
        where (borrowers.borrowernumber = ?)
        and (borrowers.categorycode = categoryitem.categorycode)
        and (categoryitem.itemtype = ?)");
     $sth2->execute($bornum,$item_type);
     if (my $data2=$sth2->fetchrow_hashref) {
        my $discount = $data2->{'rentaldiscount'};
	$charge = ($charge *(100 - $discount)) / 100;
     }
     $sth2->finish;
  }
  $sth1->finish;
  return ($charge);
}

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
