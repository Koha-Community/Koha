#!/usr/bin/perl

# Copyright 2011 BibLibre SARL
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

invoice.pl

=head1 DESCRIPTION

Invoice details

=cut

use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Output;
use C4::Acquisition;
use C4::Bookseller qw/GetBookSellerFromId/;
use C4::Budgets;

my $input = new CGI;
my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name   => 'acqui/invoice.tmpl',
        query           => $input,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { 'acquisition' => '*' },
        debug           => 1,
    }
);

my $invoiceid = $input->param('invoiceid');
my $op        = $input->param('op');

if ( $op && $op eq 'close' ) {
    CloseInvoice($invoiceid);
    my $referer = $input->param('referer');
    if ($referer) {
        print $input->redirect($referer);
        exit 0;
    }
}
elsif ( $op && $op eq 'reopen' ) {
    ReopenInvoice($invoiceid);
    my $referer = $input->param('referer');
    if ($referer) {
        print $input->redirect($referer);
        exit 0;
    }
}
elsif ( $op && $op eq 'mod' ) {
    my $shipmentdate       = $input->param('shipmentdate');
    my $billingdate        = $input->param('billingdate');
    my $shipmentcost       = $input->param('shipmentcost');
    my $shipment_budget_id = $input->param('shipment_budget_id');
    ModInvoice(
        invoiceid             => $invoiceid,
        shipmentdate          => C4::Dates->new($shipmentdate)->output("iso"),
        billingdate           => C4::Dates->new($billingdate)->output("iso"),
        shipmentcost          => $shipmentcost,
        shipmentcost_budgetid => $shipment_budget_id
    );
    if ($input->param('reopen')) {
        ReopenInvoice($invoiceid);
    } elsif ($input->param('close')) {
        CloseInvoice($invoiceid);
    }
    $template->param( modified => 1 );
}

my $details     = GetInvoiceDetails($invoiceid);
my $bookseller  = GetBookSellerFromId( $details->{booksellerid} );
my @orders_loop = ();
my $orders      = $details->{'orders'};
my $qty_total;
my @books_loop;
my @book_foot_loop;
my %foot;
my $total_quantity = 0;
my $total_rrp      = 0;
my $total_est      = 0;

foreach my $order (@$orders) {
    my $line = get_infos( $order, $bookseller );

    $total_quantity += $$line{quantity};
    $total_rrp      += $order->{quantity} * $order->{rrp};
    $total_est      += $order->{quantity} * $order->{'ecost'};

    my %row = ( %$order, %$line );
    push @orders_loop, \%row;
}

my $gist = $bookseller->{gstrate} // C4::Context->preference("gist") // 0;
my $discount =
  $bookseller->{'discount'} ? ( $bookseller->{discount} / 100 ) : 0;
my $total_est_gste;
my $total_est_gsti;
my $total_rrp_gsti;    # RRP Total, GST included
my $total_rrp_gste;    # RRP Total, GST excluded
my $gist_est;
my $gist_rrp;
if ($gist) {

    # if we have GST
    if ( $bookseller->{'listincgst'} ) {

        # if prices already includes GST

        # we know $total_rrp_gsti
        $total_rrp_gsti = $total_rrp;

        # and can reverse compute other values
        $total_rrp_gste = $total_rrp_gsti / ( $gist + 1 );

        $gist_rrp       = $total_rrp_gsti - $total_rrp_gste;
        $total_est_gste = $total_rrp_gste - ( $total_rrp_gste * $discount );
        $total_est_gsti = $total_est;
    }
    else {
        # if prices does not include GST

        # then we use the common way to compute other values
        $total_rrp_gste = $total_rrp;
        $gist_rrp       = $total_rrp_gste * $gist;
        $total_rrp_gsti = $total_rrp_gste + $gist_rrp;
        $total_est_gste = $total_est;
        $total_est_gsti = $total_rrp_gsti - ( $total_rrp_gsti * $discount );
    }
    $gist_est = $gist_rrp - ( $gist_rrp * $discount );
}
else {
    $total_rrp_gste = $total_rrp_gsti = $total_rrp;
    $total_est_gste = $total_est_gsti = $total_est;
    $gist_rrp       = $gist_est       = 0;
}
my $total_gsti_shipment = $total_est_gsti + $details->{shipmentcost};

my $format = "%.2f";
$template->param(
    total_rrp_gste      => sprintf( $format, $total_rrp_gste ),
    total_rrp_gsti      => sprintf( $format, $total_rrp_gsti ),
    total_est_gste      => sprintf( $format, $total_est_gste ),
    total_est_gsti      => sprintf( $format, $total_est_gsti ),
    gist_rrp            => sprintf( $format, $gist_rrp ),
    gist_est            => sprintf( $format, $gist_est ),
    total_gsti_shipment => sprintf( $format, $total_gsti_shipment ),
    gist                => sprintf( $format, $gist * 100 ),
);

my $budgets = GetBudgets();
my @budgets_loop;
my $shipmentcost_budgetid = $details->{shipmentcost_budgetid};
foreach my $budget (@$budgets) {
    next unless CanUserUseBudget( $loggedinuser, $budget, $flags );
    my %line = %{$budget};
    if (    $shipmentcost_budgetid
        and $budget->{budget_id} == $shipmentcost_budgetid )
    {
        $line{selected} = 1;
    }
    push @budgets_loop, \%line;
}

$template->param(
    invoiceid        => $details->{'invoiceid'},
    invoicenumber    => $details->{'invoicenumber'},
    suppliername     => $details->{'suppliername'},
    supplierid       => $details->{'booksellerid'},
    datereceived     => $details->{'datereceived'},
    shipmentdate     => $details->{'shipmentdate'},
    billingdate      => $details->{'billingdate'},
    invoiceclosedate => $details->{'closedate'},
    shipmentcost     => sprintf( $format, $details->{'shipmentcost'} || 0 ),
    orders_loop      => \@orders_loop,
    total_quantity   => $total_quantity,
    invoiceincgst    => $bookseller->{invoiceincgst},
    currency         => $bookseller->{listprice},
    budgets_loop             => \@budgets_loop,
);

sub get_infos {
    my $order      = shift;
    my $bookseller = shift;
    my $qty        = $order->{'quantity'} || 0;
    if ( !defined $order->{quantityreceived} ) {
        $order->{quantityreceived} = 0;
    }
    my $budget = GetBudget( $order->{'budget_id'} );

    my %line = %{$order};
    $line{order_received} = ( $qty == $order->{'quantityreceived'} );
    $line{budget_name}    = $budget->{budget_name};
    $line{total}          = $qty * $order->{ecost};

    if ( $line{uncertainprice} ) {
        $line{rrp} .= ' (Uncertain)';
    }
    if ( $line{'title'} ) {
        my $volume      = $order->{'volume'};
        my $seriestitle = $order->{'seriestitle'};
        $line{'title'} .= " / $seriestitle" if $seriestitle;
        $line{'title'} .= " / $volume"      if $volume;
    }
    else {
        $line{'title'} = "Deleted bibliographic notice, can't find title.";
    }

    return \%line;
}

output_html_with_http_headers $input, $cookie, $template->output;
