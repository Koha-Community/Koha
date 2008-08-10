#!/usr/bin/perl -w
#-----------------------------------
# Script Name: borrstats.pl
# Script Version: 1.0
# Date:  2006/02/24
# Author:  Stephen Hedges (shedges@skemotah.com)
# Description: 
#	This script creates a comma-separated value file of
#	new borrower statistics for any given month and year.
#       The statistics are grouped by borrower type, then by
#	branch.
# Revision History:
#    1.0  2006/02/24: original version
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

open OUTFILE, ">borrstats.csv" or die "Cannot open file borrstats.csv: $!";
print OUTFILE "\"type\",\"branch\",\"count\"\n";

use C4::Context;
use Mail::Sendmail;  # comment out 3 lines if not doing e-mail sending of file
use MIME::QuotedPrint;
use MIME::Base64;
# set the e-mail server -- comment out if not doing e-mail notices
unshift @{$Mail::Sendmail::mailcfg{'smtp'}} , 'localhost';
#                                         set your own mail server name here

my $dbh = C4::Context->dbh;
my $sth1 = $dbh->prepare ("SELECT categorycode FROM categories ORDER BY categorycode");
my $sth2 = $dbh->prepare ("SELECT branchcode,COUNT(branchcode) FROM borrowers WHERE categorycode=? AND YEAR(dateenrolled)=YEAR(SUBDATE(CURDATE(),INTERVAL 1 MONTH)) AND MONTH(dateenrolled)=MONTH(SUBDATE(CURDATE(),INTERVAL 1 MONTH)) GROUP BY branchcode");

my ($rowc,$rowb,$categorycode,$branchcode,$count,$line);

$sth1->execute();

while ($rowc = $sth1->fetchrow_arrayref) {
    $categorycode = $rowc->[0];
    $line = "\"$categorycode\"";
    
    $sth2->execute($categorycode);

    while ($rowb = $sth2->fetchrow_arrayref) {
	$branchcode = $rowb->[0];
	$count = $rowb->[1];

	$line = $line . ",\"$branchcode\",\"$count\"";
    }
    $sth2->finish;

    $line = $line . "\n";
    print OUTFILE "$line";
}
$sth1->finish;
close OUTFILE;
$dbh->disconnect;

# send the outfile as an attachment to the library e-mail

my %attachmail = (
         from => $from_address,
         to => $to_addresses,
         subject => 'New Patrons Statistics',
        );


my $boundary = "====" . time() . "====";
$attachmail{'content-type'} = "multipart/mixed; boundary=\"$boundary\"";

my $attachmessage = "Attached is the file of new borrower statistics for the previous month. Please open the statistics spreadsheet for Page 2, open this file in a new spreadsheet, and paste the numbers from this file into the statistics spreadsheet.\n";

my $attachfile = "borrstats.csv"; 

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
Content-Type: application/octet-stream; name="borrstats.csv"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="borrstats.csv"

$attachmail{body}
$boundary--
END_OF_BODY

sendmail(%attachmail) || print "Error: $Mail::Sendmail::error\n";

