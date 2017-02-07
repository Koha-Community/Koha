$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "ALTER TABLE branches ADD COLUMN pickup_location TINYINT(1) not null default 1" );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 7534 - Let libraries have configuration for pickup locations)\n";
}
