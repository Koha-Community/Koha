#!/usr/bin/perl

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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;

use CGI;
use Encode qw(encode);

use Mail::Sendmail;
use MIME::QuotedPrint;
use MIME::Base64;
use C4::Biblio;
use C4::Items;
use C4::Auth;
use C4::Output;
use C4::Biblio;

my $query = new CGI;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user (
    {
        template_name   => "opac-sendbasketform.tmpl",
        query           => $query,
        type            => "opac",
        authnotrequired => 1,
        flagsrequired   => { borrow => 1 },
    }
);

my $bib_list     = $query->param('bib_list');
my $email_add    = $query->param('email_add');
my $email_sender = $query->param('email_sender');

my $dbh          = C4::Context->dbh;

if ( $email_add ) {
    my $email_from = C4::Context->preference('KohaAdminEmailAddress');
    my $comment    = $query->param('comment');
    my %mail = (
        To   => $email_add,
        From => $email_from
    );

    my ( $template2, $borrowernumber, $cookie ) = get_template_and_user(
        {
            template_name   => "opac-sendbasket.tmpl",
            query           => $query,
            type            => "opac",
            authnotrequired => 1,
            flagsrequired   => { borrow => 1 },
        }
    );

    my @bibs = split( /\//, $bib_list );
    my @results;
    my $iso2709;
    my $marcflavour = C4::Context->preference('marcflavour');
    foreach my $biblionumber (@bibs) {
        $template2->param( biblionumber => $biblionumber );

        my $dat              = GetBiblioData($biblionumber);
        my $record           = GetMarcBiblio($biblionumber);
        my $marcnotesarray   = GetMarcNotes( $record, $marcflavour );
        my $marcauthorsarray = GetMarcAuthors( $record, $marcflavour );
        my $marcsubjctsarray = GetMarcSubjects( $record, $marcflavour );

        my @items = &GetItemsInfo( $biblionumber, 'opac' );

        $dat->{MARCNOTES}      = $marcnotesarray;
        $dat->{MARCSUBJCTS}    = $marcsubjctsarray;
        $dat->{MARCAUTHORS}    = $marcauthorsarray;
        $dat->{'biblionumber'} = $biblionumber;
        $dat->{ITEM_RESULTS}   = \@items;

        $iso2709 .= $record->as_usmarc();

        push( @results, $dat );
    }

    my $resultsarray = \@results;
    $template2->param(
        BIBLIO_RESULTS => $resultsarray,
        email_sender   => $email_sender,
        comment        => $comment
    );

    # Getting template result
    my $template_res = $template2->output();
    my $body;

    # Analysing information and getting mail properties
    if ( $template_res =~ /<SUBJECT>\n(.*)\n<END_SUBJECT>/s ) {
        $mail{'subject'} = $1;
    }
    else { $mail{'subject'} = "no subject"; }

    my $email_header = "";
    if ( $template_res =~ /<HEADER>\n(.*)\n<END_HEADER>/s ) {
        $email_header = $1;
    }

    my $email_file = "basket.txt";
    if ( $template_res =~ /<FILENAME>\n(.*)\n<END_FILENAME>/s ) {
        $email_file = $1;
    }

    if ( $template_res =~ /<MESSAGE>\n(.*)\n<END_MESSAGE>/s ) { $body = encode_qp($1); }

    my $boundary = "====" . time() . "====";

    #     $mail{'content-type'} = "multipart/mixed; boundary=\"$boundary\"";
    #
    #     $email_header = encode_qp($email_header);
    #
    #     $boundary = "--".$boundary;
    #
    #     # Writing mail
    #     $mail{body} =
    $mail{'content-type'} = "multipart/mixed; boundary=\"$boundary\"";
    my $isofile = encode_base64(encode("UTF-8", $iso2709));
    $boundary = '--' . $boundary;
    $mail{body} = <<END_OF_BODY;
$boundary
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable

$email_header
$body
$boundary
Content-Type: application/octet-stream; name="basket.iso2709"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="basket.iso2709"

$isofile
$boundary--
END_OF_BODY

    # Sending mail
    if ( sendmail %mail ) {
        # do something if it works....
        $template->param( SENT      => "1" );
    }
    else {
        # do something if it doesnt work....
        warn "Error sending mail: $Mail::Sendmail::error \n";
        $template->param( error => 1 );
    }
    $template->param( email_add => $email_add );
    output_html_with_http_headers $query, $cookie, $template->output;
}
else {
    $template->param( bib_list => $bib_list );
    $template->param(
        url            => "/cgi-bin/koha/opac-sendbasket.pl",
        suggestion     => C4::Context->preference("suggestion"),
        virtualshelves => C4::Context->preference("virtualshelves"),
    );
    output_html_with_http_headers $query, $cookie, $template->output;
}
