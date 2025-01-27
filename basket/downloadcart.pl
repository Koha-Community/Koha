#!/usr/bin/perl

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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use CGI    qw ( -utf8 );
use Encode qw( encode );

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Record;
use C4::Ris qw( marc2ris );

use Koha::CsvProfiles;
use Koha::Biblios;

use utf8;
my $query = CGI->new;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "basket/downloadcart.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { catalogue => 1 },
    }
);

my $bib_list = $query->param('bib_list');
my $format   = $query->param('format');
my $dbh      = C4::Context->dbh;

if ( $bib_list && $format ) {

    my @bibs = split( /\//, $bib_list );

    my $marcflavour = C4::Context->preference('marcflavour');
    my $output;

    # CSV
    if ( $format =~ /^\d+$/ ) {

        $output = marc2csv( \@bibs, $format );

        # Other formats
    } else {

        foreach my $biblionumber (@bibs) {

            my $biblio = Koha::Biblios->find($biblionumber);
            my $record = $biblio->metadata_record( { embed_items => 1 } );
            next unless $record;

            if ( $format eq 'iso2709' ) {

                #NOTE: If we don't explicitly UTF-8 encode the output,
                #the browser will guess the encoding, and it won't always choose UTF-8.
                $output .= encode( "UTF-8", $record->as_usmarc() ) // q{};
            } elsif ( $format eq 'ris' ) {
                $output .= marc2ris($record);
            } elsif ( $format eq 'bibtex' ) {
                $output .= marc2bibtex( $record, $biblionumber );
            }
        }
    }

    # If it was a CSV export we change the format after the export so the file extension is fine
    $format = "csv" if ( $format =~ m/^\d+$/ );

    print $query->header(
        -type                        => 'application/octet-stream',
        -'Content-Transfer-Encoding' => 'binary',
        -attachment                  => "cart.$format"
    );
    print $output;

} else {
    $template->param( csv_profiles => Koha::CsvProfiles->search( { type => 'marc', used_for => 'export_records' } ) );
    $template->param( bib_list     => $bib_list );
    output_html_with_http_headers $query, $cookie, $template->output;
}
