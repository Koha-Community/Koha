#!/usr/bin/perl

#script to delete items
#written 2/5/00
#by chris@katipo.co.nz

use strict;

use C4::Search;
use CGI;
use C4::Output;
use C4::Acquisitions;
use C4::Biblio;
use C4::Auth;

my $input = new CGI;
my $flagsrequired;
$flagsrequired->{editcatalogue}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0, $flagsrequired);

#print $input->header;
my $item=$input->param('itemnum');
delitem($item);
my $bibitemnum=$input->param('bibitemnum');
print $input->redirect("/cgi-bin/koha/moredetail.pl?bi=$bibitemnum");
