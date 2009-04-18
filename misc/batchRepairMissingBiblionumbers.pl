#!/usr/bin/perl
# This script finds and fixes missing biblionumber/biblioitemnumber fields in Koha
#  Written by TG on 01/10/2005
#  Revised by Joshua Ferraro on 03/31/2006
use strict;
use warnings;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}

# Koha modules used

use C4::Context;
use C4::Biblio;


my $dbh = C4::Context->dbh;
my %kohafields;

my $sth=$dbh->prepare("SELECT biblio.biblionumber, biblioitemnumber, frameworkcode FROM biblio JOIN biblioitems USING (biblionumber)");
$sth->execute();

while (my ($biblionumber,$biblioitemnumber,$frameworkcode)=$sth->fetchrow ){
    my $record = GetMarcBiblio($biblionumber);
    C4::Biblio::_koha_marc_update_bib_ids($record, $frameworkcode, $biblionumber, $biblioitemnumber);
    my $biblionumber = eval {ModBiblioMarc( $record, $biblionumber, $frameworkcode )};
    if($@){
        print "Problem with biblionumber : $biblionumber\n";
        exit -1;
    }else{
        print "biblionumber : $biblionumber\r\r";
    }
}

END;
