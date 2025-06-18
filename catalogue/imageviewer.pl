#!/usr/bin/perl

# Copyright 2011 C & P Bibliography Services
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI        qw ( -utf8 );
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Search qw( enabled_staff_search_views );

use Koha::Biblios;
use Koha::Items;
use Koha::Patrons;

my $query = CGI->new;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "catalogue/imageviewer.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { catalogue => 1 },
    }
);

my $itemnumber = $query->param('itemnumber');
my $biblionumber =
    $query->param('biblionumber') || $query->param('bib') || Koha::Items->find($itemnumber)->biblionumber;
my $imagenumber = $query->param('imagenumber');
my $biblio      = Koha::Biblios->find($biblionumber);
my $itemcount   = $biblio ? $biblio->items->count : 0;

if ( $query->cookie("holdfor") ) {
    my $holdfor_patron = Koha::Patrons->find( $query->cookie("holdfor") );
    $template->param(
        holdfor        => $query->cookie("holdfor"),
        holdfor_patron => $holdfor_patron,
    );
}

if ( $query->cookie("searchToOrder") ) {
    my ( $basketno, $vendorid ) = split( /\//, $query->cookie("searchToOrder") );
    $template->param(
        searchtoorder_basketno => $basketno,
        searchtoorder_vendorid => $vendorid
    );
}

if ( C4::Context->preference("LocalCoverImages") ) {
    my $images;
    if ($itemnumber) {
        my $item = Koha::Items->find($itemnumber);
        $images = $item->cover_images->as_list;
    } else {
        $images = $biblio->cover_images->as_list;
    }

    $template->param(
        LocalCoverImages => 1,
        images           => $images,
        imagenumber      => ( $imagenumber || ( @$images ? $images->[0]->imagenumber : undef ) ),
    );
}
$template->{VARS}->{'count'} = $itemcount;
$template->param(C4::Search::enabled_staff_search_views);
$template->{VARS}->{'biblio'} = $biblio;

$template->param(
    biblionumber => $biblionumber,
    itemnumber   => $itemnumber,
);

my $hold_count = $biblio ? $biblio->holds->count : 0;
$template->param( holdcount => $hold_count );

output_html_with_http_headers $query, $cookie, $template->output;
