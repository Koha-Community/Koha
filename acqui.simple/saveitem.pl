#!/usr/bin/perl

use CGI;
use strict;
use C4::Acquisitions;

my $input            = new CGI;
my $barcode          = $input->param('barcode');
my $biblionumber     = $input->param('biblionumber');
my $biblioitemnumber = $input->param('biblioitemnumber');
my $item             = {
    biblionumber     => $biblionumber,
    biblioitemnumber => $biblioitemnumber?$biblioitemnumber:"",
    homebranch       => $input->param('homebranch'),
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
    additionalauthors => $input->param('additionalauthors')?$input->param('additionalauthors'):"",
    subjectheadings   => $input->param('subjectheadings')?$input->param('subjectheadings'):"",
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
    print $input->redirect("additem.pl?biblionumber=$biblionumber&error=nobarcode");
} elsif ((! $newgroup) && (! $biblioitemnumber)) {
    print $input->redirect("additem.pl?biblionumber=$biblionumber&error=nobiblioitem");
} else {
    
    if ($website) {
	&newbiblioitem($biblioitem);
    } elsif (&checkitems(1,$barcode)) {
	print $input->redirect("additem.pl?biblionumber=$biblionumber&error=barcodeinuse");
    } else {

	if ($newgroup) {
	    $biblioitemnumber = &newbiblioitem($biblioitem);
	    $item->{'biblioitemnumber'} = $biblioitemnumber;
	} # if

	&newitems($item, ($barcode));

	print $input->redirect("additem.pl?biblionumber=$biblionumber");
    } # else
} # else
