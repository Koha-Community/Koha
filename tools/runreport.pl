#!/usr/bin/perl

# fix this line
use C4::Reports::Guided;
use C4::Context;

use Mail::Sendmail;


my ($report,$format,$email) = @ARGV;

my ($sql,$type) = get_saved_report($report);
my $results = execute_query($sql,$type,$format,$report); 
my $message;
if ($format eq 'text'){
	$message="<table>$results</table>";	
}
if ($format eq 'url'){
	$message="$results";
}

if ($email){
	my $to      = $email;
	# should be koha admin email
    my $from    = C4::Context->preference('KohaAdminEmailAddress');
    my $subject = 'Automated job run';
    my %mail    = (
		        To      => $to,
		        From    => $from,
		        Subject => $subject,
		        Message => $message 
		    );
 
                                                                                                                                                           
       if (not(sendmail %mail)) { 
		   warn "mail not sent";
		   }
	}
