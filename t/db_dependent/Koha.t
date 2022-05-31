#!/usr/bin/perl
#
# This is to test C4/Koha
# It requires a working Koha database with the sample data

use Modern::Perl;
use Test::More tests => 5;
use Test::Warn;
use Test::Deep;

use t::lib::TestBuilder;

use C4::Context;
use Koha::Database;
use Koha::AuthorisedValue;
use Koha::AuthorisedValueCategories;

BEGIN {
    use_ok('C4::Koha', qw( GetAuthorisedValues GetItemTypesCategorized xml_escape ));
    use_ok('C4::Members');
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

subtest 'ISBN tests' => sub {
    plan tests => 6;

    my $isbn13  = "9780330356473";
    my $isbn13D = "978-0-330-35647-3";
    my $isbn10  = "033035647X";
    my $isbn10D = "0-330-35647-X";
    is( xml_escape(undef), '',
        'xml_escape() returns empty string on undef input' );
    my $str = q{'"&<>'};
    is(
        xml_escape($str),
        '&apos;&quot;&amp;&lt;&gt;&apos;',
        'xml_escape() works as expected'
    );
    is( $str, q{'"&<>'}, '... and does not change input in place' );
    is( C4::Koha::_isbn_cleanup('0-590-35340-3'),
        '0590353403', '_isbn_cleanup removes hyphens' );
    is( C4::Koha::_isbn_cleanup('0590353403 (pbk.)'),
        '0590353403', '_isbn_cleanup removes parenthetical' );
    is( C4::Koha::_isbn_cleanup('978-0-321-49694-2'),
        '0321496949', '_isbn_cleanup converts ISBN-13 to ISBN-10' );

};

subtest 'GetItemTypesCategorized test' => sub{
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
