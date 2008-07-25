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
my $cnt=0;
my $error_url_str;	

if ($quantityrec > $origquantityrec ) {
	foreach my $bc (@barcode) {
		my $item_hash = {
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
                    "items.loan"             => 0, 
					};
		$item_hash->{'items.cn_source'} = C4::Context->preference('DefaultClassificationSource') if(C4::Context->preference('DefaultClassificationSource') );
		# FIXME : cn_sort is populated by Items::_set_derived_columns_for_add , which is never called with AddItemFromMarc .  Bug 2403
        my $itemRecord = TransformKohaToMarc($item_hash);
		$cnt++;
		$item_hash = TransformMarcToKoha(undef,$itemRecord,'','items');
		# FIXME: possible race condition.  duplicate barcode check should happen in AddItem, but for now we have to do it here.
		my %err = CheckItemPreSave($item_hash);
		if(%err) {
			for my $err_cnd (keys %err) {
				$error_url_str .= "&error=" . $err_cnd . "&error_param=" . $err{$err_cnd};
			}
			$quantityrec--;
		} else {
			AddItemFromMarc($itemRecord,$biblionumber);
		}
	}
	
    # save the quantity received.
	if( $quantityrec > 0 ) {
    	$datereceived = ModReceiveOrder($biblionumber,$ordnum, $quantityrec ,$user,$cost,$invoiceno,$freight,$replacement,undef,$datereceived);
	}
}
    print $input->redirect("/cgi-bin/koha/acqui/parcel.pl?invoice=$invoiceno&supplierid=$supplierid&freight=$freight&gst=$gst&datereceived=$datereceived$error_url_str");

