$DBversion = 'XXX';
if ( CheckVersion($DBversion) ) {
    if ( !column_exists( 'virtualshelves', 'allow_change_from_staff' ) ) {
        $dbh->do(q{ALTER TABLE virtualshelves ADD COLUMN `allow_change_from_staff` tinyint(1) DEFAULT '0' COMMENT 'can staff change contents?'});
    }

    $dbh->do(q{ INSERT IGNORE INTO permissions (module_bit, code, description) VALUES (20, 'edit_public_lists', 'Edit public lists') });
    NewVersion( $DBversion, 26346, "Add allow_change_from_staff to virtualshelves table" );
}
