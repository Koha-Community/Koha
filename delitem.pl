#!/usr/bin/perl

#script to delete items
#written 2/5/00
#by chris@katipo.co.nz

use strict;

use C4::Search;
use CGI;
use C4::Output;
use C4::Acquisitions;

my $input = new CGI;
#print $input->header;
my $item=$input->param('itemnum');
delitem($item);
my $bibitemnum=$input->param('bibitemnum');
print $input->redirect("/cgi-bin/koha/moredetail.pl?bi=$bibitemnum");
