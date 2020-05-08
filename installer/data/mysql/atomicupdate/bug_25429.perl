$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('CleanUpDatabaseReturnClaims', '', '', 'Sets the age of resolved return claims to delete from the database for cleanup_database.pl', 'Integer' );
    });

    NewVersion( $DBversion, 25429, "Cleanup Database - remove resolved claims returned from db after X days");
}
