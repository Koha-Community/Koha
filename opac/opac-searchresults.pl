#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Search;
use C4::Auth;
use C4::Charset;
use HTML::Template;

my $query=new CGI;

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "opac-searchresults.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 1,
			     flagsrequired => {borrow => 1},
			 });


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
    if ($field eq 'keyword'){
	$search{$field} = $query->param('words') unless $search{$field};
    }
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
my $number_of_results = 20;
my @results;
my $count;
my $startfrom = $query->param('startfrom');
my $subjectitems=$query->param('subjectitems');
if ($subjectitems) {
    @results = subsearch($env,$subjectitems, $number_of_results, $startfrom);
    $count = $#results+1;
} else {
    ($count, @results) = catalogsearch($env,'',\%search,$number_of_results,$startfrom);
}

my $num = 1;
foreach my $res (@results) {
    my @items = ItemInfo(undef, $res->{'biblionumber'}, "intra");
    my $norequests = 1;
    foreach my $itm (@items) {
	$norequests = 0 unless $itm->{'notforloan'};
    }
    $res->{'norequests'} = $norequests;
    # set up the even odd elements....
    $res->{'even'} = 1 if $num % 2 == 0;
    $res->{'odd'} = 1 if $num % 2 == 1;
    $num++;
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

print $query->header(
    -type => guesstype($template->output),
    -cookie => $cookie
), $template->output;

