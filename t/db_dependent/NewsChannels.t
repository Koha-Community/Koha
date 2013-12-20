#!/usr/bin/perl

use Modern::Perl;
use C4::Dates qw(format_date);
use C4::Branch qw(GetBranchName);
use Test::More tests => 10;
use Readonly;

Readonly my $F1 => 1;
Readonly my $F2 => 2;
Readonly my $F3 => 3;
Readonly my $F4 => 4;
Readonly my $F5 => 5;
Readonly my $F6 => 6;

BEGIN {
    use_ok('C4::NewsChannels');
}

my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

# Add LIB1, if it doesn't exist.
my $addbra = 'LIB1';
if ( !GetBranchName($addbra) ) {
    $dbh->do( q{ INSERT INTO branches (branchcode,branchname) VALUES (?,?) },
        undef, ( $addbra, "$addbra branch" ) );
}

# Test add_opac_new
my $rv = add_opac_new();    # intentionally bad
ok( $rv == 0, 'Correctly failed on no parameter!' );

my $timestamp = '2000-01-01';
my ( $timestamp1, $timestamp2 ) = ( $timestamp, $timestamp );
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
ok( $rv == 1, 'Successfully added the first dummy news item!' );

my ( $title2, $new2, $lang2, $expirationdate2, $number2 ) =
  ( 'News Title2', '<p>We have some exciting news!</p>', q{}, '2999-12-31', 1 );
my $href_entry2 = {
    title          => $title2,
    new            => $new2,
    lang           => $lang2,
    expirationdate => $expirationdate2,
    timestamp      => $timestamp2,
    number         => $number2,
    branchcode     => 'LIB1',
};
$rv = add_opac_new($href_entry2);
ok( $rv == 1, 'Successfully added the second dummy news item!' );

# We need to determine the idnew in a non-MySQLism way.
# This should be good enough.
my $query =
q{ SELECT idnew from opac_news WHERE timestamp='2000-01-01' AND expirationdate='2999-12-30'; };
my $sth = $dbh->prepare($query);
$sth->execute();
my $idnew1 = $sth->fetchrow;
$query =
q{ SELECT idnew from opac_news WHERE timestamp='2000-01-01' AND expirationdate='2999-12-31'; };
$sth = $dbh->prepare($query);
$sth->execute();
my $idnew2 = $sth->fetchrow;

# Test upd_opac_new
$rv = upd_opac_new();    # intentionally bad parmeters
ok( $rv == 0, 'Correctly failed on no parameter!' );

$new2                 = '<p>Update! There is no news!</p>';
$href_entry2->{new}   = $new2;
$href_entry2->{idnew} = $idnew2;
$rv                   = upd_opac_new($href_entry2);
ok( $rv == 1, 'Successfully updated second dummy news item!' );

# Test get_opac_new (single news item)
$timestamp1      = format_date($timestamp1);
$expirationdate1 = format_date($expirationdate1);
$timestamp2      = format_date($timestamp2);
$expirationdate2 = format_date($expirationdate2);

my $hashref_check = get_opac_new($idnew1);
my $failure       = 0;
if ( $hashref_check->{title}          ne $title1 )          { $failure = $F1; }
if ( $hashref_check->{new}            ne $new1 )            { $failure = $F2; }
if ( $hashref_check->{lang}           ne $lang1 )           { $failure = $F3; }
if ( $hashref_check->{expirationdate} ne $expirationdate1 ) { $failure = $F4; }
if ( $hashref_check->{timestamp}      ne $timestamp1 )      { $failure = $F5; }
if ( $hashref_check->{number}         ne $number1 )         { $failure = $F6; }
ok( $failure == 0, "Successfully tested get_opac_new id1 ($failure)!" );

# Test get_opac_new (single news item)
$hashref_check = get_opac_new($idnew2);
$failure       = 0;
if ( $hashref_check->{title}          ne $title2 )          { $failure = $F1; }
if ( $hashref_check->{new}            ne $new2 )            { $failure = $F2; }
if ( $hashref_check->{lang}           ne $lang2 )           { $failure = $F3; }
if ( $hashref_check->{expirationdate} ne $expirationdate2 ) { $failure = $F4; }
if ( $hashref_check->{timestamp}      ne $timestamp2 )      { $failure = $F5; }
if ( $hashref_check->{number}         ne $number2 )         { $failure = $F6; }
ok( $failure == 0, "Successfully tested get_opac_new id2 ($failure)!" );

# Test get_opac_news (multiple news items)
my ( $opac_news_count, $arrayref_opac_news ) = get_opac_news( 0, q{}, 'LIB1' );

# using >= 2, because someone may have LIB1 news already.
ok( $opac_news_count >= 2, 'Successfully tested get_opac_news for LIB1!' );

# Test GetNewsToDisplay
( $opac_news_count, $arrayref_opac_news ) = GetNewsToDisplay( q{}, 'LIB1' );
ok( $opac_news_count >= 2, 'Successfully tested GetNewsToDisplay for LIB1!' );

$dbh->rollback;
