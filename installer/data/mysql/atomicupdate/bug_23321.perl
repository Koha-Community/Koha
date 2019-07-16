$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    $dbh->do(qq{
CREATE TABLE `cash_registers` (
  `id` int(11) NOT NULL auto_increment, -- unique identifier for each account register
  `name` varchar(24) NOT NULL, -- the user friendly identifier for each account register
  `description` longtext NOT NULL, -- the user friendly description for each account register
  `branch` varchar(10) NOT NULL, -- the foreign key the library this account register belongs
  `branch_default` tinyint(1) NOT NULL DEFAULT 0, -- boolean flag to denote that this till is the branch default
  `starting_float` decimal(28, 6), -- the starting float this account register should be assigned
  `archived` tinyint(1) NOT NULL DEFAULT 0, -- boolean flag to denote if this till is archived or not
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`,`branch`),
  CONSTRAINT cash_registers_branch FOREIGN KEY (branch) REFERENCES branches (branchcode) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
    });

    unless ( column_exists( 'accountlines', 'register_id' ) ) {
        $dbh->do(qq{ALTER TABLE `accountlines` ADD `register_id` int(11) NULL DEFAULT NULL AFTER `manager_id`});
        $dbh->do(qq{
            ALTER TABLE `accountlines`
            ADD CONSTRAINT `accountlines_ibfk_registers` FOREIGN KEY (`register_id`)
            REFERENCES `cash_registers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
        });
    }

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 23321 - Add cash_registers table)\n";
}
