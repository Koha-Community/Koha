#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;
use C4::Database;
use C4::Output;  # contains gettemplate
use C4::Interface::CGI::Output;
use CGI;
use C4::Auth;

my $query = new CGI;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "intranet-main.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });

my $marc_p = C4::Context->boolean_preference("marc");
$template->param(NOTMARC => !$marc_p);

output_html_with_http_headers $query, $cookie, $template->output;
