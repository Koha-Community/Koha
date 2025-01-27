use Modern::Perl;

return {
    bug_number  => "27136",
    description =>
        "Add missing languages: Cree, Afrikaans and Multiple languages, Undetermined and No linguistic content",
    up => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('cr', 'language', 'Cree', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cr', 'language', 'en', 'Cree') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cr', 'language', 'fr', 'Cree') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('cr', 'cre') });

        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('af', 'language', 'Afrikaans', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('af', 'language', 'en', 'Afrikaans') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('af', 'language', 'fr', 'Afrikaans') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('af', 'afr') });

        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('mul', 'language', 'Multiple languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mul', 'language', 'en', 'Multiple languages') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mul', 'language', 'fr', 'Multilingue') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('mul', 'mul') });

        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('und', 'language', 'Undetermined', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('und', 'language', 'en', 'Undetermined') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('und', 'language', 'fr', 'Indéterminée') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('und', 'und') });

        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('zxx', 'language', 'No linguistic content', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('zxx', 'language', 'en', 'No linguistic content') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('zxx', 'language', 'fr', 'Pas de contenu linguistique') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('zxx', 'zxx') });
        say $out "Added missing languages";
    },
};
