#!/usr/bin/perl

# $Id$

# script to do a borrower enquiry/bring up borrower details etc
# Displays all the details about a borrower
# written 20/12/99 by chris@katipo.co.nz
# last modified 21/1/2000 by chris@katipo.co.nz
# modified 31/1/2001 by chris@katipo.co.nz
#   to not allow items on request to be renewed
#
# needs html removed and to use the C4::Output more, but its tricky
#


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
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Charset;
use CGI;
use C4::Search;
use Date::Manip;
use C4::Reserves2;
use C4::Circulation::Renewals2;
use C4::Circulation::Circ2;
use C4::Koha;
use HTML::Template;

my $dbh = C4::Context->dbh;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/moremember.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $bornum=$input->param('bornum');

#start the page and read in includes

my $data=borrdata('',$bornum);

$data->{'dateenrolled'} = slashifyDate($data->{'dateenrolled'});
$data->{'expiry'} = slashifyDate($data->{'expiry'});
$data->{'dateofbirth'} = slashifyDate($data->{'dateofbirth'});

$data->{'ethnicity'} = fixEthnicity($data->{'ethnicity'});

if ($data->{'categorycode'} eq 'C'){
    my $data2=borrdata('',$data->{'guarantor'});
    $data->{'streetaddress'}=$data2->{'streetaddress'};
    $data->{'city'}=$data2->{'city'};
    $data->{'physstreet'}=$data2->{'phystreet'};
    $data->{'streetcity'}=$data2->{'streetcity'};
    $data->{'phone'}=$data2->{'phone'};
    $data->{'phoneday'}=$data2->{'phoneday'};
}


if ($data->{'ethnicity'} || $data->{'ethnotes'}) {
	$template->param(printethnicityline => 1);
}

if ($data->{'categorycode'} ne 'C'){
  $template->param(isguarantee => 1);
  # FIXME
  # It looks like the $i is only being returned to handle walking through
  # the array, which is probably better done as a foreach loop.
  #
  my ($count,$guarantees)=findguarantees($data->{'borrowernumber'});
  my @guaranteedata;
  for (my $i=0;$i<$count;$i++){
    push (@guaranteedata, {borrowernumber => $guarantees->[$i]->{'borrowernumber'},
    			   cardnumber => $guarantees->[$i]->{'cardnumber'}});
  }
  $template->param(guaranteeloop => \@guaranteedata);

} else {
  my ($guarantor)=findguarantor($data->{'borrowernumber'});
  unless ($guarantor->{'borrowernumber'} == 0){
    $template->param(guarantorborrowernumber => $guarantor->{'borrowernumber'}, guarantorcardnumber => $guarantor->{'cardnumber'});
  }
}

my %bor;
$bor{'borrowernumber'}=$bornum;

# FIXME
# it looks like $numaccts is a temp variable and that the
# for (my $i;$i<$numaccts;$i++)
# can be turned into a foreach loop instead
#
my ($numaccts,$accts,$total)=getboracctrecord('',\%bor);
#if ($numaccts > 10){
#  $numaccts=10;
#}
my @accountdata;
for (my$i=0;$i<$numaccts;$i++){
  my $amount= $accts->[$i]{'amount'} + 0.00;
  my $amount2= $accts->[$i]{'amountoutstanding'} + 0.00;
  my %row = %$accts->[$i];
  if ($amount2 != 0){
    my $item=" &nbsp; ";
    $row{'date'} = slashifyDate($accts->[$i]{'date'});

    if ($accts->[$i]{'accounttype'} ne 'Res'){
      #get item data
      #$item=
    }

    # FIXME
    # why set this variable if it's not going to be used?
    #
    my $env;
    if ($accts->[$i]{'accounttype'} ne 'Res'){
      my $iteminfo=C4::Circulation::Circ2::getiteminformation($env,$accts->[$i]->{'itemnumber'},'');
   # FIXME, seems to me $iteminfo gets not defined
      %row = (%row , %$iteminfo) if $iteminfo;
    }
  }
  push (@accountdata, \%row);
}

my ($count,$issue)=borrissues($bornum);
my $today=ParseDate('today');
my @issuedata;
for (my $i=0;$i<$count;$i++){
  my $datedue=ParseDate($issue->[$i]{'date_due'});
  $issue->[$i]{'date_due'} = slashifyDate($issue->[$i]{'date_due'});
  my %row = %{$issue->[$i]};
  if ($datedue < $today){
    $row{'red'}=1; #print "<font color=red>";
  }
  #find the charge for an item
  # FIXME - This is expecting
  # &C4::Circulation::Renewals2::calc_charges, but it's getting
  # &C4::Circulation::Circ2::calc_charges, which only returns one
  # element, so itemtype isn't being set.
  # But &C4::Circulation::Renewals2::calc_charges doesn't appear to
  # return the correct item type either (or a properly-formatted
  # charge, for that matter).
  my ($charge,$itemtype)=calc_charges(undef,$dbh,$issue->[$i]{'itemnumber'},$bornum);
  $row{'itemtype'}=$itemtype;
  $row{'charge'}=$charge;

  #check item is not reserved
  my ($restype,$reserves)=CheckReserves($issue->[$i]{'itemnumber'});
  if ($restype){
    print "<TD><a href=/cgi-bin/koha/request.pl?bib=$issue->[$i]{'biblionumber'}>On Request - no renewals</a></td></tr>";
#  } elsif ($issue->[$i]->{'renewals'} > 0) {
#      print "<TD>Previously Renewed - no renewals</td></tr>";
  } else {
    $row{'norenew'}=0;
  }
  push (@issuedata, \%row);
}

my ($rescount,$reserves)=FindReserves('',$bornum); #From C4::Reserves2

# FIXME
# does it make sense to turn this into a foreach my $i (0..$rescount)
# kind of loop?
#
my @reservedata;
for (my $i=0;$i<$rescount;$i++){
  $reserves->[$i]{'reservedate2'} = slashifyDate($reserves->[$i]{'reservedate'});
  my $restitle;
  my %row = %$reserves->[$i];
  if ($reserves->[$i]{'constrainttype'} eq 'o'){
    $restitle=getreservetitle($reserves->[$i]{'biblionumber'},$reserves->[$i]{'borrowernumber'},$reserves->[$i]{'reservedate'},$reserves->[$i]{'timestamp'});
    %row =  (%row , %$restitle);
  }
  push (@reservedata, \%row);
}

$template->param($data);
$template->param(
		 bornum          => $bornum,
		 accountloop     => \@accountdata,
		 issueloop       => \@issuedata,
		 reserveloop     => \@reservedata);

print $input->header(
    -type => guesstype($template->output),
    -cookie => $cookie
),$template->output;
