#!/usr/bin/perl
## This script allows you to export a rel_2_2 bibliographic db in 
#MARC21 format from the command line.
#
use HTML::Template;
use strict;
require Exporter;
use C4::Database;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Output;  # contains gettemplate
use C4::Biblio;
use CGI;
use C4::Auth;
my $outfile = $ARGV[0];
open(OUT,">$outfile") or die $!;
my $query = new CGI;
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

		print OUT $record->as_usmarc();
	}
close(OUT);
