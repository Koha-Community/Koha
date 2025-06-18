#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2017 ByWater Solutions
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

use CGI        qw ( -utf8 );
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Context;
use Koha::Patrons;
use Koha::Account::Lines;

my $input = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "members/accountline-details.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => {
            borrowers     => 'edit_borrowers',
            updatecharges => 'remaining_permissions'
        },
    }
);

my $accountlines_id = $input->param('accountlines_id');

my $accountline = Koha::Account::Lines->find($accountlines_id);

if ($accountline) {
    my $account_offsets = Koha::Account::Offsets->search(
        [
            { credit_id => $accountline->accountlines_id },
            { debit_id  => $accountline->accountlines_id }
        ],
        { order_by => 'created_on' }
    );

    $template->param(
        accountline                 => $accountline,
        account_offsets             => $account_offsets,
        additional_field_values     => $accountline->get_additional_field_values_for_template,
        available_additional_fields => Koha::AdditionalFields->search(
            { tablename => $accountline->credit_type_code ? 'accountlines:credit' : 'accountlines:debit' }
        ),
        finesview => 1,
    );

    my $patron = Koha::Patrons->find( $accountline->borrowernumber );
    $template->param( patron => $patron );
}

output_html_with_http_headers $input, $cookie, $template->output;
