#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Database;
use C4::Acquisition;
use C4::Biblio;
use HTML::Template;

my $query = new CGI;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "catalogue/catalogue-home.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1},
			     debug => 1,
			     });

my ($branchcount,@branches)=branches();
my ($itemtypecount,@itemtypes)=getitemtypes();

my $classlist='';
my $dbh=C4::Context->dbh;
my $sth=$dbh->prepare("select description,itemtype from itemtypes order by description");
$sth->execute;
while (my ($description,$itemtype) = $sth->fetchrow) {
    $classlist.="<option value=\"$itemtype\">$description\n";
}

$template->param(classlist => $classlist,
						type => 'intranet',
		 branches=>\@branches,
		 itemtypes=>\@itemtypes);

output_html_with_http_headers $query, $cookie, $template->output;
