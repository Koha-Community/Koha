#!/usr/bin/perl

#script to print confirmation screen, then if accepted calls itself to insert data

use strict;
use C4::Output;
use C4::Input;
use CGI;
use Date::Manip;

my %env;
my $input = new CGI;
#get varibale that tells us whether to show confirmation page
#or insert data
my $insert=$input->param('insert');
print $input->header;
#get rest of data
my %data;
my @names=$input->param;
foreach my $key (@names){                                                                                    
  $data{$key}=$input->param($key);                                                                           
}  
my $ok=0;

my $string="The following compulsary fields have been left blank. Please push the back button
and try again<p>";
if ($data{'cardnumber_institution'} eq ''){
  $string.="Cardnumber<br>";
  $ok=1;
}
if ($data{'institution_name'} eq ''){
  $string.="Institution Name<br>";
  $ok=1;
}
if ($data{'address'} eq ''){
  $string.="Postal Address<br>";
  $ok=1;
}
if ($data{'city'} eq ''){
  $string.="City<br>";
  $ok=1;
}
if ($data{'contactname'} eq ''){
  $string.="Contact Name";
  $ok=1;
}
#print $input->Dump;
#print $string;
print startmenu('member');
if ($ok ==1){
  print $string;
} else {
  my $valid=checkdigit(\%env,$data{"cardnumber_institution"});
  if ($valid != 1){
    print "Invalid cardnumber";
  } else {
    
     my @inputs;
     my $i=0;
     while (my ($key, $value) = each %data) {
       $value=~ s/\"/%22/g;
       $inputs[$i]=["hidden","$key","$value"];
       $i++;                                  
     }                                        
     $inputs[$i]=["submit","submit","submit"];
     print mkformnotable("/cgi-bin/koha/insertidata.pl",@inputs);   
  }
}
print endmenu('member');
print endpage();
