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

#get rest of data
my %data;
my @names=$input->param;
foreach my $key (@names){                                                                                    
  $data{$key}=$input->param($key);                                                                           
}  
print $input->header;
print startpage();
print startmenu('member');
my $main="#99cc33";
my $image="/images/background-mem.gif";
if ($insert eq ''){
  my $ok=0;
  #check that all compulsary fields are entered
  my $string="The following compulsary fields have been left blank. Please push the back button
  and try again<p>";
  if ($data{'cardnumber'} eq ''){
   
     $string.=" Cardnumber<br>";
    $ok=1;
  } else {
     #check cardnumber is valid
     my $valid=checkdigit(\%env,$data{'cardnumber'});
     if ($valid != 1){
       $ok=1;
       $string.=" Invalid Cardnumber<br>";
     }
  }
  if ($data{'sex'} eq ''){
    $string.=" Gender <br>";
    $ok=1;
  }
  if ($data{'firstname'} eq ''){
    $string.=" Given Names<br>";
    $ok=1;
  }
  if ($data{'surname'} eq ''){
    $string.=" Surname<br>";
    $ok=1;
  }
  if ($data{'address'} eq ''){
    $string.=" Postal Street Address<br>";
    $ok=1;
  }
  if ($data{'city'} eq ''){
    $string.=" Postal City<br>";
    $ok=1;
  }
  if ($data{'contactname'} eq ''){
    $string.=" Alternate Contact<br>";
    $ok=1;
  }
  #we are printing confirmation page
  print mkheadr(1,'Confirm Record');
  if ($ok ==0){
   print mktablehdr;
   print mktablerow(2,$main,bold('NEW MEMBER'),"",$image);
   my $name=$data{'title'}." ";
   if ($data{'othernames'} ne ''){
     $name.=$data{'othernames'}." ";
   } else {
     $name.=$data{'firstname'}." ";
   }
   $name.="$data{'surname'} ( $data{'firstname'}, $data{'initials'})";
   print mktablerow(2,'white',bold('Name'),$name);
   print mktablerow(2,$main,bold('MEMBERSHIP DETAILS'),"",$image);
   print mktablerow(2,'white',bold('Membership Number'),$data{'borrowernumber'});
   print mktablerow(2,'white',bold('Cardnumber'),$data{'cardnumber'});
   print mktablerow(2,'white',bold('Membership Category'),$data{'categorycode'});
   print mktablerow(2,'white',bold('Area'),$data{'area'});
   print mktablerow(2,'white',bold('Fee'),$data{'fee'});
   if ($data{'joining'} eq ''){
     $data{'joining'}=ParseDate('today');
     $data{'joining'}=&UnixDate($data{'joining'},'%Y-%m-%d');
   }
   print mktablerow(2,'white',bold('Joining Date'),$data{'joining'});
   if ($data{'expiry'} eq ''){
     $data{'expiry'}=ParseDate('in 1 year');
     $data{'expiry'}=&UnixDate($data{'expiry'},'%Y-%m-%d');
   }
   print mktablerow(2,'white',bold('Expiry Date'),$data{'expiry'});
   print mktablerow(2,'white',bold('Joining Branch'),$data{'joinbranch'});
   print mktablerow(2,$main,bold('PERSONAL DETAILS'),"",$image);
   my $ethnic=$data{'ethnicity'}." ".$data{'ethnicnotes'};
   print mktablerow(2,'white',bold('Ethnicity'),$ethnic);
   $data{'dateofbirth'}=ParseDate($data{'dateofbirth'});
   $data{'dateofbirth'}=UnixDate($data{'dateofbirth'},'%Y-%m-%d');
   print mktablerow(2,'white',bold('Date of Birth'),$data{'dateofbirth'});
   my $sex;
   if ($data{'sex'} eq 'M'){
     $sex="Male";
   } else {
     $sex="Female";
   }
   print mktablerow(2,'white',bold('Sex'),$sex);
   print mktablerow(2,$main,bold('MEMBER ADDRESS'),"",$image);
   my $postal=$data{'address'}."<br>".$data{'city'};
   my $home;
   if ($data{'streetaddress'} ne ''){
     $home=$data{'streetaddress'}."<br>".$data{'streetcity'};
   } else {
     $home=$postal;
   }
   print mktablerow(2,'white',bold('Postal Address'),$postal);
   print mktablerow(2,'white',bold('Home Address'),$home);
   print mktablerow(2,$main,bold('MEMBER CONTACT DETAILS'),"",$image);
   print mktablerow(2,'white',bold('Phone (Home)'),$data{'phone'});
   print mktablerow(2,'white',bold('Phone (Daytime)'),$data{'phoneday'});
   print mktablerow(2,'white',bold('Fax'),$data{'faxnumber'});
   print mktablerow(2,'white',bold('Email'),$data{'emailaddress'});
   print mktablerow(2,$main,bold('ALTERNATIVE CONTACT DETAILS'),"",$image);
   print mktablerow(2,'white',bold('Name'),$data{'contactname'});
   print mktablerow(2,'white',bold('Phone'),$data{'altphone'});
   print mktablerow(2,'white',bold('Relationship'),$data{'altrelationship'});
   print mktablerow(2,'white',bold('Notes'),$data{'altnotes'});
   print mktablerow(2,$main,bold('Notes'),"",$image);
   print mktablerow(2,'white',bold('General Notes'),$data{'borrowernotes'});

   print mktableft;
   #set up form to post data thru for modification or insertion
   my $i=0;
   my @inputs;
   while (my ($key, $value) = each %data) {
     $value=~ s/\"/%22/g;
     $inputs[$i]=["hidden","$key","$value"];       
     $i++;
   }
   $inputs[$i]=["submit","submit","submit"];
   print mkformnotable("/cgi-bin/koha/insertdata.pl",@inputs);
  } else {
    print $string;
  }
}
#print $input->dump;

print mktablehdr;

print mktableft;
print endmenu('member');
print endpage();
