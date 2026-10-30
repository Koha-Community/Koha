#!/usr/bin/perl

# Copyright 2023 Aleisha Amohia <aleisha@catalyst.net.nz>
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
use CGI qw ( -utf8 );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use C4::Auth   qw( get_template_and_user );
use Koha::Notice::Messages;

my $input = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "members/print_notice.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { tools => 'view_generated_notices' },
    }
);

unless ( C4::Context->preference('NoticesManagement') ) {
    print $input->redirect('/cgi-bin/koha/tools/tools-home.pl');
    exit;
}

# Displaying notices must not change them. Marking them as printed does, so it needs a POST with
# a valid CSRF token and the 'cud-print' operation.
my $op          = $input->param('op') || q{};
my @message_ids = grep { /^\d+$/ } $input->multi_param('message_ids');

# Restrict to the notices of the patrons the logged in user is allowed to see,
# unknown or unauthorised ids are ignored, as are those that cannot be printed
my @messages = grep { $_->can_be_printed } Koha::Notice::Messages->search_limited(
    { 'me.message_id' => \@message_ids },
    { order_by        => 'me.message_id' }
)->as_list;

# Every notice is shown in a sandboxed frame, see print_notice.tt
my @notices = map {
    {
        id           => $_->message_id,
        type         => $_->message_transport_type,
        html_content => $_->html_content,
    }
} @messages;

$_->mark_as_printed for grep { $op eq 'cud-print' } @messages;

$template->param( notices => \@notices );

output_html_with_http_headers $input, $cookie, $template->output;
