#!/usr/bin/perl

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
require Exporter;
use CGI;
use C4::Auth;
use HTML::Template;
use C4::Context;
use C4::Search;
use C4::Auth;
use C4::Output;
use C4::Charset;

my $query=new CGI;
my $type=$query->param('type');

#(-e "opac") && ($type='opac');

my ($loggedinuser, $cookie, $sessionID) = checkauth($query, ($type eq 'opac') ? (1) : (0));

my $startfrom=$query->param('startfrom');
($startfrom) || ($startfrom=0);

my $subject=$query->param('subject');
# if it's a subject we need to use the subject.tmpl
my ($template, $loggedinuser, $cookie);
if ($subject) {
 	($template, $loggedinuser, $cookie)
   		= get_template_and_user({template_name => "catalogue/subject.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1},
			     debug => 1,
			     });
} else {
 	($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "catalogue/searchresults.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1},
			     debug => 1,
			     });
}

# %env
# Additional parameters for &catalogsearch
my %env = (
	itemcount	=> 1,	# If set to 1, &catalogsearch enumerates
				# the results found and returns the number
				# of items found, where they're located,
				# etc.
	);

# get all the search variables
# we assume that C4::Search will validate these values for us
my %search;			# Search terms. If the key is "author",
				# then $search{author} is the author the
				# user is looking for.

my @forminputs;			# This is used in the form template.

foreach my $term (qw(keyword subject author illustrator itemnumber
		     isbn date-before class dewey branch title abstract
		     publisher ttype))
{
	my $value = $query->param($term);

	next unless defined $value && $value ne "";
				# Skip blank search terms
	$search{$term} = $value;
	push @forminputs, { line => "$term=$value" };
}

$template->param(FORMINPUTS => \@forminputs);

# whats this for?
# I think it is (or was) a search from the "front" page...   [st]
$search{'front'}=$query->param('front');

my $num=10;
my @results;
my $count;
if (my $subject=$query->param('subjectitems')) {
    my $blah;
    @results=subsearch(\$blah,$subject);
    $count=$#results+1;
} else {
    ($count,@results)=catalogsearch(\%env,'',\%search,$num,$startfrom);
}

#my $resultsarray=\@results;
my $resultsarray;

foreach my $result (@results) {
    $result->{'authorhtmlescaped'}=$result->{'author'};
    $result->{'authorhtmlescaped'}=~s/ /%20/g;
    ($result->{'copyrightdate'}==0) && ($result->{'copyrightdate'}='');
    ($type eq 'opac') ? ($result->{'opac'}=1) : ($result->{'opac'}=0);
    push (@$resultsarray, $result);
}
($resultsarray) || (@$resultsarray=());
my $search="num=20";
my $searchdesc='';
if ($search{"keyword"}) {
    $search .= "&keyword=$search{keyword}";
    $searchdesc.="keyword $search{keyword}, ";
}
if (my $subjectitems=$query->param('subjectitems')){
    $search .= "&subjectitems=$subjectitems";
    $searchdesc.="subject $subjectitems, ";
}
if ($subject){
    $search .= "&subject=$subject";
    $searchdesc.="subject $subject, ";
}
if ($search{"author"}){
    $search .= "&author=$search{author}";
    $searchdesc.="author $search{author}, ";
}
if ($search{"class"}){
    $search .= "&class=$search{class}";
    $searchdesc.="class $search{class}, ";
}
if ($search{"title"}){
    $search .= "&title=$search{title}";
    $searchdesc.="title $search{title}, ";
}
if ($search{"dewey"}){
    $search .= "&dewey=$search{dewey}";
    $searchdesc.="dewey $search{dewey}, ";
}
$search.="&ttype=$search{ttype}";

$search=~ s/ /%20/g;
$template->param(startfrom => $startfrom+1);
($startfrom+$num<=$count) ? ($template->param(endat => $startfrom+$num)) : ($template->param(endat => $count));
$template->param(numrecords => $count);
my $nextstartfrom=($startfrom+$num<$count) ? ($startfrom+$num) : (-1);
my $prevstartfrom=($startfrom-$num>=0) ? ($startfrom-$num) : (-1);
$template->param(nextstartfrom => $nextstartfrom);
my $displaynext=1;
my $displayprev=0;
($nextstartfrom==-1) ? ($displaynext=0) : ($displaynext=1);
($prevstartfrom==-1) ? ($displayprev=0) : ($displayprev=1);
$template->param(displaynext => $displaynext);
$template->param(displayprev => $displayprev);
($type eq 'opac') ? ($template->param(opac => 1)) : ($template->param(opac => 0));
$template->param(prevstartfrom => $prevstartfrom);
$template->param(search => $search);
$template->param(searchdesc => $searchdesc);
$template->param(SEARCH_RESULTS => $resultsarray);
#$template->param(includesdir => $includes);
$template->param(loggedinuser => $loggedinuser);

my @numbers = ();
if ($count>10) {
    for (my $i=1; $i<$count/10+1; $i++) {
	if ($i<16) {
	    if ($search{"title"})
	    {
		push @forminputs, { line => "title=$search{title}"};
	    }
	    my $highlight=0;
	    ($startfrom==($i-1)*10) && ($highlight=1);
	    my $formelements='';
	    foreach (@forminputs) {
		my $line=$_->{line};
		$formelements.="$line&";
	    }
	    $formelements=~s/ /+/g;
	    push @numbers, { number => $i, highlight => $highlight , FORMELEMENTS => $formelements, FORMINPUTS => \@forminputs, startfrom => ($i-1)*10, opac => (($type eq 'opac') ? (1) : (0))};
	}
    }
}

$template->param(numbers => \@numbers);
if (C4::Context->preference('acquisitions') eq 'simple') {
	$template->param(script => "MARCdetail.pl");
} else {
	$template->param(script => "detail.pl");
}

# Print the page
print $query->header(
    -type => guesstype($template->output),
    -cookie => $cookie
), $template->output;

