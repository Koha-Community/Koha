$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do('DROP TABLE IF EXISTS branches_overdrive');
    $dbh->do( q|
        CREATE TABLE IF NOT EXISTS branches_overdrive (
            `branchcode` VARCHAR( 10 ) NOT NULL ,
            `authname` VARCHAR( 255 ) NOT NULL ,
            PRIMARY KEY (`branchcode`) ,
            CONSTRAINT `branches_overdrive_ibfk_1` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE = INNODB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci |);
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('OverDriveAuthname', '', 'Authname for OverDrive Patron Authentication, will be used as fallback if individual branch authname not set', NULL, 'Free');");
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('OverDriveWebsiteID','', 'WebsiteID provided by OverDrive', NULL, 'Free');");
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('OverDrivePasswordRequired','', 'Does the library require passwords for OverDrive SIP authentication', NULL, 'YesNo');");
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21082 - Add overdrive patron auth method)\n";
}
