#!/usr/bin/perl -w
#-----------------------------------
# Script Name: overduenotices.pl
# Script Version: 1.0
# Date:  2003/9/7
# Author:  Stephen Hedges (shedges@skemotah.com)
# modified by Paul Poulain (paul@koha-fr.org)
# Description: 
#	This script runs a Koha report of items that
#	are between 7 and 30 days overdue and generates
#       a file that may be dumped to a printer.  The time period
#	may be changed by editing the SQL statement handle
#	prepared in line 52.  The actual wording of the overdue
#	notices may be changed by editing the $notice variable
#	in line 101.  The current notice text is formatted to
#	fit the standard 34-line 'Speedimailer' form.
# Revision History:
#    1.0  2003/9/7: original version
#-----------------------------------
# Copyright 2003 Skemotah Solutions
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
use C4::Context;
use C4::Date;
use Mail::Sendmail;  # comment out if not doing e-mail notices

print "This script will send overdue notices by e-mail and prepare a file of\nnotices for printing if the borrower does not have e-mail.\nYou MUST edit this script for your library BEFORE you run it for the first time!\nSee the comments in the script for directions on changing the script.\n\nDo you wish to continue? (y/n) ";
chomp($_ = <STDIN>);
die unless (/^y/i);  # comment these lines out once you've made the changes

#
# BEGINNING OF PARAMETERS
#
my $mindays = 7 # the notice will be sent after mindays days (grace period)
my $maxdays = 30 # issues being more than maxdays late are managed somewhere else. (borrower probably suspended)
my $smtpserver = 'smtp.yourserver.com'; # your smtp server (the server who sent mails)
my $from = 'library@yourname.org';
my $mailtitle = 'Overdue library items';
my $librarymail = 'library@yourname.org'; # all notices without mail are sent (in 1 mail) to this mail address. They must then be managed manually.
# this parameter (the last) is the text of the mail that is sent.
# this text contains fields that are replaced by their value. Those fields must be written between brackets
# The following fields are available :
# <date> <itemcount> <firstname> <lastname> <address1> <address2> <address3> <city> <postcode>
my $mailtext = "\n\n\nDear library borrower\n\n\n       <date>\n\n       According to our records, you have <itemcount> items that are at\n       least a week overdue for return to the library or renewal.\n       If you have registered a password with the library, you may use it\n       and your library card to login at http://XXX.org\n       to check the status of your account, or you may call any of our branch\n       Please be advised that all library services will be blocked\n       if items are allowed to go more than 30 days overdue.\n\n       Thank you for using your public libraries.\n\n\n                                             <firstname> <lastname>\n                                             <address1>\n                                             <address2>\n                                             <city>  <postcode>\n\n\n\n\n\n";
#
# END OF PARAMETERS
#
open OUTFILE, ">overdues" or die "Cannot open file overdues: $!";

# set the e-mail server -- comment out if not doing e-mail notices
unshift @{$Mail::Sendmail::mailcfg{'smtp'}} , $smtpserver;
#                                         set your own mail server name here

my $dbh = C4::Context->dbh;
my $sth = $dbh->prepare ("SELECT issues.borrowernumber,firstname,surname,streetaddress,physstreet,city,zipcode,emailaddress FROM issues,borrowers,categorie WHERE returndate IS NULL AND TO_DAYS(NOW())-TO_DAYS(date_due) BETWEEN $mindays and $maxdays AND issues.borrowernumber=borrowers.borrowernumber and borrowers.categorycode=categories.categorycode and categories.overduenoticerequired=1 ORDER BY issues.borrowernumber");
my $first_borrno = $dbh->prepare ("SELECT borrowernumber FROM issues WHERE returndate IS NULL AND TO_DAYS(NOW())-TO_DAYS(date_due) BETWEEN $mindays and $maxdays ORDER BY borrowernumber");
my $get_date = $dbh->prepare ("SELECT CURDATE()");

$get_date->execute;
my $daydate = $get_date->fetchrow_arrayref;
my $rawdate = $daydate->[0];
my $date = format_date($rawdate);
$first_borrno->execute;               # get first borrowernumber
my $firstborr = $first_borrno->fetchrow_arrayref;
my $borrowernumber = $firstborr->[0];
$first_borrno->finish;  

$sth->execute;

my $itemcount = 0;
my $row;
my $count = 0;   # to keep track of how many notices are printed
my $e_count = 0;   # and e-mailed
my ($firstname,$lastname,$address1,$address2,$city,$postcode,$email);

while ($row = $sth->fetchrow_arrayref) {
    my $borrno = $row->[0];
    if ($itemcount==0) {    # store values for first borrower
		$firstname = $row->[1];
		$lastname = $row->[2];
		$address1 = $row->[3];
		$address2 = $row->[4];
		unless ($address2) {
			$address2 = '';
		}
		$city = $row->[5];
		unless ($city) {
			$city = '';
		}
		$postcode = $row->[6];
		unless ($postcode) {
			$postcode = '';
		}
		$email = $row->[7];
    }
    if ($borrno == $borrowernumber) {     # next borrower yet?
		$itemcount++;
		next;
    } else {
		$borrowernumber = $borrno;
		my $notice = $mailtext;
		$notice =~ s/\<date\>/$date/g;
		$notice =~ s/\<itemcount\>/$itemcount/g;
		$notice =~ s/\<firstname\>/$firstname/g;
		$notice =~ s/\<lastname\>/$lastname/g;
		$notice =~ s/\<address1\>/$address1/g;
		$notice =~ s/\<address2\>/$address2/g;
		$notice =~ s/\<address3\>/$address3/g;
		$notice =~ s/\<city\>/$city/g;
		$notice =~ s/\<postcode\>/$postcode/g;
	
	# if not using e-mail notices, comment out the following lines
		if ($email) {   # or you might check for borrowers.preferredcont 
			my %mail = ( To      => $email,
							From    => $from,
							Subject => $mailtitle,
							Message => $notice,
				);
			sendmail(%mail);
			$e_count++
		} else {
		# if not using e-mail notices, comment out the above lines
			print $notice;
			print OUTFILE $notice;
			$count++;
		}    # and comment this one out, too, if not using e-mail

		$itemcount = 1;   #start the count for next notice
		$firstname = $row->[1]; # and store the new values
		$lastname = $row->[2];
		$address1 = $row->[3];
		$address2 = $row->[4];
		unless ($address2) {
			$address2 = '';
		}
		$city = $row->[5];
		unless ($city) {
			$city = '';
		}
		$postcode = $row->[6];
		unless ($postcode) {
			$postcode = '';
		}
		$email = $row->[7];
	}
}
$sth->finish;
close OUTFILE;
# if some notices have to be printed & managed by the library, send them to library mail address.
if ($count) {
		open ODUES, "overdues" or die "Cannot open file overdues: $!";
		my $notice = "$e_count overdue notices e-mailed\n";
		my $notice .= "$count overdue notices in file for printing\n\n";

		my $notice .= <ODUES>;
	    my %mail = ( To      => $email,
                         From    => $from,
                         Subject => 'Koha overdues',
                         Message => $notice,
			 );
	    sendmail(%mail);

