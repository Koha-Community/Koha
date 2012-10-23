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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Context;
use C4::Acquisition;
use C4::Biblio;
use C4::Bookseller;
use C4::Items;
use C4::Search;
use List::MoreUtils qw/any/;

my $input=new CGI;
my $flagsrequired = {acquisition => 'order_receive'};

checkauth($input, 0, $flagsrequired, 'intranet');

my $user             = $input->remote_user;
my $biblionumber     = $input->param('biblionumber');
my $biblioitemnumber = $input->param('biblioitemnumber');
my $ordernumber      = $input->param('ordernumber');
my $origquantityrec  = $input->param('origquantityrec');
my $quantityrec      = $input->param('quantityrec');
my $quantity         = $input->param('quantity');
my $unitprice        = $input->param('cost');
my $invoiceid        = $input->param('invoiceid');
my $invoice          = GetInvoice($invoiceid);
my $invoiceno        = $invoice->{invoicenumber};
my $datereceived     = $invoice->{shipmentdate};
my $booksellerid     = $input->param('booksellerid');
my $cnt              = 0;
my $ecost            = $input->param('ecost');
my $rrp              = $input->param('rrp');
my $note             = $input->param("note");
my $order            = GetOrder($ordernumber);

#need old recievedate if we update the order, parcel.pl only shows the right parcel this way FIXME
if ($quantityrec > $origquantityrec ) {
    my @received_items = ();
    if(C4::Context->preference('AcqCreateItem') eq 'ordering') {
        @received_items = $input->param('items_to_receive');
    }

    $order->{rrp} = $rrp;
    $order->{ecost} = $ecost;
    $order->{unitprice} = $unitprice;
    my $bookseller = C4::Bookseller::GetBookSellerFromId($booksellerid);
    if ( $bookseller->{listincgst} ) {
        if ( not $bookseller->{invoiceincgst} ) {
            $order->{rrp} = $order->{rrp} * ( 1 + $order->{gstrate} );
            $order->{ecost} = $order->{ecost} * ( 1 + $order->{gstrate} );
            $order->{unitprice} = $order->{unitprice} * ( 1 + $order->{gstrate} );
        }
    } else {
        if ( $bookseller->{invoiceincgst} ) {
            $order->{rrp} = $order->{rrp} / ( 1 + $order->{gstrate} );
            $order->{ecost} = $order->{ecost} / ( 1 + $order->{gstrate} );
            $order->{unitprice} = $order->{unitprice} / ( 1 + $order->{gstrate} );
        }
    }

    my $new_ordernumber = $ordernumber;
    # save the quantity received.
    if ( $quantityrec > 0 ) {
        ($datereceived, $new_ordernumber) = ModReceiveOrder(
            $biblionumber,
            $ordernumber,
            $quantityrec,
            $user,
            $order->{unitprice},
            $order->{ecost},
            $invoiceid,
            $order->{rrp},
            undef,
            $datereceived,
            \@received_items,
        );
    }

    # now, add items if applicable
    if (C4::Context->preference('AcqCreateItem') eq 'receiving') {

        my @tags         = $input->param('tag');
        my @subfields    = $input->param('subfield');
        my @field_values = $input->param('field_value');
        my @serials      = $input->param('serial');
        my @itemid       = $input->param('itemid');
        my @ind_tag      = $input->param('ind_tag');
        my @indicator    = $input->param('indicator');
        #Rebuilding ALL the data for items into a hash
        # parting them on $itemid.
        my %itemhash;
        my $countdistinct;
        my $range=scalar(@itemid);
        for (my $i=0; $i<$range; $i++){
            unless ($itemhash{$itemid[$i]}){
            $countdistinct++;
            }
            push @{$itemhash{$itemid[$i]}->{'tags'}},$tags[$i];
            push @{$itemhash{$itemid[$i]}->{'subfields'}},$subfields[$i];
            push @{$itemhash{$itemid[$i]}->{'field_values'}},$field_values[$i];
            push @{$itemhash{$itemid[$i]}->{'ind_tag'}},$ind_tag[$i];
            push @{$itemhash{$itemid[$i]}->{'indicator'}},$indicator[$i];
        }
        foreach my $item (keys %itemhash){
            my $xml = TransformHtmlToXml( $itemhash{$item}->{'tags'},
                                          $itemhash{$item}->{'subfields'},
                                          $itemhash{$item}->{'field_values'},
                                          $itemhash{$item}->{'ind_tag'},
                                          $itemhash{$item}->{'indicator'},'ITEM');
            my $record=MARC::Record::new_from_xml($xml, 'UTF-8');
            my (undef,$bibitemnum,$itemnumber) = AddItemFromMarc($record,$biblionumber);
            NewOrderItem($itemnumber, $new_ordernumber);
        }
    }

}

update_item( $_ ) foreach GetItemnumbersFromOrder( $ordernumber );

print $input->redirect("/cgi-bin/koha/acqui/parcel.pl?invoiceid=$invoiceid");

################################ End of script ################################

sub update_item {
    my ( $itemnumber ) = @_;

    ModItem( {
        booksellerid         => $booksellerid,
        dateaccessioned      => $datereceived,
        price                => $unitprice,
        replacementprice     => $rrp,
        replacementpricedate => $datereceived,
    }, $biblionumber, $itemnumber );
}
