#!/usr/bin/perl

# Move an item from a biblio to another
#
# Copyright 2009 BibLibre
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
#use warnings; FIXME - Bug 2505
use CGI;
use C4::Auth;
use C4::Output;
use C4::Biblio;
use C4::Items;
use C4::Context;
use C4::Koha;
use C4::Branch;
use C4::ClassSource;
use C4::Acquisition qw/GetOrderFromItemnumber ModOrder GetOrder/;

use Date::Calc qw(Today);

use MARC::File::XML;
my $query = CGI->new;

# The biblio to move the item to
my $biblionumber = $query->param('biblionumber');

# The barcode of the item to move
my $barcode	 = $query->param('barcode');

my ($template, $loggedinuser, $cookie) = get_template_and_user(
    {
        template_name   => "cataloguing/moveitem.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { editcatalogue => 'edit_items' },
        debug           => 1,
    }
);



my $biblio = GetBiblioData($biblionumber);
$template->param(bibliotitle => $biblio->{'title'});
$template->param(biblionumber => $biblionumber);

# If we already have the barcode of the item to move and the biblionumber to move the item to
if ($barcode && $biblionumber) { 
    
    # We get his itemnumber
    my $itemnumber = GetItemnumberFromBarcode($barcode);

    if ($itemnumber) {
    	# And then, we get the item
	my $item = GetItem($itemnumber);

	if ($item) {

	    my $results = GetBiblioFromItemNumber($itemnumber, $barcode);
	    my $frombiblionumber = $results->{'biblionumber'};
	   
	    my $moveresult = MoveItemFromBiblio($itemnumber, $frombiblionumber, $biblionumber); 
	    if ($moveresult) { 
		$template->param(success => 1);
	    } else {
		$template->param(error => 1,
				 errornonewitem => 1); 
	    }


	} else {
	    $template->param(error => 1,
	                     errornoitem => 1);
	}
    } else {
	    $template->param(error => 1,
			     errornoitemnumber => 1);

    }
    $template->param(
			barcode => $barcode,  
			itemnumber => $itemnumber,
		    );

} else {
    $template->param(missingparameter => 1);
    if (!$barcode)      { $template->param(missingbarcode      => 1); }
    if (!$biblionumber) { $template->param(missingbiblionumber => 1); }
}


output_html_with_http_headers $query, $cookie, $template->output;
