$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    unless ( column_exists('article_requests', 'format') ) {
        $dbh->do(q|
            ALTER TABLE article_requests
            ADD COLUMN `format` enum('PHOTOCOPY', 'SCAN') NOT NULL DEFAULT 'PHOTOCOPY' AFTER notes
        |);
    }
    unless ( column_exists('article_requests', 'urls') ) {
        $dbh->do(q|
            ALTER TABLE article_requests
            ADD COLUMN `urls` MEDIUMTEXT AFTER format
        |);
    }
    NewVersion( $DBversion, 20472, "Add columns format and urls in article_requests table");
}
