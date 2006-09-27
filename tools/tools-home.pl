#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;


my $query = new CGI;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "tools/tools-home.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {tools => 1},
			     debug => 1,
			     });

output_html_with_http_headers $query, $cookie, $template->output;
