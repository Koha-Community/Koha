$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    if ( !column_exists( 'illrequests', 'status_alias' ) ) {
        # Fresh upgrade, just add the column and constraint
        $dbh->do( "ALTER TABLE illrequests ADD COLUMN status_alias varchar(80) DEFAULT NULL AFTER status" );
    } else {
        # Migrate all existing foreign keys from referencing authorised_values.id
        # to referencing authorised_values.authorised_value
        # First remove the foreign key constraint and index
        if ( foreign_key_exists( 'illrequests', 'illrequests_safk' ) ) {
            $dbh->do( "ALTER TABLE illrequests DROP FOREIGN KEY illrequests_safk");
        }
        if ( index_exists( 'illrequests', 'illrequests_safk' ) ) {
            $dbh->do( "DROP INDEX illrequests_safk IN illrequests" );
        }
        # Now change the illrequests.status_alias column definition from int to varchar
        $dbh->do( "ALTER TABLE illrequests MODIFY COLUMN status_alias varchar(80)" );
        # Now replace all references to authorised_values.id with their
        # corresponding authorised_values.authorised_value
        my $sth = $dbh->prepare( "SELECT illrequest_id, status_alias FROM illrequests WHERE status_alias IS NOT NULL" );
        $sth->execute();
        while (my @row = $sth->fetchrow_array()) {
            my $r_id = $row[0];
            my $av_id = $row[1];
            # Get the authorised value's authorised_value value
            my ($av_val) = $dbh->selectrow_array( "SELECT authorised_value FROM authorised_values WHERE id = ?", {}, $av_id );
            # Now update illrequests.status_alias
            if ($av_val) {
                $dbh->do( "UPDATE illrequests SET status_alias = ? WHERE illrequest_id = ?", {}, ($av_val, $r_id) );
            }
        }
    }
    if ( !foreign_key_exists( 'illrequests', 'illrequests_safk' ) ) {
        $dbh->do( "ALTER TABLE illrequests ADD CONSTRAINT illrequests_safk FOREIGN KEY (status_alias) REFERENCES authorised_values(authorised_value) ON UPDATE CASCADE ON DELETE SET NULL" );
    }
    $dbh->do( "INSERT IGNORE INTO authorised_value_categories SET category_name = 'ILLSTATUS'");

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20581 - Allow manual selection of custom ILL request statuses)\n";
}
