$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    if( !unique_key_exists( 'language_subtag_registry', 'uniq_lang' ) ) {
        my $dupe_languages = $dbh->selectall_arrayref(q|
            SELECT subtag, type FROM language_subtag_registry GROUP BY subtag, type HAVING COUNT(*) > 1
        |, { Slice => {} });
        if ( @$dupe_languages ) {
            warn "You have duplicated languages in the language_subtag_registry table in your database, unique constraint cannot be added";
        } else {
            $dbh->do(q{
                ALTER TABLE language_subtag_registry
                ADD UNIQUE KEY uniq_lang (subtag, type)
            });
        }
    };

    if( !unique_key_exists( 'language_descriptions', 'uniq_desc' ) ) {
        my $dupe_language_descriptions = $dbh->selectall_arrayref(q|
            SELECT subtag, lang, type FROM language_descriptions GROUP BY subtag, lang, type HAVING COUNT(*) > 1
        |, { Slice => {} });
        if ( @$dupe_language_descriptions ) {
            warn "You have duplicated language descriptionss in the language_descriptions table in your database, unique constraint cannot be added";
        } else {
            $dbh->do(q{
                ALTER TABLE language_descriptions
                ADD UNIQUE KEY uniq_desc (subtag, type, lang)
            });
        }
    };

    if( !unique_key_exists( 'language_rfc4646_to_iso639', 'uniq_code' ) ) {
        my $dupe_language_rfc = $dbh->selectall_arrayref(q|
            SELECT rfc4646_subtag, iso639_2_code FROM language_rfc4646_to_iso639 GROUP BY rfc4646_subtag, iso639_2_code HAVING COUNT(*) > 1
        |, { Slice => {} });
        if ( @$dupe_language_rfc ) {
            warn "You have duplicated languages in the language_rfc4646_to_iso639 in your database, unique constraint cannot be added";
        } else {
            $dbh->do(q{
                ALTER TABLE language_rfc4646_to_iso639
                ADD UNIQUE KEY uniq_code (rfc4646_subtag, iso639_2_code)
            });
        }
    };

    $dbh->do(q{
        INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added)
        VALUES
        ('et', 'language', 'Estonian', now()),
        ('lv', 'language', 'Latvian', now()),
        ('lt', 'language', 'Lithuanian', now()),
        ('iu', 'language', 'Inuktitut', now()),
        ('ik', 'language', 'Inupiaq', now())
    });

    $dbh->do(q{
        INSERT IGNORE INTO language_descriptions (subtag, type, lang, description)
        VALUES
        ('et', 'language', 'en', 'Estonian'),
        ('et', 'language', 'et', 'Eesti'),
        ('lv', 'language', 'en', 'Latvian'),
        ('lv', 'language', 'lv', 'Latvija'),
        ('lt', 'language', 'en', 'Lithuanian'),
        ('lt', 'language', 'lt', 'Lietuvių'),
        ('iu', 'language', 'en', 'Inuktitut'),
        ('iu', 'language', 'iu', 'ᐃᓄᒃᑎᑐᑦ'),
        ('ik', 'language', 'en', 'Inupiaq'),
        ('ik', 'language', 'ik', 'Iñupiaq')
    });

    $dbh->do(q{
        INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code)
        VALUES
        ('et', 'est'),
        ('lv', 'lav'),
        ('lt', 'lit'),
        ('iu', 'iku'),
        ('ik', 'ipk')
    });

    NewVersion( $DBversion, 15067, "Add missing languages");
}
