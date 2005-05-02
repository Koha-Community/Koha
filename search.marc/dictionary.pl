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
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Auth;
use CGI;
use C4::Search;
use C4::SearchMarc;
use C4::AuthoritiesMarc;
use C4::Context;
use C4::Biblio;
use HTML::Template;

my $input = new CGI;
my $field =$input->param('marclist');
#warn "field :$field";
my ($tablename, $kohafield)=split /./,$field;
#my $tablename=$input->param('tablename');
$tablename="biblio" unless ($tablename);
#my $kohafield = $input->param('kohafield');
my @search = $input->param('search');
#warn " ".$search[0];
my $op=$input->param('op');
if (($search[0]) and not ($op eq 'do_search')){
	$op='do_search';
}
my $script_name = 'search.marc/dictionary.pl';
my $query;
my $type=$input->param('type');
#warn " ".$type;

my $dbh = C4::Context->dbh;
my ($template, $loggedinuser, $cookie);

my $env;

my $startfrom=$input->param('startfrom');
$startfrom=0 if(!defined $startfrom);
my $searchdesc;
my $resultsperpage;

#warn "Starting process";

if ($op eq "do_search") {
	($template, $loggedinuser, $cookie)
			= get_template_and_user({template_name => "search.marc/dictionary.tmpl",
					query => $input,
					type => $type,
					authnotrequired => 0,
					flagsrequired => {catalogue => 1},
					debug => 1,
					});
	my $sth=$dbh->prepare("Select distinct tagfield,tagsubfield from marc_subfield_structure where kohafield = ?");
	$sth->execute("$field");
	my (@tags, @and_or, @operator, @excluding,@value);
	
 	while ((my $tagfield,my $tagsubfield,my $liblibrarian) = $sth->fetchrow) {
 		push @tags, $dbh->quote("$tagfield$tagsubfield");
 		push @and_or, "";
 		push @operator, "contains";
 		push @excluding, "";
 		push @value, @search ;
 	}

	$resultsperpage= $input->param('resultsperpage');
	$resultsperpage = 19 if(!defined $resultsperpage);
	my $orderby = $input->param('orderby');

	findseealso($dbh,\@tags);
#	select distinct m1.bibid from biblio,biblioitems,marc_biblio,marc_word as m1 where biblio.biblionumber=marc_biblio.biblionumber and biblio.biblionumber=biblioitems.biblionumber and m1.bibid=marc_biblio.bibid and (m1.word  like 'Paul' and m1.tagsubfield in ('200f','710a','711a','712a','701a','702a','700a')) order by biblio.title


	my ($results,$total) = catalogsearch($dbh,\@tags ,\@and_or,
										\@excluding, \@operator,  \@value,
										$startfrom*$resultsperpage, $resultsperpage,$orderby);
	my %seen = ();

	foreach my $item (@$results) {
		my $display;
		$display="author" if ($field=~/author/);
		$display="title" if ($field=~/title/);
		$display="subject" if ($field=~/subject/);
		$display="publishercode" if ($field=~/publisher/);
	    $seen{$item->{$display}}++;
	}
	my @catresults;
	foreach my $name (sort keys %seen){
		push @catresults, { value => $name , count => $seen{$name}}
	}

	my $strsth="Select distinct authtypecode from marc_subfield_structure where ";
	my $strtagfields="tagfield in (";
	my $strtagsubfields=" and tagsubfield in (";
	foreach my $listtags (@tags){
		my @taglist=split /,/,$listtags;
		foreach my $curtag (@taglist){
			$strtagfields=$strtagfields."'".substr($curtag,1,3)."',";
			$strtagsubfields=$strtagsubfields."'".substr($curtag,4,1)."',";
		}
	}
	$strtagfields=~s/,$/)/;
	$strtagsubfields=~s/,$/)/;
	my $strsth = $strsth.$strtagfields.$strtagsubfields." and authtypecode is not NULL";
	warn $strsth;
	my $sth=$dbh->prepare($strsth);
	$sth->execute;
	
	my @authresults;
	my $authnbresults;
	while ((my $authtypecode) = $sth->fetchrow) {
		my ($curauthresults,$nbresults) = authoritysearch($dbh,[''],[''],[''],['contains'],
														\@search,$startfrom*$resultsperpage, $resultsperpage,$authtypecode);
		push @authresults, @$curauthresults;
		$authnbresults+=$nbresults;
#		warn "auth : $authtypecode nbauthresults : $nbresults";
	}
 	
	($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "search.marc/dictionary.tmpl",
				query => $input,
				type => $type,
				authnotrequired => 0,
				flagsrequired => {borrowers => 1},
				flagsrequired => {catalogue => 1},
				debug => 1,
				});

	# multi page display gestion
	my $displaynext=0;
	my $displayprev=$startfrom;
	if(($total - (($startfrom+1)*($resultsperpage))) > 0 ) {
		$displaynext = 1;
	}

	my @field_data = ();

	for(my $i = 0 ; $i <= $#tags ; $i++) {
		push @field_data, { term => "marclist", val=>$tags[$i] };
		push @field_data, { term => "and_or", val=>$and_or[$i] };
		push @field_data, { term => "excluding", val=>$excluding[$i] };
		push @field_data, { term => "operator", val=>$operator[$i] };
		push @field_data, { term => "value", val=>$value[$i] };
	}

	my @numbers = ();

	if ($total>$resultsperpage) {
		for (my $i=1; $i<$total/$resultsperpage+1; $i++) {
			if ($i<16) {
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
					 catresult=> \@catresults,
						search => $search[0],
						marclist =>$field,
						authresult => \@authresults,
						nbresults => $authnbresults,
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
						MARC_ON => C4::Context->preference("marc"),
						);

 } else {
 	($template, $loggedinuser, $cookie)
 		= get_template_and_user({template_name => "search.marc/dictionary.tmpl",
 				query => $input,
 				type => $type,
				authnotrequired => 0,
 				flagsrequired => {catalogue => 1},
 				debug => 1,
 				search => $search[0],
 				marclist =>$field,
 				});
#warn "type : $type";
 
 }
$template->param(search => $search[0],
					marclist =>$field,
					type=>$type);

# Print the page
output_html_with_http_headers $input, $cookie, $template->output;

# Local Variables:
# tab-width: 4
# End:
