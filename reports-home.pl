#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Context;
use HTML::Template;

my $query = new CGI;
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "reports/reports-home.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {permissions => 1},
				debug => 1,
				});
print $query->header(-cookie => $cookie),$template->output;
