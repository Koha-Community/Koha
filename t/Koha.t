#!/usr/bin/perl
use strict;
use warnings;

use Test::More tests => 12;

use_ok('C4::Koha');

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

is(C4::Koha::DisplayISBN($isbn13),$isbn13D,'DisplayISBN splits an ISBN-13 into 5 segments');
is(C4::Koha::DisplayISBN($isbn10),$isbn10D,'DisplayISBN splits an ISBN-10 into 4 segments');

is(C4::Koha::DisplayISBN('9780330356473'),$isbn13D,'DisplayISBN splits an ISBN-13 into 5 segments after fixing the ISBN by using _isbn_cleanup');
is(C4::Koha::DisplayISBN('033035647X'),$isbn10D,'DisplayISBN splits an ISBN-10 into 4 segments after fixing the ISBN by using _isbn_cleanup');
