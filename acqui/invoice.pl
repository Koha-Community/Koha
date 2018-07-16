#!/usr/bin/perl

# Copyright 2011 BibLibre SARL
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

invoice.pl

=head1 DESCRIPTION

Invoice details

=cut

use Modern::Perl;

use CGI qw ( -utf8 );
use C4::Auth;
use C4::Output;
use C4::Acquisition;
use C4::Budgets;

use Koha::Acquisition::Booksellers;
use Koha::Acquisition::Currencies;
use Koha::DateUtils;
use Koha::Misc::Files;
use Koha::Acquisition::Invoice::Adjustments;

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
    my $shipmentcost       = $input->param('shipmentcost');
    my $shipment_budget_id = $input->param('shipment_budget_id');
    my $invoicenumber      = $input->param('invoicenumber');
    ModInvoice(
        invoiceid             => $invoiceid,
        invoicenumber         => $invoicenumber,
        shipmentdate          => scalar output_pref( { str => scalar $input->param('shipmentdate'), dateformat => 'iso', dateonly => 1 } ),
        billingdate           => scalar output_pref( { str => scalar $input->param('billingdate'),  dateformat => 'iso', dateonly => 1 } ),
        shipmentcost          => $shipmentcost,
        shipmentcost_budgetid => $shipment_budget_id
    );
    if ($input->param('reopen')) {
        ReopenInvoice($invoiceid);
    } elsif ($input->param('close')) {
        CloseInvoice($invoiceid);
    } elsif ($input->param('merge')) {
        my @sources = $input->multi_param('merge');
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
elsif ( $op && $op eq 'del_adj' ) {
    my $adjustment_id  = $input->param('adjustment_id');
    my $del_adj = Koha::Acquisition::Invoice::Adjustments->find( $adjustment_id );
    $del_adj->delete() if ($del_adj);
}
elsif ( $op && $op eq 'mod_adj' ) {
    my @adjustment_id  = $input->multi_param('adjustment_id');
    my @adjustment     = $input->multi_param('adjustment');
    my @reason         = $input->multi_param('reason');
    my @note           = $input->multi_param('note');
    my @budget_id      = $input->multi_param('budget_id');
    my @encumber_open  = $input->multi_param('encumber_open');
    my %e_open = map { $_ => 1 } @encumber_open;

    for( my $i=0; $i < scalar @adjustment; $i++ ){
        if( $adjustment_id[$i] eq 'new' ){
            next unless ( $adjustment[$i] || $reason[$i] );
            my $new_adj = Koha::Acquisition::Invoice::Adjustment->new({
                invoiceid => $invoiceid,
                adjustment => $adjustment[$i],
                reason => $reason[$i],
                note => $note[$i],
                budget_id => $budget_id[$i] || undef,
                encumber_open => defined $e_open{ $adjustment_id[$i] } ? 1 : 0,
            });
            $new_adj->store();
        }
        else {
            my $old_adj = Koha::Acquisition::Invoice::Adjustments->find( $adjustment_id[$i] );
            unless ( $old_adj->adjustment == $adjustment[$i] && $old_adj->reason eq $reason[$i] && $old_adj->budget_id == $budget_id[$i] && $old_adj->encumber_open == $e_open{$adjustment_id[$i]} && $old_adj->note eq $note[$i] ){
                $old_adj->timestamp(undef);
                $old_adj->adjustment( $adjustment[$i] );
                $old_adj->reason( $reason[$i] );
                $old_adj->note( $note[$i] );
                $old_adj->budget_id( $budget_id[$i] || undef );
                $old_adj->encumber_open( $e_open{$adjustment_id[$i]} ? 1 : 0 );
                $old_adj->update();
            }
        }
    }
}

my $details = GetInvoiceDetails($invoiceid);
my $bookseller = Koha::Acquisition::Booksellers->find( $details->{booksellerid} );
my @orders_loop = ();
my $orders = $details->{'orders'};
my @foot_loop;
my %foot;
my $shipmentcost = $details->{shipmentcost} || 0;
my $total_quantity = 0;
my $total_tax_excluded = 0;
my $total_tax_included = 0;
my $total_tax_value = 0;
foreach my $order (@$orders) {
    my $line = get_infos( $order, $bookseller);

    $line->{total_tax_excluded} = $line->{unitprice_tax_excluded} * $line->{quantity};
    $line->{total_tax_included} = $line->{unitprice_tax_included} * $line->{quantity};

    $line->{tax_value} = $line->{tax_value_on_receiving};
    $line->{tax_rate} = $line->{tax_rate_on_receiving};

    $foot{$$line{tax_rate}}{tax_rate} = $$line{tax_rate};
    $foot{$$line{tax_rate}}{tax_value} += $$line{tax_value};
    $total_tax_value += $$line{tax_value};
    $foot{$$line{tax_rate}}{quantity}  += $$line{quantity};
    $total_quantity += $$line{quantity};
    $foot{$$line{tax_rate}}{total_tax_excluded} += $$line{total_tax_excluded};
    $total_tax_excluded += $$line{total_tax_excluded};
    $foot{$$line{tax_rate}}{total_tax_included} += $$line{total_tax_included};
    $total_tax_included += $$line{total_tax_included};

    $line->{orderline} = $line->{parent_ordernumber};
    push @orders_loop, $line;
}

push @foot_loop, map {$_} values %foot;

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

my $adjustments = Koha::Acquisition::Invoice::Adjustments->search({ invoiceid => $details->{'invoiceid'} });
if ( $adjustments ) { $template->param( adjustments => $adjustments ); }

$template->param(
    invoiceid        => $details->{'invoiceid'},
    invoicenumber    => $details->{'invoicenumber'},
    suppliername     => $details->{'suppliername'},
    booksellerid     => $details->{'booksellerid'},
    shipmentdate     => $details->{'shipmentdate'},
    billingdate      => $details->{'billingdate'},
    invoiceclosedate => $details->{'closedate'},
    shipmentcost     => $shipmentcost,
    orders_loop      => \@orders_loop,
    foot_loop        => \@foot_loop,
    total_quantity   => $total_quantity,
    total_tax_excluded => $total_tax_excluded,
    total_tax_included => $total_tax_included,
    total_tax_value  => $total_tax_value,
    total_tax_excluded_shipment => $total_tax_excluded + $shipmentcost,
    total_tax_included_shipment => $total_tax_included + $shipmentcost,
    invoiceincgst    => $bookseller->invoiceincgst,
    currency         => Koha::Acquisition::Currencies->get_active,
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
        $line{rrp} .= ' (Uncertain)';
    }
    if ( $line{'title'} ) {
        my $volume      = $order->{'volume'};
        my $seriestitle = $order->{'seriestitle'};
        $line{'title'} .= " / $seriestitle" if $seriestitle;
        $line{'title'} .= " / $volume"      if $volume;
    }

    return \%line;
}

output_html_with_http_headers $input, $cookie, $template->output;
