#!/usr/bin/perl -w
use HTML::Template;
use strict;
require Exporter;
use C4::Database;


my $dbh=&C4Connect;  


my $template = HTML::Template->new(filename => 'searchresults.tmpl', die_on_bad_params => 0);

my @results;
my $sth=$dbh->prepare("select * from biblio where author like 's%' limit 20");
$sth->execute;
while (my $data=$sth->fetchrow_hashref){    
    push @results, $data;
}




$template->param(SEARCH_RESULTS => \@results
		);


print "Content-Type: text/html\n\n", $template->output;
