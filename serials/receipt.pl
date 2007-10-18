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
use C4::Output;
use C4::Context;


my $query = new CGI;

my $op = $query->param('op');
my $search = $query->param('titleorissn');
my $startfrom=$query->param('startfrom');

if ($op eq 'search')
{
    my $total;
    my $results;
    my $dbh = C4::Context->dbh;
    my @marclist = $query->param('marclist');
	my @and_or = $query->param('and_or');
	my @excluding = $query->param('excluding');
	my @operator = $query->param('operator');
	my @value = $query->param('value');

	my $resultsperpage= $query->param('resultsperpage');
	$resultsperpage = 19 unless $resultsperpage;


    my $sth = $dbh->prepare("select subscriptionid, biblionumber from subscription");
    $sth->execute();
    my @finalsolution;
    while (my $first_step = $sth->fetchrow_hashref)
    {
	my $sth2 = $dbh->prepare("select b3.title from biblioitems b2, biblio b3 where b3.biblionumber = ? and b2.biblionumber = b3.biblionumber and (b2.issn = ? or b3.title like ?)");
	$sth2->execute($first_step->{'biblionumber'},$search, "%$search%");
	my @answear;
	@answear = $sth2->fetchrow_array;
	$total = scalar @answear;
	if ($total >= 1)
	{
	    $first_step->{'serial'} = $answear[0];
	    push @finalsolution ,$first_step;
	}
    }
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/receipt-search-result.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {serials => 1},
				debug => 1,
				});
    $template->param(subtable => \@finalsolution, total => $total
		,);

	my $displaynext=0;
	my $displayprev=$startfrom;
	if(($total - (($startfrom+1)*($resultsperpage))) > 0 ){
		$displaynext = 1;
	}

	my @field_data = ();


	for(my $i = 0 ; $i <= $#marclist ; $i++)
	{
		push @field_data, { term => "marclist", val=>$marclist[$i] };
		push @field_data, { term => "and_or", val=>$and_or[$i] };
		push @field_data, { term => "excluding", val=>$excluding[$i] };
		push @field_data, { term => "operator", val=>$operator[$i] };
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
    $results = \@finalsolution;
	$template->param(result => $results) if $results;
	$template->param(
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
							intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
		intranetstylesheet => C4::Context->preference("intranetstylesheet"),
		IntranetNav => C4::Context->preference("IntranetNav"),
							);
output_html_with_http_headers $query, $cookie, $template->output;

}
else{
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/receipt.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {serials => 1},
				debug => 1,
				});
output_html_with_http_headers $query, $cookie, $template->output;
}
