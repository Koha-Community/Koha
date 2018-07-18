$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q{
        CREATE TABLE `circulation_rules` (
          `id` int(11) NOT NULL auto_increment,
          `branchcode` varchar(10) NULL default NULL,
          `categorycode` varchar(10) NULL default NULL,
          `itemtype` varchar(10) NULL default NULL,
          `rule_name` varchar(32) NOT NULL,
          `rule_value` varchar(32) NOT NULL,
          PRIMARY KEY (`id`),
          KEY `branchcode` (`branchcode`),
          KEY `categorycode` (`categorycode`),
          KEY `itemtype` (`itemtype`),
          KEY `rule_name` (`rule_name`),
          UNIQUE (`branchcode`,`categorycode`,`itemtype`,`rule_name`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    });

    $dbh->do(q{
        INSERT INTO circulation_rules ( branchcode, categorycode, itemtype, rule_name, rule_value )
        SELECT branchcode, categorycode, NULL, 'max_holds', COALESCE( max_holds, '' ) FROM branch_borrower_circ_rules
    });

    $dbh->do(q{
        INSERT INTO circulation_rules ( branchcode, categorycode, itemtype, rule_name, rule_value )
        SELECT NULL, categorycode, NULL, 'max_holds', COALESCE( max_holds, '' ) FROM default_borrower_circ_rules
    });

    $dbh->do(q{
        ALTER TABLE branch_borrower_circ_rules DROP COLUMN max_holds
    });

    $dbh->do(q{
        ALTER TABLE default_borrower_circ_rules DROP COLUMN max_holds
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18887 - Introduce new table 'circulation_rules', use for 'max_holds' rules)\n";
}
