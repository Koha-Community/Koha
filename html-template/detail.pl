#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;
use C4::Database;
use C4::Output;  # contains picktemplate
use CGI;
use C4::Search;
 
my $query=new CGI;


my $language='french';


my %configfile;
open (KC, "/etc/koha.conf");
while (<KC>) {
 chomp;
 (next) if (/^\s*#/);
 if (/(.*)\s*=\s*(.*)/) {
   my $variable=$1;
   my $value=$2;
   # Clean up white space at beginning and end
   $variable=~s/^\s*//g;
   $variable=~s/\s*$//g;
   $value=~s/^\s*//g;
   $value=~s/\s*$//g;
   $configfile{$variable}=$value;
 }
}

my $biblionumber=$query->param('bib');
my $type=$query->param('type');

# change back when ive fixed request.pl
my @items = ItemInfo(undef, $biblionumber, $type);
foreach my $dat (@items){
    $dat->{'type'}=$type;
}
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

my $includes=$configfile{'includes'};
($includes) || ($includes="/usr/local/www/hdl/htdocs/includes");
my $templatebase="catalogue/detail.tmpl";
my $startfrom=$query->param('startfrom');
($startfrom) || ($startfrom=0);
my $theme=picktemplate($includes, $templatebase);

my $template = HTML::Template->new(filename => "$includes/templates/$theme/$templatebase", die_on_bad_params => 0, path => [$includes]);

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
$template->param(includesdir => $includes);
$template->param(BIBLIO_RESULTS => $resultsarray);
$template->param(ITEM_RESULTS => $itemsarray);
$template->param(WEB_RESULTS => $webarray);
$template->param(SITE_RESULTS => $sitearray);
print "Content-Type: text/html\n\n", $template->output;

