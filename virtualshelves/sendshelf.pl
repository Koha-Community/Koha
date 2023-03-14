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

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
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
    if $shelf && !$shelf->can_be_viewed( $borrowernumber );

if ($to_address) {
    my $comment = $query->param('comment');

    my $patron = Koha::Patrons->find( $borrowernumber );
    my $user_email = $patron->first_valid_email_address;
    my $contents = $shelf->get_contents;
    my @biblionumbers;
    my $iso2709;

    while ( my $content = $contents->next ) {
        push @biblionumbers, $content->biblionumber;
        my $biblio = Koha::Biblios->find($content->biblionumber);
        $iso2709 .= $biblio->metadata->record->as_usmarc();
    };

    if ( !defined $iso2709 ) {
        carp "Error sending mail: empty basket";
        $template->param( error => 1 );
    } elsif ( !defined $user_email or $user_email eq '' ) {
        carp "Error sending mail: sender's email address is invalid";
        $template->param( error => 1 );
    } else {
        my %loops = (
            biblio => \@biblionumbers,
        );

        my %substitute = (
            comment => $comment,
            listname => $shelf->shelfname,
        );

        my $letter = C4::Letters::GetPreparedLetter(
            module => 'catalogue',
            letter_code => 'LIST',
            lang => $patron->lang,
            tables => {
                borrowers => $borrowernumber,
            },
            message_transport_type => 'email',
            loops => \%loops,
            substitute => \%substitute,
        );

        my $attachment = {
            filename => 'shelf.iso2709',
            type => 'application/octet-stream',
            content => Encode::encode("UTF-8", $iso2709),
        };

        my $message_id = C4::Letters::EnqueueLetter({
            letter => $letter,
            message_transport_type => 'email',
            borrowernumber => $patron->borrowernumber,
            to_address => $to_address,
            reply_address => $user_email,
            attachments => [$attachment],
        });

        C4::Letters::SendQueuedMessages({ message_id => $message_id });

        $template->param( SENT => 1 );
    }

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
