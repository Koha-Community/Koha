#!/usr/bin/perl

# Link an item belonging to an analytical record, the item barcode needs to be provided
#
# Copyright 2009 BibLibre, 2010 Nucsoft OSS Labs
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
use C4::Biblio qw( ModBiblio PrepHostMarcField );
use C4::Context;
use Koha::Biblios;

my $query = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "cataloguing/linkitem.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { editcatalogue => 'edit_catalogue' },
    }
);

my $biblionumber = $query->param('biblionumber');
my $barcode      = $query->param('barcode');
my $op           = $query->param('op') || q{};
my $biblio       = Koha::Biblios->find($biblionumber);
my $record       = $biblio->metadata->record;
my $marcflavour  = C4::Context->preference("marcflavour");
$marcflavour ||= "MARC21";
if ( $marcflavour eq 'MARC21' ) {
    $template->param( bibliotitle => $record->subfield( '245', 'a' ) );
} elsif ( $marcflavour eq 'UNIMARC' ) {
    $template->param( bibliotitle => $record->subfield( '200', 'a' ) );
}

$template->param( biblionumber => $biblionumber );

if ( $op eq 'cud-linkitem' && $barcode && $biblionumber ) {

    my $item = Koha::Items->find( { barcode => $barcode } );

    if ($item) {
        my $field = PrepHostMarcField( $item->biblio->biblionumber, $item->itemnumber, $marcflavour );
        $record->append_fields($field);

        my $modresult = ModBiblio( $record, $biblionumber, '' );
        if ($modresult) {
            $template->param( success => 1 );
        } else {
            $template->param(
                error            => 1,
                errornomodbiblio => 1
            );
        }
        $template->param(
            hostitemnumber => $item->itemnumber,
        );
    } else {
        $template->param(
            error                 => 1,
            errornohostitemnumber => 1,
        );
    }

    $template->param(
        barcode => $barcode,
    );

} else {
    $template->param( missingparameter => 1 );
    if ( !$barcode )      { $template->param( missingbarcode      => 1 ); }
    if ( !$biblionumber ) { $template->param( missingbiblionumber => 1 ); }
}

output_html_with_http_headers $query, $cookie, $template->output;
