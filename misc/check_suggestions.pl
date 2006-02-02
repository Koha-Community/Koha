#!/usr/bin/perl -w
#-----------------------------------
# Script Name: check_suggestions.pl
# Script Version: 1.0
# Date:  2006/1/15
# author : Paul Poulain (paul@koha-fr.org)
# Description: 
# This script send a mail to librarians that have a suggestion to check
# The mail is sent to the librarian defined in branches table, depending on who
# wrote the suggestion
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

my ($confirm, $nomail);
GetOptions(
    'c'    => \$confirm,
	'n'	=> \$nomail,
);
unless ($confirm) {
	print qq|
This script checks for any pending suggestions and send a mail to the librarian to warn them.
It checks 'ASKED' suggestions, group them by borrower branch, and send a mail to the mail address in branches
table
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
my $smtpserver = 'smtp.server.com'; # your smtp server (the server who sent mails)
my $mailtitle = 'Suggestions to manage'; # the title of the mails
my $mailtext = "Hello\n\nThere are <suggestion_count> waiting for a decision in Koha ILS\n\n\n";
#
# END OF PARAMETERS
#
open OUTFILE, ">overdues" or die "Cannot open file overdues: $!";

# set the e-mail server -- comment out if not doing e-mail notices
unshift @{$Mail::Sendmail::mailcfg{'smtp'}} , $smtpserver;
#                                         set your own mail server name here

my $dbh = C4::Context->dbh;
my $sth = $dbh->prepare ("SELECT count(*),branchemail FROM `suggestions`
left join borrowers on borrowernumber=suggestedby 
left join branches on branches.branchcode=borrowers.branchcode
WHERE status='ASKED' group by borrowers.branchcode
");

$sth->execute;
# 
# my $itemcount = 0;
# my $row;
my $count = 0;   # to keep track of how many notices are printed
my $e_count = 0;   # and e-mailed
my $date=localtime;
my ($suggestion_count,$email);

while (($suggestion_count,$email) = $sth->fetchrow) {
		my $notice = $mailtext;
		$notice =~ s/\<suggestion_count\>/$suggestion_count/g;

	# if not using e-mail notices, comment out the following lines
		if ($email) {   # or you might check for borrowers.preferredcont 
			if ($nomail) {
				print "TO => $email\n";
				print "SUBJECT => $mailtitle\n";
				print "MESSAGE => $notice\n";
			} else {
				my %mail = ( To      => $email,
								From    => 'webmaster@'.$smtpserver,
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
