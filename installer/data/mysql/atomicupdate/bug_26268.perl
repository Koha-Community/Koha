$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    if ( column_exists( 'items', 'paidfor' ) ) {
        my ($count) = $dbh->selectrow_array(
            qq|
                SELECT COUNT(*)
                FROM items
                WHERE paidfor IS NOT NULL AND paidfor <> ""
            |
        );
        if ($count) {
            warn "Warning - Cannot remove column items.paidfor. At least one value exists";
        }
        else {
            $dbh->do(q|ALTER TABLE items DROP COLUMN paidfor|);
            $dbh->do(q|UPDATE marc_subfield_structure SET kohafield = '' WHERE kohafield = 'items.paidfor'|);
        }
    }

    if ( column_exists( 'deleteditems', 'paidfor' ) ) {
        my ($count) = $dbh->selectrow_array(
            qq|
                SELECT COUNT(*)
                FROM items
                WHERE paidfor IS NOT NULL AND paidfor <> ""
            |
        );
        if ($count) {
            warn "Warning - Cannot remove column deleteditems.paidfor. At least one value exists";
        }
        else {
            $dbh->do(q|ALTER TABLE deleteditems DROP COLUMN paidfor|);
        }
    }

    NewVersion( $DBversion, 26268, "Remove items.paidfor field" );
}
