#!/usr/bin/perl
use strict;

use CGI;
use C4::Search;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Biblio;
use C4::Koha;
use POSIX qw(ceil floor);

my $query = new CGI;
my $dbh = C4::Context->dbh;

my $op = $query->param('op'); #show the search form or execute the search

my $format=$query->param('MARC');
my ($template, $borrowernumber, $cookie);

# get all the common search variables, 
my @value=$query->param('value');
my @kohafield=$query->param('kohafield');
my @and_or=$query->param('and_or');
my @relation=$query->param('relation');
my $order=$query->param('order');
my $reorder=$query->param('reorder');
my $number_of_results=$query->param('number_of_results');
my $zoom=$query->param('zoom');
my $ascend=$query->param('asc');

my @marclist = $query->param('marclist');
# collect all the fields ...
my %search;
my @forminputs;		#this is for the links to navigate among the results
my (@searchdesc, %hashdesc); 	#this is to show the description of the current search
my @fields = ('value', 'kohafield', 'and_or', 'relation','order','barcode','biblionumber','itemnumber','asc','from');

###Collect all the marclist values coming from old Koha MARCdetails
## Although we can not search on all marc fields- if any is matched in Zebra we can use it it
my $sth=$dbh->prepare("Select marctokoha from koha_attr where tagfield=? and tagsubfield=? and intrashow=1");
foreach my $marc (@marclist) {
		if ($marc) {
		$sth->execute(substr($marc,0,3),substr($marc,3,1));
			if ((my $kohafield)=$sth->fetchrow){
			push @kohafield,$kohafield;
			push @and_or,"\@or";
			push @value,@value[0] if @kohafield>1;
			push @relation ,"\@attr 5=1";
			}
		}
}
#### Now   normal search routine
foreach my $field (@fields) {
	$search{$field} = $query->param($field);
	if ($search{$field}) {
		push @forminputs, { field=>$field ,value=> $search{$field}} unless ($field eq 'reorder');
	    	}
}


$hashdesc{'query'} = join " , ", @value;
push @searchdesc,\%hashdesc;


############################################################################
if ($op eq "do_search"){
 
#this fields is just to allow the user come back to the search form with all the values  previously entered
$search{'search_type'} = $query->param('search_type');
push @forminputs, {field => 'search_type', value => $search{'search_type'}};


	($template, $borrowernumber, $cookie)
		= get_template_and_user({template_name => "catalogue/catalogue_searchresults.tmpl",
					 query => $query,
					 type => "intranet",
					 authnotrequired => 1,
	});

	$search{'from'} = 'intranet';
	$search{'borrowernumber'} = $borrowernumber;
	$search{'remote_IP'} = $query->remote_addr();
	$search{'remote_URL'} = $query->url(-query=>1);
	$search{'searchdesc'} = \@searchdesc;
	$template->param(FORMINPUTS => \@forminputs);
	$template->param(reorder => $query->param('reorder'));

	# do the searchs ....
	 $number_of_results = 10 unless $number_of_results;
	my $startfrom=$query->param('startfrom');
	($startfrom) || ($startfrom=0);
my ($count,@results);
if (!$zoom){
## using sql search for barcode,biblionumber or itemnumber only useful for libraian interface
	($count, @results) =sqlsearch($dbh,\%search);
}else{
my $sortorder=$order.",".$ascend if $order;
 ($count,@results) =ZEBRAsearch_kohafields(\@kohafield,\@value, \@relation,$sortorder, \@and_or, 1,$reorder,$startfrom, $number_of_results,"intranet");
}
	if ( $count eq "error"){
	$template->param(error =>1);
	goto "show";
	}
	my $num = scalar(@results) - 1;
if ( $count == 1){
    # if its a barcode search by definition we will only have one result.
    # And if we have a result
    # lets jump straight to the detail.pl page
	if ($format eq '1') {
    print $query->redirect("/cgi-bin/koha/catalogue/MARCdetail.pl?type=intra&biblionumber=$results[0]->{'biblionumber'}");
	}else{
    print $query->redirect("/cgi-bin/koha/catalogue/detail.pl?type=intra&biblionumber=$results[0]->{'biblionumber'}");
	}
}
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
						  highlight => 0 , forminputs=>\@forminputs,
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
								  highlight => 1 , forminputs=>\@forminputs,
								  startfrom => ($i-1)*$number_of_results , 
								  pg => $i };
			}
		} else {
			push @$numbers, { number => $i, 
							  highlight => 0 , forminputs=>\@forminputs,
							  startfrom => ($i-1)*$number_of_results , 
							  pg => $i };
		}
	}	        					
	if ($pg < $pages) {
		my $url = $pg + 1;
		push @$numbers, { number => "&gt;", 
						  highlight => 0 , forminputs=>\@forminputs,
						  startfrom => ($url-1)*$number_of_results, 
						  pg => $url };
		push @$numbers, { number => "&gt;&gt;", 
						  highlight => 0 , forminputs=>\@forminputs,
						  startfrom => ($total_pages-1)*$number_of_results, 
						  pg => $total_pages};
	}
#	push @$numbers,{forminputs=>@forminputs};
	$template->param(numbers =>$numbers);

	#show the virtual shelves
	#my $results = &GetShelfList($borrowernumber);
	#$template->param(shelvescount => scalar(@{$results}));
	#$template->param(shelves => $results);

########
if ($format eq '1') {
	$template->param(script => "catalogue/MARCdetail.pl");
}else{
	$template->param(script => "catalogue/detail.pl");
}

}else{ ## No search yet
($template, $borrowernumber, $cookie)
		= get_template_and_user({template_name => "catalogue/catalogue_search.tmpl",
					query => $query,
					type => "intranet",
					authnotrequired => 1,
				});
#show kohafields
	my $kohafield = $query->param('kohafield');
	my ($fieldcount,@kohafields)=getkohafields();
	foreach my $row (@kohafields) {
		if ($kohafield eq $row->{'marctokoha'}) {
			$row->{'sel'} = 1;
		}
	}
	$template->param(kohafields => \@kohafields);
##show sorting fields
my @sorts;
 $order=$query->param('order');
	foreach my $sort (@kohafields) {
	    if ($sort->{sorts}){
		push @sorts,$sort;
		if ($order eq $sort->{'marctokoha'}) {
			$sort->{'sel'} = 1;
		}
	   }
	}
	$template->param(sorts => \@sorts);

my $search_type = $query->param('search_type');
	if ((!$search_type) || ($search_type eq 'zoom'))  {
		$template->param(zoom_search => 1);
	} else{
		$template->param(sql_search => 1);
	} 
}

show:
output_html_with_http_headers $query, $cookie, $template->output();

