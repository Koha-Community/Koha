#!/usr/bin/perl

#script to place reserves/requests
#writen 2/1/00 by chris@katipo.oc.nz

use strict;
#use DBI;
use C4::Search;
use CGI;
use C4::Output;
use C4::Reserves2;

my $input = new CGI;
#print $input->header;

my @bibitems=$input->param('biblioitem');
my @reqbib=$input->param('reqbib');
my $biblio=$input->param('biblio');
my $borrower=$input->param('member');
my $notes=$input->param('notes');
my $branch=$input->param('pickup');
my @rank=$input->param('rank-request');
my $type=$input->param('type');
my $title=$input->param('title');
my $bornum=borrdata($borrower,'');
if ($type eq 'str8' && $bornum ne ''){
my $count=@bibitems;
@bibitems=sort @bibitems;
my $i2=1;
my @realbi;
$realbi[0]=$bibitems[0];
for (my $i=1;$i<$count;$i++){
  my $i3=$i2-1;
  if ($realbi[$i3] ne $bibitems[$i]){
    $realbi[$i2]=$bibitems[$i];
    $i2++;
  }
}
#print $input->dump;
my $env;

my $const;
if ($input->param('request') eq 'any'){
  $const='a';
  CreateReserve(\$env,$branch,$bornum->{'borrowernumber'},$biblio,$const,\@realbi,$rank[0],$notes,$title);
} elsif ($reqbib[0] ne ''){
  $const='o';
  CreateReserve(\$env,$branch,$bornum->{'borrowernumber'},$biblio,$const,\@reqbib,$rank[0],$notes,$title);
} else {
  CreateReserve(\$env,$branch,$bornum->{'borrowernumber'},$biblio,'a',\@realbi,$rank[0],$notes,$title);
}
#print @realbi;

print $input->redirect("request.pl?bib=$biblio");
} elsif ($bornum eq ''){
  print $input->header();
  print "Invalid card number please try again";
  print $input->dump;
}
