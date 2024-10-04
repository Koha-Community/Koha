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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use C4::Auth   qw( get_template_and_user );

my $input = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "circ/printslip.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { tools => 'view_generated_notices' },
    }
);

my @message_ids = $input->multi_param('message_ids');
my @slips;
foreach my $message_id (@message_ids) {
    my $message  = Koha::Notice::Messages->find($message_id);
    my $template = $message->template;

    push @slips, {
        content => $message->content,
        is_html => $message->is_html,
        style   => $template ? $template->style : undef,
        id      => $message_id,
    };

    $message->update( { status => 'sent' } );
}
$template->param(
    slips                 => \@slips,
    caller                => 'notice_mgmt',
    stylesheet            => C4::Context->preference("SlipCSS"),
    IntranetSlipPrinterJS => C4::Context->preference('IntranetSlipPrinterJS'),
);

output_html_with_http_headers $input, $cookie, $template->output;
