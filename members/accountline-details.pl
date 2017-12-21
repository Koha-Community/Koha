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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use CGI;
use C4::Auth;
use C4::Output;
use C4::Context;
use Koha::Patrons;
use Koha::Account::Lines;

my $input = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "members/accountline-details.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => {
            borrowers     => 1,
            updatecharges => 'remaining_permissions'
        },
    }
);

my $accountlines_id = $input->param('accountlines_id');

my $accountline = Koha::Account::Lines->find($accountlines_id);

if ($accountline) {
    my $type = $accountline->amount < 0 ? 'credit' : 'debit';
    my $column = $type eq 'credit' ? 'credit_id' : 'debit_id';

    my @account_offsets = Koha::Account::Offsets->search( { $column => $accountlines_id } );

    $template->param(
        type            => $type,
        accountline     => $accountline,
        account_offsets => \@account_offsets,

        finesview => 1,
    );

    my $patron = Koha::Patrons->find( $accountline->borrowernumber );
    $template->param( patron => $patron );
}

output_html_with_http_headers $input, $cookie, $template->output;
