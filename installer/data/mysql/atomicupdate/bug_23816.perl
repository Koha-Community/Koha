$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    # $dbh->do( "ALTER TABLE biblio ADD COLUMN badtaste int" );
    if( !column_exists( 'categories', 'min_password_length' ) ) {
        $dbh->do("ALTER TABLE categories ADD COLUMN `min_password_length` smallint(6) NULL DEFAULT NULL AFTER `change_password` -- set minimum password length for patrons in this category");
    }
    if( !column_exists( 'categories', 'require_strong_password' ) ) {
        $dbh->do("ALTER TABLE categories ADD COLUMN `require_strong_password` TINYINT(1) NULL DEFAULT NULL AFTER `min_password_length` -- set required password strength for patrons in this category");
    }

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 23816, "Add min_password_length and require_strong_password columns in categories table");
}
