#!/usr/bin/perl

use CGI;
use strict;
use C4::Acquisitions;

my $input = new CGI;
my $biblionumber = $input->param('biblionumber');
my $biblioitem = {
    biblionumber      => $biblionumber,
    publishercode     => $input->param('publishercode'),
    publicationyear   => $input->param('publicationyear'),
    place             => $input->param('year'),
    illus             => $input->param('illus'),
    isbn              => $input->param('isbn'),
    additionalauthors => $input->param('additionalauthors'),
    subjectheadings   => $input->param('subjectheadings'),
    itemtype          => $input->param('itemtype'),
    url               => $input->param('url'),
    dewey             => $input->param('dewey'),
    subclass          => $input->param('subclass'),
    issn              => $input->param('issn'),
    lccn              => $input->param('lccn'),
    volume            => $input->param('volume'),
    number            => $input->param('number'),
    volumeddesc       => $input->param('volumeddesc'),
    pages             => $input->param('pages'),
    size              => $input->param('size'),
    notes             => $input->param('notes')
};
my $biblioitemnum;

if (! $biblionumber) {
    print $input->redirect('addbooks.pl');
} else {

    $biblioitemnum = &newbiblioitem($biblioitem);

    print $input->redirect("additem.pl?biblioitemnum=$biblioitemnum");
} # else
