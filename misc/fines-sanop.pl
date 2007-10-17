#!/usr/bin/perl

#  This script loops through each overdue item, determines the fine,
#  and updates the total amount of fines due by each user.  It relies on
#  the existence of /tmp/fines, which is created by ???
# Doesnt really rely on it, it relys on being able to write to /tmp/
# It creates the fines file
#
#  This script is meant to be run nightly out of cron.

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

# $Id$

use C4::Context;
use C4::Circulation;
use C4::Overdues;
use Date::Manip qw/Date_DaysSince1BC/;
use C4::Biblio;
use strict;

open (FILE,'>/tmp/fines') || die;
# FIXME
# it looks like $count is just a counter, would it be
# better to rely on the length of the array @$data and turn the
# for loop below into a foreach loop?
#
my $DEBUG =1;
my $data=Getoverdues();
# warn "Overdues : = ".scalar(@$data)." => ".Data::Dumper::Dumper($data);
my $overdueItemsCounted=0 if $DEBUG;
# FIXME - There's got to be a better way to figure out what day
# today is.
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime(time);
$mon++;
$year=$year+1900;
my $date=Date_DaysSince1BC($mon,$mday,$year);
# print "DATE : ".$date if $DEBUG;
if ($mon < '10'  ){
$mon="0".$mon;
}
if ($mday < '10'  ){
$mday="0".$mday;
}
my $reference = $year."".$mon;
my $borrowernumber;

for (my $i=0;$i<scalar(@$data);$i++){
  my @dates=split('-',$data->[$i]->{'date_due'});
  my $date2=Date_DaysSince1BC($dates[1],$dates[2],$dates[0]);
  my $datedue=$data->[$i]->{'date_due'};
  my $due="$dates[2]/$dates[1]/$dates[0]";
  my $borrower=BorType($data->[$i]->{'borrowernumber'});
  my $starter;
      
 if ($date2 <= $date){
    $overdueItemsCounted++ if $DEBUG;
    my $difference=$date-$date2;
    my ($amount,$type,$printout,$daycounttotal,$daycount)=
    CalcFine($data->[$i]->{'itemnumber'},
        $borrower->{'categorycode'},
        $difference,
        $datedue);
    
    my ($delays1,$delays2,$delays3)=GetOverdueDelays($borrower->{'categorycode'});
    my $issuingrules=GetIssuingRules($data->[$i]->{'itemnumber'},$borrower->{'categorycode'});

# warn "$delays1  and $delays2  and $delays3";
if($delays1  and $delays2  and $delays3)  {
    
    my $debarredstatus=CheckBorrowerDebarred($borrower->{'borrowernumber'});
     
    if (($issuingrules->{'fine'} > 0) || ($issuingrules->{'fine'} ne '' )){

        #DELAYS 1##########################################
#         warn "$amount > 0 && $daycount >= $delays1 && $daycount < $delays2";
        if ($amount > 0 && $daycount >= $delays1 && $daycount < $delays2){
            # FIXME : already in GetIssuingRules ?
            my $debarred1=GetOverduerules($borrower->{'categorycode'},1);
            (UpdateBorrowerDebarred($borrower->{'borrowernumber'}))if(($debarred1 eq '1' ) and ($debarredstatus eq '0'));
            # save fine
            UpdateFine($data->[$i]->{'itemnumber'},$data->[$i]->{'borrowernumber'},$amount,$type,$due);
            # is there an open "dossier" for this date & borrower
            my $getnotifyid=CheckExistantNotifyid($borrower->{'borrowernumber'},$datedue);
        
            my $update=CheckAccountLineLevelInfo($borrower->{'borrowernumber'},$data->[$i]->{'itemnumber'},1,$datedue);
                if ($update eq '0'){
                    if ($getnotifyid eq '0'){
                        $starter=GetNextIdNotify($reference,$borrower->{'borrowernumber'});

                    }
                    else{
                        $starter=$getnotifyid;
                    }
        
                }
            UpdateAccountLines($starter,1,$borrower->{'borrowernumber'},$data->[$i]->{'itemnumber'});
        }
        ###############################################
        #SANOP specific
        if ($daycount>=$delays2) {
    
            $amount=$issuingrules->{'fine'} * ($delays2);
            UpdateFine($data->[$i]->{'itemnumber'},$data->[$i]->{'borrowernumber'},$amount,$type,$due);
    
        }
    
        #DELAYS 2#################################
    
        if ($daycount >= $delays2 && $daycount < $delays3){
        my $debarred2=GetOverduerules($borrower->{'categorycode'},2);
        (UpdateBorrowerDebarred($borrower->{'borrowernumber'}))if(($debarred2 eq '1' ) and ($debarredstatus eq '0'));
       my $update=CheckAccountLineLevelInfo($borrower->{'borrowernumber'},$data->[$i]->{'itemnumber'},2,$datedue);
        if ($update eq '0'){
        UpdateAccountLines(undef,2,$borrower->{'borrowernumber'},$data->[$i]->{'itemnumber'});
        }
        }
        ###############################################
    
        #DELAYS 3###################################
        if ($daycount >= $delays3  ){
            my $debarred3=GetOverduerules($borrower->{'categorycode'},3);
            (UpdateBorrowerDebarred($borrower->{'borrowernumber'}))if(($debarred3 eq '1' ) and ($debarredstatus eq '0'));
            my $update=CheckAccountLineLevelInfo($borrower->{'borrowernumber'},$data->[$i]->{'itemnumber'},3,$datedue);
            if ($update eq '0'){
                    UpdateAccountLines(undef,3,$borrower->{'borrowernumber'},$data->[$i]->{'itemnumber'});
            }
            my $items=GetItems($data->[$i]->{'itemnumber'});
            my $todaydate=$year."-".$mon."-".$mday;
            # add item price, the item is considered as lost.
            my $description="Item Price";
            my $typeaccount="IP";
            my $level="3";
            my $notifyid=GetNotifyId($borrower->{'borrowernumber'},$data->[$i]->{'itemnumber'});
            my $timestamp=$todaydate." ".$hour."\:".$min."\:".$sec;
            my $create=CheckAccountLineItemInfo($borrower->{'borrowernumber'},$data->[$i]->{'itemnumber'},$typeaccount,$notifyid);
            if ($create eq '0'){
    
            CreateItemAccountLine($borrower->{'borrowernumber'},$data->[$i]->{'itemnumber'},$todaydate,$items->{'price'},$description,$typeaccount,
            $items->{'price'},$timestamp,$notifyid,$level);
            }
        }
        ###############################################
    }
}



if ($borrower->{'category_type'} eq 'C'){  
        my $query=qq|    SELECT *
                FROM borrowers
                WHERE borrowernumber=?|;
        my $dbh = C4::Context->dbh;
        my $sth=$dbh->prepare($query);
        $sth->execute($borrower->{'guarantorid'});
        my $tdata=$sth->fetchrow_hashref;
        $sth->finish;
        $borrower->{'phone'}=$tdata->{'phone'};
       }
 print "$printout\t$borrower->{'cardnumber'}\t$borrower->{'category_type'}\t$borrower->{'firstname'}\t$borrower->{'surname'}\t$data->[$i]->{'date_due'}\t$type\t$difference\t$borrower->{'email'}\t$borrower->{'phone'}\t$borrower->{'address'}\t$borrower->{'city'}\t$amount\n";
 }
}

my $numOverdueItems=scalar(@$data);
if ($DEBUG) {
   print <<EOM

Number of Overdue Items counted $overdueItemsCounted
Number of Overdue Items reported $numOverdueItems

EOM
}

close FILE;
