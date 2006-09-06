#!/usr/bin/perl
# WARNING: 4-character tab stops here

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
use C4::Koha;
use C4::Auth;
use C4::Context;
use C4::Search;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Biblio;
use C4::Acquisition;
use C4::Koha; # XXX subfield_is_koha_internal_p


# Creates a scrolling list with the associated default value.
# Using more than one scrolling list in a CGI assigns the same default value to all the
# scrolling lists on the page !?!? That's why this function was written.

my $query=new CGI;
my $type=$query->param('type');
my $op = $query->param('op');
my $dbh = C4::Context->dbh;

my $startfrom=$query->param('startfrom');
$startfrom=0 if(!defined $startfrom);
my ($template, $loggedinuser, $cookie);
my $resultsperpage;

if ($op eq "do_search") {
	my @kohafield = $query->param('kohafield');
	my @and_or = $query->param('and_or');
	my @relation = $query->param('relation');
	my @value = $query->param('value');
	my $order=$query->param('order');
	$resultsperpage= $query->param('resultsperpage');
	$resultsperpage = 9 if(!defined $resultsperpage);
	# builds tag and subfield arrays
	
	my ($total,@results) = ZEBRAsearch_kohafields(\@kohafield,\@value,\@relation,$order,\@and_or,1,"",$startfrom,$resultsperpage,"intranet");
 										
	($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "serials/result.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {borrowers => 1},
				flagsrequired => {catalogue => 1},
				debug => 1,
				});

	# multi page display gestion
	my $displaynext=0;
	my $displayprev=$startfrom;
	if(($total - (($startfrom+1)*($resultsperpage))) > 0 ){
		$displaynext = 1;
	}

	my @field_data = ();


	for(my $i = 0 ; $i <= $#value ; $i++)
	{
		push @field_data, { term => "kohafield", val=>$kohafield[$i] };
		push @field_data, { term => "and_or", val=>$and_or[$i] };
		push @field_data, { term => "relation", val=>$relation[$i] };
		push @field_data, { term => "value", val=>$value[$i] };
	}

	my @numbers = ();

	if ($total>$resultsperpage)
	{
		for (my $i=1; $i<$total/$resultsperpage+1; $i++)
		{
			if ($i<16)
			{
	    		my $highlight=0;
	    		($startfrom==($i-1)) && ($highlight=1);
	    		push @numbers, { number => $i,
					highlight => $highlight ,
					searchdata=> \@field_data,
					startfrom => ($i-1)};
			}
    	}
	}

	my $from = $startfrom*$resultsperpage+1;
	my $to;

 	if($total < (($startfrom+1)*$resultsperpage))
	{
		$to = $total;
	} else {
		$to = (($startfrom+1)*$resultsperpage);
	}
	$template->param(result => \@results,
							startfrom=> $startfrom,
							displaynext=> $displaynext,
							displayprev=> $displayprev,
							resultsperpage => $resultsperpage,
							startfromnext => $startfrom+1,
							startfromprev => $startfrom-1,
							searchdata=>\@field_data,
							total=>$total,
							from=>$from,
							to=>$to,
							numbers=>\@numbers,
							);
} else {
	($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "serials/subscription-bib-search.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});
	my $sth=$dbh->prepare("Select itemtype,description from itemtypes order by description");
	$sth->execute;
	my  @itemtype;
	my %itemtypes;
	push @itemtype, "";
	$itemtypes{''} = "";
	while (my ($value,$lib) = $sth->fetchrow_array) {
		push @itemtype, $value;
		$itemtypes{$value}=$lib;
	}

	my $CGIitemtype=CGI::scrolling_list( -name     => 'value',
				-values   => \@itemtype,
 				-labels   => \%itemtypes,
				-size     => 1,
	 			-tabindex=>'',
				-multiple => 0 );
	$sth->finish;

	$template->param(
			CGIitemtype => $CGIitemtype,
			);
}


# Print the page
$template->param(intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
		intranetstylesheet => C4::Context->preference("intranetstylesheet"),
		IntranetNav => C4::Context->preference("IntranetNav"),
		);
output_html_with_http_headers $query, $cookie, $template->output;

# Local Variables:
# tab-width: 4
# End:
