#!/usr/bin/perl -w
#-----------------------------------
# Script Name: overduenotices.pl
# Script Version: 1.0
# Date:  2003/9/7
# Author:  Stephen Hedges (shedges@skemotah.com)
# modified by Paul Poulain (paul@koha-fr.org)
# Description: 
#	This script runs send a mail with an attached file of all overdues
#       that can be used for overdues claims, with your preffered word processor
#       (OpenOffice.org hopefully ;-) )

# Revision History:
#    1.0  2003/9/7: original version
#-----------------------------------
# Copyright 2003 Skemotah Solutions
#           2007 Paul POULAIN
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
use Date::Manip;
use Mail::Sendmail;  # comment out if not doing e-mail notices
use Getopt::Long;
use MIME::QuotedPrint;
use MIME::Base64;
use utf8;

my ($confirm, $nomail,$branch,$filename);
GetOptions(
    'c'    => \$confirm,
	'n'	=> \$nomail,
	'b:s' => \$branch,
	'o:s' => \$filename,
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
my $maxdays = 500; # issues being more than maxdays late are managed somewhere else. (borrower probably suspended)
my $smtpserver = 'smtp.laposte.net'; # your smtp server (the server who sent mails)
my $from = 'fromadress@toto'; # all the mails sent to the borrowers will appear coming from here.
my $mailtitle = 'Relances'; # the title of the mails
my $librarymail = 'tonadress@email'; # all notices without mail are sent (in 1 mail) to this mail address. They must then be managed manua lly.
# this parameter (the last) is the text of the mail that is sent.
# this text contains fields that are replaced by their value. Those fields must be written between brackets
# The following fields are available :
# <date> <itemcount> <firstname> <lastname> <address1> <address2> <address3> <city> <postcode>
my $mailtext = q("<firstname>";"<lastname>";"<address>";"<address2>";"<postcode>";"<city>";"<email>";"<itemcount>";<titles>);
#
# END OF PARAMETERS
#
my $result;
$result= <<END_HEADER;
Name;Surname;Adress1;Adress2;zipcode;city;Mail;Nbitems;1title;1author;1barcode;1issuedate;1returndate;2title;2author;2barcode;2issue_date;2return_date;3title;3author;3barcode;3issue_date;3return_date;4title;4author;4barcode;4issue_date;4return_date;5title;5author;5barcode;5issue_date;5return_date;6title;6author;6barcode;6issue_date;6return_date;7title;7author;7barcode;7issue_date;7return_date;8title;8author;8barcode;8issue_date;8return_date;9title;9author;9barcode;9issue_date;9return_date;10title;10author;10barcode;10issue_date;10return_date;
END_HEADER

# set the e-mail server -- comment out if not doing e-mail notices
# unshift @{$Mail::Sendmail::mailcfg{'smtp'}} , $smtpserver;
#                                         set your own mail server name here

my $dbh = C4::Context->dbh;
my $query = "SELECT COUNT(*), issues.borrowernumber,firstname,surname,address,address2,city,zipcode,email FROM issues,borrowers ,categories WHERE TO_DAYS(NOW())-TO_DAYS(date_due) BETWEEN $mindays and $maxdays AND issues.borrowernumber=borrowers.borrowernumber and borrowers.categorycode=categories.categorycode and (categories.overduenoticerequired = 1)";
$query .= " AND borrowers.branchcode=".$dbh->quote($branch) if $branch;
$query .=" GROUP BY issues.borrowernumber";
my $sth = $dbh->prepare ($query);

warn "Q : $query";
my $sth2 = $dbh->prepare("SELECT biblio.title,biblio.author,items.barcode, issues.timestamp, issues.date_due FROM issues,items,biblio WHERE items.itemnumber=issues.itemnumber and biblio.biblionumber=items.biblionumber AND issues.borrowernumber=? AND TO_DAYS(NOW())-TO_DAYS(date_due) BETWEEN $mindays and $maxdays");

$sth->execute;
#
# my $itemcount = 0;
# my $row;
my $count = 0;   # to keep track of how many notices are printed
my $e_count = 0;   # and e-mailed
my ($itemcount,$borrnum,$firstname,$lastname,$address1,$address2,$city,$postcode,$email);

while (($itemcount,$borrnum,$firstname,$lastname,$address1,$address2,$city,$postcode,$email) = $sth->fetchrow) {
                my $notice = $mailtext;
                $notice =~ s/\<firstname\>/$firstname/g if $firstname;
                $notice =~ s/\<lastname\>/$lastname/g if $lastname;
                $notice =~ s/\<address1\>/$address1/g if $address1;
                $notice =~ s/\<address2\>/$address2/g if $address2;
                $notice =~ s/\<email\>/$email/g if $email;
                $notice =~ s/\<postcode\>/$postcode/g if $postcode;
                $notice =~ s/\<city\>/$city/g if $city;
                $notice =~ s/\<itemcount\>/$itemcount/g;

                $sth2->execute($borrnum);
                my $titles="";
                my ($title, $author, $barcode,$timestamp,$date_due);
                while (($title, $author, $barcode,$timestamp,$date_due) = $sth2->fetchrow){
                        $titles .= '"'.($title?$title:"").'";"'.($author?$author:"").'";"'.($barcode?$barcode:"").'";"' ;
                        $titles .= ($timestamp?format_date(substr($timestamp,0,10)):"").'";"'.($date_due?format_date($date_due):"").'";' ;
                }
                $notice =~ s/\<titles\>/$titles/g;
                $notice =~ s/(\<.*?\>)//g;
                $sth2->finish;
                $result.=$notice."\n";
                $count++;

}
$sth->finish;
if ($nomail) {
    if ($filename){
	open OUTFILE, ">:utf8","$filename" or die "impossible d'ouvrir le fichier de relances";
	print OUTFILE $result;
	close OUTFILE;
    } 
    else {
    	binmode STDOUT, ":encoding(UTF-8)";
       	print $result;
    }
} else {
        my %mail = ( To      => 'mailto@mail.com',
                                        From    => 'mailfrom@mail.com',
                                        Subject => 'Koha overdues',
                );
        my $boundary = "====" . time() . "====";
        $mail{'content-type'} = "multipart/mixed; boundary=\"$boundary\"";
        
        my $message = encode_qp("The file");
        
        $mail{body} = encode_base64($result);
	open OUTFILE, ">:utf8","$filename" or die "impossible d'ouvrir le fichier de relances";
	print OUTFILE $result;
	close OUTFILE;
        
        $boundary = '--'.$boundary;
        $mail{body} = <<END_OF_BODY;
$boundary
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable

$message
$boundary
Content-Type: application/octet-stream; name="$^X"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="$filename"

$mail{body}
$boundary--
END_OF_BODY
        
        sendmail(%mail) || print "Error: $Mail::Sendmail::error\n";

}

#}
