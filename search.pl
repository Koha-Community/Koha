#!/usr/bin/perl
use HTML::Template;
#script to provide intranet (librarian) advanced search facility


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
if ($subject) {
    $templatebase=~ s/searchresults\.tmpl/subject\.tmpl/;
    $theme=picktemplate($includes, $templatebase);
}

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
$template->param(FORMINPUTS => $forminputs);
# whats this for?
# I think it is (or was) a search from the "front" page...   [st]
$search{'front'}=$query->param('front');

my $num=10;
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
$template->param(endat => $startfrom+$num);
$template->param(numrecords => $count);
my $nextstartfrom=($startfrom+$num<$count-$num) ? ($startfrom+$num) : ($count-$num);
my $prevstartfrom=($startfrom-$num>0) ? ($startfrom-$num) : (0);
$template->param(nextstartfrom => $nextstartfrom);
$template->param(prevstartfrom => $prevstartfrom);
$template->param(search => $search);
$template->param(SEARCH_RESULTS => $resultsarray);
$template->param(includesdir => $includes);


print "Content-Type: text/html\n\n", $template->output;

