#!/usr/bin/perl

use C4::Context;

my $dbh = C4::Context->dbh;
my $DBversion = "XXX";

# RM: Copy/paste from here, and uncomment

#if ( CheckVersion($DBversion) ) {
    # this should normally not be needed, but just in case
    my ( $cnt ) = $dbh->selectrow_array( q|
SELECT COUNT(*) FROM items it
LEFT JOIN biblio bi ON bi.biblionumber=it.biblionumber
LEFT JOIN biblioitems bii USING (biblioitemnumber)
WHERE bi.biblionumber IS NULL
    |);
    if( $cnt ) {
        print "WARNING: You have corrupted data in your items table!! The table contains $cnt references to biblio records that do not exist.\nPlease correct your data IMMEDIATELY after this upgrade and manually add the foreign key constraint for biblionumber in the items table.\n";
    } else {
        # now add FK
        $dbh->do( q|
ALTER TABLE items
ADD FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
        |);
        print "Upgrade to $DBversion done (Bug 1xxxx - Add FK for biblionumber in items)\n";
    }
    #SetVersion($DBversion);
#}
