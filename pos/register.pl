#!/usr/bin/perl

# Copyright 2020 PTFS-Europe Ltd
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
use CGI;
use C4::Auth;
use C4::Output;
use C4::Context;

use Koha::Cash::Registers;
use Koha::Database;

my $input = CGI->new();

my ( $template, $loggedinuser, $cookie, $user_flags ) = get_template_and_user(
    {
        template_name   => 'pos/register.tt',
        query           => $input,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { cash_management => [ 'cashup', 'anonymous_refund' ] },
    }
);
my $logged_in_user = Koha::Patrons->find($loggedinuser) or die "Not logged in";

my $library_id = C4::Context->userenv->{'branch'};
my $registerid = $input->param('registerid');
my $registers  = Koha::Cash::Registers->search(
    { branch   => $library_id, archived => 0 },
    { order_by => { '-asc' => 'name' } }
);

if ( !$registers->count ) {
    $template->param( error_registers => 1 );
}
else {
    if ( !$registerid ) {
        my $default_register = Koha::Cash::Registers->find(
            { branch => $library_id, branch_default => 1 } );
        $registerid = $default_register->id if $default_register;
    }
    $registerid = $registers->next->id if !$registerid;

    $template->param(
        registerid => $registerid,
        registers  => $registers,
    );

    my $cash_register = Koha::Cash::Registers->find( { id => $registerid } );
    my $accountlines = $cash_register->outstanding_accountlines();
    $template->param(
        register     => $cash_register,
        accountlines => $accountlines
    );

    my $op = $input->param('op') // '';
    if ( $op eq 'cashup' ) {
        $cash_register->add_cashup(
            {
                manager_id => $logged_in_user->id,
                amount     => $cash_register->outstanding_accountlines->total
            }
        );
    }
}

output_html_with_http_headers( $input, $cookie, $template->output );
