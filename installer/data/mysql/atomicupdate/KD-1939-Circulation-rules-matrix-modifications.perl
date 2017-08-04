$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do("ALTER TABLE issuingrules
        ADD COLUMN ccode VARCHAR(10) NOT NULL DEFAULT '*' AFTER `itemtype`,
        ADD COLUMN permanent_location VARCHAR(80) NOT NULL DEFAULT '*' AFTER `ccode`,
    ");
    $dbh->do("ALTER TABLE issuingrules
        DROP INDEX issuingrules_selects,
        ADD UNIQUE KEY `issuingrules_selects` (`branchcode`,`categorycode`,`itemtype`,`ccode`,`permanent_location`),
        ADD KEY `ccode` (`ccode`),
        ADD KEY `permanent_location` (`permanent_location`)
    ");
    $dbh->do("UPDATE issuingrules SET ccode='*' WHERE ccode IS NULL");
    $dbh->do("UPDATE issuingrules SET permanent_location='*' WHERE permanent_location IS NULL");

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-1939 - Circulation rules matrix modifications)\n";
}
