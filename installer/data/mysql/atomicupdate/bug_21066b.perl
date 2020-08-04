$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
        UPDATE letter
        SET content = REPLACE(content,?,?)
        WHERE content LIKE ?
    |, undef, 'opac_news.timestamp', 'opac_news.publicationdate', '%opac_news.timestamp%' );
    NewVersion( $DBversion, 21066, "Replace timestamp references in letters table");
}
