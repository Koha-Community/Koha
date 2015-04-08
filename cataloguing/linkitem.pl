#!/usr/bin/perl

# Link an item belonging to an analytical record, the item barcode needs to be provided
#
# Copyright 2009 BibLibre, 2010 Nucsoft OSS Labs
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Biblio;
use C4::Items;
use C4::Context;
use C4::Koha;
use C4::Branch;


my $query = CGI->new;

my $biblionumber = $query->param('biblionumber');
my $barcode	 = $query->param('barcode');

my ($template, $loggedinuser, $cookie) = get_template_and_user(
    {
        template_name   => "cataloguing/linkitem.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { editcatalogue => 'edit_catalogue' },
        debug           => 1,
    }
);

my $biblio = GetMarcBiblio($biblionumber);
my $marcflavour = C4::Context->preference("marcflavour");
$marcflavour ||="MARC21";
if ($marcflavour eq 'MARC21' || $marcflavour eq 'NORMARC') {
    $template->param(bibliotitle => $biblio->subfield('245','a'));
} elsif ($marcflavour eq 'UNIMARC') {
    $template->param(bibliotitle => $biblio->subfield('200','a'));
}

$template->param(biblionumber => $biblionumber);

if ($barcode && $biblionumber) { 
    
    # We get the host itemnumber
    my $hostitemnumber = GetItemnumberFromBarcode($barcode);

    if ($hostitemnumber) {
	my $hostbiblionumber = GetBiblionumberFromItemnumber($hostitemnumber);

	if ($hostbiblionumber) {
	        my $field = PrepHostMarcField($hostbiblionumber, $hostitemnumber,$marcflavour);
		$biblio->append_fields($field);

		my $modresult = ModBiblio($biblio, $biblionumber, ''); 
		if ($modresult) { 
			$template->param(success => 1);
		} else {
			$template->param(error => 1,
					 errornomodbiblio => 1); 
		}
	} else {
		$template->param(error => 1,
	        	             errornohostbiblionumber => 1);
	}
    } else {
	    $template->param(error => 1,
			     errornohostitemnumber => 1);

    }
    $template->param(
			barcode => $barcode,  
			hostitemnumber => $hostitemnumber,
		    );

} else {
    $template->param(missingparameter => 1);
    if (!$barcode)      { $template->param(missingbarcode      => 1); }
    if (!$biblionumber) { $template->param(missingbiblionumber => 1); }
}


output_html_with_http_headers $query, $cookie, $template->output;
