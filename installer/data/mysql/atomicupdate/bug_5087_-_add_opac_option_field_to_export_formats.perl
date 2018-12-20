$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    unless( column_exists( 'export_format', 'opac_option' ) ) {
        $dbh->do(q|ALTER TABLE export_format ADD opac_option TINYINT(1) NOT NULL DEFAULT 0 AFTER used_for|);
    }

    NewVersion( $DBversion, 5087, "Add export_format.opac_option" );
}
