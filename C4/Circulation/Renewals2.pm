package C4::Circulation::Renewals2; #assumes C4/Circulation/Renewals2.pm

#package to deal with Renewals
#written 7/11/99 by olwen@katipo.co.nz

#modified by chris@katipo.co.nz
#18/1/2000 
#need to update stats with renewals

use strict;
require Exporter;
use DBI;
use C4::Database;
use C4::Stats;
use C4::Accounts2;
use C4::Circulation::Circ2;
use warnings;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&renewstatus &renewbook &calc_charges);
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


sub Return  {
  
}    

sub renewstatus {
  # check renewal status
  my ($env,$bornum,$itemno)=@_;
  my $dbh=C4Connect;
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
  $dbh->disconnect;
  return($renewokay);    
}


sub renewbook {
  # mark book as renewed
  my ($env,$bornum,$itemno,$datedue)=@_;
  my $dbh=C4Connect;
  if ($datedue eq "" ) {    
    #debug_msg($env, "getting date");
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
  $sth=$dbh->prepare($updquery);
  $sth->execute;
  $sth->finish;
  UpdateStats($env,$env->{'branchcode'},'renew','','',$itemno);
  my ($charge,$type)=calc_charges($env, $itemno, $bornum);  
  if ($charge > 0){
    my $accountno=getnextacctno($env,$bornum,$dbh);
    my $item=getiteminformation($env, $itemno);
    my $account="Insert into accountlines
    (borrowernumber,accountno,date,amount,description,accounttype,amountoutstanding,itemnumber)
    values 
    ('$bornum','$accountno',now(),$charge,'Renewal of Rental Item $item->{'title'} $item->{'barcode'}','Rent',$charge,'$itemno')";
    $sth=$dbh->prepare($account);
    $sth->execute;
    $sth->finish;
#     print $account;
  }
  $dbh->disconnect;
 
#  return();
}


sub calc_charges {         
  # calculate charges due         
  my ($env, $itemno, $bornum)=@_;           
  my $charge=0;   
  my $dbh=C4Connect;
  my $item_type;               
  my $q1 = "select itemtypes.itemtype,rentalcharge from
  items,biblioitems,itemtypes     
  where (items.itemnumber ='$itemno')         
  and (biblioitems.biblioitemnumber = items.biblioitemnumber) 
  and (biblioitems.itemtype = itemtypes.itemtype)";                 
  my $sth1= $dbh->prepare($q1);                     
  $sth1->execute;                       
  if (my $data1=$sth1->fetchrow_hashref) {    
    $item_type = $data1->{'itemtype'};     
    $charge = $data1->{'rentalcharge'};
    my $q2 = "select rentaldiscount from 
    borrowers,categoryitem                        
    where (borrowers.borrowernumber = '$bornum')         
    and (borrowers.categorycode = categoryitem.categorycode)   
    and (categoryitem.itemtype = '$item_type')";   
    my $sth2=$dbh->prepare($q2);           
    $sth2->execute;        
    if (my$data2=$sth2->fetchrow_hashref) {                                           
      my $discount = $data2->{'rentaldiscount'};         
      $charge = ($charge *(100 - $discount)) / 100;                 
    }                         
    $sth2->finish;                              
  }                                   
  $sth1->finish;  
  $dbh->disconnect;
#  print "item $item_type";
  return ($charge,$item_type);         
}       


END { }       # module clean-up code here (global destructor)
