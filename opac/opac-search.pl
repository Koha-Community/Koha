#!/usr/bin/perl
use strict;
require Exporter;

use C4::Auth;
use C4::Charset;
use C4::Context;
use CGI;
use C4::Database;
use HTML::Template;

my $classlist='';

my $dbh=C4::Context->dbh;
my $sth=$dbh->prepare("select groupname,itemtypes from itemtypesearchgroups order by groupname");
$sth->execute;
while (my ($groupname,$itemtypes) = $sth->fetchrow) {
    $classlist.="<option value=\"$itemtypes\">$groupname\n";
}


my $query = new CGI;

my ($template, $borrowernumber, $cookie) 
    = get_template_and_user({template_name => "opac-search.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 1,
			     flagsrequired => {borrow => 1},
			 });


$template->param(classlist => $classlist);

print $query->header(
    -type => guesstype($template->output),
    -cookie => $cookie
), $template->output;
