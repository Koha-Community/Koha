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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use C4::Auth;
use C4::Output;
use CGI qw ( -utf8 );
use C4::Members;
use C4::Letters;
use C4::Members::Attributes qw(GetBorrowerAttributes);
use Koha::Patrons;

my $input=new CGI;


my $borrowernumber = $input->param('borrowernumber');
my $patron = Koha::Patrons->find( $borrowernumber );
unless ( $patron ) {
    print $input->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrowernumber");
    exit;
}
my $borrower = $patron->unblessed;

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "members/notices.tt",
				query => $input,
				type => "intranet",
				authnotrequired => 0,
                flagsrequired => {borrowers => 'edit_borrowers'},
				debug => 1,
				});

my $logged_in_user = Koha::Patrons->find( $loggedinuser ) or die "Not logged in";
output_and_exit_if_error( $input, $cookie, $template, { module => 'members', logged_in_user => $logged_in_user, current_patron => $patron } );

# Allow resending of messages in Notices tab
my $op = $input->param('op') || q{};
if ( $op eq 'resend_notice' ) {
    my $message_id = $input->param('message_id');
    my $message = C4::Letters::GetMessage( $message_id );
    if ( $message->{borrowernumber} = $borrowernumber ) {
        C4::Letters::ResendMessage( $message_id );
        # redirect to self to avoid form submission on refresh
        print $input->redirect("/cgi-bin/koha/members/notices.pl?borrowernumber=$borrowernumber");
    }
}

# Getting the messages
my $queued_messages = C4::Letters::GetQueuedMessages({borrowernumber => $borrowernumber});

if (C4::Context->preference('ExtendedPatronAttributes')) {
    my $attributes = GetBorrowerAttributes($borrowernumber);
    $template->param(
        ExtendedPatronAttributes => 1,
        extendedattributes => $attributes
    );
}

$template->param(
    patron             => $patron,
    QUEUED_MESSAGES    => $queued_messages,
    borrowernumber     => $borrowernumber,
    sentnotices        => 1,
);
output_html_with_http_headers $input, $cookie, $template->output;

