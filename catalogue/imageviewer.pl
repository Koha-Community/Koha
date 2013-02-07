#!/usr/bin/perl

# Copyright 2011 C & P Bibliography Services
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Biblio;
use C4::Items;
use C4::Output;
use C4::Images;
use C4::Search;

my $query = new CGI;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "catalogue/imageviewer.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
    }
);

my $biblionumber = $query->param('biblionumber') || $query->param('bib');
my $imagenumber = $query->param('imagenumber');
my $biblio = GetBiblio($biblionumber);
my $itemcount = GetItemsCount($biblionumber);

my @items = GetItemsInfo($biblionumber);

my $norequests = 1;
foreach my $item (@items) {

    # can place holds defaults to yes
    $norequests = 0
      unless ( ( $item->{'notforloan_per_itemtype'} > 0 )
        || ( $item->{'itemnotforloan'} > 0 ) );
}

if ( $query->cookie("holdfor") ) {
    my $holdfor_patron =
      GetMember( 'borrowernumber' => $query->cookie("holdfor") );
    $template->param(
        holdfor            => $query->cookie("holdfor"),
        holdfor_surname    => $holdfor_patron->{'surname'},
        holdfor_firstname  => $holdfor_patron->{'firstname'},
        holdfor_cardnumber => $holdfor_patron->{'cardnumber'},
    );
}

if ( C4::Context->preference("LocalCoverImages") ) {
    my @images = ListImagesForBiblio($biblionumber);
    $template->{VARS}->{'LocalCoverImages'} = 1;
    $template->{VARS}->{'images'}           = \@images;
    $template->{VARS}->{'imagenumber'}      = $imagenumber || $images[0] || '';
}
$template->{VARS}->{'count'}        = $itemcount;
$template->{VARS}->{'biblionumber'} = $biblionumber;
$template->{VARS}->{'norequests'}   = $norequests;
$template->param(C4::Search::enabled_staff_search_views);
$template->{VARS}->{'biblio'} = $biblio;

my ( $holdcount, $holds ) = C4::Reserves::GetReservesFromBiblionumber($biblionumber,1);
$template->param( holdcount => $holdcount, holds => $holds );

output_html_with_http_headers $query, $cookie, $template->output;
