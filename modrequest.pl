#!/usr/bin/perl

#script to modify reserves/requests
#written 2/1/00 by chris@katipo.oc.nz
#last update 27/1/2000 by chris@katipo.co.nz

use strict;
#use DBI;
use C4::Search;
use CGI;
use C4::Output;
use C4::Reserves2;

my $input = new CGI;
#print $input->header;

#print $input->dump;

my @rank=$input->param('rank-request');
my @biblio=$input->param('biblio');
my @borrower=$input->param('borrower');
my @branch=$input->param('pickup');
my $count=@rank;
my $del=0;
for (my $i=0;$i<$count;$i++){
  if ($rank[$i] ne 'del' && $del == 0){
    updatereserves($rank[$i],$biblio[$i],$borrower[$i],0,$branch[$i]); #from C4::Reserves2
    
  } elsif ($rank[$i] eq 'del'){
    updatereserves($rank[$i],$biblio[$i],$borrower[$i],1); #from C4::Reserves2
    $del=1;
  }
  
}
my $from=$input->param('from');
if ($from eq 'borrower'){
  print $input->redirect("/cgi-bin/koha/moremember.pl?bornum=$borrower[0]");
 } else {
   print $input->redirect("/cgi-bin/koha/request.pl?bib=$biblio[0]");
}
