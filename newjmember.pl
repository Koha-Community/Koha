#!/usr/bin/perl

# $Id$

#script to print confirmation screen, then if accepted calls itself to insert data
# FIXME - Yes, but what does it _do_?

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

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
for (my $i=0;$i<3;$i++){
  my $number=$data{"cardnumber_child_$i"};
  my $firstname=$data{"firstname_child_$i"};
  my $surname=$data{"surname_child_$i"};
  my $dob=$data{"dateofbirth_child_$i"};
  my $sex=$data{"sex_child_$i"};
  if ($number eq ''){
    if ($i == 0){
      $string.=" Cardnumber<br>";
      $ok=1;
    }
  } else {
    if ($firstname eq ''){
      $string.=" Given Names<br>";
      $ok=1;
    }
    if ($surname eq ''){
      $string.=" Surname<br>";
      $ok=1;
    }
    if ($dob eq ''){
      $string.=" Date Of Birth<br>";
      $ok=1;
    }
    if ($sex eq ''){
      $string.=" Gender <br>";
      $ok=1;
    }
    my $valid=checkdigit(\%env,$data{"cardnumber_child_$i"});
    if ($valid != 1){
      $ok=1;
      $string.=" Invalid Cardnumber $number<br>";
    }
  }
}

print startpage();
print startmenu('member');

if ($ok == 0){
  print mkheadr(1,'Confirm Record');
  my $main="#99cc33";
  my $image="/images/background-mem.gif";
  for (my $i=0;$i<3;$i++){
    if ($data{"cardnumber_child_$i"} ne ''){
      print mktablehdr;
      print mktablerow(2,$main,bold('NEW MEMBER'),"",$image);
      my $name=$data{"firstname_child_$i"}.$data{"surname_child_$i"};
      print mktablerow(2,'white',bold('Name'),$name);
      print mktablerow(2,$main,bold('MEMBERSHIP DETAILS'),"",$image);
      print mktablerow(2,'white',bold('Membership Number'),$data{"bornumber_child_$i"});
      print mktablerow(2,'white',bold('Date of Birth'),$data{"dateofbirth_child_$i"});
      my $sex;
      if ($data{"sex_child_$i"} eq 'M'){
         $sex="Male";
      } else {
         $sex="Female";
      }
      print mktablerow(2,'white',bold('Sex'),$sex);
      print mktablerow(2,'white',bold('School'),$data{"school_child_$i"});
      print mktablerow(2,'white',bold('General Notes'),$data{"altnotes_child_$i"});

      print mktableft;
      print "<p>";
    }
  }
  my $i=0;
  my @inputs;
  while (my ($key, $value) = each %data) {
    $value=~ s/\"/%22/g;
    $inputs[$i]=["hidden","$key","$value"];
    $i++;
  }
  $inputs[$i]=["submit","submit","submit"];
  print mkformnotable("/cgi-bin/koha/insertjdata.pl",@inputs);

} else {


#print $input->dump;
print $string;
}
print endmenu('member');
print endpage();
