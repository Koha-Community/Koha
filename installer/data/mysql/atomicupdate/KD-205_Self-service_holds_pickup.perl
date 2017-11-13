$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    # $dbh->do( "ALTER TABLE biblio ADD COLUMN badtaste int" );

    $dbh->do("UPDATE borrowers SET othernames = NULL WHERE othernames = '';");
	$dbh->do("ALTER TABLE borrowers MODIFY COLUMN othernames VARCHAR(50);");
	$dbh->do("ALTER TABLE borrowers ADD UNIQUE (`othernames`);");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-205-SelfServiceHoldsPickup)\n";
}
