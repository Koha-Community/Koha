#!/usr/bin/perl

#script to delete biblios
#written 2/5/00
#by chris@katipo.co.nz

use strict;

use C4::Search;
use CGI;
use C4::Output;
use C4::Acquisitions;

my $input = new CGI;
#print $input->header;


my $biblio=$input->param('biblio');

delbiblio($biblio);
print $input->redirect("/catalogue/");
