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

use Koha::Account::Lines;
use Koha::Cash::Registers;
use Koha::Database;
use Koha::DateUtils;

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
my $schema = Koha::Database->new->schema;

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

    my $transactions_range_from = $input->param('trange_f');
    my $last_cashup             = $cash_register->last_cashup;
    my $transactions_range_to =
        $input->param('trange_t') ? $input->param('trange_t')
      : $last_cashup              ? $last_cashup->timestamp
      :                             '';
    my $end               = dt_from_string($transactions_range_to);

    if ($transactions_range_from) {

        my $dtf               = $schema->storage->datetime_parser;
        my $start             = dt_from_string($transactions_range_from);
        my $past_accountlines = Koha::Account::Lines->search(
            {
                register_id => $registerid,
                timestamp   => {
                    -between => [
                        $dtf->format_datetime($start),
                        $dtf->format_datetime($end)
                    ]
                }
            }
        );
        $template->param( past_accountlines => $past_accountlines );
        $template->param( trange_f => output_pref({dt => $start, dateonly => 1}));
    }
    $template->param( trange_t => output_pref({dt => $end, dateonly => 1}));

    my $op = $input->param('op') // '';
    if ( $op eq 'cashup' ) {
        if ( $logged_in_user->has_permission( { cash_management => 'cashup' } ) ) {
            $cash_register->add_cashup(
                {
                    manager_id => $logged_in_user->id,
                    amount     => $cash_register->outstanding_accountlines->total
                }
            );
        }
        else {
            $template->param( error_cashup_permission => 1 );
        }
    }
    elsif ( $op eq 'refund' ) {
        if ( $logged_in_user->has_permission( { cash_management => 'anonymous_refund' } ) ) {
            my $amount           = $input->param('amount');
            my $quantity         = $input->param('quantity');
            my $accountline_id   = $input->param('accountline');
            my $transaction_type = $input->param('transaction_type');

            my $accountline = Koha::Account::Lines->find($accountline_id);
            $schema->txn_do(
                sub {

                    my $refund = $accountline->reduce(
                        {
                            reduction_type => 'REFUND',
                            branch         => $library_id,
                            staff_id       => $logged_in_user->id,
                            interface      => 'intranet',
                            amount         => $amount
                        }
                    );
                    my $payout = $refund->payout(
                        {
                            payout_type   => $transaction_type,
                            branch        => $library_id,
                            staff_id      => $logged_in_user->id,
                            cash_register => $cash_register->id,
                            interface     => 'intranet',
                            amount        => $amount
                        }
                    );

                }
            );
        }
        else {
            $template->param( error_refund_permission => 1 );
        }
    }
}

output_html_with_http_headers( $input, $cookie, $template->output );
