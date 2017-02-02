$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    my $sql = q{
      CREATE TABLE IF NOT EXISTS `marc_merge_rules` (
        `id` int(11) NOT NULL auto_increment,
        `tag` varchar(255) NOT NULL,
        `module` varchar(127) NOT NULL,
        `filter` varchar(255) NOT NULL,
        `add` tinyint NOT NULL,
        `append` tinyint NOT NULL,
        `remove` tinyint NOT NULL,
        `delete` tinyint NOT NULL,
        PRIMARY KEY(`id`)
      );
    };
    $dbh->do( $sql );

    $sql = q{
      INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`) VALUES (
        'MARCMergeRules',
        '0',
        NULL,
        'Use the MARC merge rules system to decide what actions to take for each field when modifying records.',
        'YesNo'
      );
    };
    $dbh->do( $sql );

    $sql = q{
      INSERT IGNORE INTO permissions (module_bit, code, description) VALUES (
        3,
        'manage_marc_merge_rules',
        'Manage MARC merge rules configuration'
      );
    };
    $dbh->do( $sql );

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14957 - Write protecting MARC fields based on source of import)\n";
}
