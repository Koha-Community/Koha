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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI             qw ( -utf8 );
use C4::Auth        qw( get_template_and_user );
use C4::Circulation qw( barcodedecode );
use C4::Output      qw( output_html_with_http_headers );

use Koha::Biblios;
use Koha::Items;

my $query = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "cataloguing/moveitem.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { editcatalogue => 'edit_items' },
    }
);

my $op = $query->param('op') || q{};

# The biblio to move the item to
my $biblionumber = $query->param('biblionumber');

# The barcode of the item to move
my $barcode = barcodedecode( scalar $query->param('barcode') );

my $biblio = Koha::Biblios->find($biblionumber);
$template->param( biblio       => $biblio );
$template->param( biblionumber => $biblionumber );

# If we already have the barcode of the item to move and the biblionumber to move the item to
if ( $op eq 'cud-moveitem' && $barcode && $biblionumber ) {

    my $itemnumber;
    my $item = Koha::Items->find( { barcode => $barcode } );

    if ($item) {

        $itemnumber = $item->itemnumber;
        my $frombiblionumber = $item->biblionumber;
        my $to_biblio        = Koha::Biblios->find($biblionumber);

        my $moveresult = $item->move_to_biblio($to_biblio);
        if ($moveresult) {
            $template->param(
                success     => 1,
                from_biblio => Koha::Biblios->find($frombiblionumber),
            );
        } else {
            $template->param(
                error          => 1,
                errornonewitem => 1
            );
        }

    } else {
        $template->param(
            error       => 1,
            errornoitem => 1
        );
    }
    $template->param(
        barcode    => $barcode,
        itemnumber => $itemnumber,
    );

} else {
    $template->param( missingparameter => 1 );
    if ( !$barcode )      { $template->param( missingbarcode      => 1 ); }
    if ( !$biblionumber ) { $template->param( missingbiblionumber => 1 ); }
}

output_html_with_http_headers $query, $cookie, $template->output;
