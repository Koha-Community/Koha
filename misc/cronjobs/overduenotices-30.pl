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
#    2.01 2008/2/21: Overhaul, provide command line SMTP options, fix ouput
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
use C4::Dates qw/format_date/;
use C4::Debug;
use Mail::Sendmail;  # comment out if not doing e-mail notices
use Getopt::Long;

sub usage () {
	return <<EndOfUsage
This script will send overdue notices by e-mail and prepare a file of
notices for printing if the borrower does not have e-mail.

Optional script parameters :
	-c to confirm and bypass this help & warning
	-n no mail mode: avoid sending any mail. Instead, all mail messages are printed on screen.  Useful for testing.
	-branch <branchcode> to select overdues for ONE specific branch.
	-borcat <borcatcode> to select overdues for ONE borrower category,        NOT IMPLEMENTED
	-borcatout <borcatcode> to exclude borrower category from overdunotices,  NOT IMPLEMENTED
	-max <MAX> MAXIMUM day count before stopping to send overdue notice,
	-file <filename> to enter a specific filename to be read for message.
	-all to include ALL the items that reader borrowed, not just overdues.    NOT IMPLEMENTED ?

Example: 
	misc/cronjobs/overduenotices-30.pl -c -branch MAIN -s foobar.mail.com 

EndOfUsage
	;
}

my ($confirm, $nomail, $mybranch, $myborcat,$myborcatout, $letter, $MAX, $choice);
my ($smtpserver);
GetOptions(
    'all'         => \$choice,
    'c'           => \$confirm,
    'n'	          => \$nomail,
    'max=s'	      => \$MAX,
    'smtp=s'      => \$smtpserver,
	'branch=s'    => \$mybranch,
	'borcat=s'    => \$myborcat,
	'borcatout=s' => \$myborcatout,
);

my $deathknell = "Parameter %s is not implemented.  Remove this option and try again.";
$myborcat    and die usage . sprintf($deathknell, "-borcat ($myborcat)");
$myborcatout and die usage . sprintf($deathknell, "-borcatout ($myborcatout)");
$choice      and die usage . sprintf($deathknell, "-all");

# $confirm = 1;  # uncomment to hardcode pre-confirmation
$smtpserver = ($smtpserver || 'smtp.wanadoo.fr'); # hardcode your smtp server (outgoing mail)
unshift @{$Mail::Sendmail::mailcfg{'smtp'}} , $smtpserver;
print STDERR ($nomail) ? "No Mail Mode\n" : "using SMTP: $smtpserver\n";
unless ($confirm) {
        print qq|
WARNING: You MUST edit this script for your library BEFORE you run it for the first time!
See the comments in the script for directions on changing the script.

|	. &usage . "Do you wish to continue? (y/[n]) ";
	chomp($_ = <STDIN>);
	unless (/^\s*[yo]/i) {
		print "Exiting.\n";
		exit;
	}
}

my $dbh = C4::Context->dbh;
my $rqoverduebranches=$dbh->prepare("SELECT DISTINCT branchcode FROM overduerules WHERE delay1 IS NOT NULL");
$rqoverduebranches->execute;
my @branches = map {shift @$_} @{$rqoverduebranches->fetchall_arrayref};
$rqoverduebranches->finish;

my $branchcount = scalar(@branches);
print "Found $branchcount branch(es) with first message enabled: " . join(' ', map {"\'$_\'"} @branches), "\n"; 
$branchcount or die "No branches with active overduerules";

if ($mybranch) {
	print "Branch $mybranch selected\n";
	if (scalar grep {$mybranch eq $_} @branches) {
		@branches = ($mybranch);
	} else {
		print "No active overduerules for branch '$mybranch'\n";
		(scalar grep {'' eq $_} @branches)
			or die "No active overduerules for DEFAULT either!";
		print "Falling back on default rules for $mybranch\n";
		@branches = ('');
	}
}

foreach my $branchcode (@branches) {
    my $branchname;
    my $emailaddress;
    if ($branchcode) {
        my $rqbranch=$dbh->prepare("SELECT branchemail,branchname FROM branches WHERE branchcode = ?");
        $rqbranch->execute($mybranch || $branchcode);
        ($emailaddress,$branchname) = $rqbranch->fetchrow;
    }
	$emailaddress = C4::Context->preference('KohaAdminEmailAddress') unless ($emailaddress);

    print STDERR sprintf "branchcode : '%s' using %s\n", ($mybranch || $branchcode), $emailaddress;
    
    # BEGINNING OF PARAMETERS
	my $rqdebarring    = $dbh->prepare("UPDATE borrowers SET debarred=1 WHERE borrowernumber=? ");
	my $letter_sth     = $dbh->prepare("SELECT content FROM letter WHERE code = ? ");
	my $sth2           = $dbh->prepare("
	SELECT biblio.title, biblio.author, items.barcode, issues.timestamp
	FROM   issues,items,biblio
	WHERE  items.itemnumber=issues.itemnumber
	AND    biblio.biblionumber=items.biblionumber
	AND    issues.borrowernumber=?
	AND    TO_DAYS(NOW())-TO_DAYS(date_due) BETWEEN ? and ? ");
    my $rqoverduerules = $dbh->prepare("SELECT * FROM overduerules WHERE delay1 IS NOT NULL AND branchcode = ? ");
    $rqoverduerules->execute($branchcode);
	my $outfile = 'overdues_' . ($mybranch || $branchcode || 'default');
	open (OUTFILE, ">$outfile") or die "Cannot write file $outfile : $!";
    while (my $data=$rqoverduerules->fetchrow_hashref){
        for (my $i=1; $i<=3; $i++) {
            # Two actions:
            # A- Send a letter
            # B- Debar
			$debug and print STDERR "branch '$branchcode', pass $i\n";
            my $mindays = $data->{"delay$i"}; # the notice will be sent after mindays days (grace period)
            my $maxdays = ($data->{"delay".($i+1)}?
                           $data->{"delay".($i+1)}
                            :($MAX?$MAX:365)); # issues being more than maxdays late are managed somewhere else. (borrower probably suspended)
            # LETTER parameters
            my $from = $emailaddress; # all mail sent will appear to be coming from here.
            my $mailtitle = ($choice) ? 'Issue status' : 'Overdue'; # the title of the mails
            my $librarymail = $emailaddress; # all notices w/o mail are sent (in 1 mail) to this address. They must then be managed manually.
            my $letter = $data->{"letter$i"} if $data->{"letter$i"};
			unless ($letter) {
				warn "No letter$i code for branch '$branchcode'";
				next;
			}
			$letter_sth->execute($letter);
            my ($mailtext)=$letter_sth->fetchrow;
			unless ($mailtext) {
				warn "Message '$letter' content not found";
				next;
			}
            # $mailtext is the text of the mail that is sent.
            # this text contains fields that are replaced by their value. Those fields must be written between brackets
            # The following fields are available :
            # <date> <itemcount> <firstname> <lastname> <address1> <address2> <address3> <city> <postcode>
			#
            # END OF PARAMETERS
            
            my $strsth = "
	SELECT COUNT(*), issues.borrowernumber,firstname,surname,address,address2,city,zipcode, email, MIN(date_due) as longest_issue
	FROM   issues,borrowers,categories
	WHERE  issues.borrowernumber=borrowers.borrowernumber
	AND    borrowers.categorycode=categories.categorycode ";
            $strsth .= "\n\tAND    issues.branchcode='$branchcode' " if ($branchcode);
            $strsth .= "\n\tAND    borrowers.categorycode='".$data->{categorycode}."' " if ($data->{categorycode});
            $strsth .= "\n\tAND    categories.overduenoticerequired=1
	GROUP BY issues.borrowernumber HAVING TO_DAYS(NOW())-TO_DAYS(longest_issue) BETWEEN ? and ? ";
            my $sth = $dbh->prepare($strsth);
            $sth->execute($mindays, $maxdays);
            $debug and warn $strsth . "\n\n ($mindays, $maxdays)\nreturns " .  $sth->rows . " rows";
            my $count = 0;		# to keep track of how many notices are printed
            my $e_count = 0;	# and e-mailed
            my $date = C4::Dates->new()->output;
            my ($itemcount,$borrowernumber,$firstname,$lastname,$address1,$address2,$city,$postcode,$email);
            while (($itemcount, $borrowernumber, $firstname, $lastname, $address1, $address2, $city, $postcode, $email) = $sth->fetchrow) {
                if ($data->{"debarred$i"}){
                    #action taken is debarring
                    $rqdebarring->execute($borrowernumber);
                    print STDERR "debarring $borrowernumber $firstname $lastname\n";
                }
				# for whatever reason, some of the template text is "double nested" with tags like:
				#   <<branches.branchname>><<borrowers.firstname>>
				# So we use the + operators below.
                if ($letter){
                    my $notice .= $mailtext;
					$notice =~ s/[<]+itemcount[>]+/$itemcount/g               if ($itemcount);
					$notice =~ s/[<]+(borrowers\.)?firstname[>]+/$firstname/g if ($firstname);
					$notice =~ s/[<]+(borrowers\.)?surname[>]+/$lastname/g    if ($lastname);
					$notice =~ s/[<]+lastname[>]+/$lastname/g                 if ($lastname);
					$notice =~ s/[<]+address1[>]+/$address1/g                 if ($address1);
					$notice =~ s/[<]+address2[>]+/$address2/g                 if ($address2);
					$notice =~ s/[<]+city[>]+/$city/g                         if ($city);
					$notice =~ s/[<]+postcode[>]+/$postcode/g                 if ($postcode);
					$notice =~ s/[<]+date[>]+/$date/g                         if ($date);
					$notice =~ s/[<]+bib[>]+/$branchname/g                    if ($branchname);
					$notice =~ s/[<]+(branches\.)branchname[>]+/$mybranch/g   if ($mybranch);
					$notice =~ s/[<]+(branches\.)branchname[>]+/$branchname/g if ($branchname);
    
                    $sth2->execute($borrowernumber, $mindays, $maxdays);
                    my $titles="";
                    while (my ($title, $author, $barcode,$issuedate) = $sth2->fetchrow){
                        $titles .= join "\t", format_date($issuedate), ($barcode?$barcode:""), ($title?$title:""), ($author?$author:"") . "\n";
                    }
                    $notice =~ s/\<titles\>/$titles/g;
					my @misses = grep {/./} map {/^([^>]*)[>]+/; ($1 || '');} split /\</, $notice;
					(@misses) and warn "The following terms were not matched/replaced: \n\t" . join "\n\t", @misses;
                    $notice =~ s/\<[^<>]*?\>//g;	# Now that we've warned about them, remove them.
                    $notice =~ s/\<[^<>]*?\>//g;	# 2nd pass for the double nesting.
                    $sth2->finish;
                    if ($email) {   # or you might check for borrowers.preferredcont 
                        if ($nomail) {
                            print "   TO   => $email\n";
                            print "  FROM  => $emailaddress\n";
                            print "SUBJECT => $mailtitle\n";
                            print "MESSAGE => $notice\n";
                        } else {
                            my %mail = ( To     => $email,
                                        From    => $emailaddress,
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
                    }
                }
            }
            $sth->finish;
            # if some notices have to be printed & managed by the library, send them to library mail address.
            if ($count) {
                open (ODUES, $outfile) or die "Cannot read file $outfile: $!";
                my $notice = "$e_count overdue notices e-mailed\n"
                			. "$count overdue notices in file for printing\n\n"
                			. <ODUES>;
                if ($nomail) {
                    print "   TO   => $email\n" if $email;
                    print "  FROM  => $emailaddress\n";
                    print "SUBJECT => Koha overdue\n";
                    print "MESSAGE => $notice\n";
                } else {
                    my %mail = (To      => $emailaddress,
                                From    => $emailaddress,
                                Subject => 'Koha overdues',
                                Message => $notice,
                                'Content-Type' => 'text/plain; charset="utf8"',
                            );
                    sendmail(%mail);
                }
            }
        }
    }
	close OUTFILE;
}
