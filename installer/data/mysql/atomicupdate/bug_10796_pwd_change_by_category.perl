$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    if ( !column_exists( 'categories', 'change_password' ) ) {
        $dbh->do(q{
            ALTER TABLE categories
                ADD COLUMN change_password TINYINT(1) NULL DEFAULT NULL
                AFTER reset_password
        });
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 10796 - Patron password change by category)\n";
}
