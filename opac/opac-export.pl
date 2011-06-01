#!/usr/bin/perl

# Parts Copyright Catalyst IT 2011
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA
#


use strict;
use warnings;

use C4::Record;
use C4::Auth;
use C4::Output;
use C4::Biblio;
use CGI;
use C4::Auth;
use C4::Ris;

my $query = new CGI;
my $op=$query->param("op");
my $format=$query->param("format");
if ($op eq "export") {
	my $biblionumber = $query->param("bib");
	my $error;

		if ($biblionumber){

			my $marc = GetMarcBiblio($biblionumber, 1);

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
 			elsif ($format =~ /ris/) {
 				$marc = marc2ris(MARC::Record->new_from_usmarc($marc));
 			}
			elsif ($format =~ /bibtex/) {
				$marc = marc2bibtex(C4::Biblio::GetMarcBiblio($biblionumber),$biblionumber);
			}
			elsif ($format =~ /dc/) {
				($error,$marc) = marc2dcxml($marc,1);
				$format = "dublin-core.xml";
			}
			elsif ($format =~ /marc8/) {
				($error,$marc) = changeEncoding($marc,"MARC","MARC21","MARC-8");
				if (! $error){
				    $marc = $marc->as_usmarc();
				}
			}
			elsif ($format =~ /utf8/) {
				C4::Charset::SetUTF8Flag($marc,1);
				$marc = $marc->as_usmarc();
			}

		if ($error){
		    print $query->header();
		    print $query->start_html();
		    print "<h1>An error occured </h1>";
		    print $error;
		    print $query->end_html();
		}
		else {
		    print $query->header(
				    -type => 'application/octet-stream',
		    -attachment=>"bib-$biblionumber.$format");
		    print $marc;
		}
	    }
}
