#!/usr/bin/perl -w
use HTML::Template;
use strict;
require Exporter;
use C4::Database;
use CGI;
use C4::Search;
 
my $query=new CGI;

# temporary variable for testing. Replace from /etc/koha.conf

my $templatedir="/usr/share/koha/intranet/htdocs/includes/templates";

my $templatename=$query->param('template');
my $startfrom=$query->param('startfrom');
($startfrom) || ($startfrom=0);
($templatename) || ($templatename="$templatedir/searchresults.tmpl");


my $dbh=&C4Connect;  


my $template = HTML::Template->new(filename => $templatename, die_on_bad_params => 0);

##my @results;
#my $sth=$dbh->prepare("select * from biblio where author like 's%' order by author limit $startfrom,20");
#$sth->execute;
#while (my $data=$sth->fetchrow_hashref){    
#    push @results, $data;
#}

my $blah;
my %search;
my $keyword='bear';
$search{'keyword'}=$keyword;

my ($count, @results) = &KeywordSearch(\$blah, 'intra', \%search, 20, $startfrom);
my $resultshash=\@results;



$template->param(startfrom => $startfrom);
$startfrom+=20;
$template->param(nextstartfrom => $startfrom);
$template->param(template => $templatename);
$template->param(SEARCH_RESULTS => $resultshash);

print "Content-Type: text/html\n\n", $template->output;
