$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if( column_exists( 'opac_news', 'timestamp' ) ) {
        $dbh->do(q|
            ALTER TABLE opac_news
            CHANGE COLUMN timestamp publicationdate date DEFAULT NULL
        |);
    }
    if( !column_exists( 'opac_news', 'updated_on' ) ) {
        $dbh->do(q|
            ALTER TABLE opac_news
            ADD COLUMN updated_on timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER publicationdate
        |);
    }
    NewVersion( $DBversion, 21066, "Update table opac_news");
}
