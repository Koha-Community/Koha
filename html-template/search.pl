#!/usr/bin/perl -w
use HTML::Template;
use strict;
require Exporter;
use C4::Database;
use CGI;
 
my $query=new CGI;

my $templatename=$query->param('template');
my $startfrom=$query->param('startfrom');
($startfrom) || ($startfrom=0);
($templatename) || ($templatename='searchresults.tmpl');


my $dbh=&C4Connect;  


print STDERR "SF: $startfrom\n";
my $template = HTML::Template->new(filename => $templatename, die_on_bad_params => 0);

my @results;
my $sth=$dbh->prepare("select * from biblio where author like 's%' order by author limit $startfrom,20");
$sth->execute;
while (my $data=$sth->fetchrow_hashref){    
    push @results, $data;
}



$startfrom+=20;
$template->param(startfrom => $startfrom);
$template->param(template => $templatename);
$template->param(SEARCH_RESULTS => \@results);

print "Content-Type: text/html\n\n", $template->output;
