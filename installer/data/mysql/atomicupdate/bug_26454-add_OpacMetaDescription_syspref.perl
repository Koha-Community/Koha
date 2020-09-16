$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES ('OpacMetaDescription','','','This description will show in search engine results (160 characters).','Textarea');" );

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 26454, "Add system preference to set meta description for the OPAC");
}
