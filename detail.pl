#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;
use C4::Database;
use C4::Output;  # contains gettemplate
use CGI;
use C4::Search;
use C4::Auth;
 
my $query=new CGI;
my $type=$query->param('type');
(-e "opac") && ($type='opac');
($type) || ($type='intra');
my ($loggedinuser, $cookie, $sessionID) = checkauth($query, ($type eq 'opac') ? (1) : (0));


my $biblionumber=$query->param('bib');

# change back when ive fixed request.pl
my @items = ItemInfo(undef, $biblionumber, $type);
my $dat=bibdata($biblionumber);
my ($authorcount, $addauthor)= &addauthor($biblionumber);
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

my $template=gettemplate('catalogue/detail.tmpl');
my $count=1;

# now to get the items into a hash we can use and whack that thru


$template->param(startfrom => $startfrom+1);
$template->param(endat => $startfrom+20);
$template->param(numrecords => $count);
my $nextstartfrom=($startfrom+20<$count-20) ? ($startfrom+20) : ($count-20);
my $prevstartfrom=($startfrom-20>0) ? ($startfrom-20) : (0);
$template->param(nextstartfrom => $nextstartfrom);
$template->param(prevstartfrom => $prevstartfrom);
# $template->param(template => $templatename);
# $template->param(search => $search);
#$template->param(includesdir => $includes);
$template->param(BIBLIO_RESULTS => $resultsarray);
$template->param(ITEM_RESULTS => $itemsarray);
$template->param(WEB_RESULTS => $webarray);
$template->param(SITE_RESULTS => $sitearray);
$template->param(loggedinuser => $loggedinuser);
print $query->header(-cookie => $cookie), $template->output;

