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
use C4::Bookseller qw/ GetBookSellerFromId /;
use C4::Biblio;
use C4::Items;
use CGI;
use C4::Output;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Suggestions;
use JSON;

my $input=new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui/parcel.tmpl",
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {acquisition => 'order_receive'},
                 debug => 1,
});

my $invoiceid = $input->param('invoiceid');
my $op = $input->param('op') // '';

if ($op eq 'cancelreceipt') {
    my $ordernumber = $input->param('ordernumber');
    my $parent_ordernumber = CancelReceipt($ordernumber);
    unless($parent_ordernumber) {
        $template->param(error_cancelling_receipt => 1);
    }
}

my $invoice = GetInvoiceDetails($invoiceid);
my $booksellerid = $invoice->{booksellerid};
my $bookseller = GetBookSellerFromId($booksellerid);
my $gst = $bookseller->{gstrate} // C4::Context->preference("gist") // 0;
my $datereceived = C4::Dates->new();
my $code            = $input->param('code');
my @rcv_err         = $input->param('error');
my @rcv_err_barcode = $input->param('error_bc');
my $startfrom=$input->param('startfrom');
my $resultsperpage = $input->param('resultsperpage');
$resultsperpage = 20 unless ($resultsperpage);
$startfrom=0 unless ($startfrom);



# If receiving error, report the error (coming from finishrecieve.pl(sic)).
if( scalar(@rcv_err) ) {
	my $cnt=0;
	my $error_loop;
	for my $err (@rcv_err) {
		push @$error_loop, { "error_$err" => 1 , barcode => $rcv_err_barcode[$cnt] };
		$cnt++;
	}
	$template->param( receive_error => 1 ,
						error_loop => $error_loop,
					);
}

my $cfstr         = "%.2f";                                                           # currency format string -- could get this from currency table.
my @parcelitems   = @{ $invoice->{orders} };
my $countlines    = scalar @parcelitems;
my $totalprice    = 0;
my $totalquantity = 0;
my $total;
my $tototal;
my @loop_received = ();

for (my $i = 0 ; $i < $countlines ; $i++) {

    $total = ($parcelitems[$i]->{'unitprice'}) * $parcelitems[$i]->{'quantityreceived'};
    $parcelitems[$i]->{'unitprice'} += 0;
    my %line;
    %line          = %{ $parcelitems[$i] };
    $line{invoice} = $invoice->{invoicenumber};
    $line{gst}     = $gst;
    $line{total} = sprintf($cfstr, $total);
    $line{booksellerid} = $invoice->{booksellerid};
    $totalprice += $parcelitems[$i]->{'unitprice'};
    $line{unitprice} = sprintf($cfstr, $parcelitems[$i]->{'unitprice'});

    my $suggestion   = GetSuggestionInfoFromBiblionumber($line{biblionumber});
    $line{suggestionid}         = $suggestion->{suggestionid};
    $line{surnamesuggestedby}   = $suggestion->{surnamesuggestedby};
    $line{firstnamesuggestedby} = $suggestion->{firstnamesuggestedby};

    if ( $line{parent_ordernumber} != $line{ordernumber} ) {
        if ( grep { $_->{ordernumber} == $line{parent_ordernumber} }
            @parcelitems )
        {
            $line{cannot_cancel} = 1;
        }
    }

    push @loop_received, \%line;
    $totalquantity += $parcelitems[$i]->{'quantityreceived'};
    $tototal       += $total;
}

if(!defined $invoice->{closedate}) {
    my $pendingorders;
    if($input->param('op') eq "search"){
        my $search   = $input->param('summaryfilter') || '';
        my $ean      = $input->param('eanfilter') || '';
        my $basketno = $input->param('basketfilter') || '';
        my $orderno  = $input->param('orderfilter') || '';
        my $grouped;
        my $owner;
        $pendingorders = GetPendingOrders($booksellerid,$grouped,$owner,$basketno,$orderno,$search,$ean);
    }else{
        $pendingorders = GetPendingOrders($booksellerid);
    }
    my $countpendings = scalar @$pendingorders;

    # pending orders totals
    my ($totalPunitprice, $totalPquantity, $totalPecost, $totalPqtyrcvd);
    my $ordergrandtotal;
    my @loop_orders = ();
    for (my $i = 0 ; $i < $countpendings ; $i++) {
        my %line;
        %line = %{$pendingorders->[$i]};

        $line{quantity}+=0;
        $line{quantityreceived}+=0;
        $line{unitprice}+=0;
        $totalPunitprice += $line{unitprice};
        $totalPquantity +=$line{quantity};
        $totalPqtyrcvd +=$line{quantityreceived};
        $totalPecost += $line{ecost};
        $line{ecost} = sprintf("%.2f",$line{ecost});
        $line{ordertotal} = sprintf("%.2f",$line{ecost}*$line{quantity});
        $line{unitprice} = sprintf("%.2f",$line{unitprice});
        $line{invoice} = $invoice;
        $line{gst} = $gst;
        $line{total} = $total;
        $line{booksellerid} = $booksellerid;
        $ordergrandtotal += $line{ecost} * $line{quantity};

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


        push @loop_orders, \%line if ($i >= $startfrom and $i < $startfrom + $resultsperpage);
    }

    my $count = $countpendings;

    if ($count>$resultsperpage){
        my $displaynext=0;
        my $displayprev=$startfrom;
        if(($count - ($startfrom+$resultsperpage)) > 0 ) {
            $displaynext = 1;
        }

        my @numbers = ();
        for (my $i=1; $i<$count/$resultsperpage+1; $i++) {
                my $highlight=0;
                ($startfrom/$resultsperpage==($i-1)) && ($highlight=1);
                push @numbers, { number => $i,
                    highlight => $highlight ,
                    startfrom => ($i-1)*$resultsperpage};
        }

        my $from = $startfrom*$resultsperpage+1;
        my $to;
        if($count < (($startfrom+1)*$resultsperpage)){
            $to = $count;
        } else {
            $to = (($startfrom+1)*$resultsperpage);
        }
        $template->param(numbers=>\@numbers,
                         displaynext=>$displaynext,
                         displayprev=>$displayprev,
                         nextstartfrom=>(($startfrom+$resultsperpage<$count)?$startfrom+$resultsperpage:$count),
                         prevstartfrom=>(($startfrom-$resultsperpage>0)?$startfrom-$resultsperpage:0)
                        );
    }

    $template->param(
        countpending => $countpendings,
        loop_orders  => \@loop_orders,
        ordergrandtotal => sprintf($cfstr, $ordergrandtotal),
        totalPunitprice => sprintf("%.2f", $totalPunitprice),
        totalPquantity  => $totalPquantity,
        totalPqtyrcvd   => $totalPqtyrcvd,
        totalPecost     => sprintf("%.2f", $totalPecost),
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
    gst                   => $gst,
    countreceived         => $countlines,
    loop_received         => \@loop_received,
    totalprice            => sprintf($cfstr, $totalprice),
    totalquantity         => $totalquantity,
    tototal               => sprintf($cfstr, $tototal),
    gst                   => $gst,
    grandtot              => sprintf($cfstr, $tototal + $gst),
    resultsperpage        => $resultsperpage,
    (uc(C4::Context->preference("marcflavour"))) => 1
);
output_html_with_http_headers $input, $cookie, $template->output;
