use Modern::Perl;

return {
    bug_number  => "15067",
    description => "Add missing languages",
    up          => sub {
        my ($args) = @_;
        my $dbh = $args->{dbh};

        if ( !unique_key_exists( 'language_subtag_registry', 'uniq_lang' ) ) {

            $dbh->do(
                q{
                DELETE a
                FROM language_subtag_registry AS a, language_subtag_registry AS b
                WHERE a.id < b.id
                AND a.subtag IS NOT NULL
                AND a.subtag=b.subtag
                AND a.type=b.type
            }
            );
            $dbh->do(
                q{
                ALTER TABLE language_subtag_registry
                ADD UNIQUE KEY uniq_lang (subtag, type)
            }
            );
        }

        if ( !unique_key_exists( 'language_descriptions', 'uniq_desc' ) ) {

            $dbh->do(
                q{
                DELETE a
                FROM language_descriptions AS a, language_descriptions AS b
                WHERE a.id < b.id
                AND a.subtag IS NOT NULL
                AND a.subtag=b.subtag
                AND a.lang IS NOT NULL
                AND a.lang=b.lang
                AND a.type=b.type
            }
            );
            $dbh->do(
                q{
                ALTER TABLE language_descriptions
                ADD UNIQUE KEY uniq_desc (subtag, type, lang)
            }
            );
        }

        if ( !unique_key_exists( 'language_rfc4646_to_iso639', 'uniq_code' ) ) {

            $dbh->do(
                q{
                DELETE a
                FROM language_rfc4646_to_iso639 AS a, language_rfc4646_to_iso639 AS b
                WHERE a.id < b.id
                AND a.rfc4646_subtag IS NOT NULL
                AND a.rfc4646_subtag=b.rfc4646_subtag
                AND a.iso639_2_code=b.iso639_2_code
            }
            );
            $dbh->do(
                q{
                ALTER TABLE language_rfc4646_to_iso639
                ADD UNIQUE KEY uniq_code (rfc4646_subtag, iso639_2_code)
            }
            );
        }

        $dbh->do(
            q{
            INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added)
            VALUES
            ('et', 'language', 'Estonian', now()),
            ('lv', 'language', 'Latvian', now()),
            ('lt', 'language', 'Lithuanian', now()),
            ('iu', 'language', 'Inuktitut', now()),
            ('ik', 'language', 'Inupiaq', now())
        }
        );

        $dbh->do(
            q{
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
        }
        );

        $dbh->do(
            q{
            INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code)
            VALUES
            ('et', 'est'),
            ('lv', 'lav'),
            ('lt', 'lit'),
            ('iu', 'iku'),
            ('ik', 'ipk')
        }
        );
    },
    }
