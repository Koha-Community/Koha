#!/usr/bin/perl

use strict;
use CGI;
use C4::SMS;
use C4::Output;
use C4::Auth;

my $query = new CGI;
my $message   = $query->param( 'message' );
my $phone     = $query->param(  'phone'  );
my $operation = $query->param('operation');
my $result;
my $errorcode;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "sms/sms-home.tmpl",
		query => $query,
		type => "intranet",
		authnotrequired => 0,
		flagsrequired => {circulate => "circulate_remaining_permissions" },
		debug => 1,
	});
if ($operation eq "sendsms"){
	$phone=parse_phone($phone);
	if ($phone){
		##write to a queue and exit
		my $me=C4::Context->userenv;
		$result=write_sms($me->{cardnumber},$message,$phone);
	} else {
		$errorcode=-1104;
	}
}
my $error=error_codes($errorcode);
$template->param(error=>$error);
output_html_with_http_headers $query, $cookie, $template->output;

