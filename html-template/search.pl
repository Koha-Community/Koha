#!/usr/bin/perl -w
use HTML::Template;
use strict;
require Exporter;
use C4::Database;
use CGI;
 
my $query=new CGI;

my $template=$query->param('template');
($template) || ($template='searchresults.tmpl');


my $dbh=&C4Connect;  


my $template = HTML::Template->new(filename => $template, die_on_bad_params => 0);

my @results;
my $sth=$dbh->prepare("select * from biblio where author like 's%' limit 20");
$sth->execute;
while (my $data=$sth->fetchrow_hashref){    
    push @results, $data;
}




$template->param(SEARCH_RESULTS => \@results
		);


print "Content-Type: text/html\n\n", $template->output;
