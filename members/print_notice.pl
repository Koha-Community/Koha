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

my $types_seen = {};
my @scoped_styles;
my @notices;
foreach my $message (@messages) {
    push @notices, {
        content => $message->content,
        is_html => $message->is_html,
        style   => $message->scoped_template_style( '#notice_' . $message->message_id ),
        id      => $message->message_id,
        type    => $message->message_transport_type,
    };

    unless ( $types_seen->{ $message->message_transport_type } ) {
        push @scoped_styles, $message->scoped_style;
        $types_seen->{ $message->message_transport_type } = 1;
    }
}

$_->mark_as_printed for grep { $op eq 'cud-print' } @messages;

$template->param(
    notices    => \@notices,
    stylesheet => C4::Context->preference("AllNoticeStylesheet"),
    styles     => \@scoped_styles,
);

output_html_with_http_headers $input, $cookie, $template->output;
