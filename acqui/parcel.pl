#!/usr/bin/perl

#script to receive orders


# Copyright 2000-2002 Katipo Communications
# Copyright 2008-2009 BibLibre SARL
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

=head1 NAME

parcel.pl

=head1 DESCRIPTION

This script shows all orders receipt or pending for a given supplier.
It allows to write an order as 'received' when it arrives.

=head1 CGI PARAMETERS

=over 4

=item booksellerid

To know the supplier this script has to show orders.

=item code

is the bookseller invoice number.


=item gst


=item datereceived

To filter the results list on this given date.

=back

=cut

use strict;
use warnings;

use C4::Auth;
use C4::Acquisition;
use C4::Budgets;
use C4::Biblio;
use C4::Items;
use CGI qw ( -utf8 );
use C4::Output;
use C4::Suggestions;

use Koha::Acquisition::Bookseller;
use Koha::Biblios;
use Koha::DateUtils;
use Koha::Biblios;

use JSON;

my $input=new CGI;
my $sticky_filters = $input->param('sticky_filters') || 0;

my $summaryfilter = $input->param('summaryfilter') || '';
my $basketfilter = $input->param('basketfilter') || '';
my $basketgroupnamefilter = $input->param('basketgroupnamefilter') || '';
my $orderfilter = $input->param('orderfilter') || '';
my $eanfilter = $input->param('eanfilter') || '';

if ($sticky_filters) {
    $summaryfilter = $input->cookie('summaryfilter') || '';
    $basketfilter = $input->cookie('basketfilter') || '';
    $basketgroupnamefilter = $input->cookie('basketgroupnamefilter') || '';
    $orderfilter = $input->cookie('orderfilter') || '';
    $eanfilter = $input->cookie('eanfilter') || '';
}

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui/parcel.tt",
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {acquisition => 'order_receive'},
                 debug => 1,
});

my $op = $input->param('op') // '';

# process cancellation first so that list of
# orders to display is calculated after
if ($op eq 'cancelreceipt') {
    my $ordernumber = $input->param('ordernumber');
    my $parent_ordernumber = CancelReceipt($ordernumber);
    unless($parent_ordernumber) {
        $template->param(error_cancelling_receipt => 1);
    }
}

my $invoiceid = $input->param('invoiceid');
my $invoice;
$invoice = GetInvoiceDetails($invoiceid) if $invoiceid;

unless( $invoiceid and $invoice->{invoiceid} ) {
    $template->param(
        error_invoice_not_known => 1,
        no_orders_to_display    => 1
    );
    output_html_with_http_headers $input, $cookie, $template->output;
    exit;
}

my $booksellerid = $invoice->{booksellerid};
my $bookseller = Koha::Acquisition::Booksellers->find( $booksellerid );

my @orders        = @{ $invoice->{orders} };
my $countlines    = scalar @orders;
my @loop_received = ();
my @book_foot_loop;
my %foot;
my $total_tax_excluded = 0;
my $total_tax_included = 0;

my $subtotal_for_funds;
for my $order ( @orders ) {
    $order->{'unitprice'} += 0;

    if ( $bookseller->invoiceincgst ) {
        $order->{ecost}     = $order->{ecost_tax_included};
        $order->{unitprice} = $order->{unitprice_tax_included};
    }
    else {
        $order->{ecost}     = $order->{ecost_tax_excluded};
        $order->{unitprice} = $order->{unitprice_tax_excluded};
    }

    $order->{total} = $order->{unitprice} * $order->{quantity};

    my %line = %{ $order };
    $line{invoice} = $invoice->{invoicenumber};
    $line{holds} = 0;
    my @itemnumbers = GetItemnumbersFromOrder( $order->{ordernumber} );
    my $biblio = Koha::Biblios->find( $line{biblionumber} );
    $line{holds} = $biblio ? $biblio->current_holds->search(
        {
            itemnumber => { -in => \@itemnumbers },
        }
    )->count : 0;
    $line{budget} = GetBudgetByOrderNumber( $line{ordernumber} );

    $line{tax_value} = $line{tax_value_on_receiving};
    $line{tax_rate} = $line{tax_rate_on_receiving};
    $foot{$line{tax_rate}}{tax_rate} = $line{tax_rate};
    $foot{$line{tax_rate}}{tax_value} += $line{tax_value};
    $total_tax_excluded += $line{unitprice_tax_excluded} * $line{quantity};
    $total_tax_included += $line{unitprice_tax_included} * $line{quantity};

    my $suggestion   = GetSuggestionInfoFromBiblionumber($line{biblionumber});
    $line{suggestionid}         = $suggestion->{suggestionid};
    $line{surnamesuggestedby}   = $suggestion->{surnamesuggestedby};
    $line{firstnamesuggestedby} = $suggestion->{firstnamesuggestedby};

    if ( $line{parent_ordernumber} != $line{ordernumber} ) {
        if ( grep { $_->{ordernumber} == $line{parent_ordernumber} }
            @orders
            )
        {
            $line{cannot_cancel} = 1;
        }
    }

    my $budget_name = GetBudgetName( $line{budget_id} );
    $line{budget_name} = $budget_name;

    $subtotal_for_funds->{ $line{budget_name} }{ecost} += $order->{ecost} * $order->{quantity};
    $subtotal_for_funds->{ $line{budget_name} }{unitprice} += $order->{total};

    push @loop_received, \%line;
}
push @book_foot_loop, map { $_ } values %foot;

$template->param(
    invoiceid             => $invoice->{invoiceid},
    invoice               => $invoice->{invoicenumber},
    invoiceclosedate      => $invoice->{closedate},
    datereceived          => dt_from_string,
    name                  => $bookseller->name,
    booksellerid          => $bookseller->id,
    loop_received         => \@loop_received,
    book_foot_loop        => \@book_foot_loop,
    (uc(C4::Context->preference("marcflavour"))) => 1,
    total_tax_excluded    => $total_tax_excluded,
    total_tax_included    => $total_tax_included,
    subtotal_for_funds    => $subtotal_for_funds,
    sticky_filters       => $sticky_filters,
    summaryfilter         => $summaryfilter,
    basketfilter          => $basketfilter,
    basketgroupnamefilter => $basketgroupnamefilter,
    orderfilter           => $orderfilter,
    eanfilter             => $eanfilter,
);
output_html_with_http_headers $input, $cookie, $template->output;
