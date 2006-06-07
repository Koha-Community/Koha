#!/usr/bin/perl

#script to add an order into the system
#written 29/2/00 by chris@katipo.co.nz

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

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Acquisition;
use C4::Suggestions;
use C4::Biblio;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Database;
use HTML::Template;

#use Data::Dumper;
#use Date::Manip;

my $input = new CGI;

# get_template_and_user used only to check auth & get user id
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/order.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 1 },
        debug           => 1,
    }
);

# get CGI parameters
my $ordnum       = $input->param('ordnum');
my $basketno     = $input->param('basketno');
my $booksellerid = $input->param('booksellerid');
my $existing     =
  $input->param('existing');    # existing biblio, (not basket or order)
my $title         = $input->param('title');
my $author        = $input->param('author');
my $copyrightdate = $input->param('copyrightdate');
my $isbn          = $input->param('ISBN');
my $itemtype      = $input->param('format');
my $quantity      = $input->param('quantity');
my $listprice     = $input->param('list_price');
my $branch        = $input->param('branch');
if ( $listprice eq '' ) {
    $listprice = 0;
}
my $series = $input->param('series');

# my $supplier=$input->param('supplier');
my $notes         = $input->param('notes');
my $bookfund      = $input->param('bookfund');
my $sort1         = $input->param('sort1');
my $sort2         = $input->param('sort2');
my $rrp           = $input->param('rrp');
my $ecost         = $input->param('ecost');
my $gst           = $input->param('GST');
my $budget        = $input->param('budget');
my $cost          = $input->param('cost');
my $sub           = $input->param('sub');
my $invoice       = $input->param('invoice');
my $publishercode = $input->param('publishercode');
my $suggestionid  = $input->param('suggestionid');
my $donation      = $input->param('donation');
my $user          = $input->remote_user;

#warn "CREATEBIBITEM =  $input->param('createbibitem')";
#warn Dumper $input->param('createbibitem');
my $createbibitem = $input->param('createbibitem');

# create, modify or delete biblio
# create if $quantity>=0 and $existing='no'
# modify if $quantity>=0 and $existing='yes'
# delete if $quantity has been se to 0 by the librarian
my $bibnum;
my $bibitemnum;
if ( $quantity ne '0' ) {

    #check to see if biblio exists
    if ( $existing eq 'no' ) {

        #if it doesnt create it
        $bibnum = &newbiblio(
            {
                title         => $title         ? $title         : "",
                author        => $author        ? $author        : "",
                copyrightdate => $copyrightdate ? $copyrightdate : "",
                series        => $series        ? $series        : "",
            }
        );
        $bibitemnum = &newbiblioitem(
            {
                biblionumber  => $bibnum,
                itemtype      => $itemtype ? $itemtype : "",
                isbn          => $isbn ? $isbn : "",
                publishercode => $publishercode ? $publishercode : "",
            }
        );

        # change suggestion status if applicable
        if ($suggestionid) {
            changestatus( $suggestionid, 'ORDERED', '', $bibnum );
        }
    }

    elsif ( $createbibitem eq 'YES' ) {
        $bibnum     = $input->param('biblio');
        $bibitemnum = $input->param('bibitemnum');
        $bibitemnum = &newbiblioitem(
            {
                biblionumber  => $bibnum,
                itemtype      => $itemtype ? $itemtype : "",
                isbn          => $isbn ? $isbn : "",
                publishercode => $publishercode ? $publishercode : "",
            }
        );
        &modbiblio(
            {
                biblionumber  => $bibnum,
                title         => $title ? $title : "",
                author        => $author ? $author : "",
                copyrightdate => $copyrightdate ? $copyrightdate : "",
                series        => $series ? $series : ""
            }
        );
    }

    # then attach it to an existing bib

    else {
        warn "attaching to an existing bibitem";

        $bibnum = $input->param('biblio');

        # if we are moddig the bibitem, not creating it createbib wont be set,
        #
        if ($createbibitem) {
            $bibitemnum = $createbibitem;
        }
        else {
            $bibitemnum = $input->param('bibitemnum');
        }

        my $oldtype = $input->param('oldtype');
        &modbibitem(
            {
                biblioitemnumber => $bibitemnum,
                isbn             => $isbn,
                publishercode    => $publishercode,
                itemtype         =>
                  $itemtype,    # added itemtype, not prev. being changed.
            }
        );
        &modbiblio(
            {
                biblionumber  => $bibnum,
                title         => $title ? $title : "",
                author        => $author ? $author : "",
                copyrightdate => $copyrightdate ? $copyrightdate : "",
                series        => $series ? $series : ""
            },
        );
    }
    if ($ordnum) {

        # 		warn "MODORDER $title / $ordnum / $quantity / $bookfund";
        modorder(
            $title,   $ordnum,   $quantity,     $listprice,
            $bibnum,  $basketno, $booksellerid, $loggedinuser,
            $notes,   $bookfund, $bibitemnum,   $rrp,
            $ecost,   $gst,      $budget,       $cost,
            $invoice, $sort1,    $sort2
        );
    }
    else {
        ( $basketno, $ordnum ) = neworder(
            $basketno,  $bibnum,       $title,        $quantity,
            $listprice, $booksellerid, $loggedinuser, $notes,
            $bookfund,  $bibitemnum,   $rrp,          $ecost,
            $gst,       $budget,       $cost,         $sub,
            $invoice,   $sort1,        $sort2
        );
    }
    if ($donation) {
        my $barcode  = $input->param('barcode');
        my @barcodes = split( /\,| |\|/, $barcode );
        my ($error)  = newitems(
            {
                biblioitemnumber => $bibitemnum,
                biblionumber     => $bibnum,
                replacementprice => $rrp,
                price            => $cost,
                booksellerid     => $booksellerid,
                homebranch       => $branch,
                loan             => 0
            },
            @barcodes
        );
        receiveorder(
            $bibnum,  $ordnum, $quantity, $user, $cost,
            $invoice, 0,       $bookfund, $rrp
        );
    }
}
else {
    $bibnum = $input->param('biblio');
    delorder( $bibnum, $ordnum );
}
print $input->redirect("basket.pl?basket=$basketno");
