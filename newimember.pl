#!/usr/bin/perl

# $Id$

#script to print confirmation screen, then if accepted calls itself to insert data
#modified 2002/12/16 by hdl@ifrance.com : Templating


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

my $template=gettemplate("newimember.tmpl");
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
#print startmenu('member');

$template->param( missingloop => ($ok==1));
$template->param( string => $string);
if ($ok !=1) {
	my $valid=checkdigit(\%env,$data{"cardnumber_institution"});
	$template->param( invalid => ($valid !=1));
	if (valid==1){
		my @inputs;
		while (my ($key, $value) = each %data) {
			$value=~ s/\"/%22/g;
			my %line;
			$line{'key'}=$key;
			$line{'value'}=$value;
			push(@inputs, \%line);
			}
		$template->param(inputsloop => \@inputs);
  }
}
print "Content-Type: text/html\n\n", $template->output;

