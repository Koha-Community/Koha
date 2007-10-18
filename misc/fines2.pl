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


use C4::Context;
use C4::Circulation;
use C4::Overdues;
use Date::Manip;
use C4::Biblio;
use strict;

open (FILE,'>/tmp/fines') || die;
# FIXME
# it looks like $count is just a counter, would it be
# better to rely on the length of the array @$data and turn the
# for loop below into a foreach loop?
#
my $DEBUG=0;
my ($data)=Getoverdues();
print scalar(@$data) if $DEBUG;
my $overdueItemsCounted=0 if $DEBUG;

# FIXME - There's got to be a better way to figure out what day
# today is.
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime(time);
$mon++;
$year=$year+1900;

my $date=Date_DaysSince1BC($mon,$mday,$year);

print $date if $DEBUG;

my $borrowernumber;

# FIXME
# $total isn't used anywhere else in the file,
# can we delete it?
#
my $total=0;

# get the maxfine parameter
my $maxFine=C4::Context->preference("MaxFine") || 999999999;

# FIXME
# This should be rewritten to be a foreach loop
# Also, this loop is really long, and could be better grokked if broken
# into a number of smaller, separate functions
#
for (my $i=0;$i<scalar(@$data);$i++){
    my @dates=split('-',$data->[$i]->{'date_due'});
    my $date2=Date_DaysSince1BC($dates[1],$dates[2],$dates[0]);
    my $due="$dates[2]/$dates[1]/$dates[0]";
    my $borrower=BorType($data->[$i]->{'borrowernumber'});
    if ($date2 <= $date){
        $overdueItemsCounted++ if $DEBUG;
        my $difference=$date-$date2;
        my ($amount,$type,$printout)=
        CalcFine($data->[$i],
            $borrower->{'categorycode'},
            $difference);
        if ($amount > $maxFine){
            $amount=$maxFine;
        }
        if ($amount > 0){
            UpdateFine($data->[$i]->{'itemnumber'},$data->[$i]->{'borrowernumber'},$amount,$type,$due);
            if ($borrower->{'categorycode'} eq 'C'){  # FIXME
                my $dbh = C4::Context->dbh;
                my $sth=$dbh->prepare("Select * from borrowers where borrowernumber=?");
                $sth->execute($borrower->{'guarantor'});
                my $tdata=$sth->fetchrow_hashref;
                $sth->finish;
                $borrower->{'phone'}=$tdata->{'phone'};
            }
            print "$printout\t$borrower->{'cardnumber'}\t$borrower->{'categorycode'}\t$borrower->{'firstname'}\t$borrower->{'surname'}\t$data->[$i]->{'date_due'}\t$type\t$difference\t$borrower->{'emailaddress'}\t$borrower->{'phone'}\t$borrower->{'streetaddress'}\t$borrower->{'city'}\t$amount\n" if $DEBUG;
        }
        if ($difference >= C4::Context->preference("NoReturnSetLost")){
            my $borrower=BorType($data->[$i]->{'borrowernumber'});
            if ($borrower->{'cardnumber'} ne ''){
                my $cost=ReplacementCost($data->[$i]->{'itemnumber'});
                my $dbh = C4::Context->dbh;
                my $accountno=C4::Accounts::getnextacctno($data->[$i]->{'borrowernumber'});
                my $item=GetBiblioFromItemNumber($data->[$i]->{'itemnumber'});
                if ($item->{'itemlost'} ne '1' && $item->{'itemlost'} ne '2' ){
                    # FIXME this should be a separate function
                    my $sth=$dbh->prepare("INSERT INTO accountlines
                    (borrowernumber,itemnumber,accountno,date,amount,
                    description,accounttype,amountoutstanding) VALUES
                    (?,?,?,now(),?,?,'L',?)");
                    $sth->execute($data->[$i]->{'borrowernumber'},$data->[$i]->{'itemnumber'},
                    $accountno,$cost,"Lost item $item->{'title'} $item->{'barcode'} $due",$cost);
                    $sth->finish;
                    $sth=$dbh->prepare("UPDATE items SET itemlost=2 WHERE itemnumber=?");
                    $sth->execute($data->[$i]->{'itemnumber'});
                    $sth->finish;
                }
            }
        }
    }
}

if ($DEBUG) {
    my $numOverdueItems=scalar(@$data);
    print <<EOM

Number of Overdue Items counted $overdueItemsCounted
Number of Overdue Items reported $numOverdueItems

EOM
}

close FILE;
