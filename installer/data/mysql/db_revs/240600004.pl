use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "18493",
    description => "Add missing languages to search options",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Greenlandic
        $dbh->do(
            q{INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'kl', 'language', 'Greenlandic', 'NOW()')}
            ) == 1
            && say_success( $out, "Added language_subtag_registry for Greenlandic" );
        $dbh->do(q{INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'kl', 'kal')})
            == 1 && say_success( $out, "Added language_rfc4646_to_iso639 for Greenlandic" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'kl', 'language', 'en', 'Greenlandic')}
            ) == 1
            && say_success( $out, "Added english language description for Greenlandic" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'kl', 'language', 'kl', 'Kalaallisut')}
            ) == 1
            && say_success( $out, "Added native language description for Greenlandic" );

        # Karelian
        $dbh->do(
            q{INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'krl', 'language', 'Karelian', 'NOW()')}
            ) == 1
            && say_success( $out, "Added language_subtag_registry for Karelian" );
        $dbh->do(q{INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'krl', 'krl')})
            == 1 && say_success( $out, "Added language_rfc4646_to_iso639 for Karelian" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'krl', 'language', 'en', 'Karelian')}
            ) == 1
            && say_success( $out, "Added english language description for Karelian" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'krl', 'language', 'krl', 'Karjala')}
            ) == 1
            && say_success( $out, "Added native language description for Karelian" );

        # Cornish
        $dbh->do(
            q{INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'kw', 'language', 'Cornish', 'NOW()')}
            ) == 1
            && say_success( $out, "Added language_subtag_registry for Cornish" );
        $dbh->do(q{INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'kw', 'cor')})
            == 1 && say_success( $out, "Added language_rfc4646_to_iso639 for Cornish" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'kw', 'language', 'en', 'Cornish')}
            ) == 1
            && say_success( $out, "Added english language description for Cornish" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'kw', 'language', 'kw', 'Kernowek')}
            ) == 1
            && say_success( $out, "Added native language description for Cornish" );

        # Burmese
        $dbh->do(
            q{INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'my', 'language', 'Burmese', 'NOW()')}
            ) == 1
            && say_success( $out, "Added language_subtag_registry for Burmese" );
        $dbh->do(q{INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'my', 'bur')})
            == 1 && say_success( $out, "Added language_rfc4646_to_iso639 for Burmese" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'my', 'language', 'en', 'Burmese')}
            ) == 1
            && say_success( $out, "Added english language description for Burmese" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'my', 'language', 'my', 'မြန်မာစာ')}
            ) == 1
            && say_success( $out, "Added native language description for Burmese" );

        # Punjabi
        $dbh->do(
            q{INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'pa', 'language', 'Punjabi', 'NOW()')}
            ) == 1
            && say_success( $out, "Added language_subtag_registry for Punjabi" );
        $dbh->do(q{INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'pa', 'pan')})
            == 1 && say_success( $out, "Added language_rfc4646_to_iso639 for Punjabi" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'pa', 'language', 'en', 'Punjabi')}
            ) == 1
            && say_success( $out, "Added english language description for Punjabi" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'pa', 'language', 'pa', 'پنجابی')}
            ) == 1
            && say_success( $out, "Added native language description for Punjabi" );

        # Pashto
        $dbh->do(
            q{INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'ps', 'language', 'Pashto', 'NOW()')}
            ) == 1
            && say_success( $out, "Added language_subtag_registry for Pashto" );
        $dbh->do(q{INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'ps', 'pus')})
            == 1 && say_success( $out, "Added language_rfc4646_to_iso639 for Pashto" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ps', 'language', 'en', 'Pashto')}
            ) == 1
            && say_success( $out, "Added english language description for Pashto" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ps', 'language', 'ps', 'پښتو')}
            ) == 1
            && say_success( $out, "Added native language description for Pashto" );

        # Finnish Kalo
        $dbh->do(q{INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES( 'rmf', 'rmf')})
            == 1 && say_success( $out, "Added language_rfc4646_to_iso639 for Finnish Kalo" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES( 'rmf', 'language', 'en', 'Finnish Kalo')}
            ) == 1
            && say_success( $out, "Added english language description for Finnish Kalo" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES( 'rmf', 'language', 'fi', 'Suomen romanikieli')}
            ) == 1
            && say_success( $out, "Added native language description for Finnish Kalo" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES( 'rmf', 'language', 'rmf', 'Fíntika Rómma')}
            ) == 1
            && say_success( $out, "Added native language description for Finnish Kalo" );

        # Akkala Sami
        $dbh->do(
            q{INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sia', 'language', 'Akkala Sami', 'NOW()')}
            ) == 1
            && say_success( $out, "Added language_subtag_registry for Akkala Sami" );
        $dbh->do(q{INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sia', 'sia')})
            == 1 && say_success( $out, "Added language_rfc4646_to_iso639 for Akkala Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sia', 'language', 'en', 'Akkala Sami')}
            ) == 1
            && say_success( $out, "Added english language description for Akkala Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sia', 'language', 'sia', 'ču´kksuâlis')}
            ) == 1
            && say_success( $out, "Added native language description for Akkala Sami" );

        # Kildin Sami
        $dbh->do(
            q{INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sjd', 'language', 'Kildin Sami', 'NOW()')}
            ) == 1
            && say_success( $out, "Added language_subtag_registry for Kildin Sami" );
        $dbh->do(q{INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sjd', 'sjd')})
            == 1 && say_success( $out, "Added language_rfc4646_to_iso639 for Kildin Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sjd', 'language', 'en', 'Kildin Sami')}
            ) == 1
            && say_success( $out, "Added english language description for Kildin Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sjd', 'language', 'sjd', 'Кӣллт са̄мь кӣлл')}
            ) == 1
            && say_success( $out, "Added native language description for Kildin Sami" );

        # Ter Sami
        $dbh->do(
            q{INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sjt', 'language', 'Ter Sami', 'NOW()')}
            ) == 1
            && say_success( $out, "Added language_subtag_registry for Ter Sami" );
        $dbh->do(q{INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sjt', 'sjt')})
            == 1 && say_success( $out, "Added language_rfc4646_to_iso639 for Ter Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sjt', 'language', 'en', 'Ter Sami')}
            ) == 1
            && say_success( $out, "Added english language description for Ter Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sjt', 'language', 'sjt', 'saa´mekiill')}
            ) == 1
            && say_success( $out, "Added native language description for Ter Sami" );

        # Pite Sami
        $dbh->do(
            q{INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sje', 'language', 'Pite Sami', 'NOW()')}
            ) == 1
            && say_success( $out, "Added language_subtag_registry for Pite Sami" );
        $dbh->do(q{INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sje', 'sje')})
            == 1 && say_success( $out, "Added language_rfc4646_to_iso639 for Pite Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sje', 'language', 'en', 'Pite Sami')}
            ) == 1
            && say_success( $out, "Added english language description for Pite Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sje', 'language', 'sje', 'Bidumsámegiella')}
            ) == 1
            && say_success( $out, "Added native language description for Pite Sami" );

        # Kemi Sami
        $dbh->do(
            q{INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sjk', 'language', 'Kemi Sami', 'NOW()')}
            ) == 1
            && say_success( $out, "Added language_subtag_registry for Kemi Sami" );
        $dbh->do(q{INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sjk', 'sjk')})
            == 1 && say_success( $out, "Added language_rfc4646_to_iso639 for Kemi Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sjk', 'language', 'en', 'Kemi Sami')}
            ) == 1
            && say_success( $out, "Added english language description for Kemi Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sjk', 'language', 'sjk', 'samääškiela')}
            ) == 1
            && say_success( $out, "Added native language description for Kemi Sami" );

        # Ume Sami
        $dbh->do(
            q{INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sju', 'language', 'Ume Sami', 'NOW()')}
            ) == 1
            && say_success( $out, "Added language_subtag_registry for Ume Sami" );
        $dbh->do(q{INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sju', 'sju')})
            == 1 && say_success( $out, "Added language_rfc4646_to_iso639 for Ume Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sju', 'language', 'en', 'Ume Sami')}
            ) == 1
            && say_success( $out, "Added english language description for Ume Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sju', 'language', 'sju', 'Ubmejensámien giella')}
            ) == 1
            && say_success( $out, "Added native language description for Ume Sami" );

        # Southern Sami
        $dbh->do(
            q{INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sma', 'language', 'Southern Sami', 'NOW()')}
            ) == 1
            && say_success( $out, "Added language_subtag_registry for Southern Sami" );
        $dbh->do(q{INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sma', 'sma')})
            == 1 && say_success( $out, "Added language_rfc4646_to_iso639 for Southern Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sma', 'language', 'en', 'Southern Sami')}
            ) == 1
            && say_success( $out, "Added english language description for Southern Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sma', 'language', 'sma', 'Åarjelsaemien gïele')}
            ) == 1
            && say_success( $out, "Added native language description for Southern Sami" );

        # Northern Sami
        $dbh->do(
            q{INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sme', 'language', 'Northern Sami', 'NOW()')}
            ) == 1
            && say_success( $out, "Added language_subtag_registry for Northern Sami" );
        $dbh->do(q{INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sme', 'sme')})
            == 1 && say_success( $out, "Added language_rfc4646_to_iso639 for Northern Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sme', 'language', 'en', 'Northern Sami')}
            ) == 1
            && say_success( $out, "Added english language description for Northern Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sme', 'language', 'fi', 'pohjoissaame')}
            ) == 1
            && say_success( $out, "Added native language description for Northern Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sme', 'language', 'sv', 'Nordsamiska')}
            ) == 1
            && say_success( $out, "Added native language description for Northern Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sme', 'language', 'sme', 'davvisámegiella')}
            ) == 1
            && say_success( $out, "Added native language description for Northern Sami" );

        # Sami languages
        $dbh->do(
            q{INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'smi', 'language', 'Sami languages', 'NOW()')}
            ) == 1
            && say_success( $out, "Added language_subtag_registry for Sami languages" );
        $dbh->do(q{INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'smi', 'smi')})
            == 1 && say_success( $out, "Added language_rfc4646_to_iso639 for Sami languages" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'smi', 'language', 'en', 'Sami languages')}
            ) == 1
            && say_success( $out, "Added english language description for Sami languages" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'smi', 'language', 'fi', 'saamelaiskielet')}
            ) == 1
            && say_success( $out, "Added native language description for Sami languages" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'smi', 'language', 'sv', 'Samiska')}
            ) == 1
            && say_success( $out, "Added native language description for Sami languages" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'smi', 'language', 'smi', 'Saami')}
            ) == 1
            && say_success( $out, "Added native language description for Sami languages" );

        # Lule Sami
        $dbh->do(
            q{INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'smj', 'language', 'Lule Sami', 'NOW()')}
            ) == 1
            && say_success( $out, "Added language_subtag_registry for Lule Sami" );
        $dbh->do(q{INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'smj', 'smj')})
            == 1 && say_success( $out, "Added language_rfc4646_to_iso639 for Lule Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'smj', 'language', 'en', 'Lule Sami')}
            ) == 1
            && say_success( $out, "Added english language description for Lule Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'smj', 'language', 'smj', 'julevsámegiella')}
            ) == 1
            && say_success( $out, "Added native language description for Lule Sami" );

        # Inari Sami
        $dbh->do(
            q{INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'smn', 'language', 'Inari Sami', 'NOW()')}
            ) == 1
            && say_success( $out, "Added language_subtag_registry for Inari Sami" );
        $dbh->do(q{INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'smn', 'smn')})
            == 1 && say_success( $out, "Added language_rfc4646_to_iso639 for Inari Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'smn', 'language', 'en', 'Inari Sami')}
            ) == 1
            && say_success( $out, "Added english language description for Inari Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'smn', 'language', 'smn', 'anarâškielâ')}
            ) == 1
            && say_success( $out, "Added native language description for Inari Sami" );

        # Skolt Sami
        $dbh->do(
            q{INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sms', 'language', 'Skolt Sami', 'NOW()')}
            ) == 1
            && say_success( $out, "Added language_subtag_registry for Skolt Sami" );
        $dbh->do(q{INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sms', 'sms')})
            == 1 && say_success( $out, "Added language_rfc4646_to_iso639 for Skolt Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sms', 'language', 'en', 'Skolt Sami')}
            ) == 1
            && say_success( $out, "Added english language description for Skolt Sami" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sms', 'language', 'sms', 'sääʹmǩiõll')}
            ) == 1
            && say_success( $out, "Added native language description for Skolt Sami" );

        # Somali
        $dbh->do(
            q{INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'so', 'language', 'Somali', 'NOW()')}
            ) == 1
            && say_success( $out, "Added language_subtag_registry for Somali" );
        $dbh->do(q{INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'so', 'som')})
            == 1 && say_success( $out, "Added language_rfc4646_to_iso639 for Somali" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'so', 'language', 'en', 'Somali')}
            ) == 1
            && say_success( $out, "Added english language description for Somali" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'so', 'language', 'so', 'Af-Soomaali')}
            ) == 1
            && say_success( $out, "Added native language description for Somali" );

        # Sotho
        $dbh->do(
            q{INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'st', 'language', 'Sotho', 'NOW()')}
            ) == 1
            && say_success( $out, "Added language_subtag_registry for Sotho" );
        $dbh->do(q{INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'st', 'sot')})
            == 1 && say_success( $out, "Added language_rfc4646_to_iso639 for Sotho" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'st', 'language', 'en', 'Sotho')}
            ) == 1
            && say_success( $out, "Added english language description for Sotho" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'st', 'language', 'st', 'Sesotho')}
            ) == 1
            && say_success( $out, "Added native language description for Sotho" );

        # Votic
        $dbh->do(
            q{INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'vot', 'language', 'Votic', 'NOW()')}
            ) == 1
            && say_success( $out, "Added language_subtag_registry for Votic" );
        $dbh->do(q{INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'vot', 'vot')})
            == 1 && say_success( $out, "Added language_rfc4646_to_iso639 for Votic" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'vot', 'language', 'en', 'Votic')}
            ) == 1
            && say_success( $out, "Added english language description for Votic" );
        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'vot', 'language', 'vot', 'vađđa ceeli')}
            ) == 1
            && say_success( $out, "Added native language description for Votic" );

        $dbh->do(
            q{UPDATE language_descriptions SET description = 'Latviešu valoda' WHERE subtag = 'lv' AND type = 'language' AND lang = 'lv'}
            ) == 1
            && say_success( $out, "Updated native lv language description from Latvija to Latviešu valoda" );

        $dbh->do(
            q{UPDATE language_descriptions SET description = 'Lietuvių kalba' WHERE subtag = 'lt' AND type = 'language' AND lang = 'lt'}
            ) == 1
            && say_success( $out, "Updated native lt language description from Lietuvių to Lietuvių kalba" );

        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'grc', 'language', 'grc', 'Ἑλληνική')}
            ) == 1
            && say_success( $out, "Added native language description for Ancient Greek" );

        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'eo', 'language', 'eo', 'Esperanto')}
            ) == 1
            && say_success( $out, "Added native language description for Esperanto" );

        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sa', 'language', 'sa', 'saṃskṛtam')}
            ) == 1
            && say_success( $out, "Added native language description for Sanskrit" );

        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ga', 'language', 'ga', 'Gaeilge')}

        ) == 1 && say_success( $out, "Added native language description for Irish Gaelic" );

        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'bs', 'language', 'bn', 'Bosanski')}
            ) == 1
            && say_success( $out, "Added native language description for Bosnian" );

        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'kk', 'language', 'kk', 'қазақ тілі')}
        ) && say_success( $out, "Added native language description for Kazakh" );

        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'bo', 'language', 'bo', 'ལྷ་སའི་སྐད་')}
            ) == 1
            && say_success( $out, "Added native language description of Standard Tibetan" );

        $dbh->do(
            q{INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'cy', 'language', 'cy', 'Cymraeg')}
        ) && say_success( $out, "Added native language description of Welsh" );
    }
    }
