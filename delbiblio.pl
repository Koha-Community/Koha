#!/usr/bin/perl

#script to delete biblios
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
#print $input->header;
my $flagsrequired;
$flagsrequired->{editcatalogue}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0, $flagsrequired);


my $biblio=$input->param('biblio');
#print $input->header;
#check no items attached
my $count=C4::Acquisitions::itemcount($biblio);


#print $count;
if ($count > 0){
  print $input->header(-cookie => $cookie);
  print "This biblio has $count items attached, please delete them before deleting this biblio<p>
  ";
} else {
	delbiblio($biblio);
	print $input->redirect("/catalogue/");
}
