$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if( !column_exists( 'z3950servers', 'attributes' ) ) {
        $dbh->do( "ALTER TABLE z3950servers ADD COLUMN attributes VARCHAR(255) after add_xslt" );
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 11297 - Add support for custom PQF attributes for Z39.50 server searches)\n";
}
