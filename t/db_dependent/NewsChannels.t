#!/usr/bin/perl

use Modern::Perl;
use C4::Dates qw(format_date);
use C4::Branch qw(GetBranchName);
use Test::More tests => 8;

BEGIN {
        use_ok('C4::NewsChannels');
}

my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

# Test add_opac_new
my $timestamp = '2000-01-01';
my ( $timestamp1, $timestamp2 ) = ( $timestamp, $timestamp );
my ($title1,         $new1,
    $lang1, $expirationdate1, $number1) =
   ( 'News Title',  '<p>We have some exciting news!</p>',
    '',    '2999-12-30',    1 );
my $rv = add_opac_new( $title1, $new1, $lang1, $expirationdate1, $timestamp1, $number1 );
ok($rv==1,"Successfully added the first dummy news item!");

my ($title2,         $new2,
    $lang2, $expirationdate2, $number2) =
   ( 'News Title2', '<p>We have some exciting news!</p>',
    '',    '2999-12-31',    1 );
$rv = add_opac_new( $title2, $new2, $lang2, $expirationdate2, $timestamp2, $number2 );
ok($rv==1,"Successfully added the second dummy news item!");

# We need to determine the idnew in a non-MySQLism way.
# This should be good enough.
my $sth = $dbh->prepare(q{
  SELECT idnew from opac_news
  WHERE timestamp='2000-01-01' AND
        expirationdate='2999-12-30';
                        });
$sth->execute();
my $idnew1 = $sth->fetchrow;
$sth = $dbh->prepare(q{
  SELECT idnew from opac_news
  WHERE timestamp='2000-01-01' AND
        expirationdate='2999-12-31';
                      });
$sth->execute();
my $idnew2 = $sth->fetchrow;

# Test upd_opac_new
$new2 = '<p>Update! There is no news!</p>';
$rv = upd_opac_new( $idnew2, $title2, $new2, $lang2, $expirationdate2, $timestamp2, $number2 );
ok($rv==1,"Successfully updated second dummy news item!");

# Test get_opac_new (single news item)
$timestamp1 = format_date( $timestamp1 );
$expirationdate1 = format_date( $expirationdate1 );
$timestamp2 = format_date( $timestamp2 );
$expirationdate2 = format_date( $expirationdate2 );

my $hashref_check = get_opac_new($idnew1);
my $failure = 0;
if ($hashref_check->{title}          ne $title1)          { $failure = 1; }
if ($hashref_check->{new}            ne $new1)            { $failure = 1; }
if ($hashref_check->{lang}           ne $lang1)           { $failure = 1; }
if ($hashref_check->{expirationdate} ne $expirationdate1) { $failure = 1; }
if ($hashref_check->{timestamp}      ne $timestamp1)      { $failure = 1; }
if ($hashref_check->{number}         ne $number1)         { $failure = 1; }
ok($failure==0,"Successfully tested get_opac_new id1!");

# Test get_opac_new (single news item)
$hashref_check = get_opac_new($idnew2);
$failure = 0;
if ($hashref_check->{title}          ne $title2)          { $failure = 1; }
if ($hashref_check->{new}            ne $new2)            { $failure = 1; }
if ($hashref_check->{lang}           ne $lang2)           { $failure = 1; }
if ($hashref_check->{expirationdate} ne $expirationdate2) { $failure = 1; }
if ($hashref_check->{timestamp}      ne $timestamp2)      { $failure = 1; }
if ($hashref_check->{number}         ne $number2)         { $failure = 1; }
ok($failure==0,"Successfully tested get_opac_new id2!");

# Test get_opac_news (multiple news items)
my ($opac_news_count, $arrayref_opac_news) = get_opac_news(0,'');
ok($opac_news_count>=2,"Successfully tested get_opac_news!");

# Test GetNewsToDisplay
($opac_news_count, $arrayref_opac_news) = GetNewsToDisplay('');
ok($opac_news_count>=2,"Successfully tested GetNewsToDisplay!");

$dbh->rollback;
