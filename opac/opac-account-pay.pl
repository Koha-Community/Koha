#!/usr/bin/perl

# Copyright ByWater Solutions 2015
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use utf8;

use Modern::Perl;

use CGI;
use HTTP::Request::Common;
use LWP::UserAgent;
use URI;

use C4::Auth;
use C4::Output;
use C4::Context;
use Koha::Acquisition::Currencies;
use Koha::Database;

my $cgi = new CGI;

unless ( C4::Context->preference('EnablePayPalOpacPayments') ) {
    print $cgi->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-account-pay-error.tt",
        query           => $cgi,
        type            => "opac",
        authnotrequired => 0,
        debug           => 1,
    }
);

my $payment_method = $cgi->param('payment_method');
my @accountlines = $cgi->param('accountline');

my $amount_to_pay =
  Koha::Database->new()->schema()->resultset('Accountline')->search( { accountlines_id => { -in => \@accountlines } } )
  ->get_column('amountoutstanding')->sum();
$amount_to_pay = sprintf( "%.2f", $amount_to_pay );

my $active_currency = Koha::Acquisition::Currencies->get_active;

my $error = 0;
if ( $payment_method eq 'paypal' ) {
    my $ua = LWP::UserAgent->new;

    my $url =
      C4::Context->preference('PayPalSandboxMode')
      ? 'https://api-3t.sandbox.paypal.com/nvp'
      : 'https://api-3t.paypal.com/nvp';

    my $opac_base_url = C4::Context->preference('OPACBaseURL');

    my $return_url = URI->new( $opac_base_url . "/cgi-bin/koha/opac-account-pay-paypal-return.pl" );
    $return_url->query_form( { amount => $amount_to_pay, accountlines => \@accountlines } );

    my $cancel_url = URI->new( $opac_base_url . "/cgi-bin/koha/opac-account.pl" );

    my $nvp_params = {
        'USER'      => C4::Context->preference('PayPalUser'),
        'PWD'       => C4::Context->preference('PayPalPwd'),
        'SIGNATURE' => C4::Context->preference('PayPalSignature'),

        # API Version and Operation
        'METHOD'  => 'SetExpressCheckout',
        'VERSION' => '82.0',

        # API specifics for SetExpressCheckout
        'NOSHIPPING'                            => 1,
        'REQCONFIRMSHIPPING'                    => 0,
        'ALLOWNOTE'                             => 0,
        'BRANDNAME'                             => C4::Context->preference('LibraryName'),
        'CANCELURL'                             => $cancel_url->as_string(),
        'RETURNURL'                             => $return_url->as_string(),
        'PAYMENTREQUEST_0_CURRENCYCODE'         => $active_currency->currency,
        'PAYMENTREQUEST_0_AMT'                  => $amount_to_pay,
        'PAYMENTREQUEST_0_PAYMENTACTION'        => 'Sale',
        'PAYMENTREQUEST_0_ALLOWEDPAYMENTMETHOD' => 'InstantPaymentOnly',
        'PAYMENTREQUEST_0_DESC'                 => C4::Context->preference('PayPalChargeDescription'),
    };

    my $response = $ua->request( POST $url, $nvp_params );

    if ( $response->is_success ) {

        my $urlencoded = $response->content;
        my %params = URI->new( "?$urlencoded" )->query_form;

        if ( $params{ACK} eq "Success" ) {
            my $token = $params{TOKEN};

            my $redirect_url =
              C4::Context->preference('PayPalSandboxMode')
              ? "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token="
              : "https://www.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=";
            print $cgi->redirect( $redirect_url . $token );

        }
        else {
            $template->param( error => "PAYPAL_ERROR_PROCESSING" );
            $error = 1;
        }

    }
    else {
        $template->param( error => "PAYPAL_UNABLE_TO_CONNECT" );
        $error = 1;
    }
}

output_html_with_http_headers( $cgi, $cookie, $template->output ) if $error;
