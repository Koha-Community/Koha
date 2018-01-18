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

use Modern::Perl;

use C4::Auth;
use C4::Acquisition;
use C4::Budgets;
use C4::Biblio;
use C4::Items;
use CGI qw ( -utf8 );
use C4::Output;
use C4::Suggestions;

use Koha::Acquisition::Baskets;
use Koha::Acquisition::Bookseller;
use Koha::Biblios;
use Koha::DateUtils;
use Koha::Biblios;

use JSON;

my $input=new CGI;
my $sticky_filters = $input->param('sticky_filters') || 0;

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

my @loop_orders = ();
unless( defined $invoice->{closedate} ) {
    my $pendingorders;
    if ( $op eq "search" or $sticky_filters ) {
        my ( $search, $ean, $basketname, $orderno, $basketgroupname );
        if ( $sticky_filters ) {
            $search = $input->cookie("filter_parcel_summary");
            $ean = $input->cookie("filter_parcel_ean");
            $basketname = $input->cookie("filter_parcel_basketname");
            $orderno = $input->cookie("filter_parcel_orderno");
            $basketgroupname = $input->cookie("filter_parcel_basketgroupname");
        } else {
            $search   = $input->param('summaryfilter') || '';
            $ean      = $input->param('eanfilter') || '';
            $basketname = $input->param('basketfilter') || '';
            $orderno  = $input->param('orderfilter') || '';
            $basketgroupname = $input->param('basketgroupnamefilter') || '';
        }
        $pendingorders = SearchOrders({
            booksellerid => $booksellerid,
            basketname => $basketname,
            ordernumber => $orderno,
            search => $search,
            ean => $ean,
            basketgroupname => $basketgroupname,
            pending => 1,
            ordered => 1,
        });
        $template->param(
            summaryfilter => $search,
            eanfilter => $ean,
            basketfilter => $basketname,
            orderfilter => $orderno,
            basketgroupnamefilter => $basketgroupname,
        );
    }else{
        $pendingorders = SearchOrders({
            booksellerid => $booksellerid,
            ordered => 1
        });
    }
    my $countpendings = scalar @$pendingorders;

    for (my $i = 0 ; $i < $countpendings ; $i++) {
        my $order = $pendingorders->[$i];

        if ( $bookseller->invoiceincgst ) {
            $order->{ecost} = $order->{ecost_tax_included};
        } else {
            $order->{ecost} = $order->{ecost_tax_excluded};
        }
        $order->{total} = $order->{ecost} * $order->{quantity};

        my %line = %$order;

        $line{invoice} = $invoice;
        $line{booksellerid} = $booksellerid;

        my $biblionumber = $line{'biblionumber'};
        my $biblio = Koha::Biblios->find( $biblionumber );
        my $countbiblio = CountBiblioInOrders($biblionumber);
        my $ordernumber = $line{'ordernumber'};
        my $cnt_subscriptions = $biblio ? $biblio->subscriptions->count: 0;
        my $itemcount   = $biblio ? $biblio->items->count : 0;
        my $holds_count = $biblio ? $biblio->holds->count : 0;
        my @items = GetItemnumbersFromOrder( $ordernumber );
        my $itemholds = $biblio ? $biblio->holds->search({ itemnumber => { -in => \@items } })->count : 0;

        my $suggestion   = GetSuggestionInfoFromBiblionumber($line{biblionumber});
        $line{suggestionid}         = $suggestion->{suggestionid};
        $line{surnamesuggestedby}   = $suggestion->{surnamesuggestedby};
        $line{firstnamesuggestedby} = $suggestion->{firstnamesuggestedby};

        # if the biblio is not in other orders and if there is no items elsewhere and no subscriptions and no holds we can then show the link "Delete order and Biblio" see bug 5680
        $line{can_del_bib}          = 1 if $countbiblio <= 1 && $itemcount == scalar @items && !($cnt_subscriptions) && !($holds_count);
        $line{items}                = ($itemcount) - (scalar @items);
        $line{left_item}            = 1 if $line{items} >= 1;
        $line{left_biblio}          = 1 if $countbiblio > 1;
        $line{biblios}              = $countbiblio - 1;
        $line{left_subscription}    = 1 if $cnt_subscriptions;
        $line{subscriptions}        = $cnt_subscriptions;
        $line{left_holds}           = ($holds_count >= 1) ? 1 : 0;
        $line{left_holds_on_order}  = 1 if $line{left_holds}==1 && ($line{items} == 0 || $itemholds );
        $line{holds}                = $holds_count;
        $line{holds_on_order}       = $itemholds?$itemholds:$holds_count if $line{left_holds_on_order};
        $line{basket}               = Koha::Acquisition::Baskets->find( $line{basketno} );

        my $budget_name = GetBudgetName( $line{budget_id} );
        $line{budget_name} = $budget_name;

        push @loop_orders, \%line;
    }

    $template->param(
        loop_orders  => \@loop_orders,
    );
}

$template->param(
    invoiceid             => $invoice->{invoiceid},
    invoice               => $invoice->{invoicenumber},
    invoiceclosedate      => $invoice->{closedate},
    datereceived          => dt_from_string,
    name                  => $bookseller->name,
    booksellerid          => $bookseller->id,
    loop_received         => \@loop_received,
    loop_orders           => \@loop_orders,
    book_foot_loop        => \@book_foot_loop,
    (uc(C4::Context->preference("marcflavour"))) => 1,
    total_tax_excluded    => $total_tax_excluded,
    total_tax_included    => $total_tax_included,
    subtotal_for_funds    => $subtotal_for_funds,
    sticky_filters       => $sticky_filters,
);
output_html_with_http_headers $input, $cookie, $template->output;
