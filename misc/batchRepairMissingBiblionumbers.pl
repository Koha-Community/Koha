#!/usr/bin/perl
# This script finds and fixes missing biblionumber/biblioitemnumber fields in Koha
#  Written by TG on 01/10/2005
#  Revised by Joshua Ferraro on 03/31/2006
use strict;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}

# Koha modules used

use C4::Context;
use C4::Biblio;
use MARC::Record;
use MARC::File::USMARC;


my $dbh = C4::Context->dbh;

my $sth=$dbh->prepare("select m.biblionumber,b.biblioitemnumber from marc_biblio m left join biblioitems b on b.biblionumber=m.biblionumber ");
    $sth->execute();

while (my ($biblionumber,$biblioitemnumber)=$sth->fetchrow ){
 my $record = GetMarcBiblio($biblionumber);
    
        MARCmodbiblionumber($biblionumber,$biblioitemnumber,$record);
    
}

sub MARCmodbiblionumber{
my ($biblionumber,$biblioitemnumber,$record)=@_;

my ($tagfield,$biblionumtagsubfield) = &GetMarcFromKohaField("biblio.biblionumber","");
my ($tagfield2,$biblioitemtagsubfield) = &GetMarcFromKohaField("biblio.biblioitemnumber","");
    
my $update=0;
      my @tags = $record->field($tagfield);

if (!@tags){
         
my $newrec = MARC::Field->new( $tagfield,'','', $biblionumtagsubfield => $biblionumber,$biblioitemtagsubfield=>$biblioitemnumber);
    $record->append_fields($newrec);
 $update=1;
    }

 
if ($update){    
&ModBiblioMarc($record,'',$biblionumber);
    print "$biblionumber \n";
    }

}
END;
