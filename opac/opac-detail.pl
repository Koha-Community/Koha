#!/usr/bin/perl
use strict;
require Exporter;
use C4::Output;  # contains picktemplate
use CGI;
use C4::Search;
use C4::Auth;
 
my $query=new CGI;

my ($loggedinuser, $cookie, $sessionID) = checkauth($query, 1);

my $template = gettemplate ("opac-detail.tmpl", "opac");

$template->param(loggedinuser => $loggedinuser);

my $biblionumber=$query->param('bib');


# change back when ive fixed request.pl
my @items                                 = &ItemInfo(undef, $biblionumber, 'opac');
my $dat                                   = &bibdata($biblionumber);
my ($authorcount, $addauthor)             = &addauthor($biblionumber);
my ($webbiblioitemcount, @webbiblioitems) = &getwebbiblioitems($biblionumber);
my ($websitecount, @websites)             = &getwebsites($biblionumber);

$dat->{'count'}=@items;

$dat->{'additional'}=$addauthor->[0]->{'author'};
for (my $i = 1; $i < $authorcount; $i++) {
        $dat->{'additional'} .= "|" . $addauthor->[$i]->{'author'};
} # for

my @results;

$results[0]=$dat;

my $resultsarray=\@results;
my $itemsarray=\@items;
my $webarray=\@webbiblioitems;
my $sitearray=\@websites;


my $startfrom=$query->param('startfrom');
($startfrom) || ($startfrom=0);

my $count=1;

# now to get the items into a hash we can use and whack that thru
$template->param(startfrom => $startfrom+1);
$template->param(endat => $startfrom+20);
$template->param(numrecords => $count);
my $nextstartfrom=($startfrom+20<$count-20) ? ($startfrom+20) : ($count-20);
my $prevstartfrom=($startfrom-20>0) ? ($startfrom-20) : (0);
$template->param(nextstartfrom => $nextstartfrom);
$template->param(prevstartfrom => $prevstartfrom);

$template->param(BIBLIO_RESULTS => $resultsarray);
$template->param(ITEM_RESULTS => $itemsarray);
$template->param(WEB_RESULTS => $webarray);
$template->param(SITE_RESULTS => $sitearray);

print "Content-Type: text/html\n\n", $template->output;

