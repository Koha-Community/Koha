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
require Exporter;
use CGI;
use C4::Auth;
use HTML::Template;
use C4::Context;
use C4::Search;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Biblio;
use C4::SearchMarc;
use C4::Koha; # XXX subfield_is_koha_internal_p

# Creates the list of active tags using the active MARC configuration
sub create_marclist {
	my $dbh = C4::Context->dbh;
	my $tagslib = &MARCgettagslib($dbh,1);
	my @marcarray;
	push @marcarray,"";
	my $widest_menu_item_width = 0;
	for (my $pass = 1; $pass <= 2; $pass += 1)
	{
		for (my $tabloop = 0; $tabloop<=9;$tabloop++)
		{
			my $separator_inserted_p = 0; # FIXME... should not use!!
			foreach my $tag (sort(keys (%{$tagslib})))
			{
				foreach my $subfield (sort(keys %{$tagslib->{$tag}}))
				{
					next if subfield_is_koha_internal_p($subfield);
					next unless ($tagslib->{$tag}->{$subfield}->{tab} eq $tabloop);
					my $menu_item = "$tag$subfield - $tagslib->{$tag}->{$subfield}->{lib}";
					if ($pass == 1)
					{
						$widest_menu_item_width = length $menu_item if($widest_menu_item_width < length $menu_item);
					} else {
						if (!$separator_inserted_p)
						{
							my $w = int(($widest_menu_item_width - 3 + 0.5)/2);
							my $s = ('-' x ($w * 4/5));
							push @marcarray,  "$s $tabloop $s";
							$separator_inserted_p = 1;
						}
					push @marcarray, $menu_item;
					}
				}
			}
		}
	}
	return \@marcarray;
}

# Creates a scrolling list with the associated default value.
# Using more than one scrolling list in a CGI assigns the same default value to all the
# scrolling lists on the page !?!? That's why this function was written.
sub create_scrolling_list {
	my ($params) = @_;
	my $scrollist = sprintf("<select name=\"%s\" size=\"%d\" onChange='%s'>\n", $params->{'name'}, $params->{'size'}, $params->{'onChange'});

	foreach my $tag (@{$params->{'values'}})
	{
		my $selected = "selected " if($params->{'default'} eq $tag);
		$scrollist .= sprintf("<option %svalue=\"%s\">%s</option>\n", $selected, $tag, $tag);
	}

	$scrollist .= "</select>\n";

	return $scrollist;
}

my $query=new CGI;
my $type=$query->param('type');
my $op = $query->param('op');
my $dbh = C4::Context->dbh;

my $startfrom=$query->param('startfrom');
$startfrom=0 if(!defined $startfrom);
my ($template, $loggedinuser, $cookie);
my $resultsperpage;

if ($op eq "do_search") {
	my @marclist = $query->param('marclist');
	my @and_or = $query->param('and_or');
	my @excluding = $query->param('excluding');
	my @operator = $query->param('operator');
	my @value = $query->param('value');

	$resultsperpage= $query->param('resultsperpage');
	$resultsperpage = 19 if(!defined $resultsperpage);
	my $orderby = $query->param('orderby');

	# builds tag and subfield arrays
	my @tags;

	foreach my $marc (@marclist) {
		my ($tag,$subfield) = MARCfind_marc_from_kohafield($dbh,$marc);
		if ($tag) {
			push @tags,$dbh->quote("$tag$subfield");
		} else {
			push @tags, $dbh->quote(substr($marc,0,4));
		}
	}
	findseealso($dbh,\@tags);
	my ($results,$total) = catalogsearch($dbh, \@tags,\@and_or,
										\@excluding, \@operator, \@value,
										$startfrom*$resultsperpage, $resultsperpage,$orderby);

	($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "search.marc/result.tmpl",
				query => $query,
				type => $type,
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

	$template->param(result => $results,
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
							numbers=>\@numbers
							);

} elsif ($op eq "AddStatement") {

	($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "search.marc/search.tmpl",
				query => $query,
				type => $type,
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});

	# Gets the entered information
	my @marcfields = $query->param('marclist');
	my @and_or = $query->param('and_or');
	my @excluding = $query->param('excluding');
	my @operator = $query->param('operator');
	my @value = $query->param('value');

	my @statements = ();

	# List of the marc tags to display
	my $marcarray = create_marclist();

	my $nbstatements = $query->param('nbstatements');
	$nbstatements = 1 if(!defined $nbstatements);

	for(my $i = 0 ; $i < $nbstatements ; $i++)
	{
		my %fields = ();

		# Recreates the old scrolling lists with the previously selected values
		my $marclist = create_scrolling_list({name=>"marclist",
					values=> $marcarray,
					size=> 1,
					default=>$marcfields[$i],
					onChange => "sql_update()"}
					);

		$fields{'marclist'} = $marclist;
		$fields{'first'} = 1 if($i == 0);

		# Restores the and/or parameters (no need to test the 'and' for activation because it's the default value)
		$fields{'or'} = 1 if($and_or[$i] eq "or");

		#Restores the "not" parameters
		$fields{'not'} = 1 if($excluding[$i]);

		#Restores the operators (most common operators first);
		if($operator[$i] eq "=") { $fields{'eq'} = 1; }
		elsif($operator[$i] eq "contains") { $fields{'contains'} = 1; }
		elsif($operator[$i] eq "start") { $fields{'start'} = 1; }
		elsif($operator[$i] eq ">") { $fields{'gt'} = 1; }	#greater than
		elsif($operator[$i] eq ">=") { $fields{'ge'} = 1; } #greater or equal
		elsif($operator[$i] eq "<") { $fields{'lt'} = 1; } #lower than
		elsif($operator[$i] eq "<=") { $fields{'le'} = 1; } #lower or equal

		#Restores the value
		$fields{'value'} = $value[$i];

		push @statements, \%fields;
	}
	$nbstatements++;

	# The new scrolling list
	my $marclist = create_scrolling_list({name=>"marclist",
				values=> $marcarray,
				size=>1,
				onChange => "sql_update()"});
	push @statements, {"marclist" => $marclist };

	$template->param("statements" => \@statements,
						"nbstatements" => $nbstatements);

}
else {
	($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "search.marc/search.tmpl",
				query => $query,
				type => $type,
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});
	#$template->param(loggedinuser => $loggedinuser);

	my $marcarray = create_marclist();

	my $marclist = CGI::scrolling_list(-name=>"marclist",
					-values=> $marcarray,
					-size=>1,
					-multiple=>0,
					-onChange => "sql_update()",
					);

	my @statements = ();

	# Considering initial search with 3 criterias
	push @statements, { "marclist" => $marclist, "first" => 1 };
	push @statements, { "marclist" => $marclist, "first" => 0 };
	push @statements, { "marclist" => $marclist, "first" => 0 };

	$template->param("statements" => \@statements, "nbstatements" => 3);
}


# Print the page
output_html_with_http_headers $query, $cookie, $template->output;

# Local Variables:
# tab-width: 4
# End:
