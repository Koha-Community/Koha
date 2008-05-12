#!/usr/bin/perl -w
#-----------------------------------
# Script Name: reservefix.pl
# Script Version: 1.0.0
# Date:  2004/02/22
# Author:  Stephen Hedges  shedges@skemotah.com
# Description: fixes priority of reserves
#    It also e-mails a list of 'problem' reserves
#    to me at the library
# Usage: reservefix.pl.
# Revision History:
#    1.0.0  2004/02/22:  original version
#-----------------------------------

use strict;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}
use C4::Context;
use Date::Manip;
use Mail::Sendmail;

my $dbh   = C4::Context->dbh;
my $message;   # e-mail message
my $admin = 'root@localhost'; #To
my @library = 'root@localhost'; #From
#    get biblionumbers of unfilled reserves
my $bibnos_sth=$dbh->prepare("SELECT DISTINCT biblionumber FROM reserves WHERE found IS NULL AND priority>0");
my $get_sth=$dbh->prepare("SELECT * FROM reserves WHERE biblionumber=? AND found IS NULL ORDER BY reservedate,priority");
#    checking reservedate avoids overwriting legitimate duplicate reserves
my $put_sth=$dbh->prepare("UPDATE reserves SET priority=? WHERE biblionumber=? AND borrowernumber=? AND reservedate=?");
my $count_sth=$dbh->prepare("SELECT COUNT(itemnumber) FROM items WHERE biblionumber=?");
my $dvd_sth=$dbh->prepare("SELECT itemtype FROM biblioitems WHERE biblionumber=?");

$bibnos_sth->execute();

while (my $number=$bibnos_sth->fetchrow_arrayref) {
    my $bibliono=$number->[0];

    $get_sth->execute($bibliono);

    my $priority=0;
    while (my $data=$get_sth->fetchrow_hashref){
	$priority++;
	my $bibno = $data->{'biblionumber'};
	my $borrno = $data->{'borrowernumber'};
	my $resdate = $data->{'reservedate'};
	if ($priority==1) {
	    my $date1 = DateCalc("today","- 60 days"); # calculate date 60 days ago
	    my $date2 = ParseDate($resdate);
	    my $flag = Date_Cmp($date2,$date1);
	    if ($flag<0) {      # date1 is later
		$dvd_sth->execute($bibno);
		while (my $itemtype=$dvd_sth->fetchrow_arrayref) {
		    my $it = $itemtype->[0];
		    if ($it) {
			if ($it ne 'DVD') {
			    $message .= "Check $bibno\n";
#			    print "Check $bibno\n";
			}
		    } else {
			$message .= "$bibno has no itemtype\n";
#			print "$bibno has no itemtype\n";
		    }
		}
		$dvd_sth->finish;
	    }
	}
	$put_sth->execute($priority,$bibno,$borrno,$resdate);
	$put_sth->finish;
    }

    $count_sth->execute($bibliono);         # get item count
    my $itemcount=$count_sth->fetchrow;
    if (($priority/4)>$itemcount) {      # no more than 4 reserves per item
	$dvd_sth->execute($bibliono);
	while (my $itemtype=$dvd_sth->fetchrow_arrayref) {
	    my $it = $itemtype->[0];
	    if ($it) {
		if ($it ne 'DVD') {
		    $message .= "Check $bibliono\n";
#		    print "Check $bibliono\n";
		}
	    } else {
		$message .= "$bibliono has no itemtype\n"
#		print "$bibliono has no itemtype\n";
	    }
	}
	$dvd_sth->finish;
    }
    $count_sth->finish;
    $get_sth->finish;
}
$bibnos_sth->finish;
$dbh->disconnect;

my %mail = ( To      => '$admin',
             From    => '$library',
             Subject => 'Reserve problems',
             Message => $message,
            'Content-Type' => 'text/plain; charset="utf8"',
 	    );
sendmail(%mail);

