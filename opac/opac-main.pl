#!/usr/bin/perl
use strict;
require Exporter;
use CGI;

use C4::Auth;       # get_template_and_user
use C4::Context;

my $query = new CGI;

my ($template, $borrowernumber, $cookie) 
    = get_template_and_user({template_name => "opac-main.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 1,
			     flagsrequired => {borrow => 1},
			 });

$template->param(kohaversion => C4::Context->config('kohaversion'));

print $query->header(-cookie => $cookie), $template->output;
