#!/usr/bin/perl


#script to show display basket of orders
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

parcels.pl

=head1 DESCRIPTION
This script shows all orders/parcels receipt or pending for a given supplier.
It allows to write an order/parcels as 'received' when he arrives.

=head1 CGI PARAMETERS

=over 4

=item supplierid
To know the supplier this script has to show orders.

=item orderby
sort list of order by 'orderby'.
Orderby can be equals to
    * datereceived desc (default value)
    * aqorders.booksellerinvoicenumber
    * datereceived
    * aqorders.booksellerinvoicenumber desc

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
use CGI;
use C4::Auth;
use C4::Output;

use C4::Dates qw/format_date/;
use C4::Acquisition;
use C4::Bookseller;

my $input=new CGI;
my $supplierid=$input->param('supplierid');
my $order=$input->param('orderby') || "datereceived desc";
my $startfrom=$input->param('startfrom');
my $code=$input->param('filter');
my $datefrom=$input->param('datefrom');
my $dateto=$input->param('dateto');
my $resultsperpage = $input->param('resultsperpage');


my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui/parcels.tmpl",
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {acquisition => 1},
                 debug => 1,
});


my $bookseller=GetBookSellerFromId($supplierid);
$resultsperpage = 20 unless ($resultsperpage);
my @results =GetParcels($supplierid, $order, $code,$datefrom,$dateto);
my $count = scalar @results;

# multi page display gestion
$startfrom=0 unless ($startfrom);
if ($count>$resultsperpage){
    my $displaynext=0;
    my $displayprev=$startfrom;
    if(($count - ($startfrom+$resultsperpage)) > 0 ) {
        $displaynext = 1;
    }

    my @numbers = ();
    if ($count>$resultsperpage) {
        for (my $i=1; $i<$count/$resultsperpage+1; $i++) {
            if ($i<16) {
                my $highlight=0;
                ($startfrom/$resultsperpage==($i-1)) && ($highlight=1);
                push @numbers, { number => $i,
                    highlight => $highlight ,
#                   searchdata=> "test",
                    startfrom => ($i-1)*$resultsperpage};
            }
        }
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
my @loopres;

my $hilighted=0;
for (my $i=$startfrom;$i<=($startfrom+$resultsperpage-1<$count-1?$startfrom+$resultsperpage-1:$count-1);$i++){

    my %cell;
    $cell{number}=$i+1;
    $cell{code}=$results[$i]->{booksellerinvoicenumber};
    $cell{nullcode}=$results[$i]->{booksellerinvoicenumber} eq "NULL";
    $cell{emptycode}=$results[$i]->{booksellerinvoicenumber} eq '';
    $cell{raw_datereceived}=$results[$i]->{datereceived};
    $cell{datereceived}=format_date($results[$i]->{datereceived});
    $cell{bibcount}=$results[$i]->{biblio};
    $cell{reccount}=$results[$i]->{itemsreceived};
    $cell{itemcount}=$results[$i]->{itemsexpected};
    $cell{hilighted} = $hilighted%2;
    $hilighted++;
    push @loopres, \%cell;
}
$template->param(searchresults=>\@loopres, count=>$count) if ($count);
$template->param(orderby=>$order, filter=>$code, datefrom=>$datefrom,dateto=>$dateto, resultsperpage=>$resultsperpage);
$template->param(
        name => $bookseller->{'name'},
        DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
		datereceived_today => C4::Dates->new()->output(),
		supplierid => $supplierid,
	    GST => C4::Context->preference("gist"),
        );

output_html_with_http_headers $input, $cookie, $template->output;
