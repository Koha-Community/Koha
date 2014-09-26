#!/usr/bin/perl

#script to recieve orders


# Copyright 2000-2002 Katipo Communications
# Copyright 2008-2009 BibLibre SARL
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

parcel.pl

=head1 DESCRIPTION

This script shows all orders receipt or pending for a given supplier.
It allows to write an order as 'received' when he arrives.

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
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Suggestions;
use C4::Reserves qw/GetReservesFromBiblionumber/;

use Koha::Acquisition::Bookseller;

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
my $bookseller = Koha::Acquisition::Bookseller->fetch({ id => $booksellerid });
my $gst = $bookseller->{gstrate} // C4::Context->preference("gist") // 0;
my $datereceived = C4::Dates->new();

my @orders        = @{ $invoice->{orders} };
my $countlines    = scalar @orders;
my @loop_received = ();
my @book_foot_loop;
my %foot;
my $total_gste = 0;
my $total_gsti = 0;

for my $order ( @orders ) {
    $order = C4::Acquisition::populate_order_with_prices({ order => $order, booksellerid => $bookseller->{id}, receiving => 1, ordering => 1 });
    $order->{'unitprice'} += 0;

    if ( $bookseller->{listincgst} and not $bookseller->{invoiceincgst} ) {
        $order->{ecost}     = $order->{ecostgste};
        $order->{unitprice} = $order->{unitpricegste};
    }
    elsif ( not $bookseller->{listinct} and $bookseller->{invoiceincgst} ) {
        $order->{ecost}     = $order->{ecostgsti};
        $order->{unitprice} = $order->{unitpricegsti};
    }
    $order->{total} = $order->{ecost} * $order->{quantity};

    my %line = %{ $order };
    $line{invoice} = $invoice->{invoicenumber};
    $line{holds} = 0;
    my @itemnumbers = GetItemnumbersFromOrder( $order->{ordernumber} );
    for my $itemnumber ( @itemnumbers ) {
        my $holds = GetReservesFromBiblionumber({ biblionumber => $line{biblionumber}, itemnumber => $itemnumber });
        $line{holds} += scalar( @$holds );
    }
    $line{budget} = GetBudgetByOrderNumber( $line{ordernumber} );
    $foot{$line{gstrate}}{gstrate} = $line{gstrate};
    $foot{$line{gstrate}}{gstvalue} += $line{gstvalue};
    $total_gste += $line{totalgste};
    $total_gsti += $line{totalgsti};

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

    my $budget = GetBudget( $line{budget_id} );
    $line{budget_name} = $budget->{'budget_name'};

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
        $order = C4::Acquisition::populate_order_with_prices({ order => $order, booksellerid => $bookseller->{id}, receiving => 1, ordering => 1 });

        if ( $bookseller->{listincgst} and not $bookseller->{invoiceincgst} ) {
            $order->{ecost} = $order->{ecostgste};
        } elsif ( not $bookseller->{listinct} and $bookseller->{invoiceincgst} ) {
            $order->{ecost} = $order->{ecostgsti};
        }
        $order->{total} = $order->{ecost} * $order->{quantity};

        my %line = %$order;

        $line{invoice} = $invoice;
        $line{booksellerid} = $booksellerid;

        my $biblionumber = $line{'biblionumber'};
        my $countbiblio = CountBiblioInOrders($biblionumber);
        my $ordernumber = $line{'ordernumber'};
        my @subscriptions = GetSubscriptionsId ($biblionumber);
        my $itemcount = GetItemsCount($biblionumber);
        my $holds  = GetHolds ($biblionumber);
        my @items = GetItemnumbersFromOrder( $ordernumber );
        my $itemholds;
        foreach my $item (@items){
            my $nb = GetItemHolds($biblionumber, $item);
            if ($nb){
                $itemholds += $nb;
            }
        }

        my $suggestion   = GetSuggestionInfoFromBiblionumber($line{biblionumber});
        $line{suggestionid}         = $suggestion->{suggestionid};
        $line{surnamesuggestedby}   = $suggestion->{surnamesuggestedby};
        $line{firstnamesuggestedby} = $suggestion->{firstnamesuggestedby};

        # if the biblio is not in other orders and if there is no items elsewhere and no subscriptions and no holds we can then show the link "Delete order and Biblio" see bug 5680
        $line{can_del_bib}          = 1 if $countbiblio <= 1 && $itemcount == scalar @items && !(@subscriptions) && !($holds);
        $line{items}                = ($itemcount) - (scalar @items);
        $line{left_item}            = 1 if $line{items} >= 1;
        $line{left_biblio}          = 1 if $countbiblio > 1;
        $line{biblios}              = $countbiblio - 1;
        $line{left_subscription}    = 1 if scalar @subscriptions >= 1;
        $line{subscriptions}        = scalar @subscriptions;
        $line{left_holds}           = ($holds >= 1) ? 1 : 0;
        $line{left_holds_on_order}  = 1 if $line{left_holds}==1 && ($line{items} == 0 || $itemholds );
        $line{holds}                = $holds;
        $line{holds_on_order}       = $itemholds?$itemholds:$holds if $line{left_holds_on_order};

        my $budget = GetBudget( $line{budget_id} );
        $line{budget_name} = $budget->{'budget_name'};

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
    datereceived          => $datereceived->output('iso'),
    invoicedatereceived   => $datereceived->output('iso'),
    formatteddatereceived => $datereceived->output(),
    name                  => $bookseller->{'name'},
    booksellerid          => $bookseller->{id},
    loop_received         => \@loop_received,
    loop_orders           => \@loop_orders,
    book_foot_loop        => \@book_foot_loop,
    (uc(C4::Context->preference("marcflavour"))) => 1,
    total_gste           => $total_gste,
    total_gsti           => $total_gsti,
    sticky_filters       => $sticky_filters,
);
output_html_with_http_headers $input, $cookie, $template->output;
