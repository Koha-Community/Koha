#!/usr/bin/perl
# script that correct the marcxml  from in biblioitems 
#  Written by TG on 10/04/2006
use strict;

# Koha modules used

use C4::Context;
use C4::Biblio;
use MARC::Record;
use MARC::File::USMARC;
use MARC::File::XML;
use Time::HiRes qw(gettimeofday);

my $starttime = gettimeofday;
my $timeneeded;
my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare("select biblionumber,marc from biblioitems ");
	$sth->execute();
  $dbh->do("LOCK TABLES biblioitems WRITE");
my $i=0;
my $sth2 = $dbh->prepare("UPDATE biblioitems  set marcxml=? where biblionumber=?" );
   

while (my ($biblionumber,$marc)=$sth->fetchrow ){

 my $record = MARC::File::USMARC::decode($marc);
my $xml=$record->as_xml_record();
$sth2->execute($xml,$biblionumber);

	print "." unless ($i % 100);
$timeneeded = gettimeofday - $starttime unless ($i % 5000);
	print "$i records in $timeneeded s\n"  unless ($i % 5000);
	$i++;
}
$dbh->do("UNLOCK TABLES ");
$timeneeded = gettimeofday - $starttime ;
	print "$i records in $timeneeded s\n" ;

END;