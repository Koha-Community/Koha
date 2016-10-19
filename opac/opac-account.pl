#!/usr/bin/perl

# Copyright Katipo Communications 2002
# Copyright Biblibre 2007,2010
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


use strict;
use CGI qw ( -utf8 );
use C4::Members;
use C4::Auth;
use C4::Output;
use warnings;

use Koha::Acquisition::Currencies;
use Koha::Payment::Online;
use Koha::Vetuma::Config;
use Koha::Vetuma::Message;

my $query = new CGI;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-account.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => 0,
        debug           => 1,
    }
);

my $borrower = C4::Members::GetMember( borrowernumber => $borrowernumber );
$template->param( BORROWER_INFO => $borrower );

#get account details
my ( $total , $accts, $numaccts) = GetMemberAccountRecords( $borrowernumber );

for ( my $i = 0 ; $i < $numaccts ; $i++ ) {
    $accts->[$i]{'amount'} = sprintf( "%.2f", $accts->[$i]{'amount'} || '0.00');
    if ( $accts->[$i]{'amount'} >= 0 ) {
        $accts->[$i]{'amountcredit'} = 1;
    }
    $accts->[$i]{'amountoutstanding'} =
      sprintf( "%.2f", $accts->[$i]{'amountoutstanding'} || '0.00' );
    if ( $accts->[$i]{'amountoutstanding'} >= 0 ) {
        $accts->[$i]{'amountoutstandingcredit'} = 1;
    }
}

# add the row parity
my $num = 0;
foreach my $row (@$accts) {
    $row->{'even'} = 1 if $num % 2 == 0;
    $row->{'odd'}  = 1 if $num % 2 == 1;
    $num++;
}

# Vetuma on-line payments related stuff KD#1446 (if Vetuma is configured, use it)

my $vetumaConfig = Koha::Vetuma::Config->new()->loadConfigXml();

# minAmount is replaced with C4::Context->preference("OnlinePaymentsMinTotal")

# my $minAmount = 0;
# if(defined $vetumaConfig->{settings}->{min_amount} && $vetumaConfig->{settings}->{min_amount} > 0){
#    $minAmount = $vetumaConfig->{settings}->{min_amount};
# }

if (defined $vetumaConfig->{settings}->{request_url}) {
  my $messages = Koha::Vetuma::Message->new();
  $messages->setSession($query->cookie("CGISESSID"));
  my $messagesJson = $messages->getMessages();
  $template->param (
    messages_json => $messagesJson,
    vetuma_enabled => 1
  );
}

# Vetuma stuff ends.


$template->param(
    ACCOUNT_LINES => $accts,
    total         => sprintf( "%.2f", $total ),
    accountview   => 1,
    currency => Koha::Acquisition::Currencies->get_active->symbol,
    online_payments_enabled => Koha::Payment::Online::is_online_payment_enabled(C4::Context::mybranch()),
    minimumSum => C4::Context->preference("OnlinePaymentMinTotal"),
    message       => scalar $query->param('message') || q{},
    message_value => scalar $query->param('message_value') || q{},
    payment       => scalar $query->param('payment') || q{},
    payment_error => scalar $query->param('payment-error') || q{},
);

output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
