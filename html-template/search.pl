#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;
use C4::Database;
use CGI;
use C4::Search;
 
my $query=new CGI;


my $language='french';
my $dbh=&C4Connect;  

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
($templatename) || ($templatename=picktemplate($templatebase));


my $template = HTML::Template->new(filename => "$includes/templates/$theme/$templatebase", die_on_bad_params => 0, path => [$includes]);

my $env;
$env->{itemcount}=1;

# get all the search variables
# we assume that C4::Search will validate these values for us
my %search;
my $keyword=$query->param('keyword');
$search{'keyword'}=$keyword;
my $subject=$query->param('subject');
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
$template->param(template => $templatename);
$template->param(search => $search);
$template->param(SEARCH_RESULTS => $resultsarray);
$template->param(includesdir => $includes);


print "Content-Type: text/html\n\n", $template->output;


sub picktemplate {
    my ($includes, $base) = @_;
    my $templates;
    opendir (D, "$includes/templates");
    my @dirlist=readdir D;
    foreach (@dirlist) {
	(next) if (/^\./);
	#(next) unless (/\.tmpl$/);
	(next) unless (-e "$includes/templates/$_/$base");
	$templates->{$_}=1;
    }
    my $sth=$dbh->prepare("select value from systempreferences where variable='template'");
    $sth->execute;
    my ($preftemplate) = $sth->fetchrow;
    $preftemplate.='.tmpl';
    if ($templates->{$preftemplate}) {
	return $preftemplate;
    } else {
	return 'default';
    }
    
}
