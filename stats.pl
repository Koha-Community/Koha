#!/usr/bin/perl

# $Id$

#written 14/1/2000
#script to display reports


# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

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
my $totalw=0;
#my $totalcf=0;
print mktablehdr;
print mktablerow(5,'#99cc33',bold('Name'),bold('Type'),bold('Date/time'),bold('Amount'), bold('Branch'),'/images/background-mem.gif');
my $i=0;
while ($i<$count){
  my $time=$payments[$i]{'datetime'};
  my $payments=$payments[$i]{'value'};
  my $charge=0;
  my @temp=split(/ /,$payments[$i]{'datetime'});
  my $date=$temp[0];
  my @charges=getcharges($payments[$i]{'borrowernumber'},$payments[$i]{'timestamp'});
  my $count=@charges;
  my $temptotalf=0;
  my $temptotalr=0;
  my $temptotalres=0;
  my $temptotalren=0;
  my $temptotalw=0;
  for (my $i2=0;$i2<$count;$i2++){
     $charge+=$charges[$i2]->{'amount'};
      print mktablerow(6,'red',$charges[$i2]->{'description'},$charges[$i2]->{'accounttype'},$charges[$i2]->{'timestamp'},
      $charges[$i2]->{'amount'},$charges[$i2]->{'amountoutstanding'});
      if ($payments[$i]{'accountytpe'} ne 'W'){
        if ($charges[$i2]->{'accounttype'} eq 'Rent'){
          $temptotalr+=$charges[$i2]->{'amount'}-$charges[$i2]->{'amountoutstanding'};
        }
        if ($charges[$i2]->{'accounttype'} eq 'F' || $charges[$i2]->{'accounttype'} eq 'FU' || $charges[$i2]->{'accounttype'} eq 'FN' ){
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

#  my $branch=
  my $hour=substr($payments[$i]{'timestamp'},8,2);
  my  $min=substr($payments[$i]{'timestamp'},10,2);
  my $sec=substr($payments[$i]{'timestamp'},12,2);
  my $time="$hour:$min:$sec";
  my $time2="$payments[$i]{'date'}";
  my $branch=Getpaidbranch($time2,$payments[$i]{'borrowernumber'});
  if ($branch eq 'C'){
    $levin{'totalf'}+=$temptotalf;
    $levin{'totalres'}+=$temptotalres;
    $levin{'totalren'}+=$temptotalren;
    $levin{'totalr'}+=$temptotalr;
  } elsif ($branch eq 'F'){
    $foxton{'totalf'}+=$temptotalf;
    $foxton{'totalres'}+=$temptotalres;
    $foxton{'totalren'}+=$temptotalren;
    $foxton{'totalr'}+=$temptotalr;
  } elsif ($branch eq 'S'){
    $shannon{'totalf'}+=$temptotalf;
    $shannon{'totalres'}+=$temptotalres;
    $shannon{'totalren'}+=$temptotalren;
    $shannon{'totalr'}+=$temptotalr;
  }
  my $bornum=$payments[$i]{'borrowernumber'};
  my $oldtime=$payments[$i]{'timestamp'};
  my $oldtype=$payments[$i]{'accounttype'};
  while ($bornum eq $payments[$i]{'borrowernumber'} && $oldtype == $payments[$i]{'accounttype'}  && $oldtime eq $payments[$i]{'timestamp'}){
     my $hour=substr($payments[$i]{'timestamp'},8,2);
     my  $min=substr($payments[$i]{'timestamp'},10,2);
     my $sec=substr($payments[$i]{'timestamp'},12,2);
     my $time="$hour:$min:$sec";
         my $time2="$payments[$i]{'date'}";
     my $branch=Getpaidbranch($time2,$payments[$i]{'borrowernumber'});

    if ($payments[$i]{'accounttype'} eq 'W'){
      $totalw+=$payments[$i]{'amount'};
    } else {
      $payments[$i]{'amount'}=$payments[$i]{'amount'}*-1;
      $total+=$payments[$i]{'amount'};
      if ($branch eq 'C'){
        $levin{'total'}+=$payments[$i]{'amount'};
      }
      if ($branch eq 'F'){
        $foxton{'total'}+=$payments[$i]{'amount'};
      }
      if ($branch eq 'S'){
        $shannon{'total'}+=$payments[$i]{'amount'};
      }

    }
#    my $time2="$payments[$i]{'date'} $time";


    print mktablerow(6,'white',"$payments[$i]{'firstname'} <b>$payments[$i]{'surname'}</b>",
    ,$payments[$i]{'accounttype'},"$payments[$i]{'date'} $time",$payments[$i]{'amount'}
    ,$branch);
    $oldtype=$payments[$i]{'accounttype'};
    $oldtime=$payments[$i]{'timestamp'};
    $bornum=$payments[$i]{'borrowernumber'};
    $i++;

  }
  print mktablerow('6','white','','','','','','');
}
print mktableft;
print endcenter;
#$totalw=$totalw * -1;
print "<p><b>Total Paid $total</b>";
print "<br><b>total written off $totalw</b>";
print mktablehdr;
$levin{'issues'}=Count('issue','C',$date,$date2);
$foxton{'issues'}=Count('issue','F',$date,$date2);
$shannon{'issues'}=Count('issue','S',$date,$date2);
$levin{'returns'}=Count('return','C',$date,$date2);
$foxton{'returns'}=Count('return','F',$date,$date2);
$shannon{'returns'}=Count('return','S',$date,$date2);
$levin{'renewals'}=Count('renew','C',$date,$date2);
$foxton{'renewals'}=Count('renew','F',$date,$date2);
$shannon{'renewals'}=Count('renew','S',$date,$date2);
$levin{'unknown'}=$levin{'total'}-($levin{'totalf'}+$levin{'totalr'}+$levin{'totalres'}+$levin{'totalren'});
$foxton{'unknown'}=$foxton{'total'}-($foxton{'totalf'}+$foxton{'totalr'}+$foxton{'totalres'}+$foxton{'totalren'});
$foxton{'unknown'}=$foxton{'total'}-($foxton{'totalf'}+$foxton{'totalr'}+$foxton{'totalres'}+$foxton{'totalren'});
print mktablerow(10,'white',"<b>Levin</b>","Fines $levin{'totalf'}","Rental Charges $levin{'totalr'}",
"Reserve Charges $levin{'totalres'}","Renewal Charges $levin{'totalren'}","Unknown $levin{'unknown'}","<b>Total $levin{'total'}</b>",
"Issues $levin{'issues'}","Renewals $levin{'renewals'}","Returns $levin{'returns'}");
print mktablerow(10,'white',"<b>foxton</b>","Fines $foxton{'totalf'}","Rental Charges $foxton{'totalr'}","Reserve Charges $foxton{'totalres'}","Renewal Charges $foxton{'totalren'}","Unknown $foxton{'unknown'}","<b>Total $foxton{'total'}</b>",
"Issues $foxton{'issues'}","Renewals $foxton{'renewals'}","Returns $foxton{'returns'}");
print mktablerow(10,'white',"<b>shannon</b>","Fines $shannon{'totalf'}","Rental Charges $shannon{'totalr'}","Reserve Charges $shannon{'totalres'}","Renewal Charges $shannon{'totalren'}","Unknown $shannon{'unknown'}","<b>Total $shannon{'total'}</b>",
"Issues $shannon{'issues'}","Renewals $shannon{'renewals'}","Returns $shannon{'returns'}");
print mktableft;


print endmenu('report');
print endpage;
