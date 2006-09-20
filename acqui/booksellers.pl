#!/usr/bin/perl

#script to show suppliers and orders
#written by chris@katipo.co.nz 23/2/2000

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

# $Id$

=head1 NAME

booksellers.pl

=head1 DESCRIPTION

this script displays the list of suppliers & orders like C<$supplier> given on input arg.
thus, this page brings differents features like to display supplier's details,
to add an order for a specific supplier or to just add a new supplier.

=head1 CGI PARAMETERS

=over 4

=item supplier

C<$supplier> is the suplier we have to search order.
=back

=item op

C<OP> can be equals to 'close' if we have to close a basket before building the page.

=item basket

the C<basket> we have to close if op is equal to 'close'.

=back

=cut

use strict;
use C4::Auth;
use CGI;
use C4::Interface::CGI::Output;
use C4::Acquisition;
use C4::Date;
use C4::Bookseller;

my $query = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/booksellers.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 1 },
        debug           => 1,
    }
);

#parameters
my $supplier = $query->param('supplier');

my @suppliers = GetBookSeller($supplier);
my $count = scalar @suppliers;

# check if we have to "close" a basket before building page
my $op     = $query->param('op');
my $basketno = $query->param('basketno');
if ( $op eq 'close' ) {
    CloseBasket($basketno);
}

#build result page
my $toggle = 0;
 my $ordcount;
my @loop_suppliers;
for ( my $i = 0 ; $i < $count ; $i++ ) {
   my $orders  = GetPendingOrders( $suppliers[$i]->{'id'} );
 my    $ordercount = scalar @$orders;
$ordcount+=$ordercount;
    my %line;
    if ( $toggle == 0 ) {
        $line{even} = 1;
        $toggle = 1;
    }
    else {
        $line{even} = 0;
        $toggle = 0;
    }
    $line{supplierid} = $suppliers[$i]->{'id'};
    $line{name}       = $suppliers[$i]->{'name'};
    $line{active}     = $suppliers[$i]->{'active'};
    $line{ordcount}=$ordercount;	
    my @loop_basket;
     foreach my $order(@$orders){
        push @loop_basket, $order;
    }
    $line{loop_basket} = \@loop_basket;
    push @loop_suppliers, \%line;
}
$template->param(
    loop_suppliers          => \@loop_suppliers,
    supplier                => $supplier,
    count                   => $ordcount,
    intranetcolorstylesheet =>
    C4::Context->preference("intranetcolorstylesheet"),
    intranetstylesheet => C4::Context->preference("intranetstylesheet"),
    IntranetNav        => C4::Context->preference("IntranetNav"),
);

output_html_with_http_headers $query, $cookie, $template->output;
