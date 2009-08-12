#!/usr/bin/perl
use HTML::Template::Pro;
use strict;
use warnings;

use C4::Record;
use C4::Auth;
use C4::Output;
use C4::Biblio;
use CGI;
use C4::Auth;

my $query = new CGI;
my $op=$query->param("op");
my $format=$query->param("format");
if ($op eq "export") {
	my $biblionumber = $query->param("bib");
	my $dbh=C4::Context->dbh;
	my $sth;
	if ($biblionumber) {
		$sth=$dbh->prepare("SELECT marc FROM biblioitems WHERE biblionumber =?");
		$sth->execute($biblionumber);
	}
	while (my ($marc) = $sth->fetchrow) {
		if ($marc){

			if ($format =~ /endnote/) {
				$marc = marc2endnote($marc);
				$format = 'endnote';
			}
			elsif ($format =~ /marcxml/) {
				$marc = marc2marcxml($marc);
			}
			elsif ($format=~ /mods/) {
				$marc = marc2modsxml($marc);
			}
			elsif ($format =~ /dc/) {
				my $error;
				($error,$marc) = marc2dcxml($marc,1);
				$format = "dublin-core.xml";
			}
			elsif ($format =~ /marc8/) {
				$marc = changeEncoding($marc,"MARC","MARC21","MARC-8");
				$marc = $marc->as_usmarc();
			}
			elsif ($format =~ /utf8/) {
				#default
			}
			print $query->header(
				-type => 'application/octet-stream',
                -attachment=>"bib-$biblionumber.$format");
			print $marc;
		}
	}
}
