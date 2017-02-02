$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    unless( column_exists( 'branches', 'geolocation' ) ) {
        $dbh->do(q|
            ALTER TABLE branches ADD COLUMN geolocation VARCHAR(255) DEFAULT NULL after opac_info
        |);
    }

    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type ) VALUES ('UsageStatsGeolocation', '', NULL, 'Geolocation of the main library', 'Free');
    |);
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type ) VALUES ('UsageStatsLibrariesInfo', '', NULL, 'Share libraries information', 'YesNo');
    |);
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type ) VALUES ('UsageStatsPublicID', '', NULL, 'Public ID for Hea website', 'Free');
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18066 - Hea version 2)\n";
}
