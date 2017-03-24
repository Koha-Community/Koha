#!/usr/bin/perl
# Copyright 2016 KohaSuomi
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
use C4::Context;
use C4::Output;

use Koha::Payment::POS;

my $input = CGI->new();

my $updatecharges_permissions = $input->param('writeoff_individual') ? 'writeoff' : 'remaining_permissions';
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => 'members/paycollect.tt',
        query           => $input,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { borrowers => 1, updatecharges => $updatecharges_permissions },
        debug           => 1,
    }
);
if (Koha::Payment::POS::is_pos_integration_enabled(C4::Context::mybranch()) && $input->param('POSTDATA')) {
    my $payment = JSON->new->utf8->canonical(1)->decode($input->param('POSTDATA'));

    if ($payment->{send_payment} && $payment->{send_payment} eq "POST") {
        delete $payment->{send_payment};
        my $pos_payment = Koha::Payment::POS->new({ branch => C4::Context::mybranch() });
        output_ajax_with_http_headers $input, $pos_payment->send_payment($payment);
    }
} else {
    output_ajax_with_http_headers $input, "";
}
