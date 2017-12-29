#!/usr/bin/perl

#script to add a new item and to mark orders as received
#written 1/3/00 by chris@katipo.co.nz

# Copyright 2000-2002 Katipo Communications
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

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Auth;
use C4::Output;
use C4::Context;
use C4::Acquisition;
use C4::Biblio;
use C4::Items;
use C4::Search;

use Koha::Number::Price;
use Koha::Acquisition::Booksellers;
use Koha::Acquisition::Orders;

use List::MoreUtils qw/any/;

my $input=new CGI;
my $flagsrequired = {acquisition => 'order_receive'};

checkauth($input, 0, $flagsrequired, 'intranet');

my $user             = $input->remote_user;
my $biblionumber     = $input->param('biblionumber');
my $ordernumber      = $input->param('ordernumber');
my $origquantityrec  = $input->param('origquantityrec');
my $quantityrec      = $input->param('quantityrec');
my $quantity         = $input->param('quantity');
my $unitprice        = $input->param('unitprice');
my $replacementprice = $input->param('replacementprice');
my $datereceived     = $input->param('datereceived'),
my $invoiceid        = $input->param('invoiceid');
my $invoice          = GetInvoice($invoiceid);
my $invoiceno        = $invoice->{invoicenumber};
my $booksellerid     = $input->param('booksellerid');
my $cnt              = 0;
my $bookfund         = $input->param("bookfund");
my $order            = GetOrder($ordernumber);
my $new_ordernumber  = $ordernumber;

$unitprice = Koha::Number::Price->new( $unitprice )->unformat();
$replacementprice = Koha::Number::Price->new( $replacementprice )->unformat();
warn "Replacement $replacementprice";
my $basket = Koha::Acquisition::Orders->find( $ordernumber )->basket;

#need old receivedate if we update the order, parcel.pl only shows the right parcel this way FIXME
if ($quantityrec > $origquantityrec ) {
    my @received_items = ();
    if ($basket->effective_create_items eq 'ordering') {
        @received_items = $input->param('items_to_receive');
        my @affects = split q{\|}, C4::Context->preference("AcqItemSetSubfieldsWhenReceived");
        if ( @affects ) {
            my $frameworkcode = GetFrameworkCode($biblionumber);
            my ( $itemfield ) = GetMarcFromKohaField( 'items.itemnumber', $frameworkcode );
            for my $in ( @received_items ) {
                my $item = C4::Items::GetMarcItem( $biblionumber, $in );
                for my $affect ( @affects ) {
                    my ( $sf, $v ) = split q{=}, $affect, 2;
                    foreach ( $item->field($itemfield) ) {
                        $_->update( $sf => $v );
                    }
                }
                C4::Items::ModItemFromMarc( $item, $biblionumber, $in );
            }
        }
    }

    $order->{order_internalnote} = $input->param("order_internalnote");
    $order->{tax_rate_on_receiving} = $input->param("tax_rate");
    $order->{replacementprice} = $replacementprice;
    $order->{unitprice} = $unitprice;

    $order = C4::Acquisition::populate_order_with_prices(
        {
            order => $order,
            booksellerid => $booksellerid,
            receiving => 1
        }
    );

    # save the quantity received.
    if ( $quantityrec > 0 ) {
        ( $datereceived, $new_ordernumber ) = ModReceiveOrder(
            {
                biblionumber     => $biblionumber,
                order            => $order,
                quantityreceived => $quantityrec,
                user             => $user,
                invoice          => $invoice,
                budget_id        => $bookfund,
                received_items   => \@received_items,
            }
        );
    }

    # now, add items if applicable
    if ($basket->effective_create_items eq 'receiving') {

        my @tags         = $input->multi_param('tag');
        my @subfields    = $input->multi_param('subfield');
        my @field_values = $input->multi_param('field_value');
        my @serials      = $input->multi_param('serial');
        my @itemid       = $input->multi_param('itemid');
        my @ind_tag      = $input->multi_param('ind_tag');
        my @indicator    = $input->multi_param('indicator');
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
        my $new_order = Koha::Acquisition::Orders->find( $new_ordernumber );
        foreach my $item (keys %itemhash){
            my $xml = TransformHtmlToXml( $itemhash{$item}->{'tags'},
                                          $itemhash{$item}->{'subfields'},
                                          $itemhash{$item}->{'field_values'},
                                          $itemhash{$item}->{'indicator'},
                                          $itemhash{$item}->{'ind_tag'},
                                          'ITEM' );
            my $record=MARC::Record::new_from_xml($xml, 'UTF-8');
            my (undef,$bibitemnum,$itemnumber) = AddItemFromMarc($record,$biblionumber);
            $new_order->add_item( $itemnumber );
        }
    }
}

ModItem(
    {
        booksellerid         => $booksellerid,
        dateaccessioned      => $datereceived,
        datelastseen         => $datereceived,
        price                => $unitprice,
        replacementprice     => $replacementprice,
        replacementpricedate => $datereceived,
    },
    $biblionumber,
    $_
) foreach GetItemnumbersFromOrder($new_ordernumber);

print $input->redirect("/cgi-bin/koha/acqui/parcel.pl?invoiceid=$invoiceid&sticky_filters=1");
