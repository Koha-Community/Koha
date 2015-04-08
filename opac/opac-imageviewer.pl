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

use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Biblio;
use C4::Output;
use C4::Images;

my $query = new CGI;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-imageviewer.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
        flagsrequired => { borrow => 1 },
    }
);

my $biblionumber = $query->param('biblionumber') || $query->param('bib');
my $imagenumber = $query->param('imagenumber');
my $biblio = GetBiblio($biblionumber);

if ( C4::Context->preference("OPACLocalCoverImages") ) {
    my @images = ListImagesForBiblio($biblionumber);
    $template->{VARS}->{'OPACLocalCoverImages'} = 1;
    $template->{VARS}->{'images'}               = \@images;
    $template->{VARS}->{'biblionumber'}         = $biblionumber;
    $template->{VARS}->{'imagenumber'} = $imagenumber || $images[0] || '';
}

$template->{VARS}->{'biblio'} = $biblio;

output_html_with_http_headers $query, $cookie, $template->output;
