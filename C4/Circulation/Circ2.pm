package C4::Circulation::Circ2;

#package to deal with Returns
#written 3/11/99 by olwen@katipo.co.nz

use strict;
require Exporter;
use DBI;
use C4::Database;
#use C4::Accounts;
#use C4::InterfaceCDK;
#use C4::Circulation::Main;
#use C4::Format;
#use C4::Circulation::Renewals;
#use C4::Scan;
use C4::Stats;
#use C4::Search;
#use C4::Print;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&getpatroninformation &currentissues &getiteminformation &findborrower &issuebook &returnbook);
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],
		  
# your exported package globals go here,
# as well as any optionally exported functions

@EXPORT_OK   = qw($Var1 %Hashit);


# non-exported package globals go here
#use vars qw(@more $stuff);
	
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


sub getbranches {
    my ($env) = @_;
    my %branches;
    my $dbh=&C4Connect;  
    my $sth=$dbh->prepare("select * from branches");
    $sth->execute;
    while (my $branch=$sth->fetchrow_hashref) {
	$branches{$branch->{'branchcode'}}=$branch;
    }
    return (\%branches);
}


sub getprinters {
    my ($env) = @_;
    my %printers;
    my $dbh=&C4Connect;  
    my $sth=$dbh->prepare("select * from printers");
    $sth->execute;
    while (my $printer=$sth->fetchrow_hashref) {
	$printers{$printer->{'printername'}}=$printer;
    }
    return (\%printers);
}



sub getpatroninformation {
# returns 
    my ($env, $borrowernumber,$cardnumber) = @_;
    my $dbh=&C4Connect;  
    my $sth;
    open O, ">>/root/tkcirc.out";
    print O "Looking up patron $borrowernumber / $cardnumber\n";
    if ($borrowernumber) {
	$sth=$dbh->prepare("select * from borrowers where borrowernumber=$borrowernumber");
    } elsif ($cardnumber) {
	$sth=$dbh->prepare("select * from borrowers where cardnumber=$cardnumber");
    } else {
	 # error condition.  This subroutine must be called with either a
	 # borrowernumber or a card number.
	$env->{'apierror'}="invalid borrower information passed to getpatroninformation subroutine";
	 return();
    }
    $sth->execute;
    my $borrower=$sth->fetchrow_hashref;
    my $flags=patronflags($env, $borrower, $dbh);
    $sth->finish;
    $dbh->disconnect;
    print O "$borrower->{'surname'} <---\n";
    close O;
    $borrower->{'flags'}=$flags;
    return($borrower, $flags);
}





sub getiteminformation {
# returns a hash of item information given either the itemnumber or the barcode
    my ($env, $itemnumber, $barcode) = @_;
    my $dbh=&C4Connect;
    my $sth;
    if ($itemnumber) {
	$sth=$dbh->prepare("select * from biblio,items,biblioitems where items.itemnumber=$itemnumber and biblio.biblionumber=items.biblionumber and biblioitems.biblioitemnumber = items.biblioitemnumber");
    } elsif ($barcode) {
	my $q_barcode=$dbh->quote($barcode);
	$sth=$dbh->prepare("select * from biblio,items,biblioitems where items.barcode=$q_barcode and biblio.biblionumber=items.biblionumber and biblioitems.biblioitemnumber = items.biblioitemnumber");
    } else {
	$env->{'apierror'}="getiteminformation() subroutine must be called with either an itemnumber or a barcode";
	# Error condition.  
	return();
    }
    $sth->execute;
    my $iteminformation=$sth->fetchrow_hashref;
    $sth->finish;
    $dbh->disconnect;
    $iteminformation->{'dewey'}=~s/0*$//;
    return($iteminformation);
}

sub findborrower {
# returns an array of borrower hash references, given a cardnumber or a partial
# surname 
    my ($env, $key) = @_;
    my $dbh=&C4Connect;
    my @borrowers;
    my $q_key=$dbh->quote($key);
    my $sth=$dbh->prepare("select * from borrowers where cardnumber=$q_key");
    $sth->execute;
    if ($sth->rows) {
	my ($borrower)=$sth->fetchrow_hashref;
	push (@borrowers, $borrower);
    } else {
	$q_key=$dbh->quote("$key%");
	$sth->finish;
	$sth=$dbh->prepare("select * from borrowers where surname like $q_key");
	$sth->execute;
	while (my $borrower = $sth->fetchrow_hashref) {
	    push (@borrowers, $borrower);
	}
    }
    $sth->finish;
    $dbh->disconnect;
    return(\@borrowers);
}


sub issuebook {
    my ($env, $patroninformation, $barcode, $responses) = @_;
    my $dbh=&C4Connect;
    my $iteminformation=getiteminformation($env, 0, $barcode);
    my ($datedue);
    my ($rejected,$question,$defaultanswer,$questionnumber, $noissue);
    SWITCH: {
	if ($patroninformation->{'gonenoaddress'}) {
	    $rejected="Patron is gone, with no known address.";
	    last SWITCH;
	}
	if ($patroninformation->{'lost'}) {
	    $rejected="Patron's card has been reported lost.";
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
	my ($currentborrower) = currentborrower($env, $iteminformation->{'itemnumber'}, $dbh);
	if ($currentborrower eq $patroninformation->{'borrowernumber'}) {
# Already issued to current borrower
	    my ($renewstatus) = renewstatus($env,$dbh,$patroninformation->{'borrowernumber'}, $iteminformation->{'itemnumber'});
	    if ($renewstatus == 0) {
		$rejected="No more renewals allowed for this item.";
		last SWITCH;
	    } else {
		if ($responses->{4} eq '') {
		    $questionnumber=4;
		    $question="Book is issued to this borrower.\nRenew?";
		    $defaultanswer='Y';
		    last SWITCH;
		} elsif ($responses->{4} eq 'Y') {
		    renewbook($env,$dbh, $patroninformation->{'borrowernumber'}, $iteminformation->{'itemnumber'});
		    $noissue=1;
		} else {
		    $rejected=-1;
		    last SWITCH;
		}
	    }
	} elsif ($currentborrower ne '') {
	    my ($currborrower, $cbflags)=getpatroninformation($env,$currentborrower,0);
	    if ($responses->{1} eq '') {
		$questionnumber=1;
		$question="Issued to $currborrower->{'firstname'} $currborrower->{'surname'} ($currborrower->{'cardnumber'}).\nMark as returned?";
		$defaultanswer='Y';
		last SWITCH;
	    } elsif ($responses->{1} eq 'Y') {
		returnbook($env,$iteminformation->{'barcode'});
	    } else {
		$rejected=-1;
		last SWITCH;
	    }
	}

	my ($resbor, $resrec) = checkreserve($env, $dbh, $iteminformation->{'itemnumber'});

	if ($resbor eq $patroninformation->{'borrowernumber'}) {
	     my $rquery = "update reserves set found = 'F' where reservedate = '$resrec->{'reservedate'}' and borrowernumber = '$resrec->{'borrowernumber'}' and biblionumber = '$resrec->{'biblionumber'}'";
	     my $rsth = $dbh->prepare($rquery);
	     $rsth->execute;
	     $rsth->finish;
	} elsif ($resbor ne "") {
	    my ($resborrower, $flags)=getpatroninformation($env, $resbor,0);
	    if ($responses->{2} eq '') {
		$questionnumber=2;
		$question="Reserved for $resborrower->{'firstname'} $resborrower->{'surname'} ($resborrower->{'cardnumber'}) [$resbor]\nAllow issue?";
		$defaultanswer='N';
		last SWITCH;
	    } elsif ($responses->{2} eq 'N') {
		printreserve($env, $resrec, $resborrower, $iteminformation);
		$rejected=-1;
		last SWITCH;
	    } else {
		if ($responses->{3} eq '') {
		    $questionnumber=3;
		    $question="Cancel reserve for $resborrower->{'firstname'} $resborrower->{'surname'} ($resborrower->{'cardnumber'}?";
		    $defaultanswer='N';
		    last SWITCH;
		} elsif ($responses->{3} eq 'Y') {
		    my $rquery = "update reserves set found = 'F' where reservedate = '$resrec->{'reservedate'}' and borrowernumber = '$resrec->{'borrowernumber'}' and biblionumber = '$resrec->{'biblionumber'}'";
		    my $rsth = $dbh->prepare($rquery);
		    $rsth->execute;
		    $rsth->finish;
		}
	    }
	}
    }
    my $dateduef;
    unless (($question) || ($rejected) || ($noissue)) {
	my $loanlength=21;
	if ($iteminformation->{'loanlength'}) {
	    $loanlength=$iteminformation->{'loanlength'};
	}
	my $ti=time;
	my $datedue=time+($loanlength)*86400;
	my @datearr = localtime($datedue);
	$dateduef = (1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
	my $sth=$dbh->prepare("insert into issues (borrowernumber, itemnumber, date_due, branchcode) values ($patroninformation->{'borrowernumber'}, $iteminformation->{'itemnumber'}, '$dateduef', '$env->{'branchcode'}')");
	$sth->execute;
	$sth->finish;
	$iteminformation->{'issues'}++;
	$sth=$dbh->prepare("update items set issues=$iteminformation->{'issues'} where itemnumber=$iteminformation->{'itemnumber'}");
	$sth->execute;
	$sth->finish;
    }
    $dbh->disconnect;
    return ($iteminformation, $dateduef, $rejected, $question, $questionnumber, $defaultanswer);
}


sub returnbook {
    my ($env, $barcode) = @_;
    my ($messages, $overduecharge);
    my $dbh=&C4Connect;
    my ($iteminformation) = getiteminformation($env, 0, $barcode);
    my $borrower;
    if ($iteminformation) {
	my $sth=$dbh->prepare("select * from issues where (itemnumber='$iteminformation->{'itemnumber'}') and (returndate is null)");
	$sth->execute;
	my ($currentborrower) = currentborrower($env, $iteminformation->{'itemnumber'}, $dbh);
	updatelastseen($env,$dbh,$iteminformation->{'itemnumber'});
	if ($currentborrower) {
	    ($borrower)=getpatroninformation($env,$currentborrower,0);
	    my @datearr = localtime(time);
	    my $dateret = (1900+$datearr[5])."-".$datearr[4]."-".$datearr[3];
	    my $query = "update issues set returndate = now(), branchcode ='$env->{'branchcode'}' where (borrowernumber = $borrower->{'borrowernumber'}) and (itemnumber = $iteminformation->{'itemnumber'}) and (returndate is null)";
	    my $sth = $dbh->prepare($query);
	    $sth->execute;
	    $sth->finish;


	    # check for overdue fine

	    $overduecharge;
	    $sth=$dbh->prepare("select * from accountlines where (borrowernumber=$borrower->{'borrowernumber'}) and (itemnumber = $iteminformation->{'itemnumber'}) and (accounttype='FU' or accounttype='O')");
	    $sth->execute;
	    # alter fine to show that the book has been returned
	    if (my $data = $sth->fetchrow_hashref) {
		my $usth=$dbh->prepare("update accountlines set accounttype='F' where (borrowernumber=$borrower->{'borrowernumber'}) and (itemnumber=$iteminformation->{'itemnumber'}) and (acccountno='$data->{'accountno'}')");
		$usth->execute();
		$usth->finish();
		$overduecharge=$data->{'amountoutstanding'};
	    }
	    $sth->finish;
	    # check for charge made for lost book
	    $sth=$dbh->prepare("select * from accountlines where (borrowernumber=$borrower->{'borrowernumber'}) and (itemnumber = $iteminformation->{'itemnumber'}) and (accounttype='L')");
	    $sth->execute;
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
		my $uquery = "update accountlines
		  set accounttype = 'LR',amountoutstanding='0'
		  where (borrowernumber = $borrower->{'borrowernumber'})
		  and (itemnumber = $iteminformation->{'itemnumber'})
		  and (accountno = '$acctno') ";
		my $usth = $dbh->prepare($uquery);
		$usth->execute();
		$usth->finish;
		my $nextaccntno = C4::Accounts::getnextacctno($env,$borrower->{'borrowernumber'},$dbh);
		$uquery = "insert into accountlines
		  (borrowernumber,accountno,date,amount,description,accounttype,amountoutstanding)
		  values ($borrower->{'borrowernumber'},$nextaccntno,now(),0-$amount,'Book Returned',
		  'CR',$amountleft)";
		$usth = $dbh->prepare($uquery);
		$usth->execute;
		$usth->finish;
		$uquery = "insert into accountoffsets
		  (borrowernumber, accountno, offsetaccount,  offsetamount)
		  values ($borrower->{'borrowernumber'},$data->{'accountno'},$nextaccntno,$offset)";
		$usth = $dbh->prepare($uquery);
		$usth->execute;
		$usth->finish;
	    }
	    $sth->finish;
	}
	UpdateStats($env,'branch','return','0','',$iteminformation->{'itemnumber'});
    }
    $dbh->disconnect;
    return ($iteminformation, $borrower, $messages, $overduecharge);
}


sub patronflags {
# Original subroutine for Circ2.pm
    my %flags;
    my ($env,$patroninformation,$dbh) = @_;
    my $amount = checkaccount($env,$patroninformation->{'borrowernumber'}, $dbh);
    if ($amount>0) { 
	my %flaginfo;
	$flaginfo{'message'}='Patron owes $amount'; 
	if ($amount>5) {
	    $flaginfo{'noissues'}=1;
	}
	$flags{'CHARGES'}=\%flaginfo;
    }
    if ($patroninformation->{'gonenoaddress'} == 1) {
	my %flaginfo;
	$flaginfo{'message'}='Borrower has no valid address.'; 
	$flaginfo{'noissues'}=1;
	$flags{'GNA'}=\%flaginfo;
    }
    if ($patroninformation->{'lost'} == 1) {
	my %flaginfo;
	$flaginfo{'message'}='Borrower\'s card reported lost.'; 
	$flaginfo{'noissues'}=1;
	$flags{'LOST'}=\%flaginfo;
    }
    if ($patroninformation->{'borrowernotes'}) {
	my %flaginfo;
	$flaginfo{'message'}="Note: $patroninformation->{'borrowernotes'}";
	$flags{'NOTES'}=\%flaginfo;
    }
    my ($odues, $itemsoverdue) = checkoverdues($env,$patroninformation->{'borrowernumber'},$dbh);
    if ($odues > 0) {
	my %flaginfo;
	$flaginfo{'message'}="Overdue Items\n";
	foreach (sort {$a->{'date_due'} cmp $b->{'date_due'}} @$itemsoverdue) {
	    $flaginfo{'message'}.="$_->{'date_due'} $_->{'barcode'} $_->{'title'} \n";
	}
	$flags{'ODUES'}=\%flaginfo;
    }
    my ($nowaiting,$itemswaiting) = checkwaiting($env,$dbh,$patroninformation->{'borrowernumber'});
    if ($nowaiting>0) {
	my %flaginfo;
	$flaginfo{'message'}="Reserved items available";
	$flaginfo{'itemlist'}=$itemswaiting;
	$flaginfo{'itemfields'}=['barcode', 'title', 'author', 'dewey', 'subclass', 'holdingbranch'];
	$flags{'WAITING'}=\%flaginfo;
    }
    my $flag;
    my $key;
    return(\%flags);
}


sub checkoverdues {
# From Main.pm, modified to return a list of overdueitems, in addition to a count
  #checks whether a borrower has overdue items
  my ($env,$bornum,$dbh)=@_;
  my @datearr = localtime;
  my $today = ($datearr[5] + 1900)."-".($datearr[4]+1)."-".$datearr[3];
  my @overdueitems;
  my $count=0;
  my $query = "Select * from issues,biblio,biblioitems,items where items.biblioitemnumber=biblioitems.biblioitemnumber and items.biblionumber=biblio.biblionumber and issues.itemnumber=items.itemnumber and borrowernumber=$bornum and returndate is NULL and date_due < '$today'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  while (my $data = $sth->fetchrow_hashref) {
      push (@overdueitems, $data);
      $count++;
  }
  $sth->finish;
  return ($count, \@overdueitems);
}

sub updatelastseen {
# Stolen from Returns.pm
    my ($env,$dbh,$itemnumber)= @_;
    my $br = $env->{'branchcode'};
    my $query = "update items 
    set datelastseen = now(), holdingbranch = '$br'
    where (itemnumber = '$itemnumber')";
    my $sth = $dbh->prepare($query);
    $sth->execute;
    $sth->finish;
} 

sub currentborrower {
# Original subroutine for Circ2.pm
    my ($env, $itemnumber, $dbh) = @_;
    my $q_itemnumber=$dbh->quote($itemnumber);
    my $sth=$dbh->prepare("select borrowers.borrowernumber from
    issues,borrowers where issues.itemnumber=$q_itemnumber and
    issues.borrowernumber=borrowers.borrowernumber and issues.returndate is
    NULL");
    $sth->execute;
    my ($previousborrower)=$sth->fetchrow;
    return($previousborrower);
}

sub checkreserve {
# Stolen from Main.pm
  # Check for reserves for biblio 
  my ($env,$dbh,$itemnum)=@_;
  my $resbor = "";
  my $query = "select * from reserves,items 
    where (items.itemnumber = '$itemnum')
    and (reserves.cancellationdate is NULL)
    and (items.biblionumber = reserves.biblionumber)
    and ((reserves.found = 'W')
    or (reserves.found is null)) 
    order by priority";
  my $sth = $dbh->prepare($query);
  $sth->execute();
  my $resrec;
  if (my $data=$sth->fetchrow_hashref) {
    $resrec=$data;
    my $const = $data->{'constrainttype'};
    if ($const eq "a") {
      $resbor = $data->{'borrowernumber'};
    } else {
      my $found = 0;
      my $cquery = "select * from reserveconstraints,items 
         where (borrowernumber='$data->{'borrowernumber'}') 
         and reservedate='$data->{'reservedate'}'
         and reserveconstraints.biblionumber='$data->{'biblionumber'}'
         and (items.itemnumber=$itemnum and 
         items.biblioitemnumber = reserveconstraints.biblioitemnumber)";
      my $csth = $dbh->prepare($cquery);
      $csth->execute;
      if (my $cdata=$csth->fetchrow_hashref) {$found = 1;}
      if ($const eq 'o') {
        if ($found eq 1) {$resbor = $data->{'borrowernumber'};}
      } else {
        if ($found eq 0) {$resbor = $data->{'borrowernumber'};}
      }
      $csth->finish();
    }
  }
  $sth->finish;
  return ($resbor,$resrec);
}

sub currentissues {
# New subroutine for Circ2.pm
    my ($env, $borrower) = @_;
    my $dbh=&C4Connect;
    my %currentissues;
    my $counter=1;
    my $borrowernumber=$borrower->{'borrowernumber'};
    my $crit='';
    if ($env->{'todaysissues'}) {
	my @datearr = localtime(time());
	my $today = (1900+$datearr[5]).sprintf "0%02d", ($datearr[4]+1).sprintf "%02d", $datearr[3];
	$crit=" and issues.timestamp like '$today%' ";
    }
    if ($env->{'nottodaysissues'}) {
	my @datearr = localtime(time());
	my $today = (1900+$datearr[5]).sprintf "0%02d", ($datearr[4]+1).sprintf "%02d", $datearr[3];
	$crit=" and !(issues.timestamp like '$today%') ";
    }
    my $sth=$dbh->prepare("select * from issues,items,biblioitems,biblio where borrowernumber=$borrowernumber and issues.itemnumber=items.itemnumber and items.biblionumber=biblio.biblionumber and items.biblioitemnumber=biblioitems.biblioitemnumber and returndate is null $crit order by date_due");
    $sth->execute;
    while (my $data = $sth->fetchrow_hashref) {
	$data->{'dewey'}=~s/0*$//;
	my $datedue=$data->{'date_due'};
	my $itemnumber=$data->{'itemnumber'};
	$currentissues{$counter}=$data;
	$counter++;
    }
    $sth->finish;
    $dbh->disconnect;
    return(\%currentissues);
}

sub checkwaiting {
#Stolen from Main.pm
  # check for reserves waiting
  my ($env,$dbh,$bornum)=@_;
  my @itemswaiting;
  my $query = "select * from reserves
    where (borrowernumber = '$bornum')
    and (reserves.found='W') and cancellationdate is NULL";
  my $sth = $dbh->prepare($query);
  $sth->execute();
  my $cnt=0;
  if (my $data=$sth->fetchrow_hashref) {
    @itemswaiting[$cnt] =$data;
    $cnt ++
  }
  $sth->finish;
  return ($cnt,\@itemswaiting);
}


sub checkaccount  {
# Stolen from Accounts.pm
  #take borrower number
  #check accounts and list amounts owing
  my ($env,$bornumber,$dbh)=@_;
  my $sth=$dbh->prepare("Select sum(amountoutstanding) from accountlines where
  borrowernumber=$bornumber and amountoutstanding<>0");
  $sth->execute;
  my $total=0;
  while (my $data=$sth->fetchrow_hashref){
    $total=$total+$data->{'sum(amountoutstanding)'};
  }
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

sub renewstatus {
# Stolen from Renewals.pm
  # check renewal status
  my ($env,$dbh,$bornum,$itemno)=@_;
  my $renews = 1;
  my $renewokay = 0;
  my $q1 = "select * from issues 
    where (borrowernumber = '$bornum')
    and (itemnumber = '$itemno') 
    and returndate is null";
  my $sth1 = $dbh->prepare($q1);
  $sth1->execute;
  if (my $data1 = $sth1->fetchrow_hashref) {
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

sub renewbook {
# Stolen from Renewals.pm
  # mark book as renewed
  my ($env,$dbh,$bornum,$itemno,$datedue)=@_;
  if ($datedue eq "" ) {    
    my $loanlength=21;
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
    my $ti = time;
    my $datedu = time + ($loanlength * 86400);
    my @datearr = localtime($datedu);
    $datedue = (1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
  }
  my @date = split("-",$datedue);
  my $odatedue = (@date[2]+0)."-".(@date[1]+0)."-".@date[0];
  my $issquery = "select * from issues where borrowernumber='$bornum' and
    itemnumber='$itemno' and returndate is null";
  my $sth=$dbh->prepare($issquery);
  $sth->execute;
  my $issuedata=$sth->fetchrow_hashref;
  $sth->finish;
  my $renews = $issuedata->{'renewals'} +1;
  my $updquery = "update issues 
    set date_due = '$datedue', renewals = '$renews'
    where borrowernumber='$bornum' and
    itemnumber='$itemno' and returndate is null";
  my $sth=$dbh->prepare($updquery);
  
  $sth->execute;
  $sth->finish;
  return($odatedue);
}


END { }       # module clean-up code here (global destructor)
