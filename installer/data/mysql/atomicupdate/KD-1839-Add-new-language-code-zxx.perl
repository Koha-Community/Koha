$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added)
    VALUES( 'zxx', 'language', 'No linguistic information',NOW())");

    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
    VALUES( 'zxx', 'zxx')");

    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description)
    VALUES( 'zxx', 'language', 'en', 'No linguistic information')");

    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description)
    VALUES( 'zxx', 'language', 'zxx', 'No linguistic information')");

    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description)
    VALUES( 'zxx', 'language', 'fi', 'Ei kielellistä sisältöä')");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-1839: Add new language code zxx - no linguistic information)\n";
}

