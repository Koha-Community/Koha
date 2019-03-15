$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    if ( column_exists( 'accountlines', 'lastincrement' ) ) {
        $dbh->do("ALTER TABLE `accountlines` DROP COLUMN `lastincrement`");
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22516 - Drop deprecated accountlines.lastincrement field)\n";
}
