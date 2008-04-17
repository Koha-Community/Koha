#!/usr/bin/perl

use strict;
use  C4::Context;
use C4::Items;
use C4::Biblio;

my $dbh=C4::Context->dbh;

if (C4::Context->preference("marcflavour") ne "UNIMARC" {
    print "this script is for UNIMARC only\n";
    exit;
}
my $rqbiblios=$dbh->prepare("SELECT biblionumber from biblioitems");
$rqbiblios->execute;
$|=1;
while (my ($biblionumber)= $rqbiblios->fetchrow_array){
    my $record=GetMarcBiblio($biblionumber);
    foreach my $itemfield ($record->field('995')){
        my $marcitem=MARC::Record->new();
        $marcitem->encoding('UTF-8');
        $marcitem->append_fields($itemfield);    
        eval{ModItemFromMarc($marcitem,$biblionumber,$itemfield->subfield('9'));};
        print "\r$biblionumber";
       if ($@){
            warn "$biblionumber : $@";
            warn $record->as_formatted;
       }    
    }  
}