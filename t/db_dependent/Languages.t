#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!
use utf8;
use Modern::Perl;

use Encode;
use Test::NoWarnings;
use Test::More tests => 23;
use Test::Deep;
use Test::Exception;
use List::Util qw(first);
use Data::Dumper;
use Test::Warn;
use t::lib::Mocks;
use Koha::Database;

BEGIN {
    use_ok(
        'C4::Languages',
        qw( accept_language getAllLanguages getLanguages getTranslatedLanguages get_rfc4646_from_iso639 )
    );
}

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

isnt( C4::Languages::_get_themes(), undef, 'testing _get_themes does not return undef' );

ok( C4::Languages::_get_language_dirs(), 'test getting _get_language_dirs' );

my $result;
warning_is { $result = C4::Languages::accept_language(); }
q{accept_language(x,y) called with no clientPreferences (x).},
    'accept_language() generated expected warning';
is( $result, undef, 'test that accept_languages returns undef when nothing is entered' );

ok( C4::Languages::getAllLanguages(), 'test get all languages' );

t::lib::Mocks::mock_preference( 'AdvancedSearchLanguages', '' );
my $all_languages = C4::Languages::getAllLanguages('eng');
ok( @$all_languages > 10, 'retrieved a bunch of languges' );

my $languages = C4::Languages::getLanguages('eng');
is_deeply( $languages, $all_languages, 'getLanguages() and getAllLanguages() return the same list' );

$languages = C4::Languages::getLanguages( 'eng', 1 );
is_deeply(
    $languages, $all_languages,
    'getLanguages() and getAllLanguages() with filtering selected but AdvancedSearchLanguages blank return the same list'
);

t::lib::Mocks::mock_preference( 'AdvancedSearchLanguages', 'ita|eng' );
$languages = C4::Languages::getLanguages( 'eng', 1 );
is( scalar(@$languages), 2, 'getLanguages() filtering using AdvancedSearchLanguages works' );

my $translatedlanguages1;
warnings_are { $translatedlanguages1 = C4::Languages::getTranslatedLanguages('opac') }
[],
    'no warnings for calling getTranslatedLanguages';
my @currentcheck1 = map { $_->{current} } @$translatedlanguages1;
my $onlyzeros     = first { $_ != 0 } @currentcheck1;
ok( !$onlyzeros, "Everything was zeros.\n" );

my $translatedlanguages2;
warnings_are { $translatedlanguages2 = C4::Languages::getTranslatedLanguages( 'opac', undef, 'en' ) }
[],
    'no warnings for calling getTranslatedLanguages';
my @currentcheck2 = map { $_->{current} } @$translatedlanguages2;
$onlyzeros = first { $_ != 0 } @currentcheck2;
ok( $onlyzeros, "There is a $onlyzeros\n" );

# Bug 32775
my @languages        = ( 'de-DE', 'en',    'en-NZ', 'mi-NZ' );
my @enabledlanguages = ( 'de-DE', 'en-NZ', 'mi-NZ' );
my $translatedlanguages3;
$translatedlanguages3 = C4::Languages::_build_languages_arrayref( \@languages, 'en', \@enabledlanguages );
is(
    $translatedlanguages3->[0]->{rfc4646_subtag}, 'de-DE',
    '_build_languages_arrayref() returns first language of "de-DE"'
);
is( $translatedlanguages3->[1]->{rfc4646_subtag}, 'en', '_build_languages_arrayref() returns second language of "en"' );
is(
    $translatedlanguages3->[2]->{rfc4646_subtag}, 'mi-NZ',
    '_build_languages_arrayref() returns third language of "mi-NZ"'
);

# Language Descriptions
my $sth = $dbh->prepare("SELECT DISTINCT subtag,type,lang,description from language_descriptions;");
$sth->execute();
my $DistinctLangDesc = $sth->fetchall_arrayref( {} );

$sth = $dbh->prepare("SELECT subtag,type,lang,description from language_descriptions;");
$sth->execute();
my $LangDesc = $sth->fetchall_arrayref( {} );

is( scalar(@$LangDesc), scalar(@$DistinctLangDesc), "No unexpected language_description duplicates." );

# Language_subtag_registry
$sth = $dbh->prepare("SELECT DISTINCT subtag,type,description,added FROM language_subtag_registry;");
$sth->execute();
my $DistinctLangReg = $sth->fetchall_arrayref( {} );

$sth = $dbh->prepare("SELECT subtag,type,description,added FROM language_subtag_registry;");
$sth->execute();
my $LangReg = $sth->fetchall_arrayref( {} );

is( scalar(@$LangReg), scalar(@$DistinctLangReg), "No unexpected language_subtag_registry duplicates." );

# Language RFC4646 to ISO639
$sth = $dbh->prepare("SELECT DISTINCT rfc4646_subtag,iso639_2_code FROM language_rfc4646_to_iso639;");
$sth->execute();
my $DistinctLangRfc4646 = $sth->fetchall_arrayref( {} );

$sth = $dbh->prepare("SELECT rfc4646_subtag,iso639_2_code FROM language_rfc4646_to_iso639;");
$sth->execute();
my $LangRfc4646 = $sth->fetchall_arrayref( {} );

is( scalar(@$LangRfc4646), scalar(@$DistinctLangRfc4646), "No unexpected language_rfc4646_to_iso639 duplicates." );

my $i = 0;
foreach my $pair (@$DistinctLangRfc4646) {
    $i++ if $pair->{rfc4646_subtag} eq C4::Languages::get_rfc4646_from_iso639( $pair->{iso639_2_code} );
}
is( $i, scalar(@$DistinctLangRfc4646), "get_rfc4646_from_iso639 returns correct rfc for all iso values." );

$schema->storage->txn_rollback;
subtest 'getLanguages()' => sub {

    $schema->storage->txn_begin;

    # Setup: Ensure test environment is clean
    $dbh->do("DELETE FROM language_descriptions");
    $dbh->do("DELETE FROM language_subtag_registry");
    $dbh->do("DELETE FROM language_rfc4646_to_iso639");

    # Insert test data
    $dbh->do(
        "INSERT INTO language_subtag_registry (subtag, type, description) VALUES
    ('en', 'language', 'English'),
    ('fr', 'language', 'French'),
    ('es', 'language', 'Spanish')"
    );

    $dbh->do(
        "INSERT INTO language_descriptions (lang, subtag, type, description) VALUES
    ('en', 'en', 'language', 'English'),
    ('en', 'fr', 'language', 'French'),
    ('en', 'es', 'language', 'Spanish'),
    ('es', 'es', 'language', 'Español'),
    ('fr', 'fr', 'language', 'Français'),
    ('fr', 'es', 'language', 'Espagnol'),
    ('fr', 'en', 'language', 'Anglais')"
    );

    $dbh->do(
        "INSERT INTO language_rfc4646_to_iso639 (rfc4646_subtag, iso639_2_code) VALUES
    ('en', 'eng'),
    ('fr', 'fra'),
    ('es', 'spa')"
    );

    my $expected = [
        {
            'id'                   => ignore(),
            'added'                => ignore(),
            'subtag'               => 'en',
            'iso639_2_code'        => 'eng',
            'description'          => 'English',
            'language_description' => 'English',
            'type'                 => 'language'
        },
        {
            'id'                   => ignore(),
            'added'                => ignore(),
            'subtag'               => 'fr',
            'iso639_2_code'        => 'fra',
            'description'          => 'French',
            'language_description' => "French (Français)",
            'type'                 => 'language'
        },
        {
            'id'                   => ignore(),
            'added'                => ignore(),
            'subtag'               => 'es',
            'iso639_2_code'        => 'spa',
            'description'          => 'Spanish',
            'language_description' => "Spanish (Español)",
            'type'                 => 'language'
        }
    ];

    # Test 1: No parameters, expect English names
    my $languages = getLanguages();
    cmp_deeply(
        $languages, $expected,
        'getLanguages returned the expected results when no parameters are passed, description is "English (Native)"'
    );

    # Test 2: Specific language without full translations
    $expected->[2]->{language_description} = "Español";
    $languages = getLanguages('es');
    cmp_deeply(
        $languages, $expected,
        'getLanguages returned the expected results when "es" is requested, description is "Spanish falling back to English when missing (Native)"'
    );

    # Test 3: Specific language with translations
    $expected->[0]->{language_description} = "Anglais (English)";
    $expected->[1]->{language_description} = "Français";
    $expected->[2]->{language_description} = "Espagnol (Español)";
    $languages                             = getLanguages('fr');
    cmp_deeply(
        $languages, $expected,
        'getLanguages returned the expected results when "fr" is requested, description is "French (Native)"'
    );

    # Test 4: Filtered results based on AdvancedSearchLanguages
    t::lib::Mocks::mock_preference( 'AdvancedSearchLanguages', 'eng,fra' );
    $languages = getLanguages( 'en', 1 );
    is( scalar(@$languages), 2, 'Returned 2 filtered languages' );
    is_deeply(
        [ map { $_->{iso639_2_code} } @$languages ],
        [ 'eng', 'fra' ],
        'Filtered ISO639-2 codes are correct'
    );

    # Cleanup: Restore database to original state
    $dbh->do("DELETE FROM language_descriptions");
    $dbh->do("DELETE FROM language_subtag_registry");
    $dbh->do("DELETE FROM language_rfc4646_to_iso639");

    $schema->storage->txn_rollback;
};
