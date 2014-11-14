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

use CGI qw ( -utf8 );
use C4::Auth;
use C4::Output;
use C4::Acquisition;
use C4::Budgets;

use Koha::Acquisition::Bookseller;
use Koha::Misc::Files;

my $input = new CGI;
my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name   => 'acqui/invoice.tt',
        query           => $input,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { 'acquisition' => '*' },
        debug           => 1,
    }
);

my $invoiceid = $input->param('invoiceid');
my $op        = $input->param('op');

my $invoice_files;
if ( C4::Context->preference('AcqEnableFiles') ) {
    $invoice_files = Koha::Misc::Files->new(
        tabletag => 'aqinvoices', recordid => $invoiceid );
}

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
    } elsif ($input->param('merge')) {
        my @sources = $input->param('merge');
        MergeInvoices($invoiceid, \@sources);
        defined($invoice_files) && $invoice_files->MergeFileRecIds(@sources);
    }
    $template->param( modified => 1 );
}
elsif ( $op && $op eq 'delete' ) {
    DelInvoice($invoiceid);
    defined($invoice_files) && $invoice_files->DelAllFiles();
    my $referer = $input->param('referer') || 'invoices.pl';
    if ($referer) {
        print $input->redirect($referer);
        exit 0;
    }
}


my $details = GetInvoiceDetails($invoiceid);
my $bookseller = Koha::Acquisition::Bookseller->fetch({ id => $details->{booksellerid} });
my @orders_loop = ();
my $orders = $details->{'orders'};
my $qty_total;
my @foot_loop;
my %foot;
my $total_quantity = 0;
my $total_gste = 0;
my $total_gsti = 0;
my $total_gstvalue = 0;
foreach my $order (@$orders) {
    $order = C4::Acquisition::populate_order_with_prices(
        {
            order        => $order,
            booksellerid => $bookseller->{id},
            receiving    => 1,
        }
    );
    my $line = get_infos( $order, $bookseller);

    $foot{$$line{gstrate}}{gstrate} = $$line{gstrate};
    $foot{$$line{gstrate}}{gstvalue} += $$line{gstvalue};
    $total_gstvalue += $$line{gstvalue};
    $foot{$$line{gstrate}}{quantity}  += $$line{quantity};
    $total_quantity += $$line{quantity};
    $foot{$$line{gstrate}}{totalgste} += $$line{totalgste};
    $total_gste += $$line{totalgste};
    $foot{$$line{gstrate}}{totalgsti} += $$line{totalgsti};
    $total_gsti += $$line{totalgsti};

    $line->{orderline} = $line->{parent_ordernumber};
    push @orders_loop, $line;
}

push @foot_loop, map {$_} values %foot;

my $format = "%.2f";
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
    booksellerid     => $details->{'booksellerid'},
    shipmentdate     => $details->{'shipmentdate'},
    billingdate      => $details->{'billingdate'},
    invoiceclosedate => $details->{'closedate'},
    shipmentcost     => $details->{'shipmentcost'},
    orders_loop      => \@orders_loop,
    foot_loop        => \@foot_loop,
    total_quantity   => $total_quantity,
    total_gste       => sprintf( $format, $total_gste ),
    total_gsti       => sprintf( $format, $total_gsti ),
    total_gstvalue   => sprintf( $format, $total_gstvalue ),
    total_gste_shipment => sprintf( $format, $total_gste + $details->{shipmentcost}),
    total_gsti_shipment => sprintf( $format, $total_gsti + $details->{shipmentcost}),
    invoiceincgst    => $bookseller->{invoiceincgst},
    currency         => GetCurrency()->{currency},
    budgets_loop     => \@budgets_loop,
);

defined( $invoice_files ) && $template->param( files => $invoice_files->GetFilesInfo() );

# FIXME
# Fonction dupplicated from basket.pl
# Code must to be exported. Where ??
sub get_infos {
    my $order = shift;
    my $bookseller = shift;
    my $qty = $order->{'quantity'} || 0;
    if ( !defined $order->{quantityreceived} ) {
        $order->{quantityreceived} = 0;
    }
    my $budget = GetBudget( $order->{'budget_id'} );

    my %line = %{ $order };
    $line{order_received} = ( $qty == $order->{'quantityreceived'} );
    $line{budget_name}    = $budget->{budget_name};

    if ( $line{uncertainprice} ) {
        $template->param( uncertainprices => 1 );
        $line{rrp} .= ' (Uncertain)';
    }
    if ( $line{'title'} ) {
        my $volume      = $order->{'volume'};
        my $seriestitle = $order->{'seriestitle'};
        $line{'title'} .= " / $seriestitle" if $seriestitle;
        $line{'title'} .= " / $volume"      if $volume;
    } else {
        $line{'title'} = "Deleted bibliographic notice, can't find title.";
    }

    return \%line;
}

output_html_with_http_headers $input, $cookie, $template->output;
