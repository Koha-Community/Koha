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

use strict;
#use warnings; FIXME - Bug 2505
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
				flagsrequired => {borrowers => 1},
				debug => 1,
				});

$template->param( $borrower );
$template->param( picture => 1 ) if $patron->image;

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

$template->param(%$borrower);
$template->param( adultborrower => 1 ) if ( $borrower->{category_type} eq 'A' || $borrower->{category_type} eq 'I' );
$template->param(
    QUEUED_MESSAGES    => $queued_messages,
    borrowernumber     => $borrowernumber,
    sentnotices        => 1,
    categoryname       => $patron->category->description,
);
output_html_with_http_headers $input, $cookie, $template->output;

