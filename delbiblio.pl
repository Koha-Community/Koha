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
#print $input->header;
#check no items attached
my $count=C4::Acquisitions::itemcount($biblio);


#print $count;
if ($count > 0){
  print $input->header;
  print "This biblio has $count items attached, please delete them before deleting this biblio<p>
  ";
} else {
#delbiblio($biblio);
print $input->redirect("/catalogue/");
}
