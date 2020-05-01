$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    unless ( column_exists( 'authorised_value_categories', 'is_system' ) ) {
        $dbh->do(q|
            ALTER TABLE authorised_value_categories
            ADD COLUMN is_system TINYINT(1) DEFAULT 0 AFTER category_name
        |);
    }

    $dbh->do(q|
        UPDATE authorised_value_categories
        SET is_system = 1
        WHERE category_name IN ('LOC', 'LOST', 'WITHDRAWN', 'Bsort1', 'Bsort2', 'Asort1', 'Asort2', 'SUGGEST', 'DAMAGED', 'LOST', 'BOR_NOTES', 'CCODE', 'NOT_LOAN')
    |);

    $dbh->do(q|
        UPDATE authorised_value_categories
        SET is_system = 1
        WHERE category_name IN ('branches', 'itemtypes', 'cn_source')
    |);

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 17355, "Add is_system to authorised_value_categories table");
}
