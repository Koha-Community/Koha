#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Date;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use C4::Koha;
use C4::Letters;
use C4::Bull;
# use C4::Search;
use HTML::Template;

my $query = new CGI;
my $op = $query->param('op');
my $dbh = C4::Context->dbh;

my $sth;
my ($template, $loggedinuser, $cookie);
my $externalid = $query->param('externalid');
my $alerttype = $query->param('alerttype');
my $biblionumber = $query->param('biblionumber');

($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "opac-alert-subscribe.tmpl",
				query => $query,
				type => "opac",
				authnotrequired => 1,
				debug => 1,
				});

if ($op eq 'alert_confirmed') {
	addalert($loggedinuser,$alerttype,$externalid);
	if ($alerttype eq 'issue') {
		print $query->redirect("opac-serial-issues.pl?biblionumber=$biblionumber");
		exit;
	}
} elsif ($op eq 'cancel_confirmed') {
	my $alerts =getalert($loggedinuser,$alerttype,$externalid);
	foreach (@$alerts) { # we are supposed to have only 1 result, but just in case...
		delalert($_->{alertid});
	}
	if ($alerttype eq 'issue') {
		print $query->redirect("opac-serial-issues.pl?biblionumber=$biblionumber");
		exit;
	}

} else {
	if ($alerttype eq 'issue') { # alert for subscription issues
		my $subscription = &getsubscription($externalid);
		$template->param("typeissue$op" => 1,
						bibliotitle => $subscription->{bibliotitle},
						notes => $subscription->{notes},
						externalid => $externalid,
						biblionumber => $biblionumber,
						);
	} else {
	}
	
}
output_html_with_http_headers $query, $cookie, $template->output;
