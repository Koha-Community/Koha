#!/usr/bin/perl -w
#-----------------------------------
# Script Name: overduenotices.pl
# Script Version: 1.0
# Date:  2003/9/7
# Author:  Stephen Hedges (shedges@skemotah.com)
# modified by Paul Poulain (paul@koha-fr.org)
# modified by Henri-Damien LAURENT (henridamien@koha-fr.org)
# Description: 
#	This script runs a Koha report of items using overduerules tables and letters tool management.
# Revision History:
#    1.0  2003/9/7: original version
#    1.5  2006/2/28: Modifications for managing Letters and overduerules
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
use C4::Dates;
use Mail::Sendmail;  # comment out if not doing e-mail notices
use Getopt::Long;

my ($confirm, $nomail, $mybranch, $myborcat,$myborcatout, $letter, $MAX, $choice);
GetOptions(
    'c'    => \$confirm,
    'n'	=> \$nomail,
    'max=s'	=> \$MAX,
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
        -max <MAX> MAXIMUM day count before stopping to send overdue notice,
        -file <filename> to enter a specific filename to be read for message.
        -all to include ALL the items that reader borrowed.

Do you wish to continue? (y/n)
|;
        chomp($_ = <STDIN>);
        exit unless (/^(y|Y|o|O)/i);  # comment these lines out once you've made the changes
        
}
my $dbh = C4::Context->dbh;
my $rqoverduebranches=$dbh->prepare("SELECT DISTINCT branchcode FROM overduerules WHERE delay1>0");
$rqoverduebranches->execute;
while (my ($branchcode)=$rqoverduebranches->fetchrow){
    warn "branchcode : $branchcode";
    my $branchname;
    my $emailaddress;
    if ($branchcode){
        my $rqbranch=$dbh->prepare("SELECT * FROM branches WHERE branchcode = ?");
        $rqbranch->execute($branchcode);
        my $data = $rqbranch->fetchrow_hashref;
        $emailaddress = $data->{branchemail};
        $branchname = $data->{branchname};
    }
    $emailaddress=C4::Context->preference('KohaAdminEmailAddress') unless ($emailaddress);

    #print STDERR "$emailaddress\n";
    #
    # BEGINNING OF PARAMETERS
    #
    my $rqoverduerules=$dbh->prepare("SELECT * FROM overduerules WHERE delay1>0 and branchcode = ?");
    $rqoverduerules->execute($branchcode);
    while (my $data=$rqoverduerules->fetchrow_hashref){
        for (my $i=1; $i<=3;$i++){
            #Two actions :
            # A- Send a letter
            # B- Debar
            my $mindays = $data->{"delay$i"}; # the notice will be sent after mindays days (grace period)
            my $rqdebarring=$dbh->prepare("UPDATE borrowers SET debarred=1 WHERE borrowernumber=?") if $data->{"debarred$i"};
            my $maxdays = ($data->{"delay".($i+1)}?
                            $data->{"delay".($i+1)}
                            :($MAX?$MAX:365)); # issues being more than maxdays late are managed somewhere else. (borrower probably suspended)
            #LETTER parameters
            my $smtpserver = 'smtp.wanadoo.fr'; # your smtp server (the server who sent mails)
            my $from = $emailaddress; # all the mails sent to the borrowers will appear coming from here.
            my $mailtitle = 'Overdue'; # the title of the mails
            $mailtitle = 'Issue status' if ($choice); # the title of the mails
            my $librarymail = $emailaddress; # all notices without mail are sent (in 1 mail) to this mail address. They must then be managed manually.
            my $letter = $data->{"letter$i"} if $data->{"letter$i"};
            # this parameter (the last) is the text of the mail that is sent.
            # this text contains fields that are replaced by their value. Those fields must be written between brackets
            # The following fields are available :
            # <date> <itemcount> <firstname> <lastname> <address1> <address2> <address3> <city> <postcode>
            my $mailtext=$letter;
            #
            # END OF PARAMETERS
            #
            open OUTFILE, ">overdues" or die "Cannot open file overdues: $!";
            
            # set the e-mail server -- comment out if not doing e-mail notices
            unshift @{$Mail::Sendmail::mailcfg{'smtp'}} , $smtpserver;
            # set your own mail server name here
            
            my $strsth = "SELECT COUNT(*), issues.borrowernumber,firstname,surname,address,address2,city,zipcode, email, MIN(date_due) as longest_issue FROM issues,borrowers,categories WHERE returndate IS NULL AND issues.borrowernumber=borrowers.borrowernumber AND borrowers.categorycode=categories.categorycode ";
            $strsth .= " AND issues.branchcode='".$branchcode."' " if ($branchcode);
            $strsth .= " AND borrowers.categorycode='".$data->{categorycode}."' " if ($data->{categorycode});
            $strsth .= " AND categories.overduenoticerequired=1 GROUP BY issues.borrowernumber HAVING TO_DAYS(NOW())-TO_DAYS(longest_issue) BETWEEN $mindays and $maxdays ";
            my $sth = $dbh->prepare ($strsth);
#             warn "".$strsth;
            my $sth2 = $dbh->prepare("SELECT biblio.title,biblio.author,items.barcode, issues.timestamp FROM issues,items,biblio WHERE items.itemnumber=issues.itemnumber and biblio.biblionumber=items.biblionumber AND issues.borrowernumber=? AND returndate IS NULL AND TO_DAYS(NOW())-TO_DAYS(date_due) BETWEEN $mindays and $maxdays");

            $sth->execute;
            # 
            # my $itemcount = 0;
            # my $row;
            my $count = 0;   # to keep track of how many notices are printed
            my $e_count = 0;   # and e-mailed
            my $date=format_date(localtime);
            my ($itemcount,$borrowernumber,$firstname,$lastname,$address1,$address2,$city,$postcode,$email);
            
            while (($itemcount, $borrowernumber, $firstname, $lastname, $address1, $address2, $city, $postcode, $email) = $sth->fetchrow) {
                if ($data->{"debarred$i"}){
                    #action taken is debarring
                    $rqdebarring->execute($borrowernumber);
                    warn "debarring $borrowernumber $firstname $lastname";
                }
                if ($letter){
                    my $notice .= $mailtext;
                    $notice =~ s/\<itemcount\>/$itemcount/g if ($itemcount);
                    $notice =~ s/\<firstname\>/$firstname/g if ($firstname);
                    $notice =~ s/\<lastname\>/$lastname/g if ($lastname);
                    $notice =~ s/\<address1\>/$address1/g if ($address1);
                    $notice =~ s/\<address2\>/$address2/g if ($address2);
                    $notice =~ s/\<city\>/$city/g if ($city);
                    $notice =~ s/\<postcode\>/$postcode/g if ($postcode);
                    $notice =~ s/\<date\>/$date/g if ($date);
                    $notice =~ s/\<bib\>/$branchname/g if ($branchname);
    
                    $sth2->execute($borrowernumber);
                    my $titles="";
                    my ($title, $author, $barcode, $issuedate);
                    while (($title, $author, $barcode,$issuedate) = $sth2->fetchrow){
                            $titles .= "	".format_date($issuedate)."	".($barcode?$barcode:"")."	".($title?$title:"")."	".($author?$author:"")."\n";
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
                                    );
                            sendmail(%mail);
                        }
                        $e_count++
                    } else {
                        print OUTFILE $notice;
                        $count++;
                    }    # and comment this one out, too, if not using e-mail
                }
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
                    my %mail = (To      => $email,
                                From    => $from,
                                Subject => 'Koha overdues',
                                Message => $notice,
                            );
                    sendmail(%mail);
                }
            }
        }
    }
}
