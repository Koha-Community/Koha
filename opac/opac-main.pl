#!/usr/bin/perl
use strict;
require Exporter;
use CGI;

use C4::Output;       # gettemplate
use C4::Auth;         # checkauth

my $query = new CGI;

my ($loggedinuser, $cookie, $sessionID) = checkauth($query, 1);

my $template = gettemplate("opac-main.tmpl", "opac");

$template->param(loggedinuser => $loggedinuser);

print "Content-Type: text/html\n\n", $template->output;
