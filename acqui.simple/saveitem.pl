#!/usr/bin/perl

use CGI;
use strict;
use C4::Acquisitions;

my $input         = new CGI;
my $barcode       = $input->param('barcode');
my $biblioitemnum = $input->param('biblioitemnum');
my $item          = {
    biblioitemnumber => $biblioitemnum,
    homebranch       => $input->param('homebranch'),
    replacementprice => $input->param('replacementprice')?$input->param('replacementprice'):"",
    itemnotes        => $input->param('notes')?$input->param('notes'):""
}; # my $item
my $count;
my @results;

if (! $barcode) {
    print $input->redirect('additem.pl?error=nobarcode');
} elsif (! $biblioitemnum) {
    print $input->redirect('addbooks.pl');
} else {

    ($count, @results) = &getbiblioitem($biblioitemnum);
    if (! $count) {
	print->redirect('addbooks.pl');
    } else {

	$item->{'biblionumber'} = $results[0]->{'biblionumber'};
	&newitems($item, ($barcode));

	print $input->redirect("additem.pl?biblioitemnum=$biblioitemnum");
    } # else
} # else
