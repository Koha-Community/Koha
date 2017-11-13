$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    $dbh->do( "ALTER TABLE `issuingrules` DROP PRIMARY KEY" );
    $dbh->do( "ALTER TABLE `issuingrules` ADD `issuingrules_id` INT( 11 ) NOT NULL auto_increment PRIMARY KEY FIRST" );
    $dbh->do( "ALTER TABLE `issuingrules` ADD CONSTRAINT UNIQUE `issuingrules_selects` (`branchcode`,`categorycode`,`itemtype`)" );

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18231 - id to issuing rules table)\n";
}
