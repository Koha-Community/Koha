$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if ( foreign_key_exists( 'return_claims', 'issue_id' ) ) {
        $dbh->do(q{
            ALTER TABLE return_claims DROP FOREIGN KEY issue_id
        });
    }

    NewVersion( $DBversion, 29495, "Issue link is lost in return claims when using 'MarkLostItemsAsReturned'");
}
