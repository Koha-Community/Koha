$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences
            ( variable, value, options, explanation, type )
        VALUES
            ('CustomCoverImages','0',NULL,'If enabled, the custom cover images will be displayed in the staff client. CustomCoverImagesURL must be defined.','YesNo'),
            ('OPACCustomCoverImages','0',NULL,'If enabled, the custom cover images will be displayed at the OPAC. CustomCoverImagesURL must be defined.','YesNo'),
            ('CustomCoverImagesURL','',NULL,'Define an URL serving book cover images, using the following patterns: {issn}, {isbn}, {normalized_isbn}, {field$subfield} (use it with CustomCoverImages and/or OPACCustomCoverImages)','free')
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - Add new pref *CustomCoverImages*)\n";
}
