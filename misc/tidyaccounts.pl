#!/usr/bin/perl
#
# written 31/5/00 by chris@katipo.co.nz to make a way to fix account mistakes
#

use strict;
use C4::Database;
use CGI;
use C4::Accounts2;

my $input=new CGI;

#print $input->header();
#print $input->dump;

my $bornum=$input->param('bornum');

my @name=$input->param;

foreach my $key (@name){
  if ($key ne 'bornum'){
    if (my $temp=$input->param($key)){
      fixaccounts($bornum,$key,$temp);
    }
  }
}
    
print $input->redirect("boraccount.pl?bornum=$bornum");
