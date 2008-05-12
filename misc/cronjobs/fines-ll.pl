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


use strict;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}
use C4::Context;
use C4::Circulation;
use C4::Overdues;
use C4::Calendar;
use Date::Manip qw/Date_DaysSince1BC/;
use C4::Biblio;
#use Data::Dumper;
#
my $fldir = "/tmp";

my $libname=C4::Context->preference('LibraryName');
my $dbname= C4::Context->config('database');

my $SET_LOST = 0;  #  automatically charge item price at delay=3 if set.

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime(time);
$mon++;
$year=$year+1900;
my $date=Date_DaysSince1BC($mon,$mday,$year);
my $datestr = $year . sprintf("-%02d-%02d",$mon,$mday);
my $filename= $dbname;
$filename =~ s/\W//;
$filename = $fldir . '/'. $filename . $datestr . ".log";
open (FILE,">$filename") || die "Can't open LOG";
print FILE "cardnumber\tcategory\tsurname\tfirstname\temail\tphone\taddress\tcitystate\tbarcode\tdate_due\ttype\titemnumber\tdays_overdue\tfine\n";

# FIXME
# it looks like $count is just a counter, would it be
# better to rely on the length of the array @$data and turn the
# for loop below into a foreach loop?
#
my $DEBUG =1;
my $data=Getoverdues();
# warn "Overdues : = ".scalar(@$data)." => ".Data::Dumper::Dumper($data);
my $overdueItemsCounted=0 if $DEBUG;
my $reference = $year."".$mon;
my $borrowernumber;

for (my $i=0;$i<scalar(@$data);$i++){
  my @dates=split('-',$data->[$i]->{'date_due'});
  my $date2=Date_DaysSince1BC($dates[1],$dates[2],$dates[0]);
  my $datedue=$data->[$i]->{'date_due'};
  my $due="$dates[1]/$dates[2]/$dates[0]";
  my $borrower=BorType($data->[$i]->{'borrowernumber'});
  my $branchcode;
  if ( C4::Context->preference('CircControl') eq 'ItemHomeLibrary' ) {
  	$branchcode = $data->[$i]->{'homebranch'};
  } elsif ( C4::Context->preference('CircControl') eq 'PatronLibrary' ) {
  	$branchcode = $borrower->{'branchcode'};
} else {
  	# CircControl must be PickupLibrary. (branchcode comes from issues table here).
	$branchcode =  $data->[$i]->{'branchcode'};
  }
  my $calendar = C4::Calendar->new( branchcode => $branchcode );

  my @dmy =  split( '-', C4::Dates->new()->output('metric') ) ;
  my $isHoliday = $calendar->isHoliday( split( '/', C4::Dates->new()->output('metric') ) );
  my $starter;
      
 if ($date2 <= $date){
    $overdueItemsCounted++ if $DEBUG;
    my $difference=$date-$date2;
	my $start_date = C4::Dates->new($data->[$i]->{'date_due'},'iso');
	my $end_date = C4::Dates->new($datestr,'iso');
    my ($amount,$type,$printout,$daycounttotal,$daycount)=
  		CalcFine($data->[$i], $borrower->{'categorycode'}, $branchcode,undef,undef, $start_date,$end_date);
    my ($delays1,$delays2,$delays3)=GetOverdueDelays($borrower->{'categorycode'});

	# Don't update the fine if today is a holiday.  
  	# This ensures that dropbox mode will remove the correct amount of fine.
	if( ! $isHoliday ) {
		# FIXME - $type is always null, afaict.
		UpdateFine($data->[$i]->{'itemnumber'},$data->[$i]->{'borrowernumber'},$amount,$type,$due) if( $amount > 0 ) ;
 	}
	if($delays1  and $delays2  and $delays3)  {
    
    	my $debarredstatus=CheckBorrowerDebarred($borrower->{'borrowernumber'});

        #DELAYS 1##########################################
        if ($amount > 0 && $daycount >= $delays1 && $daycount < $delays2){
            # FIXME : already in GetIssuingRules ?
            my $debarred1=GetOverduerules($borrower->{'categorycode'},1);
            (UpdateBorrowerDebarred($borrower->{'borrowernumber'}))if(($debarred1 eq '1' ) and ($debarredstatus eq '0'));
            # is there an open "dossier" for this date & borrower
            my $getnotifyid=CheckExistantNotifyid($borrower->{'borrowernumber'},$datedue);
            my $update=CheckAccountLineLevelInfo($borrower->{'borrowernumber'},$data->[$i]->{'itemnumber'},1,$datedue);
            if ($update eq '0'){
               	if ($getnotifyid eq '0'){
                        $starter=GetNextIdNotify($reference,$borrower->{'borrowernumber'});
               	} else {
                  $starter=$getnotifyid;
              	}
            }
            UpdateAccountLines($starter,1,$borrower->{'borrowernumber'},$data->[$i]->{'itemnumber'});
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
            if ($SET_LOST && ($create eq '0') ){
          		CreateItemAccountLine($borrower->{'borrowernumber'},$data->[$i]->{'itemnumber'},$todaydate,$items->{'price'},$description,$typeaccount,
            		$items->{'price'},$timestamp,$notifyid,$level);
            }
        }
        ###############################################
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
 	print FILE "$printout\t$borrower->{'cardnumber'}\t$borrower->{'categorycode'}\t$borrower->{'surname'}\t$borrower->{'firstname'}\t$borrower->{'email'}\t$borrower->{'phone'}\t$borrower->{'address'}\t$borrower->{'city'}\t$data->[$i]->{'barcode'}\t$data->[$i]->{'date_due'}\t$type\t$data->[$i]->{'itemnumber'}\t$daycounttotal\t$amount\n";
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
