$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "ALTER TABLE oai_sets_mappings ADD COLUMN rule_order INT AFTER set_id, ADD COLUMN rule_operator VARCHAR(3) AFTER rule_order" );
    $dbh->do( "UPDATE oai_sets_mappings SET rule_operator='or'" );
    my $sets = $dbh->selectall_arrayref("SELECT * from oai_sets_mappings ORDER BY set_id", { Slice => {} });
    my $i = 0;
    my $previous_set_id;
    for my $set ( @{$sets}) {
        my $set_id = $set->{set_id};

        if ($previous_set_id && $previous_set_id != $set_id) {
            $i = 0;
        }

        if ($i == 0) {
            $dbh->do("UPDATE oai_sets_mappings SET rule_operator=NULL WHERE set_id=? LIMIT 1", {}, $set_id);
        }

        $dbh->do("UPDATE oai_sets_mappings SET rule_order=? WHERE set_id=? AND rule_order IS NULL LIMIT 1", {}, $i, $set_id);

        $i++;
        $previous_set_id = $set_id;
    }

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21520 - Add rule_order and rule_operator fields to oai_sets_mappings table)\n";
}
