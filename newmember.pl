#!/usr/bin/perl

# $Id$

#script to print confirmation screen, then if accepted calls itself to insert data
# FIXME - Yes, but what does it _do_?
# 2002/12/18 hdl@ifrance.com templating

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
use HTML::Template;

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

my $template = gettemplate("newmember.tmpl");
#print $input->header;
#print startpage();
#print startmenu('member');
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
$template->param(	OK=> ($ok==0),
								string=> $string);
  if ($ok ==0){
   my $name=$data{'title'}." ";
   if ($data{'othernames'} ne ''){
     $name.=$data{'othernames'}." ";
   } else {
     $name.=$data{'firstname'}." ";
   }
   $name.="$data{'surname'} ( $data{'firstname'}, $data{'initials'})";
   my $sex;
   if ($data{'sex'} eq 'M'){
     $sex="Male";
   } else {
     $sex="Female";
   }
   if ($data{'joining'} eq ''){
     $data{'joining'}=ParseDate('today');
     $data{'joining'}=&UnixDate($data{'joining'},'%Y-%m-%d');
   }
   if ($data{'expiry'} eq ''){
     $data{'expiry'}=ParseDate('in 1 year');
     $data{'expiry'}=&UnixDate($data{'expiry'},'%Y-%m-%d');
   }
   my $ethnic=$data{'ethnicity'}." ".$data{'ethnicnotes'};
   my $postal=$data{'address'}."<br>".$data{'city'};
   my $home;
   if ($data{'streetaddress'} ne ''){
     $home=$data{'streetaddress'}."<br>".$data{'streetcity'};
   } else {
     $home=$postal;
   }
   my @inputsloop;
   while (my ($key, $value) = each %data) {
     $value=~ s/\"/%22/g;
			my %line;
			$line{'key'}=$key;
			$line{'value'}=$value;
			push(@inputsloop, \%line);
  }

   $template->param(name => $name,
									bornum => $data{'borrowernumber'},
									cardnum => $data{'cardnumber'},
									memcat => $data{'categorycode'},
									area => $data{'area'},
									fee => $data{'fee'},
									joindate => $data{'joining'},
									expdate => $data{'expiry'},
									joinbranch => $data{'joinbranch'},
									ethnic => $ethnic,
									dob => $data{'dateofbirth'},
									sex => $sex,
									postal => $postal,
									home => $home,
									phone => $data{'phone'},
									phoneday => $data{'phoneday'},
									faxnumber => $data{'faxnumber'},
									emailaddress => $data{'emailaddress'},
									contactname => $data{'contactname'},
									altphone => $data{'altphone'},
									altrelationship => $data{'altrelationship'},
									altnotes => $data{'altnotes'},
									bornotes => $data{'borrowernotes'},
									inputsloop => \@inputsloop);
  }
print "Content-Type: text/html\n\n", $template->output;


