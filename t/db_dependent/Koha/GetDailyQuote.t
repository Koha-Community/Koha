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
(6,'George Washington','To be prepared for war is one of the most effectual means of preserving peace.',NOW()),
(7,'Thomas Jefferson','When angry, count ten, before you speak; if very angry, an hundred.',NOW()),
(8,'Abraham Lincoln','Four score and seven years ago our fathers brought forth on this continent, a new nation, conceived in Liberty, and dedicated to the proposition that all men are created equal.',NOW()),
(9,'Abraham Lincoln','I have always found that mercy bears richer fruits than strict justice.',NOW()),
(10,'Andrew Johnson','I feel incompetent to perform duties...which have been so unexpectedly thrown upon me.',NOW());");

my $expected_quote = {
    id          => 8,
    source      => 'Abraham Lincoln',
    text        => 'Four score and seven years ago our fathers brought forth on this continent, a new nation, conceived in Liberty, and dedicated to the proposition that all men are created equal.',
    timestamp   => dt_from_string,
};

my $quote = GetDailyQuote('id'=>8);
cmp_ok($quote->{'id'}, '==', $expected_quote->{'id'}, "Correctly got quote by ID");
is($quote->{'quote'}, $expected_quote->{'quote'}, "Quote is correct");

$quote = GetDailyQuote('random'=>1);
ok($quote, "Got a random quote.");
cmp_ok($quote->{'id'}, '>', 0, 'Id is greater than 0');

my $timestamp = DateTime::Format::MySQL->format_datetime(dt_from_string->add( seconds => 1 )); # To make it the last one
my $query = 'UPDATE quotes SET timestamp = ? WHERE id = ?';
my $sth = C4::Context->dbh->prepare($query);
$sth->execute( $timestamp , $expected_quote->{'id'});

$expected_quote->{'timestamp'} = $timestamp;

$quote = GetDailyQuote(); # this is the "default" mode of selection
cmp_ok($quote->{'id'}, '==', $expected_quote->{'id'}, "Id is correct");
is($quote->{'source'}, $expected_quote->{'source'}, "Source is correct");
is($quote->{'timestamp'}, $expected_quote->{'timestamp'}, "Timestamp $timestamp is correct");

$dbh->do(q|DELETE FROM quotes|);
$quote = eval {GetDailyQuote();};
is( $@, '', 'GetDailyQuote does not die if no quote exist' );
is_deeply( $quote, {}, 'GetDailyQuote return an empty hashref is no quote exist'); # Is it what we expect?
$dbh->do(q|INSERT INTO `quotes` VALUES
    (6,'George Washington','To be prepared for war is one of the most effectual means of preserving peace.',NOW())
|);

$quote = GetDailyQuote();
is( $quote->{id}, 6, ' GetDailyQuote returns the only existing quote' );

$dbh->rollback;
