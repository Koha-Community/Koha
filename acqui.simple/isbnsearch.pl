#!/usr/bin/perl

use CGI;
use strict;
use C4::Acquisitions;

my $input = new CGI;
my $isbn  = $input->param('isbn');
my $biblioitemnum;
my $count;
my @results;

if (! $isbn) {
    print $input->redirect('addbooks.pl');
} else {

    ($count, @results) = &isbnsearch($isbn);
    if (! $count) {
	print $input->redirect("addbooks.pl?error=notfound");
    } else {

	$biblioitemnum = $results[0]->{'biblioitemnumber'};
	print $input->redirect("additem.pl?biblioitemnum=$biblioitemnum");

    } # else
} # else
