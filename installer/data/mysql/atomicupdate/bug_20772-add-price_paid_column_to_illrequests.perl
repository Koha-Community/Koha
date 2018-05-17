$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

     if( !column_exists( 'illrequests', 'price_paid' ) ) {
        $dbh->do( "ALTER TABLE illrequests ADD COLUMN price_paid varchar(20) DEFAULT NULL" );
     }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20772 - Add illrequest.price_paid column)\n";
}
