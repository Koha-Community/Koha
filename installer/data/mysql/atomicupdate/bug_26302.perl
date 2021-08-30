$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES
            ('ResultsMaxItems','1','','Maximum number of available items displayed in search results','Integer'),
            ('ResultsMaxItemsUnavailable','0','','Maximum number of unavailable items displayed in search results','Integer')
    |);
    NewVersion( $DBversion, 26302, "Add preferences ResultsMaxItems and ResultsMaxItemsUnavailable");
}
