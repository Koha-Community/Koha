package C4::Accounts2; #asummes C4/Accounts2

#requires DBI.pm to be installed
#uses DBD:Pg

use strict;
require Exporter;
use DBI;
use C4::Database;
use C4::Stats;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&recordpayment &fixaccounts &makepayment);
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

sub recordpayment{
  #here we update both the accountoffsets and the account lines
  my ($env,$bornumber,$data)=@_;
  my $dbh=C4Connect;
  my $updquery = "";
  my $newamtos = 0;
  my $accdata = "";
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
     my $usth = $dbh->prepare($updquery);
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
  UpdateStats($env,'branch','payment',$data);
  $sth->finish;
  $dbh->disconnect;
}

sub makepayment{
  #here we update both the accountoffsets and the account lines
  my ($bornumber,$accountno,$amount,$user)=@_;
  my $env;
  my $dbh=C4Connect;
  # begin transaction
  my $nextaccntno = getnextacctno($env,$bornumber,$dbh);
  my $newamtos=0;
  my $updquery="Update accountlines set amountoutstanding=0 where
  borrowernumber=$bornumber and accountno=$accountno";
  my $sth=$dbh->prepare($updquery);
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
  my $usth = $dbh->prepare($updquery);
  $usth->execute;
  $usth->finish;
  UpdateStats($env,$user,'payment',$amount);
  $sth->finish;
  $dbh->disconnect;
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
 
END { }       # module clean-up code here (global destructor)
