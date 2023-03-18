#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use Modern::Perl;

use Test::More tests => 21;
use List::Util qw(first);
use Data::Dumper;
use Test::Warn;
use t::lib::Mocks;
use Koha::Database;

BEGIN {
    use_ok('C4::Languages', qw( accept_language getAllLanguages getLanguages getTranslatedLanguages get_rfc4646_from_iso639 ));
}

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

isnt(C4::Languages::_get_themes(), undef, 'testing _get_themes doesnt return undef');

ok(C4::Languages::_get_language_dirs(), 'test getting _get_language_dirs');

my $result;
warning_is { $result = C4::Languages::accept_language(); }
    q{accept_language(x,y) called with no clientPreferences (x).},
    'accept_language() generated expected warning';
is($result,undef, 'test that accept_languages returns undef when nothing is entered');

ok(C4::Languages::getAllLanguages(), 'test get all languages');

t::lib::Mocks::mock_preference('AdvancedSearchLanguages', '');
my $all_languages = C4::Languages::getAllLanguages('eng');
ok(@$all_languages > 10, 'retrieved a bunch of languges');

my $languages = C4::Languages::getLanguages('eng');
is_deeply($languages, $all_languages, 'getLanguages() and getAllLanguages() return the same list');

$languages = C4::Languages::getLanguages('eng', 1);
is_deeply($languages, $all_languages, 'getLanguages() and getAllLanguages() with filtering selected but AdvancedSearchLanguages blank return the same list');

t::lib::Mocks::mock_preference('AdvancedSearchLanguages', 'ita|eng');
$languages = C4::Languages::getLanguages('eng', 1);
is(scalar(@$languages), 2, 'getLanguages() filtering using AdvancedSearchLanguages works');

my $translatedlanguages1;
warnings_are { $translatedlanguages1 = C4::Languages::getTranslatedLanguages('opac','prog',undef,'') }
             [],
             'no warnings for calling getTranslatedLanguages';
my @currentcheck1 = map { $_->{current} } @$translatedlanguages1;
my $onlyzeros = first { $_ != 0 } @currentcheck1;
ok(! $onlyzeros, "Everything was zeros.\n");

my $translatedlanguages2;
warnings_are { $translatedlanguages2 = C4::Languages::getTranslatedLanguages('opac','prog','en','') }
             [],
             'no warnings for calling getTranslatedLanguages';
my @currentcheck2 = map { $_->{current} } @$translatedlanguages2;
$onlyzeros = first { $_ != 0 } @currentcheck2;
ok($onlyzeros, "There is a $onlyzeros\n");

# Bug 32775
my @languages = ('de-DE', 'en', 'en-NZ', 'mi-NZ');
my @enabledlanguages = ('de-DE', 'en-NZ', 'mi-NZ');
my $translatedlanguages3;
$translatedlanguages3 = C4::Languages::_build_languages_arrayref(\@languages,'en',\@enabledlanguages);
is( $translatedlanguages3->[0]->{rfc4646_subtag}, 'de-DE', '_build_languages_arrayref() returns first language of "de-DE"' );
is( $translatedlanguages3->[1]->{rfc4646_subtag}, 'en', '_build_languages_arrayref() returns second language of "en"');
is( $translatedlanguages3->[2]->{rfc4646_subtag}, 'mi-NZ', '_build_languages_arrayref() returns third language of "mi-NZ"');


# Language Descriptions
my $sth = $dbh->prepare("SELECT DISTINCT subtag,type,lang,description from language_descriptions;");
$sth->execute();
my $DistinctLangDesc = $sth->fetchall_arrayref({});

$sth = $dbh->prepare("SELECT subtag,type,lang,description from language_descriptions;");
$sth->execute();
my $LangDesc = $sth->fetchall_arrayref({});

is(scalar(@$LangDesc),scalar(@$DistinctLangDesc),"No unexpected language_description duplicates.");

# Language_subtag_registry
$sth = $dbh->prepare("SELECT DISTINCT subtag,type,description,added FROM language_subtag_registry;");
$sth->execute();
my $DistinctLangReg = $sth->fetchall_arrayref({});

$sth = $dbh->prepare("SELECT subtag,type,description,added FROM language_subtag_registry;");
$sth->execute();
my $LangReg = $sth->fetchall_arrayref({});

is(scalar(@$LangReg),scalar(@$DistinctLangReg),"No unexpected language_subtag_registry duplicates.");

# Language RFC4646 to ISO639
$sth = $dbh->prepare("SELECT DISTINCT rfc4646_subtag,iso639_2_code FROM language_rfc4646_to_iso639;");
$sth->execute();
my $DistinctLangRfc4646 = $sth->fetchall_arrayref({});

$sth = $dbh->prepare("SELECT rfc4646_subtag,iso639_2_code FROM language_rfc4646_to_iso639;");
$sth->execute();
my $LangRfc4646 = $sth->fetchall_arrayref({});

is(scalar(@$LangRfc4646),scalar(@$DistinctLangRfc4646),"No unexpected language_rfc4646_to_iso639 duplicates.");

my $i = 0;
foreach my $pair (@$DistinctLangRfc4646){
    $i++ if $pair->{rfc4646_subtag} eq C4::Languages::get_rfc4646_from_iso639( $pair->{iso639_2_code} );
}
is($i,scalar(@$DistinctLangRfc4646),"get_rfc4646_from_iso639 returns correct rfc for all iso values.");
