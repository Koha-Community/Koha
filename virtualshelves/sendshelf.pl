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

use CGI qw ( -utf8 );
use Encode;
use Carp qw( carp );
use Try::Tiny qw( catch try );

use C4::Auth qw( get_template_and_user );
use C4::Biblio qw(
    GetMarcISBN
    GetMarcSubjects
);
use C4::Output qw(
    output_html_with_http_headers
    output_and_exit
);

use Koha::Biblios;
use Koha::Email;
use Koha::Virtualshelves;

my $query = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "virtualshelves/sendshelfform.tt",
        query           => $query,
        type            => "intranet",
        flagsrequired   => { catalogue => 1 },
    }
);

my $shelfid    = $query->param('shelfid');
my $to_address = $query->param('email');

my $shelf = Koha::Virtualshelves->find( $shelfid );

output_and_exit( $query, $cookie, $template, 'insufficient_permission' )
    if $shelf && !$shelf->can_be_viewed( $loggedinuser );

if ($to_address) {
    my $comment = $query->param('comment');

    my ( $template2, $borrowernumber, $cookie ) = get_template_and_user(
        {
        template_name   => "virtualshelves/sendshelf.tt",
        query           => $query,
        type            => "intranet",
        flagsrequired   => { catalogue => 1 },
        }
    );

    my $contents = $shelf->get_contents;
    my $marcflavour = C4::Context->preference('marcflavour');
    my $iso2709;
    my @results;

    while ( my $content = $contents->next ) {
        my $biblionumber     = $content->biblionumber;
        my $biblio           = Koha::Biblios->find( $biblionumber ) or next;
        my $dat              = $biblio->unblessed;
        my $record           = $biblio->metadata->record({ embed_items => 1 });
        my $marcauthorsarray = $biblio->get_marc_contributors;
        my $marcsubjctsarray = GetMarcSubjects( $record, $marcflavour );

        my $items = $biblio->items->search_ordered;

        $dat->{ISBN}           = GetMarcISBN($record, $marcflavour);
        $dat->{MARCSUBJCTS}    = $marcsubjctsarray;
        $dat->{MARCAUTHORS}    = $marcauthorsarray;
        $dat->{'biblionumber'} = $biblionumber;
        $dat->{ITEM_RESULTS}   = $items;
        $dat->{HASAUTHORS}     = $dat->{'author'} || @$marcauthorsarray;
        $dat->{HOSTITEMENTRIES} = $biblio->get_host_item_entries;

        $iso2709 .= $record->as_usmarc();

        push( @results, $dat );
    }

    $template2->param(
        BIBLIO_RESULTS => \@results,
        comment        => $comment,
        shelfname      => $shelf->shelfname,
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
                to      => $to_address,
                subject => $subject,
            }
        );
        $email->text_body( $THE_body );
        $email->attach(
            Encode::encode("UTF-8", $iso2709),
            content_type => 'application/octet-stream',
            name         => 'shelf.iso2709',
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

    $template->param( email => $to_address );
    output_html_with_http_headers $query, $cookie, $template->output;

}
else {
    $template->param(
        shelfid => $shelfid,
        url     => "/cgi-bin/koha/virtualshelves/sendshelf.pl",
    );
    output_html_with_http_headers $query, $cookie, $template->output;
}
