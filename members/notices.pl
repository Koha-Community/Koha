#!/usr/bin/perl

# Displays sent notices for a given borrower

# Copyright (c) 2009 BibLibre
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_and_exit_if_error output_and_exit output_html_with_http_headers );
use CGI        qw ( -utf8 );
use C4::Members;
use C4::Letters qw( GetPreparedLetter EnqueueLetter );
use Koha::Patrons;
use Koha::Patron::Categories;
use Koha::Patron::Password::Recovery qw( SendPasswordRecoveryEmail ValidateBorrowernumber );

my $input = CGI->new;

my $borrowernumber = $input->param('borrowernumber');
my $patron         = Koha::Patrons->find($borrowernumber);
unless ($patron) {
    print $input->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrowernumber");
    exit;
}
my $borrower = $patron->unblessed;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "members/notices.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { borrowers => 'edit_borrowers' },
    }
);

my $logged_in_user = Koha::Patrons->find($loggedinuser);
output_and_exit_if_error(
    $input, $cookie, $template,
    { module => 'members', logged_in_user => $logged_in_user, current_patron => $patron }
);

# Allow resending of messages in Notices tab
my $op = $input->param('op') || q{};
if ( $op eq 'cud-resend_notice' ) {
    my $message_id = $input->param('message_id');
    my $message    = C4::Letters::GetMessage($message_id);
    if ( $message->{borrowernumber} = $borrowernumber ) {
        C4::Letters::ResendMessage($message_id);

        # redirect to self to avoid form submission on refresh
        print $input->redirect("/cgi-bin/koha/members/notices.pl?borrowernumber=$borrowernumber");
    }
}

if ( $op eq 'send_welcome' ) {
    my $emailaddr = $patron->notice_email_address;

    # if we manage to find a valid email address, send notice
    if ($emailaddr) {
        eval {
            my $letter = GetPreparedLetter(
                module      => 'members',
                letter_code => 'WELCOME',
                branchcode  => $patron->branchcode,
                lang        => $patron->lang || 'default',
                tables      => {
                    'branches'  => $patron->branchcode,
                    'borrowers' => $patron->borrowernumber,
                },
                want_librarian => 1,
            ) or return;

            my $message_id = EnqueueLetter(
                {
                    letter                 => $letter,
                    borrowernumber         => $patron->id,
                    to_address             => $emailaddr,
                    message_transport_type => 'email'
                }
            );
        };
    } else {
        eval {
            my $print = GetPreparedLetter(
                module      => 'members',
                letter_code => 'WELCOME',
                branchcode  => $patron->branchcode,
                lang        => $patron->lang || 'default',
                tables      => {
                    'branches'  => $patron->branchcode,
                    'borrowers' => $patron->borrowernumber,
                },
                want_librarian         => 1,
                message_transport_type => 'print'
            ) or return;

            my $message_id = EnqueueLetter(
                {
                    letter                 => $print,
                    borrowernumber         => $patron->id,
                    message_transport_type => 'print'
                }
            );
        };
    }

    # redirect to self to avoid form submission on refresh
    print $input->redirect("/cgi-bin/koha/members/notices.pl?borrowernumber=$borrowernumber");
}

if ( $op eq 'send_password_reset' ) {

    my $emailaddr = $patron->notice_email_address;

    if ($emailaddr) {

        # send staff initiated password recovery
        SendPasswordRecoveryEmail( $patron, $emailaddr, 1 );
    }

    # redirect to self to avoid form submission on refresh
    print $input->redirect("/cgi-bin/koha/members/notices.pl?borrowernumber=$borrowernumber");
}

# Getting the messages
my $queued_messages = Koha::Notice::Messages->search( { borrowernumber => $borrowernumber } );

$template->param(
    patron          => $patron,
    QUEUED_MESSAGES => $queued_messages,
    borrowernumber  => $borrowernumber,
    sentnotices     => 1,
);
output_html_with_http_headers $input, $cookie, $template->output;

