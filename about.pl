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

my $dbh = C4::Context->dbh;
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
my $perlVersion = $];

# mysql(1) may not be on the PATH, so we try to do a select statement instead
my $sti = $dbh->prepare("select version()");
$sti->execute;
my $mysqlVersion = ($sti->fetchrow_array)[0]; # `mysql -V`

# The web server may not be httpd, and/or may not be in the PATH
my $apacheVersion =  $ENV{SERVER_SOFTWARE} || `httpd -v`;

$template->param(
					kohaVersion => $kohaVersion,
					osVersion          => $osVersion,
					perlVersion        => $perlVersion,
					mysqlVersion       => $mysqlVersion,
					apacheVersion      => $apacheVersion,
		);

output_html_with_http_headers $query, $cookie, $template->output;
