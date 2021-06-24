$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES
            ('resultsMaxItems','2','','Maximum number of available items displayed in search results','Integer'),
            ('resultsMaxItemsUnavailable','1','','Maximum number of unavailable items displayed in search results','Integer')
    |);
    NewVersion( $DBversion, 26302, "Add preferences resultsMaxItems and resultsMaxItemsUnavailable");
}
