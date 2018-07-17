$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
        ALTER TABLE opac_news
        CHANGE COLUMN timestamp publicationdate date DEFAULT NULL,
        ADD COLUMN updated_on timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    |);
    NewVersion( $DBversion, 21066, "Update table opac_news");
}
