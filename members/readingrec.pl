#!/usr/bin/perl

# written 27/01/2000
# script to display borrowers reading record

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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

use CGI;

use C4::Auth;
use C4::Output;
use C4::Members;
use C4::Branch;
use List::MoreUtils qw/any/;

use C4::Dates qw/format_date/;

my $input = CGI->new;

#get borrower details
my $data = undef;
my $borrowernumber = undef;
my $cardnumber = undef;

my ($template, $loggedinuser, $cookie)= get_template_and_user({template_name => "members/readingrec.tmpl",
				query => $input,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {borrowers => 1},
				debug => 1,
				});

if ($input->param('cardnumber')) {
    $cardnumber = $input->param('cardnumber');
    $data = GetMember(cardnumber => $cardnumber);
    $borrowernumber = $data->{'borrowernumber'}; # we must define this as it is used to retrieve other data about the patron
}
if ($input->param('borrowernumber')) {
    $borrowernumber = $input->param('borrowernumber');
    $data = GetMember(borrowernumber => $borrowernumber);
}

my $order = 'date_due desc';
my $limit = 0;
my ( $issues ) = GetAllIssues($borrowernumber,$order,$limit);

my @loop_reading;

foreach my $issue (@{$issues}){
 	my %line;
 	$line{issuestimestamp} = format_date($issue->{'issuestimestamp'});
	$line{biblionumber}    = $issue->{'biblionumber'};
	$line{title}           = $issue->{'title'};
	$line{author}          = $issue->{'author'};
	$line{classification}  = $issue->{'classification'} || $issue->{'itemcallnumber'};
	$line{date_due}        = format_date($issue->{'date_due'});
	$line{returndate}      = format_date($issue->{'returndate'});
	$line{issuedate}       = format_date($issue->{'issuedate'});
	$line{issuingbranch}   = GetBranchName($issue->{'branchcode'});
	$line{renewals}        = $issue->{'renewals'};
	$line{barcode}         = $issue->{'barcode'};
	$line{volumeddesc}     = $issue->{'volumeddesc'};
	push(@loop_reading,\%line);
}

if ( $data->{'category_type'} eq 'C') {
    my  ( $catcodes, $labels ) =  GetborCatFromCatType( 'A', 'WHERE category_type = ?' );
    my $cnt = scalar(@$catcodes);
    $template->param( 'CATCODE_MULTI' => 1) if $cnt > 1;
    $template->param( 'catcode' =>    $catcodes->[0])  if $cnt == 1;
}

$template->param( adultborrower => 1 ) if ( $data->{'category_type'} eq 'A' );
if (! $limit){
	$limit = 'full';
}

my ($picture, $dberror) = GetPatronImage($data->{'cardnumber'});
$template->param( picture => 1 ) if $picture;

$template->param(
						readingrecordview => 1,
						biblionumber => $data->{'biblionumber'},
						title => $data->{'title'},
						initials => $data->{'initials'},
						surname => $data->{'surname'},
						borrowernumber => $borrowernumber,
						limit => $limit,
						firstname => $data->{'firstname'},
						cardnumber => $data->{'cardnumber'},
					    categorycode => $data->{'categorycode'},
					    category_type => $data->{'category_type'},
					   # category_description => $data->{'description'},
					    categoryname	=> $data->{'description'},
					    address => $data->{'address'},
						address2 => $data->{'address2'},
					    city => $data->{'city'},
					    state => $data->{'state'},
						zipcode => $data->{'zipcode'},
						country => $data->{'country'},
						phone => $data->{'phone'},
						email => $data->{'email'},
			   			branchcode => $data->{'branchcode'},
			   			is_child        => ($data->{'category_type'} eq 'C'),
			   			branchname => GetBranchName($data->{'branchcode'}),
						showfulllink => (scalar @loop_reading > 50),					
						loop_reading => \@loop_reading);
output_html_with_http_headers $input, $cookie, $template->output;



