#!/usr/bin/perl
use strict;
require Exporter;

use C4::Output;  
use CGI;
use C4::Auth;

my $query = new CGI;
my ($loggedinuser, $cookie, $sessionID) = checkauth($query ,1);

my $template = gettemplate("opac-search.tmpl", "opac");

print "Content-Type: text/html\n\n", $template->output;
