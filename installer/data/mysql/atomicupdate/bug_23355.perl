$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    $dbh->do(qq{
CREATE TABLE `cash_register_actions` (
  `id` int(11) NOT NULL auto_increment, -- unique identifier for each account register action
  `code` varchar(24) NOT NULL, -- action code denoting the type of action recorded (enum),
  `manager_id` int(11) NOT NULL, -- staff member performing the action
  `amount` decimal(28,6) DEFAULT NULL, -- amount recorded in action (signed)
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `cash_register_actions_manager` FOREIGN KEY (`manager_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `cash_register_actions_register` FOREIGN KEY (`register_id`) REFERENCES `cash_registers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
    });

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 23355 - Add cash_register_actions table)\n";
}
