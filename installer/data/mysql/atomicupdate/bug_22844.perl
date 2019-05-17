$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    if( !column_exists( 'borrower_attribute_types', 'mandatory' ) ) {
        $dbh->do(q|
            ALTER TABLE borrower_attribute_types
            ADD COLUMN mandatory TINYINT(1) NOT NULL DEFAULT 0
            AFTER keep_for_pseudonymization
        |);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - Add borrower_attribute_types.mandatory)\n";
}
