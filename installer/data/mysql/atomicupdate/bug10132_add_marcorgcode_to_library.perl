$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    if( !column_exists( 'branches', 'marcorgcode' ) ) {
        $dbh->do( "ALTER TABLE branches ADD COLUMN marcorgcode VARCHAR(16) default NULL AFTER geolocation" );
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 10132 -  MARCOrgCode on branch level)\n";
}
