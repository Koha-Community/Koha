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
use Getopt::Long;

my ($confirm, $nomail, $mybranch, $myborcat,$myborcatout, $letter, $choice);
GetOptions(
    'c'    => \$confirm,
	'n'	=> \$nomail,
	'branch=s'	=> \$mybranch,
	'borcat=s'	=> \$myborcat,
	'borcatout=s'	=> \$myborcatout,
	'file=s'	=> \$letter,
	'all'	=> \$choice,
);
unless ($confirm) {
	print qq|
This script will send overdue notices by e-mail and prepare a file of\nnotices for printing if the borrower does not have e-mail.
You MUST edit this script for your library BEFORE you run it for the first time!
See the comments in the script for directions on changing the script.
This script has 2 parameters :
	-c to confirm and remove this help & warning
	-n to avoid sending any mail. Instead, all mail messages are printed on screen. Usefull for testing purposes.
	-branch <branchcode> to select overdues for ONE specific branch.
	-borcat <borcatcode> to select overdues for one borrower category,
	-borcatout <borcatcode> to exclude this borrower category from overdunotices,
	-file <filename> to enter a specific filename to be read for message.
	-all to include ALL the items that reader borrowed.

Do you wish to continue? (y/n)
|;
	chomp($_ = <STDIN>);
	exit unless (/^(y|Y|o|O)/i);  # comment these lines out once you've made the changes
	
}
#warn 'site '.$mybranch.' text '.$letter;
my $dbh = C4::Context->dbh;
my $branchname;
my $emailaddress;
if ($mybranch){
my $rqbranch=$dbh->prepare("SELECT * from branches where branchcode = ?");
$rqbranch->execute($mybranch);
my $data = $rqbranch->fetchrow_hashref;
$emailaddress = $data->{branchemail};
$branchname = $data->{branchname};
}
$emailaddress=C4::Context->preference('KohaAdminEmailAddress') unless ($emailaddress);

#print STDERR "$emailaddress\n";
#
# BEGINNING OF PARAMETERS
#
my $mindays = 0; # the notice will be sent after mindays days (grace period)
my $maxdays = 90; # issues being more than maxdays late are managed somewhere else. (borrower probably suspended)
my $smtpserver = 'smtp.wanadoo.fr'; # your smtp server (the server who sent mails)
my $from = $emailaddress; # all the mails sent to the borrowers will appear coming from here.
my $mailtitle = 'Relance'; # the title of the mails
$mailtitle = 'Etat des prêts' if ($choice); # the title of the mails
my $librarymail = $emailaddress; # all notices without mail are sent (in 1 mail) to this mail address. They must then be managed manually.
# this parameter (the last) is the text of the mail that is sent.
# this text contains fields that are replaced by their value. Those fields must be written between brackets
# The following fields are available :
# <date> <itemcount> <firstname> <lastname> <address1> <address2> <address3> <city> <postcode>
my $mailtext;
$mailtext = "\n\n\nDear library borrower\n\n\n       <date>\n\n       According to our records, you have <itemcount> items, the description of which follows, that are at\n       least a week overdue for return to the library or renewal:\n		title		author		barcode\n<titles>\n
       If you have registered a password with the library, you may use it\n       and your library card to login at http://XXX.org\n       to check the status of your account, or you may call any of our branch\n       Please be advised that all library services will be blocked\n       if items are allowed to go more than 30 days overdue.\n\n       Thank you for using your public libraries.\n\n\n                                             <firstname> <lastname>\n                                             <address1>\n                                             <address2>\n                                             <city>  <postcode>\n\n\n\n\n\n" unless ($letter);
if ($letter){
	open LETTER, "<$letter" or die "Cannot open file $letter for letter,\ncheck filename, path or rights";
	$mailtext = do{local $/;<LETTER>}; ;
# print STDERR $mailtext;
}
#
# END OF PARAMETERS
#
open OUTFILE, ">overdues" or die "Cannot open file overdues: $!";

# set the e-mail server -- comment out if not doing e-mail notices
unshift @{$Mail::Sendmail::mailcfg{'smtp'}} , $smtpserver;
#                                         set your own mail server name here

my $strsth = "SELECT COUNT(*), issues.borrowernumber,firstname,surname,streetaddress,physstreet,city,zipcode,emailaddress FROM issues,borrowers,categories WHERE returndate IS NULL AND issues.borrowernumber=borrowers.borrowernumber and borrowers.categorycode=categories.categorycode ";
$strsth .= " and issues.branchcode='".$mybranch."' " if ($mybranch);
$strsth .= " and borrowers.categorycode='".$myborcat."' " if ($myborcat);
$strsth .= " and borrowers.categorycode<>'".$myborcatout."' " if ($myborcatout);
$strsth .= " AND TO_DAYS(NOW())-TO_DAYS(date_due) BETWEEN 0 and 500 and categories.overduenoticerequired=1 " unless ($choice);
$strsth .= " group by issues.borrowernumber";
my $sth = $dbh->prepare ($strsth);
#warn "".$strsth;
my $sth2 = $dbh->prepare("SELECT biblio.title,biblio.author,items.barcode, issues.timestamp FROM issues,items,biblio WHERE items.itemnumber=issues.itemnumber and biblio.biblionumber=items.biblionumber AND issues.borrowernumber=? AND returndate IS NULL AND TO_DAYS(NOW())-TO_DAYS(date_due) BETWEEN 0 and 500");

$sth->execute;
# 
# my $itemcount = 0;
# my $row;
my $count = 0;   # to keep track of how many notices are printed
my $e_count = 0;   # and e-mailed
my $date=format_date(localtime);
my ($itemcount,$borrnum,$firstname,$lastname,$address1,$address2,$city,$postcode,$email);

while (($itemcount,$borrnum,$firstname,$lastname,$address1,$address2,$city,$postcode,$email) = $sth->fetchrow) {
#		print STDERR "$itemcount,$borrnum,$firstname,$lastname,$address1,$address2,$city,$postcode,$email\n"; 
		my $notice .= $mailtext;
#		print STDERR "$notice\n";
		$notice =~ s/\<itemcount\>/$itemcount/g if ($itemcount);
		$notice =~ s/\<firstname\>/$firstname/g if ($firstname);
		$notice =~ s/\<lastname\>/$lastname/g if ($lastname);
		$notice =~ s/\<address1\>/$address1/g if ($address1);
		$notice =~ s/\<address2\>/$address2/g if ($address2);
		$notice =~ s/\<city\>/$city/g if ($city);
		$notice =~ s/\<postcode\>/$postcode/g if ($postcode);
		$notice =~ s/\<date\>/$date/g if ($date);
		$notice =~ s/\<bib\>/$branchname/g if ($branchname);

		$sth2->execute($borrnum);
		my $titles="";
		my ($title, $author, $barcode, $issuedate);
		while (($title, $author, $barcode,$issuedate) = $sth2->fetchrow){
			$titles .= "	".format_date($issuedate)."	".($barcode?$barcode:"")."	".($title?$title:"")."	".($author?$author:"")."\n";
		}
#			print STDERR "$titles";
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
				);
			sendmail(%mail);
		}
}
