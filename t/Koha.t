#!/usr/bin/perl
use strict;
use warnings;

use C4::Context;
use Test::More tests => 11;
use Test::MockModule;
use DBD::Mock;

use_ok('C4::Koha');

my $module_context = new Test::MockModule('C4::Context');
$module_context->mock(
    '_new_dbh',
    sub {
        my $dbh = DBI->connect( 'DBI:Mock:', '', '' )
          || die "Cannot create handle: $DBI::errstr\n";
        return $dbh;
    }
);

SKIP: {

    skip "DBD::Mock is too old", 3
        unless $DBD::Mock::VERSION >= 1.45;

    my @loc_results = (['category'],['LOC']);
    my @empty_results = ([]);
    my @relterms_results = (['category'],['RELTERMS']);

    my $dbh = C4::Context->dbh();

    $dbh->{mock_add_resultset} = \@loc_results;
    is ( IsAuthorisedValueCategory('LOC'), 1, 'LOC is a valid authorized value category');
    $dbh->{mock_add_resultset} = \@empty_results;
    is ( IsAuthorisedValueCategory('something'), 0, 'something is not a valid authorized value category');
    $dbh->{mock_add_resultset} = \@relterms_results;
    is ( IsAuthorisedValueCategory('RELTERMS'), 1, 'RELTERMS is a valid authorized value category');

} # End SKIP block

#
# test that &slashifyDate returns correct (non-US) date
#
my $date = "01/01/2002";
my $newdate = &slashifyDate("2002-01-01");
my $isbn13 = "9780330356473";
my $isbn13D = "978-0-330-35647-3";
my $isbn10 = "033035647X";
my $isbn10D = "0-330-35647-X";

ok($date eq $newdate, 'slashifyDate');

my $undef = undef;
is(xml_escape($undef), '', 'xml_escape() returns empty string on undef input');
my $str = q{'"&<>'};
is(xml_escape($str), '&apos;&quot;&amp;&lt;&gt;&apos;', 'xml_escape() works as expected');
is($str, q{'"&<>'}, '... and does not change input in place');

is(C4::Koha::_isbn_cleanup('0-590-35340-3'), '0590353403', '_isbn_cleanup removes hyphens');
is(C4::Koha::_isbn_cleanup('0590353403 (pbk.)'), '0590353403', '_isbn_cleanup removes parenthetical');
is(C4::Koha::_isbn_cleanup('978-0-321-49694-2'), '0321496949', '_isbn_cleanup converts ISBN-13 to ISBN-10');

