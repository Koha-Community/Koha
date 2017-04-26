$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    # Aramaic
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added)
    VALUES( 'arc', 'language', 'Aramaic',NOW())");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
    VALUES( 'arc', 'arc')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description)
    VALUES( 'arc', 'language', 'en', 'Aramaic')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description)
    VALUES( 'arc', 'language', 'arc', 'Arāmāyā')");

    # Finno-Ugric
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added)
    VALUES( 'fiu', 'language', 'Finno-Ugric',NOW())");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
    VALUES( 'fiu', 'fiu')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description)
    VALUES( 'fiu', 'language', 'en', 'Finno-Ugric')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description)
    VALUES( 'fiu', 'language', 'fiu', 'Finno-Ugrian')");

    # Indic
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added)
    VALUES( 'inc', 'language', 'Indic',NOW())");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
    VALUES( 'inc', 'inc')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description)
    VALUES( 'inc', 'language', 'en', 'Indic')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description)
    VALUES( 'inc', 'language', 'inc', 'Indic')");

    # Iranian
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added)
    VALUES( 'ira', 'language', 'Iranian',NOW())");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
    VALUES( 'ira', 'ira')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description)
    VALUES( 'ira', 'language', 'en', 'Iranian')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description)
    VALUES( 'ira', 'language', 'ira', 'Iranian')");

    # Mayan
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added)
    VALUES( 'myn', 'language', 'Mayan',NOW())");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
    VALUES( 'myn', 'myn')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description)
    VALUES( 'myn', 'language', 'en', 'Mayan')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description)
    VALUES( 'myn', 'language', 'myn', 'Mayan')");

    # Romani
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added)
    VALUES( 'rom', 'language', 'Romani',NOW())");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
    VALUES( 'rom', 'rom')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description)
    VALUES( 'rom', 'language', 'en', 'Romani')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description)
    VALUES( 'rom', 'language', 'rom', 'romani ćhib')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description)
    VALUES( 'rom', 'language', 'fi', 'romanikieli')");

    # Yupik
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added)
    VALUES( 'ypk', 'language', 'Yupik',NOW())");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code)
    VALUES( 'ypk', 'ypk')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description)
    VALUES( 'ypk', 'language', 'en', 'Yupik')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description)
    VALUES( 'ypk', 'language', 'ypk', 'Yupik')");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - description)\n";
}
