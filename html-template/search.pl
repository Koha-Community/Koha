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
my $includes=$configfile{'includes'};
($includes) || ($includes="/usr/local/www/hdl/htdocs/includes");
my $templatebase="catalogue/searchresults.tmpl";
my $startfrom=$query->param('startfrom');
($startfrom) || ($startfrom=0);
my $theme=picktemplate($includes, $templatebase);




my $template = HTML::Template->new(filename => "$includes/templates/$theme/$templatebase", die_on_bad_params => 0, path => [$includes]);

##my @results;
#my $sth=$dbh->prepare("select * from biblio where author like 's%' order by author limit $startfrom,20");
#$sth->execute;
#while (my $data=$sth->fetchrow_hashref){    
#    push @results, $data;
#}

my $env;
$env->{itemcount}=1;
my %search;
my $keyword='tree';
$search{'keyword'}=$keyword;

my ($count, @results) = &KeywordSearch($env, 'intra', \%search, 20, $startfrom);


my $resultsarray=\@results;

$template->param(startfrom => $startfrom+1);
$template->param(endat => $startfrom+20);
$template->param(numrecords => $count);
my $nextstartfrom=($startfrom+20<$count-20) ? ($startfrom+20) : ($count-20);
my $prevstartfrom=($startfrom-20>0) ? ($startfrom-20) : (0);
$template->param(nextstartfrom => $nextstartfrom);
$template->param(prevstartfrom => $prevstartfrom);
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
