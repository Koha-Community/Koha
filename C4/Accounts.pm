package C4::Accounts; #asummes C4/Accounts

#requires DBI.pm to be installed
#uses DBD:Pg

use strict;
require Exporter;
use DBI;
use C4::Database;
use C4::Format;
use C4::Search;
use C4::Stats;
use C4::InterfaceCDK;
use C4::Interface::AccountsCDK;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&checkaccount &reconcileaccount &getnextacctno);
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

sub displayaccounts{
  my ($env)=@_;
}

sub checkaccount  {
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

sub reconcileaccount {
  #print put money owing give person opportunity to pay it off
  my ($env,$dummy,$bornumber,$total)=@_;
  my $dbh = &C4Connect;
  #get borrower record
  my $sth=$dbh->prepare("select * from borrowers
    where borrowernumber=$bornumber");
  $sth->execute;
  my $borrower=$sth->fetchrow_hashref;
  $sth->finish();
  #get borrower information
  $sth=$dbh->prepare("Select * from accountlines where 
  borrowernumber=$bornumber and amountoutstanding<>0 order by date");   
  $sth->execute;     
  #display account information
  &clearscreen();
  #&helptext('F11 quits');
  output(20,0,"Accounts");
  my @accountlines;
  my $row=4;
  my $i=0;
  my $text;
  #output (1,2,"Account Info");
  #output (1,3,"Item\tDate      \tAmount\tDescription");
  while (my $data=$sth->fetchrow_hashref){
    my $line=$i+1;
    my $amount=0+$data->{'amountoutstanding'};
    my $itemdata = itemnodata($env,$dbh,$data->{'itemnumber'});
    $line= $data->{'accountno'}." ".$data->{'date'}." ".$data->{'accounttype'}." ";
    my $title = $itemdata->{'title'};
    if (length($title) > 15 ) {$title = substr($title,0,15);}
    $line= $line.$itemdata->{'barcode'}." $title ".$data->{'description'};
    $line = fmtstr($env,$line,"L65")." ".fmtdec($env,$amount,"52");
    push @accountlines,$line;
    $i++;
  }
  #get amount paid and update database
  my ($data,$reason)=
    &accountsdialog($env,"Payment Entry",$borrower,\@accountlines,$total); 
  if ($data>0) {
    &recordpayment($env,$bornumber,$dbh,$data);
    #Check if the borrower still owes
    $total=&checkaccount($env,$bornumber,$dbh);
  }
  $dbh->disconnect;
  return($total);

}

sub recordpayment{
  #here we update both the accountoffsets and the account lines
  my ($env,$bornumber,$dbh,$data)=@_;
  my $updquery = "";
  my $newamtos = 0;
  my $accdata = "";
  my $amountleft = $data;
  # begin transaction
#  my $sth = $dbh->prepare("begin");
#  $sth->execute;
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
     my $usth = $dbh->prepare($updquery);
#     print $updquery
     $usth->execute;
     $usth->finish;
  }
  # create new line
  #$updquery = "insert into accountlines (borrowernumber,
  #accountno,date,amount,description,accounttype,amountoutstanding) values
  #($bornumber,$nextaccntno,datetime('now'::abstime),0-$data,'Payment,thanks',
  #'Pay',0-$amountleft)";
  $updquery = "insert into accountlines 
  (borrowernumber, accountno,date,amount,description,accounttype,amountoutstanding)  
  values ($bornumber,$nextaccntno,now(),0-$data,'Payment,thanks',
  'Pay',0-$amountleft)";
  my $usth = $dbh->prepare($updquery);
  $usth->execute;
  $usth->finish;
  UpdateStats($env,'branch','payment',$data)
#  $sth->finish;
#  $query = "commit";
#  $sth = $dbh->prepare;
#  $sth->execute;
#  $sth-finish;
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
			
END { }       # module clean-up code here (global destructor)
