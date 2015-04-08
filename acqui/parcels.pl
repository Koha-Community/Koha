#!/usr/bin/perl


#script to show display basket of orders


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

parcels.pl

=head1 DESCRIPTION

This script shows all orders/parcels receipt or pending for a given supplier.
It allows to write an order/parcels as 'received' when he arrives.

=head1 CGI PARAMETERS

=over 4

=item booksellerid

To know the supplier this script has to show orders.

=item orderby

sort list of order by 'orderby'.
Orderby can be equals to
    * datereceived desc (default value)
    * invoicenumber
    * datereceived
    * invoicenumber desc

=item filter

=item datefrom

To filter on date

=item dateto

To filter on date

=item resultsperpage

To know how many results have to be display / page.

=back

=cut

use strict;
use warnings;
use CGI;
use C4::Auth;
use C4::Output;

use C4::Dates qw/format_date/;
use C4::Acquisition;
use C4::Bookseller qw/ GetBookSellerFromId /;
use C4::Budgets;

my $input          = CGI->new;
my $booksellerid     = $input->param('booksellerid');
my $order          = $input->param('orderby') || 'shipmentdate desc';
my $startfrom      = $input->param('startfrom');
my $code           = $input->param('filter');
my $datefrom       = $input->param('datefrom');
my $dateto         = $input->param('dateto');
my $resultsperpage = $input->param('resultsperpage');
my $op             = $input->param('op');
$resultsperpage ||= 20;

our ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {   template_name   => 'acqui/parcels.tt',
        query           => $input,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'order_receive' },
        debug           => 1,
    }
);

my $invoicenumber = $input->param('invoice');
my $shipmentdate = $input->param('shipmentdate');
my $shipmentcost = $input->param('shipmentcost');
my $shipmentcost_budgetid = $input->param('shipmentcost_budgetid');
if($shipmentdate) {
    $shipmentdate = C4::Dates->new($shipmentdate)->output('iso');
}

if ( $op and $op eq 'new' ) {
    if ( C4::Context->preference('AcqWarnOnDuplicateInvoice') ) {
        my @invoices = GetInvoices(
            supplierid    => $booksellerid,
            invoicenumber => $invoicenumber,
        );
        if ( scalar @invoices > 0 ) {
            $template->{'VARS'}->{'duplicate_invoices'} = \@invoices;
            $template->{'VARS'}->{'invoicenumber'}      = $invoicenumber;
            $template->{'VARS'}->{'shipmentdate'}       = $shipmentdate;
            $template->{'VARS'}->{'shipmentcost'}       = $shipmentcost;
            $template->{'VARS'}->{'shipmentcost_budgetid'} =
              $shipmentcost_budgetid;
        }
    }
    $op = 'confirm' unless $template->{'VARS'}->{'duplicate_invoices'};
}
if ($op and $op eq 'confirm') {
    my $invoiceid = AddInvoice(
        invoicenumber => $invoicenumber,
        booksellerid => $booksellerid,
        shipmentdate => $shipmentdate,
        shipmentcost => $shipmentcost,
        shipmentcost_budgetid => $shipmentcost_budgetid,
    );
    if(defined $invoiceid) {
        # Successful 'Add'
        print $input->redirect("/cgi-bin/koha/acqui/parcel.pl?invoiceid=$invoiceid");
        exit 0;
    } else {
        $template->param(error_failed_to_create_invoice => 1);
    }
}

my $bookseller = GetBookSellerFromId($booksellerid);
my @parcels = GetInvoices(
    supplierid => $booksellerid,
    invoicenumber => $code,
    shipmentdatefrom => $datefrom,
    shipmentdateto => $dateto,
    order_by => $order
);
my $count_parcels = @parcels;

# multi page display gestion
$startfrom ||= 0;
if ( $count_parcels > $resultsperpage ) {
    set_page_navigation( $count_parcels, $startfrom, $resultsperpage );
}
my $loopres = [];

my $next_page_start = $startfrom + $resultsperpage;
my $last_row = ( $next_page_start < $count_parcels  ) ? $next_page_start - 1 : $count_parcels - 1;
for my $i ( $startfrom .. $last_row) {
    my $p = $parcels[$i];

    push @{$loopres},
      { number           => $i + 1,
        invoiceid        => $p->{invoiceid},
        code             => $p->{invoicenumber},
        nullcode         => $p->{invoicenumber} eq 'NULL',
        emptycode        => $p->{invoicenumber} eq q{},
        raw_datereceived => $p->{shipmentdate},
        datereceived     => $p->{shipmentdate},
        bibcount         => $p->{receivedbiblios} || 0,
        reccount         => $p->{receiveditems} || 0,
        itemcount        => $p->{itemsexpected} || 0,
      };
}
if ($count_parcels) {
    $template->param( searchresults => $loopres, count => $count_parcels );
}

# build budget list
my $budget_loop = [];
my $budgets = GetBudgetHierarchy;
foreach my $r (@{$budgets}) {
    next unless (CanUserUseBudget($loggedinuser, $r, $flags));
    if (!defined $r->{budget_amount} || $r->{budget_amount} == 0) {
        next;
    }
    push @{$budget_loop}, {
        b_id  => $r->{budget_id},
        b_txt => $r->{budget_name},
        b_active => $r->{budget_period_active},
    };
}

@{$budget_loop} =
  sort { uc( $a->{b_txt}) cmp uc( $b->{b_txt}) } @{$budget_loop};


$template->param(
    orderby                  => $order,
    filter                   => $code,
    datefrom                 => $datefrom,
    dateto                   => $dateto,
    resultsperpage           => $resultsperpage,
    name                     => $bookseller->{'name'},
    shipmentdate_today       => C4::Dates->new()->output(),
    booksellerid             => $booksellerid,
    GST                      => C4::Context->preference('gist'),
    budgets                  => $budget_loop,
);

output_html_with_http_headers $input, $cookie, $template->output;

sub set_page_navigation {
    my ( $total_rows, $startfrom, $resultsperpage ) = @_;
    my $displaynext = 0;
    my $displayprev = $startfrom;
    my $next_row    = $startfrom + $resultsperpage;
    my $prev_row    = $startfrom - $resultsperpage;

    if ( $total_rows - $next_row > 0 ) {
        $displaynext = 1;
    }

    # set up index numbers for paging
    my $numbers = [];
    if ( $total_rows > $resultsperpage ) {
        my $pages = $total_rows / $resultsperpage;
        if ( $total_rows % $resultsperpage ) {
            ++$pages;
        }

        # set up page indexes for at max 15 pages
        my $max_idx = ( $pages < 15 ) ? $pages : 15;
        my $current_page = ( $startfrom / $resultsperpage ) - 1;
        for my $idx ( 1 .. $max_idx ) {
            push @{$numbers},
              { number    => $idx,
                startfrom => ( $idx - 1 ) * $resultsperpage,
                highlight => ( $idx == $current_page ),
              };
        }
    }

    $template->param(
        numbers     => $numbers,
        displaynext => $displaynext,
        displayprev => $displayprev,
        nextstartfrom => ( ( $next_row < $total_rows ) ? $next_row : $total_rows ),
        prevstartfrom => ( ( $prev_row > 0 ) ? $prev_row : 0 )
    );
    return;
}
