#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Database;
use HTML::Template;

my $query = new CGI;
my ($loggedinuser, $cookie, $sessionID) = checkauth($query);

my $template = gettemplate("parameters/admin-home.tmpl");
$template->param(loggeninuser => $loggedinuser);

print $query->header(-cookie => $cookie),$template->output;
