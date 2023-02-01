package Koha::EDI;

# Copyright 2014,2015 PTFS-Europe Ltd
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

use strict;
use warnings;
use base qw(Exporter);
use utf8;
use Carp qw( carp );
use English qw{ -no_match_vars };
use Business::ISBN;
use DateTime;
use C4::Context;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use C4::Acquisition qw( ModOrder NewBasket );
use C4::Suggestions qw( ModSuggestion );
use C4::Biblio qw(
    AddBiblio
    GetFrameworkCode
    GetMarcFromKohaField
    TransformKohaToMarc
);
use Koha::Edifact::Order;
use Koha::Edifact;
use C4::Log qw( logaction );
use Log::Log4perl;
use Text::Unidecode qw( unidecode );
use Koha::Plugins; # Adds plugin dirs to @INC
use Koha::Plugins::Handler;
use Koha::Acquisition::Baskets;
use Koha::Acquisition::Booksellers;

our $VERSION = 1.1;

our (@ISA, @EXPORT_OK);
BEGIN {
    require Exporter;
    @ISA = qw(Exporter);
    @EXPORT_OK = qw(
      process_quote
      process_invoice
      process_ordrsp
      create_edi_order
      get_edifact_ean
    );
};

sub create_edi_order {
    my $parameters = shift;
    my $basketno   = $parameters->{basketno};
    my $ean        = $parameters->{ean};
    my $branchcode = $parameters->{branchcode};
    my $noingest   = $parameters->{noingest};
    if ( !$basketno || !$ean ) {
        carp 'create_edi_order called with no basketno or ean';
        return;
    }

    my $schema = Koha::Database->new()->schema();

    my @orderlines = $schema->resultset('Aqorder')->search(
        {
            basketno    => $basketno,
            orderstatus => 'new',
        }
    )->all;

    if ( !@orderlines ) {
        carp "No orderlines for basket $basketno";
        return;
    }

    my $vendor = $schema->resultset('VendorEdiAccount')->search(
        {
            vendor_id => $orderlines[0]->basketno->booksellerid->id,
        }
    )->single;

    my $ean_search_keys = { ean => $ean, };
    if ($branchcode) {
        $ean_search_keys->{branchcode} = $branchcode;
    }
    my $ean_obj =
      $schema->resultset('EdifactEan')->search($ean_search_keys)->single;

    # If no branch specific each can be found, look for a default ean
    unless ($ean_obj) {
        $ean_obj = $schema->resultset('EdifactEan')->search(
            {
                ean        => $ean,
                branchcode => undef,
            }
        )->single;
    }

    my $dbh     = C4::Context->dbh;
    my $arr_ref = $dbh->selectcol_arrayref(
'select id from edifact_messages where basketno = ? and message_type = \'QUOTE\'',
        {}, $basketno
    );
    my $response = @{$arr_ref} ? 1 : 0;

    my $edifact_order_params = {
        orderlines  => \@orderlines,
        vendor      => $vendor,
        ean         => $ean_obj,
        is_response => $response,
    };

    my $edifact;
    if ( $vendor->plugin ) {
        $edifact = Koha::Plugins::Handler->run(
            {
                class  => $vendor->plugin,
                method => 'edifact_order',
                params => {
                    params => $edifact_order_params,
                }
            }
        );
    }
    else {
        $edifact = Koha::Edifact::Order->new($edifact_order_params);
    }

    return unless $edifact;

    my $order_file = $edifact->encode();

    # ingest result
    if ($order_file) {
        my $m = unidecode($order_file);  # remove diacritics and non-latin chars
        if ($noingest) {                 # allows scripts to produce test files
            return $m;
        }
        my $order = {
            message_type  => 'ORDERS',
            raw_msg       => $m,
            vendor_id     => $vendor->vendor_id,
            status        => 'Pending',
            basketno      => $basketno,
            filename      => $edifact->filename(),
            transfer_date => $edifact->msg_date_string(),
            edi_acct      => $vendor->id,

        };
        $schema->resultset('EdifactMessage')->create($order);
        return 1;
    }

    return;
}

sub process_ordrsp {
    my $response_message = shift;
    $response_message->status('processing');
    $response_message->update;
    my $schema = Koha::Database->new()->schema();
    my $logger = Log::Log4perl->get_logger();
    my $vendor_acct;
    my $edi =
      Koha::Edifact->new( { transmission => $response_message->raw_msg, } );
    my $messages = $edi->message_array();

    if ( @{$messages} ) {
        foreach my $msg ( @{$messages} ) {
            my $lines = $msg->lineitems();
            foreach my $line ( @{$lines} ) {
                my $ordernumber = $line->ordernumber();

       # action cancelled:change_requested:no_action:accepted:not_found:recorded
                my $action = $line->action_notification();
                if ( $action eq 'cancelled' ) {
                    my $reason = $line->coded_orderline_text();
                    ModOrder(
                        {
                            ordernumber             => $ordernumber,
                            cancellationreason      => $reason,
                            orderstatus             => 'cancelled',
                            datecancellationprinted => dt_from_string()->ymd(),
                        }
                    );
                }
                else {    # record order as due with possible further info

                    my $report     = $line->coded_orderline_text();
                    my $date_avail = $line->availability_date();
                    $report ||= q{};
                    if ($date_avail) {
                        $report .= " Available: $date_avail";
                    }
                    ModOrder(
                        {
                            ordernumber      => $ordernumber,
                            suppliers_report => $report,
                        }
                    );
                }
            }
        }
    }

    $response_message->status('received');
    $response_message->update;
    return;
}

sub process_invoice {
    my $invoice_message = shift;
    $invoice_message->status('processing');
    $invoice_message->update;
    my $schema = Koha::Database->new()->schema();
    my $logger = Log::Log4perl->get_logger();
    my $vendor_acct;

    my $plugin_class = $invoice_message->edi_acct()->plugin();

    # Plugin has its own invoice processor, only run it and not the standard invoice processor below
    if ( $plugin_class ) {
        eval "require $plugin_class"; # Import the class, eval is needed because requiring a string doesn't work like requiring a bareword
        my $plugin = $plugin_class->new();
        if ( $plugin->can('edifact_process_invoice') ) {
            Koha::Plugins::Handler->run(
                {
                    class  => $plugin_class,
                    method => 'edifact_process_invoice',
                    params => {
                        invoice => $invoice_message,
                    }
                }
            );
            return;
        }
    }

    my $edi_plugin;
    if ( $plugin_class ) {
        $edi_plugin = Koha::Plugins::Handler->run(
            {
                class  => $plugin_class,
                method => 'edifact',
                params => {
                    invoice_message => $invoice_message,
                    transmission => $invoice_message->raw_msg,
                }
            }
        );
    }

    my $edi = $edi_plugin ||
      Koha::Edifact->new( { transmission => $invoice_message->raw_msg, } );

    my $messages = $edi->message_array();

    if ( @{$messages} ) {

        # BGM contains an invoice number
        foreach my $msg ( @{$messages} ) {
            my $invoicenumber  = $msg->docmsg_number();
            my $shipmentcharge = $msg->shipment_charge();
            my $msg_date       = $msg->message_date;
            my $tax_date       = $msg->tax_point_date;
            if ( !defined $tax_date || $tax_date !~ m/^\d{8}/xms ) {
                $tax_date = $msg_date;
            }

            my $vendor_ean = $msg->supplier_ean;
            if ( !defined $vendor_acct || $vendor_ean ne $vendor_acct->san ) {
                $vendor_acct = $schema->resultset('VendorEdiAccount')->search(
                    {
                        san => $vendor_ean,
                    }
                )->single;
            }
            if ( !$vendor_acct ) {
                carp
"Cannot find vendor with ean $vendor_ean for invoice $invoicenumber in $invoice_message->filename";
                next;
            }
            $invoice_message->edi_acct( $vendor_acct->id );
            $logger->trace("Adding invoice:$invoicenumber");
            my $new_invoice = $schema->resultset('Aqinvoice')->create(
                {
                    invoicenumber         => $invoicenumber,
                    booksellerid          => $invoice_message->vendor_id,
                    shipmentdate          => $msg_date,
                    billingdate           => $tax_date,
                    shipmentcost          => $shipmentcharge,
                    shipmentcost_budgetid => $vendor_acct->shipment_budget,
                    message_id            => $invoice_message->id,
                }
            );
            my $invoiceid = $new_invoice->invoiceid;
            $logger->trace("Added as invoiceno :$invoiceid");
            my $lines = $msg->lineitems();

            foreach my $line ( @{$lines} ) {
                my $ordernumber = $line->ordernumber;
                $logger->trace( "Receipting order:$ordernumber Qty: ",
                    $line->quantity );

                my $order = $schema->resultset('Aqorder')->find($ordernumber);

      # ModReceiveOrder does not validate that $ordernumber exists validate here
                if ($order) {

                    # check suggestions
                    my $s = $schema->resultset('Suggestion')->search(
                        {
                            biblionumber => $order->biblionumber->biblionumber,
                        }
                    )->single;
                    if ($s) {
                        ModSuggestion(
                            {
                                suggestionid => $s->suggestionid,
                                STATUS       => 'AVAILABLE',
                            }
                        );
                    }
                    # If quantity_invoiced is present use it in preference
                    my $quantity = $line->quantity_invoiced;
                    if (!$quantity) {
                        $quantity = $line->quantity;
                    }

                    my ( $price, $price_excl_tax ) = _get_invoiced_price($line, $quantity);
                    my $tax_rate = $line->tax_rate;
                    if ($tax_rate && $tax_rate->{rate} != 0) {
                       $tax_rate->{rate} /= 100;
                    }

                    if ( $order->quantity > $quantity ) {
                        my $ordered = $order->quantity;

                        # part receipt
                        $order->orderstatus('partial');
                        $order->quantity( $ordered - $quantity );
                        $order->update;
                        my $received_order = $order->copy(
                            {
                                ordernumber            => undef,
                                quantity               => $quantity,
                                quantityreceived       => $quantity,
                                orderstatus            => 'complete',
                                unitprice              => $price,
                                unitprice_tax_included => $price,
                                unitprice_tax_excluded => $price_excl_tax,
                                invoiceid              => $invoiceid,
                                datereceived           => $msg_date,
                                tax_rate_on_receiving  => $tax_rate->{rate},
                                tax_value_on_receiving => $quantity * $price_excl_tax * $tax_rate->{rate},
                            }
                        );
                        transfer_items( $schema, $line, $order,
                            $received_order, $quantity );
                        receipt_items( $schema, $line,
                            $received_order->ordernumber, $quantity );
                    }
                    else {    # simple receipt all copies on order
                        $order->quantityreceived( $quantity );
                        $order->datereceived($msg_date);
                        $order->invoiceid($invoiceid);
                        $order->unitprice($price);
                        $order->unitprice_tax_excluded($price_excl_tax);
                        $order->unitprice_tax_included($price);
                        $order->tax_rate_on_receiving($tax_rate->{rate});
                        $order->tax_value_on_receiving( $quantity * $price_excl_tax * $tax_rate->{rate});
                        $order->orderstatus('complete');
                        $order->update;
                        receipt_items( $schema, $line, $ordernumber, $quantity );
                    }
                }
                else {
                    $logger->error(
                        "No order found for $ordernumber Invoice:$invoicenumber"
                    );
                    next;
                }

            }

        }
    }

    $invoice_message->status('received');
    $invoice_message->update;    # status and basketno link
    return;
}

sub _get_invoiced_price {
    my $line       = shift;
    my $qty        = shift;
    my $line_total = $line->amt_total;
    my $excl_tax   = $line->amt_lineitem;

    # If no tax some suppliers omit the total owed
    # If no total given calculate from cost exclusive of tax
    # + tax amount (if present, sometimes omitted if 0 )
    if ( !defined $line_total ) {
        my $x = $line->amt_taxoncharge;
        if ( !defined $x ) {
            $x = 0;
        }
        $line_total = $excl_tax + $x;
    }

    # invoices give amounts per orderline, Koha requires that we store
    # them per item
    if ( $qty != 1 ) {
        return ( $line_total / $qty, $excl_tax / $qty );
    }
    return ( $line_total, $excl_tax );    # return as is for most common case
}

sub receipt_items {
    my ( $schema, $inv_line, $ordernumber, $quantity ) = @_;
    my $logger   = Log::Log4perl->get_logger();

    # itemnumber is not a foreign key ??? makes this a bit cumbersome
    my @item_links = $schema->resultset('AqordersItem')->search(
        {
            ordernumber => $ordernumber,
        }
    );
    my %branch_map;
    foreach my $ilink (@item_links) {
        my $item = $schema->resultset('Item')->find( $ilink->itemnumber );
        if ( !$item ) {
            my $i = $ilink->itemnumber;
            $logger->warn(
                "Cannot find aqorder item for $i :Order:$ordernumber");
            next;
        }
        my $b = $item->get_column('homebranch');
        if ( !exists $branch_map{$b} ) {
            $branch_map{$b} = [];
        }
        push @{ $branch_map{$b} }, $item;
    }

    # Handling for 'AcqItemSetSubfieldsWhenReceived'
    my @affects;
    my $biblionumber;
    my $itemfield;
    if ( C4::Context->preference('AcqCreateItem') eq 'ordering' ) {
        @affects = split q{\|},
          C4::Context->preference("AcqItemSetSubfieldsWhenReceived");
        if (@affects) {
            my $order = Koha::Acquisition::Orders->find($ordernumber);
            $biblionumber = $order->biblionumber;
            my $frameworkcode = GetFrameworkCode($biblionumber);
            ($itemfield) = GetMarcFromKohaField( 'items.itemnumber',
                $frameworkcode );
        }
    }

    my $gir_occurrence = 0;
    while ( $gir_occurrence < $quantity ) {
        my $branch = $inv_line->girfield( 'branch', $gir_occurrence );
        my $item = shift @{ $branch_map{$branch} };
        if ($item) {
            my $barcode = $inv_line->girfield( 'barcode', $gir_occurrence );
            if ( $barcode && !$item->barcode ) {
                my $rs = $schema->resultset('Item')->search(
                    {
                        barcode => $barcode,
                    }
                );
                if ( $rs->count > 0 ) {
                    $logger->warn("Barcode $barcode is a duplicate");
                }
                else {

                    $logger->trace("Adding barcode $barcode");
                    $item->barcode($barcode);
                }
            }

            # Handling for 'AcqItemSetSubfieldsWhenReceived'
            if (@affects) {
                my $item_marc = C4::Items::GetMarcItem( $biblionumber, $item->itemnumber );
                for my $affect (@affects) {
                    my ( $sf, $v ) = split q{=}, $affect, 2;
                    foreach ( $item_marc->field($itemfield) ) {
                        $_->update( $sf => $v );
                    }
                }
                C4::Items::ModItemFromMarc( $item_marc, $biblionumber, $item->itemnumber );
            }

            $item->update;
        }
        else {
            $logger->warn("Unmatched item at branch:$branch");
        }
        ++$gir_occurrence;
    }
    return;

}

sub transfer_items {
    my ( $schema, $inv_line, $order_from, $order_to, $quantity ) = @_;

    # Transfer x items from the orig order to a completed partial order
    my $gocc     = 0;
    my %mapped_by_branch;
    while ( $gocc < $quantity ) {
        my $branch = $inv_line->girfield( 'branch', $gocc );
        if ( !exists $mapped_by_branch{$branch} ) {
            $mapped_by_branch{$branch} = 1;
        }
        else {
            $mapped_by_branch{$branch}++;
        }
        ++$gocc;
    }
    my $logger = Log::Log4perl->get_logger();
    my $o1     = $order_from->ordernumber;
    my $o2     = $order_to->ordernumber;
    $logger->warn("transferring $quantity copies from order $o1 to order $o2");

    my @item_links = $schema->resultset('AqordersItem')->search(
        {
            ordernumber => $order_from->ordernumber,
        }
    );
    foreach my $ilink (@item_links) {
        my $ino      = $ilink->itemnumber;
        my $item     = $schema->resultset('Item')->find( $ilink->itemnumber );
        my $i_branch = $item->get_column('homebranch');
        if ( exists $mapped_by_branch{$i_branch}
            && $mapped_by_branch{$i_branch} > 0 )
        {
            $ilink->ordernumber( $order_to->ordernumber );
            $ilink->update;
            --$quantity;
            --$mapped_by_branch{$i_branch};
            $logger->warn("Transferred item " . $item->itemnumber);
        }
        else {
            $logger->warn("Skipped item " . $item->itemnumber);
        }
        if ( $quantity < 1 ) {
            last;
        }
    }

    return;
}

sub process_quote {
    my $quote = shift;

    $quote->status('processing');
    $quote->update;

    my $edi = Koha::Edifact->new( { transmission => $quote->raw_msg, } );

    my $messages       = $edi->message_array();
    my $process_errors = 0;
    my $logger         = Log::Log4perl->get_logger();
    my $schema         = Koha::Database->new()->schema();
    my $message_count  = 0;
    my @added_baskets;    # if auto & multiple baskets need to order all

    if ( @{$messages} && $quote->vendor_id ) {
        foreach my $msg ( @{$messages} ) {
            ++$message_count;
            my $basketno =
              NewBasket( $quote->vendor_id, 0, $quote->filename, q{},
                q{} . q{} );
            push @added_baskets, $basketno;
            if ( $message_count > 1 ) {
                my $m_filename = $quote->filename;
                $m_filename .= "_$message_count";
                $schema->resultset('EdifactMessage')->create(
                    {
                        message_type  => $quote->message_type,
                        transfer_date => $quote->transfer_date,
                        vendor_id     => $quote->vendor_id,
                        edi_acct      => $quote->edi_acct,
                        status        => 'recmsg',
                        basketno      => $basketno,
                        raw_msg       => q{},
                        filename      => $m_filename,
                    }
                );
            }
            else {
                $quote->basketno($basketno);
            }
            $logger->trace("Created basket :$basketno");
            my $items  = $msg->lineitems();
            my $refnum = $msg->message_refno;

            for my $item ( @{$items} ) {
                if ( !quote_item( $item, $quote, $basketno ) ) {
                    ++$process_errors;
                }
            }
        }
    }
    my $status = 'received';
    if ($process_errors) {
        $status = 'error';
    }

    $quote->status($status);
    $quote->update;    # status and basketno link
                       # Do we automatically generate orders for this vendor
    my $v = $schema->resultset('VendorEdiAccount')->search(
        {
            vendor_id => $quote->vendor_id,
        }
    )->single;
    if ( $v->auto_orders ) {
        for my $b (@added_baskets) {
            create_edi_order(
                {
                    ean      => $messages->[0]->buyer_ean,
                    basketno => $b,
                }
            );
            Koha::Acquisition::Baskets->find($b)->close;
            # Log the approval
            if (C4::Context->preference("AcquisitionLog")) {
                my $approved = Koha::Acquisition::Baskets->find( $b );
                logaction(
                    'ACQUISITIONS',
                    'APPROVE_BASKET',
                    $b,
                    to_json($approved->unblessed)
                );
            }
        }
    }


    return;
}

sub quote_item {
    my ( $item, $quote, $basketno ) = @_;

    my $schema = Koha::Database->new()->schema();
    my $logger = Log::Log4perl->get_logger();

    # $basketno is the return from AddBasket in the calling routine
    # So this call should not fail unless that has
    my $basket = Koha::Acquisition::Baskets->find( $basketno );
    unless ( $basket ) {
        $logger->error('Skipping order creation no valid basketno');
        return;
    }
    $logger->trace( 'Checking db for matches with ', $item->item_number_id() );
    my $bib = _check_for_existing_bib( $item->item_number_id() );
    if ( !defined $bib ) {
        $bib = {};
        my $bib_record = _create_bib_from_quote( $item, $quote );
        ( $bib->{biblionumber}, $bib->{biblioitemnumber} ) =
          AddBiblio( $bib_record, q{} );
        $logger->trace("New biblio added $bib->{biblionumber}");
    }
    else {
        $logger->trace("Match found: $bib->{biblionumber}");
    }

    # Create an orderline
    my $order_note = $item->{orderline_free_text};
    $order_note ||= q{};
    my $order_quantity = $item->quantity();
    my $gir_count      = $item->number_of_girs();
    $order_quantity ||= 1;    # quantity not necessarily present
    if ( $gir_count > 1 ) {
        if ( $gir_count != $order_quantity ) {
            $logger->error(
                "Order for $order_quantity items, $gir_count segments present");
        }
        $order_quantity = 1;    # attempts to create an orderline for each gir
    }
    my $price  = $item->price_info;
    # Howells do not send an info price but do have a gross price
    if (!$price) {
        $price = $item->price_gross;
    }
    my $vendor = Koha::Acquisition::Booksellers->find( $quote->vendor_id );

    # NB quote will not include tax info it only contains the list price
    my $ecost = _discounted_price( $vendor->discount, $price, $item->price_info_inclusive );

    # database definitions should set some of these defaults but dont
    my $order_hash = {
        biblionumber       => $bib->{biblionumber},
        entrydate          => dt_from_string()->ymd(),
        basketno           => $basketno,
        listprice          => $price,
        quantity           => $order_quantity,
        quantityreceived   => 0,
        order_vendornote   => q{},
        order_internalnote => q{},
        replacementprice   => $price,
        rrp_tax_included   => $price,
        rrp_tax_excluded   => $price,
        rrp                => $price,
        ecost              => $ecost,
        ecost_tax_included => $ecost,
        ecost_tax_excluded => $ecost,
        uncertainprice     => 0,
        sort1              => q{},
        sort2              => q{},
        currency           => $vendor->listprice(),
    };

    # suppliers references
    if ( $item->reference() ) {
        $order_hash->{suppliers_reference_number}    = $item->reference;
        $order_hash->{suppliers_reference_qualifier} = 'QLI';
    }
    elsif ( $item->orderline_reference_number() ) {
        $order_hash->{suppliers_reference_number} =
          $item->orderline_reference_number;
        $order_hash->{suppliers_reference_qualifier} = 'SLI';
    }
    if ( $item->item_number_id ) {    # suppliers ean
        $order_hash->{line_item_id} = $item->item_number_id;
    }

    if ( $item->girfield('servicing_instruction') ) {
        my $occ = 0;
        my $txt = q{};
        my $si;
        while ( $si = $item->girfield( 'servicing_instruction', $occ ) ) {
            if ($occ) {
                $txt .= q{: };
            }
            $txt .= $si;
            ++$occ;
        }
    }
    if ($order_note) {
        $order_hash->{order_vendornote} = $order_note;
    }

    if ( $item->internal_notes() ) {
        if ( $order_hash->{order_internalnote} ) {    # more than ''
            $order_hash->{order_internalnote} .= q{ };
        }
        $order_hash->{order_internalnote} .= $item->internal_notes;
    }

    my $budget = _get_budget( $schema, $item->girfield('fund_allocation') );

    my $skip = '0';
    if ( !$budget ) {
        if ( $item->quantity > 1 ) {
            carp 'Skipping line with no budget info';
            $logger->trace('girfield skipped for invalid budget');
            $skip++;
        }
        else {
            carp 'Skipping line with no budget info';
            $logger->trace('orderline skipped for invalid budget');
            return;
        }
    }

    my %ordernumber;
    my %budgets;
    my $item_hash;

    if ( !$skip ) {
        $order_hash->{budget_id} = $budget->budget_id;
        my $first_order = $schema->resultset('Aqorder')->create($order_hash);
        my $o           = $first_order->ordernumber();
        $logger->trace("Order created :$o");

        # should be done by database settings
        $first_order->parent_ordernumber( $first_order->ordernumber() );
        $first_order->update();

        # add to $budgets to prevent duplicate orderlines
        $budgets{ $budget->budget_id } = '1';

        # record ordernumber against budget
        $ordernumber{ $budget->budget_id } = $o;

        if ( C4::Context->preference('AcqCreateItem') eq 'ordering' ) {
            $item_hash = _create_item_from_quote( $item, $quote );

            my $created = 0;
            while ( $created < $order_quantity ) {
                $item_hash->{biblionumber} = $bib->{biblionumber};
                $item_hash->{biblioitemnumber} = $bib->{biblioitemnumber};
                my $kitem = Koha::Item->new( $item_hash )->store;
                my $itemnumber = $kitem->itemnumber;
                $logger->trace("Added item:$itemnumber");
                $schema->resultset('AqordersItem')->create(
                    {
                        ordernumber => $first_order->ordernumber,
                        itemnumber  => $itemnumber,
                    }
                );
                ++$created;
            }
        }
    }

    if ( $order_quantity == 1 && $item->quantity > 1 ) {
        my $occurrence = 1;    # occ zero already added
        while ( $occurrence < $item->quantity ) {

            # check budget code
            $budget = _get_budget( $schema,
                $item->girfield( 'fund_allocation', $occurrence ) );

            if ( !$budget ) {
                my $bad_budget =
                  $item->girfield( 'fund_allocation', $occurrence );
                carp 'Skipping line with no budget info';
                $logger->trace(
                    "girfield skipped for invalid budget:$bad_budget");
                ++$occurrence;    ## lets look at the next one not this one again
                next;
            }

            # add orderline for NEW budget in $budgets
            if ( !exists $budgets{ $budget->budget_id } ) {

                # $order_hash->{quantity} = 1; by default above
                # we should handle both 1:1 GIR & 1:n GIR (with LQT values) here

                $order_hash->{budget_id} = $budget->budget_id;

                my $new_order =
                  $schema->resultset('Aqorder')->create($order_hash);
                my $o = $new_order->ordernumber();
                $logger->trace("Order created :$o");

                # should be done by database settings
                $new_order->parent_ordernumber( $new_order->ordernumber() );
                $new_order->update();

                # add to $budgets to prevent duplicate orderlines
                $budgets{ $budget->budget_id } = '1';

                # record ordernumber against budget
                $ordernumber{ $budget->budget_id } = $o;

                if ( C4::Context->preference('AcqCreateItem') eq 'ordering' ) {
                    if ( !defined $item_hash ) {
                        $item_hash = _create_item_from_quote( $item, $quote );
                    }
                    my $new_item = {
                        itype =>
                          $item->girfield( 'stock_category', $occurrence ),
                        location =>
                          $item->girfield( 'collection_code', $occurrence ),
                        itemcallnumber =>
                          $item->girfield( 'shelfmark', $occurrence )
                          || $item->girfield( 'classification', $occurrence )
                          || title_level_class($item),
                        holdingbranch =>
                          $item->girfield( 'branch', $occurrence ),
                        homebranch => $item->girfield( 'branch', $occurrence ),
                    };
                    if ( $new_item->{itype} ) {
                        $item_hash->{itype} = $new_item->{itype};
                    }
                    if ( $new_item->{location} ) {
                        $item_hash->{location} = $new_item->{location};
                    }
                    if ( $new_item->{itemcallnumber} ) {
                        $item_hash->{itemcallnumber} =
                          $new_item->{itemcallnumber};
                    }
                    if ( $new_item->{holdingbranch} ) {
                        $item_hash->{holdingbranch} =
                          $new_item->{holdingbranch};
                    }
                    if ( $new_item->{homebranch} ) {
                        $item_hash->{homebranch} = $new_item->{homebranch};
                    }

                    $item_hash->{biblionumber} = $bib->{biblionumber};
                    $item_hash->{biblioitemnumber} = $bib->{biblioitemnumber};
                    my $kitem = Koha::Item->new( $item_hash )->store;
                    my $itemnumber = $kitem->itemnumber;
                    $logger->trace("New item $itemnumber added");
                    $schema->resultset('AqordersItem')->create(
                        {
                            ordernumber => $new_order->ordernumber,
                            itemnumber  => $itemnumber,
                        }
                    );

                    my $lrp =
                      $item->girfield( 'library_rotation_plan', $occurrence );
                    if ($lrp) {
                        my $rota =
                          Koha::StockRotationRotas->find( { title => $lrp },
                            { key => 'stockrotationrotas_title' } );
                        if ($rota) {
                            $rota->add_item($itemnumber);
                            $logger->trace("Item added to rota $rota->id");
                        }
                        else {
                            $logger->error(
                                "No rota found matching $lrp in orderline");
                        }
                    }
                }

                ++$occurrence;
            }

            # increment quantity in orderline for EXISTING budget in $budgets
            else {
                my $row = $schema->resultset('Aqorder')->find(
                    {
                        ordernumber => $ordernumber{ $budget->budget_id }
                    }
                );
                if ($row) {
                    my $qty = $row->quantity;
                    $qty++;
                    $row->update(
                        {
                            quantity => $qty,
                        }
                    );
                }

                # Do not use the basket level value as it is always NULL
                # See calling subs call to AddBasket
                if ( C4::Context->preference('AcqCreateItem') eq 'ordering' ) {
                    my $new_item = {
                        notforloan       => -1,
                        cn_sort          => q{},
                        cn_source        => 'ddc',
                        price            => $price,
                        replacementprice => $price,
                        itype =>
                          $item->girfield( 'stock_category', $occurrence ),
                        location =>
                          $item->girfield( 'collection_code', $occurrence ),
                        itemcallnumber =>
                          $item->girfield( 'shelfmark', $occurrence )
                          || $item->girfield( 'classification', $occurrence )
                          || $item_hash->{itemcallnumber},
                        holdingbranch =>
                          $item->girfield( 'branch', $occurrence ),
                        homebranch => $item->girfield( 'branch', $occurrence ),
                    };
                    $new_item->{biblionumber} = $bib->{biblionumber};
                    $new_item->{biblioitemnumber} = $bib->{biblioitemnumber};
                    my $kitem = Koha::Item->new( $new_item )->store;
                    my $itemnumber = $kitem->itemnumber;
                    $logger->trace("New item $itemnumber added");
                    $schema->resultset('AqordersItem')->create(
                        {
                            ordernumber => $ordernumber{ $budget->budget_id },
                            itemnumber  => $itemnumber,
                        }
                    );

                    my $lrp =
                      $item->girfield( 'library_rotation_plan', $occurrence );
                    if ($lrp) {
                        my $rota =
                          Koha::StockRotationRotas->find( { title => $lrp },
                            { key => 'stockrotationrotas_title' } );
                        if ($rota) {
                            $rota->add_item($itemnumber);
                            $logger->trace("Item added to rota $rota->id");
                        }
                        else {
                            $logger->error(
                                "No rota found matching $lrp in orderline");
                        }
                    }
                }

                ++$occurrence;
            }
        }
    }
    return 1;

}

sub get_edifact_ean {

    my $dbh = C4::Context->dbh;

    my $eans = $dbh->selectcol_arrayref('select ean from edifact_ean');

    return $eans->[0];
}

# We should not need to have a routine to do this here
sub _discounted_price {
    my ( $discount, $price, $discounted_price ) = @_;
    if (defined $discounted_price) {
        return $discounted_price;
    }
    if (!$price) {
        return 0;
    }
    return $price - ( ( $discount * $price ) / 100 );
}

sub _check_for_existing_bib {
    my $isbn = shift;

    my $search_isbn = $isbn;
    $search_isbn =~ s/^\s*/%/xms;
    $search_isbn =~ s/\s*$/%/xms;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
'select biblionumber, biblioitemnumber from biblioitems where isbn like ?',
    );
    my $tuple_arr =
      $dbh->selectall_arrayref( $sth, { Slice => {} }, $search_isbn );
    if ( @{$tuple_arr} ) {
        return $tuple_arr->[0];
    }
    elsif ( length($isbn) == 13 && $isbn !~ /^97[89]/ ) {
        my $tarr = $dbh->selectall_arrayref(
'select biblionumber, biblioitemnumber from biblioitems where ean = ?',
            { Slice => {} },
            $isbn
        );
        if ( @{$tarr} ) {
            return $tarr->[0];
        }
    }
    else {
        undef $search_isbn;
        $isbn =~ s/\-//xmsg;
        if ( $isbn =~ m/(\d{13})/xms ) {
            my $b_isbn = Business::ISBN->new($1);
            if ( $b_isbn && $b_isbn->is_valid && $b_isbn->as_isbn10 ) {
                $search_isbn = $b_isbn->as_isbn10->as_string( [] );
            }

        }
        elsif ( $isbn =~ m/(\d{9}[xX]|\d{10})/xms ) {
            my $b_isbn = Business::ISBN->new($1);
            if ( $b_isbn && $b_isbn->is_valid ) {
                $search_isbn = $b_isbn->as_isbn13->as_string( [] );
            }

        }
        if ($search_isbn) {
            $search_isbn = "%$search_isbn%";
            $tuple_arr =
              $dbh->selectall_arrayref( $sth, { Slice => {} }, $search_isbn );
            if ( @{$tuple_arr} ) {
                return $tuple_arr->[0];
            }
        }
    }
    return;
}

# returns a budget obj or undef
# fact we need this shows what a mess Acq API is
sub _get_budget {
    my ( $schema, $budget_code ) = @_;
    my $period_rs = $schema->resultset('Aqbudgetperiod')->search(
        {
            budget_period_active => 1,
        }
    );

    # db does not ensure budget code is unque
    return $schema->resultset('Aqbudget')->single(
        {
            budget_code => $budget_code,
            budget_period_id =>
              { -in => $period_rs->get_column('budget_period_id')->as_query },
        }
    );
}

# try to get title level classification from incoming quote
sub title_level_class {
    my ($item)         = @_;
    my $class          = q{};
    my $default_scheme = C4::Context->preference('DefaultClassificationSource');
    if ( $default_scheme eq 'ddc' ) {
        $class = $item->dewey_class();
    }
    elsif ( $default_scheme eq 'lcc' ) {
        $class = $item->lc_class();
    }
    if ( !$class ) {
        $class =
             $item->girfield('shelfmark')
          || $item->girfield('classification')
          || q{};
    }
    return $class;
}

sub _create_bib_from_quote {

    #TBD we should flag this for updating from an external source
    #As biblio (&biblioitems) has no candidates flag in order
    my ( $item, $quote ) = @_;
    my $itemid = $item->item_number_id;
    my $defalt_classification_source =
      C4::Context->preference('DefaultClassificationSource');
    my $bib_hash = {
        'biblioitems.cn_source' => $defalt_classification_source,
        'items.cn_source'       => $defalt_classification_source,
        'items.notforloan'      => -1,
        'items.cn_sort'         => q{},
    };
    $bib_hash->{'biblio.seriestitle'} = $item->series;

    $bib_hash->{'biblioitems.publishercode'} = $item->publisher;
    $bib_hash->{'biblioitems.publicationyear'} =
      $bib_hash->{'biblio.copyrightdate'} = $item->publication_date;

    $bib_hash->{'biblio.title'}         = $item->title;
    $bib_hash->{'biblio.author'}        = $item->author;
    $bib_hash->{'biblioitems.isbn'}     = $item->item_number_id;
    $bib_hash->{'biblioitems.itemtype'} = $item->girfield('stock_category');

    # If we have a 13 digit id we are assuming its an ean
    # (it may also be an isbn or issn)
    if ( $itemid =~ /^\d{13}$/ ) {
        $bib_hash->{'biblioitems.ean'} = $itemid;
        if ( $itemid =~ /^977/ ) {
            $bib_hash->{'biblioitems.issn'} = $itemid;
        }
    }
    for my $key ( keys %{$bib_hash} ) {
        if ( !defined $bib_hash->{$key} ) {
            delete $bib_hash->{$key};
        }
    }
    return TransformKohaToMarc($bib_hash);

}

sub _create_item_from_quote {
    my ( $item, $quote ) = @_;
    my $defalt_classification_source =
      C4::Context->preference('DefaultClassificationSource');
    my $item_hash = {
        cn_source  => $defalt_classification_source,
        notforloan => -1,
        cn_sort    => q{},
    };
    $item_hash->{booksellerid} = $quote->vendor_id;
    $item_hash->{price}        = $item_hash->{replacementprice} = $item->price;
    $item_hash->{itype}        = $item->girfield('stock_category');
    $item_hash->{location}     = $item->girfield('collection_code');

    my $note = {};

    $item_hash->{itemcallnumber} =
         $item->girfield('shelfmark')
      || $item->girfield('classification')
      || title_level_class($item);

    my $branch = $item->girfield('branch');
    $item_hash->{holdingbranch} = $item_hash->{homebranch} = $branch;
    return $item_hash;
}

1;
__END__

=head1 NAME

Koha::EDI

=head1 SYNOPSIS

   Module exporting subroutines used in EDI processing for Koha

=head1 DESCRIPTION

   Subroutines called by batch processing to handle Edifact
   messages of various types and related utilities

=head1 BUGS

   These routines should really be methods of some object.
   get_edifact_ean is a stopgap which should be replaced

=head1 SUBROUTINES

=head2 process_quote

    process_quote(quote_message);

   passed a message object for a quote, parses it creating an order basket
   and orderlines in the database
   updates the message's status to received in the database and adds the
   link to basket

=head2 process_invoice

    process_invoice(invoice_message)

    passed a message object for an invoice, add the contained invoices
    and update the orderlines referred to in the invoice
    As an Edifact invoice is in effect a despatch note this receipts the
    appropriate quantities in the orders

    no meaningful return value

=head2 process_ordrsp

     process_ordrsp(ordrsp_message)

     passed a message object for a supplier response, process the contents
     If an orderline is cancelled cancel the corresponding orderline in koha
     otherwise record the supplier message against it

     no meaningful return value

=head2 create_edi_order

    create_edi_order( { parameter_hashref } )

    parameters must include basketno and ean

    branchcode can optionally be passed

    returns 1 on success undef otherwise

    if the parameter noingest is set the formatted order is returned
    and not saved in the database. This functionality is intended for debugging only

=head2 receipt_items

    receipt_items( schema_obj, invoice_line, ordernumber, $quantity)

    receipts the items recorded on this invoice line

    no meaningful return

=head2 transfer_items

    transfer_items(schema, invoice_line, originating_order, receiving_order, $quantity)

    Transfer the items covered by this invoice line from their original
    order to another order recording the partial fulfillment of the original
    order

    no meaningful return

=head2 get_edifact_ean

    $ean = get_edifact_ean();

    routine to return the ean.

=head2 quote_item

     quote_item(lineitem, quote_message);

      Called by process_quote to handle an individual lineitem
     Generate the biblios and items if required and orderline linking to them

     Returns 1 on success undef on error

     Most usual cause of error is a line with no or incorrect budget codes
     which woild cause order creation to abort
     If other correct lines exist these are processed and the erroneous line os logged

=head2 title_level_class

      classmark = title_level_class(edi_item)

      Trys to return a title level classmark from a quote message line
      Will return a dewey or lcc classmark if one exists according to the
      value in DefaultClassificationSource syspref

      If unable to returns the shelfmark or classification from the GIR segment

      If all else fails returns empty string

=head2 _create_bib_from_quote

       marc_record_obj = _create_bib_from_quote(lineitem, quote)

       Returns a MARC::Record object based on the  info in the quote's lineitem

=head2 _create_item_from_quote

       item_hashref = _create_item_from_quote( lineitem, quote)

       returns a hashref representing the item fields specified in the quote

=head2 _get_invoiced_price

      (price, price_tax_excluded) = _get_invoiced_price(line_object, $quantity)

      Returns an array of unitprice and unitprice_tax_excluded derived from the lineitem
      monetary fields

=head2 _discounted_price

      ecost = _discounted_price(discount, item_price, discounted_price)

      utility subroutine to return a price calculated from the
      vendors discount and quoted price
      if invoice has a field containing discounted price that is returned
      instead of recalculating

=head2 _check_for_existing_bib

     (biblionumber, biblioitemnumber) = _check_for_existing_bib(isbn_or_ean)

     passed an isbn or ean attempts to locate a match bib
     On success returns biblionumber and biblioitemnumber
     On failure returns undefined/an empty list

=head2 _get_budget

     b = _get_budget(schema_obj, budget_code)

     Returns the Aqbudget object for the active budget given the passed budget_code
     or undefined if one does not exist

=head1 AUTHOR

   Colin Campbell <colin.campbell@ptfs-europe.com>


=head1 COPYRIGHT

   Copyright 2014,2015 PTFS-Europe Ltd
   This program is free software, You may redistribute it under
   under the terms of the GNU General Public License


=cut
