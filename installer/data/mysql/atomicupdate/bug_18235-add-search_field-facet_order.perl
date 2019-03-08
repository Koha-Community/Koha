$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if( !column_exists( 'search_field', 'facet_order' ) ) {
        $dbh->do("ALTER TABLE search_field ADD COLUMN facet_order TINYINT(4) DEFAULT NULL AFTER weight");
    }

    $dbh->do("UPDATE search_field SET facet_order=1 WHERE name='author'");
    $dbh->do("UPDATE search_field SET facet_order=2 WHERE name='itype'");
    $dbh->do("UPDATE search_field SET facet_order=3 WHERE name='location'");
    $dbh->do("UPDATE search_field SET facet_order=4 WHERE name='su-geo'");
    $dbh->do("UPDATE search_field SET facet_order=5 WHERE name='title-series'");
    $dbh->do("UPDATE search_field SET facet_order=6 WHERE name='subject'");
    $dbh->do("UPDATE search_field SET facet_order=7 WHERE name='ccode'");
    $dbh->do("UPDATE search_field SET facet_order=8 WHERE name='holdingbranch'");
    $dbh->do("UPDATE search_field SET facet_order=9 WHERE name='homebranch'");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18235 - Elastic search - make facets configurable)\n";
}
