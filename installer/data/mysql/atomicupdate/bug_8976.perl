$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    unless ( column_exists( 'marc_subfield_structure', 'display_order' ) ) {
        $dbh->do(q{
            ALTER TABLE marc_subfield_structure
            ADD COLUMN display_order INT(2) NOT NULL DEFAULT 0 AFTER maxlength
        });
    }

    unless ( column_exists( 'auth_subfield_structure', 'display_order' ) ) {
        $dbh->do(q{
            ALTER TABLE auth_subfield_structure
            ADD COLUMN display_order INT(2) NOT NULL DEFAULT 0 AFTER defaultvalue
        });
    }

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 8976, "Description");
}
