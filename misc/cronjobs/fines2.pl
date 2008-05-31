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

use Date::Manip;	# qw( Date_DaysSince1BC ) ;
use Data::Dumper;
use Getopt::Long;

use C4::Context;
use C4::Circulation;
use C4::Overdues;	# qw( Getoverdues CalcFine );
use C4::Biblio;
use C4::Items;
use C4::Dates;
use C4::Debug;

our $verbose;
GetOptions('verbose+', \$verbose);
$debug and $verbose++;

# my $filename = "/tmp/fines";
# open (FILE, ">$filename") or die "Cannot write to $filename";

my ($data)=Getoverdues();
my $overdueItemsCounted=0;

# FIXME - There's got to be a better way to figure out what day today is.
my ($mday,$mon,$year) = (localtime)[3..5]; # ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)
my $date = Date_DaysSince1BC($mon+1,$mday,$year+1900);
my $today_obj = C4::Dates->new();
my $today_iso = $today_obj->output('iso');

if ($verbose) {
	printf "Number of overdues: %7d\nDate_DaysSince1BC : %7d\n", scalar(@$data), $date;
	print "today: $today_iso\n";
}

# get the maxfine parameter
my $maxFine=C4::Context->preference("MaxFine") || 999999999;

our $phone_sth = C4::Context->dbh->prepare("Select * from borrowers where borrowernumber=?");
sub get_guarantor_phone ($) {
	$phone_sth->execute(shift);
	my $x = $phone_sth->fetchrow_hashref;
	return $x->{'phone'};
}

our $fine_sth = C4::Context->dbh->prepare("
	INSERT INTO accountlines
	(borrowernumber, itemnumber, accountno, date,
	amount, description, accounttype, amountoutstanding)
	VALUES (?,?,?,now(),?,?,'L',?)
	");
sub insert_fine ($$$$$$) {
	$verbose and print "inserting fine: " . join(", ",@_), "\n";
	return $fine_sth->execute(@_);
}

my $circcontrol = C4::Context->preference('CircControl');
foreach (@$data){
	my $date_due = $_->{date_due};
	$verbose and print "date_due: $date_due ", ($date_due le $today_iso ? 'fine!' : 'ok'), "\n";
    my @dates=split('-',$date_due);
    my $date2=Date_DaysSince1BC($dates[1],$dates[2],$dates[0]);
    my $due="$dates[2]/$dates[1]/$dates[0]";
	my $borrowernumber = $_->{borrowernumber};
	my $itemnumber     = $_->{itemnumber};
    my $borrower = BorType($borrowernumber);
    ($date_due le $today_iso) or next;		# it is valid to string compare ISO dates.
	$overdueItemsCounted++ if $verbose;
	my $branchcode = ($circcontrol eq 'PatronLibrary'  ) ? $borrower->{branchcode} : 
					 ($circcontrol eq 'ItemHomeLibrary') ?        $_->{homebranch} :
					 									          $_->{branchcode} ; # Last option: Pickup Library.
	my $difference=$date-$date2;
	my (@calc_returns) = CalcFine(
		$_, $borrower->{categorycode}, $branchcode,undef,undef, C4::Dates->new($date_due,'iso'), $today_obj 
	);
	if ($verbose) {
		my $dump = Dumper($_);
		$dump =~ s/;/,/;
		$verbose and print "CalcFine($dump" .
			"\t$borrower->{categorycode}, $branchcode,undef,undef,[$date_due],[today]) returns:\n" . Dumper(\@calc_returns), "\n";
	}
	my ($amount,$type,$printout) = @calc_returns[0..2];
	# ($amount,$chargename,$daycount,$daycounttotal)=&CalcFine($itemnumber,$categorycode,$branch,$days_overdue,$description, $start_date, $end_date );

	($amount > $maxFine) and $amount = $maxFine;
	if ($amount > 0) {
		UpdateFine($itemnumber,$borrowernumber,$amount,$type,$due);
		if ($borrower->{'guarantorid'}) {
			$borrower->{'phone'} = get_guarantor_phone($borrower->{'guarantorid'}) || $borrower->{'phone'};
		}
		print "$printout\t$borrower->{'cardnumber'}\t$borrower->{'categorycode'}\t$borrower->{'firstname'}\t$borrower->{'surname'}\t",
		"$_->{'date_due'}\t$type\t$difference\t",
		"$borrower->{'emailaddress'}\t$borrower->{'phone'}\t$borrower->{'streetaddress'}\t$borrower->{'city'}\t$amount\n" if $verbose;
	}
	if ($difference >= C4::Context->preference("NoReturnSetLost")){
		my $borrower=BorType($borrowernumber);
		if ($borrower->{'cardnumber'} ne ''){
			my $cost = ReplacementCost($itemnumber);
			my $item = GetBiblioFromItemNumber($itemnumber);
			if ($item->{'itemlost'} ne '1' && $item->{'itemlost'} ne '2' ){
				insert_fine(
					$borrowernumber,
					$itemnumber,
					C4::Accounts::getnextacctno($borrowernumber),
					$cost,
					"Lost item $item->{'title'} $item->{'barcode'} $due",
					$cost
				);
				ModItem({ itemlost => 2 }, undef, $itemnumber);
			}
		}
	}
}

if ($verbose) {
    my $numOverdueItems=scalar(@$data);
    print <<EOM

Number of Overdue Items counted  $overdueItemsCounted
Number of Overdue Items reported $numOverdueItems

EOM
}

# close FILE;
