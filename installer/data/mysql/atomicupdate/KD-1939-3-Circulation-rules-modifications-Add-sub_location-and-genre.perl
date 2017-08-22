$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do("ALTER TABLE issuingrules
        ADD COLUMN sub_location VARCHAR(80) NOT NULL DEFAULT '*' AFTER `permanent_location`,
        ADD COLUMN genre VARCHAR(10) NOT NULL DEFAULT '*' AFTER `sub_location`
    ");
    $dbh->do("ALTER TABLE issuingrules
        DROP INDEX issuingrules_selects,
        ADD UNIQUE KEY `issuingrules_selects` (`branchcode`,`categorycode`,`itemtype`,`ccode`,`permanent_location`,`sub_location`,`genre`),
        ADD KEY `sub_location` (`sub_location`),
        ADD KEY `genre` (`genre`)
    ");
    $dbh->do("UPDATE issuingrules SET sub_location='*' WHERE sub_location IS NULL");
    $dbh->do("UPDATE issuingrules SET genre='*' WHERE genre IS NULL");

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-1939 - Circulation rules matrix modifications - Add sub_location and genre)\n";
}
