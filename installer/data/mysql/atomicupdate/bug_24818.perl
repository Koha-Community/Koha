$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do( "ALTER TABLE accountlines MODIFY COLUMN date TIMESTAMP NULL" );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24818: Update 'accountlines.date' from DATE to TIMESTAMP)\n";
}
