#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Database;
use C4::Context;
use HTML::Template;

my $query = new CGI;
my ($loggedinuser, $cookie, $sessionID) = checkauth($query);
my $template = gettemplate("catalogue/catalogue-home.tmpl");

my $classlist='';
my $dbh=C4::Context->dbh();
my $sth=$dbh->prepare("select groupname,itemtypes from itemtypesearchgroups order by groupname");
$sth->execute;
while (my ($groupname,$itemtypes) = $sth->fetchrow) {
    $classlist.="<option value=\"$itemtypes\">$groupname\n";
}

$template->param(loggedinuser => $loggedinuser,
						classlist => $classlist,
						opac => 0);

print $query->header(-cookie => $cookie), $template->output;
