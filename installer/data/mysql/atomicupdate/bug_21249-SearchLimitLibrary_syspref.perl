$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES ('SearchLimitLibrary', 'both', 'homebranch|holdingbranch|both', "When limiting search results with a library or library group, use the item's home library, or holding library, or both.", 'Choice')});

    NewVersion( $DBversion, 21249, "Adding SearchLimitLibrary system preference" );
}
