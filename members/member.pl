#!/usr/bin/perl


#script to do a borrower enquiry/bring up borrower details etc
#written 20/12/99 by chris@katipo.co.nz


# Copyright 2000-2002 Katipo Communications
# Copyright 2010 BibLibre
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
#use warnings; FIXME - Bug 2505
use C4::Auth;
use C4::Output;
use CGI;
use C4::Members;
use C4::Branch;
use C4::Category;
use File::Basename;

my $input = new CGI;
my $quicksearch = $input->param('quicksearch');
my $startfrom = $input->param('startfrom')||1;
my $resultsperpage = $input->param('resultsperpage')||C4::Context->preference("PatronsPerPage")||20;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/member.tmpl",
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {borrowers => 1},
                 });

my $theme = $input->param('theme') || "default";

my $patron = $input->Vars;
foreach (keys %$patron){
	delete $$patron{$_} unless($$patron{$_});
}
my @categories=C4::Category->all;

my $branches = GetBranches;
my @branchloop;

foreach (sort { $branches->{$a}->{branchname} cmp $branches->{$b}->{branchname} } keys %$branches) {
  my $selected;
  $selected = 1 if $branches->{$_}->{branchcode} eq $$patron{branchcode};
  my %row = ( value => $_,
        selected => $selected,
        branchname => $branches->{$_}->{branchname},
      );
  push @branchloop, \%row;
}

my %categories_dislay;

foreach my $category (@categories){
	my $hash={
			category_description=>$$category{description},
			category_type=>$$category{category_type}
			 };
	$categories_dislay{$$category{categorycode}} = $hash;
}
my $AddPatronLists = C4::Context->preference("AddPatronLists") || '';
$template->param( 
        "AddPatronLists_$AddPatronLists" => "1",
            );
if ($AddPatronLists=~/code/){
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
	@orderby = ({surname=>0},{firstname=>0});
}

my $searchfields = $input->param('searchfields');
my @searchfields = $searchfields ? split( ',', $searchfields ) : ( "firstname", "surname", "othernames", "cardnumber", "userid", "email" );

$member =~ s/,//g;   #remove any commas from search string
$member =~ s/\*/%/g;

my $searchtype = $input->param('searchtype');
my %searchtype_ok = ( 'contain' => 1 );
if ( !defined($searchtype_ok{$searchtype}) ) {
    undef $searchtype;
}

my $from = ( $startfrom - 1 ) * $resultsperpage;
my $to   = $from + $resultsperpage;

my ($count,$results);
if ($member || keys %$patron) {
    #($results)=Search($member || $patron,{surname=>1,firstname=>1},[$from,$to],undef,["firstname","surname","email","othernames"]  );
    my $search_scope = $searchtype || ( $quicksearch ? "field_start_with" : "start_with" );
    ($results) = Search( $member || $patron, \@orderby, undef, undef, \@searchfields, $search_scope );
}

if ($results) {
	for my $field ('categorycode','branchcode'){
		next unless ($patron->{$field});
		@$results = grep { $_->{$field} eq $patron->{$field} } @$results; 
	}
    $count = scalar(@$results);
}

if($count == 1){
    print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=" . @$results[0]->{borrowernumber});
    exit;
}

my @resultsdata;
$to=($count>$to?$to:$count);
my $index=$from;
foreach my $borrower(@$results[$from..$to-1]){
  #find out stats
  my ($od,$issue,$fines)=GetMemberIssuesAndFines($$borrower{'borrowernumber'});

  $$borrower{'dateexpiry'}= C4::Dates->new($$borrower{'dateexpiry'},'iso')->output('syspref');

  my %row = (
    count => $index++,
    %$borrower,
    (defined $categories_dislay{ $borrower->{categorycode} }?   %{ $categories_dislay{ $borrower->{categorycode} } }:()),
    overdues => $od,
    issues => $issue,
    odissue => "$od/$issue",
    fines =>  sprintf("%.2f",$fines),
    branchname => $branches->{$borrower->{branchcode}}->{branchname},
    );
  push(@resultsdata, \%row);
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

my @letters = map { {letter => $_} } ( 'A' .. 'Z');

$template->param(
    letters => \@letters,
    paginationbar => pagination_bar(
        $base_url,
        int( $count / $resultsperpage ) + ($count % $resultsperpage ? 1 : 0),
        $startfrom, 'startfrom'
    ),
    startfrom => $startfrom,
    from      => ($startfrom-1)*$resultsperpage+1,  
    to        => $to,
    multipage => ($count != $to || $startfrom!=1),
    advsearch => ($$patron{categorycode} || $$patron{branchcode}),
    branchloop=>\@branchloop,
    categories=>\@categories,
    searching       => "1",
		actionname		=>basename($0),
		%$patron,
        numresults      => $count,
        resultsloop     => \@resultsdata,
            );

output_html_with_http_headers $input, $cookie, $template->output;
