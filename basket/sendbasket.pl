#!/usr/bin/perl

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
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_and_exit output_html_with_http_headers );
use C4::Templates;
use Koha::Biblios;
use Koha::Email;
use Koha::Token;

my $query = CGI->new;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user (
    {
        template_name   => "basket/sendbasketform.tt",
        query           => $query,
        type            => "intranet",
        flagsrequired   => { catalogue => 1 },
    }
);

my $bib_list  = $query->param('bib_list') || '';
my $email_add = $query->param('email_add');

my $dbh = C4::Context->dbh;

if ( $email_add ) {
    output_and_exit( $query, $cookie, $template, 'wrong_csrf_token' )
        unless Koha::Token->new->check_csrf({
            session_id => scalar $query->cookie('CGISESSID'),
            token  => scalar $query->param('csrf_token'),
        });
    my $comment = $query->param('comment');

    # Since we are already logged in, no need to check credentials again
    # when loading a second template.
    my $template2 = C4::Templates::gettemplate(
        'basket/sendbasket.tt', 'intranet', $query,
    );

    my @bibs = split( /\//, $bib_list );
    my @results;
    my $iso2709;
    my $marcflavour = C4::Context->preference('marcflavour');
    foreach my $biblionumber (@bibs) {
        $template2->param( biblionumber => $biblionumber );

        my $biblio           = Koha::Biblios->find( $biblionumber ) or next;
        my $dat              = $biblio->unblessed;
        my $record           = $biblio->metadata->record({ embed_items => 1 });
        my $marcauthorsarray = $biblio->get_marc_contributors;
        my $marcsubjctsarray = GetMarcSubjects( $record, $marcflavour );

        my $hasauthors = 0;
        if($dat->{'author'} || @$marcauthorsarray) {
          $hasauthors = 1;
        }
	

        $dat->{MARCSUBJCTS}    = $marcsubjctsarray;
        $dat->{MARCAUTHORS}    = $marcauthorsarray;
        $dat->{HASAUTHORS}     = $hasauthors;
        $dat->{'biblionumber'} = $biblionumber;
        $dat->{ITEM_RESULTS}   = $biblio->items->search_ordered;

        $iso2709 .= $record->as_usmarc();

        push( @results, $dat );
    }

    my $resultsarray = \@results;
    $template2->param(
        BIBLIO_RESULTS => $resultsarray,
        comment        => $comment
    );

    # Getting template result
    my $template_res = $template2->output();
    my $body;

    my $subject;
    # Analysing information and getting mail properties
    if ( $template_res =~ /<SUBJECT>(?<subject>.*)<END_SUBJECT>/s ) {
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

    try {

        my $email = Koha::Email->create(
            {
                to      => $email_add,
                subject => $subject,
            }
        );

        $email->text_body( $THE_body );
        $email->attach(
            Encode::encode( "UTF-8", $iso2709 ),
            content_type => 'application/octet-stream',
            name         => 'basket.iso2709',
            disposition  => 'attachment',
        );

        my $library = Koha::Patrons->find( $borrowernumber )->library;
        $email->send_or_die({ transport => $library->smtp_server->transport });
        $template->param( SENT => "1" );
    }
    catch {
        carp "Error sending mail: $_";
        $template->param( error => 1 );
    };

    $template->param( email_add => $email_add );
    output_html_with_http_headers $query, $cookie, $template->output;
}
else {
    $template->param(
        bib_list       => $bib_list,
        url            => "/cgi-bin/koha/basket/sendbasket.pl",
        suggestion     => C4::Context->preference("suggestion"),
        virtualshelves => C4::Context->preference("virtualshelves"),
        csrf_token     => Koha::Token->new->generate_csrf({ session_id => scalar $query->cookie('CGISESSID'), }),
    );
    output_html_with_http_headers $query, $cookie, $template->output;
}
