#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;
use C4::Koha;
use CGI;
use C4::Search;
use C4::Acquisitions;
use C4::Output; # contains picktemplate
  
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

my $includes=$configfile{'includes'};
($includes) || ($includes="/usr/local/www/hdl/htdocs/includes");
my $templatebase="catalogue/moredetail.tmpl";
my $startfrom=$query->param('startfrom');
($startfrom) || ($startfrom=0);
my $theme=picktemplate($includes, $templatebase);

my $subject=$query->param('subject');
# if its a subject we need to use the subject.tmpl
if ($subject){
  $templatebase=~ s/searchresults\.tmpl/subject\.tmpl/;
}
my $template = HTML::Template->new(filename => "$includes/templates/$theme/$templatebase", die_on_bad_params => 0, path => [$includes]);

# get variables 

my $biblionumber=$query->param('bib');
my $title=$query->param('title');
my $bi=$query->param('bi');

my $data=bibitemdata($bi);
my $dewey = $data->{'dewey'};
$dewey =~ s/0+$//;
if ($dewey eq "000.") { $dewey = "";};
if ($dewey < 10){$dewey='00'.$dewey;}
if ($dewey < 100 && $dewey > 10){$dewey='0'.$dewey;}
if ($dewey <= 0){
      $dewey='';
}
$dewey=~ s/\.$//;
$data->{'dewey'}=$dewey;

my @results;

my (@items)=itemissues($bi);
my $count=@items;
$data->{'count'}=$count;
my ($order,$ordernum)=getorder($bi,$biblionumber);

my $env;
$env->{itemcount}=1;

$results[0]=$data;

$template->param(includesdir => $includes);
$template->param(BIBITEM_DATA => \@results);
$template->param(ITEM_DATA => \@items);
print "Content-Type: text/html\n\n", $template->output;

