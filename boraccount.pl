#!/usr/bin/perl

# $Id$

#writen 11/1/2000 by chris@katipo.oc.nz
#script to display borrowers account details


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
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Date;
use CGI;
use C4::Search;
use HTML::Template;

my $input=new CGI;

my $theme = $input->param('theme'); # only used if allowthemeoverride is set
#my %tmpldata = pathtotemplate ( template => 'boraccount.tmpl', theme => $theme );
#my $template = HTML::Template->new(filename => $tmpldata{'path'}, die_on_bad_params => 0);
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "boraccount.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $bornum=$input->param('bornum');
#get borrower details
my $data=borrdata('',$bornum);

#get account details
my %bor;
$bor{'borrowernumber'}=$bornum;
my ($numaccts,$accts,$total)=getboracctrecord('',\%bor);
my $totalcredit;
if($total <= 0){
	$totalcredit = 1;
}
my @accountrows; # this is for the tmpl-loop

my $toggle;
for (my $i=0;$i<$numaccts;$i++){
	if($i%2){
		$toggle = 0;
	} else {
		$toggle = 1;
	}
  $accts->[$i]{'toggle'} = $toggle;
  $accts->[$i]{'amount'}+=0.00;
  if($accts->[$i]{'amount'} <= 0){
  	$accts->[$i]{'amountcredit'} = 1;
  }
  $accts->[$i]{'amountoutstanding'}+=0.00;
  if($accts->[$i]{'amountoutstanding'} <= 0){
  	$accts->[$i]{'amountoutstandingcredit'} = 1;
  }
  my %row = (   'date'              => format_date($accts->[$i]{'date'}),
  		'amountcredit' => $accts->[$i]{'amountcredit'},
  		'amountoutstandingcredit' => $accts->[$i]{'amountoutstandingcredit'},
  		'toggle' => $accts->[$i]{'toggle'},
		'description'       => $accts->[$i]{'description'},
  		'amount'            => sprintf("%.2f",$accts->[$i]{'amount'}),
		'amountoutstanding' => sprintf("%.2f",$accts->[$i]{'amountoutstanding'}) );

  if ($accts->[$i]{'accounttype'} ne 'F' && $accts->[$i]{'accounttype'} ne 'FU'){
    $row{'printtitle'}=1;
    $row{'title'} = $accts->[$i]{'title'};
  }

  push(@accountrows, \%row);
}

$template->param(
			firstname       => $data->{'firstname'},
			surname         => $data->{'surname'},
			bornum          => $bornum,
			total           => sprintf("%.2f",$total),
			totalcredit => $totalcredit,
			accounts        => \@accountrows );

output_html_with_http_headers $input, $cookie, $template->output;
