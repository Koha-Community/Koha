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

use C4::Output;
use C4::Acquisition;
use C4::Biblio;
use CGI;
use C4::Search;

my $input=new CGI;

my $user=$input->remote_user;
my $biblionumber = $input->param('biblio');
my $ordnum=$input->param('ordnum');
my $quantrec=$input->param('quantityrec');
my $quantity=$input->param('quantity');
my $notes=$input->param('notes');
my $cost=$input->param('cost');
my $invoiceno=$input->param('invoice');
my $bibitemno=$input->param('biblioitemnum');
my $data=bibitemdata($bibitemno);
my $publisher=$data->{'publishercode'};
my $pubdate=$data->{'publicationdate'};
my $class=$data->{'classification'};
my $dewey=$data->{'dewey'};
my $subclass=$data->{'subclass'};

my $size=$data->{'size'};
my $illus=$data->{'illus'};
my $pages=$data->{'pages'};
my $replacement=$input->param('rrp');
my $branch=$input->param('branch');
my $bookfund=$input->param('bookfund');
my $itemtype=$input->param('format');
my $isbn=$input->param('ISBN');
my $biblio = {
	biblionumber  => $biblionumber,
	title         => $input->param('title')?$input->param('title'):"",
	author        => $input->param('author')?$input->param('author'):"",
	copyrightdate => $input->param('copyright')?$input->param('copyright'):"",
	series        => $input->param('Series')?$input->param('Series'):""
}; # my $biblio

if ($quantrec != 0){
	$cost /= $quantrec;
}

my $gst=$input->param('gst');
my $freight=$input->param('freight');
my $volinf=$input->param('volinf');
my $id = $input->param('id');
my $loan=0;
if ($itemtype =~ /REF/){
	$loan=1;
}

if ($itemtype =~ /PER/){
	$class="Periodical";
	$bibitemno = &newbiblioitem({
		biblionumber   => $biblionumber,
		itemtype       => $itemtype?$itemtype:"",
		isbn           => $isbn?$isbn:"",
		volumeddesc    => $volinf?$volinf:"",
		classification => $class?$class:"" });
}
if ($quantity != 0){
# 	warn "receive : $biblionumber,$ordnum,$quantrec,$user,$cost,$invoiceno,$bibitemno,$freight,$bookfund";
	receiveorder($biblionumber,$ordnum,$quantrec,$user,$cost,$invoiceno,$bibitemno,$freight,$bookfund);
	modbiblio($biblio);
	&modbibitem({
		biblioitemnumber => $bibitemno,
		biblionumber     => $biblionumber,
		itemtype         => $itemtype?$itemtype:"",
		isbn             => $isbn?$isbn:"",
		publisher        => $publisher?$publisher:"",
		publicationyear  => $pubdate?$pubdate:"",
		class            => $class?$class:"",
		dewey            => $dewey?$dewey:"",
		subclass         => $subclass?$subclass:"",
		illus            => $illus?$illus:"",
		pages            => $pages?$pages:"",
		volumeddesc      => $volinf?$volinf:"",
		notes            => $notes?$notes:"",
		size             => $size?$size:"" });
	my $barcode=$input->param('barcode');
	my @barcodes;
#	if ($barcode =~ /\,/){
		@barcodes=split(/\,| |\|/,$barcode);
#	}elsif ($barcode =~ /\|/){
#		@barcodes=split(/\|/,$barcode);
#	} else {
#		$barcodes[0]=$barcode;
#	}
	my ($error) = newitems({ biblioitemnumber => $bibitemno,
					biblionumber     => $biblionumber,
					replacementprice => $replacement,
					price            => $cost,
					booksellerid     => $id,
					homebranch       => $branch,
					loan             => $loan },
				@barcodes);
	if ($error eq ''){
		if ($itemtype ne 'PER'){
			print $input->redirect("/cgi-bin/koha/acqui/receive.pl?invoice=$invoiceno&id=$id&freight=$freight&gst=$gst");
		} else {
			print $input->redirect("/acquisitions/");
		}
	} else {
		print $input->header;
		print $error;
	}
} else {
	print $input->header;
	delorder($biblionumber,$ordnum);
	print $input->redirect("/acquisitions/");
}
