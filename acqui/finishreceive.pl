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

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Context;
use C4::Acquisition;
use C4::Biblio;
use C4::Items;
use C4::Search;

my $input=new CGI;
my $flagsrequired = { acquisition => 1};
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0, $flagsrequired, 'intranet');
my $user=$input->remote_user;
my $biblionumber = $input->param('biblionumber');
my $biblioitemnumber=$input->param('biblioitemnumber');
my $ordnum=$input->param('ordnum');
my $origquantityrec=$input->param('origquantityrec');
my $quantityrec=$input->param('quantityrec');
my $quantity=$input->param('quantity');
my $cost=$input->param('cost');
my $invoiceno=$input->param('invoice');
my $datereceived=$input->param('datereceived');
my $replacement=$input->param('rrp');
my $gst=$input->param('gst');
my $freight=$input->param('freight');
my $supplierid = $input->param('supplierid');
my @branch=$input->param('homebranch');
my @barcode=$input->param('barcode');
my @ccode=$input->param('ccode');
my @itemtype=$input->param('itemtype');
my @location=$input->param('location');
my @enumchron=$input->param('volinf');
my $cnt = 0;

if ($quantityrec > $origquantityrec ) {
    # save the quantity recieved.
    $datereceived = ModReceiveOrder($biblionumber,$ordnum,$quantityrec,$user,$cost,$invoiceno,$freight,$replacement,undef,$datereceived);
    # create items if the user has entered barcodes
   # my @barcodes=split(/\,| |\|/,$barcode);
    # foreach barcode provided, build the item MARC::Record and create the item
    foreach my $bc (@barcode) {
        my $itemRecord = TransformKohaToMarc({
                    "items.replacementprice" => $replacement,
                    "items.price"            => $cost,
                    "items.booksellerid"     => $supplierid,
                    "items.homebranch"       => $branch[$cnt],
                    "items.holdingbranch"    => $branch[$cnt],
                    "items.barcode"          => $barcode[$cnt],
                    "items.ccode"          => $ccode[$cnt],
                    "items.itype"          => $itemtype[$cnt],
                    "items.location"          => $location[$cnt],
                    "items.enumchron"          => $enumchron[$cnt], # FIXME : No integration here with serials module.
                    "items.loan"             => 0, });
		AddItemFromMarc($itemRecord,$biblionumber);
		$cnt++;
	}
}
    print $input->redirect("/cgi-bin/koha/acqui/parcel.pl?invoice=$invoiceno&supplierid=$supplierid&freight=$freight&gst=$gst&datereceived=$datereceived");
#} else {
#    print $input->header;
#    #delorder($biblionumber,$ordnum);
#    print $input->redirect("/acquisitions/");
#}
