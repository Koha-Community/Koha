#!/usr/bin/perl

use Modern::Perl;
use Koha::DateUtils;
use Koha::Libraries;

use Test::More tests => 14;

BEGIN {
    use_ok('C4::NewsChannels');
}

my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

# Add LIB1, if it doesn't exist.
my $addbra = 'LIB1';
unless ( Koha::Libraries->find($addbra) ) {
    $dbh->do( q{ INSERT INTO branches (branchcode,branchname) VALUES (?,?) },
        undef, ( $addbra, "$addbra branch" ) );
}

# Add CAT1, if it doesn't exist.
my $addcat = 'CAT1';
{
    my $sth = $dbh->prepare( q{ SELECT categorycode FROM categories WHERE categorycode = ? } );
    $sth->execute ( $addcat );
    if ( not defined $sth->fetchrow () ) {
        $dbh->do( q{ INSERT INTO categories (categorycode,description) VALUES (?,?) },
            undef, ( $addcat, "$addcat description") );
    }
}

# Add a test user if not already present.
my $addbrwr = 'BRWR1';
my $brwrnmbr;
{
    my $query =
        q{ SELECT borrowernumber from borrowers WHERE surname = ? AND branchcode = ? AND categorycode = ? };
    my $sth = $dbh->prepare( $query );
    $sth->execute( ($addbrwr, $addbra, $addcat) );
    $brwrnmbr = $sth->fetchrow;

    # Not found, let us insert it.
    if ( not defined $brwrnmbr ) {
        $dbh->do( q{ INSERT INTO borrowers (surname, address, city, branchcode, categorycode) VALUES (?, ?, ?, ?, ?) },
            undef, ($addbrwr, '(test) address', '(test) city', $addbra, $addcat) );

        # Retrieve the njew borrower number.
        $query =
            q{ SELECT borrowernumber from borrowers WHERE surname = ? AND branchcode = ? AND categorycode = ? };
        my $sth = $dbh->prepare( $query );
        $sth->execute( ($addbrwr, $addbra, $addcat) );
        $brwrnmbr = $sth->fetchrow;
    }
}

# Must have valid borrower number, or tests are meaningless.
ok ( defined $brwrnmbr );

# Test add_opac_new
my $rv = add_opac_new();    # intentionally bad
is( $rv, 0, 'Correctly failed on no parameter!' );

my $timestamp = '2000-01-01';
my ( $timestamp1, $timestamp2 ) = ( $timestamp, $timestamp );
my $timestamp3 = '2000-01-02';
my ( $title1, $new1, $lang1, $expirationdate1, $number1 ) =
  ( 'News Title', '<p>We have some exciting news!</p>', q{}, '2999-12-30', 1 );
my $href_entry1 = {
    title          => $title1,
    new            => $new1,
    lang           => $lang1,
    expirationdate => $expirationdate1,
    timestamp      => $timestamp1,
    number         => $number1,
    branchcode     => 'LIB1',
};

$rv = add_opac_new($href_entry1);
is( $rv, 1, 'Successfully added the first dummy news item!' );

my ( $title2, $new2, $lang2, $expirationdate2, $number2 ) =
  ( 'News Title2', '<p>We have some exciting news!</p>', q{}, '2999-12-31', 1 );
my $href_entry2 = {
    title          => $title2,
    new            => $new2,
    lang           => $lang2,
    expirationdate => $expirationdate2,
    timestamp      => $timestamp2,
    number         => $number2,
    borrowernumber => $brwrnmbr,
    branchcode     => 'LIB1',
};
$rv = add_opac_new($href_entry2);
is( $rv, 1, 'Successfully added the second dummy news item!' );

my ( $title3, $new3, $lang3, $number3 ) =
  ( 'News Title3', '<p>News without expiration date</p>', q{}, 1 );
my $href_entry3 = {
    title          => $title3,
    new            => $new3,
    lang           => $lang3,
    timestamp      => $timestamp3,
    number         => $number3,
    borrowernumber => $brwrnmbr,
    branchcode     => 'LIB1',
};
$rv = add_opac_new($href_entry3);
is( $rv, 1, 'Successfully added the third dummy news item without expiration date!' );

# We need to determine the idnew in a non-MySQLism way.
# This should be good enough.
my $query =
q{ SELECT idnew from opac_news WHERE timestamp='2000-01-01' AND expirationdate='2999-12-30'; };
my ( $idnew1 ) = $dbh->selectrow_array( $query );
$query =
q{ SELECT idnew from opac_news WHERE timestamp='2000-01-01' AND expirationdate='2999-12-31'; };
my ( $idnew2 ) = $dbh->selectrow_array( $query );

$query =
q{ SELECT idnew from opac_news WHERE timestamp='2000-01-02'; };
my ( $idnew3 ) = $dbh->selectrow_array( $query );

# Test upd_opac_new
$rv = upd_opac_new();    # intentionally bad parmeters
is( $rv, 0, 'Correctly failed on no parameter!' );

$new2                 = '<p>Update! There is no news!</p>';
$href_entry2->{new}   = $new2;
$href_entry2->{idnew} = $idnew2;
$rv                   = upd_opac_new($href_entry2);
is( $rv, 1, 'Successfully updated second dummy news item!' );

# Test get_opac_new (single news item)
$timestamp1      = output_pref( { dt => dt_from_string( $timestamp1 ), dateonly => 1 } );
$expirationdate1 = output_pref( { dt => dt_from_string( $expirationdate1 ), dateonly => 1 } );
$timestamp2      = output_pref( { dt => dt_from_string( $timestamp2 ), dateonly => 1 } );
$expirationdate2 = output_pref( { dt => dt_from_string( $expirationdate2) , dateonly => 1 } );

is_deeply(
    get_opac_new($idnew1),
    {
        title          => $title1,
        new            => $new1,
        lang           => $lang1,
        expirationdate => $expirationdate1,
        timestamp      => $timestamp1,
        number         => $number1,
        borrowernumber => undef,
        idnew          => $idnew1,
        branchname     => "$addbra branch",
        branchcode     => $addbra,
        # this represents $lang => 1 in the hash
        # that's returned... which seems a little
        # redundant given that there's a perfectly
        # good 'lang' key in the hash
        ''             => 1,
    },
    'got back expected news item via get_opac_new - ID 1'
);

# Test get_opac_new (single news item)
is_deeply(
    get_opac_new($idnew2),
    {  
        title          => $title2,
        new            => $new2,
        lang           => $lang2,
        expirationdate => $expirationdate2,
        timestamp      => $timestamp2,
        number         => $number2,
        borrowernumber => $brwrnmbr,
        idnew          => $idnew2,
        branchname     => "$addbra branch",
        branchcode     => $addbra,
        ''             => 1,
    },
    'got back expected news item via get_opac_new - ID 2'
);

# Test get_opac_new (single news item without expiration date)
my $news3 = get_opac_new($idnew3);
is($news3->{ expirationdate }, undef, "Expiration date should be empty");

# Test get_opac_news (multiple news items)
my ( $opac_news_count, $arrayref_opac_news ) = get_opac_news( 0, q{}, 'LIB1' );

# using >= 2, because someone may have LIB1 news already.
ok( $opac_news_count >= 2, 'Successfully tested get_opac_news for LIB1!' );

# Test GetNewsToDisplay
( $opac_news_count, $arrayref_opac_news ) = GetNewsToDisplay( q{}, 'LIB1' );
ok( $opac_news_count >= 2, 'Successfully tested GetNewsToDisplay for LIB1!' );

# Regression test 14248 -- make sure author_title, author_firstname, and
# author_surname exist.

subtest 'Regression tests on author title, firstname, and surname.', sub {
    my ( $opac_news_count, $opac_news ) = get_opac_news( 0, q{}, 'LIB1' );
    my $check = 0; # bitwise flag to confirm NULL and not NULL borrowernumber.
    ok($opac_news_count>0,'Data exists for regression testing');
    foreach my $news_item (@$opac_news) {
        ok(exists $news_item->{author_title},    'Author title exists');
        ok(exists $news_item->{author_firstname},'Author first name exists');
        ok(exists $news_item->{author_surname},  'Author surname exists');
        if ($news_item->{borrowernumber}) {
            ok(defined $news_item->{author_title} ||
               defined $news_item->{author_firstname} ||
               defined $news_item->{author_surname},  'Author data defined');
            $check = $check | 2; # bitwise flag;
        }
        else {
            ok(!defined $news_item->{author_title},
               'Author title undefined as expected');
            ok(!defined $news_item->{author_firstname},
               'Author first name undefined as expected');
            ok(!defined $news_item->{author_surname},
               'Author surname undefined as expected');
            $check = $check | 1; # bitwise flag;
        }
    }
    ok($check==3,'Both with and without author data tested');
    done_testing();
};

$dbh->rollback;
