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
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}
use C4::Context;
use C4::Dates;
use Mail::Sendmail;  # comment out if not doing e-mail notices
use Getopt::Long;

my ($confirm, $nomail);
GetOptions(
    'c'    => \$confirm,
	'n'	=> \$nomail,
);
unless ($confirm) {
	print qq|
This script will send overdue notices by e-mail and prepare a file of\nnotices for printing if the borrower does not have e-mail.
You MUST edit this script for your library BEFORE you run it for the first time!
See the comments in the script for directions on changing the script.
This script has 2 parameters :
	-c to confirm and remove this help & warning
	-n to avoid sending any mail. Instead, all mail messages are printed on screen. Usefull for testing purposes.

Do you wish to continue? (y/n)
|;
	chomp($_ = <STDIN>);
	exit unless (/^y/i);  # comment these lines out once you've made the changes
	
}
#
# BEGINNING OF PARAMETERS
#
my $mindays = 7; # the notice will be sent after mindays days (grace period)
my $maxdays = 30; # issues being more than maxdays late are managed somewhere else. (borrower probably suspended)
my $smtpserver = 'smtp.server.com'; # your smtp server (the server who sent mails)
my $from = 'librarianname@library.com'; # all the mails sent to the borrowers will appear coming from here.
my $mailtitle = 'Overdues'; # the title of the mails
my $librarymail = 'librarystaff@library.com'; # all notices without mail are sent (in 1 mail) to this mail address. They must then be managed manually.
# this parameter (the last) is the text of the mail that is sent.
# this text contains fields that are replaced by their value. Those fields must be written between brackets
# The following fields are available :
# <date> <itemcount> <firstname> <lastname> <address1> <address2> <address3> <city> <postcode>
my $mailtext = "\n\n\nDear library borrower\n\n\n       <date>\n\n       According to our records, you have <itemcount> items, the description of which follows, that are at\n       least a week overdue for return to the library or renewal:\n		title		author		barcode\n<titles>\n
       If you have registered a password with the library, you may use it\n       and your library card to login at http://XXX.org\n       to check the status of your account, or you may call any of our branch\n       Please be advised that all library services will be blocked\n       if items are allowed to go more than 30 days overdue.\n\n       Thank you for using your public libraries.\n\n\n                                             <firstname> <lastname>\n                                             <address1>\n                                             <address2>\n                                             <city>  <postcode>\n\n\n\n\n\n";
#
# END OF PARAMETERS
#
open OUTFILE, ">overdues" or die "Cannot open file overdues: $!";

# set the e-mail server -- comment out if not doing e-mail notices
unshift @{$Mail::Sendmail::mailcfg{'smtp'}} , $smtpserver;
#                                         set your own mail server name here

my $dbh = C4::Context->dbh;
my $sth = $dbh->prepare ("SELECT COUNT(*), issues.borrowernumber,firstname,surname,streetaddress,physstreet,city,zipcode,emailaddress FROM issues,borrowers,categories WHERE TO_DAYS(NOW())-TO_DAYS(date_due) BETWEEN 0 and 500 AND issues.borrowernumber=borrowers.borrowernumber and borrowers.categorycode=categories.categorycode and categories.overduenoticerequired=1 group by issues.borrowernumber");
my $sth2 = $dbh->prepare("SELECT biblio.title,biblio.author,items.barcode FROM issues,items,biblio WHERE items.itemnumber=issues.itemnumber and biblio.biblionumber=items.biblionumber AND issues.borrowernumber=? AND TO_DAYS(NOW())-TO_DAYS(date_due) BETWEEN 0 and 500");

$sth->execute;
# 
# my $itemcount = 0;
# my $row;
my $count = 0;   # to keep track of how many notices are printed
my $e_count = 0;   # and e-mailed
my $date=localtime;
my ($itemcount,$borrowernumber,$firstname,$lastname,$address1,$address2,$city,$postcode,$email);

while (($itemcount,$borrowernumber,$firstname,$lastname,$address1,$address2,$city,$postcode,$email) = $sth->fetchrow) {
		my $notice = $mailtext;
		$notice =~ s/\<itemcount\>/$itemcount/g;
		$notice =~ s/\<firstname\>/$firstname/g;
		$notice =~ s/\<lastname\>/$lastname/g;
		$notice =~ s/\<address1\>/$address1/g;
		$notice =~ s/\<address2\>/$address2/g;
		$notice =~ s/\<city\>/$city/g;
		$notice =~ s/\<postcode\>/$postcode/g;
		$notice =~ s/\<date\>/$date/g;

		$sth2->execute($borrowernumber);
		my $titles="";
		my ($title, $author, $barcode);
		while (($title, $author, $barcode) = $sth2->fetchrow){
			$titles .= "		".($title?$title:"")."	".($author?$author:"")."	".($barcode?$barcode:"")."\n";
		}
		$notice =~ s/\<titles\>/$titles/g;
		$sth2->finish;
	# if not using e-mail notices, comment out the following lines
		if ($email) {   # or you might check for borrowers.preferredcont 
			if ($nomail) {
				print "TO => $email\n";
				print "FROM => $from\n";
				print "SUBJECT => $mailtitle\n";
				print "MESSAGE => $notice\n";
			} else {
				my %mail = ( To      => $email,
								From    => $from,
								Subject => $mailtitle,
								Message => $notice,
                                'Content-Type' => 'text/plain; charset="utf8"',
					);
				sendmail(%mail);
			}
			$e_count++
		} else {
			print OUTFILE $notice;
			$count++;
		}    # and comment this one out, too, if not using e-mail

}
$sth->finish;
close OUTFILE;
# if some notices have to be printed & managed by the library, send them to library mail address.
if ($count) {
		open ODUES, "overdues" or die "Cannot open file overdues: $!";
		my $notice = "$e_count overdue notices e-mailed\n";
		$notice .= "$count overdue notices in file for printing\n\n";

		$notice .= <ODUES>;
		if ($nomail) {
			print "TO => $email\n" if $email;
			print "FROM => $from\n";
			print "SUBJECT => Koha overdue\n";
			print "MESSAGE => $notice\n";
		} else {
			my %mail = ( To      => $email,
							From    => $from,
							Subject => 'Koha overdues',
							Message => $notice,
                            'Content-Type' => 'text/plain; charset="utf8"',
				);
			sendmail(%mail);
		}
}
