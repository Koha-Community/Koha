#!/usr/bin/perl

# Copyright 2009 PTFS Inc.
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

use C4::Auth    qw( get_template_and_user );
use C4::Output  qw( output_and_exit );
use C4::Letters qw( GetPreparedLetter EnqueueLetter );
use Koha::Patron::Message;
use Koha::Patrons;

my $input = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "circ/circulation.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { borrowers => 'edit_borrowers' },
    }
);

my $op               = $input->param('op');
my $message_id       = $input->param('message_id');
my $borrowernumber   = $input->param('borrowernumber');
my $branchcode       = $input->param('branchcode');
my $message_type     = $input->param('message_type');
my $borrower_message = $input->param('borrower_message');
my $borrower_subject = $input->param('borrower_subject');
my $letter_code      = $input->param('select_patron_notice');
my $batch            = $input->param('batch');

if ( $op eq 'cud-edit_message' && $message_id ) {
    my $message = Koha::Patron::Messages->find($message_id);
    $message->update( { message => $borrower_message } ) if $message;
} elsif ( $op eq 'cud-add_message' ) {
    if ( $message_type eq 'L' or $message_type eq 'B' ) {
        Koha::Patron::Message->new(
            {
                borrowernumber => $borrowernumber,
                branchcode     => $branchcode,
                message_type   => $message_type,
                message        => $borrower_message,
            }
        )->store;
    }

    if ( $message_type eq 'E' ) {
        my $logged_in_patron = Koha::Patrons->find($loggedinuser);
        if ( !$logged_in_patron->has_permission( { borrowers => 'send_messages_to_borrowers' } ) ) {
            C4::Output::output_and_exit( $input, $cookie, $template, 'insufficient_permission' );
        }

        my $letter = {
            title   => $borrower_subject,
            content => $borrower_message
        };

        my $patron = Koha::Patrons->find($borrowernumber);

        if ($letter_code) {
            $letter = C4::Letters::GetPreparedLetter(
                module      => 'add_message',
                letter_code => $letter_code,
                lang        => $patron->lang,
                tables      => {
                    'borrowers' => $borrowernumber,
                    'branches'  => $branchcode,
                },
            );
        }

        C4::Letters::EnqueueLetter(
            {
                letter                 => $letter,
                borrowernumber         => $borrowernumber,
                message_transport_type => 'email',
            }
        ) or warn "can't enqueue letter";
    }
}

my $url = $input->referer;
if ($url) {
    if ( $url =~ m/(circulation\.pl|members\/files\.pl)$/ ) {

        # Trick for POST form from batch checkouts
        $url .= "?borrowernumber=$borrowernumber";
        $url .= "&amp;batch=1" if $batch;
    }
} else {
    $url = "/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrowernumber";
}
print $input->redirect($url);
