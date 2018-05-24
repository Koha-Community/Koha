$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do("
	CREATE TABLE action_logs_cache (
	  action_id int(11) NOT NULL auto_increment,
	  timestamp timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
	  user int(11) NOT NULL default 0,
	  module text,
	  action text,
	  object int(11) default NULL,
	  info text,
	  interface VARCHAR(30) DEFAULT NULL,
	  PRIMARY KEY (action_id),
	  KEY timestamp_idx (timestamp),
	  KEY user_idx (user),
	  KEY module_idx (module(255)),
	  KEY action_idx (action(255)),
	  KEY object_idx (object),
	  KEY info_idx (info(255)),
	  KEY interface (interface)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
	");
    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD 2990 - MongoDB datawarehouse for storing the logging data.)\n";
}
