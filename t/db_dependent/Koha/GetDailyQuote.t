#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 12;
use C4::Koha qw( GetDailyQuote );
use DateTime::Format::MySQL;
use Koha::DateUtils qw(dt_from_string);

BEGIN {
    use_ok('C4::Koha');
}

can_ok('C4::Koha', qw( GetDailyQuote ));

my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

# Setup stage
$dbh->do("DELETE FROM quotes");

# Ids not starting with 1 to reflect possible deletes, this acts as a regression test for bug 11297
$dbh->do("INSERT INTO `quotes` VALUES
(6,'George Washington','To be prepared for war is one of the most effectual means of preserving peace.','0000-00-00 00:00:00'),
(7,'Thomas Jefferson','When angry, count ten, before you speak; if very angry, an hundred.','0000-00-00 00:00:00'),
(8,'Abraham Lincoln','Four score and seven years ago our fathers brought forth on this continent, a new nation, conceived in Liberty, and dedicated to the proposition that all men are created equal.','0000-00-00 00:00:00'),
(9,'Abraham Lincoln','I have always found that mercy bears richer fruits than strict justice.','0000-00-00 00:00:00'),
(10,'Andrew Johnson','I feel incompetent to perform duties...which have been so unexpectedly thrown upon me.','0000-00-00 00:00:00');");

my $expected_quote = {
    id          => 8,
    source      => 'Abraham Lincoln',
    text        => 'Four score and seven years ago our fathers brought forth on this continent, a new nation, conceived in Liberty, and dedicated to the proposition that all men are created equal.',
    timestamp   => '0000-00-00 00:00:00',
};

diag("Get a quote based on id");
my $quote = GetDailyQuote('id'=>8);
cmp_ok($quote->{'id'}, '==', $expected_quote->{'id'}, "Id is correct");
is($quote->{'quote'}, $expected_quote->{'quote'}, "Quote is correct");


diag("Get a random quote");
$quote = GetDailyQuote('random'=>1);
ok($quote, "Got a random quote.");
cmp_ok($quote->{'id'}, '>', 0, 'Id is greater than 0');


diag("Get a quote based on today's date");
$dbh->do("UPDATE quotes SET timestamp = '0000-00-00 00:00:00';");
my $timestamp = DateTime::Format::MySQL->format_datetime(dt_from_string());
my $query = 'UPDATE quotes SET timestamp = ? WHERE id = ?';
my $sth = C4::Context->dbh->prepare($query);
$sth->execute( $timestamp , $expected_quote->{'id'});

$expected_quote->{'timestamp'} = $timestamp;

$quote = GetDailyQuote(); # this is the "default" mode of selection
cmp_ok($quote->{'id'}, '==', $expected_quote->{'id'}, "Id is correct");
is($quote->{'quote'}, $expected_quote->{'quote'}, "Quote is correct");
is($quote->{'timestamp'}, $expected_quote->{'timestamp'}, "Timestamp $timestamp is correct");

$dbh->do(q|DELETE FROM quotes|);
$quote = eval {GetDailyQuote();};
is( $@, '', 'GetDailyQuote does not die if no quote exist' );
is_deeply( $quote, {}, 'GetDailyQuote return an empty hashref is no quote exist'); # Is it what we expect?
$dbh->do(q|INSERT INTO `quotes` VALUES
    (6,'George Washington','To be prepared for war is one of the most effectual means of preserving peace.','0000-00-00 00:00:00')
|);

$quote = GetDailyQuote();
is( $quote->{id}, 6, ' GetDailyQuote returns the only existing quote' );

$dbh->rollback;
