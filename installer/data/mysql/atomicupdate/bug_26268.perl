$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    if( !column_exists( 'items', 'paidfor' ) ) {
       $dbh->do(q|ALTER TABLE items DROP COLUMN paidfor|);
       $dbh->do(q|ALTER TABLE deleteditems DROP COLUMN paidfor|);
    }

    NewVersion( $DBversion, 26268, "Remove items.paidfor field");
}
