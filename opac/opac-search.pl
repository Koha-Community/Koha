#!/usr/bin/perl
use strict;
require Exporter;

use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Context;
use CGI;
use C4::Database;
use HTML::Template;
use C4::SearchMarc;
use C4::Acquisition;
use C4::Biblio;

my $classlist='';

my $dbh=C4::Context->dbh;
my $sth=$dbh->prepare("select description,itemtype from itemtypes order by description");
$sth->execute;
while (my ($description,$itemtype) = $sth->fetchrow) {
    $classlist.="<option value=\"$itemtype\">$description</option>\n";
}


my $query = new CGI;
my $op = $query->param("op");
my $type=$query->param('type');

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
		if ($marc) {
			my ($tag,$subfield) = MARCfind_marc_from_kohafield($dbh,$marc);
			if ($tag) {
				push @tags,$dbh->quote("$tag$subfield");
			} else {
				push @tags, $dbh->quote(substr($marc,0,4));
			}
		} else {
			push @tags, "";
		}
	}
	findseealso($dbh,\@tags);
	my ($results,$total) = catalogsearch($dbh, \@tags,\@and_or,
										\@excluding, \@operator, \@value,
										$startfrom*$resultsperpage, $resultsperpage,$orderby);

	($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "opac-searchresults.tmpl",
				query => $query,
				type => 'opac',
				authnotrequired => 1,
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
	$template->param(results => $results,
							startfrom=> $startfrom,
							displaynext=> $displaynext,
							displayprev=> $displayprev,
							resultsperpage => $resultsperpage,
							orderby => $orderby,
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
		= get_template_and_user({template_name => "opac-search.tmpl",
					query => $query,
					type => "opac",
					authnotrequired => 1,
				});
	
	
	$sth=$dbh->prepare("Select itemtype,description from itemtypes order by description");
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
				-multiple => 0 );
	$sth->finish;
	
	my @branches;
	my @select_branch;
	my %select_branches;
	my ($count2,@branches)=branches();
	push @select_branch, "";
	$select_branches{''} = "";
	for (my $i=0;$i<$count2;$i++){
		push @select_branch, $branches[$i]->{'branchcode'};#
		$select_branches{$branches[$i]->{'branchcode'}} = $branches[$i]->{'branchname'};
	}
	my $CGIbranch=CGI::scrolling_list( -name     => 'value',
				-values   => \@select_branch,
				-labels   => \%select_branches,
				-size     => 1,
				-multiple => 0 );
	$sth->finish;
	
	$template->param(classlist => $classlist,
					CGIitemtype => $CGIitemtype,
					CGIbranch => $CGIbranch,
	);
}

output_html_with_http_headers $query, $cookie, $template->output;
