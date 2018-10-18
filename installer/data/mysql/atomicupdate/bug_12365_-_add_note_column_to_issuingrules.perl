$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    unless( column_exists( 'issuingrules', 'note' ) ) {
        $dbh->do(q|ALTER TABLE `issuingrules` ADD `note` varchar(100) default NULL AFTER `article_requests`|);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 12365: Add column issuingrules.note)\n";
}
