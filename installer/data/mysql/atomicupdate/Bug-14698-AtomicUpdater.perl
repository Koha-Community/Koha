$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    $dbh->do("
	CREATE TABLE `atomicupdates` (
	  `atomicupdate_id` int(11) unsigned NOT NULL auto_increment,
	  `issue_id` varchar(20) NOT NULL,
	  `filename` varchar(30) NOT NULL,
	  `modification_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	  PRIMARY KEY  (`atomicupdate_id`),
	  UNIQUE KEY `origincode` (`issue_id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
	");
	$dbh->do("INSERT INTO atomicupdates (issue_id, filename) VALUES ('Bug14698', 'Bug14698-AtomicUpdater.pl')");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14698 - AtomicUpdater - Keeps track of which updates have been applied to a database done)\n";
}
