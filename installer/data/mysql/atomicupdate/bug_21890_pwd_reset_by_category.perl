$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    if ( !column_exists( 'categories', 'reset_password' ) ) {
        $dbh->do(q{
            ALTER TABLE categories
                ADD COLUMN reset_password TINYINT(1) NULL DEFAULT NULL
                AFTER checkprevcheckout
        });
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21890 - Patron password reset by category)\n";
}
