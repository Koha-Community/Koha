#!/usr/bin/perl

#script to keep total of number of issues;

use C4::Database;
use C4::Search;
use C4::Circulation::Circ2;
use C4::Circulation::Fines;
use Date::Manip;

open (FILE,'>/tmp/fines') || die;
my ($count,$data)=Getoverdues();
#print $count;
my $count2=0;
#$count=1000;
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime(time);
$mon++;
$year=$year+1900;
my $date=Date_DaysSince1BC($mon,$mday,$year);
#my $date=Date_DaysSince1BC(1,24,2002);
my $bornum;
#print $date;
my $total=0;
my $max=5;
#my $bornum2=$data->[0]->{'borrowernumber'};

my $i2=1;
for (my $i=0;$i<$count;$i++){
  my @dates=split('-',$data->[$i]->{'date_due'});
  my $date2=Date_DaysSince1BC($dates[1],$dates[2],$dates[0]);    
  my $due="$dates[2]/$dates[1]/$dates[0]";
  my $borrower=BorType($data->[$i]->{'borrowernumber'});
  if ($date2 <= $date){
    $count2++;
    my $difference=$date-$date2;
    my ($amount,$type,$printout)=CalcFine($data->[$i]->{'itemnumber'},$borrower->{'categorycode'},$difference);      
    if ($amount > $max){
      $amount=$max;
    }
    if ($amount > 0){
      UpdateFine($data->[$i]->{'itemnumber'},$data->[$i]->{'borrowernumber'},$amount,$type,$due);
#      if ($amount ==5){
#	      marklost();
#      }
       if ($borrower->{'categorycode'} eq 'C'){
	 my $dbh=C4Connect;
	 my $query="Select * from borrowers where borrowernumber='$borrower->{'guarantor'}'";
	 my $sth=$dbh->prepare($query);
	 $sth->execute;
	 my $tdata=$sth->fetchrow_hashref;
	 $sth->finish;
	 $dbh->disconnect;
	 $borrower->{'phone'}=$tdata->{'phone'};
       }
       print "$printout\t$borrower->{'cardnumber'}\t$borrower->{'categorycode'}\t$borrower->{'firstname'}\t$borrower->{'surname'}\t$data->[$i]->{'date_due'}\t$type\t$difference\t$borrower->{'emailaddress'}\t$borrower->{'phone'}\t$borrower->{'streetaddress'}\t$borrower->{'city'}\t$amount\n";
    } else {
#      print "$borrower->{'cardnumber'}\t$borrower->{'categorycode'}\t0 fine\n";
    }
    if ($difference >= 28){ 
      my $borrower=BorType($data->[$i]->{'borrowernumber'});
      if ($borrower->{'cardnumber'} ne ''){
        my $cost=ReplacementCost($data->[$i]->{'itemnumber'});	
	my $dbh=C4Connect;
	my $env;
	my $accountno=C4::Circulation::Circ2::getnextacctno($env,$data->[$i]->{'borrowernumber'},$dbh);
	my $item=itemnodata($env,$dbh,$data->[$i]->{'itemnumber'});
	if ($item->{'itemlost'} ne '1' && $item->{'itemlost'} ne '2' ){
	  $item->{'title'}=~ s/\'/\\'/g;
	  my $query="Insert into accountlines
	  (borrowernumber,itemnumber,accountno,date,amount,
	  description,accounttype,amountoutstanding) values
	  ($data->[$i]->{'borrowernumber'},$data->[$i]->{'itemnumber'},
	  '$accountno',now(),'$cost','Lost item $item->{'title'} $item->{'barcode'}','L','$cost')";
	  my $sth=$dbh->prepare($query);
	  $sth->execute;
	  $sth->finish;
	  $query="update items set itemlost=2 where itemnumber='$data->[$i]->{'itemnumber'}'";
	  $sth=$dbh->prepare($query);
	  $sth->execute;
	  $sth->finish;
	} else {
	  
	}
	$dbh->disconnect;
      }
    }

  }
}
close FILE;
