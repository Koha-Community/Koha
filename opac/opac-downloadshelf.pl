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

use strict;
use warnings;

use CGI qw ( -utf8 );
use Encode qw(encode);

use C4::Auth;
use C4::Biblio;
use C4::Items;
use C4::Output;
use C4::Record;
use C4::Ris;
use C4::Csv;

use Koha::Virtualshelves;

use utf8;
my $query = new CGI;

# if virtualshelves is disabled, leave immediately
if ( ! C4::Context->preference('virtualshelves') ) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my ( $template, $borrowernumber, $cookie ) = get_template_and_user (
    {
        template_name   => "opac-downloadshelf.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
    }
);

my $shelfnumber = $query->param('shelfnumber');
my $format  = $query->param('format');
my $context = $query->param('context');
my $dbh     = C4::Context->dbh;

my $shelf = Koha::Virtualshelves->find( $shelfnumber );
if ( $shelf and $shelf->can_be_viewed( $borrowernumber ) ) {

    if ($shelfnumber && $format) {


        my $contents = $shelf->get_contents;
        my $marcflavour         = C4::Context->preference('marcflavour');
        my $output;
        my $extension;
        my $type;

       # CSV
        if ($format =~ /^\d+$/) {
            my @biblios;
            while ( my $content = $contents->next ) {
                push @biblios, $content->biblionumber->biblionumber;
            }
            $output = marc2csv(\@biblios, $format);
        # Other formats
        } else {
            while ( my $content = $contents->next ) {
                my $biblionumber = $content->biblionumber->biblionumber;

                my $record = GetMarcBiblio($biblionumber, 1);
                next unless $record;

                if ($format eq 'iso2709') {
                    $output .= $record->as_usmarc();
                }
                elsif ($format eq 'ris' ) {
                    $output .= marc2ris($record);
                }
                elsif ($format eq 'bibtex') {
                    $output .= marc2bibtex($record, $biblionumber);
                }
                elsif ( $format eq 'isbd' ) {
                    $output   .= GetISBDView($biblionumber, "opac");
                    $extension = "txt";
                    $type      = "text/plain";
                }
            }
        }

        # If it was a CSV export we change the format after the export so the file extension is fine
        $format = "csv" if ($format =~ m/^\d+$/);

        print $query->header(
                                   -type => ($type) ? $type : 'application/octet-stream',
            -'Content-Transfer-Encoding' => 'binary',
                             -attachment => ($extension) ? "shelf.$format.$extension" : "shelf.$format"
        );
        print $output;

    } else {

        # if modal context is passed set a variable so that page markup can be different
        if($context eq "modal"){
            $template->param(modal => 1);
        } else {
            $template->param(fullpage => 1);
        }
        $template->param(csv_profiles => GetCsvProfilesLoop('marc'));
        $template->param( shelf => $shelf );
        output_html_with_http_headers $query, $cookie, $template->output;
    }

} else {
    $template->param(invalidlist => 1); 
    output_html_with_http_headers $query, $cookie, $template->output;
}
