$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

     if( !column_exists( 'illrequestattributes', 'readonly' ) ) {
        $dbh->do( "ALTER TABLE illrequestattributes ADD COLUMN readonly tinyint(1) NOT NULL DEFAULT 1" );
        $dbh->do( "UPDATE illrequestattributes SET readonly = 1" );
     }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20772 - Add illrequestattributes.readonly column)\n";
}
