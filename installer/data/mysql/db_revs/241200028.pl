use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "39147",
    description => "Add more missing languages",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Abkhaz
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ab', 'language', 'Abkhaz', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ab', 'abk') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ab', 'language', 'en', 'Abkhaz') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ab', 'language', 'pl', 'Abchaski') }
        );

        # Acoli
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ach', 'language', 'Acoli', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ach', 'ach') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ach', 'language', 'en', 'Acoli') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ach', 'language', 'pl', 'Aczoli') }
        );

        # Adangme
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ada', 'language', 'Adangme', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ada', 'ada') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ada', 'language', 'en', 'Adangme') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ada', 'language', 'pl', 'Adangme') }
        );

        # Adygei
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ady', 'language', 'Adygei', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ady', 'ady') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ady', 'language', 'en', 'Adygei') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ady', 'language', 'pl', 'Adygejski') }
        );

        # Afroasiatic (Other)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('afa', 'language', 'Afroasiatic (Other)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('afa', 'afa') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('afa', 'language', 'en', 'Afroasiatic (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('afa', 'language', 'pl', 'Afroazjatyckie (inne)') }
        );

        # Ainu
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ain', 'language', 'Ainu', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ain', 'ain') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ain', 'language', 'en', 'Ainu') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ain', 'language', 'pl', 'Ajnoski (ajnu)') }
        );

        # Akan
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ak', 'language', 'Akan', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ak', 'aka') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ak', 'language', 'en', 'Akan') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ak', 'language', 'pl', 'Akan') }
        );

        # Aleut
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ale', 'language', 'Aleut', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ale', 'ale') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ale', 'language', 'en', 'Aleut') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ale', 'language', 'pl', 'Aleucki') }
        );

        # Algonquian (Other)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('alg', 'language', 'Algonquian (Other)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('alg', 'alg') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('alg', 'language', 'en', 'Algonquian (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('alg', 'language', 'pl', 'Algonkińskie (inne)') }
        );

        # Altai
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('alt', 'language', 'Altai', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('alt', 'alt') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('alt', 'language', 'en', 'Altai') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('alt', 'language', 'pl', 'Ałtajski') }
        );

        # Angika
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('anp', 'language', 'Angika', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('anp', 'anp') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('anp', 'language', 'en', 'Angika') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('anp', 'language', 'pl', 'Angika') }
        );

        # Apache languages
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('apa', 'language', 'Apache languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('apa', 'apa') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('apa', 'language', 'en', 'Apache languages') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('apa', 'language', 'pl', 'Apaczeańskie (języki Apaczów)') }
        );

        # Aragonese
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('an', 'language', 'Aragonese', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('an', 'arg') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('an', 'language', 'en', 'Aragonese') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('an', 'language', 'pl', 'Aragoński') }
        );

        # Mapuche
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('arn', 'language', 'Mapuche', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('arn', 'arn') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('arn', 'language', 'en', 'Mapuche') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('arn', 'language', 'pl', 'Araukański') }
        );

        # Artificial (Other)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('art', 'language', 'Artificial (Other)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('art', 'art') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('art', 'language', 'en', 'Artificial (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('art', 'language', 'pl', 'Sztuczne (inne)') }
        );

        # Arawak
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('arw', 'language', 'Arawak', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('arw', 'arw') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('arw', 'language', 'en', 'Arawak') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('arw', 'language', 'pl', 'Arawaskie') }
        );

        # Assamese
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('as', 'language', 'Assamese', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('as', 'asm') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('as', 'language', 'en', 'Assamese') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('as', 'language', 'pl', 'Assamski') }
        );

        # Athapascan (Other)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ath', 'language', 'Athapascan (Other)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ath', 'ath') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ath', 'language', 'en', 'Athapascan (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ath', 'language', 'pl', 'Atapaskańskie') }
        );

        # Australian languages
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('aus', 'language', 'Australian languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('aus', 'aus') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('aus', 'language', 'en', 'Australian languages') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('aus', 'language', 'pl', 'Australijskie') }
        );

        # Avaric
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('av', 'language', 'Avaric', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('av', 'ava') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('av', 'language', 'en', 'Avaric') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('av', 'language', 'pl', 'Awarski') }
        );

        # Awadhi
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('awa', 'language', 'Awadhi', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('awa', 'awa') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('awa', 'language', 'en', 'Awadhi') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('awa', 'language', 'pl', 'Awadhi') }
        );

        # Aymara
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ay', 'language', 'Aymara', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ay', 'aym') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ay', 'language', 'en', 'Aymara') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ay', 'language', 'pl', 'Ajmara') }
        );

        # Banda languages
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('bad', 'language', 'Banda languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('bad', 'bad') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bad', 'language', 'en', 'Banda languages') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bad', 'language', 'pl', 'Banda, języki') }
        );

        # Bashkir
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ba', 'language', 'Bashkir', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ba', 'bak') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ba', 'language', 'en', 'Bashkir') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ba', 'language', 'pl', 'Baszkirski') }
        );

        # Baluchi
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('bal', 'language', 'Baluchi', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('bal', 'bal') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bal', 'language', 'en', 'Baluchi') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bal', 'language', 'pl', 'Beludżyjski') }
        );

        # Bambara
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('bm', 'language', 'Bambara', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('bm', 'bam') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bm', 'language', 'en', 'Bambara') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bm', 'language', 'pl', 'Bambara') }
        );

        # Basa
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('bas', 'language', 'Basa', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('bas', 'bas') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bas', 'language', 'en', 'Basa') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bas', 'language', 'pl', 'Basa') }
        );

        # Baltic (Other)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('bat', 'language', 'Baltic (Other)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('bat', 'bat') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bat', 'language', 'en', 'Baltic (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bat', 'language', 'pl', 'Bałtyckie (inne)') }
        );

        # Berber (Other)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ber', 'language', 'Berber (Other)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ber', 'ber') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ber', 'language', 'en', 'Berber (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ber', 'language', 'pl', 'Berberskie (inne)') }
        );

        # Bhojpuri
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('bho', 'language', 'Bhojpuri', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('bho', 'bho') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bho', 'language', 'en', 'Bhojpuri') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bho', 'language', 'pl', 'Bhodźpuri') }
        );

        # Edo
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('bin', 'language', 'Edo', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('bin', 'bin') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bin', 'language', 'en', 'Edo') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bin', 'language', 'pl', 'Bini') }
        );

        # Breton
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('br', 'language', 'Breton', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('br', 'bre') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('br', 'language', 'en', 'Breton') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('br', 'language', 'pl', 'Bretoński') }
        );

        # Buriat
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('bua', 'language', 'Buriat', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('bua', 'bua') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bua', 'language', 'en', 'Buriat') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bua', 'language', 'pl', 'Buriacki') }
        );

        # Bugis
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('bug', 'language', 'Bugis', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('bug', 'bug') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bug', 'language', 'en', 'Bugis') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('bug', 'language', 'pl', 'Bugijski') }
        );

        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('my', 'language', 'pl', 'Birmański') }
        );

        # Central American Indian (Other)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('cai', 'language', 'Central American Indian (Other)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('cai', 'cai') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cai', 'language', 'en', 'Central American Indian (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cai', 'language', 'pl', 'Indian środkowoamerykańskich (inne)') }
        );

        # Carib
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('car', 'language', 'Carib', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('car', 'car') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('car', 'language', 'en', 'Carib') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('car', 'language', 'pl', 'Carib') }
        );

        # Caucasian (Other)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('cau', 'language', 'Caucasian (Other)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('cau', 'cau') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cau', 'language', 'en', 'Caucasian (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cau', 'language', 'pl', 'Kaukaskie') }
        );

        # Cebuano
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ceb', 'language', 'Cebuano', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ceb', 'ceb') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ceb', 'language', 'en', 'Cebuano') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ceb', 'language', 'pl', 'Cebuański (cebuano)') }
        );

        # Chamorro
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ch', 'language', 'Chamorro', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ch', 'cha') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ch', 'language', 'en', 'Chamorro') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ch', 'language', 'pl', 'Czamorro') }
        );

        # Chibcha
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('chb', 'language', 'Chibcha', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('chb', 'chb') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('chb', 'language', 'en', 'Chibcha') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('chb', 'language', 'pl', 'Czibczańskie') }
        );

        # Chagatai
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('chg', 'language', 'Chagatai', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('chg', 'chg') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('chg', 'language', 'en', 'Chagatai') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('chg', 'language', 'pl', 'Czagatajski') }
        );

        # Chuukese
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('chk', 'language', 'Chuukese', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('chk', 'chk') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('chk', 'language', 'en', 'Chuukese') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('chk', 'language', 'pl', 'Czukocki') }
        );

        # Mari
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('chm', 'language', 'Mari', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('chm', 'chm') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('chm', 'language', 'en', 'Mari') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('chm', 'language', 'pl', 'Maryjski (czeremiski)') }
        );

        # Chinook jargon
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('chn', 'language', 'Chinook jargon', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('chn', 'chn') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('chn', 'language', 'en', 'Chinook jargon') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('chn', 'language', 'pl', 'Chinook jargon') }
        );

        # Cherokee
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('chr', 'language', 'Cherokee', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('chr', 'chr') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('chr', 'language', 'en', 'Cherokee') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('chr', 'language', 'pl', 'Czirokeski') }
        );

        # Chuvash
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('cv', 'language', 'Chuvash', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('cv', 'chv') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cv', 'language', 'en', 'Chuvash') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cv', 'language', 'pl', 'Czuwaski') }
        );

        # Cheyenne
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('chy', 'language', 'Cheyenne', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('chy', 'chy') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('chy', 'language', 'en', 'Cheyenne') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('chy', 'language', 'pl', 'Cheyenne') }
        );

        # Chamic languages
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('cmc', 'language', 'Chamic languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('cmc', 'cmc') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cmc', 'language', 'en', 'Chamic languages') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cmc', 'language', 'pl', 'Czamskie') }
        );

        # Montenegrin
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('cnr', 'language', 'Montenegrin', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('cnr', 'cnr') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cnr', 'language', 'en', 'Montenegrin') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cnr', 'language', 'pl', 'Czarnogórski') }
        );

        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kw', 'language', 'pl', 'Kornijski (kornwalijski)') }
        );

        # Corsican
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('co', 'language', 'Corsican', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('co', 'cos') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('co', 'language', 'en', 'Corsican') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('co', 'language', 'pl', 'Korsykański') }
        );

        # Creoles and Pidgins, English
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('cpe', 'language', 'Creoles and Pidgins, English', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('cpe', 'cpe') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cpe', 'language', 'en', 'Creoles and Pidgins, English') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cpe', 'language', 'pl', 'Kreolskie i pidżynowe na bazie języka angielskiego (inne)') }
        );

        # Creoles and Pidgins, French
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('cpf', 'language', 'Creoles and Pidgins, French', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('cpf', 'cpf') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cpf', 'language', 'en', 'Creoles and Pidgins, French') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cpf', 'language', 'pl', 'Kreolskie i pidżynowe na bazie języka francuskiego (inne)') }
        );

        # Creoles and Pidgins, Portuguese
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('cpp', 'language', 'Creoles and Pidgins, Portuguese', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('cpp', 'cpp') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cpp', 'language', 'en', 'Creoles and Pidgins, Portuguese') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cpp', 'language', 'pl', 'Kreolskie i pidżynowe na bazie języka portugalskiego (inne)') }
        );

        # Crimean Tatar
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('crh', 'language', 'Crimean Tatar', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('crh', 'crh') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('crh', 'language', 'en', 'Crimean Tatar') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('crh', 'language', 'pl', 'Krymskotatarski') }
        );

        # Creoles and Pidgins (Other)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('crp', 'language', 'Creoles and Pidgins (Other)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('crp', 'crp') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('crp', 'language', 'en', 'Creoles and Pidgins (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('crp', 'language', 'pl', 'Kreolskie i pidżynowe (inne)') }
        );

        # Cushitic (Other)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('cus', 'language', 'Cushitic (Other)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('cus', 'cus') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cus', 'language', 'en', 'Cushitic (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('cus', 'language', 'pl', 'Kuszyckie (inne)') }
        );

        # Dakota
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('dak', 'language', 'Dakota', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('dak', 'dak') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('dak', 'language', 'en', 'Dakota') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('dak', 'language', 'pl', 'Dakota') }
        );

        # Dargwa
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('dar', 'language', 'Dargwa', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('dar', 'dar') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('dar', 'language', 'en', 'Dargwa') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('dar', 'language', 'pl', 'Dargwijski') }
        );

        # Dayak
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('day', 'language', 'Dayak', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('day', 'day') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('day', 'language', 'en', 'Dayak') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('day', 'language', 'pl', 'Dajackie') }
        );

        # Delaware
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('del', 'language', 'Delaware', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('del', 'del') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('del', 'language', 'en', 'Delaware') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('del', 'language', 'pl', 'Delaware') }
        );

        # Dinka
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('din', 'language', 'Dinka', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('din', 'din') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('din', 'language', 'en', 'Dinka') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('din', 'language', 'pl', 'Dinka') }
        );

        # Divehi
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('dv', 'language', 'Divehi', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('dv', 'div') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('dv', 'language', 'en', 'Divehi') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('dv', 'language', 'pl', 'Malediwski (divehi)') }
        );

        # Dravidian (Other)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('dra', 'language', 'Dravidian (Other)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('dra', 'dra') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('dra', 'language', 'en', 'Dravidian (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('dra', 'language', 'pl', 'Drawidyjskie (inne)') }
        );

        # Lower Sorbian
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('dsb', 'language', 'Lower Sorbian', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('dsb', 'dsb') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('dsb', 'language', 'en', 'Lower Sorbian') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('dsb', 'language', 'pl', 'Dolnołużycki') }
        );

        # Duala
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('dua', 'language', 'Duala', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('dua', 'dua') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('dua', 'language', 'en', 'Duala') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('dua', 'language', 'pl', 'Duala') }
        );

        # Dyula
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('dyu', 'language', 'Dyula', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('dyu', 'dyu') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('dyu', 'language', 'en', 'Dyula') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('dyu', 'language', 'pl', 'Dyula') }
        );

        # Dzongkha
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('dz', 'language', 'Dzongkha', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('dz', 'dzo') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('dz', 'language', 'en', 'Dzongkha') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('dz', 'language', 'pl', 'Dzongka') }
        );

        # Efik
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('efi', 'language', 'Efik', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('efi', 'efi') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('efi', 'language', 'en', 'Efik') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('efi', 'language', 'pl', 'Efik') }
        );

        # Elamite
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('elx', 'language', 'Elamite', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('elx', 'elx') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('elx', 'language', 'en', 'Elamite') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('elx', 'language', 'pl', 'Elamicki') }
        );

        # Ewe
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ee', 'language', 'Ewe', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ee', 'ewe') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ee', 'language', 'en', 'Ewe') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ee', 'language', 'pl', 'Ewe') }
        );

        # Ewondo
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ewo', 'language', 'Ewondo', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ewo', 'ewo') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ewo', 'language', 'en', 'Ewondo') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ewo', 'language', 'pl', 'Ewondo') }
        );

        # Fang
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('fan', 'language', 'Fang', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('fan', 'fan') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('fan', 'language', 'en', 'Fang') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('fan', 'language', 'pl', 'Fang') }
        );

        # Fanti
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('fat', 'language', 'Fanti', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('fat', 'fat') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('fat', 'language', 'en', 'Fanti') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('fat', 'language', 'pl', 'Fante') }
        );

        # Fijian
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('fj', 'language', 'Fijian', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('fj', 'fij') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('fj', 'language', 'en', 'Fijian') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('fj', 'language', 'pl', 'Fidżyjski') }
        );

        # Filipino
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('fil', 'language', 'Filipino', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('fil', 'fil') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('fil', 'language', 'en', 'Filipino') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('fil', 'language', 'pl', 'Filipiński (pilipino)') }
        );

        # Finno
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('fiu', 'language', 'Finno', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('fiu', 'fiu') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('fiu', 'language', 'en', 'Finno') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('fiu', 'language', 'pl', 'Ugrofińskie (inne)') }
        );

        # Fon
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('fon', 'language', 'Fon', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('fon', 'fon') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('fon', 'language', 'en', 'Fon') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('fon', 'language', 'pl', 'Fon') }
        );

        # Frisian
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('fy', 'language', 'Frisian', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('fy', 'fry') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('fy', 'language', 'en', 'Frisian') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('fy', 'language', 'pl', 'Fryzyjski') }
        );

        # Fula
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ff', 'language', 'Fula', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ff', 'ful') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ff', 'language', 'en', 'Fula') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ff', 'language', 'pl', 'Fulani') }
        );

        # Gã
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('gaa', 'language', 'Gã', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('gaa', 'gaa') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('gaa', 'language', 'en', 'Gã') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('gaa', 'language', 'pl', 'Ga') }
        );

        # Gilbertese
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('gil', 'language', 'Gilbertese', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('gil', 'gil') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('gil', 'language', 'en', 'Gilbertese') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('gil', 'language', 'pl', 'Gilbertański') }
        );

        # Manx
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('gv', 'language', 'Manx', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('gv', 'glv') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('gv', 'language', 'en', 'Manx') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('gv', 'language', 'pl', 'Mański (manx)') }
        );

        # Grebo
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('grb', 'language', 'Grebo', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('grb', 'grb') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('grb', 'language', 'en', 'Grebo') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('grb', 'language', 'pl', 'Grebo') }
        );

        # Guarani
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('gn', 'language', 'Guarani', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('gn', 'grn') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('gn', 'language', 'en', 'Guarani') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('gn', 'language', 'pl', 'Guarani') }
        );

        # Swiss German
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('gsw', 'language', 'Swiss German', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('gsw', 'gsw') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('gsw', 'language', 'en', 'Swiss German') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('gsw', 'language', 'pl', 'Niemiecki szwajcarski') }
        );

        # Gujarati
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('gu', 'language', 'Gujarati', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('gu', 'guj') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('gu', 'language', 'en', 'Gujarati') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('gu', 'language', 'pl', 'Gudźarati') }
        );

        # Haitian French Creole
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ht', 'language', 'Haitian French Creole', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ht', 'hat') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ht', 'language', 'en', 'Haitian French Creole') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ht', 'language', 'pl', 'Haitański') }
        );

        # Hawaiian
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('haw', 'language', 'Hawaiian', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('haw', 'haw') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('haw', 'language', 'en', 'Hawaiian') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('haw', 'language', 'pl', 'Hawajski') }
        );

        # Western Pahari languages
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('him', 'language', 'Western Pahari languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('him', 'him') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('him', 'language', 'en', 'Western Pahari languages') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('him', 'language', 'pl', 'Pahari zachodnie, języki (himachali)') }
        );

        # Hmong
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('hmn', 'language', 'Hmong', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('hmn', 'hmn') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('hmn', 'language', 'en', 'Hmong') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('hmn', 'language', 'pl', 'Hmong') }
        );

        # Hiri Motu
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ho', 'language', 'Hiri Motu', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ho', 'hmo') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ho', 'language', 'en', 'Hiri Motu') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ho', 'language', 'pl', 'Hiri motu') }
        );

        # Igbo
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ig', 'language', 'Igbo', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ig', 'ibo') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ig', 'language', 'en', 'Igbo') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ig', 'language', 'pl', 'Igbo') }
        );

        # Ido
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('io', 'language', 'Ido', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('io', 'ido') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('io', 'language', 'en', 'Ido') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('io', 'language', 'pl', 'Ido') }
        );

        # Ijo
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ijo', 'language', 'Ijo', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ijo', 'ijo') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ijo', 'language', 'en', 'Ijo') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ijo', 'language', 'pl', 'Ijo') }
        );

        # Interlingue
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ie', 'language', 'Interlingue', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ie', 'ile') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ie', 'language', 'en', 'Interlingue') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ie', 'language', 'pl', 'Interlingwe (język sztuczny)') }
        );

        # Interlingua (International Auxiliary Language Association)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ia', 'language', 'Interlingua (International Auxiliary Language Association)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ia', 'ina') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ia', 'language', 'en', 'Interlingua (International Auxiliary Language Association)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ia', 'language', 'pl', 'Interlingwa (Miedzynarodowy Język Pomocniczy)') }
        );

        # Indo
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ine', 'language', 'Indo', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ine', 'ine') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ine', 'language', 'en', 'Indo') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ine', 'language', 'pl', 'Indoeuropejskie (inne)') }
        );

        # Ingush
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('inh', 'language', 'Ingush', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('inh', 'inh') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('inh', 'language', 'en', 'Ingush') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('inh', 'language', 'pl', 'Inguski') }
        );

        # Iroquoian (Other)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('iro', 'language', 'Iroquoian (Other)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('iro', 'iro') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('iro', 'language', 'en', 'Iroquoian (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('iro', 'language', 'pl', 'Irokeskie (inne)') }
        );

        # Javanese
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('jv', 'language', 'Javanese', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('jv', 'jav') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('jv', 'language', 'en', 'Javanese') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('jv', 'language', 'pl', 'Jawajski') }
        );

        # Judeo
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('jpr', 'language', 'Judeo', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('jpr', 'jpr') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('jpr', 'language', 'en', 'Judeo') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('jpr', 'language', 'pl', 'Judeo-perski') }
        );

        # Kara
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('kaa', 'language', 'Kara', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('kaa', 'kaa') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kaa', 'language', 'en', 'Kara') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kaa', 'language', 'pl', 'Karakałpacki') }
        );

        # Kabyle
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('kab', 'language', 'Kabyle', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('kab', 'kab') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kab', 'language', 'en', 'Kabyle') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kab', 'language', 'pl', 'Kabylski') }
        );

        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kl', 'language', 'pl', 'Kalaallisut (grenlandzki)') }
        );

        # Kamba
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('kam', 'language', 'Kamba', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('kam', 'kam') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kam', 'language', 'en', 'Kamba') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kam', 'language', 'pl', 'Kamba') }
        );

        # Karen languages
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('kar', 'language', 'Karen languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('kar', 'kar') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kar', 'language', 'en', 'Karen languages') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kar', 'language', 'pl', 'Kareńskie') }
        );

        # Kanuri
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('kr', 'language', 'Kanuri', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('kr', 'kau') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kr', 'language', 'en', 'Kanuri') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kr', 'language', 'pl', 'Kanuri') }
        );

        # Kawi
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('kaw', 'language', 'Kawi', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('kaw', 'kaw') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kaw', 'language', 'en', 'Kawi') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kaw', 'language', 'pl', 'Kawi') }
        );

        # Kabardian
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('kbd', 'language', 'Kabardian', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('kbd', 'kbd') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kbd', 'language', 'en', 'Kabardian') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kbd', 'language', 'pl', 'Kabardyjski') }
        );

        # Khoisan (Other)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('khi', 'language', 'Khoisan (Other)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('khi', 'khi') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('khi', 'language', 'en', 'Khoisan (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('khi', 'language', 'pl', 'Khoisan, języki (inne)') }
        );

        # Kikuyu
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ki', 'language', 'Kikuyu', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ki', 'kik') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ki', 'language', 'en', 'Kikuyu') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ki', 'language', 'pl', 'Kikuju') }
        );

        # Kyrgyz
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ky', 'language', 'Kyrgyz', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ky', 'kir') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ky', 'language', 'en', 'Kyrgyz') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ky', 'language', 'pl', 'Kirgiski') }
        );

        # Konkani
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('kok', 'language', 'Konkani', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('kok', 'kok') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kok', 'language', 'en', 'Konkani') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kok', 'language', 'pl', 'Konkani') }
        );

        # Komi
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('kv', 'language', 'Komi', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('kv', 'kom') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kv', 'language', 'en', 'Komi') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kv', 'language', 'pl', 'Komi') }
        );

        # Kongo
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('kg', 'language', 'Kongo', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('kg', 'kon') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kg', 'language', 'en', 'Kongo') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kg', 'language', 'pl', 'Kongo') }
        );

        # Karachay
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('krc', 'language', 'Karachay', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('krc', 'krc') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('krc', 'language', 'en', 'Karachay') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('krc', 'language', 'pl', 'Karaczajsko-bałkarski') }
        );

        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('krl', 'language', 'pl', 'Karelski') }
        );

        # Kumyk
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('kum', 'language', 'Kumyk', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('kum', 'kum') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kum', 'language', 'en', 'Kumyk') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('kum', 'language', 'pl', 'Kumycki') }
        );

        # Lahndā
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('lah', 'language', 'Lahndā', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('lah', 'lah') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('lah', 'language', 'en', 'Lahndā') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('lah', 'language', 'pl', 'Lahnda') }
        );

        # Lamba (Zambia and Congo)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('lam', 'language', 'Lamba (Zambia and Congo)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('lam', 'lam') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('lam', 'language', 'en', 'Lamba (Zambia and Congo)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('lam', 'language', 'pl', 'Lamba (Zambia i Kongo)') }
        );

        # Limburgish
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('li', 'language', 'Limburgish', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('li', 'lim') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('li', 'language', 'en', 'Limburgish') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('li', 'language', 'pl', 'Limburski') }
        );

        # Mongo
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('lol', 'language', 'Mongo', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('lol', 'lol') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('lol', 'language', 'en', 'Mongo') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('lol', 'language', 'pl', 'Mongo-nkundu') }
        );

        # Luxembourgish
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('lb', 'language', 'Luxembourgish', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('lb', 'ltz') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('lb', 'language', 'en', 'Luxembourgish') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('lb', 'language', 'pl', 'Luksemburski') }
        );

        # Luba
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('lu', 'language', 'Luba', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('lu', 'lua') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('lu', 'language', 'en', 'Luba') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('lu', 'language', 'pl', 'Luba-lulua (kasai)') }
        );

        # Ganda
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('lg', 'language', 'Ganda', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('lg', 'lug') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('lg', 'language', 'en', 'Ganda') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('lg', 'language', 'pl', 'Ganda') }
        );

        # Luiseño
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('lui', 'language', 'Luiseño', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('lui', 'lui') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('lui', 'language', 'en', 'Luiseño') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('lui', 'language', 'pl', 'Luiseno') }
        );

        # Lunda
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('lun', 'language', 'Lunda', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('lun', 'lun') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('lun', 'language', 'en', 'Lunda') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('lun', 'language', 'pl', 'Lunda') }
        );

        # Luo (Kenya and Tanzania)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('luo', 'language', 'Luo (Kenya and Tanzania)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('luo', 'luo') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('luo', 'language', 'en', 'Luo (Kenya and Tanzania)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('luo', 'language', 'pl', 'Luo (Kenia i Tanzania)') }
        );

        # Lushai
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('lus', 'language', 'Lushai', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('lus', 'lus') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('lus', 'language', 'en', 'Lushai') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('lus', 'language', 'pl', 'Lushai') }
        );

        # Madurese
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('mad', 'language', 'Madurese', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('mad', 'mad') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mad', 'language', 'en', 'Madurese') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mad', 'language', 'pl', 'Madurski') }
        );

        # Maithili
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('mai', 'language', 'Maithili', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('mai', 'mai') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mai', 'language', 'en', 'Maithili') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mai', 'language', 'pl', 'Maithili') }
        );

        # Mandingo
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('man', 'language', 'Mandingo', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('man', 'man') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('man', 'language', 'en', 'Mandingo') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('man', 'language', 'pl', 'Mandingo') }
        );

        # Austronesian (Other)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('map', 'language', 'Austronesian (Other)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('map', 'map') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('map', 'language', 'en', 'Austronesian (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('map', 'language', 'pl', 'Austronezyjskie (malajo-polinezyjskie) (inne)') }
        );

        # Maasai
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('mas', 'language', 'Maasai', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('mas', 'mas') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mas', 'language', 'en', 'Maasai') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mas', 'language', 'pl', 'Masajski') }
        );

        # Moksha
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('mdf', 'language', 'Moksha', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('mdf', 'mdf') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mdf', 'language', 'en', 'Moksha') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mdf', 'language', 'pl', 'Moksza') }
        );

        # Mandar
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('mdr', 'language', 'Mandar', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('mdr', 'mdr') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mdr', 'language', 'en', 'Mandar') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mdr', 'language', 'pl', 'Mandarski') }
        );

        # Mende
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('men', 'language', 'Mende', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('men', 'men') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('men', 'language', 'en', 'Mende') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('men', 'language', 'pl', 'Mende') }
        );

        # Mon
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('mnw', 'language', 'Mon', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('mnw', 'mkh') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mnw', 'language', 'en', 'Mon') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mnw', 'language', 'pl', 'Mon-khmerskie (inne)') }
        );

        # Manchu
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('mnc', 'language', 'Manchu', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('mnc', 'mnc') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mnc', 'language', 'en', 'Manchu') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mnc', 'language', 'pl', 'Mandżurski') }
        );

        # Mooré
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('mos', 'language', 'Mooré', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('mos', 'mos') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mos', 'language', 'en', 'Mooré') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mos', 'language', 'pl', 'Mossi (mooré)') }
        );

        # Munda (Other)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('mun', 'language', 'Munda (Other)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('mun', 'mun') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mun', 'language', 'en', 'Munda (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mun', 'language', 'pl', 'Mundajskie (inne)') }
        );

        # Creek
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('mus', 'language', 'Creek', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('mus', 'mus') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mus', 'language', 'en', 'Creek') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mus', 'language', 'pl', 'Creek (muskogi)') }
        );

        # Mirandese
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('mwl', 'language', 'Mirandese', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('mwl', 'mwl') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mwl', 'language', 'en', 'Mirandese') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('mwl', 'language', 'pl', 'Mirandyjski') }
        );

        # Erzya
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('myv', 'language', 'Erzya', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('myv', 'myv') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('myv', 'language', 'en', 'Erzya') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('myv', 'language', 'pl', 'Erzja') }
        );

        # North American Indian (Other)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('nai', 'language', 'North American Indian (Other)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('nai', 'nai') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nai', 'language', 'en', 'North American Indian (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nai', 'language', 'pl', 'Indian północnoamerykańskich (inne)') }
        );

        # Neapolitan Italian
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('nap', 'language', 'Neapolitan Italian', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('nap', 'nap') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nap', 'language', 'en', 'Neapolitan Italian') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nap', 'language', 'pl', 'Neapolitański') }
        );

        # Nauru
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('na', 'language', 'Nauru', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('na', 'nau') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('na', 'language', 'en', 'Nauru') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('na', 'language', 'pl', 'Nauru') }
        );

        # Navajo
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('nv', 'language', 'Navajo', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('nv', 'nav') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nv', 'language', 'en', 'Navajo') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nv', 'language', 'pl', 'Nawaho') }
        );

        # Ndebele (Zimbabwe)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('nd', 'language', 'Ndebele (Zimbabwe)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('nd', 'nde') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nd', 'language', 'en', 'Ndebele (Zimbabwe)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nd', 'language', 'pl', 'Ndebele północny (Zimbabwe)') }
        );

        # Newari
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('new', 'language', 'Newari', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('new', 'new') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('new', 'language', 'en', 'Newari') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('new', 'language', 'pl', 'Newarski') }
        );

        # Nias
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('nia', 'language', 'Nias', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('nia', 'nia') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nia', 'language', 'en', 'Nias') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nia', 'language', 'pl', 'Nias') }
        );

        # Niger
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('nic', 'language', 'Niger', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('nic', 'nic') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nic', 'language', 'en', 'Niger') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nic', 'language', 'pl', 'Nigero-kongijskie (kongo-kordofańskie) (inne)') }
        );

        # Niuean
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('niu', 'language', 'Niuean', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('niu', 'niu') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('niu', 'language', 'en', 'Niuean') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('niu', 'language', 'pl', 'Niue') }
        );

        # Nogai
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('nog', 'language', 'Nogai', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('nog', 'nog') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nog', 'language', 'en', 'Nogai') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nog', 'language', 'pl', 'Nogajski') }
        );

        # Old Norse
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('non', 'language', 'Old Norse', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('non', 'non') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('non', 'language', 'en', 'Old Norse') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('non', 'language', 'pl', 'Staronordyjski') }
        );

        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('no', 'language', 'pl', 'Norweski') }
        );

        # Northern Sotho
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('nso', 'language', 'Northern Sotho', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('nso', 'nso') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nso', 'language', 'en', 'Northern Sotho') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nso', 'language', 'pl', 'Sotho północny') }
        );

        # Nubian languages
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('nub', 'language', 'Nubian languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('nub', 'nub') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nub', 'language', 'en', 'Nubian languages') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nub', 'language', 'pl', 'Nubijskie') }
        );

        # Nyankole
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('nyn', 'language', 'Nyankole', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('nyn', 'nyn') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nyn', 'language', 'en', 'Nyankole') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('nyn', 'language', 'pl', 'Nyankole') }
        );

        # Occitan (post-1500)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('oc', 'language', 'Occitan (post-1500)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('oc', 'oci') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('oc', 'language', 'en', 'Occitan (post-1500)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('oc', 'language', 'pl', 'Prowansalski (oksytański)') }
        );

        # Ojibwa
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('oj', 'language', 'Ojibwa', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('oj', 'oji') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('oj', 'language', 'en', 'Ojibwa') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('oj', 'language', 'pl', 'Odżibwa') }
        );

        # Oriya
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('or', 'language', 'Oriya', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('or', 'ori') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('or', 'language', 'en', 'Oriya') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('or', 'language', 'pl', 'Orija') }
        );

        # Oromo
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('om', 'language', 'Oromo', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('om', 'orm') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('om', 'language', 'en', 'Oromo') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('om', 'language', 'pl', 'Oromo') }
        );

        # Ossetic
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('os', 'language', 'Ossetic', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('os', 'oss') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('os', 'language', 'en', 'Ossetic') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('os', 'language', 'pl', 'Osetyjski') }
        );

        # Otomian languages
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('oto', 'language', 'Otomian languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('oto', 'oto') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('oto', 'language', 'en', 'Otomian languages') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('oto', 'language', 'pl', 'Otomi-mangue, języki (otomang)') }
        );

        # Papuan (Other)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('paa', 'language', 'Papuan (Other)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('paa', 'paa') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('paa', 'language', 'en', 'Papuan (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('paa', 'language', 'pl', 'Papuaskie (inne)') }
        );

        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('pa', 'language', 'pl', 'Pendżabski') }
        );

        # Papiamento
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('pap', 'language', 'Papiamento', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('pap', 'pap') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('pap', 'language', 'en', 'Papiamento') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('pap', 'language', 'pl', 'Papiamento') }
        );

        # Philippine (Other)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('phi', 'language', 'Philippine (Other)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('phi', 'phi') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('phi', 'language', 'en', 'Philippine (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('phi', 'language', 'pl', 'Filipińskie (inne)') }
        );

        # Phoenician
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('phn', 'language', 'Phoenician', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('phn', 'phn') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('phn', 'language', 'en', 'Phoenician') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('phn', 'language', 'pl', 'Fenicki') }
        );

        # Pohnpeian
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('pon', 'language', 'Pohnpeian', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('pon', 'pon') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('pon', 'language', 'en', 'Pohnpeian') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('pon', 'language', 'pl', 'Ponape') }
        );

        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ps', 'language', 'pl', 'Paszto (pusztu)') }
        );

        # Rajasthani
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('raj', 'language', 'Rajasthani', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('raj', 'raj') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('raj', 'language', 'en', 'Rajasthani') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('raj', 'language', 'pl', 'Radźastani') }
        );

        # Rapanui
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('rap', 'language', 'Rapanui', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('rap', 'rap') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('rap', 'language', 'en', 'Rapanui') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('rap', 'language', 'pl', 'Rapanui') }
        );

        # Raeto
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('rm', 'language', 'Raeto', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('rm', 'roh') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('rm', 'language', 'en', 'Raeto') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('rm', 'language', 'pl', 'Retoromański (romansz)') }
        );

        # Rundi
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('rn', 'language', 'Rundi', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('rn', 'run') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('rn', 'language', 'en', 'Rundi') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('rn', 'language', 'pl', 'Rundi') }
        );

        # Aromanian
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('rup', 'language', 'Aromanian', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('rup', 'rup') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('rup', 'language', 'en', 'Aromanian') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('rup', 'language', 'pl', 'Arumuński') }
        );

        # Sango (Ubangi Creole)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('sg', 'language', 'Sango (Ubangi Creole)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('sg', 'sag') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sg', 'language', 'en', 'Sango (Ubangi Creole)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sg', 'language', 'pl', 'Sango') }
        );

        # Yakut
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('sah', 'language', 'Yakut', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('sah', 'sah') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sah', 'language', 'en', 'Yakut') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sah', 'language', 'pl', 'Jakucki') }
        );

        # South American Indian (Other)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('sai', 'language', 'South American Indian (Other)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('sai', 'sai') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sai', 'language', 'en', 'South American Indian (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sai', 'language', 'pl', 'Indian południowoamerykańskich (inne)') }
        );

        # Salishan languages
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('sal', 'language', 'Salishan languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('sal', 'sal') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sal', 'language', 'en', 'Salishan languages') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sal', 'language', 'pl', 'Salisz, języki') }
        );

        # Sasak
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('sas', 'language', 'Sasak', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('sas', 'sas') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sas', 'language', 'en', 'Sasak') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sas', 'language', 'pl', 'Sasak') }
        );

        # Santali
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('sat', 'language', 'Santali', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('sat', 'sat') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sat', 'language', 'en', 'Santali') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sat', 'language', 'pl', 'Santali') }
        );

        # Sicilian Italian
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('scn', 'language', 'Sicilian Italian', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('scn', 'scn') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('scn', 'language', 'en', 'Sicilian Italian') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('scn', 'language', 'pl', 'Sycylijski') }
        );

        # Scots
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('sco', 'language', 'Scots', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('sco', 'sco') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sco', 'language', 'en', 'Scots') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sco', 'language', 'pl', 'Szkocki') }
        );

        # Selkup
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('sel', 'language', 'Selkup', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('sel', 'sel') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sel', 'language', 'en', 'Selkup') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sel', 'language', 'pl', 'Selkupski') }
        );

        # Irish, Old (to 1100)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('sga', 'language', 'Irish, Old (to 1100)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('sga', 'sga') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sga', 'language', 'en', 'Irish, Old (to 1100)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sga', 'language', 'pl', 'Staroirlandzki (do 1100)') }
        );

        # Sign languages
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('sgn', 'language', 'Sign languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('sgn', 'sgn') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sgn', 'language', 'en', 'Sign languages') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sgn', 'language', 'pl', 'Migowe, języki') }
        );

        # Shan
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('shn', 'language', 'Shan', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('shn', 'shn') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('shn', 'language', 'en', 'Shan') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('shn', 'language', 'pl', 'Szan') }
        );

        # Sinhalese
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('si', 'language', 'Sinhalese', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('si', 'sin') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('si', 'language', 'en', 'Sinhalese') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('si', 'language', 'pl', 'Syngaleski') }
        );

        # Siouan (Other)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('sio', 'language', 'Siouan (Other)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('sio', 'sio') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sio', 'language', 'en', 'Siouan (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sio', 'language', 'pl', 'Siouańskie (języki Siuksów) (inne)') }
        );

        # Sino
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('sit', 'language', 'Sino', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('sit', 'sit') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sit', 'language', 'en', 'Sino') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sit', 'language', 'pl', 'Chińsko-tybetańskie (inne)') }
        );

        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sma', 'language', 'pl', 'Lapoński południowy') }
        );

        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sme', 'language', 'pl', 'Lapoński północny') }
        );

        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('smi', 'language', 'pl', 'Lapońskie (inne)') }
        );

        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('smj', 'language', 'pl', 'Lapoński lule') }
        );

        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('smn', 'language', 'pl', 'Lapoński inari') }
        );

        # Samoan
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('sm', 'language', 'Samoan', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('sm', 'smo') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sm', 'language', 'en', 'Samoan') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sm', 'language', 'pl', 'Samoański') }
        );

        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sms', 'language', 'pl', 'Lapoński skolt') }
        );

        # Shona
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('sn', 'language', 'Shona', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('sn', 'sna') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sn', 'language', 'en', 'Shona') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sn', 'language', 'pl', 'Szona') }
        );

        # Soninke
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('snk', 'language', 'Soninke', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('snk', 'snk') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('snk', 'language', 'en', 'Soninke') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('snk', 'language', 'pl', 'Soninke') }
        );

        # Sogdian
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('sog', 'language', 'Sogdian', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('sog', 'sog') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sog', 'language', 'en', 'Sogdian') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sog', 'language', 'pl', 'Sogdyjski') }
        );

        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('so', 'language', 'pl', 'Somalijski') }
        );

        # Songhai
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('son', 'language', 'Songhai', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('son', 'son') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('son', 'language', 'en', 'Songhai') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('son', 'language', 'pl', 'Songhaj') }
        );

        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('st', 'language', 'pl', 'Sotho południowy') }
        );

        # Sardinian
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('sc', 'language', 'Sardinian', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('sc', 'srd') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sc', 'language', 'en', 'Sardinian') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('sc', 'language', 'pl', 'Sardyński') }
        );

        # Nilo
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ssa', 'language', 'Nilo', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ssa', 'ssa') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ssa', 'language', 'en', 'Nilo') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ssa', 'language', 'pl', 'Nilo-saharyjskie (inne)') }
        );

        # Sundanese
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('su', 'language', 'Sundanese', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('su', 'sun') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('su', 'language', 'en', 'Sundanese') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('su', 'language', 'pl', 'Sundajski') }
        );

        # Tahitian
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ty', 'language', 'Tahitian', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ty', 'tah') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ty', 'language', 'en', 'Tahitian') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ty', 'language', 'pl', 'Tahitański') }
        );

        # Tai (Other)
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('tai', 'language', 'Tai (Other)', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('tai', 'tai') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tai', 'language', 'en', 'Tai (Other)') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tai', 'language', 'pl', 'Tajskie (inne)') }
        );

        # Telugu
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('te', 'language', 'Telugu', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('te', 'tel') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('te', 'language', 'en', 'Telugu') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('te', 'language', 'pl', 'Telugu') }
        );

        # Tajik
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('tg', 'language', 'Tajik', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('tg', 'tgk') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tg', 'language', 'en', 'Tajik') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tg', 'language', 'pl', 'Tadżycki') }
        );

        # Tigré
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('tig', 'language', 'Tigré', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('tig', 'tig') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tig', 'language', 'en', 'Tigré') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tig', 'language', 'pl', 'Tigre') }
        );

        # Tiv
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('tiv', 'language', 'Tiv', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('tiv', 'tiv') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tiv', 'language', 'en', 'Tiv') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tiv', 'language', 'pl', 'Tiw') }
        );

        # Tokelauan
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('tkl', 'language', 'Tokelauan', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('tkl', 'tkl') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tkl', 'language', 'en', 'Tokelauan') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tkl', 'language', 'pl', 'Tokelau') }
        );

        # Tlingit
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('tli', 'language', 'Tlingit', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('tli', 'tli') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tli', 'language', 'en', 'Tlingit') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tli', 'language', 'pl', 'Tlingit') }
        );

        # Tamashek
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('tmh', 'language', 'Tamashek', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('tmh', 'tmh') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tmh', 'language', 'en', 'Tamashek') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tmh', 'language', 'pl', 'Tamaszek (tuareski)') }
        );

        # Tongan
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('to', 'language', 'Tongan', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('to', 'ton') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('to', 'language', 'en', 'Tongan') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('to', 'language', 'pl', 'Tongijski') }
        );

        # Tok Pisin
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('tpi', 'language', 'Tok Pisin', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('tpi', 'tpi') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tpi', 'language', 'en', 'Tok Pisin') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tpi', 'language', 'pl', 'Neomelanezyjski (tok pisin)') }
        );

        # Tsimshian
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('tsi', 'language', 'Tsimshian', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('tsi', 'tsi') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tsi', 'language', 'en', 'Tsimshian') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tsi', 'language', 'pl', 'Tsimshian') }
        );

        # Tswana
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('tn', 'language', 'Tswana', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('tn', 'tsn') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tn', 'language', 'en', 'Tswana') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tn', 'language', 'pl', 'Tswana') }
        );

        # Tsonga
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ts', 'language', 'Tsonga', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ts', 'tso') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ts', 'language', 'en', 'Tsonga') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ts', 'language', 'pl', 'Tsonga') }
        );

        # Tumbuka
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('tum', 'language', 'Tumbuka', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('tum', 'tum') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tum', 'language', 'en', 'Tumbuka') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tum', 'language', 'pl', 'Tumbuka') }
        );

        # Tupi languages
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('tup', 'language', 'Tupi languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('tup', 'tup') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tup', 'language', 'en', 'Tupi languages') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tup', 'language', 'pl', 'Tupi, języki') }
        );

        # Twi
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('tw', 'language', 'Twi', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('tw', 'twi') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tw', 'language', 'en', 'Twi') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tw', 'language', 'pl', 'Twi (aszanti)') }
        );

        # Tuvinian
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('tyv', 'language', 'Tuvinian', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('tyv', 'tyv') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tyv', 'language', 'en', 'Tuvinian') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('tyv', 'language', 'pl', 'Tuwiński') }
        );

        # Udmurt
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('udm', 'language', 'Udmurt', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('udm', 'udm') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('udm', 'language', 'en', 'Udmurt') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('udm', 'language', 'pl', 'Udmurcki (wotiacki)') }
        );

        # Uighur
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ug', 'language', 'Uighur', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ug', 'uig') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ug', 'language', 'en', 'Uighur') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ug', 'language', 'pl', 'Ujgurski') }
        );

        # Umbundu
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('umb', 'language', 'Umbundu', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('umb', 'umb') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('umb', 'language', 'en', 'Umbundu') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('umb', 'language', 'pl', 'Umbundu') }
        );

        # Vai
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('vai', 'language', 'Vai', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('vai', 'vai') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('vai', 'language', 'en', 'Vai') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('vai', 'language', 'pl', 'Vai') }
        );

        # Venda
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ve', 'language', 'Venda', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ve', 'ven') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ve', 'language', 'en', 'Venda') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ve', 'language', 'pl', 'Venda') }
        );

        # Volapük
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('vo', 'language', 'Volapük', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('vo', 'vol') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('vo', 'language', 'en', 'Volapük') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('vo', 'language', 'pl', 'Volapük') }
        );

        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('vot', 'language', 'pl', 'Wocki') }
        );

        # Wakashan languages
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('wak', 'language', 'Wakashan languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('wak', 'wak') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('wak', 'language', 'en', 'Wakashan languages') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('wak', 'language', 'pl', 'Wakasz, języki') }
        );

        # Washoe
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('was', 'language', 'Washoe', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('was', 'was') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('was', 'language', 'en', 'Washoe') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('was', 'language', 'pl', 'Washo') }
        );

        # Walloon
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('wa', 'language', 'Walloon', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('wa', 'wln') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('wa', 'language', 'en', 'Walloon') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('wa', 'language', 'pl', 'Waloński') }
        );

        # Wolof
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('wo', 'language', 'Wolof', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('wo', 'wol') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('wo', 'language', 'en', 'Wolof') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('wo', 'language', 'pl', 'Wolof') }
        );

        # Oirat
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('xal', 'language', 'Oirat', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('xal', 'xal') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('xal', 'language', 'en', 'Oirat') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('xal', 'language', 'pl', 'Ojracki (kałmucki)') }
        );

        # Xhosa
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('xh', 'language', 'Xhosa', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('xh', 'xho') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('xh', 'language', 'en', 'Xhosa') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('xh', 'language', 'pl', 'Xhosa (khosa)') }
        );

        # Yapese
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('yap', 'language', 'Yapese', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('yap', 'yap') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('yap', 'language', 'en', 'Yapese') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('yap', 'language', 'pl', 'Japski') }
        );

        # Yupik languages
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('ypk', 'language', 'Yupik languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('ypk', 'ypk') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ypk', 'language', 'en', 'Yupik languages') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('ypk', 'language', 'pl', 'Jupik, języki') }
        );

        # Zapotec
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('zap', 'language', 'Zapotec', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('zap', 'zap') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('zap', 'language', 'en', 'Zapotec') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('zap', 'language', 'pl', 'Zapoteckie') }
        );

        # Zande languages
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('znd', 'language', 'Zande languages', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('znd', 'znd') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('znd', 'language', 'en', 'Zande languages') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('znd', 'language', 'pl', 'Zande, języki') }
        );

        # Zulu
        $dbh->do(
            q{ INSERT IGNORE INTO language_subtag_registry (subtag, type, description, added) VALUES ('zu', 'language', 'Zulu', now()) }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES ('zu', 'zul') });
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('zu', 'language', 'en', 'Zulu') }
        );
        $dbh->do(
            q{ INSERT IGNORE INTO language_descriptions (subtag, type, lang, description) VALUES ('zu', 'language', 'pl', 'Zulu') }
        );

        say_success( $out, "Added more new languages" );
    },
};
