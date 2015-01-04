#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use C4::Context;
use Test::More tests => 18;
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

is(C4::Koha::NormalizeISBN({ isbn => '978-0-321-49694-2 (pbk.)', format => 'ISBN-10', strip_hyphens => 1 }), '0321496949', 'Test NormalizeISBN with all features enabled' );

my @isbns = qw/ 978-0-321-49694-2 0-321-49694-9 978-0-321-49694-2 0321496949 9780321496942/;
is( join('|', @isbns), join('|', GetVariationsOfISBN('978-0-321-49694-2 (pbk.)')), 'GetVariationsOfISBN returns all variations' );

is( join('|', @isbns), join('|', GetVariationsOfISBNs('978-0-321-49694-2 (pbk.)')), 'GetVariationsOfISBNs returns all variations' );

my $isbn;
eval {
    $isbn = C4::Koha::NormalizeISBN({ isbn => '0788893777 (2 DVD 45th ed)', format => 'ISBN-10', strip_hyphens => 1 });
};
ok($@ eq '', 'NormalizeISBN does not throw exception when parsing invalid ISBN (bug 12243)');

eval {
    $isbn = C4::Koha::NormalizeISBN({ isbn => '979-10-90085-00-8', format => 'ISBN-10', strip_hyphens => 1 });
};
ok($@ eq '', 'NormalizeISBN does not throw exception when converting to ISBN10 an ISBN starting with 979 (bug 13167)');
ok(!defined $isbn, 'NormalizeISBN returns undef when converting to ISBN10 an ISBN starting with 979 (bug 13167)');

@isbns = GetVariationsOfISBNs('abc');
is(scalar(@isbns), 0, 'zero variations returned of invalid ISBN');

1;
