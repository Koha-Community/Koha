#!/usr/bin/perl
use strict;
require Exporter;

use C4::Output;  # contains picktemplate
use CGI;
use C4::Auth;

my $query = new CGI;
#my ($loggedinuser, $cookie, $sessionID) = checkauth($query);

my $template = gettemplate("opac-search.tmpl", "opac");

#$template->param(SITE_RESULTS => $sitearray);
print "Content-Type: text/html\n\n", $template->output;
