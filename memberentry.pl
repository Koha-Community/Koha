#!/usr/bin/perl
# NOTE: This file uses standard 8-space tabs
#       DO NOT SET TAB SIZE TO 4

# $Id$

#script to set up screen for modification of borrower details
#written 20/12/99 by chris@katipo.co.nz


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
use C4::Interface::CGI::Output;
use CGI;
use C4::Search;
use C4::Members;
use C4::Koha;
use HTML::Template;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/memberentry.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $member=$input->param('bornum');
if ($member eq ''){
  $member=NewBorrowerNumber();
}
my $type=$input->param('type') || '';
my $modify=$input->param('modify.x');
my $delete=$input->param('delete.x');
if ($delete){
  print $input->redirect("/cgi-bin/koha/deletemem.pl?member=$member");

} else {  # this else goes down the whole script
  if ($type ne 'Add'){
    $template->param( header => 'Update Member Details'); # bad templating style
  } else {
    $template->param( header => 'Add New Member');
  }

  my $data=borrdata('',$member);

  if ($type eq 'Add'){
    $template->param( updtype => 'I');
  } else {
    $template->param( updtype => 'M');
  }

  my $cardnumber=C4::Members::fixup_cardnumber($data->{'cardnumber'});

  if ($data->{'sex'} eq 'F'){
    $template->param(female => 1);
  }

  my @titles = ('Miss', 'Mrs', 'Ms', 'Mr', 'Dr', 'Sir');
	# FIXME - Assumes English. This ought to be made part of i18n.
  my @titledata;
  while (@titles) {
    my %row;
    my $title = shift @titles;
    $row{'title'} = $title;
    if ($data->{'title'} eq $title) {
      $row{'selected'}=' selected';
    } else {
      $row{'selected'}='';
    }
    push(@titledata, \%row);
  }

  my ($categories,$labels)=ethnicitycategories();
  my $ethnicitycategoriescount=$#{$categories};
  my $ethcatpopup;
  if ($ethnicitycategoriescount>=0) {
  	$ethcatpopup = CGI::popup_menu(-name=>'ethnicity',
  			        -values=>$categories,
  			        -default=>$data->{'ethnicity'},
  			        -labels=>$labels);
  	$template->param(ethcatpopup => $ethcatpopup); # bad style, has to be fixed
  }

  ($categories,$labels)=borrowercategories();
  my $catcodepopup = CGI::popup_menu(-name=>'categorycode',
  			        -values=>$categories,
  			        -default=>$data->{'categorycode'},
  			        -labels=>$labels);

  my @areas = ('L','F','S','H','K','O','X','Z','V');
  my %arealabels = ('L' => 'Levin',
  		  'F' => 'Foxton',
  		  'S' => 'Shannon',
  		  'H' => 'Horowhenua',
  		  'K' => 'Kapiti',
  		  'O' => 'Out of District',
  		  'X' => 'Temporary Visitor',
  		  'Z' => 'Interloan Libraries',
  		  'V' => 'Village');

  my @areadata;
  while (@areas) {
    my %row;
    my $shortcut = shift @areas;
    $row{'shortcut'} = $shortcut;
    if ($data->{'area'} eq $shortcut) {
      $row{'selected'}=' selected';
    } else {
      $row{'selected'}='';
    }
    $row{'area'}=$arealabels{$shortcut};
    push(@areadata, \%row);
  }


  my @relationships = ('workplace', 'relative','friend', 'neighbour');
  my @relshipdata;
  while (@relationships) {
    my $relship = shift @relationships;
    my %row = ('relationship' => $relship);
    if ($data->{'altrelationship'} eq $relship) {
      $row{'selected'}=' selected';
    } else {
      $row{'selected'}='';
    }
    push(@relshipdata, \%row);
  }

  # %flags: keys=$data-keys, datas=[formname, HTML-explanation]
  my %flags = ('gonenoaddress' => ['gna', 'Gone no address'],
               'lost'          => ['lost', 'Lost'],
               'debarred'      => ['debarred', 'Debarred']);

  my @flagdata;
  foreach (keys(%flags)) {
    my $key = $_;
    my %row =  ('key'   => $key,
		'name'  => $flags{$key}[0],
		'html'  => $flags{$key}[1]);
    if ($data->{$key}) {
      $row{'yes'}=' checked';
      $row{'no'}='';
    } else {
      $row{'yes'}='';
      $row{'no'}=' checked';
    }
    push(@flagdata, \%row);
  }

  if ($modify){
    $template->param( modify => 1 );
  }

  #Convert dateofbirth to correct format
  $data->{'dateofbirth'}=ParseDate($data->{'dateofbirth'});
  $data->{'dateofbirth'}=UnixDate($data->{'dateofbirth'},'%d/%m/%Y');


  $template->param( 
  			member          => $member,
  			firstname       => $data->{'firstname'},
  			surname         => $data->{'surname'},
  			othernames	=> $data->{'othernames'},
  			initials	=> $data->{'initials'},
  			ethcatpopup	=> $ethcatpopup,
  			catcodepopup	=> $catcodepopup,
  			streetaddress   => $data->{'streetaddress'},
  			streetcity      => $data->{'streetcity'},
			city		=> $data->{'city'},
  			phone           => $data->{'phone'},
  			phoneday        => $data->{'phoneday'},
  			faxnumber       => $data->{'faxnumber'},
  			emailaddress    => $data->{'emailaddress'},
  			contactname     => $data->{'contactname'},
  			altphone        => $data->{'altphone'},
  			altnotes	=> $data->{'altnotes'},
  			borrowernotes	=> $data->{'borrowernotes'},
  			flagloop	=> \@flagdata,
  			relshiploop	=> \@relshipdata,
  			titleloop       => \@titledata,
  			arealoop        => \@areadata,
  			dateenrolled	=> $data->{'dateenrolled'},
  			expiry		=> $data->{'expiry'},
  			cardnumber	=> $cardnumber,
  			dateofbirth	=> $data->{'dateofbirth'});

output_html_with_http_headers $input, $cookie, $template->output;


}

# Local Variables:
# tab-width: 8
# End:
