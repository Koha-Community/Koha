$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if( !column_exists( 'itemtypes', 'automatic_checkin' ) ) {
        $dbh->do(q{
            ALTER TABLE itemtypes
                ADD COLUMN `automatic_checkin` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'If automatic checkin is enabled for items of this type' AFTER `searchcategory`
        });
    }

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 23027, "Add automatic_checkin to itemtypes table");
}
