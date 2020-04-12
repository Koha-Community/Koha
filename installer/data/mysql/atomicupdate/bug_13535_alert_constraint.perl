$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    unless ( foreign_key_exists( 'alert', 'alert_ibfk_1' ) ) {
        $dbh->do(q|
            DELETE a FROM alert a
            LEFT JOIN borrowers b ON a.borrowernumber=b.borrowernumber
            WHERE b.borrowernumber IS NULL
        |);
        $dbh->do(
            qq{
            ALTER TABLE alert ADD CONSTRAINT alert_ibfk_1 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) ON UPDATE CASCADE ON DELETE CASCADE
              }
        );
    }
    NewVersion( $DBversion, 13535, "Add FK constraint on borrowernumber to alert table");
}
