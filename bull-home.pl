#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Bull;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;

my $query = new CGI;
my $title = $query->param('title');
my $ISSN = $query->param('ISSN');
my @subscriptions = getsubscriptions($title,$ISSN);
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "bull/bull-home.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});

$template->param(
	subscriptions => \@subscriptions,
	title => $title,
	ISSN => $ISSN,
	);
output_html_with_http_headers $query, $cookie, $template->output;
