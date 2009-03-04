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
use warnings;

use CGI;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Koha;
use C4::Branch; 
use C4::Circulation qw{ IsBranchTransferAllowed DeleteBranchTransferLimits CreateBranchTransferLimit };

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "admin/branch_transfer_limits.tmpl",
			     query => $input,
			     type => "intranet",
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $dbh = C4::Context->dbh;

# Set the template language for the correct limit type
my $limit_phrase = 'Collection Code';
my $limitType = C4::Context->preference("BranchTransferLimitsType");
if ( $limitType eq 'itemtype' ) {
	$limit_phrase = 'Item Type';
}

my @codes;
my @branchcodes;

my $sth;
if ( $limitType eq 'ccode' ) {
	$sth = $dbh->prepare('SELECT authorised_value AS ccode FROM authorised_values WHERE category = "CCODE"');
} elsif ( $limitType eq 'itemtype' ) {
	$sth = $dbh->prepare('SELECT itemtype FROM itemtypes');
}
$sth->execute();
while ( my $row = $sth->fetchrow_hashref ) {
	push( @codes, $row->{ $limitType } );
}

$sth = $dbh->prepare("SELECT branchcode FROM branches");
$sth->execute();
while ( my $row = $sth->fetchrow_hashref ) {
	push( @branchcodes, $row->{'branchcode'} );
}

## If Form Data Passed, Update the Database
if ( $input->param('updateLimits') ) {
    DeleteBranchTransferLimits();

	foreach my $code ( @codes ) {
		foreach my $toBranch ( @branchcodes ) {
			foreach my $fromBranch ( @branchcodes ) {
				my $isSet = $input->param( $code . "_" . $toBranch . "_" . $fromBranch );
				if ( $isSet ) {
                                    CreateBranchTransferLimit( $toBranch, $fromBranch, $code );
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
my @codes_loop;
foreach my $code ( @codes ) {
	my @to_branch_loop;
	my %row_data;
	$row_data{ code } = $code;
	$row_data{ to_branch_loop } = \@to_branch_loop;
	foreach my $toBranch ( @branchcodes ) {
		my @from_branch_loop;
		my %row_data;
		$row_data{ code } = $code;
		$row_data{ toBranch } = $toBranch;
		$row_data{ from_branch_loop } = \@from_branch_loop;
		
		foreach my $fromBranch ( @branchcodes ) {
			my %row_data;
                        my $isChecked = ! IsBranchTransferAllowed( $toBranch, $fromBranch, $code );
			$row_data{ code } = $code;
			$row_data{ toBranch } = $toBranch;
			$row_data{ fromBranch } = $fromBranch;
                        $row_data{ isChecked } = $isChecked;
			
			push( @from_branch_loop, \%row_data );
		}
		
		push( @to_branch_loop, \%row_data );
	}

	push( @codes_loop, \%row_data );
}


$template->param(
		codes_loop => \@codes_loop,
		branchcode_loop => \@branchcode_loop,
		limit_phrase => $limit_phrase,
		);

output_html_with_http_headers $input, $cookie, $template->output;

