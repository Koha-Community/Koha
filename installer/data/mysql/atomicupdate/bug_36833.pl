use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => "36833",
    description => "Add German translations for new languages",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
        INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'kl', 'language', 'de', 'Grönländisch');
}
        );

        $dbh->do(
            q{
        INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'kn', 'language', 'de', 'Kannada');
}
        );

        $dbh->do(
            q{
 INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'krl', 'language', 'de', 'Karelisch');
}
        );

        $dbh->do(
            q{
 INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'kw', 'language', 'de', 'Kornisch');
}
        );

        $dbh->do(
            q{
 INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'my', 'language', 'de', 'Burmesisch');
}
        );

        $dbh->do(
            q{
 INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'pa', 'language', 'de', 'Panjabi');
}
        );

        $dbh->do(
            q{
 INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'ps', 'language', 'de', 'Paschtu');
}
        );

        $dbh->do(
            q{
 INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES( 'rmf', 'language', 'de', 'Finnisch Kalo');
}
        );

        $dbh->do(
            q{
 INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sia', 'language', 'de', 'Akkalasamisch');
}
        );

        $dbh->do(
            q{
 INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sjd', 'language', 'de', 'Kildinsamisch');
}
        );

        $dbh->do(
            q{
 INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sjt', 'language', 'de', 'Tersamisch');
}
        );

        $dbh->do(
            q{
 INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sje', 'language', 'de', 'Pitesamisch');
}
        );

        $dbh->do(
            q{
 INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sjk', 'language', 'de', 'Kemisamisch');
}
        );

        $dbh->do(
            q{
 INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sju', 'language', 'de', 'Umesamisch');
}
        );

        $dbh->do(
            q{
 INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sma', 'language', 'de', 'Südsamisch');
}
        );

        $dbh->do(
            q{
 INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sme', 'language', 'de', 'Nordsamisch');
}
        );

        $dbh->do(
            q{
 INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'smi', 'language', 'de', 'Samische Sprachen');
}
        );

        $dbh->do(
            q{
 INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'smj', 'language', 'de', 'Lulesamisch');
}
        );

        $dbh->do(
            q{
 INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'smn', 'language', 'de', 'Inarisamisch');
}
        );

        $dbh->do(
            q{
 INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'sms', 'language', 'de', 'Skoltsamisch');
}
        );

        $dbh->do(
            q{
 INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'so', 'language', 'de', 'Somali');
}
        );

        $dbh->do(
            q{
 INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'st', 'language', 'de', 'Sotho');
}
        );

        $dbh->do(
            q{
 INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'vot', 'language', 'de', 'Wotisch');
}
        );

        say_success( $out, "Added German translations for new languages" );

        $dbh->do(
            q{
 UPDATE language_descriptions
SET description = 'Latein'
WHERE subtag = 'la' AND type = 'language' AND lang = 'de';
}
        );

        say_success( $out, "Updated German translation for Latin" );
    },
};
