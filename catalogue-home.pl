#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Database;
use HTML::Template;

my $query = new CGI;
my ($loggedinuser, $cookie, $sessionID) = checkauth($query);
my $template = gettemplate("catalogue/catalogue-home.tmpl");

my $classlist='';
#open C, "$intranetdir/htdocs/includes/cat-class-list.inc";
#while (<C>) {
#   $classlist.=$_;
#}
$template->param(loggedinuser => $loggedinuser,
						classlist => $classlist,
						opac => 0);

print $query->header(-cookie => $cookie), $template->output;
