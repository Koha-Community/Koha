#!/usr/bin/perl
use strict;
require Exporter;

use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Context;
use CGI;
use C4::Database;
use HTML::Template;

my $classlist='';

my $dbh=C4::Context->dbh;
my $sth=$dbh->prepare("select description,itemtype from itemtypes order by description");
$sth->execute;
while (my ($description,$itemtype) = $sth->fetchrow) {
    $classlist.="<option value=\"$itemtype\">$description</option>\n";
}


my $query = new CGI;

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "opac-search.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 1,
			     flagsrequired => {borrow => 1},
			 });


$template->param(classlist => $classlist,
			     LibraryName => C4::Context->preference("LibraryName"),
);

output_html_with_http_headers $query, $cookie, $template->output;
