$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    if ( !column_exists( 'accountlines', 'payment_type' ) ) {
        $dbh->do( "ALTER TABLE accountlines ADD `payment_type` varchar(80) default NULL AFTER accounttype" );
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18786 - Add ability to create custom payment types)\n";
}
