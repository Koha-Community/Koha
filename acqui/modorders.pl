#!/usr/bin/perl

#script to add an order into the system
#written 29/2/00 by chris@katipo.co.nz

use strict;
use CGI;
use C4::Output;
use C4::Acquisitions;
#use Date::Manip;

my $input = new CGI;
#print $input->header;
#print startpage();
#print startmenu('acquisitions');
#print $input->Dump;
my $basketno=$input->param('basketno');
my $count=$input->param('number');
for (my $i=0;$i<$count;$i++){
  my  $bibnum=$input->param("bibnum$i");
  my $ordnum=$input->param("ordnum$i");
  my $quantity=$input->param("quantity$i");
  if ($quantity == 0){
    delorder($bibnum,$ordnum);
  }
}
print $input->redirect("basket.pl?basket=$basketno");
#print $input->dump;
#print endmenu('acquisitions');
#print endpage();
