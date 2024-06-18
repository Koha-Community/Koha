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

#need
use CGI qw ( -utf8 );
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::Libraries;

#unsure
use C4::Biblio;
use C4::External::BakerTaylor qw( image_url link_url );
use MARC::Record;
use Koha::Patrons;
use Koha::ItemTypes;

my $query = CGI->new;

# if OPACVirtualCard is disabled, leave immediately
if ( ! C4::Context->preference('OPACVirtualCard') ) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-virtual-card.tt",
        query           => $query,
        type            => "opac",
    }
);

my $patron = Koha::Patrons->find( $borrowernumber );
# Find and display patron image if allowed
if (C4::Context->preference('OPACpatronimages')) {
        $template->param( display_patron_image => 1 ) if $patron->image;
    }

my $branchcode = $patron->branchcode;
# Fetch the library object using the branchcode
my $library = Koha::Libraries->find($branchcode);

# Get the library name
my $library_name = $library ? $library->branchname : 'Unknown Library';

$template->param(
    virtualcardview => 1,
    cardnumber      => $patron->cardnumber,
    library         => $library_name,
);


output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
