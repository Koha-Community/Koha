$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
	    $dbh->do( "DELETE FROM collections_tracking WHERE itemnumber NOT IN (SELECT itemnumber FROM items WHERE items.itemnumber = collections_tracking.itemnumber);" );
	    $dbh->do( "ALTER TABLE collections_tracking ADD CONSTRAINT FOREIGN KEY `coltra-fk-items` (itemnumber) REFERENCES items (itemnumber);" );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18705 - collections tracking fk items)\n";
}


