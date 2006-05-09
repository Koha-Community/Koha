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
use C4::AuthoritiesMarc;
use CGI;
use C4::Auth;
use MARC::Record;
my $outfile = $ARGV[0];
open(OUT,">$outfile") or die $!;
my $query = new CGI;
my $dbh=C4::Context->dbh;

	
	
	my	$sth=$dbh->prepare("select marc from biblioitems order by biblionumber");
		$sth->execute();
	while (my ($marc) = $sth->fetchrow) {
		print OUT $marc;
	}
close(OUT);
