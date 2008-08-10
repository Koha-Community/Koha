#!/usr/bin/perl -w
#-----------------------------------
# Script Name: circstats.pl
# Script Version: 1.0
# Date:  2006/02/07
# Author:  Stephen Hedges (shedges@skemotah.com)
# Description: 
#	This script creates a comma-separated value file of
#	circulation statistics for any given month and year.
#       The statistics are grouped by itemtype, then by branch,
#	then by issues and renewals.
# Revision History:
#    1.0  2006/02/07: original version
#-----------------------------------
# Contributed 2003-6 by Skemotah Solutions
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

# use strict;

# UNCOMMENT the following lines if running from a command line
# print "THIS SCRIPT produces a comma-separated values file of circulation statistics for a given month and year.\n\nDo you wish to continue? (y/n) ";
# chomp($_ = <STDIN>);
# die unless (/^y/i);

# UNCOMMENT the following lines if getting old stats (but be aware that renewal numbers are affected by deletes)
# YOU WILL also need to modify the SQLs to use these dates
# my ($month,$year);
# print "Get statistics for which month (1 to 12)? ";
# chomp($month = <STDIN>);
# die if ($month < 1 || $month > 12);
# print "Get statistics for which year (2000 to 2050)? ";
# chomp($year = <STDIN>);
# die if ($year < 2000 || $year > 2050);

open OUTFILE, ">circstats.csv" or die "Cannot open file circstats.csv: $!";
print OUTFILE "\"ccode\",\"branch\",\"issues\",\"renewals\"\n";

use C4::Context;
use C4::Koha;
use Mail::Sendmail;  # comment out 3 lines if not doing e-mail sending of file
use MIME::QuotedPrint;
use MIME::Base64;
# set the e-mail server -- comment out if not doing e-mail notices
unshift @{$Mail::Sendmail::mailcfg{'smtp'}} , 'localhost';
#                                         set your own mail server name here

my $dbh = C4::Context->dbh;
#my $sth1 = $dbh->prepare ("SELECT itemtype FROM itemtypes ORDER BY itemtype");
my $sth2 = $dbh->prepare ("SELECT branchcode, branchname FROM branches ORDER BY branchcode");

# number of checkouts for this library
my $sth3 = $dbh->prepare ("SELECT COUNT(*) FROM biblioitems,items,statistics WHERE biblioitems.biblioitemnumber=items.biblioitemnumber AND statistics.itemnumber=items.itemnumber AND items.ccode=? AND YEAR(statistics.datetime)=YEAR(SUBDATE(CURDATE(),INTERVAL 1 MONTH)) AND MONTH(statistics.datetime)=MONTH(SUBDATE(CURDATE(),INTERVAL 1 MONTH)) AND statistics.branch=? AND statistics.type='issue' GROUP BY ccode");

# number of renewals for this library
my $sth4 = $dbh->prepare ("SELECT COUNT(statistics.itemnumber) FROM statistics,items,biblioitems
	WHERE YEAR(statistics.datetime)=YEAR(SUBDATE('2007-01-01',INTERVAL 1 MONTH))
	AND MONTH(statistics.datetime)=MONTH(SUBDATE('2007-01-01',INTERVAL 1 MONTH))
	AND statistics.itemnumber=items.itemnumber
	AND biblioitems.ccode=?
        AND homebranch=?
        AND biblioitems.biblioitemnumber=items.biblioitemnumber
        AND statistics.type='renew'
        GROUP BY statistics.type");                                                                                         

# find the itemnumbers
my ($rowt,$rowb,$rowi,$rowr,$itemtype,$branchcode,$branchname,$issues,$renews,$line);

#$sth1->execute();
my ($ccode_count,@ccode_results) = GetCcodes;

#for my $ccode (@ccode_results);
# loop through every itemtype
#while ($rowt = $sth1->fetchrow_arrayref) {
for (my $i=0;$i<scalar(@ccode_results);$i++) {
#for my $ccode (@ccode_results) {
    unless (!$ccode_results[$i]) {
#	use Data::Dumper;
#	warn Dumper($ccode_results[$i]);
    $itemtype = $ccode_results[$i]{'authorised_value'}; #$ccode->{authorised_value}; #rowt->[0];
    $line = "\"$itemtype\"";
#	warn "$itemtype\n";
	# find branchnames
    $sth2->execute();

	# find the number of issues per itemtype in this branch
    while ($rowb = $sth2->fetchrow_arrayref) {
		$branchcode = $rowb->[0];
		$branchname = $rowb->[1];
		$sth3->execute($itemtype,$branchcode); # find issues by itemtype per branch
		$rowi = $sth3->fetchrow_arrayref;
		$issues = $rowi->[0]; # count
		unless ($issues) {$issues=""}
		$sth3->finish;

		$sth4->execute($itemtype,$branchcode); # find reserves by itemtype per branch
		$rowr = $sth4->fetchrow_arrayref; # count
		$renews = $rowr->[0];
		unless ($renews) {$renews=""}
		$sth4->finish;

		# put the data in this line
		$line = $line . ",\"$branchname\",\"$issues\",\"$renews\"";
#		warn "LINE: $branchname $issues $renews\n";
    }
    $sth2->finish;

    $line = $line . "\n";
    print OUTFILE "$line";
	}
}
#$sth1->finish;
close OUTFILE;
$dbh->disconnect;

# send the outfile as an attachment to the library e-mail

my %attachmail = (
         from => $from_address,
         to => $to_addresses,
         subject => 'Circulation Statistics',
        );


my $boundary = "====" . time() . "====";
$attachmail{'content-type'} = "multipart/mixed; boundary=\"$boundary\"";

my $attachmessage = "Attached is the file of circulation statistics for the previous month. Please open the statistics spreadsheet template for Page 1, open this file in a new spreadsheet, and paste the numbers from this file into the template.\n";

my $attachfile = "circstats.csv"; 

open (F, $attachfile) or die "Cannot read $attachfile: $!";
binmode F; undef $/;
$attachmail{body} = encode_base64(<F>);
close F;

$boundary = '--'.$boundary;
$attachmail{body} = <<END_OF_BODY;
$boundary
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

$attachmessage
$boundary
Content-Type: application/octet-stream; name="circstats.csv"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="circstats.csv"

$attachmail{body}
$boundary--
END_OF_BODY

sendmail(%attachmail) || print "Error: $Mail::Sendmail::error\n";

