$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if( !column_exists( 'currency', 'p_sep_by_space' ) ) {
        $dbh->do( "ALTER TABLE currency ADD COLUMN p_sep_by_space tinyint(1) default 0 after archived" );
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 4078: Add column currency.p_sep_by_space)\n";
}
