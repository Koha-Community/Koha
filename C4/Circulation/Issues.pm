package C4::Circulation::Issues; #asummes C4/Circulation/Issues

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
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&Issue &formatitem);
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],
		  
# your exported package globals go here,
# as well as any optionally exported functions

@EXPORT_OK   = qw($Var1 %Hashit);


# non-exported package globals go here
use vars qw(@more $stuff);
	
# initalize package globals, first exported ones

my $Var1   = '';
my %Hashit = ();
		    
# then the others (which are still accessible as $Some::Module::stuff)
my $stuff  = '';
my @more   = ();
	
# all file-scoped lexicals must be created before
# the functions below that use them.
		
# file-private lexicals go here
my $priv_var    = '';
my %secret_hash = ();
			    
# here's a file-private function as a closure,
# callable as &$priv_func;  it cannot be prototyped.
my $priv_func = sub {
  # stuff goes here.
};
						    
# make all your functions, whether exported or not;


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

sub formatitem {
   my ($env,$item,$datedue,$charge) = @_;
   my $line = $datedue." ".$item->{'barcode'}." ".$item->{'title'}.": ".$item->{'author'};
   my $iclass =  $item->{'itemtype'};
   if ($item->{'dewey'} > 0) {
     my $dewey = $item->{'dewey'};
     $dewey =~ s/0*$//;
     $dewey =~ s/\.$//;
     $iclass = $iclass.$dewey.$item->{'subclass'};
   };
   my $llen = 65 - length($iclass);
   my $line = fmtstr($env,$line,"L".$llen);
   my $line = $line." $iclass ";
   my $line = $line.fmtdec($env,$charge,"22");
   return $line;
}   
	 
sub issueitem{
   my ($env,$dbh,$itemnum,$bornum,$items)=@_;
   $itemnum=uc $itemnum;
   my $canissue = 1;
   ##  my ($itemnum,$reason)=&scanbook();
   my $query="Select * from items,biblio,biblioitems where (barcode='$itemnum') and
      (items.biblionumber=biblio.biblionumber) and
      (items.biblioitemnumber=biblioitems.biblioitemnumber) ";
   my $item;
   my $charge;
   my $datedue = $env->{'loanlength'};
   my $sth=$dbh->prepare($query);  
   $sth->execute;
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
         my $rquery = "update reserves 
	   set found = 'F'
	   where reservedate = '$resrec->{'reservedate'}'
	   and borrowernumber = '$resrec->{'borrowernumber'}'
	   and biblionumber = '$resrec->{'biblionumber'}'";
	 my $rsth = $dbh->prepare($rquery);
	 $rsth->execute;
	 $rsth->finish;
       } elsif ($resbor ne "") {
         my $bquery = "select * from borrowers 
	    where borrowernumber = '$resbor'";
	 my $btsh = $dbh->prepare($bquery);
	 $btsh->execute;
	 my $resborrower = $btsh->fetchrow_hashref;
	 my $msgtxt = chr(7)."Res for $resborrower->{'cardnumber'},";
         $msgtxt = $msgtxt." $resborrower->{'initials'} $resborrower->{'surname'}";
         my $ans = msg_ny($env,$msgtxt,"Allow issue?");
	 if ($ans eq "N") {
	    # print a docket;
	    printreserve($env,$resrec,$resborrower,$item);
	    $canissue = 0;
	 } else {
	   my $ans = msg_ny($env,"Cancel reserve?");
	   if ($ans eq "Y") {
	     my $rquery = "update reserves 
	       set found = 'F'
	       where reservedate = '$resrec->{'reservedate'}'
	       and borrowernumber = '$resrec->{'borrowernumber'}'
	       and biblionumber = '$resrec->{'biblionumber'}'";
             my $rsth = $dbh->prepare($rquery);
	     $rsth->execute;
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
     my $valid = checkdigit($env,$itemnum);
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

sub createcharge {
  my ($env,$dbh,$itemno,$bornum,$charge) = @_;
  my $nextaccntno = getnextacctno($env,$bornum,$dbh);
  my $query = "insert into accountlines
     (borrowernumber,itemnumber,accountno,date,amount,
     description,accounttype,amountoutstanding)
     values ($bornum,$itemno,$nextaccntno,now(),$charge,'Rental','Rent',$charge)";
  my $sth = $dbh->prepare($query);
  $sth->execute;
  $sth->finish;
}



sub updateissues{
  # issue the book
  my ($env,$itemno,$bitno,$dbh,$bornum)=@_;
  my $loanlength=21;
  my $query="Select *  from biblioitems,itemtypes
  where (biblioitems.biblioitemnumber='$bitno') 
  and (biblioitems.itemtype = itemtypes.itemtype)";
  my $sth=$dbh->prepare($query);
  $sth->execute;
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
  $query = "Insert into issues (borrowernumber,itemnumber, date_due,branchcode)
  values ($bornum,$itemno,'$dateduef','$env->{'branchcode'}')";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $query = "Select * from items where itemnumber=$itemno";
  $sth=$dbh->prepare($query);
  $sth->execute;
  my $item=$sth->fetchrow_hashref;
  $sth->finish;
  $item->{'issues'}++;
  $query="Update items set issues=$item->{'issues'} where itemnumber=$itemno";
  $sth=$dbh->prepare($query);
  $sth->execute;
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
sub calc_charges {
  # calculate charges due
  my ($env, $dbh, $itemno, $bornum)=@_;
  my $charge=0;
  my $item_type;
  my $q1 = "select itemtypes.itemtype,rentalcharge from items,biblioitems,itemtypes
    where (items.itemnumber ='$itemno')
    and (biblioitems.biblioitemnumber = items.biblioitemnumber)
    and (biblioitems.itemtype = itemtypes.itemtype)";
  my $sth1= $dbh->prepare($q1);
  $sth1->execute;
  if (my $data1=$sth1->fetchrow_hashref) {
     $item_type = $data1->{'itemtype'};
     $charge = $data1->{'rentalcharge'};
     my $q2 = "select rentaldiscount from borrowers,categoryitem 
        where (borrowers.borrowernumber = '$bornum') 
        and (borrowers.categorycode = categoryitem.categorycode)
        and (categoryitem.itemtype = '$item_type')";
     my $sth2=$dbh->prepare($q2);
     $sth2->execute;
     if (my $data2=$sth2->fetchrow_hashref) {
        my $discount = $data2->{'rentaldiscount'};
	$charge = ($charge *(100 - $discount)) / 100;
     }
     $sth2->{'finish'};	# FIXME - Was this supposed to be $sth2->finish ?
  }   
  $sth1->finish;
  return ($charge);
}

END { }       # module clean-up code here (global destructor)
