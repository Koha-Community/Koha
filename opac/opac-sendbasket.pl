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
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Templates;
use Koha::Biblios;
use Koha::Email;
use Koha::Patrons;
use Koha::Token;

my $query = CGI->new;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "opac-sendbasketform.tt",
        query         => $query,
        type          => "opac",
    }
);

my $bib_list  = $query->param('bib_list') || '';
my $email_add = $query->param('email_add');

if ( $email_add ) {
    die "Wrong CSRF token"
      unless Koha::Token->new->check_csrf(
        {
            session_id => scalar $query->cookie('CGISESSID'),
            token      => scalar $query->param('csrf_token'),
        }
      );

    my $patron     = Koha::Patrons->find($borrowernumber);
    my $user_email = $patron->notice_email_address;

    my $comment = $query->param('comment');

    my @bibs = split( /\//, $bib_list );
    my $iso2709;
    foreach my $bib (@bibs) {
        my $biblio = Koha::Biblios->find($bib) or next;
        $iso2709 .= $biblio->metadata->record->as_usmarc();
    }

    if ( !defined $iso2709 ) {
        carp "Error sending mail: empty basket";
        $template->param( error => 1 );
    }
    elsif ( !defined $user_email or $user_email eq '' ) {
        carp "Error sending mail: sender's email address is invalid";
        $template->param( error => 1 );
    }
    else {
        my %loops = ( biblio => \@bibs, );

        my %substitute = ( comment => $comment, );

        my $letter = C4::Letters::GetPreparedLetter(
            module      => 'catalogue',
            letter_code => 'CART',
            lang        => $patron->lang,
            tables      => {
                borrowers => $borrowernumber,
            },
            message_transport_type => 'email',
            loops                  => \%loops,
            substitute             => \%substitute,
        );

        my $attachment = {
            filename => 'basket.iso2709',
            type     => 'application/octet-stream',
            content  => Encode::encode( "UTF-8", $iso2709 ),
        };

        my $message_id = C4::Letters::EnqueueLetter(
            {
                letter                 => $letter,
                message_transport_type => 'email',
                to_address             => $email_add,
                reply_address          => $user_email,
                attachments            => [$attachment],
            }
        );

        C4::Letters::SendQueuedMessages( { message_id => $message_id } ) if $message_id;

        $template->param( SENT => 1 );
    }

    $template->param( email_add => $email_add );
    output_html_with_http_headers $query, $cookie, $template->output, undef,
      { force_no_caching => 1 };
}
else {
    my $new_session_id = $query->cookie('CGISESSID');
    $template->param(
        bib_list       => $bib_list,
        url            => "/cgi-bin/koha/opac-sendbasket.pl",
        suggestion     => C4::Context->preference("suggestion"),
        virtualshelves => C4::Context->preference("virtualshelves"),
        csrf_token =>
          Koha::Token->new->generate_csrf( { session_id => $new_session_id, } ),
    );
    output_html_with_http_headers $query, $cookie, $template->output, undef,
      { force_no_caching => 1 };
}
