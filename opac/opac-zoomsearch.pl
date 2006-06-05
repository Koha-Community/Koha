#!/usr/bin/perl
use strict; use warnings;
# load our Koha modules
use C4::Context;
use C4::Interface::CGI::Output;
use C4::Auth;

# load other modules
use HTML::Template;
use CGI;
my $query=new CGI;
my $op = $query->param('op'); #show the search form or execute the search
my $query_form = $query->param('query_form'); # which query form was submitted
my ($template,$borrowernumber,$cookie);

## Check if we're searching
if ($op eq 'get_results') { # Yea, we're searching, load the results template
	($template, $borrowernumber, $cookie)
		= get_template_and_user({template_name => "opac-results.tmpl",
                                         query => $query,
                                         type => "opac",
                                         authnotrequired => 1,});

my $number_of_results = $query->param('results_per_page');
$number_of_results = 20 unless ($number_of_results); #this could be a parameter with 20 50 or 100 results per page
my $offset=$query->param('offset');
($offset) || ($offset=0);

## OK, We're searching
# STEP 1. We're a CGI script,so first thing to do is get the
# query into PQF format so we can use the Koha API properly
my $cql_query = $query->param('cql_query');
my ($error,$pqf_sort_by, $pqf_prox_ops, $pqf_bool_ops, $pqf_query) = cgi2pqf($query);
warn "AFTER CGI: $pqf_sort_by $pqf_prox_ops $pqf_bool_ops $pqf_query";

# STEP 2. OK, now we have PQF, so we can pass off the query to
# the API
my ($count, @results);
if ($query->param('cql_query')) {
	($count,@results) = searchZOOM('cql',$cql_query,$number_of_results,$offset);
} else {
	($count,@results) = searchZOOM('pqf',"$pqf_sort_by $pqf_prox_ops $pqf_bool_ops $pqf_query",$number_of_results,$offset);
}
if ($count =~ /^error/) {
	print $query->header();
	print $count;
	die;
}

print $query->header();
print "Success:".$count;

print "

Resort by:
<form action='/cgi-bin/koha/opac-zoomsearch.pl' method='get'>
        <input type='hidden' name='query_form' value='pqf'/>
        <input type='hidden' name='op' value='get_results'/>
		<select name='pqf_query'>
			<option value='' selected>Relevance</option>
			<option value='\@or \@or \@attr 7=1 \@attr 1=4 0 \@attr 7=2 \@attr 1=30 1 $pqf_prox_ops $pqf_bool_ops $pqf_query'>Title Ascending, Date Descending</option>
			<option value='\@or \@or \@attr 7=1 \@attr 1=1003 0 \@attr 7=2 \@attr 1=30 1 $pqf_prox_ops $pqf_bool_ops $pqf_query'>Author Ascending, Date Descending</option>
			<option value='\@or \@or \@attr 7=2 \@attr 1=32 0 \@attr 7=2 \@attr 1=30 1 $pqf_prox_ops $pqf_bool_ops $pqf_query'>Date of Acquisition, Relevance</option>
			<option value='\@or \@or \@attr 7=2 \@attr 1=30 0 \@attr 7=2 \@attr 1=4 1 $pqf_prox_ops $pqf_bool_ops $pqf_query'>Date of Publication, Relevance</option>
				
		</select>

        <input type='submit' value='resort'/>
</form>

";
my $c;
foreach my $res (@results) {
	$c++;
	my $marc = MARC::Record->new_from_usmarc($res);
	print "$c. ".$marc->title()."<br/><br/>";
}
} else {

($template, $borrowernumber, $cookie)
        = get_template_and_user({template_name => "opac-zoomsearch.tmpl",
                    query => $query,
                    type => "opac",
                    authnotrequired => 1,
                });

output_html_with_http_headers $query, $cookie, $template->output;
}

sub searchZOOM {
	use C4::Biblio;
	my ($type,$query,$num,$offset) = @_;
	my $dbh = C4::Context->dbh;
	my $zconn=C4::Context->Zconn("biblioserver");

	if ($zconn eq "error") {
		return("error with connection",undef); #FIXME: better error handling
	}
	my $limit = $num + $offset;
	my $startfrom = $offset;

	my $zoom_query_obj;

	eval {
	if ($type eq 'cql') {
		$zoom_query_obj = new ZOOM::Query::CQL2RPN($query,$zconn);
	} else {
		$zoom_query_obj = new ZOOM::Query::PQF($query);
	}
	};
	if ($@) {
		return("error with search",undef); #FIXME: better error handling
    }	
	# PERFORM THE SEARCH
	my $result;
	eval {
		$result = $zconn->search($zoom_query_obj);
	};

	if ($@) {
		return("error with search",undef); #FIXME: better error handling
	}
	my $numresults = $result->size() if  ($result);
	my @results;
	for (my $i=$startfrom; $i<=$limit;$i++) {
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
	my ($cql_query,$pqf_query,$pqf_sort_by,$original_pqf_query,$original_sort_by) = ($query->param('cql_query'),$query->param('pqf_query'),$query->param('pqf_sort_by'),$query->param('original_pqf_query'),$query->param('original_sort_by'));

	# operators:
	my $pqf_ops; my $pqf_prox_ops; my $pqf_bool_ops;

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

    my $zoom_query;

	# load the default attributes, set once per query
	foreach my $def_attr (@default_attributes) {
		$pqf_sort_by .= " ".$query->param($def_attr);
	}
	# these are attributes specific to this query_form, set many times per query
	# First, process the 'operators' and put them in a separate variable
	# proximity and boolean
	foreach my $spec_attr (@specific_attributes) {
		for (my $i=1;$i<5;$i++) {
			if ($query->param("query$i")) { # make sure this set should be used
				if ($spec_attr =~ /^op/) { # process the operators separately
					$pqf_bool_ops .= " ".$query->param("$spec_attr$i");
				} elsif ($spec_attr =~ /^prox/) { # process the proximity operators separately
					if ($query->param("$spec_attr$i")) {
						warn "PQF:".$query->param("$spec_attr$i");
						$pqf_prox_ops .= " ".$query->param("$spec_attr$i");
					} else {
						if (($spec_attr =~ /^prox_exclusion/) || ($spec_attr =~ /^prox_ordered/)) { # this is an exception, sloppy way to handle it
							if ($i==2) {
								$pqf_prox_ops .=" 0";
							}
						}
					}
				}
			}
		}
	}
	# by now, we have two variables: $pqf_bool_ops (boolean) and $pqf_prox_ops (proximity), join them
	$pqf_ops.= $pqf_prox_ops if $pqf_prox_ops;
	$pqf_ops = $pqf_bool_ops." ".$pqf_ops if $pqf_bool_ops;

	# Now, process the attributes
	for (my $i=1;$i<5;$i++) {
		foreach my $spec_attr (@specific_attributes) {
			if ($query->param("query$i")) {
				if ($spec_attr =~ /^query/) {
					if ($query->param("$spec_attr$i") =~ /@/) { # don't wrap in quotes if the query is PQF
						$pqf_query .= " ".$query->param("$spec_attr$i");
					} else {
						$pqf_query .= " \"".$query->param("$spec_attr$i")."\"";
					}
				} elsif ($spec_attr =~ /^op/) { # don't process the operators again
				} elsif ($spec_attr =~ /^prox/) { 
				} else {
					$pqf_query .= " ".$query->param("$spec_attr$i");
				}
			}
		}
	}
	warn "Boolean Operators: ".$pqf_bool_ops if $pqf_bool_ops;
	warn "Proximigy Operators: ".$pqf_prox_ops if $pqf_prox_ops;
	warn "Sort by: ".$pqf_sort_by;
	warn "PQF:".$pqf_query;	
	warn "Full PQF: $pqf_sort_by $pqf_prox_ops $pqf_bool_ops $pqf_query";
	return ('',$pqf_sort_by, $pqf_prox_ops, $pqf_bool_ops, $pqf_query);
}
