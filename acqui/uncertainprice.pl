#!/usr/bin/perl

#script to show a list of orders with uncertain prices for a bookseller
#the script also allows to edit the prices and uncheck the uncertainprice property of them
#written by john.soros@biblibre.com 01/10/2008

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

uncertainprice.pl

=head1 DESCRIPTION

 This script displays all the orders with uncertain prices for a given bookseller, it also lets the user modify the unitprice and uncertainprice properties of the order

=head1 CGI PARAMETERS

=over 4

=item $booksellerid

The bookseller who we want to display the orders of.

=back

=cut


use strict;
use warnings;

use C4::Input;
use C4::Auth;
use C4::Output;
use CGI;

use C4::Bookseller qw/GetBookSellerFromId/;
use C4::Bookseller::Contact;
use C4::Acquisition qw/SearchOrders GetOrder ModOrder/;
use C4::Biblio qw/GetBiblioData/;

my $input=new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui/uncertainprice.tt",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired   => { acquisition => 'order_manage' },
			     debug => 1,
                });

my $booksellerid = $input->param('booksellerid');
my $basketno     = $input->param('basketno');
my $op = $input->param('op');
my $owner = $input->param('owner') || 0 ; # flag to see only "my" orders, or everyone orders
my $bookseller = &GetBookSellerFromId($booksellerid);

#show all orders that have uncertain price for the bookseller
my $pendingorders = SearchOrders({
    booksellerid => $booksellerid,
    owner => $owner,
    basketno => $basketno,
    pending => 1,
});
my @orders;

foreach my $order (@{$pendingorders}) {
    if ( $order->{'uncertainprice'} ) {
        my $bibdata = &GetBiblioData($order->{'biblionumber'});
        $order->{'bibisbn'} = $bibdata->{'isbn'};
        $order->{'bibpublishercode'} = $bibdata->{'publishercode'};
        $order->{'bibpublicationyear'} = $bibdata->{'publicationyear'};
        $order->{'bibtitle'} = $bibdata->{'title'};
        $order->{'bibauthor'} = $bibdata->{'author'};
        $order->{'surname'} = $order->{'surname'};
        $order->{'firstname'} = $order->{'firstname'};
        my $order_as_from_db=GetOrder($order->{ordernumber});
        $order->{'quantity'} = $order_as_from_db->{'quantity'};
        $order->{'listprice'} = $order_as_from_db->{'listprice'};
        push(@orders, $order);
    }
}
if ( $op eq 'validate' ) {
    $template->param( validate => 1);
    my $count = scalar(@orders);
    for (my $i=0; $i < $count; $i++) {
        my $order = pop(@orders);
        my $ordernumber = $order->{ordernumber};
        my $order_as_from_db=GetOrder($order->{ordernumber});
        $order->{'listprice'} = $input->param('price'.$ordernumber);
        $order->{'ecost'}= $input->param('price'.$ordernumber) - (($input->param('price'.$ordernumber) /100) * $bookseller->{'discount'});
        $order->{'rrp'} = $input->param('price'.$ordernumber);
        $order->{'quantity'}=$input->param('qty'.$ordernumber);
        $order->{'uncertainprice'}=$input->param('uncertainprice'.$ordernumber);
        ModOrder($order);
    }
}

$template->param( uncertainpriceorders => \@orders,
                                   booksellername => "".$bookseller->{'name'},
                                   booksellerid => $bookseller->{'id'},
                                   booksellerpostal =>$bookseller->{'postal'},
                                   bookselleraddress1 => $bookseller->{'address1'},
                                   bookselleraddress2 => $bookseller->{'address2'},
                                   bookselleraddress3 => $bookseller->{'address3'},
                                   bookselleraddress4 => $bookseller->{'address4'},
                                   booksellerphone =>$bookseller->{'phone'},
                                   booksellerfax => $bookseller->{'fax'},
                                   booksellerurl => $bookseller->{'url'},
                                   booksellernotes => $bookseller->{'notes'},
                                   basketcount   => $bookseller->{'basketcount'},
                                   subscriptioncount   => $bookseller->{'subscriptioncount'},
                                   owner => $owner,
                                   scriptname => "/cgi-bin/koha/acqui/uncertainprice.pl");
$template->{'VARS'}->{'contacts'} = $bookseller->{'contacts'};
output_html_with_http_headers $input, $cookie, $template->output;
