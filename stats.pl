#!/usr/bin/perl

#written 14/1/2000
#script to display reports

use C4::Stats;
use strict;
use Date::Manip;
use CGI;
use C4::Output;

my $input=new CGI;
my $time=$input->param('time');
print $input->header;

print startpage;
print startmenu('report');
print center;

my $date;
my $date2;
if ($time eq 'yesterday'){
  $date=ParseDate('yesterday');
  $date2=ParseDate('today');
}
if ($time eq 'today'){
  $date=ParseDate('today');
  $date2=ParseDate('tomorrow');
}
if ($time eq 'daybefore'){
  $date=ParseDate('2 days ago');
  $date2=ParseDate('yesterday');
}
if ($time=~ /\//){
  $date=ParseDate($time);
  $date2=ParseDateDelta('+ 1 day');
  $date2=DateCalc($date,$date2);
}
$date=UnixDate($date,'%Y-%m-%d');
$date2=UnixDate($date2,'%Y-%m-%d');
my @payments=TotalPaid($date);
my $count=@payments;
my $total=0;
my %levin;
my %foxton;
my %shannon;
my $oldtime;
#my $totalc=0;
#my $totalcf=0;
print mktablehdr;
print mktablerow(5,'#99cc33',bold('Name'),bold('Type'),bold('Date/time'),bold('Amount'), bold('Branch'),'/images/background-mem.gif');
for (my $i=0;$i<$count;$i++){
  my $hour=substr($payments[$i]{'timestamp'},8,2);
  my  $min=substr($payments[$i]{'timestamp'},10,2);
  my $sec=substr($payments[$i]{'timestamp'},12,2);
  my $time="$hour:$min:$sec";
  $payments[$i]{'amount'}*=-1;
  $total+=$payments[$i]{'amount'};
  my @charges=getcharges($payments[$i]{'borrowernumber'},$payments[$i]{'timestamp'});
  my $count=@charges;
  my $temptotalf=0;
  my $temptotalr=0;
  my $temptotalres=0;
  my $temptotalren=0;
  for (my $i2=0;$i2<$count;$i2++){
    if ($charges[$i2]->{'amountoutstanding'} != $oldtime){
    print mktablerow(6,'red',$charges[$i2]->{'description'},$charges[$i2]->{'accounttype'},'',
    $charges[$i2]->{'amount'},$charges[$i2]->{'amountoutstanding'});
    if ($charges[$i2]->{'accounttype'} eq 'Rent'){
      $temptotalr+=$charges[$i2]->{'amount'}-$charges[$i2]->{'amountoutstanding'};
    }
    if ($charges[$i2]->{'accounttype'} eq 'F' || $charges[$i2]->{'accounttype'} eq 'FU'){
      $temptotalf+=$charges[$i2]->{'amount'}-$charges[$i2]->{'amountoutstanding'};
    }
    if ($charges[$i2]->{'accounttype'} eq 'Res'){
      $temptotalres+=$charges[$i2]->{'amount'}-$charges[$i2]->{'amountoutstanding'};
    }
    if ($charges[$i2]->{'accounttype'} eq 'R'){
      $temptotalren+=$charges[$i2]->{'amount'}-$charges[$i2]->{'amountoutstanding'};
    }
    }
  }                 
  my $time2="$payments[$i]{'date'} $time";
  my $branch=Getpaidbranch($time2);
  $branch=~ s/Levi/C/;
  if ($branch eq 'C'){
    $levin{'total'}+=$payments[$i]{'amount'};
    $levin{'totalr'}+=$temptotalr;
    $levin{'totalres'}+=$temptotalres;
    $levin{'totalf'}+=$temptotalf;
    $levin{'totalren'}+=$temptotalren;
  }
  if ($branch eq 'F'){
    $foxton{'total'}+=$payments[$i]{'amount'};
    $foxton{'totalr'}+=$temptotalr;
    $foxton{'totalres'}+=$temptotalres;
    $foxton{'totalf'}+=$temptotalf;
    $foxton{'totalren'}+=$temptotalren;
  }
  if ($branch eq 'S'){
    $shannon{'total'}+=$payments[$i]{'amount'};
    $shannon{'totalr'}+=$temptotalr;
    $shannon{'totalres'}+=$temptotalres;
    $shannon{'totalf'}+=$temptotalf;
    $shannon{'totalren'}+=$temptotalren;
  }
  print mktablerow(6,'white',"$payments[$i]{'firstname'} <b>$payments[$i]{'surname'}</b>"
  ,$payments[$i]{'accounttype'},"$payments[$i]{'date'} $time",$payments[$i]{'amount'}
  ,$branch);
  $oldtime=$payments[$i]{'timestamp'};
}
print mktableft;
print endcenter;
print "<p><b>$total</b>";
#print "<b
print mktablehdr;
$levin{'issues'}=Count('issue','C',$date,$date2);
$foxton{'issues'}=Count('issue','F',$date,$date2);
$shannon{'issues'}=Count('issue','S',$date,$date2);
$levin{'returns'}=Count('return','C',$date,$date2);
$foxton{'returns'}=Count('return','F',$date,$date2);
$shannon{'returns'}=Count('return','S',$date,$date2);
print mktablerow(9,'white',"<b>Levin</b>","Fines $levin{'totalf'}","Rental Charges $levin{'totalr'}",
"Reserve Charges $levin{'totalres'}","Renewal Charges $levin{'totalren'}","Total $levin{'total'}",
"Issues $levin{'issues'}","Renewals $levin{'renewals'}","Returns $levin{'returns'}");
print mktablerow(9,'white',"<b>foxton</b>","Fines $foxton{'totalf'}","Rental Charges $foxton{'totalr'}","Reserve Charges $foxton{'totalres'}","Renewal Charges $foxton{'totalren'}","Total $foxton{'total'}",
"Issues $foxton{'issues'}","Renewals $foxton{'renewals'}","Returns $foxton{'returns'}");
print mktablerow(9,'white',"<b>shannon</b>","Fines $shannon{'totalf'}","Rental Charges $shannon{'totalr'}","Reserve Charges $shannon{'totalres'}","Renewal Charges $shannon{'totalren'}","Total $shannon{'total'}",
"Issues $shannon{'issues'}","Renewals $shannon{'renewals'}","Returns $shannon{'returns'}");
print mktableft;


print endmenu('report');
print endpage;
