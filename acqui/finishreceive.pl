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
use C4::Auth qw( checkauth );
use JSON qw( encode_json );
use C4::Output;
use C4::Context;
use C4::Acquisition qw( GetInvoice GetOrder ModReceiveOrder );
use C4::Biblio qw( GetFrameworkCode GetMarcFromKohaField TransformHtmlToXml );
use C4::Items qw( GetMarcItem ModItemFromMarc AddItemFromMarc );
use C4::Log qw(logaction);
use C4::Search;

use Koha::Number::Price;
use Koha::Acquisition::Booksellers;
use Koha::Acquisition::Orders;


my $input=CGI->new;
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
my $datereceived     = $input->param('datereceived');
my $invoice_unitprice = $input->param('invoice_unitprice');
my $invoice_currency = $input->param('invoice_currency');
my $invoiceid        = $input->param('invoiceid');
my $invoice          = GetInvoice($invoiceid);
my $invoiceno        = $invoice->{invoicenumber};
my $booksellerid     = $input->param('booksellerid');
my $cnt              = 0;
my $bookfund         = $input->param("bookfund");
my $suggestion_id    = $input->param("suggestionid");
my $order            = GetOrder($ordernumber);
my $new_ordernumber  = $ordernumber;

#bug18723 regression fix
if (C4::Context->preference("CurrencyFormat") eq 'FR') {
    if (rindex($unitprice, '.') ge 0) {
        substr($unitprice, rindex($unitprice, '.'), 1, ',');
    }
    if (rindex($replacementprice,'.') ge 0) {
        substr($replacementprice, rindex($replacementprice, '.'), 1, ',');
    }
}

$unitprice = Koha::Number::Price->new( $unitprice )->unformat();
$replacementprice = Koha::Number::Price->new( $replacementprice )->unformat();
my $order_obj = Koha::Acquisition::Orders->find( $ordernumber );
my $basket = $order_obj->basket;

#need old receivedate if we update the order, parcel.pl only shows the right parcel this way FIXME
if ($quantityrec > $origquantityrec ) {
    my @received_items = ();
    if ($basket->effective_create_items eq 'ordering') {
        @received_items = $input->multi_param('items_to_receive[]');
        my @affects = split q{\|}, C4::Context->preference("AcqItemSetSubfieldsWhenReceived");
        if ( @affects ) {
            my $frameworkcode = GetFrameworkCode($biblionumber);
            my ( $itemfield ) = GetMarcFromKohaField( 'items.itemnumber' );
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

    $order_obj->set(
        {
            order_internalnote    => scalar $input->param("order_internalnote"),
            tax_rate_on_receiving => scalar $input->param("tax_rate"),
            replacementprice      => $replacementprice,
            unitprice             => $unitprice,
            (
                $invoice_unitprice && $invoice_unitprice ne ''
                ? (
                    invoice_unitprice => $invoice_unitprice,
                    invoice_currency  => $invoice_currency,
                  )
                : (
                    invoice_unitprice => undef,
                    invoice_currency  => undef,
                )
            ),
        }
    );

    $order_obj->populate_with_prices_for_receiving();

    # save the quantity received.
    if ( $quantityrec > 0 ) {
        if ( $order_obj->subscriptionid ) {
            # Quantity can only be modified if linked to a subscription
            $order_obj->quantity($quantity); # quantityrec will be deduced from this value in ModReceiveOrder
        }
        ( $datereceived, $new_ordernumber ) = ModReceiveOrder(
            {
                biblionumber     => $biblionumber,
                order            => $order_obj->unblessed,
                quantityreceived => $quantityrec,
                user             => $user,
                invoice          => $invoice,
                budget_id        => $bookfund,
                datereceived     => $datereceived,
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
        }
        my $new_order = Koha::Acquisition::Orders->find( $new_ordernumber );
        foreach my $item (keys %itemhash){
            my $xml = TransformHtmlToXml( $itemhash{$item}->{'tags'},
                                          $itemhash{$item}->{'subfields'},
                                          $itemhash{$item}->{'field_values'},
                                          undef,
                                          undef,
                                          'ITEM' );
            my $record=MARC::Record::new_from_xml($xml, 'UTF-8');
            my (undef,$bibitemnum,$itemnumber) = AddItemFromMarc($record,$biblionumber);
            $new_order->add_item( $itemnumber );
        }
    }
}

my $new_order_object = Koha::Acquisition::Orders->find( $new_ordernumber ); # FIXME we should not need to refetch it
my $items = $new_order_object->items;
while ( my $item = $items->next )  {
    $item->update({
        booksellerid => $booksellerid,
        dateaccessioned => $datereceived,
        datelastseen => $datereceived,
        price => $unitprice,
        replacementprice => $replacementprice,
        replacementpricedate => $datereceived,
    });
}

if ($suggestion_id) {
    my $reason = $input->param("reason") || '';
    my $other_reason = $input->param("other_reason");
    $reason = $other_reason if $reason eq 'other';
    my $suggestion = Koha::Suggestions->find($suggestion_id);
    $suggestion->update( { reason => $reason } ) if $suggestion;
}

# Log the receipt
if (C4::Context->preference("AcquisitionLog")) {
    my $infos = {
        quantityrec      => $quantityrec,
        bookfund         => $bookfund || 'unchanged',
        tax_rate         => $input->param("tax_rate"),
        replacementprice => $replacementprice,
        unitprice        => $unitprice,
        (
            defined $invoice_unitprice && $invoice_unitprice ne ''
            ? (
                invoice_unitprice => $invoice_unitprice,
                invoice_currency  => $invoice_currency,
              )
            : ()
        ),
    };

    logaction(
        'ACQUISITIONS',
        'RECEIVE_ORDER',
        $ordernumber,
        encode_json($infos)
    );
}

print $input->redirect("/cgi-bin/koha/acqui/parcel.pl?invoiceid=$invoiceid");
