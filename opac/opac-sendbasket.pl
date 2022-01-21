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

use Modern::Perl;

use CGI qw ( -utf8 );
use Encode;
use Carp qw( carp );
use Try::Tiny qw( catch try );

use C4::Biblio qw(
    GetMarcSubjects
);
use C4::Items qw( GetItemsInfo );
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Templates;
use Koha::Biblios;
use Koha::Email;
use Koha::Patrons;
use Koha::Token;

my $query = CGI->new;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user (
    {
        template_name   => "opac-sendbasketform.tt",
        query           => $query,
        type            => "opac",
    }
);

my $bib_list     = $query->param('bib_list') || '';
my $email_add    = $query->param('email_add');

my $dbh          = C4::Context->dbh;

if ( $email_add ) {
    die "Wrong CSRF token" unless Koha::Token->new->check_csrf({
        session_id => scalar $query->cookie('CGISESSID'),
        token  => scalar $query->param('csrf_token'),
    });
    my $patron = Koha::Patrons->find( $borrowernumber );
    my $user_email = $patron->first_valid_email_address
    || C4::Context->preference('KohaAdminEmailAddress');

    my $email_replyto = $patron->firstname . " " . $patron->surname . " <$user_email>";
    my $comment    = $query->param('comment');

    # Since we are already logged in, no need to check credentials again
    # when loading a second template.
    my $template2 = C4::Templates::gettemplate(
        'opac-sendbasket.tt', 'opac', $query,
    );

    my @bibs = split( /\//, $bib_list );
    my @results;
    my $iso2709;
    my $marcflavour = C4::Context->preference('marcflavour');
    foreach my $biblionumber (@bibs) {
        $template2->param( biblionumber => $biblionumber );

        my $biblio           = Koha::Biblios->find( $biblionumber ) or next;
        my $dat              = $biblio->unblessed;
        my $record = $biblio->metadata->record(
            {
                embed_items => 1,
                opac        => 1,
                patron      => $patron,
            }
        );
        my $marcauthorsarray = $biblio->get_marc_authors;
        my $marcsubjctsarray = GetMarcSubjects( $record, $marcflavour );

        my @items = GetItemsInfo( $biblionumber );

        my $hasauthors = 0;
        if($dat->{'author'} || @$marcauthorsarray) {
          $hasauthors = 1;
        }
	

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
        comment        => $comment,
        firstname      => $patron->firstname,
        surname        => $patron->surname,
    );

    # Getting template result
    my $template_res = $template2->output();
    my $body;

    # Analysing information and getting mail properties
    my $subject;
    if ( $template_res =~ /\<SUBJECT\>(?<subject>.*)\<END_SUBJECT\>/s ) {
        $subject = $+{subject};
        $subject =~ s|\n?(.*)\n?|$1|;
    }
    else {
        $subject = "no subject";
    }

    my $email_header = "";
    if ( $template_res =~ /<HEADER>(.*)<END_HEADER>/s ) {
        $email_header = $1;
        $email_header =~ s|\n?(.*)\n?|$1|;
    }

    if ( $template_res =~ /<MESSAGE>(.*)<END_MESSAGE>/s ) {
        $body = $1;
        $body =~ s|\n?(.*)\n?|$1|;
    }

    my $THE_body = <<END_OF_BODY;
$email_header
$body
END_OF_BODY

    if ( !defined $iso2709 ) {
        carp "Error sending mail: empty basket";
        $template->param( error => 1 );
    }
    else {
        try {
            # if you want to use the KohaAdmin address as from, that is the default no need to set it
            my $email = Koha::Email->create({
                to       => $email_add,
                reply_to => $email_replyto,
                subject  => $subject,
            });
            $email->header( 'X-Abuse-Report' => C4::Context->preference('KohaAdminEmailAddress') );
            $email->text_body( $THE_body );
            $email->attach(
                Encode::encode( "UTF-8", $iso2709 ),
                content_type => 'application/octet-stream',
                name         => 'basket.iso2709',
                disposition  => 'attachment',
            );
            my $library = $patron->library;
            $email->transport( $library->smtp_server->transport );
            $email->send_or_die;
            $template->param( SENT => "1" );
        }
        catch {
            carp "Error sending mail: $_";
            $template->param( error => 1 );
        };
    }

    $template->param( email_add => $email_add );
    output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
}
else {
    my $new_session_id = $query->cookie('CGISESSID');
    $template->param(
        bib_list       => $bib_list,
        url            => "/cgi-bin/koha/opac-sendbasket.pl",
        suggestion     => C4::Context->preference("suggestion"),
        virtualshelves => C4::Context->preference("virtualshelves"),
        csrf_token => Koha::Token->new->generate_csrf(
            { session_id => $new_session_id, } ),
    );
    output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
}
