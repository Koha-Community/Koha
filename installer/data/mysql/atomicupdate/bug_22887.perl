$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    unless ( index_exists('authorised_values', 'av_uniq') ) {
        $dbh->do(q|
            DELETE FROM authorised_values
            WHERE category="COUNTRY" AND authorised_value="CC" AND lib="Keeling"
        |);
        my $duplicates = $dbh->selectall_arrayref(q|
            SELECT category, authorised_value, COUNT(concat(category, ':', authorised_value)) AS c
            FROM authorised_values
            GROUP BY category, authorised_value
            HAVING c > 1
        |, { Slice => {} });
        if ( @$duplicates ) {
            warn "WARNING - Cannot create unique constraint on authorised_value(category, authorised_value)\n";
            warn "The following entries are duplicated: " . join (', ', map { sprintf "%s:%s (%s)", $_->{category}, $_->{authorised_value}, $_->{c} } @$duplicates);
        } else {
            $dbh->do( q{ALTER TABLE `authorised_values` ADD CONSTRAINT `av_uniq` UNIQUE (category, authorised_value)} );
        }
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22887 - Add unique constraint to authorised_values)\n";
}
