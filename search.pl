#!/usr/bin/perl

use HTML::Template;



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
use C4::Context;
use C4::Search;
use C4::Auth;
use C4::Output;

my $query=new CGI;
my $type=$query->param('type');
(-e "opac") && ($type='opac');

my ($loggedinuser, $cookie, $sessionID) = checkauth($query, ($type eq 'opac') ? (1) : (0));


my $startfrom=$query->param('startfrom');
($startfrom) || ($startfrom=0);

my $subject=$query->param('subject');
my $template;
# if it's a subject we need to use the subject.tmpl
if ($subject) {
	$template = gettemplate("catalogue/subject.tmpl",0);
} else {
	$template = gettemplate("catalogue/searchresults.tmpl", 0);
}

my $env;
$env->{itemcount}=1;

# get all the search variables
# we assume that C4::Search will validate these values for us
# FIXME - This whole section, up to the &catalogsearch call, is crying
# out for
#	foreach $search_term (qw(keyword subject author ...))
#	{ ... }
my %search;
my $keyword=$query->param('keyword');
$search{'keyword'}=$keyword;

$search{'subject'}=$subject;
my $author=$query->param('author');
$search{'author'}=$author;
$search{'authoresc'}=$author;
#$search{'authorhtmlescaped'}=~s/ /%20/g;
my $illustrator=$query->param('illustrator');
$search{'param'}=$illustrator;
my $itemnumber=$query->param('itemnumber');
$search{'itemnumber'}=$itemnumber;
my $isbn=$query->param('isbn');
$search{'isbn'}=$isbn;
my $datebefore=$query->param('date-before');
$search{'date-before'}=$datebefore;
my $class=$query->param('class');
$search{'class'}=$class;
my $dewey=$query->param('dewey');
$search{'dewey'}=$dewey;
my $branch=$query->param('branch');
$search{'branch'}=$branch;
my $title=$query->param('title');
$search{'title'}=$title;
my $abstract=$query->param('abstract');
$search{'abstract'}=$abstract;
my $publisher=$query->param('publisher');
$search{'publisher'}=$publisher;

my $ttype=$query->param('ttype');
$search{'ttype'}=$ttype;

my $forminputs;
($keyword) && (push @$forminputs, { line => "keyword=$keyword"});
($subject) && (push @$forminputs, { line => "subject=$subject"});
($author) && (push @$forminputs, { line => "author=$author"});
($illustrator) && (push @$forminputs, { line => "illustrator=$illustrator"});
($itemnumber) && (push @$forminputs, { line => "itemnumber=$itemnumber"});
($isbn) && (push @$forminputs, { line => "isbn=$isbn"});
($datebefore) && (push @$forminputs, { line => "date-before=$datebefore"});
($class) && (push @$forminputs, { line => "class=$class"});
($dewey) && (push @$forminputs, { line => "dewey=$dewey"});
($branch) && (push @$forminputs, { line => "branch=$branch"});
($title) && (push @$forminputs, { line => "title=$title"});
($ttype) && (push @$forminputs, { line => "ttype=$ttype"});
($abstract) && (push @$forminputs, { line => "abstract=$abstract"});
($publisher) && (push @$forminputs, { line => "publisher=$publisher"});
($forminputs) || (@$forminputs=());
$template->param(FORMINPUTS => $forminputs);
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
    ($count,@results)=catalogsearch($env,'',\%search,$num,$startfrom);
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
if ($keyword){
    $search=$search."&keyword=$keyword";
    $searchdesc.="keyword $keyword, ";
}
if (my $subjectitems=$query->param('subjectitems')){
    $search=$search."&subjectitems=$subjectitems";
    $searchdesc.="subject $subjectitems, ";
}
if ($subject){
    $search=$search."&subject=$subject";
    $searchdesc.="subject $subject, ";
}
if ($author){
    $search=$search."&author=$author";
    $searchdesc.="author $author, ";
}
if ($class){
    $search=$search."&class=$class";
    $searchdesc.="class $class, ";
}
if ($title){
    $search=$search."&title=$title";
    $searchdesc.="title $title, ";
}
if ($dewey){
    $search=$search."&dewey=$dewey";
    $searchdesc.="dewey $dewey, ";
}
$search.="&ttype=$ttype";

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

my $numbers;
@$numbers=();
if ($count>10) {
    for (my $i=1; $i<$count/10+1; $i++) {
	if ($i<16) {
	    ($title) && (push @$forminputs, { line => "title=$title"});
	    my $highlight=0;
	    ($startfrom==($i-1)*10) && ($highlight=1);
	    my $formelements='';
	    foreach (@$forminputs) {
		my $line=$_->{line};
		$formelements.="$line&";
	    }
	    $formelements=~s/ /+/g;
	    push @$numbers, { number => $i, highlight => $highlight , FORMELEMENTS => $formelements, FORMINPUTS => $forminputs, startfrom => ($i-1)*10, opac => (($type eq 'opac') ? (1) : (0))};
	}
    }
}

$template->param(numbers => $numbers);



print $query->header(-cookie => $cookie), $template->output;

