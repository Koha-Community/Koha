#!/usr/bin/perl

#written 18/1/2000 by chris@katipo.co.nz
#script to renew items from the web

use CGI;
use C4::Circulation::Renewals2;
#get input
my $input= new CGI;
#print $input->header;

#print $input->dump;

my @names=$input->param();
my $count=@names;
my %data;

for (my $i=0;$i<$count;$i++){
  if ($names[$i] =~ /renew/){
    my $temp=$names[$i];
    $temp=~ s/renew_item_//;
    $data{$temp}=$input->param($names[$i]);
  }
}
my %env;
my $bornum=$input->param("bornum");
while ( my ($key, $value) = each %data) {
 #  print "$key = $value\n";
   if ($value eq 'y'){
     #means we want to renew this item
     #check its status
     my $status=renewstatus(\%env,$bornum,$key);
     if ($status == 1){
       renewbook(\%env,$bornum,$key);
     }
   }
}	

print $input->redirect("/cgi-bin/koha/moremember.pl?bornum=$bornum");
