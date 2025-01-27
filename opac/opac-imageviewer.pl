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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use CGI        qw ( -utf8 );
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::Biblios;
use Koha::CoverImages;
use Koha::Items;

my $query = CGI->new;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-imageviewer.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
    }
);

my $biblionumber = $query->param('biblionumber') || $query->param('bib');
my $imagenumber  = $query->param('imagenumber');
unless ($biblionumber) {

    # Retrieving the biblio from the imagenumber
    my $image = Koha::CoverImages->find($imagenumber);
    my $item  = Koha::Items->find( $image->{itemnumber} );
    $biblionumber = $item->biblionumber;
}
my $biblio = Koha::Biblios->find($biblionumber);

if ( C4::Context->preference("OPACLocalCoverImages") ) {
    my $images = !$imagenumber ? Koha::Biblios->find($biblionumber)->cover_images->as_list : [];
    $template->param(
        OPACLocalCoverImages => 1,
        images               => $images,
        biblionumber         => $biblionumber,
        imagenumber          => ( @$images ? $images->[0]->imagenumber : $imagenumber ),
    );
}

$template->{VARS}->{'biblio'} = $biblio;

output_html_with_http_headers $query, $cookie, $template->output;
