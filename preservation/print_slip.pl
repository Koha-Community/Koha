#!/usr/bin/perl

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
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_and_exit_if_error output_and_exit output_html_with_http_headers );
use C4::Letters;
use Koha::Patrons;
use Koha::Preservation::Train::Items;

my $input          = CGI->new;
my @train_item_ids = $input->multi_param('train_item_id');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "circ/printslip.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { preservation => '*' },
    }
);

my $logged_in_user = Koha::Patrons->find($loggedinuser);
my $branch         = C4::Context->userenv->{'branch'};

my @slips;
my $count = 0;
for my $train_item_id (@train_item_ids) {
    my $train_item = Koha::Preservation::Train::Items->find($train_item_id);
    my $letter     = C4::Letters::GetPreparedLetter(
        module      => 'preservation',
        letter_code => $train_item->processing->letter_code,
        branchcode  => $branch,
        lang        => $logged_in_user->lang,
        tables      => {
            preservation_train_items => $train_item_id,
        },
        message_transport_type => 'print'
    );
    push @slips, {
        content => $letter->{content},
        is_html => $letter->{is_html},
        style   => $letter->{style},
        id      => ++$count,
    };
}

$template->param(
    slips      => \@slips,
    caller     => 'preservation',
    stylesheet => C4::Context->preference("SlipCSS"),
);

$template->param( IntranetSlipPrinterJS => C4::Context->preference('IntranetSlipPrinterJS') );

output_html_with_http_headers $input, $cookie, $template->output;
