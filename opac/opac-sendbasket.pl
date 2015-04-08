#!/usr/bin/perl

# Copyright Doxulting 2004
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
use Encode qw(encode);
use Carp;

use Mail::Sendmail;
use MIME::QuotedPrint;
use MIME::Base64;
use C4::Biblio;
use C4::Items;
use C4::Auth;
use C4::Output;
use C4::Biblio;
use C4::Members;
use Koha::Email;

my $query = new CGI;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user (
    {
        template_name   => "opac-sendbasketform.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => 0,
        flagsrequired   => { borrow => 1 },
    }
);

my $bib_list     = $query->param('bib_list');
my $email_add    = $query->param('email_add');
my $email_sender = $query->param('email_sender');

my $dbh          = C4::Context->dbh;

if ( $email_add ) {
    my $email = Koha::Email->new();
    my $user = GetMember(borrowernumber => $borrowernumber);
    my $user_email = GetFirstValidEmailAddress($borrowernumber)
    || C4::Context->preference('KohaAdminEmailAddress');

    my $email_replyto = "$user->{firstname} $user->{surname} <$user_email>";
    my $comment    = $query->param('comment');

   # if you want to use the KohaAdmin address as from, that is the default no need to set it
    my %mail = $email->create_message_headers({
        to => $email_add,
        replyto => $email_replyto,
    });
    $mail{'X-Abuse-Report'} = C4::Context->preference('KohaAdminEmailAddress');

    my ( $template2, $borrowernumber, $cookie ) = get_template_and_user(
        {
            template_name   => "opac-sendbasket.tt",
            query           => $query,
            type            => "opac",
            authnotrequired => 0,
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
        next unless $dat;
        my $record           = GetMarcBiblio($biblionumber, 1);
        my $marcnotesarray   = GetMarcNotes( $record, $marcflavour );
        my $marcauthorsarray = GetMarcAuthors( $record, $marcflavour );
        my $marcsubjctsarray = GetMarcSubjects( $record, $marcflavour );

        my @items = GetItemsInfo( $biblionumber );

        my $hasauthors = 0;
        if($dat->{'author'} || @$marcauthorsarray) {
          $hasauthors = 1;
        }
	

        $dat->{MARCNOTES}      = $marcnotesarray;
        $dat->{MARCSUBJCTS}    = $marcsubjctsarray;
        $dat->{MARCAUTHORS}    = $marcauthorsarray;
        $dat->{HASAUTHORS}     = $hasauthors;
        $dat->{'biblionumber'} = $biblionumber;
        $dat->{ITEM_RESULTS}   = \@items;

        $iso2709 .= $record->as_usmarc();

        push( @results, $dat );
    }

    my $resultsarray = \@results;
    
    $template2->param(
        BIBLIO_RESULTS => $resultsarray,
        email_sender   => $email_sender,
        comment        => $comment,
        firstname      => $user->{firstname},
        surname        => $user->{surname},
    );

    # Getting template result
    my $template_res = $template2->output();
    my $body;

    # Analysing information and getting mail properties

    if ( $template_res =~ /<SUBJECT>(.*)<END_SUBJECT>/s ) {
        $mail{subject} = $1;
        $mail{subject} =~ s|\n?(.*)\n?|$1|;
    }
    else { $mail{'subject'} = "no subject"; }

    my $email_header = "";
    if ( $template_res =~ /<HEADER>(.*)<END_HEADER>/s ) {
        $email_header = $1;
        $email_header =~ s|\n?(.*)\n?|$1|;
        $email_header = encode_qp($email_header);
    }

    my $email_file = "basket.txt";
    if ( $template_res =~ /<FILENAME>(.*)<END_FILENAME>/s ) {
        $email_file = $1;
        $email_file =~ s|\n?(.*)\n?|$1|;
    }

    if ( $template_res =~ /<MESSAGE>(.*)<END_MESSAGE>/s ) {
        $body = $1;
        $body =~ s|\n?(.*)\n?|$1|;
        $body = encode_qp($body);
    }

    $mail{body} = $body;

    my $boundary = "====" . time() . "====";

    $mail{'content-type'} = "multipart/mixed; boundary=\"$boundary\"";
    my $isofile = encode_base64(encode("UTF-8", $iso2709));
    $boundary = '--' . $boundary;
    $mail{body} = <<END_OF_BODY;
$boundary
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
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

    # Sending mail (if not empty basket)
    if ( defined($iso2709) && sendmail %mail ) {
    # do something if it works....
        $template->param( SENT      => "1" );
    }
    else {
        # do something if it doesnt work....
    carp "Error sending mail: empty basket" if !defined($iso2709);
        carp "Error sending mail: $Mail::Sendmail::error" if $Mail::Sendmail::error;
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
