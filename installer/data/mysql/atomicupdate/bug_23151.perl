$DBversion = 'XXX';
if ( CheckVersion( $DBversion ) ) {
    unless ( column_exists( 'borrower_modifications', 'changed_fields' ) ) {
        $dbh->do("ALTER TABLE borrower_modifications ADD changed_fields MEDIUMTEXT AFTER verification_token;");
    }
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23151 - Add borrower_modifications.changed_fields column)\n";
}
