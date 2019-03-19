#!/usr/bin/perl

use Modern::Perl;
use Koha::Database;
use Koha::DateUtils;
use Koha::Libraries;
use Koha::News;

use Test::More tests => 7;

BEGIN {
    use_ok('C4::NewsChannels');
}

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

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
    content        => $new1,
    lang           => $lang1,
    expirationdate => $expirationdate1,
    published_on=> $timestamp1,
    number         => $number1,
    branchcode     => 'LIB1',
};

$rv = add_opac_new($href_entry1);
is( $rv, 1, 'Successfully added the first dummy news item!' );

my ( $title2, $new2, $lang2, $expirationdate2, $number2 ) =
  ( 'News Title2', '<p>We have some exciting news!</p>', q{}, '2999-12-31', 1 );
my $href_entry2 = {
    title          => $title2,
    content        => $new2,
    lang           => $lang2,
    expirationdate => $expirationdate2,
    published_on=> $timestamp2,
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
    content        => $new3,
    lang           => $lang3,
    published_on=> $timestamp3,
    number         => $number3,
    borrowernumber => $brwrnmbr,
    branchcode     => 'LIB1',
};
$rv = add_opac_new($href_entry3);
is( $rv, 1, 'Successfully added the third dummy news item without expiration date!' );

# We need to determine the idnew in a non-MySQLism way.
# This should be good enough.
my $query =
q{ SELECT idnew from opac_news WHERE published_on='2000-01-01' AND expirationdate='2999-12-30'; };
my ( $idnew1 ) = $dbh->selectrow_array( $query );
$query =
q{ SELECT idnew from opac_news WHERE published_on='2000-01-01' AND expirationdate='2999-12-31'; };
my ( $idnew2 ) = $dbh->selectrow_array( $query );

$query =
q{ SELECT idnew from opac_news WHERE published_on='2000-01-02'; };
my ( $idnew3 ) = $dbh->selectrow_array( $query );

# Test GetNewsToDisplay
my ( $opac_news_count, $arrayref_opac_news ) = GetNewsToDisplay( q{}, 'LIB1' );
ok( $opac_news_count >= 2, 'Successfully tested GetNewsToDisplay for LIB1!' );

