#!/usr/bin/perl
# This script finds and fixes missing 090 fields in Koha for MARC21
#  Written by TG on 01/10/2005
#  Revised by Joshua Ferraro on 03/31/2006
use strict;
#use warnings; FIXME - Bug 2505
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


my $dbh = C4::Context->dbh;

my $sth=$dbh->prepare("select m.bibid,b.biblioitemnumber from marc_biblio m left join biblioitems b on b.biblionumber=m.biblionumber ");
	$sth->execute();

while (my ($biblionumber,$biblioitemnumber)=$sth->fetchrow ){
 my $record = MARCgetbiblio($dbh,$biblionumber);
		
		MARCmodleader($biblionumber,$record);
		
}

sub MARCmodleader{
my ($biblionumber,$record)=@_;

my $update=0;
#warn "".$record->leader();
#if (length($record->leader())>24){
#	$record->leader(substr($record->leader,0,24));	
#	$update =1;
#} elsif (length($record->leader())<24){
	$record->leader('     nac  22     1u 4500');
	$update=1;
#}

warn "leader : ".$record->leader if ($biblionumber==2262);
foreach ($record->field('995')) {
	$record->delete_field($_);
}
if ($update){	
	&ModBiblioMarc($record,'',$biblionumber);
	print "$biblionumber \n";	
}

}
END;
