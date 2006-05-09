#!/usr/bin/perl

# script to shift marc to biblioitems
# scraped from updatedatabase for dev week by chris@katipo.co.nz

use C4::Context;
use C4::Biblio;
use MARC::Record;
use MARC::File::XML ( BinaryEncoding => 'utf8' );

print "moving MARC record to biblioitems table\n";

my $dbh = C4::Context->dbh();
# changing marc field type
$dbh->do('ALTER TABLE biblioitems CHANGE marc marc BLOB NULL DEFAULT NULL ');

# adding marc xml, just for convenience
$dbh->do(
'ALTER TABLE biblioitems ADD marcxml TEXT CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL '
);

# moving data from marc_subfield_value to biblio
$sth = $dbh->prepare('select bibid,biblionumber from marc_biblio');
$sth->execute;
my $sth_update =
  $dbh->prepare(
    'update biblioitems set marc=? where biblionumber=?');
my $totaldone = 0;
while ( my ( $bibid, $biblionumber ) = $sth->fetchrow ) {
    my $record = MARCgetbiblio( $dbh, $bibid );

    #Force UTF-8 in record leader
    $record->encoding('UTF-8');
    $sth_update->execute( $record->as_usmarc(), $record->as_xml_record(),
        $biblionumber );
    $totaldone++;
    print "\r$totaldone / $totaltodo" unless ( $totaldone % 100 );
}
print "\rdone\n";
