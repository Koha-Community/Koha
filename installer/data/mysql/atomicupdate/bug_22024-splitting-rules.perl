$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {


    # On a new installation the class_sources.sql will have failed, so we need to add all missing data

    my( $sort_cnt ) = $dbh->selectrow_array( q|SELECT COUNT(*) FROM class_sort_rules|);
    if( !$sort_cnt ) {
        $dbh->do(q|INSERT INTO `class_sort_rules` (`class_sort_rule`, `description`, `sort_routine`) VALUES
                               ('dewey', 'Default filing rules for DDC', 'Dewey'),
                               ('lcc', 'Default filing rules for LCC', 'LCC'),
                               ('generic', 'Generic call number filing rules', 'Generic')
            |);
    }

    my ( $split_cnt ) = $dbh->selectrow_array( q|SELECT COUNT(*) FROM class_split_rules|);
    if( !$split_cnt ) {
        $dbh->do(q|INSERT INTO `class_split_rules` (`class_split_rule`, `description`, `split_routine`) VALUES
                               ('dewey', 'Default splitting rules for DDC', 'Dewey'),
                               ('lcc', 'Default splitting rules for LCC', 'LCC'),
                               ('generic', 'Generic call number splitting rules', 'Generic')
            |);
    }

    my( $source_cnt ) = $dbh->selectrow_array( q|SELECT COUNT(*) FROM class_sources|);
    if( !$source_cnt ) {
        $dbh->do(q|INSERT INTO `class_sources` (`cn_source`, `description`, `used`, `class_sort_rule`, `class_split_rule`) VALUES
                            ('ddc', 'Dewey Decimal Classification', 1, 'dewey', 'dewey'),
                            ('lcc', 'Library of Congress Classification', 1, 'lcc', 'lcc'),
                            ('udc', 'Universal Decimal Classification', 0, 'generic', 'generic'),
                            ('sudocs', 'SuDoc Classification (U.S. GPO)', 0, 'generic', 'generic'),
                            ('anscr', 'ANSCR (Sound Recordings)', 0, 'generic', 'generic'),
                            ('z', 'Other/Generic Classification Scheme', 0, 'generic', 'generic')
            |);

    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22024 - Add missing splitting rule definitions)\n";
}
