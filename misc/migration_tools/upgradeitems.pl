#!/usr/bin/perl

use strict;
#use warnings; FIXME - Bug 2505
use  C4::Context;
use C4::Items;
use C4::Biblio;

my $dbh=C4::Context->dbh;

if (C4::Context->preference("marcflavour") ne "UNIMARC") {
    print "this script is for UNIMARC only\n";
    exit;
}
my $rqbiblios=$dbh->prepare("SELECT biblionumber from biblioitems");
my $rqitemnumber=$dbh->prepare("SELECT itemnumber, biblionumber from items where itemnumber = ? and biblionumber = ?");

$rqbiblios->execute;
$|=1;
while (my ($biblionumber)= $rqbiblios->fetchrow_array){
    my $record=GetMarcBiblio($biblionumber);
    foreach my $itemfield ($record->field('995')){
        my $marcitem=MARC::Record->new();
        $marcitem->encoding('UTF-8');
        $marcitem->append_fields($itemfield);    

	
	my $itemnum;
	my @itemnumbers = $itemfield->subfield('9');
        foreach my $itemnumber ( @itemnumbers ){
		$rqitemnumber->execute($itemnumber, $biblionumber);
		if( my $row = $rqitemnumber->fetchrow_hashref ){
			$itemnum = $row->{itemnumber};
		}
        }

        eval{
		if($itemnum){
			ModItemFromMarc($marcitem,$biblionumber,$itemnum)
		}else{
			die("$biblionumber");
		}
        };
        print "\r$biblionumber";
       if ($@){
            warn "Problem with : $biblionumber : $@";
            warn $record->as_formatted;
       }    
    }  
}
