#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Search;
use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;

my $query=new CGI;
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "opac-searchresults.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 1,
			     flagsrequired => {borrow => 1},
			 });




my $itemtype=$query->param('itemtype');
my $duration =$query->param('duration');
my $number_of_results = 20;

my $startfrom = $query->param('startfrom');
($startfrom) || ($startfrom=0);
my $subjectitems=$query->param('subjectitems');
my (@results) = newsearch($itemtype,$duration,$number_of_results,$startfrom);
my $count= $#results+1;
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

my $resultsarray=\@results;
($resultsarray) || (@$resultsarray=());

# sorting out which results to display.
$template->param(startfrom => $startfrom+1);
($startfrom+$num<=$count) ? ($template->param(endat => $startfrom+$num)) : ($template->param(endat => $count));
$template->param(numrecords => $count);
my $nextstartfrom=($startfrom+$num<$count) ? ($startfrom+$num) : (-1);
my $prevstartfrom=($startfrom-$num>=0) ? ($startfrom-$number_of_results) : (-1);
my $displaynext=($nextstartfrom==-1) ? 0 : 1;
my $displayprev=($prevstartfrom==-1) ? 0 : 1;
$template->param(nextstartfrom => $nextstartfrom,
				displaynext => $displaynext,
				displayprev => $displayprev,
				prevstartfrom => $prevstartfrom,
				searchnew => 1,
				itemtype => ItemType($itemtype),
				duration => $duration);

$template->param(SEARCH_RESULTS => $resultsarray,
			     LibraryName => C4::Context->preference("LibraryName"),
);

my $numbers;
@$numbers = ();
if ($count>$number_of_results) {
	for (my $i=1; $i<$count/$number_of_results+1; $i++) {
		my $highlight=0;
		my $themelang = $template->param('themelang');
		($startfrom==($i-1)*$number_of_results+1) && ($highlight=1);
		push @$numbers, { number => $i, highlight => $highlight , startfrom => ($i-1)*$number_of_results+1 };
	}
}

$template->param(numbers => $numbers);

output_html_with_http_headers $query, $cookie, $template->output;
