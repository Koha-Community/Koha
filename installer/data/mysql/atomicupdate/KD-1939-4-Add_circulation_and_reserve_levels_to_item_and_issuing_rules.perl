$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        ALTER TABLE items
            ADD COLUMN circulation_level varchar(10) DEFAULT NULL AFTER `sub_location`,
            ADD COLUMN reserve_level varchar(10) DEFAULT NULL AFTER `circulation_level`
    });
    $dbh->do(q{
        ALTER TABLE deleteditems
            ADD COLUMN circulation_level varchar(10) DEFAULT NULL AFTER `datereceived`,
            ADD COLUMN reserve_level varchar(10) DEFAULT NULL AFTER `circulation_level`
    });
    $dbh->do(q{
        INSERT INTO authorised_value_categories (category_name)
            VALUES ("CIRCULATION_LEVEL")
    });
    $dbh->do(q{
        INSERT INTO authorised_value_categories (category_name)
            VALUES ("RESERVE_LEVEL")
    });
    $dbh->do(q{
        ALTER TABLE issuingrules
            ADD COLUMN circulation_level varchar(10) DEFAULT '*' AFTER `genre`,
            ADD COLUMN reserve_level varchar(10) DEFAULT '*' AFTER `circulation_level`
    });
    $dbh->do("ALTER TABLE issuingrules
        DROP INDEX issuingrules_selects,
        ADD UNIQUE KEY `issuingrules_selects` (`branchcode`,`categorycode`,`itemtype`,`ccode`,`permanent_location`,`sub_location`,`genre`,`circulation_level`,`reserve_level`),
        ADD KEY `circulation_level` (`circulation_level`),
        ADD KEY `reserve_level` (`reserve_level`)
    ");
    $dbh->do("UPDATE issuingrules SET circulation_level='*' WHERE circulation_level IS NULL");
    $dbh->do("UPDATE issuingrules SET reserve_level='*' WHERE reserve_level IS NULL");

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-1939-4: Add circulation and reserve levels to items and issuing rules\n";
}
