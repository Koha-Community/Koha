package C4::Circulation::Borrower; #assumes C4/Circulation/Borrower

#package to deal with Issues
#written 3/11/99 by chris@katipo.co.nz

use strict;
require Exporter;
use DBI;
use C4::Database;
use C4::Accounts;
use C4::InterfaceCDK;
use C4::Interface::FlagsCDK;
use C4::Circulation::Main;
use C4::Circulation::Issues;
use C4::Circulation::Renewals;
use C4::Scan;
use C4::Search;
use C4::Stats;
use C4::Format;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&findborrower &Borenq &findoneborrower &NewBorrowerNumber
&findguarantees);
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


sub findborrower  {
  my ($env,$dbh) = @_;
  C4::InterfaceCDK::helptext('');
  C4::InterfaceCDK::clearscreen();
  my $bornum = "";
  my $sth = "";
  my $borcode = "";
  my $borrower;
  my $reason = "";
  my $book;
  while (($bornum eq '') && ($reason eq "")) {
    #get borrowerbarcode from scanner
    my $title = C4::InterfaceCDK::titlepanel($env,$env->{'sysarea'},"Borrower Entry");
    if ($env->{'newborrower'} eq "") {
      ($borcode,$reason,$book)=&C4::Circulation::Main::scanborrower($env); 
    } else { 
      $borcode = $env->{'newborrower'};
      $reason = "";
      $book = "";
      $env->{'newborrower'}= "";
    }  
    #C4::Circulation::Main
    if ($reason eq "") {
      if ($borcode ne '') {
        ($bornum,$borrower) = findoneborrower($env,$dbh,$borcode);
        $env->{'IssuesAllowed'} = 1;
      } elsif ($book ne "") {
        my $query = "select * from issues,items where (barcode = '$book') 
          and (items.itemnumber = issues.itemnumber) 
          and (issues.returndate is null)";
        my $iss_sth=$dbh->prepare($query);
        $iss_sth->execute;
        if (my $issdata  = $iss_sth->fetchrow_hashref) {
           $bornum=$issdata->{'borrowernumber'};
	   $sth = $dbh->prepare("Select * from borrowers 
	     where borrowernumber =  '$bornum'");
	   $sth->execute;
	   $borrower=$sth->fetchrow_hashref;
	   $sth->finish;  
         } else {
           error_msg($env,"Item $book not found");
         } 
	 $iss_sth->finish;
      }
    } 
  } 
  my ($issuesallowed,$owing);
  if ($reason eq "") {
    $env->{'bornum'} = $bornum;
    $env->{'bcard'} = $borrower->{'cardnumber'};
    my $borrowers=join(' ',($borrower->{'title'},$borrower->{'firstname'},$borrower->{'surname'}));
    my $odues;
    ($issuesallowed,$odues,$owing) = &checktraps($env,$dbh,$bornum,$borrower);
#    error_msg ($env,"bcard =  $env->{'bcard'}");
  }
  #debug_msg ($env,"2 =  $env->{'IssuesAllowed'}");
  return ($bornum, $issuesallowed,$borrower,$reason,$owing);
};


sub findoneborrower {
  #  output(1,1,$borcode);
  my ($env,$dbh,$borcode)=@_;
  my $bornum;
  my $borrower;
  my $ucborcode = uc $borcode;
  my $lcborcode = lc $borcode;
  my $sth=$dbh->prepare("Select * from borrowers where cardnumber=\"$ucborcode\"");
  $sth->execute;
  if ($borrower=$sth->fetchrow_hashref) {
    $bornum=$borrower->{'borrowernumber'};
    $sth->finish;
  } else {
    $sth->finish;
    # my $borquery = "Select * from borrowers
    # where surname ~* '$borcode' order by surname";
	      
    my $borquery = "Select * from borrowers 
      where lower(surname) like \"$lcborcode%\" order by surname,firstname";
    my $sthb =$dbh->prepare($borquery);
    $sthb->execute;
    my $cntbor = 0;
    my @borrows;
    my @bornums;
    while ($borrower= $sthb->fetchrow_hashref) {
      my $line = $borrower->{'cardnumber'}.' '.$borrower->{'categorycode'}.' '.$borrower->{'surname'}.
        ', '.$borrower->{'othernames'};
      $borrows[$cntbor] = fmtstr($env,$line,"L50");
      $bornums[$cntbor] =$borrower->{'borrowernumber'};
      $cntbor++;
    }
    if ($cntbor == 1)  {
      $bornum = $bornums[0];       
      my $query = "select * from borrowers where borrowernumber = '$bornum'";	   
      $sth = $dbh->prepare($query);
      $sth->execute;
      $borrower =$sth->fetchrow_hashref;
      $sth->finish;					         
    } elsif ($cntbor > 0) {
      my ($cardnum) = C4::InterfaceCDK::selborrower($env,$dbh,\@borrows,\@bornums);
      my $query = "select * from borrowers where cardnumber = '$cardnum'";   
      $sth = $dbh->prepare($query);                          
      $sth->execute;                          
      $borrower =$sth->fetchrow_hashref;
      $sth->finish;
      $bornum=$borrower->{'borrowernumber'};
      #C4::InterfaceCDK::clearscreen();
      if ($bornum eq '') {
        error_msg($env,"Borrower not found");
      }
    }  
  }
  return ($bornum,$borrower); 
}
sub checktraps {
  my ($env,$dbh,$bornum,$borrower) = @_;
  my $issuesallowed = "1";
  #my @traps_set;
  #check amountowing
  my $traps_done; 
  my $odues;
  my $amount;
  while ($traps_done ne "DONE") {
    my @traps_set;
    $amount=C4::Accounts::checkaccount($env,$bornum,$dbh);    #from C4::Accounts
    if ($amount > 0) { push (@traps_set,"CHARGES");}  
    if ($borrower->{'gonenoaddress'} == 1){ push (@traps_set,"GNA");}
    #check if member has a card reported as lost
    if ($borrower->{'lost'} ==1){push (@traps_set,"LOST");}
    #check the notes field if notes exist display them
    if ($borrower->{'borrowernotes'} ne ''){ push (@traps_set,"NOTES");}
    #check if borrower has overdue items
    #call overdue checker
    my $odues = &C4::Circulation::Main::checkoverdues($env,$bornum,$dbh);
    if ($odues > 0) {push (@traps_set,"ODUES");}  
    #check if borrower has any items waiting
    my ($nowaiting,$itemswaiting) = &C4::Circulation::Main::checkwaiting($env,$dbh,$bornum);
    if ($nowaiting > 0) { push (@traps_set,"WAITING"); } 
    if (@traps_set[0] ne "" ) {
      ($issuesallowed,$traps_done,$amount,$odues) = 
         process_traps($env,$dbh,$bornum,$borrower,
	 $amount,$odues,\@traps_set,$itemswaiting);
    } else {
      $traps_done = "DONE";
    }   
  }
  return ($issuesallowed, $odues,$amount);
}

sub process_traps {
  my ($env,$dbh,$bornum,$borrower,$amount,$odues,$traps_set,$waiting) = @_;
  my $issuesallowed = 1;
  my $x = 0;
  my %traps;
  while (@$traps_set[$x] ne "") {
    $traps{@$traps_set[$x]} = 1; 
    $x++;
  }
  my $traps_done;
  my $trapact;
  my $issues;
  while ($trapact ne "NONE") {
    $trapact = &trapscreen($env,$bornum,$borrower,$amount,$traps_set);
    if ($trapact eq "CHARGES") {
      C4::Accounts::reconcileaccount($env,$dbh,$bornum,$amount,$borrower,$odues);
      ($odues,$issues,$amount)=borrdata2($env,$bornum);          
      if ($amount <= 0) {
        $traps{'CHARGES'} = 0;
        my @newtraps;
	$x =0;
        while ($traps_set->[$x] ne "") {
	  if ($traps_set->[$x] ne "CHARGES") {
            push @newtraps,$traps_set->[$x];
	  }
	  $x++;
        }
	$traps_set = \@newtraps;
      }
    } elsif ($trapact eq "WAITING") {
      reserveslist($env,$borrower,$amount,$odues,$waiting);
    } elsif ($trapact eq "ODUES") {
      C4::Circulation::Renewals::bulkrenew($env,$dbh,$bornum,$amount,$borrower,$odues);
      ($odues,$issues,$amount)=borrdata2($env,$bornum);
      if ($odues == 0) {
        $traps{'ODUES'} = 0;
        my @newtraps;
	$x =0;
        while ($traps_set->[$x] ne "") {
          if ($traps_set->[$x] ne "ODUES") {
            push @newtraps,$traps_set->[$x];
          }
          $x++;
        }
        $traps_set = \@newtraps;
      }
    } elsif  ($trapact eq "NOTES") {
      my $notes = trapsnotes($env,$bornum,$borrower,$amount);
      if ($notes ne $borrower->{'borrowernotes'}) { 
        my $query = "update borrowers set borrowernotes = '$notes' 
	   where borrowernumber = $bornum";
        my $sth = $dbh->prepare($query);
	$sth->execute();
	$sth->finish();
        $borrower->{'borrowernotes'} = $notes;
      }
      if ($notes eq "") {
        $traps{'NOTES'} = 0;
	my @newtraps;
	$x =0;
	while ($traps_set->[$x] ne "") {
	  if ($traps_set->[$x] ne "NOTES") {
	    push @newtraps,$traps_set->[$x];
	  }
	  $x++;
        }                 
        $traps_set = \@newtraps;                                                     
      }
    }
    my $notr = @$traps_set;
    if ($notr == 0) {
      $trapact = "NONE";
    }
    $traps_done = "DONE";
  }
  if ($traps{'GNA'} eq 1 ) {
    $issuesallowed=0;
    $env->{'IssuesAllowed'} = 0;
  }
  if ($traps{'CHARGES'} eq 1) {
    if ($amount > 5) {
      $env->{'IssuesAllowed'} = 0;
      $issuesallowed=0;
    }
  }
  return ($issuesallowed,$traps_done,$amount,$odues);
} # end of process_traps

sub Borenq {
  my ($env)=@_;
  my $dbh=C4Connect;
  #get borrower guff
  my $bornum;
  my $issuesallowed;
  my $borrower;
  my $reason;
  $env->{'sysarea'} = "Enquiries";
  while ($reason eq "") {
    $env->{'sysarea'} = "Enquiries";
    ($bornum,$issuesallowed,$borrower,$reason) = &findborrower($env,$dbh);
    if ($reason eq "") {
      my ($data,$reason)=&borrowerwindow($env,$borrower);
      if ($reason eq 'Modify'){
        modifyuser($env,$borrower);
        $reason = "";
      } elsif ($reason eq 'New'){
        $reason = "";
       }
    }
  $dbh->disconnect;
  }
  return $reason;
}  

sub modifyuser {
  my ($env,$borrower) = @_;
  debug_msg($env,"Please use intranet");
  #return;
}

sub reserveslist {
  my ($env,$borrower,$amount,$odues,$waiting) = @_;
  my $dbh=C4Connect;
  my @items;
  my $x=0;
  my $query="Select * from reserves where
  borrowernumber='$borrower->{'borrowernumber'}' and found='W' and
  cancellationdate is null order by timestamp";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  while (my $data=$sth->fetchrow_hashref){
    my $itemdata = itemnodata($env,$dbh,$data->{'itemnumber'});
    if ($itemdata){
      push @items,$itemdata;
    }
  }
  $sth->finish;
  reservesdisplay($env,$borrower,$amount,$odues,\@items);
  $dbh->disconnect;
}
  
sub NewBorrowerNumber {
  my $dbh=C4Connect;
  my $sth=$dbh->prepare("Select max(borrowernumber) from borrowers");
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $data->{'max(borrowernumber)'}++;
  return($data->{'max(borrowernumber)'});
  $dbh->disconnect;
}

sub findguarantees{
  my ($bornum)=@_;
  my $dbh=C4Connect;
  my $query="select cardnumber,borrowernumber from borrowers where 
  guarantor='$bornum'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @dat;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $dat[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,\@dat);
}
END { }       # module clean-up code here (global destructor)
