#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;
use C4::Database;
use C4::Output;  # contains gettemplate
use C4::Biblio;
use CGI;
use C4::Auth;

my $query = new CGI;
my $op=$query->param("op");
if ($op eq "export") {
	print $query->header('Content-Type: text/marc');
	my $start_bib = $query->param("start_bib");
	my $end_bib = $query->param("end_bib");
	my $dbh=C4::Context->dbh;
	my $sth;
	if ($start_bib && $end_bib) {
		$sth=$dbh->prepare("select bibid from marc_biblio where bibid >=? and bibid <=? order by bibid");
		$sth->execute($start_bib,$end_bib);
	} else {
		$sth=$dbh->prepare("select bibid from marc_biblio order by bibid");
		$sth->execute();
	}
	while (my ($bibid) = $sth->fetchrow) {
		my $record = MARCgetbiblio($dbh,$bibid);

		print $record->as_usmarc();
	}
} else {
	my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "export/marc.tmpl",
					query => $query,
					type => "intranet",
					authnotrequired => 0,
					flagsrequired => {parameters => 1},
					debug => 1,
					});
	print  $query->header(-cookie => $cookie), $template->output;
}

