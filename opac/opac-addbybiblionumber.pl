#!/usr/bin/perl

#script to provide virtualshelf management
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
use C4::Biblio;
use CGI;
use C4::VirtualShelves;
use C4::Auth;
use C4::Output;

my $query        = new CGI;
my @biblionumber = $query->param('biblionumber');
my $selectedshelf = $query->param('selectedshelf');
my $newshelf = $query->param('newshelf');
my $shelfnumber  = $query->param('shelfnumber');
my $newvirtualshelf = $query->param('newvirtualshelf');
my $category     = $query->param('category');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-addbybiblionumber.tmpl",
        query           => $query,
        type            => "opac",
        authnotrequired => 1,
    }
);

$shelfnumber = AddShelf(  $newvirtualshelf, $loggedinuser, $category ) if $newvirtualshelf;

# verify user is authorized to perform the action on the shelf...
my $authorized = 1 if ( (ShelfPossibleAction( $loggedinuser, $selectedshelf )) );

# multiple bibs might come in as '/' delimited string (from where, i don't see), or as array.

my $multiple = 0;
my @bibs;
if (scalar(@biblionumber) == 1) {
	@biblionumber =  (split /\//,$biblionumber[0]);
}
if ($shelfnumber && ($shelfnumber != -1)) {
	for my $bib (@biblionumber){
		&AddToShelfFromBiblio($bib,$shelfnumber);
	}	
	print $query->header;
	print "<html><body onload=\"window.close();\"><div>Please close this window to continue.</div></body></html>";
	exit;
}
else {
	if($selectedshelf){
	# adding to specific shelf
	my ( $singleshelf, $singleshelfname, $singlecategory ) = GetShelf( $query->param('selectedshelf') );
				$template->param(
				singleshelf 		=> 1,
				shelfnumber         => $singleshelf,
				shelfname           => $singleshelfname,
				"category$singlecategory" => 1
			);
	} else {
	# offer choice of shelves
    my ($shelflist) = GetShelves( $loggedinuser, 3 );
    my @shelvesloop;
    my %shelvesloop;
    foreach my $element ( sort keys %$shelflist ) {
        push( @shelvesloop, $element );
		$shelvesloop{$element} = $shelflist->{$element}->{'shelfname'};

    my $CGIvirtualshelves;
    if ( @shelvesloop > 0 ) {
        $CGIvirtualshelves = CGI::scrolling_list (
            -name     => 'shelfnumber',
            -id     => 'shelfnumber',
            -values   => \@shelvesloop,
            -labels   => \%shelvesloop,
            -size     => 1,
            -tabindex => '',
            -multiple => 0
        );

	$template->param (
		CGIvirtualshelves       => $CGIvirtualshelves,
	);
    }
    }
	}

	my @biblios;
	for my $bib (@biblionumber) {
		my $data = GetBiblioData( $bib );
		push(@biblios, 
			{ biblionumber => $bib,
			  title        => $data->{'title'},
			  author       => $data->{'author'},
			} );
	}
	$template->param (
		newshelf => $newshelf,
		multiple => (scalar(@biblios) > 1),
		total    => scalar @biblios,
		biblios  => \@biblios,
		authorized	=> $authorized,
	);

	output_html_with_http_headers $query, $cookie, $template->output;
}
