#!/usr/bin/perl

# use lib ('/usr/local/koha/intranet/modules');


use C4::Database;
use C4::Search;
use C4::Circulation::Circ2;
use C4::Circulation::Fines;
use Date::Manip;
use Data::Dumper;
use HTML::Template;
use Mail::Sendmail;
use Mail::RFC822::Address;
use strict;


#levyFines();	# Do not levy real fines in testing situation.
notifyOverdues();



# Todo
# 	- Need to calculate the fine on each book; no idea how to get this information from Koha
#	- Need to diffentricate between the total_fines including replacement costs, 
#	and the total fines if the books are returned in the day 29 notices (see above).
#	- clean up the %actions hash creation code.

#Done
# 	- preferedcont field in borrowers hash; does this do anything?
#	- logging 
#	- which 'address' to send sms to?
#	- senders returning success or fail



sub levyFines {
	# Look at the current overdues, and levy fines on the offenders. 
	# arguments:
	#	$date
	# 	$maxfine
	
	# Work out what today is as an integer value.
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime(time);
	$mon++; $year=$year+1900;
	my $date=Date_DaysSince1BC($mon,$mday,$year);
	my $maxfine =5;


	# Retrieve an array of overdues.
	my ($count, $overduesReference) = Getoverdues();
	print "$count overdue items where found.\n\n";
	my @overdues=@$overduesReference;

	foreach my $overdue (@overdues) {
	  	my @dates=split('-',$overdue->{'date_due'});
  		my $due_day=Date_DaysSince1BC($dates[1],$dates[2],$dates[0]);    


		# Check that the item is really overdue. The output of Getoverdues() will normally 
		# always be overdue items. However, if you are running this script with a value of $date other than the current time, this check is needed.
		if ($due_day <= $date) {
 			my $difference=$date-$due_day;
			print "Itemnumber ".$overdue->{'itemnumber'}." is issued to ".$overdue->{'borrowernumber'}." is overdue by $difference days.\n";		

			# Calculate the cost of this overdue.
			# Fines vary according to borrower type, but cannot exceed the maximum fine. 
			print $overdue->{'borrowernumber'};
			my $borrower=BorType($overdue->{'borrowernumber'});

	    		my ($amount,$type,$printout)=CalcFine($overdue->{'itemnumber'}, $borrower->{'categorycode'}, $difference);      
			if ($amount > $maxfine){
      				$amount=$maxfine;
    				}

			if ($amount > 0){
				my $due="$dates[2]/$dates[1]/$dates[0]";
      				UpdateFine($overdue->{'itemnumber'}, $overdue->{'borrowernumber'}, $amount, $type, $due);
				print $overdue->{'borrowernumber'}." has been fined $amount for itemnumber ".$overdue->{'itemnumber'}." overdue for $difference days.\n";		
				}

			

			# After 28 days, the item is marked lost and the replacement charge is added as a fine
			if ($difference >= 28) { 
      				my $borrower=BorType($overdue->{'borrowernumber'});
      				if ($borrower->{'cardnumber'} ne ''){
       					my $cost=ReplacementCost($overdue->{'itemnumber'});  
				        my $dbh=C4Connect();
				        my $env;

		        		my $accountno=C4::Circulation::Circ2::getnextacctno($env,$overdue->{'borrowernumber'},$dbh);
       					my $item=itemnodata($env,$dbh,$overdue->{'itemnumber'});
        				if ($item->{'itemlost'} ne '1' && $item->{'itemlost'} ne '2' ){
          					$item->{'title'}=~ s/\'/\\'/g;
					      	my $query="Insert into accountlines (borrowernumber,itemnumber,accountno,date,amount, description,accounttype,amountoutstanding) 
								values ($overdue->{'borrowernumber'}, $overdue->{'itemnumber'},
								        '$accountno',now(),'$cost','Lost item $item->{'title'} $item->{'barcode'}','L','$cost')";

					       	my $sth=$dbh->prepare($query);
					       	$sth->execute();
					      	$sth->finish();
        	  
						$query="update items set itemlost=2 where itemnumber='$overdue->{'itemnumber'}'";
	          				$sth=$dbh->prepare($query);
			          		$sth->execute();
				      		$sth->finish();
				        	}
					} 
				}
       			}
		}

	return 1;
	}






sub	notifyOverdues {
	# Look up the overdues for today. 
	# Capture overdues which fall on our dates of interest.




####################################################################################################
# Creating a big hash of available templates
my %email;
%email->{'template'}='email-8.txt';
my %sms; 
%sms->{'template'}='sms-8.txt';

my %fax1;
%fax1->{'template'}='fax-8.html';

my %firstReminder->{'email'} = \%email;
%firstReminder->{'sms'} = \%sms;
%firstReminder->{'fax'} = \%fax1;
	
my %email2;
%email2->{'template'}='email-15.txt';

my %fax2;
%fax2->{'template'}='fax-15.html';
    
my %letter2;
%letter2->{'template'}='fax-15.html';
    
my %sms2->{'template'}='sms-15.txt';
my %secondReminder->{'email'} = \%email2;
%secondReminder->{'sms'} = \%sms2;
%secondReminder->{'fax'} = \%fax2;
%secondReminder->{'letter'} = \%letter2;    


my %email3;
%email3->{'template'}='email-29.txt';
my %fax3;
%fax3->{'template'}='fax-29.html';
my %letter3;
%letter3->{'template'}='letter-29.html';

my %finalReminder->{'email'} = \%email3;
%finalReminder->{'fax'} = \%fax3;
%finalReminder->{'letter'} = \%letter3;

my $fines;
my %actions;
%actions->{'8'}=\%firstReminder;
%actions->{'15'}=\%secondReminder;
%actions->{'29'}=\%finalReminder;

##################################################################################################################


        # Work out what today is as an integer value.
        my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime(time);
        $mon++; $year=$year+1900;
        my $date=Date_DaysSince1BC($mon,$mday,$year);


        # Retrieve an array of overdues.
        my ($count, $overduesReference) = Getoverdues();
        print "$count overdue items where found.\n\n";
        my @overdues=@$overduesReference;


	# We're going to build a hash of arrays, containing the items requiring action.
	# ->borrowernumber, date, @overdues
	my %actionItems;
	foreach my $actionday (keys(%actions)) {
		my @items=();
		%actionItems->{$actionday} = \@items;
		}
	


        foreach my $overdue (@overdues) {
                my @dates=split('-',$overdue->{'date_due'});
                my $due_day=Date_DaysSince1BC($dates[1],$dates[2],$dates[0]);

               	my $difference=$date-$due_day;
#    		$overdue->{'fine'}=GetFine($overdue->{'itemnumber'});
		# If does this item fall on a day of interest?
	        			        $overdue->{'difference'}=$difference;
		foreach my $actiondate (keys(%actions)) {
			if ($actiondate == $difference) {
				my @items = @{%actionItems->{$actiondate}};

				my %o = %$overdue;
				push (@items, \%o); 
				%actionItems->{$actiondate} = \@items;
				}
			}
		}




	# We now have a hash containing overdues which need actioning,  we can step through each set. 
	# Work from earilest to latest. We only wish to send the most urgent message.
	my %messages; 
        my %borritem;

	foreach my $actiondate (sort {$a <=> $b} (keys(%actions))) {
		print "\n\nThe following items are $actiondate days overdue.\n";
		my @items = @{%actionItems->{$actiondate}};
	
			
		foreach my $overdue (@items) {		
			if ($overdue->{'difference'} eq $actiondate) {	
				# Detemine which borrower is responsible for this overdue;
				# if the offender is a child, then the garentor is the person to notify
				my $borrower=responsibleBorrower($overdue);


				my ($method, $address) = preferedContactMethod($borrower);
				if ($method) {	
				
					# Do we have to send something, using this method on this day?
					if (%actions->{$actiondate}->{$method}->{'template'}) {
						# If this user has one overdue, then they may have offers as well.
						# No point in sending a notice without mentioning all of the items.
						my @alloverdues; 
						foreach my $over (@overdues) {
							my $responisble= responsibleBorrower($over);
							if ($responisble->{'borrowernumber'} eq $borrower->{'borrowernumber'}) {
							        $over->{'borrowernumber'}=$responisble->{'borrowernumber'};
 								my %o = %$over;
								push (@alloverdues, \%o);
								}
							}
			
						my $dbh=C4Connect();	# FIXME disconnect this

						# Template the message
						my $template = HTML::Template->new(filename => 'templates/'.%actions->{$actiondate}->{$method}->{'template'}, die_on_bad_params => 0);

						my @bookdetails;
						my $total_fines = 0;
	                                	foreach my $over (@alloverdues) {
	                                        	my %row_data;
							my $env;	#FIXME what is this varible for?
						      
 							if ( my $item = itemnodata($env, $dbh, $over->{'itemnumber'})){
							    print "getting fine ($over->{'itemnumber'} $overdue->{'borrowernumber'} $over->{'borrowernumber'}\n";
						        my $fine = GetFine($over->{'itemnumber'},$overdue->{'borrowernumber'}); 
							    
							    
							    print "fine=$fine  ";

						          my $rep = ReplacementCost2($over->{'itemnumber'},$overdue->{'borrowernumber'});

						        if ($rep){
							     $rep+=0.00;
							    }
						        if ($fine){
							    $fine+=0.00;
							     $borritem{"$over->{'itemnumber'} $over->{'borrowernumber'}"}=$fine;
							    } else {
								$borritem{"$over->{'itemnumber'} $over->{'borrowernumber'}"}+=$fine;
								}
  							    print $borritem{"$over->{'itemnumber'} $over->{'borrowernumber'}"},"\n";
						        $total_fines +=  $borritem{"$over->{'itemnumber'} $over->{'borrowernumber'}"};
							$item->{'title'}=substr($item->{'title'},0,25);
							my $len=length($item->{'title'});
							if ($len < 25){
							    my $diff=25-$len;
							    $item->{'title'}.=" " x $diff;
							    }

        		                                $row_data{'BARCODE'}=$item->{'barcode'};
        	        	                        $row_data{'TITLE'}=$item->{'title'};
        	                	                $row_data{'DATE_DUE'}=$over->{'date_due'};
						        $row_data{'FINE'}=$borritem{"$over->{'itemnumber'} $over->{'borrowernumber'}"};
						    $row_data{'REP'}=$rep;

	                                        	push(@bookdetails, \%row_data);
							    } else {
								print "Missing item  $over->{'itemnumber'}\n";
								}
        	                                	}

                	                        $template->param(BOOKDETAILS => \@bookdetails);		
   						
						my $env;
				                my %params;
				                %params->{'borrowernumber'} = $overdue->{'borrowernumber'};
				                my ($count, $acctlines, $total) = &getboracctrecord($env, \%params);
                        	                $template->param(FINES_TOTAL => $total_fines);
					        $template->param(OWING => $total);
					        my $name= "$borrower->{'firstname'} $borrower->{'surname'}"; 
					        $template->param(NAME=> $name);
	
						%messages->{$borrower->{'borrowernumber'}} = $template->output();
						}
					else	{
						print "No $method needs to be sent at $overdue->{'difference'} days; not sending\n";
						}
	
					}
				else	{
					print "This borrower has an overdue item, but no means of contact\n";
					}		

				} #end of 'if this overdue falls on an action date'

			} #end of 'foreach overdue'

		} # end of foreach actiondate


	# How that all of the messsages to be sent have been composed, send them.
	foreach my $borrowernumber (keys(%messages)) {
		print "$borrowernumber\n";

	   	my $borrower=BorType($borrowernumber);
		my ($method, $address) = preferedContactMethod($borrower);

		my $result=0;
		if ($method eq 'email') {
			$result = sendEmail($address, 'lep@library.org.nz', 'Overdue Library Items', %messages->{$borrowernumber});
			}
		elsif ($method eq 'sms') {
			$result = sendSMS($address, %messages->{$borrowernumber});
			}
		elsif ($method eq 'fax') {
			$result = sendFax($address, %messages->{$borrowernumber});
			}
		elsif ($method eq 'letter') {
			$result = printLetter($address, %messages->{$borrowernumber});
			}	


		#print %messages->{$borrowernumber};	# debug


		# Log the outcome of this attempt
		logContact($borrowernumber, $method, $address, $result, %messages->{$borrowernumber});
		}



	return 1;
	}










sub	responsibleBorrower {	
	# Given an overdue item, return the details of the borrower responible as a hash of database columns.
	my $overdue=$_[0];

	if ($overdue->{'borrowernumber'}) {
		my $borrower=BorType($overdue->{'borrowernumber'});


		# Overdue books assigned to children have notices sent to the guarantor.	
	   	if ($borrower->{'categorycode'} eq 'C') {
        		my $dbh=C4Connect();
        		my $query="Select 	borrowernumber from borrowers 
						where borrowernumber=?";

        		my $sth=$dbh->prepare($query);
        		$sth->execute($borrower->{'guarantor'});

        		my $tdata=$sth->fetchrow_hashref();
        	 	$sth->finish();
        	 	$dbh->disconnect();
			
			my $guarantor=BorType($tdata->{'borrowernumber'});
			$borrower = $guarantor;
			}
	
		return $borrower;
		}

	}









sub	preferedContactMethod {
	# Given a reference to borrower details, in the format
	# returned by BorType(), determine the prefered contact method, and address to use.
	my $borrower=$_[0];
#        	    print "finding borrower method $borrower->{'preferredcont'} $borrower->{'emailaddress'} $borrower->{'streetaddress'}\n";

	# Possible contact methods, in order of preference are:
	my @methods = ('email', 'sms', 'fax', 'letter');

	my $method='';	
	my $address='';	


	# Does this borrower have a borrower.preferredcont set?
	# If so, push it to the head of our array of methods to try.
	# If it's a method unheard of by this system, then we'll drop though to the prefined methods above.
	# Note use of unshift to push onto the front of the array.
	if ($borrower->{'preferredcont'}) {
		unshift(@methods, $borrower->{'preferredcont'});
		}


	# Cycle through the possible methods until one is accepted
	while ((@methods) and (!$address)) {
		$method=shift(@methods);


		if ($method eq 'email') {
			if (($borrower->{'emailaddress'}) and (Mail::RFC822::Address::valid($borrower->{'emailaddress'}))) {
				$address = $borrower->{'emailaddress'};
				}
			}	
		elsif ($method eq 'fax') {
			if ($borrower->{'faxnumber'}) {
				$address = $borrower->{'faxnumber'};
				}
			}
		elsif ($method eq 'sms') {
			if ($borrower->{'textmessaging'}) {
				$address = $borrower->{'textmessaging'};
				}
			}
		elsif ($method eq 'letter') {
			if ($borrower->{'streetaddress'}) {
				$address =  mailingAddress($borrower);
				}
			}
		}
print "$method, $address\n";
	return ($method, $address);
	}








sub	logContact {
	# Given the details of an attempt to contact a borrower, 
	# log them in the attempted_contacts table of the koha database.
	my ($borrowernumber, $method, $address, $result, $message) = @_;

 	my $dbh=C4Connect();	# FIXME - disconnect me
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







sub itemFine {
	# Given an overdue item, return the current fines on it
	my $overdue=$_[0];
	# FIXME
	return 1;
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
#                                        CC => 'rosalie@library.org.nz', 
					From    => $from,
                                        Subject => $subject,
                                        Message => $message);

                
	if (not(sendmail %mail)) {       
		warn "sendEmail to $to failed.";
		return 0;	
		}
	
	return 1;
#    die "got to here";
	}


sub	sendSMS {
	# Given a cell number and a message, attempt to send an SMS message.
	# FIXME - needs information about how to do this at HLT
	return 1;
	}


sub 	sendFax {
    print "in fax \n";
	# Given a fax number, and a message, attempt to send a fax.
	# FIXME - needs information about how to do this at HLT
	# This is fairly easy. 
	# We will be past the body of the fax as HTML.
	# We can pass this through html2ps to generate Postscript suitable
	# for passing to the fax server. 
	return 1;
	}


sub 	printLetter {
	# Print a letter
	# FIXME - needs information about how to do this at HLT
	return 1;
	}
