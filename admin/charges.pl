#!/usr/bin/perl

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
use CGI;
use C4::Context;
use C4::Output;
use C4::Database;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use HTML::Template;

my $input = new CGI;

my $flagsrequired;
$flagsrequired->{circulation}=1;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "parameters/charges.tmpl",
                             query => $input,
                             type => "intranet",
                             authnotrequired => 0,
 			     flagsrequired => {parameters => 1},
			      debug => 1,
                             });

my $type=$input->param('type');

my $dbh = C4::Context->dbh;
my $query="Select description,categorycode from categories";
my $sth=$dbh->prepare($query);
$sth->execute;
 my @trow3;
my @title_loop;
my $i=0;
while (my $data=$sth->fetchrow_hashref){
	my %row = (in_title => $data->{'description'});
	push @title_loop,\%row;
 	$trow3[$i]=$data->{'categorycode'};
	$i++;
}
$sth->finish;
$query="Select description,itemtype from itemtypes";
$sth=$dbh->prepare($query);
$sth->execute;
$i=0;
my $toggle="white";
my @row_loop;
while (my $data=$sth->fetchrow_hashref){
	my @trow2;
	my @cell_loop;
	if ( $toggle eq 'white' ) {
		$toggle = '#ffffcc';
	} else {
		$toggle = 'white';
	}
	for ($i=0;$i<9;$i++){
		$query="select * from categoryitem where categorycode=? and itemtype=?";
		my $sth2=$dbh->prepare($query);
		$sth2->execute($trow3[$i],$data->{'itemtype'});
		my $dat=$sth2->fetchrow_hashref;
		$sth2->finish;
		my $fine=$dat->{'fine'}+0;
# 		$trow2[$i]="<input type=text name=\"$trow3[$i].$data->{'itemtype'}\" value=\"$fine,$dat->{'firstremind'},$dat->{'chargeperiod'}\" size=6>";
		my %row = (inputname=> "$trow3[$i].$data->{'itemtype'}",
						inputvalue => "$fine,$dat->{'firstremind'},$dat->{'chargeperiod'}",
						toggle => $toggle,
						);
		push @cell_loop,\%row;
	}
	my %row = (categorycode => $data->{description},
  					cell =>\@cell_loop);
	push @row_loop, \%row;
}

$sth->finish;
$template->param(title => \@title_loop,
						row => \@row_loop);
output_html_with_http_headers $input, $cookie, $template->output;
