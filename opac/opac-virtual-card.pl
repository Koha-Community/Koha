#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2024 Sam Lau (ByWater Solutions)
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
use Koha::Libraries;
use Koha::Patrons;

my $query = CGI->new;

# if OPACVirtualCard is disabled, leave immediately
if ( !C4::Context->preference('OPACVirtualCard') ) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "opac-virtual-card.tt",
        query         => $query,
        type          => "opac",
    }
);

my $patron = Koha::Patrons->find($borrowernumber);

# Find and display patron image if allowed
if ( C4::Context->preference('OPACpatronimages') ) {
    $template->param( display_patron_image => 1 ) if $patron->image;
}

# Get the desired barcode format
my $barcode_format = C4::Context->preference('OPACVirtualCardBarcode');

$template->param(
    virtualcardview => 1,
    patron          => $patron,
    barcode_format  => $barcode_format,
);

output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
