#!/usr/bin/perl

#script to keep total of number of issues;


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
#my $date=Date_DaysSince1BC(12,4,2000);
my $bornum;

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
      if ($amount ==5){
#	      marklost();
      }
      print "$printout\t$borrower->{'cardnumber'}\t$borrower->{'categorycode'}\t$borrower->{'firstname'}\t$borrower->{'surname'}\t$data->[$i]->{'date_due'}\t$type\t$difference\t$borrower->{'emailaddress'}\t$borrower->{'phone'}\t$borrower->{'streetaddress'}\t$borrower->{'city'}\t$amount\n";
    } else {
#      print "$borrower->{'cardnumber'}\t$borrower->{'categorycode'}\t0 fine\n";
    }

  }
}
close FILE;
