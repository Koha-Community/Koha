$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
INSERT IGNORE INTO  systempreferences (variable, value, options, explanation, type) VALUES ('ArticleRequestsLinkControl', 'always', 'always\|calc', 'Control display of article request link on search results', 'Choice')
    |);
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17530 - Add pref ArticleRequestsLinkControl)\n";
}
