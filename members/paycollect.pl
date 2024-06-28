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
use URI::Escape qw( uri_escape uri_unescape );
use CGI         qw ( -utf8 );

use C4::Context;
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_and_exit_if_error output_and_exit output_html_with_http_headers );
use C4::Accounts;
use C4::Koha;

use Koha::Cash::Registers;
use Koha::Patrons;
use Koha::Patron::Categories;
use Koha::AuthorisedValues;
use Koha::Account;
use Koha::Account::Lines;
use Koha::AdditionalFields;
use Koha::DateUtils qw( output_pref );

my $input = CGI->new();

my $payment_id          = $input->param('payment_id');
my $writeoff_individual = $input->param('writeoff_individual');
my $change_given        = $input->param('change_given');
my $type                = scalar $input->param('type') || 'PAYMENT';

# get operation
my $op = $input->param('op') // qw{};

my $updatecharges_permissions = ( $writeoff_individual || $type eq 'WRITEOFF' ) ? 'writeoff' : 'remaining_permissions';
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => 'members/paycollect.tt',
        query         => $input,
        type          => 'intranet',
        flagsrequired => { borrowers => 'edit_borrowers', updatecharges => $updatecharges_permissions },
    }
);

# get borrower details
my $borrowernumber = $input->param('borrowernumber');
my $logged_in_user = Koha::Patrons->find($loggedinuser);
my $patron         = Koha::Patrons->find($borrowernumber);
output_and_exit_if_error(
    $input, $cookie, $template,
    { module => 'members', logged_in_user => $logged_in_user, current_patron => $patron }
);

my $account  = $patron->account;
my $category = $patron->category;
my $user     = $input->remote_user;

my $library_id = C4::Context->userenv->{'branch'};
my $total_due  = $account->outstanding_debits->total_outstanding;

my $total_paid      = $input->param('paid');
my $total_collected = $input->param('collected');

my $selected_lines = $input->param('selected');                           # comes from pay.pl
my $pay_individual = $input->param('pay_individual');
my $selected_accts = $input->param('selected_accts');                     # comes from paycollect.pl
my $payment_note   = uri_unescape scalar $input->param('payment_note');
my $payment_type   = scalar $input->param('payment_type');
my $accountlines_id;

my $cash_register_id = $input->param('cash_register');
if ( $pay_individual || $writeoff_individual ) {
    if ($pay_individual) {
        $template->param( pay_individual => 1 );
    } elsif ($writeoff_individual) {
        $template->param( writeoff_individual => 1 );
    }
    my $debit_type_code = $input->param('debit_type_code');
    $accountlines_id = $input->param('accountlines_id');
    my $amount            = $input->param('amount');
    my $amountoutstanding = $input->param('amountoutstanding');
    my $itemnumber        = $input->param('itemnumber');
    my $description       = $input->param('description');
    $total_due = $amountoutstanding;
    $template->param(
        debit_type_code        => $debit_type_code,
        accountlines_id        => $accountlines_id,
        amount                 => $amount,
        amountoutstanding      => $amountoutstanding,
        itemnumber             => $itemnumber,
        individual_description => $description,
        payment_note           => $payment_note,
    );
} elsif ($selected_lines) {
    $total_due = $input->param('amt');
    $template->param(
        selected_accts       => $selected_lines,
        amt                  => $total_due,
        selected_accts_notes => scalar $input->param('notes'),
    );
}

my @selected_accountlines;
if ($selected_accts) {
    if ( $selected_accts =~ /^([\d,]*).*/ ) {
        $selected_accts = $1;    # ensure passing no junk
    }
    my @acc = split /,/, $selected_accts;

    my $search_params = {
        borrowernumber    => $borrowernumber,
        amountoutstanding => { '<>' => 0 },
        accountlines_id   => { 'in' => \@acc },
    };

    @selected_accountlines = Koha::Account::Lines->search(
        $search_params,
        { order_by => 'date' }
    )->as_list;

    my $sum = Koha::Account::Lines->search(
        $search_params,
        {
            select => [ { sum => 'amountoutstanding' } ],
            as     => ['total_amountoutstanding'],
        }
    );
    $total_due = $sum->_resultset->first->get_column('total_amountoutstanding');
}

if ( $total_paid and $total_paid ne '0.00' ) {
    $accountlines_id = $input->param('accountlines_id');
    $total_paid      = $total_due
        if ( abs( $total_paid - $total_due ) < 0.01 ) && C4::Context->preference('RoundFinesAtPayment');
    if ( $total_paid < 0 or $total_paid > $total_due ) {
        $template->param(
            error_over => 1,
            total_due  => $total_due
        );
    } elsif ( $total_collected < $total_paid && !( $op eq 'cud-writeoff_individual' || $type eq 'WRITEOFF' ) ) {
        $template->param(
            error_under => 1,
            total_paid  => $total_paid
        );
    } else {
        my $url;
        my $pay_result;
        if ( $op eq 'cud-pay_individual' ) {
            my $line = Koha::Account::Lines->find($accountlines_id);
            $pay_result = $account->pay(
                {
                    type          => $type,
                    lines         => [$line],
                    amount        => $total_paid,
                    library_id    => $library_id,
                    note          => $payment_note,
                    interface     => C4::Context->interface,
                    payment_type  => $payment_type,
                    cash_register => $cash_register_id
                }
            );
            $payment_id = $pay_result->{payment_id};

            my $payment           = Koha::Account::Lines->find($payment_id);
            my @additional_fields = $payment->prepare_cgi_additional_field_values( $input, 'accountlines:credit' );
            if (@additional_fields) {
                $payment->set_additional_fields( \@additional_fields );
            }

            $url = "/cgi-bin/koha/members/pay.pl";
        } elsif ( $op eq 'cud-writeoff_individual' ) {
            my $item_id      = $input->param('itemnumber');
            my $payment_note = $input->param("payment_note");

            my $accountline = Koha::Account::Lines->find($accountlines_id);
            $pay_result = $account->pay(
                {
                    type       => 'WRITEOFF',
                    amount     => $total_paid,
                    lines      => [$accountline],
                    note       => $payment_note,
                    interface  => C4::Context->interface,
                    item_id    => $item_id,
                    library_id => $library_id,
                }
            );
            $payment_id = $pay_result->{payment_id};

            $url = "/cgi-bin/koha/members/pay.pl";
        } elsif ( $op eq 'cud-pay' || $op eq 'cud-writeoff' ) {
            if ($selected_accts) {
                if ( $total_paid > $total_due ) {
                    $template->param(
                        error_over => 1,
                        total_due  => $total_due
                    );
                } else {
                    my $note = $input->param('selected_accts_notes');

                    $pay_result = $account->pay(
                        {
                            type          => $type,
                            amount        => $total_paid,
                            library_id    => $library_id,
                            lines         => \@selected_accountlines,
                            note          => $note,
                            interface     => C4::Context->interface,
                            payment_type  => $payment_type,
                            cash_register => $cash_register_id
                        }
                    );
                }
                $payment_id = $pay_result->{payment_id};
            } else {
                my $note = $input->param('selected_accts_notes');
                $pay_result = $account->pay(
                    {
                        amount        => $total_paid,
                        library_id    => $library_id,
                        note          => $note,
                        payment_type  => $payment_type,
                        interface     => C4::Context->interface,
                        payment_type  => $payment_type,
                        cash_register => $cash_register_id
                    }
                );
                $payment_id = $pay_result->{payment_id};
            }
            $payment_id = $pay_result->{payment_id};

            my $payment           = Koha::Account::Lines->find($payment_id);
            my @additional_fields = $payment->prepare_cgi_additional_field_values( $input, 'accountlines:credit' );
            if (@additional_fields) {
                $payment->set_additional_fields( \@additional_fields );
            }

            $url = "/cgi-bin/koha/members/boraccount.pl";
        }

        # It's possible renewals took place, parse any renew results
        # and pass on
        my @renew_result = ();
        foreach my $ren ( @{ $pay_result->{renew_result} } ) {
            my $str = "renew_result=$ren->{itemnumber},$ren->{success},";
            my $app =
                $ren->{success}
                ? uri_escape( output_pref( { dt => $ren->{due_date}, as_due_date => 1 } ) )
                : $ren->{error};
            push @renew_result, "${str}${app}";
        }
        my $append = scalar @renew_result ? '&' . join( '&', @renew_result ) : '';

        $url .= "?borrowernumber=$borrowernumber&payment_id=$payment_id&change_given=${change_given}${append}";

        print $input->redirect($url);
    }
} else {
    $total_paid = '0.00';    #TODO not right with pay_individual
}

if ( $input->param('error_over') ) {
    $template->param( error_over => 1, total_due => scalar $input->param('amountoutstanding') );
}

$template->param(
    finesview                   => 1,
    payment_id                  => $payment_id,
    type                        => $type,
    borrowernumber              => $borrowernumber,    # some templates require global
    patron                      => $patron,
    total                       => $total_due,
    available_additional_fields =>
        [ Koha::AdditionalFields->search( { tablename => 'accountlines:credit' } )->as_list ],
);

output_html_with_http_headers $input, $cookie, $template->output;
