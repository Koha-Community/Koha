$DBversion = 'XXX';
if (CheckVersion($DBversion)) {
    if (!column_exists('course_items', 'homebranch')) {
        $dbh->do(q{
            ALTER TABLE course_items
            ADD COLUMN homebranch VARCHAR(10) NULL DEFAULT NULL AFTER ccode_storage
        });
    }

    if (!foreign_key_exists('course_items', 'fk_course_items_homebranch')) {
        $dbh->do(q{
            ALTER TABLE course_items
            ADD CONSTRAINT fk_course_items_homebranch
              FOREIGN KEY (homebranch) REFERENCES branches (branchcode)
              ON DELETE CASCADE ON UPDATE CASCADE
        });
    }

    if (!column_exists('course_items', 'homebranch_enabled')) {
        $dbh->do(q{
            ALTER TABLE course_items
            ADD COLUMN homebranch_enabled tinyint(1) NOT NULL DEFAULT 0 AFTER homebranch
        });
    }

    if (!column_exists('course_items', 'homebranch_storage')) {
        $dbh->do(q{
            ALTER TABLE course_items
            ADD COLUMN homebranch_storage VARCHAR(10) NULL DEFAULT NULL AFTER homebranch_enabled
        });
    }

    if (!foreign_key_exists('course_items', 'fk_course_items_homebranch_storage')) {
        $dbh->do(q{
            ALTER TABLE course_items
            ADD CONSTRAINT fk_course_items_homebranch_storage
              FOREIGN KEY (homebranch_storage) REFERENCES branches (branchcode)
              ON DELETE CASCADE ON UPDATE CASCADE
        });
    }

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 22630 - Add course_items.homebranch)\n";
}
