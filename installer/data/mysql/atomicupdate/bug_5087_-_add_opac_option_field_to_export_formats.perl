$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    unless( column_exists( 'export_format', 'staff_only' ) ) {
        $dbh->do(q|
            ALTER TABLE export_format
                ADD staff_only TINYINT(1) NOT NULL DEFAULT 0 AFTER used_for,
                ADD KEY `staff_only_idx` (`staff_only`);
        |);
    }

    unless ( index_exists( 'export_format', 'used_for_idx' ) ) {
        $dbh->do(q|
            ALTER TABLE export_format
                ADD KEY `used_for_idx` (`used_for` (191));
        |);
    }

    NewVersion( $DBversion, 5087, "Add export_format.staff_only" );
}
