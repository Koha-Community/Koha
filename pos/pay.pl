#!/usr/bin/perl

use Modern::Perl;

use CGI;
use JSON qw( from_json );

use C4::Auth qw/:DEFAULT get_session/;
use C4::Output;
use C4::Context;

use Koha::Account::DebitTypes;
use Koha::AuthorisedValues;
use Koha::Cash::Registers;
use Koha::Charges::Sales;
use Koha::Database;
use Koha::Libraries;

my $q         = CGI->new();
my $sessionID = $q->cookie('CGISESSID');
my $session   = get_session($sessionID);

my ( $template, $loggedinuser, $cookie, $user_flags ) = get_template_and_user(
    {
        template_name   => 'pos/pay.tt',
        query           => $q,
        type            => 'intranet',
        authnotrequired => 0,
    }
);
my $logged_in_user = Koha::Patrons->find($loggedinuser) or die "Not logged in";

my $library_id = C4::Context->userenv->{'branch'};
my $registerid = $q->param('registerid');
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

my $invoice_types =
  Koha::Account::DebitTypes->search_with_library_limits(
    { can_be_sold => 1 },
    {}, $library_id );
$template->param( invoice_types => $invoice_types );

my $total_paid = $q->param('paid');
if ( $total_paid and $total_paid ne '0.00' ) {
    my $cash_register = Koha::Cash::Registers->find( { id => $registerid } );
    my $payment_type  = $q->param('payment_type');
    my $sale          = Koha::Charges::Sales->new(
        {
            cash_register => $cash_register,
            staff_id      => $logged_in_user->id
        }
    );

    my @sales = $q->multi_param('sales');
    for my $item (@sales) {
        $item = from_json $item;
        $sale->add_item($item);
    }

    my $payment = $sale->purchase( { payment_type => $payment_type } );

    $template->param(
        payment_id => $payment->accountlines_id,
        collected  => scalar $q->param('collected'),
        change     => scalar $q->param('change')
    );
}

output_html_with_http_headers( $q, $cookie, $template->output );

1;
