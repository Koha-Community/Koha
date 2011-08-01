#!/usr/bin/perl
use strict;
#use warnings; FIXME - Bug 2505
require Exporter;

use CGI;

use C4::Output;
use C4::Auth;
use C4::Context;
use C4::RotatingCollections;

my $query = new CGI;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "rotating_collections/rotatingCollections.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });

my $branchcode = $query->cookie('branch');

my $collections = GetCollections();

$template->param(
                intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
                intranetstylesheet => C4::Context->preference("intranetstylesheet"),
                IntranetNav => C4::Context->preference("IntranetNav"),
                                  
                collectionsLoop => $collections,
                );
                                                                                                
output_html_with_http_headers $query, $cookie, $template->output;
