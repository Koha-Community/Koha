#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Context;
use HTML::Template;

my $query = new CGI;
my $flagsrequired;
$flagsrequired->{borrowers}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($query, 0, $flagsrequired);

my $template = gettemplate("members/members-home.tmpl");
$template->param(loggedinuser => $loggedinuser);

print $query->header(-cookie => $cookie),$template->output;
