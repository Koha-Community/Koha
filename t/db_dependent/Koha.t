#!/usr/bin/perl
#
# This is to test C4/Koha
# It requires a working Koha database with the sample data

use Modern::Perl;
use Test::More tests => 6;
use Test::MockModule;
use Test::Warn;
use Test::Deep;

use t::lib::TestBuilder;

use C4::Context;
use Koha::Database;
use Koha::AuthorisedValue;
use Koha::AuthorisedValueCategories;
use Koha::Libraries;

BEGIN {
    use_ok(
        'C4::Koha',
        qw( GetAuthorisedValues GetItemTypesCategorized xml_escape GetVariationsOfISBN GetVariationsOfISBNs GetVariationsOfISSN GetVariationsOfISSNs )
    );
}

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;

our $itype_1 = $builder->build({ source => 'Itemtype' });

subtest 'Authorized Values Tests' => sub {
    plan tests => 4;

    my $data = {
        category            => 'CATEGORY',
        authorised_value    => 'AUTHORISED_VALUE',
        lib                 => 'LIB',
        lib_opac            => 'LIBOPAC',
        imageurl            => 'IMAGEURL'
    };

    my $avc = Koha::AuthorisedValueCategories->find($data->{category});
    Koha::AuthorisedValueCategory->new({ category_name => $data->{category} })->store unless $avc;
# Insert an entry into authorised_value table
    my $insert_success = Koha::AuthorisedValue->new(
        {   category         => $data->{category},
            authorised_value => $data->{authorised_value},
            lib              => $data->{lib},
            lib_opac         => $data->{lib_opac},
            imageurl         => $data->{imageurl}
        }
    )->store;
    ok( $insert_success, "Insert data in database" );


# Clean up
    if($insert_success){
        my $query = "DELETE FROM authorised_values WHERE category=? AND authorised_value=? AND lib=? AND lib_opac=? AND imageurl=?;";
        my $sth = $dbh->prepare($query);
        $sth->execute($data->{category}, $data->{authorised_value}, $data->{lib}, $data->{lib_opac}, $data->{imageurl});
    }

    Koha::AuthorisedValueCategory->new({ category_name => 'BUG10656' })->store;
    Koha::AuthorisedValue->new(
        {   category         => 'BUG10656',
            authorised_value => 'ZZZ',
            lib              => 'Z_STAFF',
            lib_opac         => 'A_PUBLIC',
            imageurl         => ''
        }
    )->store;
    Koha::AuthorisedValue->new(
        {   category         => 'BUG10656',
            authorised_value => 'AAA',
            lib              => 'A_STAFF',
            lib_opac         => 'Z_PUBLIC',
            imageurl         => ''
        }
    )->store;

    # the next one sets lib_opac to NULL; in that case, the staff
    # display value is meant to be used.
    Koha::AuthorisedValue->new(
        {   category         => 'BUG10656',
            authorised_value => 'DDD',
            lib              => 'D_STAFF',
            lib_opac         => undef,
            imageurl         => ''
        }
    )->store;

    my $authvals = GetAuthorisedValues('BUG10656');
    cmp_deeply(
        $authvals,
        [
            {
                id => ignore(),
                category => 'BUG10656',
                authorised_value => 'AAA',
                lib => 'A_STAFF',
                lib_opac => 'Z_PUBLIC',
                imageurl => '',
            },
            {
                id => ignore(),
                category => 'BUG10656',
                authorised_value => 'DDD',
                lib => 'D_STAFF',
                lib_opac => undef,
                imageurl => '',
            },
            {
                id => ignore(),
                category => 'BUG10656',
                authorised_value => 'ZZZ',
                lib => 'Z_STAFF',
                lib_opac => 'A_PUBLIC',
                imageurl => '',
            },
        ],
        'list of authorised values in staff mode sorted by staff label (bug 10656)'
    );
    $authvals = GetAuthorisedValues('BUG10656', 1);
    cmp_deeply(
        $authvals,
        [
            {
                id => ignore(),
                category => 'BUG10656',
                authorised_value => 'ZZZ',
                lib => 'A_PUBLIC',
                lib_opac => 'A_PUBLIC',
                imageurl => '',
            },
            {
                id => ignore(),
                category => 'BUG10656',
                authorised_value => 'DDD',
                lib => 'D_STAFF',
                lib_opac => undef,
                imageurl => '',
            },
            {
                id => ignore(),
                category => 'BUG10656',
                authorised_value => 'AAA',
                lib => 'Z_PUBLIC',
                lib_opac => 'Z_PUBLIC',
                imageurl => '',
            },
        ],
        'list of authorised values in OPAC mode sorted by OPAC label (bug 10656)'
    );

    warning_is { GetAuthorisedValues() } [], 'No warning when no parameter passed to GetAuthorisedValues';

};

subtest 'isbn tests' => sub {
    plan tests => 29;

    my $isbn13  = "9780330356473";
    my $isbn13D = "978-0-330-35647-3";
    my $isbn10  = "033035647X";
    my $isbn10D = "0-330-35647-X";

    my $undef = undef;
    is( xml_escape($undef), '', 'xml_escape() returns empty string on undef input' );
    my $str = q{'"&<>'};
    is( xml_escape($str), '&apos;&quot;&amp;&lt;&gt;&apos;', 'xml_escape() works as expected' );
    is( $str,             q{'"&<>'},                         '... and does not change input in place' );

    is( C4::Koha::_isbn_cleanup('0-590-35340-3'),     '0590353403', '_isbn_cleanup removes hyphens' );
    is( C4::Koha::_isbn_cleanup('0590353403 (pbk.)'), '0590353403', '_isbn_cleanup removes parenthetical' );
    is( C4::Koha::_isbn_cleanup('978-0-321-49694-2'), '0321496949', '_isbn_cleanup converts ISBN-13 to ISBN-10' );

    is(
        C4::Koha::NormalizeISBN( { isbn => '978-0-321-49694-2 (pbk.)', format => 'ISBN-10', strip_hyphens => 1 } ),
        '0321496949', 'Test NormalizeISBN with all features enabled'
    );

    my @isbns = qw/ 978-0-321-49694-2 0-321-49694-9 978-0-321-49694-2 0321496949 9780321496942/;
    is(
        join( '|', @isbns ), join( '|', GetVariationsOfISBN('978-0-321-49694-2 (pbk.)') ),
        'GetVariationsOfISBN returns all variations'
    );

    is(
        join( '|', @isbns ), join( '|', GetVariationsOfISBNs('978-0-321-49694-2 (pbk.)') ),
        'GetVariationsOfISBNs returns all variations'
    );

    my $isbn;
    eval {
        $isbn = C4::Koha::NormalizeISBN(
            { isbn => '0788893777 (2 DVD 45th ed)', format => 'ISBN-10', strip_hyphens => 1 } );
    };
    ok( $@ eq '', 'NormalizeISBN does not throw exception when parsing invalid ISBN (bug 12243)' );
    $isbn = C4::Koha::NormalizeISBN(
        { isbn => '0788893777 (2 DVD 45th ed)', format => 'ISBN-10', strip_hyphens => 1, return_invalid => 1 } );
    is(
        $isbn, '0788893777 (2 DVD 45th ed)',
        'NormalizeISBN returns original string when converting to ISBN10 an ISBN starting with 979 (bug 13167)'
    );

    eval {
        $isbn = C4::Koha::NormalizeISBN( { isbn => '979-10-90085-00-8', format => 'ISBN-10', strip_hyphens => 1 } );
    };
    ok(
        $@ eq '',
        'NormalizeISBN does not throw exception when converting to ISBN10 an ISBN starting with 979 (bug 13167)'
    );
    ok( !defined $isbn, 'NormalizeISBN returns undef when converting to ISBN10 an ISBN starting with 979 (bug 13167)' );

    @isbns = GetVariationsOfISBNs('abc');
    is( @isbns == 1 && $isbns[0] eq 'abc', 1, 'The unaltered version should be returned if invalid' );

    is(
        C4::Koha::GetNormalizedISBN('9780062059994 (hardcover bdg.) | 0062059998 (hardcover bdg.)'), '0062059998',
        'Test GetNormalizedISBN'
    );
    is(
        C4::Koha::GetNormalizedISBN(
            '9780385753067 (trade) | 0385753063 (trade) | 9780385753074 (lib. bdg.) | 0385753071 (lib. bdg.)'),
        '0385753063',
        'Test GetNormalizedISBN'
    );
    is(
        C4::Koha::GetNormalizedISBN('9781432829162 (hardcover) | 1432829165 (hardcover)'), '1432829165',
        'Test GetNormalizedISBN'
    );
    is(
        C4::Koha::GetNormalizedISBN('9780062063625 (hardcover) | 9780062063632 | 0062063634'), '0062063626',
        'Test GetNormalizedISBN'
    );
    is( C4::Koha::GetNormalizedISBN('9780062059932 (hardback)'), '0062059939', 'Test GetNormalizedISBN' );
    is(
        C4::Koha::GetNormalizedISBN(
            '9780316370318 (hardback) | 9780316376266 (special edition hardcover) | 9780316405454 (international paperback edition)'
        ),
        '0316370312',
        'Test GetNormalizedISBN'
    );
    is(
        C4::Koha::GetNormalizedISBN('9781595148032 (hbk.) | 1595148035 (hbk.)'), '1595148035',
        'Test GetNormalizedISBN'
    );
    is(
        C4::Koha::GetNormalizedISBN('9780062349859 | 0062349856 | 9780062391308 | 0062391305'), '0062349856',
        'Test GetNormalizedISBN'
    );
    is(
        C4::Koha::GetNormalizedISBN(
            '9781250075345 (hardcover) | 1250075343 (hardcover) | 9781250049872 (trade pbk.) | 1250049873 (trade pbk.)'
        ),
        '1250075343',
        'Test GetNormalizedISBN'
    );
    is( C4::Koha::GetNormalizedISBN('9781250067128 | 125006712X'), '125006712X', 'Test GetNormalizedISBN' );
    is( C4::Koha::GetNormalizedISBN('9780373211463 | 0373211465'), '0373211465', 'Test GetNormalizedISBN' );

    is( C4::Koha::GetNormalizedUPC(), undef, 'GetNormalizedUPC should return undef if no record is passed' );
    is(
        C4::Koha::GetNormalizedISBN(), undef,
        'GetNormalizedISBN should return undef if no record and no isbn are passed'
    );
    is(
        C4::Koha::GetNormalizedEAN(), undef,
        'GetNormalizedEAN should return undef if no record and no isbn are passed'
    );
    is(
        C4::Koha::GetNormalizedOCLCNumber(), undef,
        'GetNormalizedOCLCNumber should return undef if no record and no isbn are passed'
    );
};

subtest 'issn stuff' => sub {
    plan tests => 7;

    is(
        C4::Koha::NormalizeISSN( { issn => '0024-9319', strip_hyphen => 1 } ), '00249319',
        'Test NormalizeISSN with all features enabled'
    );
    is(
        C4::Koha::NormalizeISSN( { issn => '0024-9319', strip_hyphen => 0 } ), '0024-9319',
        'Test NormalizeISSN with all features enabled'
    );

    my @issns = qw/ 0024-9319 00249319 /;
    is(
        join( '|', @issns ), join( '|', GetVariationsOfISSN('0024-9319') ),
        'GetVariationsOfISSN returns all variations'
    );
    is(
        join( '|', @issns ), join( '|', GetVariationsOfISSNs('0024-9319') ),
        'GetVariationsOfISSNs returns all variations'
    );

    my $issn;
    eval { $issn = C4::Koha::NormalizeISSN( { issn => '1234-5678', strip_hyphen => 1 } ); };
    ok( $@ eq '', 'NormalizeISSN does not throw exception when parsing invalid ISSN' );

    @issns = GetVariationsOfISSNs('abc');
    is( $issns[0],      'abc', 'Original ISSN passed through even if invalid' );
    is( scalar(@issns), 1,     'zero additional variations returned of invalid ISSN' );
};

subtest 'getFacets() tests' => sub {
    plan tests => 4;

    my $count          = 1;
    my $library_module = Test::MockModule->new('Koha::Libraries');
    $library_module->mock( 'count', sub { return $count } );

    is( Koha::Libraries->search->count, 1, 'There should be only 1 library (singleBranchMode on)' );
    my $facets = C4::Koha::getFacets();
    is(
        scalar( grep { defined $_->{idx} && $_->{idx} eq 'location' } @$facets ),
        1,
        'location facet present with singleBranchMode on (bug 10078)'
    );

    $count = 3;    # more libraries..
    is( Koha::Libraries->search->count, 3, 'There should be more than 1 library (singleBranchMode off)' );

    $facets = C4::Koha::getFacets();
    is(
        scalar( grep { defined $_->{idx} && $_->{idx} eq 'location' } @$facets ),
        1,
        'location facet present with singleBranchMode off (bug 10078)'
    );
};

subtest 'GetItemTypesCategorized test' => sub {
    plan tests => 9;

    my $avc = Koha::AuthorisedValueCategories->find('ITEMTYPECAT');
    Koha::AuthorisedValueCategory->new({ category_name => 'ITEMTYPECAT' })->store unless $avc;
    my $insertGroup = Koha::AuthorisedValue->new(
        {   category         => 'ITEMTYPECAT',
            authorised_value => 'Qwertyware',
            lib              => 'Keyboard software',
            lib_opac         => 'Computer stuff',
        }
    )->store;

    ok($insertGroup, "Create group Qwertyware");

    my $query = "INSERT into itemtypes (itemtype, description, searchcategory, hideinopac) values (?,?,?,?)";
    my $insertSth = C4::Context->dbh->prepare($query);
    $insertSth->execute('BKghjklo1', 'One type of book', '', 0);
    $insertSth->execute('BKghjklo2', 'Another type of book', 'Qwertyware', 0);
    $insertSth->execute('BKghjklo3', 'Yet another type of book', 'Qwertyware', 0);

    # Azertyware should not exist.
    my @itemtypes = Koha::ItemTypes->search({ searchcategory => 'Azertyware' })->as_list;
    is( @itemtypes, 0, 'Search item types by searchcategory: Invalid category returns nothing');

    @itemtypes = Koha::ItemTypes->search({ searchcategory => 'Qwertyware' })->as_list;
    my @got = map { $_->itemtype } @itemtypes;
    my @expected = ( 'BKghjklo2', 'BKghjklo3' );
    is_deeply(\@got,\@expected,'Search item types by searchcategory: valid category returns itemtypes');

    # add more data since GetItemTypesCategorized's search is more subtle
    $insertGroup = Koha::AuthorisedValue->new(
        {   category         => 'ITEMTYPECAT',
            authorised_value => 'Veryheavybook',
            lib              => 'Weighty literature',
        }
    )->store;

    $insertSth->execute('BKghjklo4', 'Another hidden book', 'Veryheavybook', 1);

    my $hrCat = GetItemTypesCategorized();
    ok(exists $hrCat->{Qwertyware}, 'GetItemTypesCategorized: fully visible category exists');
    ok($hrCat->{Veryheavybook} &&
       $hrCat->{Veryheavybook}->{hideinopac}==1, 'GetItemTypesCategorized: non-visible category hidden' );

    is( $hrCat->{Veryheavybook}->{description}, 'Weighty literature', 'A category with only lib description passes through');
    is( $hrCat->{Qwertyware}->{description}, 'Computer stuff', 'A category with lib_opac description uses that');

    $insertSth->execute('BKghjklo5', 'An hidden book', 'Qwertyware', 1);
    $hrCat = GetItemTypesCategorized();
    ok(exists $hrCat->{Qwertyware}, 'GetItemTypesCategorized: partially visible category exists');

    my @only = ( 'BKghjklo1', 'BKghjklo2', 'BKghjklo3', 'BKghjklo4', 'BKghjklo5', 'Qwertyware', 'Veryheavybook' );
    my @results = ();
    foreach my $key (@only) {
        push @results, $key if exists $hrCat->{$key};
    }
    @expected = ( 'BKghjklo1', 'Qwertyware', 'Veryheavybook' );
    is_deeply(\@results,\@expected, 'GetItemTypesCategorized: grouped and ungrouped items returned as expected.');
};

$schema->storage->txn_rollback;
