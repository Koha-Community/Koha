$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    # Standard Tibetan
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'bo', 'language', 'Standard Tibetan', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'bo', 'tib')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'bo', 'language', 'en', 'Standard Tibetan')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'bo', 'language', 'bo', 'ལྷ་སའི་སྐད་')");
    # Bosnian
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'bs', 'language', 'Bosnian', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'bs', 'bos')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'bs', 'language', 'en', 'Bosnian')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'bs', 'language', 'bn', 'Bosanski')");
    # Welsh
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'cy', 'language', 'Welsh', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'cy', 'wel')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'cy', 'language', 'en', 'Welsh')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'cy', 'language', 'cy', 'Cymraeg')");
    # Esperanto
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'eo', 'language', 'Esperanto', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'eo', 'epo')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'eo', 'language', 'en', 'Esperanto')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'eo', 'language', 'eo', 'Esperanto')");
    # Estonian
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'et', 'language', 'Estonian', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'et', 'est')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'et', 'language', 'et', 'Eesti')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'et', 'language', 'en', 'Estonian')");
    # Irish Gaelic
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'ga', 'language', 'Irish', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'ga', 'gle')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ga', 'language', 'en', 'Irish')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ga', 'language', 'ga', 'Gaeilge')");
    # Scottish Gaelic
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'gd', 'language', 'Scottish Gaelic', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'gd', 'gla')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'gd', 'language', 'en', 'Scottish Gaelic')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'gd', 'language', 'gd', 'Gàidhlig')");
    # Ancient Greek
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'grc', 'language', 'Greek, Ancient', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'grc', 'grc')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'grc', 'language', 'en', 'Greek, Ancient')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'grc', 'language', 'grc', 'Ἑλληνική')");
    # Kazakh
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'kk', 'language', 'Kazakh', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'kk', 'kaz')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'kk', 'language', 'en', 'Kazakh')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'kk', 'language', 'kk', 'қазақ тілі')");
    # Greenlandic
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'kl', 'language', 'Greenlandic', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'kl', 'kal')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'kl', 'language', 'en', 'Greenlandic')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'kl', 'language', 'kl', 'Kalaallisut')");
    # Karelian
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'krl', 'language', 'Karelian', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'krl', 'krl')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'krl', 'language', 'en', 'Karelian')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'krl', 'language', 'krl', 'Karjala')");
    # Cornish
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'kw', 'language', 'Cornish', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'kw', 'cor')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'kw', 'language', 'en', 'Cornish')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'kw', 'language', 'kw', 'Kernowek')");
    # Lithuanian
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'lt', 'language', 'Lithuanian', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'lt', 'lit')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'lt', 'language', 'en', 'Lithuanian')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'lt', 'language', 'lt', 'lietuvių kalba')");
    # Latvian
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'lv', 'language', 'Latvian', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'lv', 'lav')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'lv', 'language', 'en', 'Latvian')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'lv', 'language', 'lv', 'Latviešu valoda')");
    # Burmese
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'my', 'language', 'Burmese', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'my', 'bur')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'my', 'language', 'en', 'Burmese')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'my', 'language', 'my', 'မြန်မာစာ')");
    # Punjabi
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'pa', 'language', 'Punjabi', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'pa', 'pan')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'pa', 'language', 'en', 'Punjabi')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'pa', 'language', 'pa', 'پنجابی')");
    # Pashto
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'ps', 'language', 'Pashto', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'ps', 'pus')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ps', 'language', 'en', 'Pashto')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ps', 'language', 'ps', 'پښتو')");
    # Finnish Kalo
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES( 'rmf', 'rmf')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES( 'rmf', 'language', 'en', 'Finnish Kalo')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES( 'rmf', 'language', 'fi', 'Suomen romanikieli')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES( 'rmf', 'language', 'rmf', 'Fíntika Rómma')");
    # Sanskrit
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sa', 'language', 'Sanskrit', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sa', 'san')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sa', 'language', 'en', 'Sanskrit')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sa', 'language', 'sa', 'saṃskṛtam')");
    # Akkala Sami
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sia', 'language', 'Akkala Sami', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sia', 'sia')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sia', 'language', 'en', 'Akkala Sami')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sia', 'language', 'sia', 'ču´kksuâlis')");
    # Kildin Sami
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sjd', 'language', 'Kildin Sami', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sjd', 'sjd')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sjd', 'language', 'en', 'Kildin Sami')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sjd', 'language', 'sjd', 'Кӣллт са̄мь кӣлл')");
    # Ter Sami
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sjt', 'language', 'Ter Sami', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sjt', 'sjt')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sjt', 'language', 'en', 'Ter Sami')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sjt', 'language', 'sjt', 'saa´mekiill')");
    # Pite Sami
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sje', 'language', 'Pite Sami', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sje', 'sje')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sje', 'language', 'en', 'Pite Sami')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sje', 'language', 'sje', 'Bidumsámegiella')");
    # Kemi Sami
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sjk', 'language', 'Kemi Sami', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sjk', 'sjk')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sjk', 'language', 'en', 'Kemi Sami')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sjk', 'language', 'sjk', 'samääškiela')");
    # Ume Sami
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sju', 'language', 'Ume Sami', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sju', 'sju')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sju', 'language', 'en', 'Ume Sami')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sju', 'language', 'sju', 'Ubmejensámien giella')");
    # Southern Sami
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sma', 'language', 'Southern Sami', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sma', 'sma')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sma', 'language', 'en', 'Southern Sami')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sma', 'language', 'sma', 'Åarjelsaemien gïele')");
    # Northern Sami
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sme', 'language', 'Northern Sami', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sme', 'sme')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sme', 'language', 'en', 'Northern Sami')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sme', 'language', 'fi', 'pohjoissaame')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sme', 'language', 'sv', 'Nordsamiska')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sme', 'language', 'sme', 'davvisámegiella')");
    # Sami languages
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'smi', 'language', 'Sami languages', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'smi', 'smi')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'smi', 'language', 'en', 'Sami languages')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'smi', 'language', 'fi', 'saamelaiskielet')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'smi', 'language', 'sv', 'Samiska')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'smi', 'language', 'smi', 'Saami')");
    # Lule Sami
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'smj', 'language', 'Lule Sami', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'smj', 'smj')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'smj', 'language', 'en', 'Lule Sami')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'smj', 'language', 'smj', 'julevsámegiella')");
    # Inari Sami
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'smn', 'language', 'Inari Sami', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'smn', 'smn')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'smn', 'language', 'en', 'Inari Sami')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'smn', 'language', 'smn', 'anarâškielâ')");
    # Skolt Sami
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sms', 'language', 'Skolt Sami', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sms', 'sms')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sms', 'language', 'en', 'Skolt Sami')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sms', 'language', 'sms', 'sääʹmǩiõll')");
    # Somali
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'so', 'language', 'Somali', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'so', 'som')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'so', 'language', 'en', 'Somali')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'so', 'language', 'so', 'Af-Soomaali')");
    # Sotho
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'st', 'language', 'Sotho', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'st', 'sot')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'st', 'language', 'en', 'Sotho')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'st', 'language', 'st', 'Sesotho')");
    # Votic
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'vot', 'language', 'Votic', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'vot', 'vot')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'vot', 'language', 'en', 'Votic')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'vot', 'language', 'vot', 'vađđa ceeli')");
    # Yiddish
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'yi', 'language', 'Yiddish', '2017-04-21')");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'yi', 'yid')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'yi', 'language', 'en', 'Yiddish')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES ( 'yi', 'language', 'yi', 'יידיש')");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - description)\n";
}
