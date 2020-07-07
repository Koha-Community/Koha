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
use DateTime::Format::MySQL;
use Test::More tests => 13;

use Koha::Database;
use Koha::DateUtils qw(dt_from_string);
use Koha::Quote;
use Koha::Quotes;

use t::lib::TestBuilder;
use t::lib::Mocks;

BEGIN {
    use_ok('Koha::Quote');
}

my $quote = Koha::Quote->new();
isa_ok( $quote, 'Koha::Quote', 'Quote class returned' );

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

# Ids not starting with 1 to reflect possible deletes, this acts as a regression test for bug 11297
my $timestamp = DateTime::Format::MySQL->format_datetime(dt_from_string());
my $quote_1 = Koha::Quote->new({ source => 'George Washington', text => 'To be prepared for war is one of the most effectual means of preserving peace.', timestamp =>  $timestamp })->store;
my $quote_2 = Koha::Quote->new({ source => 'Thomas Jefferson', text => 'When angry, count ten, before you speak; if very angry, an hundred.', timestamp =>  $timestamp })->store;
my $quote_3 = Koha::Quote->new({ source => 'Abraham Lincoln', text => 'Four score and seven years ago our fathers brought forth on this continent, a new nation, conceived in Liberty, and dedicated to the proposition that all men are created equal', timestamp =>  $timestamp })->store;
my $quote_4 = Koha::Quote->new({ source => 'Abraham Lincoln', text => 'I have always found that mercy bears richer fruits than strict justice.', timestamp =>  $timestamp })->store;
my $quote_5 = Koha::Quote->new({ source => 'Andrew Johnson', text => 'I feel incompetent to perform duties...which have been so unexpectedly thrown upon me.', timestamp =>  $timestamp })->store;

my $expected_quote = {
    id          => $quote_3->id,
    source      => 'Abraham Lincoln',
    text        => 'Four score and seven years ago our fathers brought forth on this continent, a new nation, conceived in Liberty, and dedicated to the proposition that all men are created equal.',
    timestamp   => $timestamp,
};

$quote = Koha::Quote->get_daily_quote('id'=>$quote_3->id);
cmp_ok($quote->id, '==', $expected_quote->{'id'}, "Correctly got quote by ID");
is($quote->{'quote'}, $expected_quote->{'quote'}, "Quote is correct");

$quote = Koha::Quote->get_daily_quote('random'=>1);
ok($quote, "Got a random quote.");
cmp_ok($quote->id, '>', 0, 'Id is greater than 0');

$timestamp = DateTime::Format::MySQL->format_datetime(dt_from_string->add( seconds => 1 )); # To make it the last one
Koha::Quotes->search({ id => $expected_quote->{'id'} })->update({ timestamp => $timestamp });
$expected_quote->{'timestamp'} = $timestamp;

$quote = Koha::Quote->get_daily_quote()->unblessed; # this is the "default" mode of selection
cmp_ok($quote->{'id'}, '==', $expected_quote->{'id'}, "Id is correct");
is($quote->{'source'}, $expected_quote->{'source'}, "Source is correct");
is($quote->{'timestamp'}, $expected_quote->{'timestamp'}, "Timestamp $timestamp is correct");

Koha::Quotes->search()->delete();
$quote = eval {Koha::Quote->get_daily_quote();};
is( $@, '', 'get_daily_quote does not die if no quote exist' );
is_deeply( $quote, undef, 'return undef if quotes do not exists'); # Is it what we expect?

my $quote_6 = Koha::Quote->new({ source => 'George Washington', text => 'To be prepared for war is one of the most effectual means of preserving peace.', timestamp =>  dt_from_string() })->store;

$quote = Koha::Quote->get_daily_quote();
is( $quote->id, $quote_6->id, ' get_daily_quote returns the only existing quote' );

$schema->storage->txn_rollback;

subtest "get_daily_quote_for_interface" => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my ($quote);
    my $quote_1 = Koha::Quote->new({ source => 'Dusk And Her Embrace', text => 'Unfurl thy limbs breathless succubus<br/>How the full embosomed fog<br/>Imparts the night to us....', timestamp =>  dt_from_string })->store;

    my $expected_quote = {
        id          => $quote_1->id,
        source      => 'Dusk And Her Embrace',
        text        => 'Unfurl thy limbs breathless succubus<br/>How the full embosomed fog<br/>Imparts the night to us....',
        timestamp   => DateTime::Format::MySQL->format_datetime(dt_from_string),
    };

    t::lib::Mocks::mock_preference('QuoteOfTheDay', 0);

    ##Set interface and get nothing because syspref is not set.
    C4::Context->interface('opac');
    $quote = Koha::Quote->get_daily_quote_for_interface(id => $quote_1->id);
    ok(not($quote), "'QuoteOfTheDay'-syspref not set so nothing returned");

    ##Set 'QuoteOfTheDay'-syspref to not include current interface 'opac'
    t::lib::Mocks::mock_preference('QuoteOfTheDay', 'intranet');
    $quote = Koha::Quote->get_daily_quote_for_interface(id => $quote_1->id);
    ok(not($quote), "'QuoteOfTheDay'-syspref doesn't include 'opac'");

    ##Set 'QuoteOfTheDay'-syspref to include current interface 'opac'
    t::lib::Mocks::mock_preference('QuoteOfTheDay', 'opac,intranet');
    $quote = Koha::Quote->get_daily_quote_for_interface(id => $quote_1->id)->unblessed;
    is_deeply($quote, $expected_quote, "Got the expected quote");

    $schema->storage->txn_rollback;
};
