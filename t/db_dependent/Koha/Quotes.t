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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 15;

use Koha::Database;
use Koha::DateUtils qw(dt_from_string);
use Koha::Quote;
use Koha::Quotes;

use t::lib::TestBuilder;
use t::lib::Dates;
use t::lib::Mocks;

BEGIN {
    use_ok('Koha::Quote');
    use_ok('Koha::Quotes');
}

my $quote = Koha::Quote->new();
isa_ok( $quote, 'Koha::Quote', 'Quote class returned' );

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

# Ids not starting with 1 to reflect possible deletes, this acts as a regression test for bug 11297
my $yesterday = dt_from_string()->subtract( days => 1 );
my $quote_1   = Koha::Quote->new(
    {
        source => 'George Washington',
        text   => 'To be prepared for war is one of the most effectual means of preserving peace.'
    }
)->store;
my $quote_2 = Koha::Quote->new(
    { source => 'Thomas Jefferson', text => 'When angry, count ten, before you speak; if very angry, an hundred.' } )
    ->store;
my $quote_3 = Koha::Quote->new(
    {
        source => 'Abraham Lincoln',
        text   =>
            'Four score and seven years ago our fathers brought forth on this continent, a new nation, conceived in Liberty, and dedicated to the proposition that all men are created equal'
    }
)->store;
my $quote_4 = Koha::Quote->new(
    { source => 'Abraham Lincoln', text => 'I have always found that mercy bears richer fruits than strict justice.' } )
    ->store;
my $quote_5 = Koha::Quote->new(
    {
        source => 'Andrew Johnson',
        text   => 'I feel incompetent to perform duties...which have been so unexpectedly thrown upon me.'
    }
)->store;

#First test with QuoteOfTheDay disabled
t::lib::Mocks::mock_preference( 'QuoteOfTheDay', 0 );

##Set interface and get nothing because syspref is not set.
C4::Context->interface('opac');
$quote = Koha::Quotes->get_daily_quote( id => $quote_1->id );
ok( not($quote), "'QuoteOfTheDay'-syspref not set so nothing returned" );

##Set 'QuoteOfTheDay'-syspref to not include current interface 'opac'
t::lib::Mocks::mock_preference( 'QuoteOfTheDay', 'intranet' );
$quote = Koha::Quotes->get_daily_quote( id => $quote_1->id );
ok( not($quote), "'QuoteOfTheDay'-syspref doesn't include 'opac'" );

##Set 'QuoteOfTheDay'-syspref to include current interface 'opac'
t::lib::Mocks::mock_preference( 'QuoteOfTheDay', 'opac,intranet' );

$quote = Koha::Quotes->get_daily_quote( 'id' => $quote_3->id );
is( $quote->id,                                                  $quote_3->id,   "Correctly got quote by ID" );
is( $quote->text,                                                $quote_3->text, "Quote is correct" );
is( t::lib::Dates::compare( $quote->timestamp, dt_from_string ), 0, "get_daily_quote updated the timestamp/last seen" );

$quote = Koha::Quotes->get_daily_quote( 'random' => 1 );
ok( $quote, "Got a random quote." );
cmp_ok( $quote->id, '>', 0, 'Id is greater than 0' );

subtest 'timestamp column is updated' => sub {
    plan tests => 3;

    Koha::Quotes->search->update( { timestamp => $yesterday } );

    my $now = dt_from_string;

    my $expected_quote = {
        id     => $quote_3->id,
        source => 'Abraham Lincoln',
        text   =>
            'Four score and seven years ago our fathers brought forth on this continent, a new nation, conceived in Liberty, and dedicated to the proposition that all men are created equal.',
        timestamp => $yesterday,
    };

    Koha::Quotes->find( $expected_quote->{'id'} )->update( { timestamp => $now->clone->subtract( seconds => 10 ) } );
    ;                                            # To make it the last one
    $quote = Koha::Quotes->get_daily_quote();    # this is the "default" mode of selection
    is( $quote->id,                                        $expected_quote->{'id'},     "Id is correct" );
    is( $quote->source,                                    $expected_quote->{'source'}, "Source is correct" );
    is( t::lib::Dates::compare( $quote->timestamp, $now ), 0, "get_daily_quote updated the timestamp/last seen" );
};

Koha::Quotes->search()->delete();
$quote = eval { Koha::Quotes->get_daily_quote(); };
is( $@, '', 'get_daily_quote does not die if no quote exist' );
is_deeply( $quote, undef, 'return undef if quotes do not exists' );    # Is it what we expect?

my $quote_6 = Koha::Quote->new(
    {
        source    => 'George Washington',
        text      => 'To be prepared for war is one of the most effectual means of preserving peace.',
        timestamp => dt_from_string()
    }
)->store;

$quote = Koha::Quotes->get_daily_quote();
is( $quote->id, $quote_6->id, ' get_daily_quote returns the only existing quote' );

$schema->storage->txn_rollback;
