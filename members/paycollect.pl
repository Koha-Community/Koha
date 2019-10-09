#!/usr/bin/perl
# Copyright 2009,2010 PTFS Inc.
# Copyright 2011 PTFS-Europe Ltd
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
use URI::Escape;
use CGI qw ( -utf8 );

use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Members;
use C4::Accounts;
use C4::Koha;

use Koha::Cash::Registers;
use Koha::Patrons;
use Koha::Patron::Categories;
use Koha::AuthorisedValues;
use Koha::Account;
use Koha::Token;

my $input = CGI->new();

my $payment_id          = $input->param('payment_id');
my $writeoff_individual = $input->param('writeoff_individual');
my $change_given        = $input->param('change_given');
my $type                = scalar $input->param('type') || 'PAYMENT';

my $updatecharges_permissions = ($writeoff_individual || $type eq 'writeoff') ? 'writeoff' : 'remaining_permissions';
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => 'members/paycollect.tt',
        query           => $input,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { borrowers => 'edit_borrowers', updatecharges => $updatecharges_permissions },
        debug           => 1,
    }
);

# get borrower details
my $borrowernumber = $input->param('borrowernumber');
my $logged_in_user = Koha::Patrons->find( $loggedinuser ) or die "Not logged in";
my $patron         = Koha::Patrons->find( $borrowernumber );
output_and_exit_if_error( $input, $cookie, $template, { module => 'members', logged_in_user => $logged_in_user, current_patron => $patron } );

my $borrower       = $patron->unblessed;
my $account        = $patron->account;
my $category       = $patron->category;
my $user           = $input->remote_user;

my $library_id = C4::Context->userenv->{'branch'};
my $total_due  = $account->outstanding_debits->total_outstanding;

my $total_paid = $input->param('paid');

my $select_lines = $input->param('selected');
my $pay_individual   = $input->param('pay_individual');
my $selected_accts   = $input->param('selected_accts');
my $payment_note = uri_unescape scalar $input->param('payment_note');
my $payment_type = scalar $input->param('payment_type');
my $accountlines_id;

my $registerid;
if ( C4::Context->preference('UseCashRegisters') ) {
    $registerid = $input->param('registerid');
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
    }
}

if ( $pay_individual || $writeoff_individual ) {
    if ($pay_individual) {
        $template->param( pay_individual => 1 );
    } elsif ($writeoff_individual) {
        $template->param( writeoff_individual => 1 );
    }
    my $debit_type_code   = $input->param('debit_type_code');
    $accountlines_id      = $input->param('accountlines_id');
    my $amount            = $input->param('amount');
    my $amountoutstanding = $input->param('amountoutstanding');
    my $itemnumber  = $input->param('itemnumber');
    my $description  = $input->param('description');
    my $title        = $input->param('title');
    $total_due = $amountoutstanding;
    $template->param(
        debit_type_code    => $debit_type_code,
        accountlines_id    => $accountlines_id,
        amount            => $amount,
        amountoutstanding => $amountoutstanding,
        title             => $title,
        itemnumber        => $itemnumber,
        individual_description => $description,
        payment_note    => $payment_note,
    );
} elsif ($select_lines) {
    $total_due = $input->param('amt');
    $template->param(
        selected_accts => $select_lines,
        amt            => $total_due,
        selected_accts_notes => scalar $input->param('notes'),
    );
}

if ( $total_paid and $total_paid ne '0.00' ) {
    $total_paid = $total_due if (abs($total_paid - $total_due) < 0.01) && C4::Context->preference('RoundFinesAtPayment');
    if ( $total_paid < 0 or $total_paid > $total_due ) {
        $template->param(
            error_over => 1,
            total_due => $total_due
        );
    } else {
        output_and_exit( $input, $cookie, $template,  'wrong_csrf_token' )
            unless Koha::Token->new->check_csrf( {
                session_id => $input->cookie('CGISESSID'),
                token  => scalar $input->param('csrf_token'),
            });

        if ($pay_individual) {
            my $line = Koha::Account::Lines->find($accountlines_id);
            $payment_id = $account->pay(
                {
                    lines        => [$line],
                    amount       => $total_paid,
                    library_id   => $library_id,
                    note         => $payment_note,
                    interface    => C4::Context->interface,
                    payment_type => $payment_type,
                    cash_register => $registerid
                }
            );
            print $input->redirect(
                "/cgi-bin/koha/members/pay.pl?borrowernumber=$borrowernumber&payment_id=$payment_id&change_given=$change_given");
        } else {
            if ($selected_accts) {
                if ( $selected_accts =~ /^([\d,]*).*/ ) {
                    $selected_accts = $1;    # ensure passing no junk
                }
                my @acc = split /,/, $selected_accts;
                my $note = $input->param('selected_accts_notes');

                my @lines = Koha::Account::Lines->search(
                    {
                        borrowernumber    => $borrowernumber,
                        amountoutstanding => { '<>' => 0 },
                        accountlines_id   => { 'IN' => \@acc },
                    },
                    { order_by => 'date' }
                );

                $payment_id = $account->pay(
                    {
                        type         => $type,
                        amount       => $total_paid,
                        library_id   => $library_id,
                        lines        => \@lines,
                        note         => $note,
                        interface    => C4::Context->interface,
                        payment_type => $payment_type,
                        cash_register => $registerid
                    }
                  );
            }
            else {
                my $note = $input->param('selected_accts_notes');
                $payment_id = $account->pay(
                    {
                        amount       => $total_paid,
                        library_id   => $library_id,
                        note         => $note,
                        payment_type => $payment_type,
                        interface    => C4::Context->interface,
                        payment_type => $payment_type,
                        cash_register => $registerid
                    }
                );
            }

            print $input->redirect("/cgi-bin/koha/members/boraccount.pl?borrowernumber=$borrowernumber&payment_id=$payment_id&change_given=$change_given");
        }
    }
} else {
    $total_paid = '0.00';    #TODO not right with pay_individual
}

$template->param(%$borrower);

if ( $input->param('error_over') ) {
    $template->param( error_over => 1, total_due => scalar $input->param('amountoutstanding') );
}

$template->param(
    payment_id => $payment_id,

    type           => $type,
    borrowernumber => $borrowernumber,    # some templates require global
    patron         => $patron,
    total          => $total_due,

    csrf_token => Koha::Token->new->generate_csrf( { session_id => scalar $input->cookie('CGISESSID') } ),
);

output_html_with_http_headers $input, $cookie, $template->output;
