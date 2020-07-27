$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # Remove from the systempreferences table
    $dbh->do("DELETE FROM systempreferences WHERE variable = 'GoogleIndicTransliteration'");

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 26070, "Remove references to deprecated Google Transliterate API");
}
