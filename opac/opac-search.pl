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
use C4::Koha;
# use C4::Search;

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
my $searchdesc;

if ($op eq "do_search") {
	my @marclist = $query->param('marclist');
	my @and_or = $query->param('and_or');
	my @excluding = $query->param('excluding');
	my @operator = $query->param('operator');
	my @value = $query->param('value');
	my $orderby = $query->param('orderby');
	my $desc_or_asc = $query->param('desc_or_asc');
	my $exactsearch = $query->param('exact');
	for (my $i=0;$i<=$#marclist;$i++) {

		if ($marclist[$i] eq "biblioitems.isbn") {
			$value[$i] =~ s/-//g;
		}
                if ($searchdesc) { # don't put the and_or on the 1st search term
                        $searchdesc .= $and_or[$i].$excluding[$i]." ".($marclist[$i]?$marclist[$i]:"* ")." ".$operator[$i]." ".$value[$i]." " if ($value[$i]);
                } else {                        $searchdesc = $excluding[$i].($marclist[$i]?$marclist[$i]:"* ")." ".$operator[$i]." ".$value[$i]." " if ($value[$i]);
                }
        }
	
	$resultsperpage= $query->param('resultsperpage');
	$resultsperpage = 19 if(!defined $resultsperpage);
	
	if ($exactsearch) {
		foreach (@operator) {
			$_='=';
		}
	}
	# builds tag and subfield arrays
	my @tags;

	foreach my $marc (@marclist) {
		if ($marc) {
			my ($tag,$subfield) = MARCfind_marc_from_kohafield($dbh,$marc,'');
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
										$startfrom*$resultsperpage, $resultsperpage,$orderby,$desc_or_asc);
	if ($total ==1) {
	if (C4::Context->preference("BiblioDefaultView") eq "normal") {
	     print $query->redirect("/cgi-bin/koha/opac-detail.pl?bib=".@$results[0]->{biblionumber});
	} elsif (C4::Context->preference("BiblioDefaultView") eq "marc") {
	     print $query->redirect("/cgi-bin/koha/opac-MARCdetail.pl?bib=".@$results[0]->{biblionumber});
	} else {
	     print $query->redirect("/cgi-bin/koha/opac-ISBDdetail.pl?bib=".@$results[0]->{biblionumber});
	}
	exit;
	}
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
	push @field_data, {term => "desc_or_asc", val => $desc_or_asc} if $desc_or_asc;
	push @field_data, {term => "orderby", val => $orderby} if $orderby;
	my @numbers = ();

	if ($total>$resultsperpage){
		
		if($startfrom>5){
			for(my $i = $startfrom-4;$i<$total/$resultsperpage+1;$i++){
				if($i<$startfrom+7){
					my $highlight = 0;
					($startfrom==($i-1)) && ($highlight = 1);
					push @numbers,
					{       number => $i,
						 highlight => $highlight ,
						 searchdata=> \@field_data,
						 startfrom => ($i-1)
					};
				}
			}
		}
		else {
			for (my $i=1; $i<$total/$resultsperpage+1; $i++){
				if (($i<=10)) {
					my $highlight = 0;
					($startfrom==($i-1)) && ($highlight = 1);
					push @numbers,{
						number => $i,
						highlight => $highlight ,
						searchdata=> \@field_data,
						startfrom => ($i-1)
					};
				}
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
	my $defaultview = 'BiblioDefaultView'.C4::Context->preference('BiblioDefaultView');
	$template->param(
			results => $results,
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
			searchdesc=> $searchdesc,
			$defaultview => 1,
		);

} else {
	($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "opac-search.tmpl",
					query => $query,
					type => "opac",
					authnotrequired => 1,
				});
	
	
	my $query="Select itemtype,description from itemtypes order by description";
	my $sth=$dbh->prepare($query);
	$sth->execute;
	my  @itemtypeloop;
	my %itemtypes;
	while (my ($value,$lib) = $sth->fetchrow_array) {
		my %row =(	value => $value,
					description => $lib,
				);
		push @itemtypeloop, \%row;
	}
	$sth->finish;

	my @oldbranches;
	my @oldselect_branch;
	my %oldselect_branches;
	my ($oldcount2,@oldbranches)=branches();
	push @oldselect_branch, "";
	$oldselect_branches{''} = "";
	for (my $i=0;$i<$oldcount2;$i++){
		push @oldselect_branch, $oldbranches[$i]->{'branchcode'};#
		$oldselect_branches{$oldbranches[$i]->{'branchcode'}} = $oldbranches[$i]->{'branchname'};
	}
	my $CGIbranch=CGI::scrolling_list( -name     => 'value',
				-values   => \@oldselect_branch,
				-labels   => \%oldselect_branches,
				-size     => 1,
				-multiple => 0 );
	$sth->finish;

	my @branches;
	my @select_branch;
	my %select_branches;
	my $branches = getallbranches();
	my @branchloop;
	foreach my $thisbranch (keys %$branches) {
        my $selected = 1 if (C4::Context->userenv && ($thisbranch eq C4::Context->userenv->{branch}));
        my %row =(value => $thisbranch,
                                selected => $selected,
                                branchname => $branches->{$thisbranch}->{'branchname'},
                        );
        push @branchloop, \%row;
	}
 
	$template->param('Disable_Dictionary'=>C4::Context->preference("Disable_Dictionary")) if (C4::Context->preference("Disable_Dictionary"));
	$template->param(classlist => $classlist,
					branchloop=>\@branchloop,
					itemtypeloop => \@itemtypeloop,
					CGIbranch => $CGIbranch,
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
}

output_html_with_http_headers $query, $cookie, $template->output;
