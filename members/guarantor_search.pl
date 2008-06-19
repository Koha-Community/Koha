#!/usr/bin/perl


# script to find a guarantor

# Copyright 2006 OUEST PROVENCE
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
use C4::Dates qw/format_date/;
use C4::Members;

my $input = new CGI;
my ($template, $loggedinuser, $cookie);

	($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/guarantor_search.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });
# }
my $theme = $input->param('theme') || "default";
			# only used if allowthemeoverride is set


my $member=$input->param('member');
my $orderby=$input->param('orderby');
$orderby = "surname,firstname" unless $orderby;
$member =~ s/,//g;   #remove any commas from search string
$member =~ s/\*/%/g;
if ($member eq ''){
		$template->param(results=>0);
}else{
		$template->param(results=>1);
}	

my ($count,$results);
my @resultsdata;
my $background = 0;

if ($member ne ''){
	if(length($member) == 1)
	{
		($count,$results)=SearchMember($member,$orderby,"simple",'A');
	}
	else
	{
		($count,$results)=SearchMember($member,$orderby,"advanced",'A');
	}
	for (my $i=0; $i < $count; $i++){
	#find out stats
	my ($od,$issue,$fines)=GetMemberIssuesAndFines($results->[$i]{'borrowerid'});
	my $guarantorinfo=uc($results->[$i]{'surname'})." , ".ucfirst($results->[$i]{'firstname'});
	my %row = (
		background => $background,
		count => $i+1,
		borrowernumber => $results->[$i]{'borrowernumber'},
		cardnumber => $results->[$i]{'cardnumber'},
		surname => $results->[$i]{'surname'},
		firstname => $results->[$i]{'firstname'},
		categorycode => $results->[$i]{'categorycode'},
		address => $results->[$i]{'address'},
		city => $results->[$i]{'city'},
		zipcode => $results->[$i]{'zipcode'},
		branchcode => $results->[$i]{'branchcode'},
		guarantorinfo =>$guarantorinfo,
		#op
		dateofbirth =>format_date($results->[$i]{'dateofbirth'}),
		#fi op	
		
		odissue => "$od/$issue",
		fines => $fines,
		borrowernotes => $results->[$i]{'borrowernotes'});
	if ( $background ) { $background = 0; } else {$background = 1; }
	push(@resultsdata, \%row);
		}
}
$template->param( 
			member          => $member,
			numresults		=> $count,
			
			resultsloop     => \@resultsdata );

output_html_with_http_headers $input, $cookie, $template->output;
