#!/usr/bin/perl

#  This script loops through each overdue item, determines the fine,
#  and updates the total amount of fines due by each user.  It relies on 
#  the existence of /tmp/fines, which is created by ???
# Doesnt really rely on it, it relys on being able to write to /tmp/
# It creates the fines file
#
#  This script is meant to be run nightly out of cron.

use C4::Database;
use C4::Search;
use C4::Circulation::Circ2;
use C4::Circulation::Fines;
use Date::Manip;

open (FILE,'>/tmp/fines') || die;
# FIXME
# it looks like $count is just a counter, would it be
# better to rely on the length of the array @$data and turn the
# for loop below into a foreach loop?
#
my ($numOverdueItems,$data)=Getoverdues();
print $numOverdueItems if $DEBUG;
my $overdueItemsCounted=0 if $DEBUG;

# FIXME
# delete this?
# yep just a debuging thing
#$numOverdueItems=1000;

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime(time);
$mon++;
$year=$year+1900;

my $date=Date_DaysSince1BC($mon,$mday,$year);

# FIXME
# delete this?
# another debugging thing, and yep it can go (you can make the script fake a day, say u want to rerun the overdues for
# a day when for some reason the script didnt run)
#my $date=Date_DaysSince1BC(1,24,2002);
print $date if $DEBUG;

my $bornum;

# FIXME
# $total isn't used anywhere else in the file,
# can we delete it?
#
my $total=0;

# FIXME
# this probably ought to be a global variable or constant
# defined in a central place
#
# Yep
my $maxFine=5;

# FIXME
# delete both of these?
#my $bornum2=$data->[0]->{'borrowernumber'};
#my $i2=1;

# FIXME
# This should be rewritten to be a foreach loop
# Also, this loop is really long, and could be better grokked if broken
# into a number of smaller, separate functions
#
for (my $i=0;$i<$numOverdueItems;$i++){
  my @dates=split('-',$data->[$i]->{'date_due'});
  my $date2=Date_DaysSince1BC($dates[1],$dates[2],$dates[0]);    
  my $due="$dates[2]/$dates[1]/$dates[0]";
  my $borrower=BorType($data->[$i]->{'borrowernumber'});
  if ($date2 <= $date){
    $overdueItemsCounted++ if $DEBUG;
    my $difference=$date-$date2;
    my ($amount,$type,$printout)=
	CalcFine($data->[$i]->{'itemnumber'},
		 $borrower->{'categorycode'},
		 $difference);      
    if ($amount > $maxFine){
      $amount=$maxFine;
    }
    if ($amount > 0){
      UpdateFine($data->[$i]->{'itemnumber'},$data->[$i]->{'borrowernumber'},$amount,$type,$due);

#
# FIXME
# If this isn't needed it should be deleted
#

#      if ($amount ==5){
#	      marklost();
#      }
       if ($borrower->{'categorycode'} eq 'C'){  # FIXME
	                                         # this should be a
                                                 # separate function
                                                 #
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
    } else { # FIXME
	     # if this is really useless, the whole else clause should be 
	     # deleted. 
             #
#      print "$borrower->{'cardnumber'}\t$borrower->{'categorycode'}\t0 fine\n";
    }
    if ($difference >= 28){ # FIXME
	                    # this should be a separate function
                            #
      my $borrower=BorType($data->[$i]->{'borrowernumber'});
      if ($borrower->{'cardnumber'} ne ''){
        my $cost=ReplacementCost($data->[$i]->{'itemnumber'});	
	my $dbh=C4Connect;
	my $env;
	my $accountno=C4::Circulation::Circ2::getnextacctno($env,$data->[$i]->{'borrowernumber'},$dbh);
	my $item=itemnodata($env,$dbh,$data->[$i]->{'itemnumber'});
	if ($item->{'itemlost'} ne '1' && $item->{'itemlost'} ne '2' ){
              # FIXME
              # this should be a separate function
              #
	  $item->{'title'}=~ s/\'/\\'/g;
	  my $query="Insert into accountlines
	  (borrowernumber,itemnumber,accountno,date,amount,
	  description,accounttype,amountoutstanding) values
	  ($data->[$i]->{'borrowernumber'},$data->[$i]->{'itemnumber'},
	  '$accountno',now(),'$cost','Lost item $item->{'title'} $item->{'barcode'} $due','L','$cost')";
	  my $sth=$dbh->prepare($query);
	  $sth->execute;
	  $sth->finish;
	  $query="update items set itemlost=2 where itemnumber='$data->[$i]->{'itemnumber'}'";
	  $sth=$dbh->prepare($query);
	  $sth->execute;
	  $sth->finish;
	} else { # FIXME
	         # this should be deleted
                 #
	}
	$dbh->disconnect;
      }
    }

  }
}

if ($DEBUG) {
   print <<EOM

Number of Overdue Items counted $overdueItemsCounted
Number of Overdue Items reported $numOverdueItems

EOM
}

close FILE;
