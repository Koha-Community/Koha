$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "ALTER TABLE items MODIFY COLUMN uri MEDIUMTEXT" );
    $dbh->do( "ALTER TABLE deleteditems MODIFY COLUMN uri MEDIUMTEXT" );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20882 - items.uri to MEDIUMTEXT)\n";
}
