$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE language_subtag_registry SET description = 'Ukrainian' WHERE subtag='uk' and type='language' and description='Ukranian'" );
    $dbh->do( "UPDATE language_descriptions SET description = 'Ukrainian' WHERE subtag='uk' and type='language' and lang='en' and description='Ukranian'" );

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 28244, "Fix Ukrainian typo in English");
}
