#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;

my $query = new CGI;
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "errors/402.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});
output_html_with_http_headers $query, $cookie, $template->output;
