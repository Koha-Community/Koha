package C4::Accounts2; #assumes C4/Accounts2

use strict;
use warnings;
require Exporter;
use DBI;
use C4::Database;
use C4::Stats;
use C4::Search;
use C4::Circulation::Circ2;
use vars qw($VERSION @ISA @EXPORT);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&recordpayment &fixaccounts &makepayment &manualinvoice
&getnextacctno);

sub displayaccounts{
  my ($env)=@_;
}

sub recordpayment{
  #here we update both the accountoffsets and the account lines
  my ($env,$bornumber,$data)=@_;
  my $dbh=C4Connect;
  my $updquery = "";
  my $newamtos = 0;
  my $accdata = "";
  my $branch=$env->{'branchcode'};
  my $amountleft = $data;
  # begin transaction
  my $nextaccntno = getnextacctno($env,$bornumber,$dbh);
  # get lines with outstanding amounts to offset
  my $query = "select * from accountlines 
  where (borrowernumber = '$bornumber') and (amountoutstanding<>0)
  order by date";
  my $sth = $dbh->prepare($query);
  $sth->execute;
  # offset transactions
  while (($accdata=$sth->fetchrow_hashref) and ($amountleft>0)){
     if ($accdata->{'amountoutstanding'} < $amountleft) {
        $newamtos = 0;
	$amountleft = $amountleft - $accdata->{'amountoutstanding'};
     }  else {
        $newamtos = $accdata->{'amountoutstanding'} - $amountleft;
	$amountleft = 0;
     }
     my $thisacct = $accdata->{accountno};
     $updquery = "update accountlines set amountoutstanding= '$newamtos'
     where (borrowernumber = '$bornumber') and (accountno='$thisacct')";
     my $usth = $dbh->prepare($updquery);
     $usth->execute;
     $usth->finish;
     $updquery = "insert into accountoffsets 
     (borrowernumber, accountno, offsetaccount,  offsetamount)
     values ($bornumber,$accdata->{'accountno'},$nextaccntno,$newamtos)";
     $usth = $dbh->prepare($updquery);
     $usth->execute;
     $usth->finish;
  }
  # create new line
  $updquery = "insert into accountlines 
  (borrowernumber, accountno,date,amount,description,accounttype,amountoutstanding)  
  values ($bornumber,$nextaccntno,now(),0-$data,'Payment,thanks',
  'Pay',0-$amountleft)";
  my $usth = $dbh->prepare($updquery);
  $usth->execute;
  $usth->finish;
  UpdateStats($env,$branch,'payment',$data,'','','',$bornumber);
  $sth->finish;
  $dbh->disconnect;
}

sub makepayment{
  #here we update both the accountoffsets and the account lines
  #updated to check, if they are paying off a lost item, we return the item 
  # from their card, and put a note on the item record
  my ($bornumber,$accountno,$amount,$user)=@_;
  my $env;
  my $dbh=C4Connect;
  # begin transaction
  my $nextaccntno = getnextacctno($env,$bornumber,$dbh);
  my $newamtos=0;
  my $sel="Select * from accountlines where  borrowernumber=$bornumber and
  accountno=$accountno";
  my $sth=$dbh->prepare($sel);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  my $updquery="Update accountlines set amountoutstanding=0 where
  borrowernumber=$bornumber and accountno=$accountno";
  $sth=$dbh->prepare($updquery);
  $sth->execute;
  $sth->finish;
#  print $updquery;
  $updquery = "insert into accountoffsets 
  (borrowernumber, accountno, offsetaccount,  offsetamount)
  values ($bornumber,$accountno,$nextaccntno,$newamtos)";
  my $usth = $dbh->prepare($updquery);
  $usth->execute;
  $usth->finish;  
  # create new line
  my $payment=0-$amount;
  $updquery = "insert into accountlines 
  (borrowernumber, accountno,date,amount,description,accounttype,amountoutstanding)  
  values ($bornumber,$nextaccntno,now(),$payment,'Payment,thanks - $user', 'Pay',0)";
  $usth = $dbh->prepare($updquery);
  $usth->execute;
  $usth->finish;
  UpdateStats($env,$user,'payment',$amount,'','','',$bornumber);
  $sth->finish;
  $dbh->disconnect;
  #check to see what accounttype
  if ($data->{'accounttype'} eq 'Rep' || $data->{'accounttype'} eq 'L'){
    returnlost($bornumber,$data->{'itemnumber'});
  }
}

sub getnextacctno {
  my ($env,$bornumber,$dbh)=@_;
  my $nextaccntno = 1;
  my $query = "select * from accountlines
  where (borrowernumber = '$bornumber')
  order by accountno desc";
  my $sth = $dbh->prepare($query);
  $sth->execute;
  if (my $accdata=$sth->fetchrow_hashref){
    $nextaccntno = $accdata->{'accountno'} + 1;
  }
  $sth->finish;
  return($nextaccntno);
}

sub fixaccounts {
  my ($borrowernumber,$accountno,$amount)=@_;
  my $dbh=C4Connect;
  my $query="Select * from accountlines where borrowernumber=$borrowernumber
     and accountno=$accountno";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  my $diff=$amount-$data->{'amount'};
  my $outstanding=$data->{'amountoutstanding'}+$diff;
  $sth->finish;
  $query="Update accountlines set amount='$amount',amountoutstanding='$outstanding' where
          borrowernumber=$borrowernumber and accountno=$accountno";
   $sth=$dbh->prepare($query);
#   print $query;
   $sth->execute;
   $sth->finish;
   $dbh->disconnect;
 }

sub returnlost{
  my ($borrnum,$itemnum)=@_;
  my $dbh=C4Connect;
  my $borrower=borrdata('',$borrnum); #from C4::Search;
  my $upiss="Update issues set returndate=now() where
  borrowernumber='$borrnum' and itemnumber='$itemnum' and returndate is null";
  my $sth=$dbh->prepare($upiss);
  $sth->execute;
  $sth->finish;
  my @datearr = localtime(time);
  my $date = (1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
  my $bor="$borrower->{'firstname'} $borrower->{'surname'} $borrower->{'cardnumber'}";
  my $upitem="Update items set paidfor='Paid for by $bor $date' where itemnumber='$itemnum'";
  $sth=$dbh->prepare($upitem);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub manualinvoice{
  my ($bornum,$itemnum,$desc,$type,$amount,$user)=@_;
  my $dbh=C4Connect;
  my $insert;
  $itemnum=~ s/ //g;
  my %env;
  my $accountno=getnextacctno('',$bornum,$dbh);
  my $amountleft=$amount;
  
  if ($type eq 'CS' || $type eq 'CB' || $type eq 'CW'
  || $type eq 'CF' || $type eq 'CL'){
    my $amount2=$amount*-1;
    $amountleft=fixcredit(\%env,$bornum,$amount2,$itemnum,$type,$user);
  }
  if ($type eq 'N'){
    $desc.="New Card";
  }
  if ($type eq 'L' && $desc eq ''){
    $desc="Lost Item";
  }
  if ($type eq 'REF'){
    $amountleft=refund('',$bornum,$amount);    
  }
  if ($itemnum ne ''){
    my $sth=$dbh->prepare("Select * from items where barcode='$itemnum'");
    $sth->execute;
    my $data=$sth->fetchrow_hashref;
    $sth->finish;
    $desc.=" ".$itemnum;
    $desc=$dbh->quote($desc);
    $insert="insert into accountlines (borrowernumber,accountno,date,amount,description,accounttype,amountoutstanding,itemnumber)
    values ($bornum,$accountno,now(),'$amount',$desc,'$type','$amountleft','$data->{'itemnumber'}')";
  } else {
      $desc=$dbh->quote($desc);
    $insert="insert into accountlines (borrowernumber,accountno,date,amount,description,accounttype,amountoutstanding)
    values ($bornum,$accountno,now(),'$amount',$desc,'$type','$amountleft')";
  }
  
  my $sth=$dbh->prepare($insert);
  $sth->execute;
  $sth->finish;
  
  $dbh->disconnect;
}
  
sub fixcredit{
  #here we update both the accountoffsets and the account lines
  my ($env,$bornumber,$data,$barcode,$type,$user)=@_;
  my $dbh=C4Connect;
  my $updquery = "";
  my $newamtos = 0;
  my $accdata = "";
  my $amountleft = $data;
  if ($barcode ne ''){    
    my $item=getiteminformation($env,'',$barcode);
    my $nextaccntno = getnextacctno($env,$bornumber,$dbh);
    my $query="Select * from accountlines where (borrowernumber='$bornumber'
    and itemnumber='$item->{'itemnumber'}' and amountoutstanding > 0)";
    if ($type eq 'CL'){
      $query.=" and (accounttype = 'L' or accounttype = 'Rep')";
    } elsif ($type eq 'CF'){
      $query.=" and (accounttype = 'F' or accounttype = 'FU' or
      accounttype='Res' or accounttype='Rent')";
    } elsif ($type eq 'CB'){
      $query.=" and accounttype='A'";
    }
#    print $query;
    my $sth=$dbh->prepare($query);
    $sth->execute;
    $accdata=$sth->fetchrow_hashref;
    $sth->finish;   
    if ($accdata->{'amountoutstanding'} < $amountleft) {
        $newamtos = 0;
	$amountleft = $amountleft - $accdata->{'amountoutstanding'};
     }  else {
        $newamtos = $accdata->{'amountoutstanding'} - $amountleft;
	$amountleft = 0;
     }
          my $thisacct = $accdata->{accountno};
     my $updquery = "update accountlines set amountoutstanding= '$newamtos'
     where (borrowernumber = '$bornumber') and (accountno='$thisacct')";
     my $usth = $dbh->prepare($updquery);
     $usth->execute;
     $usth->finish;
     $updquery = "insert into accountoffsets 
     (borrowernumber, accountno, offsetaccount,  offsetamount)
     values ($bornumber,$accdata->{'accountno'},$nextaccntno,$newamtos)";
     $usth = $dbh->prepare($updquery);
     $usth->execute;
     $usth->finish;
  }
  # begin transaction
  my $nextaccntno = getnextacctno($env,$bornumber,$dbh);
  # get lines with outstanding amounts to offset
  my $query = "select * from accountlines 
  where (borrowernumber = '$bornumber') and (amountoutstanding >0)
  order by date";
  my $sth = $dbh->prepare($query);
  $sth->execute;
#  print $query;
  # offset transactions
  while (($accdata=$sth->fetchrow_hashref) and ($amountleft>0)){
     if ($accdata->{'amountoutstanding'} < $amountleft) {
        $newamtos = 0;
	$amountleft = $amountleft - $accdata->{'amountoutstanding'};
     }  else {
        $newamtos = $accdata->{'amountoutstanding'} - $amountleft;
	$amountleft = 0;
     }
     my $thisacct = $accdata->{accountno};
     $updquery = "update accountlines set amountoutstanding= '$newamtos'
     where (borrowernumber = '$bornumber') and (accountno='$thisacct')";
     my $usth = $dbh->prepare($updquery);
     $usth->execute;
     $usth->finish;
     $updquery = "insert into accountoffsets 
     (borrowernumber, accountno, offsetaccount,  offsetamount)
     values ($bornumber,$accdata->{'accountno'},$nextaccntno,$newamtos)";
     $usth = $dbh->prepare($updquery);
     $usth->execute;
     $usth->finish;
  }
  $sth->finish;
  $dbh->disconnect;
  $env->{'branch'}=$user;
  $type="Credit ".$type;
  UpdateStats($env,$user,$type,$data,$user,'','',$bornumber);
  $amountleft*=-1;
  return($amountleft);
  
}

sub refund{
  #here we update both the accountoffsets and the account lines
  my ($env,$bornumber,$data)=@_;
  my $dbh=C4Connect;
  my $updquery = "";
  my $newamtos = 0;
  my $accdata = "";
#  my $branch=$env->{'branchcode'};
  my $amountleft = $data *-1;
  
  # begin transaction
  my $nextaccntno = getnextacctno($env,$bornumber,$dbh);
  # get lines with outstanding amounts to offset
  my $query = "select * from accountlines 
  where (borrowernumber = '$bornumber') and (amountoutstanding<0)
  order by date";
  my $sth = $dbh->prepare($query);
  $sth->execute;
#  print $query;
#  print $amountleft;
  # offset transactions
  while (($accdata=$sth->fetchrow_hashref) and ($amountleft<0)){
     if ($accdata->{'amountoutstanding'} > $amountleft) {
        $newamtos = 0;
	$amountleft = $amountleft - $accdata->{'amountoutstanding'};
     }  else {
        $newamtos = $accdata->{'amountoutstanding'} - $amountleft;
	$amountleft = 0;
     }
#     print $amountleft;
     my $thisacct = $accdata->{accountno};
     $updquery = "update accountlines set amountoutstanding= '$newamtos'
     where (borrowernumber = '$bornumber') and (accountno='$thisacct')";
     my $usth = $dbh->prepare($updquery);
     $usth->execute;
     $usth->finish;
     $updquery = "insert into accountoffsets 
     (borrowernumber, accountno, offsetaccount,  offsetamount)
     values ($bornumber,$accdata->{'accountno'},$nextaccntno,$newamtos)";
     $usth = $dbh->prepare($updquery);
     $usth->execute;
     $usth->finish;
  }
  $sth->finish;
  $dbh->disconnect;
  return($amountleft);
}
END { }       # module clean-up code here (global destructor)
