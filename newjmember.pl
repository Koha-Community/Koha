#!/usr/bin/perl

# $Id$

#script to print confirmation screen, then if accepted calls itself to insert data
# FIXME - Yes, but what does it _do_?
# 2002/12/18 hdl@ifrance.comTemplating

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

#print $input->header;
my $template = gettemplate("newjmember.tmpl");

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
	my @identsloop;
	for (my $i=0;$i<3;$i++){
		my %ident;
#		$ident{'main'}=$main;
#		$ident{'image'}=$image;
		$ident{'cardchlid')=($data{"cardnumber_child_$i"} ne '');
		if ($data{"cardnumber_child_$i"} ne ''){
			my $name=$data{"firstname_child_$i"}.$data{"surname_child_$i"};
			$ident{'name'}=$name;
			$ident{'bornum'}=$data{"bornumber_child_$i"};
			$ident{'dob'}=$data{"dateofbirth_child_$i"};
			($data{"sex_child_$i"} eq 'M') ? ($ident{'sex'}="Male") : ($ident{'sex'}="Female") ;
			$ident{'school'}=$data{"school_child_$i"};
			$ident{'notes'}=$data{"altnotes_child_$i"}
			push(@identsloop, \%ident);
		}
	}
	my @inputsloop;
	while (my ($key, $value) = each %data) {
		$value=~ s/\"/%22/g;
		my %line;
		$line{'key'}=$key;
		$line{'value'}=$value;
		push(@inputsloop, \%line);
	}

# FIXME IF main and image are not fetched by HTML::TEMPLATE get them into identsloop
$template->param( 	NOK => (ok==1),
								main => $main,
								image => $image,
								identsloop => \@identsloop,
								inputsloop => \@inputsloop,
								string => $string);

print "Content-Type: text/html\n\n", $template->output;
