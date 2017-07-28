$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("ALTER TABLE `atomicupdates` MODIFY COLUMN `filename` varchar(128) NOT NULL");
    $dbh->do("ALTER TABLE `atomicupdates` DROP INDEX `origincode`");
    $dbh->do("ALTER TABLE `atomicupdates` ADD UNIQUE KEY `atomic_issue_id` (`issue_id`)");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14698 - AtomicUpdater - Schema mismatch fixes)\n";
}
