#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# copyright 2010 BibLibre
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

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
    = get_template_and_user({template_name => "admin/branch_transfer_limits.tt",
			     query => $input,
			     type => "intranet",
                 flagsrequired => {parameters => 'parameters_remaining_permissions'},
			     debug => 1,
			     });

my $dbh = C4::Context->dbh;
my $branchcode;
if((!defined($input->param('branchcode'))) & mybranch() ne '')
{
	$branchcode = mybranch();
}
else
{
	$branchcode = $input->param('branchcode');
}

my $branchname = GetBranchName($branchcode);

# Getting the branches for user selection
my $branches = GetBranches();
my @branch_loop;
for my $thisbranch (sort { $branches->{$a}->{branchname} cmp $branches->{$b}->{branchname} } keys %$branches) {
    my %row =(value => $thisbranch,
              branchname => $branches->{$thisbranch}->{'branchname'},
              selected => $thisbranch eq $branchcode ? 1 : 0,
             );
    push @branch_loop, \%row;
}


# Set the template language for the correct limit type using $limitType
my $limitType = C4::Context->preference("BranchTransferLimitsType") || "ccode";

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
    DeleteBranchTransferLimits($branchcode);


	foreach my $code ( @codes ) {
		foreach my $toBranch ( @branchcodes ) {
			my $isSet = not $input->param( $code . "_" . $toBranch);
			if ( $isSet ) {
			    CreateBranchTransferLimit( $toBranch, $branchcode, $code );
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
my $branchcount = scalar(@branchcode_loop);

## Build the default data
my @codes_loop;
foreach my $code ( @codes ) {
	my @to_branch_loop;
	my %row_data;
	$row_data{ code } = $code;
	$row_data{ to_branch_loop } = \@to_branch_loop;
	foreach my $toBranch ( @branchcodes ) {
		my %row_data;
                my $isChecked = IsBranchTransferAllowed( $toBranch, $branchcode, $code );
		$row_data{ code }         = $code;
		$row_data{ toBranch }     = $toBranch;
		$row_data{ isChecked }    = $isChecked;	
		$row_data{ toBranchname } = GetBranchName($toBranch);	
		push( @to_branch_loop, \%row_data );
	}

	push( @codes_loop, \%row_data );
}


$template->param(
		branchcount => $branchcount,
		codes_loop => \@codes_loop,
		branch_loop => \@branch_loop,
		branchcode_loop => \@branchcode_loop,
		branchcode => $branchcode,
		branchname => $branchname,
        limitType => $limitType,
		);

output_html_with_http_headers $input, $cookie, $template->output;

