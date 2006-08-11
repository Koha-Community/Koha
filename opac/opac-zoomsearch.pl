#!/usr/bin/perl

# Copyright 2006 Liblime
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

# load our Koha modules
use C4::Context;
use C4::Interface::CGI::Output;
use C4::Auth;
use C4::Search;
use C4::Biblio;
use C4::Koha;
use POSIX qw(ceil floor);

# load other modules
use HTML::Template;
use CGI;
use strict; 

my $query=new CGI;
my $op = $query->param('op'); # show the search form or execute the search

# expanded facet?
my $expanded_facet = $query->param('expand');

### Gather up all our search queries
## CQL
my $cql_query = $query->param('cql_query');

## CCL
my @previous_ccl_queries; # array of hashes
my @previous_ccl_queries_array = $query->param('previous_ccl_queries');

my @ccl_query = $query->param('ccl_query');
my $ccl_query;
foreach my $ccl (@ccl_query) {
	$ccl_query.="$ccl " if $ccl;
}
push @previous_ccl_queries_array, $ccl_query;
# put the queries in a form the template can use
my $previous_ccl_queries_hash;
foreach my $ccl (@previous_ccl_queries_array) {
	if ($ccl) {
	my %row =(
		value => $ccl
		);
	push @previous_ccl_queries, %row;
	}
}
## PQF
my $pqf_query = $query->param('pqf_query');

my @newresults;
my ($template,$borrowernumber,$cookie);
my @forminputs;		# this is for the links to navigate among the results when they are more than the maximum number of results per page
my $searchdesc; 
my $search_type = $query->param('search_type');

my $dbh = C4::Context->dbh;
## Get Itemtypes (Collection Codes)
my $itemtypequery="Select itemtype,description from itemtypes order by description";    
my $sth=$dbh->prepare($itemtypequery);
$sth->execute;
my @itemtypeloop;
my %itemtypes;
while (my ($value,$lib) = $sth->fetchrow_array) {
        my %row =(
            value => $value,
            description => $lib,
            );
        push @itemtypeloop, \%row;

}
$sth->finish;

## Get Branches
my @branches;
my @select_branch;
my %select_branches;
my $branches = getallbranches();
my @branchloop;
foreach my $thisbranch (keys %$branches) {
		my $selected = 1 if (C4::Context->userenv && ($thisbranch eq C4::Context->userenv->{branch}));            
		my %row =(
            	value => $thisbranch,
            	selected => $selected,
            	branchname => $branches->{$thisbranch}->{'branchname'},
        	);
        push @branchloop, \%row;
}

## Check if we're searching
if ($op eq 'get_results') { # Yea, we're searching, load the results template
	($template, $borrowernumber, $cookie)
		= get_template_and_user({template_name => "opac-results.tmpl",
                                         query => $query,
                                         type => "opac",
                                         authnotrequired => 1,});

	my $number_of_results = $query->param('results_per_page');
	$number_of_results = 20 unless ($number_of_results); #this could be a parameter with 20 50 or 100 results per page
	my $startfrom = $query->param('startfrom');
	($startfrom) || ($startfrom=0);

	## OK, WE'RE SEARCHING
	# STEP 1. We're a CGI script,so first thing to do is get the
	# query into PQF format so we can use the Koha API properly
	my ($error,$pqf_sort_by, $pqf_prox_ops, $pqf_bool_ops, $nice_query);
	($error,$pqf_sort_by, $pqf_prox_ops, $pqf_bool_ops, $pqf_query, $nice_query)= cgi2pqf($query);
	my $then_sort_by = $query->param('then_sort_by');
	# implement a query history

	# lets store the query details in an array for later
	push @forminputs, { field => "cql_query" , value => $cql_query} ;
	push @forminputs, { field => "ccl_query" , value => $ccl_query} ;
	push @forminputs, { field => 'pqf_sort_by', value => $pqf_sort_by} ;
	push @forminputs, { field => 'pqf_prox_ops', value => $pqf_prox_ops};
	push @forminputs, { field => 'pqf_bool_ops' , value => $pqf_bool_ops};
	push @forminputs, { field => 'pqf_query' , value => $pqf_query };
	$searchdesc=$cql_query.$ccl_query.$nice_query; # FIXME: this should be a more use-friendly string

	# STEP 2. OK, now we have PQF, so we can pass off the query to
	# the API
	my ($count,@results,$facets);

	# queries are handled differently, so alert our API and pass in the variables
	if ($ccl_query) { # CCL
        	if ($query->param('scan')) {
            		($error,$count, $facets,@results) = searchZOOM('scan','ccl',$ccl_query,$number_of_results,$startfrom,$then_sort_by,$expanded_facet);
            		$template->param(scan => 1);
        	} else {
            		($error,$count,$facets,@results) = searchZOOM('search','ccl',$ccl_query,$number_of_results,$startfrom,$then_sort_by,$expanded_facet);
        	}
	} elsif ($query->param('cql_query')) { # CQL
		if ($query->param('scan')) {
			($error,$count,$facets,@results) = searchZOOM('scan','cql',$cql_query,$number_of_results,$startfrom,$then_sort_by,$expanded_facet);
			$template->param(scan => 1);
		} else {
			($error,$count,$facets,@results) = searchZOOM('search','cql',$cql_query,$number_of_results,$startfrom,$then_sort_by,$expanded_facet);
		}
	} else { # we're in PQF territory now
		if ($query->param('scan')) {
			$template->param(scan => 1);
			($error,$count,$facets,@results) = searchZOOM('scan','pqf',"$pqf_sort_by $pqf_prox_ops $pqf_bool_ops $pqf_query",$number_of_results,$startfrom,$then_sort_by,$expanded_facet);
		} else {
			($error,$count,$facets,@results) = searchZOOM('search','pqf',"$pqf_sort_by $pqf_prox_ops $pqf_bool_ops $pqf_query",$number_of_results,$startfrom,$then_sort_by,$expanded_facet);
		}
	}
	@newresults=searchResults( $searchdesc,$number_of_results,$count,@results) ;

	# How many did we get back?
	my $num = scalar(@newresults);

	# sorting out which results to display.
	# the result number to start to show
	$template->param(starting => $startfrom+1);
	$template->param(ending => $startfrom+$number_of_results);
	# the result number to end to show
	($startfrom+$num<=$count) ? ($template->param(endat => $startfrom+$num)) : ($template->param(endat => $count));
	# the total results found
	$template->param(total => $count);
	$template->param(FORMINPUTS => \@forminputs);
	#$template->param(pqf_query => $pqf_query);
	$template->param(ccl_query => $ccl_query);
	$template->param(searchdesc => $searchdesc );
	$template->param(results_per_page =>  $number_of_results );
	$template->param(SEARCH_RESULTS => \@newresults);
	$template->param(PREVIOUS_CCL_QUERIES => \@previous_ccl_queries);
	$template->param(facets_loop => $facets);

	#this is to show the page numbers to navigate among the results, whether it has to show the number highlighted or not
	my $numbers;
	@$numbers = ();
	my $pg = 1;
	if (defined($query->param('pg'))) {
		$pg = $query->param('pg');
	}
	my $start = 0;
	
	$start = ($pg - 1) * $number_of_results;
	my $pages = ceil($count / $number_of_results);
	my $total_pages = ceil($count / $number_of_results);
	my $url;
	if ($pg > 1) {
		$url = $pg - 1;
		push @$numbers, { 		
				number => "&lt;&lt;", 
				highlight => 0 , 
				startfrom => 0, 
				pg => '1' };

		push @$numbers, { 		
				number => "&lt;", 
				highlight => 0 , 
				startfrom => ($url-1)*$number_of_results, 
				pg => $url };
	}
	my $current_ten = $pg / 10;
	if ($current_ten == 0) {
		 $current_ten = 0.1;           # In case it's in ten = 0
	} 
	my $from = $current_ten * 10; # Calculate the initial page
	my $end_ten = $from + 9;
	my $to;
	if ($pages > $end_ten) {
		$to = $end_ten;
	} else {
		$to = $pages;
	}
	for (my $i =$from; $i <= $to ; $i++) {
		if ($i == $pg) {   
			if ($count > $number_of_results) {
				push @$numbers, { 
						number => $i, 
						highlight => 1 , 
						startfrom => ($i-1)*$number_of_results , 
						pg => $i };
			}
		} else {
			push @$numbers, { 	
						number => $i, 
						highlight => 0 , 
						startfrom => ($i-1)*$number_of_results , 
						pg => $i };
		}
	}	        					
	if ($pg < $pages) {
		 $url = $pg + 1;
		push @$numbers, {		
						number => "&gt;", 
						highlight => 0 , 
						startfrom => ($url-1)*$number_of_results, 
						pg => $url };

		push @$numbers, { 		
						number => "&gt;&gt;", 
						highlight => 0 , 
						startfrom => ($total_pages-1)*$number_of_results, 
						pg => $total_pages};
	}

	$template->param(			
						pqf_sort_by => $pqf_sort_by,
						pqf_query => "$pqf_prox_ops $pqf_bool_ops $pqf_query",
						numbers => $numbers);


    $template->param('Disable_Dictionary'=>C4::Context->preference("Disable_Dictionary")) if (C4::Context->preference("Disable_Dictionary"));
    my $scan_use = $query->param('use1');
    $template->param(
			#classlist => $classlist,
			suggestion => C4::Context->preference("suggestion"),
			virtualshelves => C4::Context->preference("virtualshelves"),
			LibraryName => C4::Context->preference("LibraryName"),
			OpacNav => C4::Context->preference("OpacNav"),
			opaccredits => C4::Context->preference("opaccredits"),
			AmazonContent => C4::Context->preference("AmazonContent"),
			opacsmallimage => C4::Context->preference("opacsmallimage"),
			opaclayoutstylesheet => C4::Context->preference("opaclayoutstylesheet"),
			opaccolorstylesheet => C4::Context->preference("opaccolorstylesheet"),
			scan_use => $scan_use,
			search_error => $error,
    );

	## Now let's find out if we have any supplemental data to show the user
	#  and in the meantime, save the current query for statistical purposes, etc.
	my $koha_spsuggest; # a flag to tell if we've got suggestions coming from Koha
	my @koha_spsuggest; # place we store the suggestions to be returned to the template as LOOP
	my $phrases = $searchdesc;
	my $ipaddress;
	
	if ( C4::Context->preference("kohaspsuggest") ) {
		eval {
			my $koha_spsuggest_dbh;
			eval {
				$koha_spsuggest_dbh=DBI->connect("DBI:mysql:suggest:66.213.78.76","auth","Free2cirC");
			};
			if ($@) { warn "can't connect to spsuggest db";
			}
			else {
				my $koha_spsuggest_insert = "INSERT INTO phrase_log(phr_phrase,phr_resultcount,phr_ip) VALUES(?,?,?)";
				my $koha_spsuggest_query = "SELECT display FROM distincts WHERE strcmp(soundex(suggestion), soundex(?)) = 0 order by soundex(suggestion) limit 0,5";
				my $koha_spsuggest_sth = $koha_spsuggest_dbh->prepare($koha_spsuggest_query);
				$koha_spsuggest_sth->execute($phrases);
				while (my $spsuggestion = $koha_spsuggest_sth->fetchrow_array) {
					$spsuggestion =~ s/(:|\/)//g;
					my %line;
					$line{spsuggestion} = $spsuggestion;
					push @koha_spsuggest,\%line;
					$koha_spsuggest = 1;
				}

				# Now save the current query
				$koha_spsuggest_sth=$koha_spsuggest_dbh->prepare($koha_spsuggest_insert);
				#$koha_spsuggest_sth->execute($phrases,$count,$ipaddress);
				$koha_spsuggest_sth->finish;

				$template->param( koha_spsuggest => $koha_spsuggest ) unless $num;
				$template->param( SPELL_SUGGEST => \@koha_spsuggest,
					        branchloop=>\@branchloop,
							itemtypeloop=>\@itemtypeloop,
				);
			}
		};
		if ($@) {
			warn "Kohaspsuggest failure:".$@;
		}
	}
	
	## Spellchecking using Google API
	## Did you mean? Suggestions using spsuggest table
	#	
	# Related Searches
	#
## OK, we're not searching, load the search template
} else {

	($template, $borrowernumber, $cookie)
        = get_template_and_user({template_name => "opac-zoomsearch.tmpl",
                    query => $query,
                    type => "opac",
                    authnotrequired => 1,
                });

	# set the default tab, etc.
	my $search_type = $query->param('query_form');
	if ((!$search_type) || ($search_type eq 'advanced'))  {
		$template->param(advanced_search => 1);
	} elsif ($search_type eq 'format') {
		$template->param(format_search => 1);
	} elsif ($search_type eq 'power') {
		$template->param(power_search => 1);
	} elsif ($search_type eq 'cql') {
		$template->param(power_search => 1);
	} elsif ($search_type eq 'pqf') {
		$template->param(power_search => 1);
	} elsif ($search_type eq 'proximity') {
		$template->param(proximity_search => 1);
	}

	$template->param(
		branchloop=>\@branchloop,
		itemtypeloop=>\@itemtypeloop,
	);

}
output_html_with_http_headers $query, $cookie, $template->output;

=head2 cgi2pdf
=cut
# build a valid PQF query from a CGI form
sub cgi2pqf {
	my ($query) = @_;
	my $nice_query; # just a string storing a nicely formatted query
	my @default_attributes = ('sort_by');
	# attributes specific to the advanced search - a search_point is actually a combination of
	#  several bib1 attributes
	my @advanced_attributes = ('search_point','op','query');
	# attributes specific to the power search
	my @power_attributes = ( 'use','relation','structure','truncation','completeness','op','query');
	# attributes specific to the proximity search
	my @proximity_attributes = ('prox_op','prox_exclusion','prox_distance','prox_ordered','prox_relation','prox_which-code','prox_unit-code','query');

	my @specific_attributes; # these will be looped as many times as needed

	my $query_form = $query->param('query_form');

	# bunch of places to store the various queries we're working with
	my $cql_query = $query->param('cql_query');

	my $pqf_query = $query->param('pqf_query');

	my @pqf_query_array;
	my @counting_pqf_query_array;
	
	my $pqf_prox_ops = $query->param('pqf_prox_ops');
	my @pqf_prox_ops_array;
	
	my $pqf_bool_ops = $query->param('pqf_bool_ops');
	my @pqf_bool_ops_array;

	my $pqf_sort_by = $query->param('pqf_sort_by');

	# operators:

	# ADVANCED SEARCH
	if (($query_form) eq 'advanced') {
		@specific_attributes = @advanced_attributes;
	# POWER SEARCH
	} elsif (($query_form) eq 'power') {
		@specific_attributes = @power_attributes;
	# PROXIMITY SEARCH
	} elsif (($query_form) eq 'proximity') {
		@specific_attributes = @proximity_attributes;
	}
	

	# load the default attributes, set once per query
	foreach my $def_attr (@default_attributes) {
		$pqf_sort_by .= " ".$query->param($def_attr);
	}
	# these are attributes specific to this query_form, set many times per query
	# First, process the 'operators' and put them in an array
	# proximity and boolean
	foreach my $spec_attr (@specific_attributes) {
		for (my $i=1;$i<15;$i++) {
			if ($query->param("query$i")) { # make sure this set should be used
				if ($spec_attr =~ /^op/) { # process the operators separately
					push @pqf_bool_ops_array, $query->param("$spec_attr$i");
					$nice_query .=" ".$query->param("$spec_attr$i")." ".$query->param("query$i");
					$nice_query =~ s/\@and/AND/g;
					$nice_query =~ s/\@or/OR/g;
				} elsif ($spec_attr =~ /^prox/) { # process the proximity operators separately
					if ($query->param("$spec_attr$i")) {
						#warn "PQF:".$query->param("$spec_attr$i");
						push @pqf_prox_ops_array,$query->param("$spec_attr$i");
					} else {
						if (($spec_attr =~ /^prox_exclusion/) || ($spec_attr =~ /^prox_ordered/)) { # this is an exception, sloppy way to handle it
							if ($i==2) {
								push @pqf_prox_ops_array,0;
							}
						}
					}
				}
			}
		}
	}
	# by now, we have two operator arrays: @pqf_bool_ops_array (boolean) and @pqf_prox_ops_array (proximity)

	# Next, we process the attributes (operands)
	for (my $i=1;$i<15;$i++) {
		foreach my $spec_attr (@specific_attributes) {
			if ($query->param("query$i")) {
				if ($spec_attr =~ /^query/) {
					push @counting_pqf_query_array,$query->param("$spec_attr$i") if $query->param("$spec_attr$i");
					push @pqf_query_array,$query->param("$spec_attr$i") if $query->param("$spec_attr$i")
				} elsif ($spec_attr =~ /^op/) { # don't process the operators again
				} elsif ($spec_attr =~ /^prox/) { 
				} else {
					push @pqf_query_array,$query->param("$spec_attr$i") if $query->param("$spec_attr$i");
				}
			}
		}
	}

	# we have to make sure that there # of operators == # of operands-1
	# because second, third, etc queries, come in with an operator attached
	# ...but if there is no previous queries, it should be dropped ... 
	# that's what we're doing here
	my $count_pqf_query = @counting_pqf_query_array;
	my $count_pqf_bool_ops = @pqf_bool_ops_array;

	if ($count_pqf_bool_ops == $count_pqf_query-1) {
		for (my $i=$count_pqf_query;$i>=0;$i--) {
			$pqf_bool_ops.=" ".$pqf_bool_ops_array[$i];
		}
	} else {
		for (my $i=$count_pqf_query;$i>=1;$i--) {
			$pqf_bool_ops.=" ".$pqf_bool_ops_array[$i];
		}
	}
	foreach my $que(@pqf_query_array) {
		if ($que =~ /@/) {
			$pqf_query .=" ".$que;
		} else {
			$que =~ s/(\"|\'|\.)//g;
			$pqf_query .=" \"".$que."\"";
		}
	}
	foreach my $prox(@pqf_prox_ops_array) {
		$pqf_prox_ops.=" ".$prox;
	}

	# finally, nice_query needs to be populated if it hasn't been
	$nice_query = $pqf_query unless $nice_query;
	# and cleaned up FIXME: bad bad ... 
	$nice_query =~ s/\@attr//g;
	$nice_query =~ s/\d+=\d+//g;
	# OK, done with that, now lets have a look
	#warn "Boolean Operators: ".$pqf_bool_ops if $pqf_bool_ops;
	#warn "Proximigy Operators: ".$pqf_prox_ops if $pqf_prox_ops;
	#warn "Sort by: ".$pqf_sort_by;
	#warn "PQF:".$pqf_query;	
	#warn "Full PQF: $pqf_sort_by $pqf_prox_ops $pqf_bool_ops $pqf_query";
	#warn "NICE: $nice_query";
	return ('',$pqf_sort_by, $pqf_prox_ops, $pqf_bool_ops, $pqf_query, $nice_query);
}
