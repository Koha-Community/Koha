#!/usr/bin/perl
#script to provide bookshelf management
# WARNING: This file uses 4-character tabs!
#
# $Header$
#
# Copyright 2000-2002 Katipo Communications
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

use strict;
use C4::Search;
use C4::Biblio;
use CGI;
use C4::Output;
use C4::BookShelves;
use C4::Circulation::Circ2;
use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;

my $env;
my $query = new CGI;
my $biblionumber = $query->param('biblionumber');
my $shelfnumber = $query->param('shelfnumber');
if ($shelfnumber) {
	&AddToShelfFromBiblio($env, $biblionumber, $shelfnumber);
	print "Content-Type: text/html\n\n<html><body onload=\"window.close()\"></body></html>";
	exit;
} else {

	my  ( $bibliocount, @biblios )  = getbiblio($biblionumber);
	my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "bookshelves/addbookbybiblionumber.tmpl",
								query => $query,
								type => "intranet",
								authnotrequired => 0,
								flagsrequired => {catalogue => 1},
							});

	my ($shelflist) = GetShelfList($loggedinuser,3);
	my @shelvesloop;
	my %shelvesloop;
	foreach my $element (sort keys %$shelflist) {
			push (@shelvesloop, $element);
			$shelvesloop{$element} = $shelflist->{$element}->{'shelfname'};
	}

	my $CGIbookshelves=CGI::scrolling_list( -name     => 'shelfnumber',
				-values   => \@shelvesloop,
				-labels   => \%shelvesloop,
				-size     => 1,
				-multiple => 0 );

	$template->param(biblionumber => $biblionumber,
						title => $biblios[0]->{'title'},
						author => $biblios[0]->{'author'},
						CGIbookshelves => $CGIbookshelves,
						);

	output_html_with_http_headers $query, $cookie, $template->output;
}
# $Log$
# Revision 1.2  2004/11/19 16:31:30  tipaul
# bugfix for bookshelves not in official CVS
#
# Revision 1.1.2.2  2004/03/10 15:08:18  tipaul
# modifying shelves : introducing category of shelf : private, public, free for all
#
# Revision 1.1.2.1  2004/02/19 10:14:36  tipaul
# new feature : adding book to bookshelf from biblio detail screen.
#

# Local Variables:
# tab-width: 4
# End:
