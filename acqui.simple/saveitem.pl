#!/usr/bin/perl

# $Id$

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

use CGI;
use strict;
use C4::Catalogue;
use C4::Biblio;

my $input            = new CGI;
my $barcode          = $input->param('barcode');
my $biblionumber     = $input->param('biblionumber');
my $biblioitemnumber = $input->param('biblioitemnumber');
my $item             = {
    biblionumber     => $biblionumber,
    biblioitemnumber => $biblioitemnumber?$biblioitemnumber:"",
    homebranch       => $input->param('homebranch'),
    holdingbranch       => $input->param('homebranch'),
    replacementprice => $input->param('replacementprice')?$input->param('replacementprice'):"",
    itemnotes        => $input->param('notes')?$input->param('notes'):""
}; # my $item
my $biblioitem       = {
    biblionumber      => $biblionumber,
    itemtype          => $input->param('itemtype'),
    isbn              => $input->param('isbn')?$input->param('isbn'):"",
    publishercode     => $input->param('publishercode')?$input->param('publishercode'):"",
    publicationyear   => $input->param('publicationyear')?$input->param('publicationyear'):"",
    place             => $input->param('place')?$input->param('place'):"",
    illus             => $input->param('illus')?$input->param('illus'):"",
    url               => $input->param('url')?$input->param('url'):"",
    dewey             => $input->param('dewey')?$input->param('dewey'):"",
    subclass          => $input->param('subclass')?$input->param('subclass'):"",
    issn              => $input->param('issn')?$input->param('issn'):"",
    lccn              => $input->param('lccn')?$input->param('lccn'):"",
    volume            => $input->param('volume')?$input->param('volume'):"",
    number            => $input->param('number')?$input->param('number'):"",
    volumeddesc       => $input->param('volumeddesc')?$input->param('volumeddesc'):"",
    pages             => $input->param('pages')?$input->param('pages'):"",
    size              => $input->param('size')?$input->param('size'):"",
    notes             => $input->param('notes')?$input->param('notes'):""
}; # my biblioitem
my $newgroup = 0;
my $website  = 0;
my $count;
my @results;

if ($input->param('newgroup')) {
    $newgroup = 1;
    if ($biblioitem->{'itemtype'} eq "WEB") {
	$website = 1;
    } # if
} # if

if (! $biblionumber) {
    print $input->redirect('addbooks.pl');
} elsif ((! $barcode) && (! $website)) {
    print $input->redirect("additem-nomarc.pl?biblionumber=$biblionumber&error=nobarcode");
} elsif ((! $newgroup) && (! $biblioitemnumber)) {
    print $input->redirect("additem-nomarc.pl?biblionumber=$biblionumber&error=nobiblioitem");
} else {

    if ($website) {
	&newbiblioitem($biblioitem);
		print $input->redirect("additem-nomarc.pl?biblionumber=$biblionumber");
    } elsif (&checkitems(1,$barcode)) {
	print $input->redirect("additem-nomarc.pl?biblionumber=$biblionumber&error=barcodeinuse");
    } else {

	if ($newgroup) {
	    $biblioitemnumber = &newbiblioitem($biblioitem);
	    $item->{'biblioitemnumber'} = $biblioitemnumber;
	} # if

	&newitems($item, ($barcode));

	print $input->redirect("additem-nomarc.pl?biblionumber=$biblionumber");
    } # else
} # else
