#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 9;

BEGIN {
    use_ok('C4::Languages');
}

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

isnt(C4::Languages::_get_themes(), undef, 'testing _get_themes doesnt return undef');

ok(C4::Languages::_get_language_dirs(), 'test getting _get_language_dirs');

is(C4::Languages::accept_language(),undef, 'test that accept_languages returns undef when nothing is entered');

ok(C4::Languages::getAllLanguages(), 'test get all languages');

C4::Context->set_preference('AdvancedSearchLanguages', '');
my $all_languages = C4::Languages::getAllLanguages('eng');
ok(@$all_languages > 10, 'retrieved a bunch of languges');

my $languages = C4::Languages::getLanguages('eng');
is_deeply($languages, $all_languages, 'getLanguages() and getAllLanguages() return the same list');

$languages = C4::Languages::getLanguages('eng', 1);
is_deeply($languages, $all_languages, 'getLanguages() and getAllLanguages() with filtering selected but AdvancedSearchLanguages blank return the same list');

C4::Context->set_preference('AdvancedSearchLanguages', 'ita|eng');
$languages = C4::Languages::getLanguages('eng', 1);
is(scalar(@$languages), 2, 'getLanguages() filtering using AdvancedSearchLanguages works');

$dbh->rollback;
