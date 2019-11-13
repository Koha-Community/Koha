$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if( !column_exists( 'suggestions', 'archived' ) ) {
        $dbh->do(q|
            ALTER TABLE suggestions ADD COLUMN archived INT(1) NOT NULL DEFAULT 0 AFTER `STATUS`;
        |);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22784 - Add a new suggestions.archived column)\n";
}
