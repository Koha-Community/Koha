#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;
use C4::Database;
use CGI;
use C4::Search;
use C4::Auth;
use C4::Output; # no contains gettemplate
  
my $query=new CGI;
my $type=$query->param('type');

my ($loggedinuser, $cookie, $sessionID) = checkauth($query, 1);



my $startfrom=$query->param('startfrom');
($startfrom) || ($startfrom=0);

my $subject=$query->param('subject');

my $template;
if ($subject) {
    $template=gettemplate('catalogue/subject.tmpl');
} else {
    $template=gettemplate('catalogue/searchresults.tmpl');
}


my $env;
$env->{itemcount}=1;

# get all the search variables
# we assume that C4::Search will validate these values for us
my %search;

my @fields = ('keyword', 'subject', 'author', 'illustrator', 'itemnumber', 'isbn', 'date-before', 'date-after', 'class', 'dewey', 'class', 'branch', 'title', 'abstract', 'publisher');

my $forminputs;
my $searchdesc = '';
foreach my $field (@fields) {
    $search{$field} = $query->param($field);
    if ($search{$field}) {
	push @$forminputs, {field => $field, value => $search{$field}};
	$searchdesc .= "$field = $search{$field}, ";
    }
}
$search{'ttype'} = $query->param('ttype');
push @$forminputs, {field => 'ttype', value => $search{'ttype'}};

if (my $subjectitems=$query->param('subjectitems')){
    $search{'subject'} = $subjectitems;
    $searchdesc.="subject = $subjectitems, ";
}

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
    @results=subsearch(\$blah,$subject,$num,$startfrom);
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
    push (@$resultsarray, $result);
}
($resultsarray) || (@$resultsarray=());
my $search="num=20";

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
	    my $highlight=0;
	    ($startfrom==($i-1)*10) && ($highlight=1);
	    push @$numbers, { number => $i, highlight => $highlight , FORMINPUTS => $forminputs, startfrom => ($i-1)*10};
	}
    }
}

$template->param(numbers => $numbers);



print $query->header(-cookie => $cookie), $template->output;

