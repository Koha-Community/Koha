#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;
use C4::Database;
use CGI;
use C4::Search;
use C4::Output; # no contains picktemplate
  
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
#print $query->header;

my $includes=$configfile{'includes'};
($includes) || ($includes="/usr/local/www/hdl/htdocs/includes");
my $templatebase="catalogue/searchresults.tmpl";
my $startfrom=$query->param('startfrom');
($startfrom) || ($startfrom=0);
my $theme=picktemplate($includes, $templatebase);

my $subject=$query->param('subject');
# if its a subject we need to use the subject.tmpl
$templatebase=~ s/searchresults\.tmpl/subject\.tmpl/;

my $template = HTML::Template->new(filename => "$includes/templates/$theme/$templatebase", die_on_bad_params => 0, path => [$includes]);

my $env;
$env->{itemcount}=1;

# get all the search variables
# we assume that C4::Search will validate these values for us
my %search;
my $keyword=$query->param('keyword');
$search{'keyword'}=$keyword;

$search{'subject'}=$subject;
my $author=$query->param('author');
$search{'author'}=$author;
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
$search{'dewey'};
my $branch=$query->param('branch');
$search{'branch'}=$branch;
my $title=$query->param('title');
$search{'title'}=$title;
my $ttype=$query->param('ttype');
$search{'ttype'}=$ttype;

# whats this for?
$search{'front'}=$query->param('front');

my $num=20;
my ($count,@results)=catalogsearch($env,'',\%search,$num,$startfrom);

my $resultsarray=\@results;

my $search="num=20";
if ($keyword){
    $search=$search."&keyword=$keyword";
}
if ($subject){
    $search=$search."&subject=$subject";
}
if ($author){
    $search=$search."&author=$author";
}
if ($class){
    $search=$search."&class=$class";
}
if ($title){
    $search=$search."&title=$title";
}
if ($dewey){
    $search=$search."&dewey=$dewey";
}
$search.="&ttype=$ttype";

$search=~ s/ /%20/g;
$template->param(startfrom => $startfrom+1);
$template->param(endat => $startfrom+20);
$template->param(numrecords => $count);
my $nextstartfrom=($startfrom+20<$count-20) ? ($startfrom+20) : ($count-20);
my $prevstartfrom=($startfrom-20>0) ? ($startfrom-20) : (0);
$template->param(nextstartfrom => $nextstartfrom);
$template->param(prevstartfrom => $prevstartfrom);
$template->param(search => $search);
$template->param(SEARCH_RESULTS => $resultsarray);
$template->param(includesdir => $includes);


print "Content-Type: text/html\n\n", $template->output;

