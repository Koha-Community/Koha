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

my @accountrows; # this is for the tmpl-loop

for (my $i=0;$i<$numaccts;$i++){
  $accts->[$i]{'amount'}+=0.00;
  $accts->[$i]{'amountoutstanding'}+=0.00;
  my %row = (   'date'              => $accts->[$i]{'date'},
		'description'       => $accts->[$i]{'description'},
  		'amount'            => $accts->[$i]{'amount'},
		'amountoutstanding' => $accts->[$i]{'amountoutstanding'} );

  if ($accts->[$i]{'accounttype'} ne 'F' && $accts->[$i]{'accounttype'} ne 'FU'){
    $row{'printtitle'}=1;
    $row{'title'} = $accts->[$i]{'title'};
  }

  push(@accountrows, \%row);
}

$template->param( startmenumember => join('', startmenu('member')),
			 endmenumember   => join('', endmenu('member')),
			firstname       => $data->{'firstname'},
			surname         => $data->{'surname'},
			bornum          => $bornum,
			total           => $total,
			accounts        => \@accountrows );

print $input->header(-cookie => $cookie),$template->output;
