#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;
use C4::Database;
use C4::Output;  # contains gettemplate
use CGI;
use C4::Auth;

my $query = new CGI;
my ($loggedinuser, $cookie, $sessionID) = checkauth($query);

my $template = gettemplate("intranet-main.tmpl");

print  $query->header(-cookie => $cookie), $template->output;
