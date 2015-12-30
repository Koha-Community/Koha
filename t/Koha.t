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
use Test::More;
use Test::MockModule;

use Module::Load::Conditional qw/check_install/;

BEGIN {
    if ( check_install( module => 'Test::DBIx::Class' ) ) {
        plan tests => 37;
    } else {
        plan skip_all => "Need Test::DBIx::Class"
    }
}

use_ok('C4::Koha');

use Test::DBIx::Class {
    schema_class => 'Koha::Schema',
    connect_info => ['dbi:SQLite:dbname=:memory:','',''],
    connect_opts => { name_sep => '.', quote_char => '`', },
    fixture_class => '::Populate',
}, 'Branch' ;

sub fixtures {
    my ( $libraries ) = @_;
    fixtures_ok [
        Branch => [
            ['branchcode', 'branchname'],
            @$libraries,
        ]
    ], 'add fixtures';
}

my $db = Test::MockModule->new('Koha::Database');
$db->mock( _new_schema => sub { return Schema(); } );

my $libraries = [
    ['XXX_test', 'my branchname XXX'],
];
fixtures($libraries);

my $isbn13 = "9780330356473";
my $isbn13D = "978-0-330-35647-3";
my $isbn10 = "033035647X";
my $isbn10D = "0-330-35647-X";

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

is( C4::Koha::GetNormalizedISBN('9780062059994 (hardcover bdg.) | 0062059998 (hardcover bdg.)'), '0062059998', 'Test GetNormalizedISBN' );
is( C4::Koha::GetNormalizedISBN('9780385753067 (trade) | 0385753063 (trade) | 9780385753074 (lib. bdg.) | 0385753071 (lib. bdg.)'), '0385753063', 'Test GetNormalizedISBN' );
is( C4::Koha::GetNormalizedISBN('9781432829162 (hardcover) | 1432829165 (hardcover)'), '1432829165', 'Test GetNormalizedISBN' );
is( C4::Koha::GetNormalizedISBN('9780062063625 (hardcover) | 9780062063632 | 0062063634'), '0062063626', 'Test GetNormalizedISBN' );
is( C4::Koha::GetNormalizedISBN('9780062059932 (hardback)'), '0062059939', 'Test GetNormalizedISBN' );
is( C4::Koha::GetNormalizedISBN('9780316370318 (hardback) | 9780316376266 (special edition hardcover) | 9780316405454 (international paperback edition)'), '0316370312', 'Test GetNormalizedISBN' );
is( C4::Koha::GetNormalizedISBN('9781595148032 (hbk.) | 1595148035 (hbk.)') , '1595148035', 'Test GetNormalizedISBN' );
is( C4::Koha::GetNormalizedISBN('9780062349859 | 0062349856 | 9780062391308 | 0062391305'), '0062349856', 'Test GetNormalizedISBN' );
is( C4::Koha::GetNormalizedISBN('9781250075345 (hardcover) | 1250075343 (hardcover) | 9781250049872 (trade pbk.) | 1250049873 (trade pbk.)'), '1250075343', 'Test GetNormalizedISBN' );
is( C4::Koha::GetNormalizedISBN('9781250067128 | 125006712X'), '125006712X', 'Test GetNormalizedISBN' );
is( C4::Koha::GetNormalizedISBN('9780373211463 | 0373211465'), '0373211465', 'Test GetNormalizedISBN' );

is( C4::Koha::GetNormalizedUPC(), undef, 'GetNormalizedUPC should return undef if no record is passed' );
is( C4::Koha::GetNormalizedISBN(), undef, 'GetNormalizedISBN should return undef if no record and no isbn are passed' );
is( C4::Koha::GetNormalizedEAN(), undef, 'GetNormalizedEAN should return undef if no record and no isbn are passed' );
is( C4::Koha::GetNormalizedOCLCNumber(), undef, 'GetNormalizedOCLCNumber should return undef if no record and no isbn are passed' );

subtest 'getFacets() tests' => sub {
    plan tests => 5;

    is ( Koha::Libraries->search->count, 1, 'There should be only 1 library (singleBranchMode on)' );
    my $facets = C4::Koha::getFacets();
    is(
        scalar( grep { defined $_->{idx} && $_->{idx} eq 'location' } @$facets ),
        1,
        'location facet present with singleBranchMode on (bug 10078)'
    );

    $libraries = [
        ['YYY_test', 'my branchname YYY'],
        ['ZZZ_test', 'my branchname XXX'],
    ];
    fixtures($libraries);
    is ( Koha::Libraries->search->count, 3, 'There should be only more than 1 library (singleBranchMode off)' );

    $facets = C4::Koha::getFacets();
    is(
        scalar( grep { defined $_->{idx} && $_->{idx} eq 'location' } @$facets ),
        1,
        'location facet present with singleBranchMode off (bug 10078)'
    );
};

is(C4::Koha::NormalizeISSN({ issn => '0024-9319', strip_hyphen => 1 }), '00249319', 'Test NormalizeISSN with all features enabled' );
is(C4::Koha::NormalizeISSN({ issn => '0024-9319', strip_hyphen => 0 }), '0024-9319', 'Test NormalizeISSN with all features enabled' );

my @issns = qw/ 0024-9319 00249319 /;
is( join('|', @issns), join('|', GetVariationsOfISSN('0024-9319')), 'GetVariationsOfISSN returns all variations' );
is( join('|', @issns), join('|', GetVariationsOfISSNs('0024-9319')), 'GetVariationsOfISSNs returns all variations' );

my $issn;
eval {
    $issn = C4::Koha::NormalizeISSN({ issn => '1234-5678', strip_hyphen => 1 });
};
ok($@ eq '', 'NormalizeISSN does not throw exception when parsing invalid ISSN');

@issns = GetVariationsOfISSNs('abc');
is(scalar(@issns), 0, 'zero variations returned of invalid ISSN');

1;
