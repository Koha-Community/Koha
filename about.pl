#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;
use C4::Database;
use C4::Output;  # contains gettemplate
use C4::Interface::CGI::Output;
use C4::Auth;
use C4::Context;
use CGI;

my $query = new CGI;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "about.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });

my $kohaVersion = C4::Context->config("kohaversion");
my $osVersion = `uname -a`;
my $perlVersion = `perl -v`;
my $mysqlVersion = `mysql -V`;
my $apacheVersion =  `httpd -V`;

$template->param(
					kohaVersion => $kohaVersion,
					osVersion          => $osVersion,
					perlVersion        => $perlVersion,
					mysqlVersion       => $mysqlVersion,
					apacheVersion      => $apacheVersion,
		);

output_html_with_http_headers $query, $cookie, $template->output;
