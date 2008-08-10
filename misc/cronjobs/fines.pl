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
use Date::Calc qw/Date_to_Days/;
use C4::Biblio;


my $fldir = "/tmp" ;

my $libname=C4::Context->preference('LibraryName');
my $dbname= C4::Context->config('database');

my $today = C4::Dates->new();
my $datestr = $today->output('iso');
my $today_days= Date_to_Days(split(/-/,$today->output('iso')));
my $filename= $dbname;
$filename =~ s/\W//;
$filename = $fldir . '/'. $filename . $datestr . ".log";
open (FILE,">$filename") || die "Can't open LOG";
print FILE "cardnumber\tcategory\tsurname\tfirstname\temail\tphone\taddress\tcitystate\tbarcode\tdate_due\ttype\titemnumber\tdays_overdue\tfine\n";


my $DEBUG =1;

my $data=Getoverdues();
my $overdueItemsCounted=0 ;
my $borrowernumber;

for (my $i=0;$i<scalar(@$data);$i++){
  my $datedue=C4::Dates->new($data->[$i]->{'date_due'},'iso');
  my $datedue_days = Date_to_Days(split(/-/,$datedue->output('iso')));
  my $due_str=$datedue->output();
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

  my $isHoliday = $calendar->isHoliday( split( '/', C4::Dates->new()->output('metric') ) );
      
 if ($datedue_days <= $today_days){
    $overdueItemsCounted++ if $DEBUG;
    my $difference=$today_days - $datedue_days;
    my ($amount,$type,$printout,$daycounttotal,$daycount)=
  		CalcFine($data->[$i], $borrower->{'categorycode'}, $branchcode,undef,undef, $datedue ,$today);
    my ($delays1,$delays2,$delays3)=GetOverdueDelays($borrower->{'categorycode'});

	# Don't update the fine if today is a holiday.  
  	# This ensures that dropbox mode will remove the correct amount of fine.
	if( (C4::Context->preference('finesMode') eq 'production') &&  ! $isHoliday ) {
		# FIXME - $type is always null, afaict.
		UpdateFine($data->[$i]->{'itemnumber'},$data->[$i]->{'borrowernumber'},$amount,$type,$due_str) if( $amount > 0 ) ;
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
