$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
     $dbh->do( "ALTER TABLE auth_header DROP COLUMN marc" );

    NewVersion( $DBversion, XXXXX, "Drop marc column from auth_header");
}
