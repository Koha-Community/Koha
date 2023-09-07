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
use JSON qw( from_json );

use C4::Auth qw( get_session get_template_and_user );
use C4::Context;
use C4::Letters qw( GetPreparedLetter EnqueueLetter SendQueuedMessages );
use C4::Output  qw( output_html_with_http_headers );

use Koha::Account::DebitTypes;
use Koha::AuthorisedValues;
use Koha::Cash::Registers;
use Koha::Charges::Sales;
use Koha::Database;
use Koha::Libraries;

my $input     = CGI->new();
my $sessionID = $input->cookie('CGISESSID');
my $session   = get_session($sessionID);

my ( $template, $loggedinuser, $cookie, $user_flags ) = get_template_and_user(
    {
        template_name => 'pos/pay.tt',
        query         => $input,
        type          => 'intranet',
        flagsrequired => { cash_management => 'takepayment' },
    }
);
my $logged_in_user = Koha::Patrons->find($loggedinuser) or die "Not logged in";

my $library_id = C4::Context->userenv->{'branch'};
my $registerid = $input->param('registerid');
my $action     = $input->param('action') || '';

my $invoice_types =
  Koha::Account::DebitTypes->search_with_library_limits(
    { can_be_sold => 1, archived => 0 },
    {}, $library_id );
$template->param( invoice_types => $invoice_types );

my $total_paid = $input->param('paid');
if ( $total_paid and $total_paid ne '0.00' ) {
    my $cash_register = Koha::Cash::Registers->find( { id => $registerid } );
    my $payment_type  = $input->param('payment_type');
    my $sale          = Koha::Charges::Sales->new(
        {
            cash_register => $cash_register,
            staff_id      => $logged_in_user->id
        }
    );

    my @sales = $input->multi_param('sales');
    for my $item (@sales) {
        $item = from_json $item;
        $sale->add_item($item);
    }

    my $payment = $sale->purchase( { payment_type => $payment_type } );

    $template->param(
        payment_id => $payment->accountlines_id,
        collected  => scalar $input->param('collected'),
        change     => scalar $input->param('change')
    );
}

if ( $action eq 'send' ) {
    my $payment_id = $input->param('payment_id');
    my $change     = $input->param('change');
    my $collected  = $input->param('collected');
    my $toaddr     = $input->param('toaddr');

    # Create our letter from the template
    my $letter = GetPreparedLetter(
        module                 => 'pos',
        letter_code            => 'RECEIPT',
        branchcode             => C4::Context->userenv->{'branch'},
        message_transport_type => 'email',
        tables                 => {
            credits => $payment_id,
        },
        substitute => {
            collected => $collected,
            change    => $change
        }
    );

    # Add letter to the queue
    my $message_id = EnqueueLetter(
        {
            letter                 => $letter,
            message_transport_type => 'email',
            from_address => C4::Context->preference('KohaAdminEmailAddress'),
            to_address   => $toaddr,
        }
    );

    # Send immediately
    SendQueuedMessages( { message_id => $message_id } ) if $message_id;

    # Set variables for template to allow printing still
    $template->param(
        payment_id => $payment_id,
        collected  => $collected,
        change     => $change
    );
}

output_html_with_http_headers( $input, $cookie, $template->output );

1;
