#!/usr/bin/perl

#  This script loops through each overdue item, determines the fine,
#  and updates the total amount of fines due by each user.  It relies on
#  the existence of /tmp/fines, which is created by ???
# Doesnt really rely on it, it relys on being able to write to /tmp/
# It creates the fines file
#
#  This script is meant to be run nightly out of cron.

# Copyright 2000-2002 Katipo Communications
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

# $Id: sendoverdues.pl,v 1.1.2.1 2007/03/26 22:38:09 tgarip1957 Exp $

BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use C4::Context;
use C4::Search;
use C4::Circulation;
use C4::Circulation::Fines;
use C4::Members;
use C4::Dates qw/format_date/;
use HTML::Template::Pro;
use Mail::Sendmail;
use Mail::RFC822::Address;
use C4::SMS;
use utf8;
my ($res,$ua);##variables for SMS

my $date=get_today();
       		my $dbh = C4::Context->dbh;
 


notifyOverdues();

sub	notifyOverdues {
	# Look up the overdues for today. 
	# Capture overdues which fall on our dates of interest.

####################################################################################################
# Creating a big hash of available templates
my %email;
%email->{'template'}='email-2.txt';
my %sms; 
%sms->{'template'}='sms-2.txt';


my %firstReminder->{'email'} = \%email;
%firstReminder->{'sms'} = \%sms;

my %email2;
%email2->{'template'}='email-7.txt';
my %secondReminder->{'email'} = \%email2;
my %sms2;  
%sms2->{'template'}='sms-7.txt';
%secondReminder->{'sms'} = \%sms2;
my %letter2;
%letter2->{'template'}='letter-7.html';
%secondReminder->{'letter'} = \%letter2;    


my %email3;
%email3->{'template'}='email-29.txt';
my %sms3;
%sms3->{'template'}='sms-29.txt';
my %letter3;
%letter3->{'template'}='letter-29.html';

my %finalReminder->{'email'} = \%email3;
%finalReminder->{'letter'} = \%letter3;
%finalReminder->{'sms'} = \%sms3;

my %actions;
%actions->{'1'}=\%firstReminder;
%actions->{'3'}=\%secondReminder;###This was 7 days changed to 3 days
%actions->{'20'}=\%finalReminder;###This was 29 days changed to 20 days

##################################################################################################################
my @overdues2;#an array for each actiondate
my @overdues7;
my @overdues29;
my $filename;
       
   

        # Retrieve an array of overdues.
        my ($count, $overduesReference) = Getoverdues();
        my @overdues=@$overduesReference;


	# We're going to build a hash of arrays, containing the items requiring action.
	# ->borrowernumber, date, @overdues
	my %actionItems;
	

        foreach my $overdue (@overdues) {
                 my $due_day=$overdue->{'date_due'};

               	my $difference=DATE_subtract($date,$due_day);
		# If does this item fall on a day of interest?
	        		$overdue->{'difference'}=$difference;
		foreach my $actiondate (keys(%actions)) {
			if ($actiondate == $difference) {
			$filename='overdues'.$actiondate;
				push @$$filename,$overdue;		
#print "$actiondate,-,$overdue->{borrowernumber}\n";		
			}
			$actionItems{$actiondate} = \@$$filename;
		}
	}

	# We now have a hash containing overdues which need actioning,  we can step through each set. 
	# Work from earilest to latest. We only wish to send the most urgent message.
	my %messages; 
        my %borritem;

    foreach my $actiondate (keys %actions) {
#		print "\n\nThe following items are $actiondate days overdue.\n";
		my $items = $actionItems{$actiondate};
		$filename='overdues'.$actiondate;
	foreach my $overdue (@$$filename) {
				# Detemine which borrower is responsible for this overdue;
				# if the offender is a child, then the guarantor is the person to notify
				my $borrowernumber=$overdue->{borrowernumber};

				my $borrower=responsibleBorrower($borrowernumber);
				my ($method, $address) = preferedContactMethod($borrower);
                  if ($method && $address) {	
				
					# Do we have to send something, using this method on this day?
		    if (%actions->{$actiondate}->{$method}->{'template'}) {
						my $intranetdir=C4::Context->config('intranetdir');
						# Template the message
						my $template = HTML::Template::Pro->new(filename => $intranetdir.'/scripts/misc/notifys/templates/'.%actions->{$actiondate}->{$method}->{'template'}, die_on_bad_params => 0);
						my @bookdetails;
	  	                                        	my %row_data;
 					 my $item = getiteminformation("", $overdue->{'itemnumber'});
        		                                $row_data{'BARCODE'}=$item->{'barcode'};
				
        	        	                       my $title=substr($item->{'title'},0,25)."...";

				$title=changecharacter($title);
				  $row_data{'TITLE'}=$title;
        	                	                $row_data{'DATE_DUE'}=format_date($overdue->{'date_due'});
				$row_data{'cardnumber'}=$borrower->{'cardnumber'};
		                   	push(@bookdetails, \%row_data);
                	                        $template->param(BOOKDETAILS => \@bookdetails);		   						
			        my $name= "$borrower->{'firstname'} $borrower->{'surname'}"; 
			        $template->param(NAME=> $name);
		      %messages->{$borrower->{'borrowernumber'}} = $template->output();
			if ($method eq 'email') {
			$result = sendEmail($address, 'library@library.neu.edu.tr', 'Overdue Library Items', %messages->{$borrowernumber});
			logContact($borrowernumber, $method, $address, $result, %messages->{$borrowernumber});
			}
			elsif ($method eq 'sms') {
			$result = sendSMS($address, %messages->{$borrowernumber});
			logContact($borrowernumber, $method, $address, $result, %messages->{$borrowernumber});
			}
			elsif ($method eq 'letter') {
			$result = printLetter($address, %messages->{$borrowernumber});
			}							
		       }##template exists
		}else{
		print "$borrowernumber has an overdue item, but no means of contact\n";
		}##$method		


	} #end of 'foreach overdue'

     } # end of foreach actiondate
}

sub	responsibleBorrower {	
	# Given an overdue item, return the details of the borrower responible as a hash of database columns.
	my $borrowernumber=shift;

	if ($borrowernumber) {
		my $borrower=BorType($borrowernumber);
		# Overdue books assigned to children have notices sent to the guarantor.	
	   	if ($borrower->{'categorycode'} eq 'C') {
  			my $guarantor=BorType($borrower->{'guarantor'});
			$borrower = $guarantor;
			}
	
		return $borrower;
	}

}









sub	preferedContactMethod {
	# Given a reference to borrower details, in the format
	# returned by BorType(), determine the prefered contact method, and address to use.
	my $borrower=$_[0];
	my $borrcat = getborrowercategoryinfo($borrower->{'categorycode'});
if(  !$borrcat->{'overduenoticerequired'}){
return (undef,undef);
}
	my $method='';	
	my $address='';	
## if borrower has a phone set that as our preferrred contact
	if ($borrower->{'phoneday'}) {
		if (parse_phone($borrower->{phoneday})){
				$address = parse_phone($borrower->{phoneday});
				$method="sms";
				return ($method, $address);
		}
	}
	
	if (($borrower->{'emailaddress'}) and (Mail::RFC822::Address::valid($borrower->{'emailaddress'}))) {
				$address = $borrower->{'emailaddress'};
		$method="email";
				return ($method, $address);
	}
			
	if ($borrower->{'streetaddress'}) {
				$address =  mailingAddress($borrower);
			$method = 'letter';	
	}
#print "$method, $address\n";
	return ($method, $address);
}








sub	logContact {
	# Given the details of an attempt to contact a borrower, 
	# log them in the attempted_contacts table of the koha database.
	my ($borrowernumber, $method, $address, $result, $message) = @_;

 	my $querystring = "	insert into	attempted_contacts 
						(borrowernumber, method, address, result, message, date) 
						values (?, ?, ?, ?, ?, now())";
	my $sth= $dbh->prepare($querystring);
	$sth->execute($borrowernumber, $method, $address, $result, $message);
	$sth->finish();
}








sub	mailingAddress {
	# Given a hash of borrower information, such as that returned by BorType, 
	# return a mailing address. 
	my $borrower=$_[0];

	my $address = 	$borrower->{'firstname'}."\n". 
			$borrower->{'streetaddress'}."\n".
			$borrower->{'streetcity'};

	return $address;
}



sub	sendEmail {
	# Given an email address, and a subject and message, attempt to send email.

	my $to=$_[0];
	my $from=$_[1];
	my $subject=$_[2];
	my $message=$_[3];
#    print "in email area";

#	print "\nSending Email To: $to\n$message\n";

	my      %mail = (       	To      => $to,
                                        CC => 'library@library.neu.edu.tr', 
					From    => $from,
                                        Subject => $subject,
                                        Message => $message);

                
	if (not(sendmail %mail)) {       
warn  $Mail::Sendmail::error;
		warn "sendEmail to $to failed.";
		return 0;	
	}
	
	return 1;
}


sub	sendSMS {
my ($phone, $message)=@_;
($res,$ua)=get_sms_auth() unless $res;
	# Given a cell number and a message, attempt to send an SMS message.
my  $sendresult=send_sms($ua,$phone,$message,$res->{pSessionId});
	my $error=error_codes($sendresult->{pErrCode});
	return 1 unless $error;
	return $error;
}


sub 	printLetter {
print "letter\n";
	# Print a letter
	# FIXME - decide where to print
	return 1;
}
sub changecharacter {
my ($string)=@_;
$_=$string;

s/ş/s/g;
s/Ş/S/g;
s/ü/u/g;
s/Ü/U/g;
s/ç/c/g;
s/Ç/C/g;
s/ö/o/g;
s/Ö/O/g;
s/ı/i/g;
s/İ/I/g;
s/ğ/g/g;
s/Ğ/G/g;
$string=$_;
return $string;
}
$dbh->disconnect();
			
