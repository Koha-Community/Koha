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

use C4::Auth;
use C4::Catalogue;
use C4::Biblio;
use C4::Output;
use CGI;
use C4::Interface::CGI::Output;
use C4::Database;
use HTML::Template;
use C4::Catalogue;
use strict;

my $input=new CGI;
my $id=$input->param('id');
my ($count,@booksellers)=bookseller($id);
my $invoice=$input->param('invoice');
my $freight=$input->param('freight');
my $gst=$input->param('gst');
my $date=localtime(time);

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui/recieve.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {acquisition => 1},
			     debug => 1,
			     });

my @results;
($count,@results)=invoice($invoice);
if ($invoice eq ''){
	($count,@results)=getallorders($id);
}
my $totalprice=0;
my $totalfreight=0;
my $totalquantity=0;
my $total;
my $tototal;
my $toggle;
my @loop_orders = ();
for (my$i=0;$i<$count;$i++){
	$total=($results[$i]->{'unitprice'} + $results[$i]->{'freight'}) * $results[$i]->{'quantityreceived'};
	$results[$i]->{'unitprice'}+=0;
	my %line;
	if ($toggle==0){
		$line{color}='#ffffcc';
		$toggle=1;
	} else {
		$line{color}='white';
		$toggle=0;
	}
	$line{basketno} = $results[$i]->{'basketno'};
	$line{isbn} = $results[$i]->{'isbn'};
	$line{ordernumber} = $results[$i]->{'ordernumber'};
	$line{biblionumber} = $results[$i]->{'biblionumber'};
	$line{invoice} = $invoice;
	$line{gst} = $gst;
	$line{title} = $results[$i]->{'title'};
	$line{author} = $results[$i]->{'author'};
	$line{unitprice} = $results[$i]->{'unitprice'};
	$line{quantityrecieved} = $results[$i]->{'quantityreceived'};
	$line{total} = $total;
	$line{id} = $id;
	push @loop_orders, \%line;
	$totalprice+=$results[$i]->{'unitprice'};
	$totalfreight+=$results[$i]->{'freight'};
	$totalquantity+=$results[$i]->{'quantityreceived'};
	$tototal+=$total;
}

$totalfreight=$freight;
$tototal=$tototal+$freight;

$template->param(invoice => $invoice,
						user => $loggedinuser,
						date => $date,
						name => $booksellers[0]->{'name'},
						id => $id,
						gst => $gst,
						freight => $freight,
						invoice => $invoice,
						count => $count,
						loop_orders => \@loop_orders,
						totalprice => $totalprice,
						totalfreight => $totalfreight,
						totalquantity => $totalquantity,
						tototal => $tototal,
						gst => $gst,
						grandtot => $tototal+$gst,
						);
output_html_with_http_headers $input, $cookie, $template->output;
