#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Koha;
use C4::Date;
use C4::Bull;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;

my $query = new CGI;
my $op = $query->param('op');
my $dbh = C4::Context->dbh;
my $sth;
# my $id;
my ($template, $loggedinuser, $cookie);
my ($subscriptionid);

$subscriptionid = $query->param('subscriptionid');
my $subscription = &getsubscription($subscriptionid);

($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "bull/serial-issues.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});

# replace CR by <br> in librarian note
$subscription->{librariannote} =~ s/\n/\<br\/\>/g;

$template->param(
	startdate => format_date($subscription->{startdate}),
	periodicity => $subscription->{periodicity},
	dow => $subscription->{dow},
	numberlength => $subscription->{numberlength},
	weeklength => $subscription->{weeklength},
	monthlength => $subscription->{monthlength},
	librariannote => $subscription->{librariannote},
	numberingmethod => $subscription->{numberingmethod},
	arrivalplanified => $subscription->{arrivalplanified},
	status => $subscription->{status},
	biblionumber => $subscription->{biblionumber},
	bibliotitle => $subscription->{bibliotitle},
	notes => $subscription->{notes},
	subscriptionid => $subscription->{subscriptionid}
	);
$template->param(
			"periodicity$subscription->{periodicity}" => 1,
			"arrival$subscription->{dow}" => 1,
			);

output_html_with_http_headers $query, $cookie, $template->output;
