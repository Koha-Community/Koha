#!/usr/bin/perl

use CGI;
use strict;
use C4::Acquisitions;

my $input = new CGI;
my $biblionumber = $input->param('biblionumber');
my $biblioitem = {
    biblionumber      => $biblionumber,
    publishercode     => $input->param('publishercode')?$input->param('publishercode'):"",
    publicationyear   => $input->param('publicationyear')?$input->param('publicationyear'):"",
    place             => $input->param('year')?$input->param('year'):"",
    illus             => $input->param('illus')?$input->param('illus'):"",
    isbn              => $input->param('isbn')?$input->param('isbn'):"",
    additionalauthors => $input->param('additionalauthors')?$input->param('additionalauthors'):"",
    subjectheadings   => $input->param('subjectheadings')?$input->param('subjectheadings'):"",
    itemtype          => $input->param('itemtype')?$input->param('itemtype'):"",
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
};
my $biblioitemnum;

if (! $biblionumber) {
    print $input->redirect('addbooks.pl');
} else {

    $biblioitemnum = &newbiblioitem($biblioitem);
    
    if ($input->param('itemtype') eq "WEB") {
	print $input->redirect("addbooks.pl?biblioitem=added");
    } else {
	print $input->redirect("additem.pl?biblioitemnum=$biblioitemnum");
    } # else
} # else
