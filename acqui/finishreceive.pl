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
use C4::Output;
use C4::Acquisition;
use C4::Biblio;
use CGI;
use C4::Search;

my $input=new CGI;

my $user=$input->remote_user;
my $biblionumber = $input->param('biblio');
my $bibitemno=$input->param('biblioitemnum');
my $ordnum=$input->param('ordnum');
my $quantrec=$input->param('quantityrec');
my $quantity=$input->param('quantity');
my $cost=$input->param('cost');
my $invoiceno=$input->param('invoice');
my $replacement=$input->param('rrp');
my $gst=$input->param('gst');
my $freight=$input->param('freight');
my $supplierid = $input->param('supplierid');
my $branch=$input->param('branch');

if ($quantrec != 0){
	$cost /= $quantrec;
}

if ($quantity != 0) {
	# save the quantity recieved.
	receiveorder($biblionumber,$ordnum,$quantrec,$user,$cost,$invoiceno,$freight,$replacement);
	# create items if the user has entered barcodes
	my $barcode=$input->param('barcode');
	my @barcodes=split(/\,| |\|/,$barcode);
	my ($error) = newitems({ biblioitemnumber => $bibitemno,
					biblionumber     => $biblionumber,
					replacementprice => $replacement,
					price            => $cost,
					booksellerid     => $supplierid,
					homebranch       => $branch,
					loan             => 0 },
				@barcodes);
	print $input->redirect("/cgi-bin/koha/acqui/receive.pl?invoice=$invoiceno&supplierid=$supplierid&freight=$freight&gst=$gst");
} else {
	print $input->header;
	delorder($biblionumber,$ordnum);
	print $input->redirect("/acquisitions/");
}
