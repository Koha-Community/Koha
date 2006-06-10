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
use POSIX qw(ceil floor);
# load other modules
use HTML::Template;
use CGI;
use strict; 

my $query=new CGI;
my $op = $query->param('op'); #show the search form or execute the search
my $cql_query = $query->param('cql_query');
my @pqf_query_history = $query->param('pqf_query_history');
my @newresults;
my ($template,$borrowernumber,$cookie);
my @forminputs;		# this is for the links to navigate among the results when they are more than the maximum number of results per page
my $searchdesc;
my $search_type = $query->param('search_type');

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

	## OK, We're searching
	# STEP 1. We're a CGI script,so first thing to do is get the
	# query into PQF format so we can use the Koha API properly
	my ($error,$pqf_sort_by, $pqf_prox_ops, $pqf_bool_ops, $pqf_query) = cgi2pqf($query);
	warn "AFTER CGI: $pqf_sort_by $pqf_prox_ops $pqf_bool_ops $pqf_query";
	# implement a query history
	push @pqf_query_history, { field => 'pqf_query', value => $pqf_query};

	# lets store the query details in an array for later
	push @forminputs, { field => "cql_query" , value => $cql_query} ;
	push @forminputs, { field => 'pqf_sort_by', value => $pqf_sort_by} ;
	push @forminputs, { field => 'pqf_prox_ops', value => $pqf_prox_ops};
	push @forminputs, { field => 'pqf_bool_ops' , value => $pqf_bool_ops};
	push @forminputs, { field => 'pqf_query' , value => $pqf_query };
	$searchdesc=$cql_query.$pqf_prox_ops.$pqf_bool_ops.$pqf_query; # FIXME: this should be a more use-friendly string

	# STEP 2. OK, now we have PQF, so we can pass off the query to
	# the API
	my ($count, @results);

	# CQL queries are handled differently, so alert our API and pass in the variables
	if ($query->param('cql_query')) {
		($count,@results) = searchZOOM('cql',$cql_query,$number_of_results,$startfrom);
	} else {
		($count,@results) = searchZOOM('pqf',"$pqf_sort_by $pqf_prox_ops $pqf_bool_ops $pqf_query",$number_of_results,$startfrom);
	}
	@newresults=searchResults( $number_of_results,@results) ;
	my $num = scalar(@newresults);
	# sorting out which results to display.
	# the result number to start to show
	$template->param(starting => $startfrom+1);
	$template->param(ending => $startfrom+$number_of_results);
	# the result number to end to show
	($startfrom+$num<=$count) ? ($template->param(endat => $startfrom+$num)) : ($template->param(endat => $count));
	# the total results searched
	$template->param(total => $count);
	$template->param(FORMINPUTS => \@forminputs);
	$template->param(PQF_QUERY_HISTORY => \@pqf_query_history);
	$template->param(searchdesc => $searchdesc );
	$template->param(results_per_page =>  $number_of_results );
	$template->param(SEARCH_RESULTS => \@newresults);

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
		push @$numbers, { number => "&lt;&lt;", 
					      highlight => 0 , 
					      startfrom => 0, 
					      pg => '1' };
		push @$numbers, { number => "&lt;", 
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
				push @$numbers, { number => $i, 
								  highlight => 1 , 
								  startfrom => ($i-1)*$number_of_results , 
								  pg => $i };
			}
		} else {
			push @$numbers, { number => $i, 
							  highlight => 0 , 
							  startfrom => ($i-1)*$number_of_results , 
							  pg => $i };
		}
	}	        					
	if ($pg < $pages) {
		 $url = $pg + 1;
		push @$numbers, { number => "&gt;", 
						  highlight => 0 , 
						  startfrom => ($url-1)*$number_of_results, 
						  pg => $url };
		push @$numbers, { number => "&gt;&gt;", 
						  highlight => 0 , 
						  startfrom => ($total_pages-1)*$number_of_results, 
						  pg => $total_pages};
	}

	$template->param(	pqf_sort_by => $pqf_sort_by,
						pqf_query => "$pqf_prox_ops $pqf_bool_ops $pqf_query",
						numbers => $numbers);


    $template->param('Disable_Dictionary'=>C4::Context->preference("Disable_Dictionary")) if (C4::Context->preference("Disable_Dictionary"));
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
    );
## OK, we're not searching, load the search template
} else {

	($template, $borrowernumber, $cookie)
        = get_template_and_user({template_name => "opac-zoomsearch.tmpl",
                    query => $query,
                    type => "opac",
                    authnotrequired => 1,
                });

	# pass on the query history
	$template->param(PQF_QUERY_HISTORY => \@pqf_query_history);
	use C4::Koha;
	my $dbh = C4::Context->dbh;
##Itemtypes (Collection Codes)
	my $itemtypequery="Select itemtype,description from itemtypes order by description";
	my $sth=$dbh->prepare($itemtypequery);
	$sth->execute;
	my  @itemtypeloop;
	my %itemtypes;
	while (my ($value,$lib) = $sth->fetchrow_array) {
		my %row =(      
			value => $value,
			description => $lib,
			);
		push @itemtypeloop, \%row;
       
	}
	$sth->finish;

##Branches
	my @branches;
	my @select_branch;
	my %select_branches;
	my $branches = getallbranches();
	my @branchloop;
	#push @branchloop, (value => "", selected => 1,branchname =>"");
	foreach my $thisbranch (keys %$branches) {
        my $selected = 1 if (C4::Context->userenv && ($thisbranch eq C4::Context->userenv->{branch}));
        my %row =(	value => $thisbranch,
				selected => $selected,
				branchname => $branches->{$thisbranch}->{'branchname'},
                        );        
		push @branchloop, \%row;
	}

	# set the default tab, etc.
	my $search_type = $query->param('query_form');
	if ((!$search_type) || ($search_type eq 'cql'))  {
		$template->param(cql_search => 1);
	} elsif ($search_type eq 'advanced') {
		$template->param(advanced_search => 1);
	} elsif ($search_type eq 'power') {
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


###Move these subs to a proper Search.pm
sub searchZOOM {
	use C4::Biblio;
	my ($type,$query,$num,$startfrom) = @_;
	my $dbh = C4::Context->dbh;
	my $zconn=C4::Context->Zconn("biblioserver");

	#warn ($type,$query,$num,$startfrom) ;
	if ($zconn eq "error") {
		return("error with connection",undef); #FIXME: better error handling
	}
	
	my $zoom_query_obj;
	eval {
	if ($type eq 'cql') {
		$zoom_query_obj = new ZOOM::Query::CQL2RPN($query,$zconn);
	} else {
		$zoom_query_obj = new ZOOM::Query::PQF($query);
	}
	};
	if ($@) {
		return("error with search: $@",undef); #FIXME: better error handling
    }	

	# PERFORM THE SEARCH
	my $result;
	eval {
		$result = $zconn->search($zoom_query_obj);
	};

	if ($@) {
		return("error with search: $@",undef); #FIXME: better error handling
	}
	my $i;
	my $numresults = $result->size() if  ($result);
	my @results;
	for ( $i=$startfrom; $i<(($startfrom+$num<=$numresults) ? ($startfrom+$num):$numresults) ; $i++){
	
		my $rec = $result->record($i);
		push(@results,$rec->raw()) if $rec;
	}
	return($numresults,@results);
}

# build a valid PQF query from the CGI form
sub cgi2pqf {
	my ($query) = @_;
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
				} elsif ($spec_attr =~ /^prox/) { # process the proximity operators separately
					if ($query->param("$spec_attr$i")) {
						warn "PQF:".$query->param("$spec_attr$i");
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
		$pqf_query .=" ".$que;
	}
	foreach my $prox(@pqf_prox_ops_array) {
		$pqf_prox_ops.=" ".$prox;
	}
	# OK, done with that, now lets have a look
	warn "Boolean Operators: ".$pqf_bool_ops if $pqf_bool_ops;
	warn "Proximigy Operators: ".$pqf_prox_ops if $pqf_prox_ops;
	warn "Sort by: ".$pqf_sort_by;
	warn "PQF:".$pqf_query;	
	warn "Full PQF: $pqf_sort_by $pqf_prox_ops $pqf_bool_ops $pqf_query";
	return ('',$pqf_sort_by, $pqf_prox_ops, $pqf_bool_ops, $pqf_query);
}



sub searchResults {
	my ($num,@marcresults)=@_;	
	use C4::Date;

	my $dbh= C4::Context->dbh;
	my $toggle;
	my $even=1;
	my @newresults;

	#Build brancnames hash
	#find branchname
	#get branch information.....
	my %branches;
	my $bsth=$dbh->prepare("SELECT branchcode,branchname FROM branches");
	$bsth->execute();
	while (my $bdata=$bsth->fetchrow_hashref){
		$branches{$bdata->{'branchcode'}}= $bdata->{'branchname'};
	}

	#search item field code
	my $sth = $dbh->prepare(
		"select tagfield from marc_subfield_structure where kohafield like 'items.itemnumber'"
        );
	$sth->execute;
	my ($itemtag) = $sth->fetchrow;
	
	## find column names of items related to MARC
	my $sth2=$dbh->prepare("SHOW COLUMNS from items");
	$sth2->execute;
	my %subfieldstosearch;
	while ((my $column)=$sth2->fetchrow){
		my ($tagfield,$tagsubfield) = &MARCfind_marc_from_kohafield($dbh,"items.".$column,"");
		$subfieldstosearch{$column}=$tagsubfield;
	}
	
	for ( my $i=0; $i<$num ; $i++){
		my $marcrecord;					
		$marcrecord = MARC::File::USMARC::decode($marcresults[$i]);
		my $oldbiblio = MARCmarc2koha($dbh,$marcrecord,'');
		if ($i % 2) {
			$toggle="#ffffcc";
		} else {
			$toggle="white";
		}
		$oldbiblio->{'toggle'}=$toggle;
 		my @fields = $marcrecord->field($itemtag);
		my @items;
		my $item;
		my %counts;
		$counts{'total'}=0;

#	
##Loop for each item field
		foreach my $field (@fields) {
	   	foreach my $code ( keys %subfieldstosearch ) {

		$item->{$code}=$field->subfield($subfieldstosearch{$code});
		}

		my $status;
		$item->{'branchname'}=$branches{$item->{'holdingbranch'}};
		$item->{'date_due'}=$item->{onloan};
		$status="Lost" if ($item->{itemlost});
		$status="Withdrawn" if ($item->{wthdrawn});
		$status="Due:".format_date($item->{onloan}) if ($item->{onloan}>0 );
		# $status="On Loan" if ($item->{onloan} );
		if ($item->{'location'}){
			$status = $item->{'branchname'}."[".$item->{'location'}."]" unless defined $status;
		}else{
			$status = $item->{'branchname'} unless defined $status;
		}
		$counts{$status}++;
		$counts{'total'}++;
		push @items,$item;
	}
	my $norequests = 1;
	my $noitems    = 1;
	if (@items) {
		$noitems = 0;
		foreach my $itm (@items) {
			$norequests = 0 unless $itm->{'itemnotforloan'};
		}
	}
	$oldbiblio->{'noitems'} = $noitems;
	$oldbiblio->{'norequests'} = $norequests;
	$oldbiblio->{'even'} = $even = not $even;
	$oldbiblio->{'itemcount'} = $counts{'total'};
	my $totalitemcounts = 0;
	foreach my $key (keys %counts){
		if ($key ne 'total'){	
			$totalitemcounts+= $counts{$key};
			$oldbiblio->{'locationhash'}->{$key}=$counts{$key};
		}
	}
	my ($locationtext, $locationtextonly, $notavailabletext) = ('','','');
	foreach (sort keys %{$oldbiblio->{'locationhash'}}) {
		if ($_ eq 'notavailable') {
			$notavailabletext="Not available";
			my $c=$oldbiblio->{'locationhash'}->{$_};
			$oldbiblio->{'not-available-p'}=$c;
		} else {
			$locationtext.="$_";
			my $c=$oldbiblio->{'locationhash'}->{$_};
			if ($_ eq 'Item Lost') {
				$oldbiblio->{'lost-p'} = $c;
			} elsif ($_ eq 'Withdrawn') {
				$oldbiblio->{'withdrawn-p'} = $c;
			} elsif ($_ eq 'On Loan') {
				$oldbiblio->{'on-loan-p'} = $c;
			} else {
				$locationtextonly.= $_;
				$locationtextonly.= " ($c)<br> " if $totalitemcounts > 1;
			}
			if ($totalitemcounts>1) {
				$locationtext.=" ($c)<br> ";
			}
		}
	}
	if ($notavailabletext) {
		$locationtext.= $notavailabletext;
	} else {
		$locationtext=~s/, $//;
	}
	$oldbiblio->{'location'} = $locationtext;
	$oldbiblio->{'location-only'} = $locationtextonly;
	$oldbiblio->{'use-location-flags-p'} = 1;
	push (@newresults, $oldbiblio);

	}
	return @newresults;
}
