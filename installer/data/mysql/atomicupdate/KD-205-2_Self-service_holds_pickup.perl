$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:

    $dbh->do("UPDATE deletedborrowers SET othernames = NULL WHERE othernames = '';");
	$dbh->do("ALTER TABLE deletedborrowers MODIFY COLUMN othernames VARCHAR(50);");
	$dbh->do("ALTER TABLE deletedborrowers ADD UNIQUE (`othernames`);");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-205-2-SelfServiceHoldsPickup)\n";
}
