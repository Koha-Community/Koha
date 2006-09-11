#!/usr/bin/perl
use strict;

use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Biblio;
use CGI;
use C4::Auth;
use MARC::Record;
use MARC::File::XML;
my $query = new CGI;
my $op=$query->param("op");
if ($op eq "export") {
	print $query->header('Content-Type: text/marc');
	my $start_bib = $query->param("start_bib");
	my $end_bib = $query->param("end_bib");
	my $dbh=C4::Context->dbh;
	my $sth;
	if ($start_bib && $end_bib) {
		$sth=$dbh->prepare("select marcxml from biblio where biblionumber >=? and biblionumber <=? order by biblionumber");
		$sth->execute($start_bib,$end_bib);
	} elsif ($start_bib ) {
		$sth=$dbh->prepare("select marcxml from biblio where biblionumber >=?  order by biblionumber");
		$sth->execute($start_bib);
	}else {
		$sth=$dbh->prepare("select marcxml from biblio order by biblionumber");
		$sth->execute();
	}
	while (my ($marc) = $sth->fetchrow) {
my $record=MARC::Record->new_from_xml($marc,"UTF-8");
	
		print $record->as_usmarc;;
	
	}
} else {
	my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "tools/marc.tmpl",
					query => $query,
					type => "intranet",
					authnotrequired => 0,
					flagsrequired => {parameters => 1, management => 1, tools => 1},
					debug => 1,
					});
	output_html_with_http_headers $query, $cookie, $template->output;
}

