#!/usr/bin/perl

#script to add a new item and to mark orders as received
#written 1/3/00 by chris@katipo.co.nz

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

# this script makes the items, addorder.pl has already made the biblio and biblioitem records: MASON


=head1 NAME

finishreceive.pl

=head1 DESCRIPTION
TODO

=head1 CGI PARAMETERS

=over 4

TODO

=back

=cut

use strict;
use C4::Acquisition;
use CGI;
use C4::Interface::CGI::Output;
use C4::Auth;
use C4::Bookseller;

my $input = new CGI;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/finishreceive.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { editcatalogue => 1 },
        debug           => 1,
    }
);

my @biblionumber     = $input->param('biblionumber');
my @ordnum           = $input->param('ordernumber');
my $cost             = $input->param('invoicetotal');
my $locacost             = $input->param('localtotal');
my $invoiceno        = $input->param('invoice');
my @replacement    = $input->param('actual');
my @gst            = $input->param('gstrate');
my $freight        = $input->param('actualfreight');
my @freightperitem = $input->param('freight');
my $supplierid     = $input->param('supplierid');
my @title         = $input->param('title');
my $currencyrate=$input->param('currencyrate');
my @bookfund      = $input->param('bookfund');
my @discount     = $input->param('discount');
my @quantrec      = $input->param('received');
my $totalreceived=$input->param('totalreceived');
my $incgst=$input->param('incgst');
my $ecost;
my $unitprice;
my $listprice;

my @supplier=GetBookSeller($supplierid);
my $count=scalar @quantrec;
my @additems;

 for (my $i=0; $i<$count;$i++){
 $freightperitem[$i]=$freight/$totalreceived unless  $freightperitem[$i];
$listprice=$replacement[$i];
  $replacement[$i]= $replacement[$i]*$currencyrate;
	if ($incgst){
	$ecost= ($replacement[$i]*100/($gst[$i]+100))*(100 - $discount[$i])/100;
	}else{
	$ecost= $replacement[$i]*(100 - $discount[$i])/100;
	}
$unitprice=$ecost + $ecost*$gst[$i]/100;
    	if ( $quantrec[$i] != 0 ) {
       	 # save the quantity recieved.
        	ModReceiveOrder( $biblionumber[$i], $ordnum[$i], $quantrec[$i], $unitprice,
            $invoiceno, $freightperitem[$i], $replacement[$i] ,$listprice,$input );   
  	push @additems,{biblionumber=>$biblionumber[$i],itemcount=>$quantrec[$i], title=>$title[$i],supplier=>$supplier[0]->{name},rrp=>$replacement[$i],};

	}
}
$template->param(loopbiblios => \@additems,);
                      
 output_html_with_http_headers $input, $cookie, $template->output;