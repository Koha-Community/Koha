#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Search;
use C4::Auth;
use C4::Output; # now contains gettemplate
  
my $query=new CGI;

my ($loggedinuser, $cookie, $sessionID) = checkauth($query, 1);


my $template = gettemplate ("opac-searchresults.tmpl", "opac");



my $subject=$query->param('subject');


if ($subject) {
    $template->param(subjectsearch => $subject);
}

# get all the search variables
# we assume that C4::Search will validate these values for us
my @fields = ('keyword', 'subject', 'author', 'illustrator', 'itemnumber', 'isbn', 'date-before', 'date-after', 'class', 'dewey', 'branch', 'title', 'abstract', 'publisher');



# collect all the fields ...
my %search;
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

@$forminputs=() unless $forminputs;
$template->param(FORMINPUTS => $forminputs);

# do the searchs ....
my $env;
$env->{itemcount}=1;
my $num=10;
my @results;
my $count;
my $startfrom = $query->param('startfrom');
my $subjectitems=$query->param('subjectitems');
if ($subjectitems) {
    my $blah;
    @results = subsearch(\$blah,$subjectitems, $num, $startfrom);
    $count = $#results+1;
} else {
    ($count, @results) = catalogsearch($env,'',\%search,$num,$startfrom);
}

foreach my $res (@results) {
    my @items = ItemInfo(undef, $res->{'biblionumber'}, "intra");
    my $norequests = 1;
    foreach my $itm (@items) {
	$norequests = 0 unless $itm->{'notforloan'};
    }
    $res->{'norequests'} = $norequests;
}


my $startfrom=$query->param('startfrom');
($startfrom) || ($startfrom=0);

my $resultsarray=\@results;
($resultsarray) || (@$resultsarray=());


# sorting out which results to display.
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

$template->param(searchdesc => $searchdesc);
$template->param(SEARCH_RESULTS => $resultsarray);
$template->param(loggedinuser => $loggedinuser);

my $numbers;
@$numbers = ();
if ($count>10) {
    for (my $i=1; $i<$count/10+1; $i++) {
	my $highlight=0;
	my $themelang = $template->param('themelang');
	($startfrom==($i-1)*10) && ($highlight=1);
	push @$numbers, { number => $i, highlight => $highlight , startfrom => ($i-1)*10 };
    }
}

$template->param(numbers => $numbers);

$template->param(loggedinuser => $loggedinuser);

print $query->header(-cookie => $cookie), $template->output;

