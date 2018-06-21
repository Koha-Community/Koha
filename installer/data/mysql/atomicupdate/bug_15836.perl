$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    unless( TableExists( 'class_split_rules' ) ) {
        $dbh->do(q|
            CREATE TABLE class_split_rules (
              class_split_rule varchar(10) NOT NULL default '',
              description LONGTEXT,
              split_routine varchar(30) NOT NULL default '',
              split_regex varchar(255) NOT NULL default '',
              PRIMARY KEY (class_split_rule),
              UNIQUE KEY class_split_rule_idx (class_split_rule)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        |);

        $dbh->do(q|
            ALTER TABLE class_sources
            ADD COLUMN class_split_rule varchar(10) NOT NULL default ''
            AFTER class_sort_rule
        |);
        $dbh->do(q|
            UPDATE class_sources
            SET class_split_rule = class_sort_rule
        |);

        $dbh->do(q|
            INSERT INTO class_split_rules(class_split_rule, description, split_routine)
            VALUES
            ('dewey', 'Default sorting rules for DDC', 'dewey'),
            ('lcc', 'Default sorting rules for LCC', 'LCC'),
            ('generic', 'Generic call number sorting rules', 'Generic')
        |);

        $dbh->do(q|
            ALTER TABLE class_sources
            ADD CONSTRAINT class_source_ibfk_2 FOREIGN KEY (class_split_rule)
            REFERENCES class_split_rules (class_split_rule)
        |);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 15836 - Add class_sort_rules.split_routine and split_regex)\n";
}
