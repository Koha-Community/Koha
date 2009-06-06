#!/usr/bin/perl
# This script finds and fixes missing 090 fields in Koha for MARC21
#  Written by TG on 01/10/2005
#  Revised by Joshua Ferraro on 03/31/2006
use strict;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../../kohalib.pl" };
}

# Koha modules used

use C4::Context;
use C4::Biblio;
use MARC::Record;
use MARC::File::USMARC;

$|=1;
my $dbh = C4::Context->dbh;

my $sth=$dbh->prepare("select m.biblionumber,b.biblioitemnumber from biblio m left join biblioitems b on b.biblionumber=m.biblionumber");
$sth->execute();

my $i=1;
while (my ($biblionumber,$biblioitemnumber)=$sth->fetchrow ){
 my $record = GetMarcBiblio($biblionumber);
    print ".";
    print "\r$i" unless $i %100;
    MARCmodbiblionumber($biblionumber,$biblioitemnumber,$record);
}

sub MARCmodbiblionumber{
    my ($biblionumber,$biblioitemnumber,$record)=@_;
    
    my ($tagfield,$biblionumtagsubfield) = &GetMarcFromKohaField("biblio.biblionumber","");
    my ($tagfield2,$biblioitemtagsubfield) = &GetMarcFromKohaField("biblio.biblioitemnumber","");
        
    my $update=0;
    if (defined $record) {
        my $tag = $record->field($tagfield);
        #warn "ICI : ".$record->as_formatted if $record->subfield('090','a') eq '11546';
    
        # check that we have biblionumber at the right place, otherwise, update or create the field.
        if ($tagfield <10) {
            unless ($tag && $tag->data() == $biblionumber) {
                if ($tag) {
                    $tag->update($biblionumber);
                } else {
                    my $newrec = MARC::Field->new( $tagfield, $biblionumber);
                    $record->insert_fields_ordered($newrec);
                }
                $update=1;
            }
        } else {
            unless ($tag && $tag->subfield($biblionumtagsubfield) == $biblionumber) {
                if($tag) {
                    $tag->update($tagfield => $biblionumber);
                } else {
                    my $newrec = MARC::Field->new( $tagfield,'','', $biblionumtagsubfield => $biblionumber,$biblioitemtagsubfield=>$biblioitemnumber);
                    $record->insert_fields_ordered($newrec);
                }
                $update=1;
            }
        }
    } else {
        warn "problem with :".$biblionumber." , record undefined";
    }


    if ($update){
        &ModBiblioMarc($record,$biblionumber,'');
        print "\n modified : $biblionumber \n";
    }
    
}
END;
