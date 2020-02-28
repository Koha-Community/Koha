$DBversion = 'XXX'; # will be replaced by the RM
if ( CheckVersion( $DBversion ) ) {
    unless ( column_exists( 'reserves', 'item_group_id' ) ) {
        $dbh->do(q{
            ALTER TABLE reserves
            ADD COLUMN `item_group_id` int(11) NULL default NULL AFTER biblionumber,
            ADD CONSTRAINT `reserves_ibfk_ig` FOREIGN KEY (`item_group_id`) REFERENCES `item_groups` (`item_group_id`) ON DELETE SET NULL ON UPDATE CASCADE;
        });
    }

    unless ( column_exists( 'old_reserves', 'item_group_id' ) ) {
        $dbh->do(q{
            ALTER TABLE old_reserves
            ADD COLUMN `item_group_id` int(11) NULL default NULL AFTER biblionumber,
            ADD CONSTRAINT `old_reserves_ibfk_ig` FOREIGN KEY (`item_group_id`) REFERENCES `item_groups` (`item_group_id`) ON DELETE SET NULL ON UPDATE SET NULL;
        });
    }

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('EnableItemGroupHolds','0','','Enable volume level holds feature','YesNo')
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24860 - Add ability to place item group level holds)\n";
}
