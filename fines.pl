#!/usr/bin/perl

#script to calculate fines


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
#my $date=Date_DaysSince999($mon,$mday,$year);
my $date=Date_DaysSince999(2,20,2000);
my $bornum;
my $borrower;
my $total=0;
my $max=5;
my $bornum2;
for (my $i=0;$i<$count;$i++){
  my @dates=split('-',$data->[$i]->{'date_due'});
    my $date2=Date_DaysSince999($dates[1],$dates[2],$dates[0]);    
    my $due="$dates[2]/$dates[1]/$dates[0]";
    if ($date2 <= $date){
      $count2++;
      my $difference=$date-$date2;
      if ($bornum != $data->[$i]->{'borrowernumber'}){
        
        $bornum=$data->[$i]->{'borrowernumber'};
        $borrower=BorType($bornum);
      }


          my ($amount,$type,$printout)=CalcFine($data->[$i]->{'itemnumber'},$borrower->{'categorycode'},$difference);      
	  if ($amount > $max){
  	    $amount=$max;
	  }
	  if ($amount > 0){
            UpdateFine($data->[$i]->{'itemnumber'},$bornum,$amount,$type,$due);
	    if ($bornum2 == $data->[$i]->{'borrowernumber'}){
	      $total=$total+$amount;
	    } else {
	      print FILE "\"$borrower->{'cardnumber'}\"\,\"$borrower->{'phone'}\"\,\"Overdue or Extd Rental$total\"\,\"$borrower->{'homebranch'}\"\n";
	      $total=$amount;
	    }
  	    if ($amount ==5){
#	      marklost();
            }
              print "$printout\t$borrower->{'cardnumber'}\t$borrower->{'firstname'}\t$borrower->{'surname'}\t$data->[$i]->{'date_due'}\t$type\t$difference\t$borrower->{'emailaddress'}\t$borrower->{'phone'}\t$borrower->{'streetaddress'}\t$borrower->{'city'}\n";
	  } else {
#	    print "0 fine\n";
	  }

    }
    $bornum2=$data->[$i]->{'borrowernumber'};
}
close FILE;
