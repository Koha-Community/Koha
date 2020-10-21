$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if( column_exists( 'auth_header', 'marc' ) ) {
        $dbh->do( "ALTER TABLE auth_header DROP COLUMN marc" );
    }

    NewVersion( $DBversion, 26684, "Drop marc column from auth_header");
}
