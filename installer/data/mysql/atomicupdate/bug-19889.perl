$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if( !column_exists( 'items', 'exclude_from_local_holds_priority' ) ) {
        $dbh->do(q{
            ALTER TABLE `items` ADD COLUMN `exclude_from_local_holds_priority` tinyint(1) default NULL AFTER `new_status` -- Exclude this item from local holds priority
        });
    }

    if( !column_exists( 'deleteditems', 'exclude_from_local_holds_priority' ) ) {
        $dbh->do(q{
            ALTER TABLE `deleteditems` ADD COLUMN `exclude_from_local_holds_priority` tinyint(1) default NULL AFTER `new_status` -- Exclude this item from local holds priority
        });
    }

    if( !column_exists( 'categories', 'exclude_from_local_holds_priority' ) ) {
        $dbh->do(q{
            ALTER TABLE `categories` ADD COLUMN `exclude_from_local_holds_priority` tinyint(1) default NULL AFTER `change_password` -- Exclude patrons of this category from local holds priority
        });
    }
    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 19889, "Add exclude_from_local_holds_priority column to items, deleteditems and categories tables");
}
