#!/usr/bin/perl
use strict;
require Exporter;

use C4::Output;
use CGI;
use C4::Auth;
use C4::Context;

my $classlist='';
my $dbh=C4::Context->dbh();
my $sth=$dbh->prepare("select groupname,itemtypes from itemtypesearchgroups order by groupname");
$sth->execute;
while (my ($groupname,$itemtypes) = $sth->fetchrow) {
    $classlist.="<option value=\"$itemtypes\">$groupname\n";
}


my $query = new CGI;

my $flagsrequired;
$flagsrequired->{borrow}=1;

my ($loggedinuser, $cookie, $sessionID) = checkauth($query ,1, $flagsrequired);

my $template = gettemplate("opac-search.tmpl", "opac");

$template->param(loggedinuser => $loggedinuser,
		classlist => $classlist);

print "Content-Type: text/html\n\n", $template->output;
