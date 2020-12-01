$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    unless ( column_exists( 'marc_subfield_structure', 'display_order' ) ) {
        $dbh->do(q{
            ALTER TABLE marc_subfield_structure
            ADD COLUMN display_order INT(2) NOT NULL DEFAULT 0 AFTER maxlength
        });
    }

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, XXXXX, "Description");
}
