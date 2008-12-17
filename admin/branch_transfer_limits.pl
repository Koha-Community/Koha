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
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Koha;
use C4::Branch; 

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "admin/branch_transfer_limits.tmpl",
			     query => $input,
			     type => "intranet",
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $dbh = C4::Context->dbh;

my @itemtypes;
my @branchcodes;

my $sth = $dbh->prepare("SELECT itemtype FROM itemtypes");
$sth->execute();
while ( my $row = $sth->fetchrow_hashref ) {
	push( @itemtypes, $row->{'itemtype'} );
}

$sth = $dbh->prepare("SELECT branchcode FROM branches");
$sth->execute();
while ( my $row = $sth->fetchrow_hashref ) {
	push( @branchcodes, $row->{'branchcode'} );
}

## If Form Data Passed, Update the Database
if ( $input->param('updateLimits') ) {
    DeleteBranchTransferLimits();

	foreach my $itemtype ( @itemtypes ) {
		foreach my $toBranch ( @branchcodes ) {
			foreach my $fromBranch ( @branchcodes ) {
				my $isSet = $input->param( $itemtype . "_" . $toBranch . "_" . $fromBranch );
				if ( $isSet ) {
                                    CreateBranchTransferLimit( $toBranch, $fromBranch, $itemtype );
				}
			}
		}
	}
}

## Build branchcode loop
my @branchcode_loop;
foreach my $branchcode ( @branchcodes ) {
	my %row_data;
	$row_data{ branchcode } = $branchcode;
	push ( @branchcode_loop, \%row_data );
}

## Build the default data
my @loop0;
foreach my $itemtype ( @itemtypes ) {
	my @loop1;
	my %row_data;
	$row_data{ itemtype } = $itemtype;
	$row_data{ loop1 } = \@loop1;
	foreach my $toBranch ( @branchcodes ) {
		my @loop2;
		my %row_data;
		$row_data{ itemtype } = $itemtype;
		$row_data{ toBranch } = $toBranch;
		$row_data{ loop2 } = \@loop2;
		
		foreach my $fromBranch ( @branchcodes ) {
			my %row_data;
                        my $isChecked = ! IsBranchTransferAllowed( $toBranch, $fromBranch, $itemtype );
			$row_data{ itemtype } = $itemtype;
			$row_data{ toBranch } = $toBranch;
			$row_data{ fromBranch } = $fromBranch;
                        $row_data{ isChecked } = $isChecked;
			
			push( @loop2, \%row_data );
		}
		
		push( @loop1, \%row_data );
	}

	push( @loop0, \%row_data );	
}


$template->param(
		loop0 => \@loop0,
		branchcode_loop => \@branchcode_loop,
		intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
		intranetstylesheet => C4::Context->preference("intranetstylesheet"),
		IntranetNav => C4::Context->preference("IntranetNav"),
		);

output_html_with_http_headers $input, $cookie, $template->output;

