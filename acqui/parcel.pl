#!/usr/bin/perl

# $Id$

#script to recieve orders
#written by chris@katipo.co.nz 24/2/2000


# Copyright 2000-2002 Katipo Communications
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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA


=head1 NAME

parcel.pl

=head1 DESCRIPTION
This script shows all orders receipt or pending for a given supplier.
It allows to write an order as 'received' when he arrives.

=head1 CGI PARAMETERS

=over 4

=item supplierid
To know the supplier this script has to show orders.

=item code
is the bookseller invoice number.

=item freight


=item gst


=item datereceived
To filter the results list on this given date.

=back

=cut
use strict;
use C4::Auth;
use C4::Acquisition;
use C4::Bookseller;
use C4::Bookfund;
use C4::Biblio;
use CGI;
use C4::Interface::CGI::Output;
use C4::Date;
use Time::localtime;


my $input=new CGI;
my $supplierid=$input->param('supplierid');
my $basketno=$input->param('basketno');
my @booksellers=GetBookSeller($supplierid);
my $count = scalar @booksellers;

my @datetoday = localtime();
my $date = (1900+$datetoday[5])."-".($datetoday[4]+1)."-". $datetoday[3];
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui/parcel.tmpl",
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {acquisition => 1},
                 debug => 1,
});

my @booksellers=GetBookSeller($supplierid);

my $gstreg=$booksellers[0]->{gstreg};
my $incgst=$booksellers[0]->{'invoiceincgst'};
my $invcurrency=$booksellers[0]->{'invoiceprice'};
my $discount=$booksellers[0]->{'discount'};
my $currencyrate;
# get currencies (for exchange rates calcs if needed)
my @rates = GetCurrencies();
my $count = scalar @rates;

for ( my $i = 0 ; $i < $count ; $i++ ) {
 if ($rates[$i]->{'currency'} eq $invcurrency){
    $currencyrate     = $rates[$i]->{'rate'};
   }
}
my $me=C4::Context->userenv;
my $user=$me->{'cardnumber'};
my $totalprice=0;
my $totalfreight=0;
my $totalquantity=0;
my $totaldiscount=0;
my $total;
my $tototal;
my $toggle;
my $totalgst;
my $totaltoreceive;
my $totaltoprice;
my $totaltogst;
my $totaltodiscount;
my @loop_orders;
my $countpendings;
my $invoice;
##Receiving a single basket or all baskets of a supplier
unless($basketno){
my $pendingorders = GetPendingOrders($supplierid);
$countpendings = scalar @$pendingorders;
foreach my $pendingorder (@$pendingorders){
 my @orders=GetOrders($pendingorder->{basketno});
  foreach my $order(@orders){
  $order->{toreceive}=$order->{quantity} - $order->{quantityreceived};
  $totalquantity+=$order->{quantity};
  $totaltoreceive+=$order->{toreceive};
  $totalprice+=$order->{rrp}*$order->{quantity};
  $totaltoprice+=$order->{rrp}*$order->{toreceive};
  $totalgst+=(($order->{rrp}*$order->{quantity}) -($order->{rrp}*$order->{quantity}*$order->{discount}/100))* $order->{gst}/100;
  $totaltogst+=(($order->{rrp}*$order->{toreceive}) -($order->{rrp}*$order->{toreceive}*$order->{discount}/100))* $order->{gst}/100;
  $totaldiscount +=$order->{rrp}*$order->{quantity}*$order->{discount}/100;
  $totaltodiscount +=$order->{rrp}*$order->{toreceive}*$order->{discount}/100;
  $order->{actualrrp}=sprintf( "%.2f",$order->{rrp}/$currencyrate);
	push @loop_orders, $order;
  }	
}
  
}else{
## one basket
$countpendings=1;

my @orders=GetOrders($basketno);
  foreach my $order(@orders){
$invoice=$order->{booksellerinvoicenumber} unless $invoice;
  $order->{toreceive}=$order->{quantity} - $order->{quantityreceived};
  $totalquantity+=$order->{quantity};
  $totaltoreceive+=$order->{toreceive};
  $totalprice+=$order->{rrp}*$order->{quantity};
  $totaltoprice+=$order->{rrp}*$order->{toreceive};
  $totalgst+=(($order->{rrp}*$order->{quantity}) -($order->{rrp}*$order->{quantity}*$order->{discount}/100))* $order->{gst}/100;
  $totaltogst+=(($order->{rrp}*$order->{toreceive}) -($order->{rrp}*$order->{toreceive}*$order->{discount}/100))* $order->{gst}/100;
  $totaldiscount +=$order->{rrp}*$order->{quantity}*$order->{discount}/100;
  $totaltodiscount +=$order->{rrp}*$order->{toreceive}*$order->{discount}/100;
  $order->{actualrrp}=sprintf( "%.2f",$order->{rrp}/$currencyrate);
	push @loop_orders, $order;
  }	
}
undef $invcurrency if ($currencyrate ==1);

$template->param( invoice=>$invoice,
                        date => format_date($date),
                        name => $booksellers[0]->{'name'},
                        supplierid => $supplierid,
                        countpending => $countpendings,
                        loop_orders => \@loop_orders,
 	          user=>$user,
	         totalquantity=>$totalquantity,
	         totaltoreceive=>$totaltoreceive,
	          totalprice=>sprintf( "%.2f",$totalprice),
	         totalactual =>sprintf( "%.2f",$totaltoprice/$currencyrate),
                        totalgst=>sprintf( "%.2f",$totalgst),
                        actualgst=>sprintf( "%.2f",$totaltogst/$currencyrate),
		totaldiscount=>sprintf( "%.2f",$totaldiscount),
		actualdiscount=>sprintf( "%.2f",$totaltodiscount/$currencyrate),	
		total=>sprintf( "%.2f",$totalprice+$totalgst-$totaldiscount),
		gstreg=>$gstreg,
                            gstrate=>C4::Context->preference('gist')*100,
		currencyrate=>$currencyrate,
		incgst =>$incgst,
		invcurrency=>$invcurrency ,
                        intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
        intranetstylesheet => C4::Context->preference("intranetstylesheet"),
        IntranetNav => C4::Context->preference("IntranetNav"),
                        );
output_html_with_http_headers $input, $cookie, $template->output;
