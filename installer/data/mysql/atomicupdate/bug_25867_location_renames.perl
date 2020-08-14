$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do( "UPDATE marc_subfield_structure SET liblibrarian = 'Home library' WHERE liblibrarian = 'Permanent location'
        AND tagfield = 952 and tagsubfield = 'a'" );
    $dbh->do( "UPDATE marc_subfield_structure SET libopac = 'Home library' WHERE libopac = 'Permanent location'
        AND tagfield = 952 and tagsubfield = 'a'" );
    $dbh->do( "UPDATE marc_subfield_structure SET liblibrarian = 'Current library' WHERE liblibrarian = 'Current location'
        AND tagfield = 952 and tagsubfield = 'b'" );
    $dbh->do( "UPDATE marc_subfield_structure SET libopac = 'Current library' WHERE libopac = 'Current location'
        AND tagfield = 952 and tagsubfield = 'b'" );

    NewVersion( $DBversion, 25867, "Update subfield descriptions for 952\$a and 952\$b");
}
