$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    unless ( column_exists( 'authorised_value_categories', 'is_system' ) ) {
        $dbh->do(q|
            ALTER TABLE authorised_value_categories
            ADD COLUMN is_system TINYINT(1) DEFAULT 0 AFTER category_name
        |);
    }

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 17355, "Description");
}
