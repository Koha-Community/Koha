#!/usr/bin/perl

use strict;
use C4::Acquisitions;
use CGI;

my $input = new CGI;
my $biblionumber     = $input->param('biblionumber');
my $biblioitemnumber = $input->param('biblioitemnumber');

if (! $biblionumber) {
    print $input->redirect("/catalogue/");

} elsif (! $biblioitemnumber) {
    print $input->param("detail.pl?type=intra&bib=$biblionumber");

} else {
    &deletebiblioitem($biblioitemnumber);

    print $input->redirect("detail.pl?type=intra&bib=$biblionumber");
} # else
