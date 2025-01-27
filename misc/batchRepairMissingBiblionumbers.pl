#!/usr/bin/perl
# This script finds and fixes missing biblionumber/biblioitemnumber fields in Koha
#  Written by TG on 01/10/2005
#  Revised by Joshua Ferraro on 03/31/2006
use strict;
use warnings;

# Koha modules used
use Koha::Script;
use C4::Context;
use C4::Biblio qw( ModBiblioMarc );
use Koha::Biblios;

my $dbh = C4::Context->dbh;

my $sth = $dbh->prepare(
    "SELECT biblio.biblionumber, biblioitemnumber, frameworkcode FROM biblio JOIN biblioitems USING (biblionumber)");
$sth->execute();

while ( my ( $biblionumber, $biblioitemnumber, $frameworkcode ) = $sth->fetchrow ) {
    my $biblio = Koha::Biblios->find($biblionumber);
    my $record = $biblio->metadata->record;
    C4::Biblio::_koha_marc_update_bib_ids( $record, $frameworkcode, $biblionumber, $biblioitemnumber );
    my $biblionumber = eval { ModBiblioMarc( $record, $biblionumber ) };
    if ($@) {
        print "Problem with biblionumber : $biblionumber\n";
        exit -1;
    } else {
        print "biblionumber : $biblionumber\r\r";
    }
}

END;
