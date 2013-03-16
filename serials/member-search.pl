#!/usr/bin/perl

# Parts copyright Catalyst IT 2010
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

=head1 member-search.pl

Member Search.pl script used to search for members to add to a routing list

=cut

use strict;
use warnings;
use CGI;
use C4::Auth;       # get_template_and_user
use C4::Output;
use C4::Members;    # BornameSearch
use C4::Branch;
use C4::Category;
use File::Basename;

my $cgi          = new CGI;
my $theme = $cgi->param('theme') || "default";
my $resultsperpage = $cgi->param('resultsperpage')||C4::Context->preference("PatronsPerPage")||20;
my $startfrom = $cgi->param('startfrom')||1;

my $patron = $cgi->Vars;
foreach (keys %$patron){
    delete $$patron{$_} unless($$patron{$_});
}

my @categories=C4::Category->all;
my $branches=(defined $$patron{branchcode}?GetBranchesLoop($$patron{branchcode}):GetBranchesLoop());
my $subscriptionid = $cgi->param('subscriptionid');
my $searchstring   = $cgi->param('member');

my %categories_dislay;
my ($template, $loggedinuser, $cookie);
    ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "serials/member-search.tmpl",
                 query => $cgi,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => { serials => 'routing' },
                 });

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

my $member=$cgi->param('member');
my $orderby=$cgi->param('orderby');
$orderby = "surname,firstname" unless $orderby;
if (defined $member) {
    $member =~ s/,//g;   #remove any commas from search string
    $member =~ s/\*/%/g;
}

my ($count,$results);

if (C4::Context->preference("IndependantBranches")){
   if (C4::Context->userenv && C4::Context->userenv->{flags} % 2 !=1 && C4::Context->userenv->{'branch'}){
        $$patron{branchcode}=C4::Context->userenv->{'branch'};
   }
}
$$patron{firstname}.="\%" if ($$patron{firstname});
$$patron{surname}.="\%" if ($$patron{surname});

my @searchpatron;
push @searchpatron, $member if ($member);
push @searchpatron, $patron if ( keys %$patron );
my $from = ( $startfrom - 1 ) * $resultsperpage;
my $to   = $from + $resultsperpage;
if (@searchpatron) {
    ($results) = Search(
        \@searchpatron,
        [ { surname => 0 }, { firstname => 0 } ],
        undef,
        undef,
        [ "firstname", "surname", "email", "othernames", "cardnumber" ],
        "start_with"
    );
}
if ($results) {
    $count = scalar(@$results);
}
my @resultsdata;
$to=($count>$to?$to:$count);
my $index=$from;
foreach my $borrower(@$results[$from..$to-1]){
    # find out stats
    $borrower->{'dateexpiry'}= C4::Dates->new($borrower->{'dateexpiry'},'iso')->output('syspref');
    if ($categories_dislay{$borrower->{'categorycode'}}){
        my %row = (
	    count => $index++,
	    %$borrower,
	    %{$categories_dislay{$$borrower{categorycode}}},
	);
	push(@resultsdata, \%row);
    }
    else {
	 warn $borrower->{'cardnumber'} ." has a bad category code of " . $borrower->{'categorycode'} ."\n";
    }
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
(  %{$patron},
    'orderby' => $orderby,
    'resultsperpage' => $resultsperpage,
    'type'=> 'intranet');
my $base_url =
    'member-search.pl?&amp;'
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
		actionname		=> basename($0),
		%$patron,
        numresults      => $count,
        resultsloop     => \@resultsdata,
            );

output_html_with_http_headers $cgi, $cookie, $template->output;
