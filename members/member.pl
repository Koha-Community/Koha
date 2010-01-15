#!/usr/bin/perl


#script to do a borrower enquiry/bring up borrower details etc
#written 20/12/99 by chris@katipo.co.nz


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
use C4::Auth;
use C4::Output;
use CGI;
use C4::Members;
use C4::Branch;
use C4::Category;
use File::Basename;
use YAML;

my $input = new CGI;
my $quicksearch = $input->param('quicksearch');
my $startfrom = $input->param('startfrom')||1;
my $resultsperpage = $input->param('resultsperpage')||C4::Context->preference("PatronsPerPage")||20;

my ($template, $loggedinuser, $cookie);
if($quicksearch){
    ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/member-quicksearch-results.tmpl",
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {borrowers => 1},
                 });
} else {
    ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/member.tmpl",
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {borrowers => 1},
                 });
}
my $theme = $input->param('theme') || "default";

my $patron = $input->Vars;
foreach (keys %$patron){
	delete $$patron{$_} unless($$patron{$_}); 
}

my @categories=C4::Category->all;
my $branches=(defined $$patron{branchcode}?GetBranchesLoop($$patron{branchcode}):GetBranchesLoop());

my %categories_dislay;

foreach my $category (@categories){
	my $hash={
			category_description=>$$category{description},
			category_type=>$$category{category_type}
			 };
	$categories_dislay{$$category{categorycode}} = $hash;
}
$template->param( 
        "AddPatronLists_".C4::Context->preference("AddPatronLists")=> "1",
            );
if (C4::Context->preference("AddPatronLists")=~/code/){
    $categories[0]->{'first'}=1;
}  

my $member=$input->param('member');
my $orderbyparams=$input->param('orderby');
my @orderby;
if ($orderbyparams){
	my @orderbyelt=split(/,/,$orderbyparams);
	push @orderby, {$orderbyelt[0]=>$orderbyelt[1]||0};
}
else {
	@orderby = ({firstname=>1},{surname=>1});
}

$member =~ s/,//g;   #remove any commas from search string
$member =~ s/\*/%/g;

my ($count,$results);

my @searchpatron;
push @searchpatron, $member if ($member);
push @searchpatron, $patron if (keys %$patron);
my $from= ($startfrom-1)*$resultsperpage;
my $to=$from+$resultsperpage;
 #($results)=Search(\@searchpatron,{surname=>1,firstname=>1},[$from,$to],undef,["firstname","surname","email","othernames"]  ) if (@searchpatron);
 my $search_scope=($quicksearch?"field_start_with":"start_with");
 ($results)=Search(\@searchpatron,\@orderby,undef,undef,["firstname","surname","email","othernames","cardnumber","userid"],$search_scope  ) if (@searchpatron);
if ($results){
	$count =scalar(@$results);
}
my @resultsdata;
my $to=($count>$to?$to:$count);
my $index=$from;
foreach my $borrower(@$results[$from..$to-1]){
  #find out stats
  my ($od,$issue,$fines)=GetMemberIssuesAndFines($$borrower{'borrowernumber'});

  $$borrower{'dateexpiry'}= C4::Dates->new($$borrower{'dateexpiry'},'iso')->output('syspref');

  my %row = (
    count => $index++,
	%$borrower,
	%{$categories_dislay{$$borrower{categorycode}}},
    overdues => $od,
    issues => $issue,
    odissue => "$od/$issue",
    fines =>  sprintf("%.2f",$fines),
    );
  push(@resultsdata, \%row);
}

if ($$patron{branchcode}){
	foreach my $branch (grep{$_->{value} eq $$patron{branchcode}}@$branches){
		$$branch{selected}=1;
	}
}
if ($$patron{categorycode}){
	foreach my $category (grep{$_->{categorycode} eq $$patron{categorycode}}@categories){
		$$category{selected}=1;
	}
}
my %parameters=
        (  %$patron
		, 'orderby'			=> $orderbyparams 
		, 'resultsperpage'	=> $resultsperpage 
        , 'type'=> 'intranet'); 
my $base_url =
    'member.pl?&amp;'
  . join(
    '&amp;',
    map { "$_=$parameters{$_}" } (keys %parameters)
  );

$template->param(
    paginationbar => pagination_bar(
        $base_url,  int( $count / $resultsperpage ) + 1,
        $startfrom, 'startfrom'
    ),
    startfrom => $startfrom,
    from      => ($startfrom-1)*$resultsperpage+1,  
    to        => $to,
    multipage => ($count != $to+1 || $startfrom!=1),
);
$template->param(
    branchloop=>$branches,
	categoryloop=>\@categories,
);


$template->param( 
        searching       => "1",
		actionname		=>basename($0),
		%$patron,
        numresults      => $count,
        resultsloop     => \@resultsdata,
            );

output_html_with_http_headers $input, $cookie, $template->output;
