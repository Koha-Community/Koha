#!/usr/bin/perl
use strict;
require Exporter;
use CGI;

use C4::Search;
use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::Acquisition;
use C4::Biblio;
use C4::Koha;
use POSIX qw(ceil floor);
use C4::BookShelves;

my $query = new CGI;
my $dbh = C4::Context->dbh;
my $op = $query->param('op'); #show the search form or execute the search
my $zoom=$query->param('zoom');
my $number_of_results=$query->param('number_to_display');
my $format=$query->param('MARC');
my ($template, $borrowernumber, $cookie);

# get all the common search variables, 
my @fields = ('keyword', 'cql', 'itemnumber', 'isbn','biblionumber', 'class', 'branch', 'range', 'recently_items', 'ttype',
	      'field_name1', 'field_name2', 'field_name3', 'field_value1', 'field_value2', 'field_value3', 
	      'op1', 'op2', 'ttype1', 'ttype2', 'ttype3', 'atype1','atype2','atype3','date_from', 'date_to','stack','callno','authtype','authnumber','number_to_display','zoom','order','format');

# collect all the fields ...
my %search;

my @forminputs;		#this is for the links to navigate among the results when they are more than the maximum number of results per page
my (@searchdesc, %hashdesc); 	#this is to show the description of the current search

foreach my $field (@fields) {
	$search{$field} = $query->param($field);
	
	if ($search{$field}) {
		push @forminputs, {field => $field, value => $search{$field}};
	    
		if ($field eq 'class') {
			my $itemtypeinfo = &getitemtypeinfo($search{$field});
			$hashdesc{'class_desc'} = $itemtypeinfo->{'description'}; 

	    } elsif ($field eq 'branch') {	
			$hashdesc{'branch_desc'} = &getbranchname($search{$field});
	
		}

		$hashdesc{$field} = $search{$field};
	}
}


#this code is for gets the params in a loose search, and allow the user to
#come back to the last search 
my @search_conditions;
my $strdesc = '';
for (my $i = 1; $i <= 3; $i++) {
	my %hash;
	$hash{'num'} = $i;
	$hash{'with_op'} = 1 if ($i < 3);
	if ($search{"op$i"} eq 'or') {
		$hash{'or'} = 1;
	} else {
		$hash{'and'} = 1;
	}
	if ($search{"ttype$i"} eq 'normal') {
		$hash{'normal'} = 1;
	} else {
		$hash{'exact'} = 1;
	}
	$hash{"field_value"} = $search{"field_value$i"};
	$hash{$search{"field_name$i"}} = 1; 
	push @search_conditions, \%hash;
}
my @fieldsvals;
push @fieldsvals, $search{"field_value1"} if ($search{"field_value1"}); 
push @fieldsvals, $search{"field_value2"} if ($search{"field_value2"});
push @fieldsvals, $search{"field_value3"} if ($search{"field_value3"});
$hashdesc{'advanced_desc'} = join " , ", @fieldsvals;
push @searchdesc, \%hashdesc;
############################################################################

 
#this fields is just to allow the user come back to the search form with all the values who previously entered
$search{'search_type'} = $query->param('search_type');
push @forminputs, {field => 'search_type', value => $search{'search_type'}};

#Check the param to know if there is to do the search or to show the search form. 
if ($op eq "do_search") {

	($template, $borrowernumber, $cookie)
		= get_template_and_user({template_name => "catalogue/searchresults.tmpl",
					 query => $query,
					 type => "intranet",
					 authnotrequired => 1,
	});

	$search{'from'} = 'intranet';
	$search{'borrowernumber'} = $borrowernumber;
	$search{'remote_IP'} = $query->remote_addr();
	$search{'remote_URL'} = $query->url(-query=>1);
	$template->param(FORMINPUTS => \@forminputs);

	# do the searchs ....
	$number_of_results = 20 unless ($number_of_results); #this could be a parameter with 20 50 or 100 results per page
	my $startfrom=$query->param('startfrom');
	($startfrom) || ($startfrom=0);
my ($count, @results);
##Check to see if Zebra is available;
if ($zoom eq "1"){
my $zconn=C4::Context->Zconn("biblioserver");
if (!$zconn ||$zconn eq "error"){
$zoom=0;
}
}
if ($zoom eq "1"){
warn "SEARCH";
while( my ($k, $v) = each %search ) {
        warn "key: $k, value: $v.\n";
	    }
 ($count, @results) =catalogsearch4(\%search,$number_of_results,$startfrom);

}else{
($count, @results) = catalogsearch3(\%search,$number_of_results,$startfrom);
}
	if ( $count eq "error"){
	$template->param(error =>1);
	goto "show";
	}
	my $num = scalar(@results) - 1;

	# sorting out which results to display.
	# the result number to star to show
	$template->param(starting => $startfrom+$number_of_results);
	$template->param(endinging => $startfrom+1);
	$template->param(startfrom => $startfrom+1);
	# the result number to end to show
	($startfrom+$num<=$count) ? ($template->param(endat => $startfrom+$num+1)) : ($template->param(endat => $count));
	# the total results searched
	$template->param(numrecords => $count);

	$template->param(searchdesc => \@searchdesc );
	$template->param(SEARCH_RESULTS => \@results);

	#this is to show the images numbers to navigate among the results, if it has to show the number highlighted or not
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

	if ($pg > 1) {
		my $url = $pg - 1;
		push @$numbers, { number => "&lt;&lt;", 
					      highlight => 0 , 
					      startfrom => 0, 
					      pg => '1' };
		push @$numbers, { number => "&lt;", 
						  highlight => 0 , 
						  startfrom => ($url-1)*$number_of_results+1, 
						  pg => $url };
	}
	my $current_ten = $pg / 10;
	if ($current_ten == 0) {
		 $current_ten = 0.1;           # In case it´s in ten = 0
	} 
	my $from = $current_ten * 10; # Calculate the initial page
	my $end_ten = $from + 9;
	my $to;
	if ($pages > $end_ten) {
		$to = $end_ten;
	} else {
		$to = $pages;
	}
	for (my $i = $from; $i <= $to ; $i++) {
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
		my $url = $pg + 1;
		push @$numbers, { number => "&gt;", 
						  highlight => 0 , 
						  startfrom => ($url-1)*$number_of_results, 
						  pg => $url };
		push @$numbers, { number => "&gt;&gt;", 
						  highlight => 0 , 
						  startfrom => ($total_pages-1)*$number_of_results, 
						  pg => $total_pages};
	}

	$template->param(numbers => $numbers);

	#show the virtual shelves
	#my $results = &GetShelfList($borrowernumber);
	#$template->param(shelvescount => scalar(@{$results}));
	#$template->param(shelves => $results);

########
if ($format eq '1') {
	$template->param(script => "MARCdetail.pl");
}else{
	$template->param(script => "detail.pl");
}

if ( $count == 1){
    # if its a barcode search by definition we will only have one result.
    # And if we have a result
    # lets jump straight to the detail.pl page
	if ($format eq '1') {
    print $query->redirect("/cgi-bin/koha/MARCdetail.pl?type=intra&bib=$results[0]->{'biblionumber'}");
	}else{
    print $query->redirect("/cgi-bin/koha/detail.pl?type=intra&bib=$results[0]->{'biblionumber'}");
	}

}

#there isn't a search, so show the advanced search form
} else {

	($template, $borrowernumber, $cookie)
		= get_template_and_user({template_name => "catalogue/catalogue-home.tmpl",
					query => $query,
					type => "intranet",
					authnotrequired => 1,
				});

	$template->param(search_conditions => \@search_conditions);

	my $search_type = $query->param('search_type');
	if ((!$search_type) || ($search_type eq 'loose'))  {
		$template->param(loose_search => 1);
	} elsif ($search_type eq 'precise') {
		$template->param(precise_search => 1);
	} else {
		$template->param(keyword_search => 1);
	}

	my $ttype = $query->param('ttype');
	if ( (!$ttype) || ($ttype eq 'exact') ) {
		$template->param(exact => 1);
	} else {
		$template->param(normal => 1);
		$template->param(wonder => 1);
	}
	my $atype = $query->param('atype');
	if ( (!$atype) || ($atype eq 'start') && ($ttype ne 'wonder') ) {
		$template->param(start => 1);
	} else {
		$template->param(wonder => 1);
	}
	$template->param(%search);

	#show the item types
	my $class = $query->param('class');
	my ($itemtypecount,@itemtypes)= C4::Biblio::getitemtypes();
	foreach my $row (@itemtypes) {
		if ($class eq $row->{'itemtype'}) {
			$row->{'sel'} = 1;
		}
	}
	$template->param(itemtype => \@itemtypes);

	#show the branches
	my $branch = $query->param('branch');
	my ($branchcount,@branches)=branches();
	foreach my $row (@branches) {
		if ($branch eq $row->{'branchcode'}) {
			$row->{'sel'} = 1;
		}
	}
	$template->param(branches => \@branches);

	#show stacks	
	my $stack = $query->param('stack');
	my ($stackcount,@stacks)=C4::Biblio::getstacks();
	foreach my $row (@stacks) {
		if ($stack eq $row->{'authorised_value'}) {
			$row->{'sel'} = 1;
		}
	}
	$template->param(stacks => \@stacks);
		
}
show:
output_html_with_http_headers $query, $cookie, $template->output;
