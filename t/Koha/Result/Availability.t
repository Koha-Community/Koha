#!/usr/bin/perl

# Copyright 2026 Koha Development team
#
# This file is part of Koha
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

use Test::More tests => 13;
use Test::NoWarnings;
use Test::Exception;
use Test::MockObject;

use Koha::Result::Availability;
use Koha::Item::Availability::Checkin::Result;
use Koha::Token;

subtest 'new() creates empty result' => sub {

    plan tests => 5;

    my $result = Koha::Result::Availability->new();

    isa_ok( $result, 'Koha::Result::Availability', 'new() returns Result object' );
    is( ref( $result->blockers ),      'HASH', 'blockers is a hashref' );
    is( ref( $result->confirmations ), 'HASH', 'confirmations is a hashref' );
    is( ref( $result->warnings ),      'HASH', 'warnings is a hashref' );
    is( ref( $result->context ),       'HASH', 'context is a hashref' );
};

subtest 'add_blocker()' => sub {

    plan tests => 3;

    my $result = Koha::Result::Availability->new();

    $result->add_blocker( test_blocker => 'value' );

    is( $result->blockers->{test_blocker}, 'value', 'blocker added' );
    is( keys %{ $result->blockers },       1,       'one blocker present' );
    isa_ok( $result->add_blocker( another => 1 ), 'Koha::Result::Availability', 'returns self for chaining' );
};

subtest 'add_confirmation()' => sub {

    plan tests => 3;

    my $result = Koha::Result::Availability->new();

    $result->add_confirmation( test_confirm => 'value' );

    is( $result->confirmations->{test_confirm}, 'value', 'confirmation added' );
    is( keys %{ $result->confirmations },       1,       'one confirmation present' );
    isa_ok( $result->add_confirmation( another => 1 ), 'Koha::Result::Availability', 'returns self for chaining' );
};

subtest 'add_warning()' => sub {

    plan tests => 3;

    my $result = Koha::Result::Availability->new();

    $result->add_warning( test_warning => 'value' );

    is( $result->warnings->{test_warning}, 'value', 'warning added' );
    is( keys %{ $result->warnings },       1,       'one warning present' );
    isa_ok( $result->add_warning( another => 1 ), 'Koha::Result::Availability', 'returns self for chaining' );
};

subtest 'set_context()' => sub {

    plan tests => 3;

    my $result = Koha::Result::Availability->new();

    $result->set_context( item => 'test_item' );

    is( $result->context->{item},   'test_item', 'context value set' );
    is( keys %{ $result->context }, 1,           'one context value present' );
    isa_ok(
        $result->set_context( patron => 'test_patron' ), 'Koha::Result::Availability',
        'returns self for chaining'
    );
};

subtest 'available()' => sub {

    plan tests => 2;

    my $result = Koha::Result::Availability->new();

    ok( $result->available, 'available when no blockers' );

    $result->add_blocker( test => 1 );

    ok( !$result->available, 'not available when blockers present' );
};

subtest 'needs_confirmation()' => sub {

    plan tests => 2;

    my $result = Koha::Result::Availability->new();

    ok( !$result->needs_confirmation, 'no confirmation needed when empty' );

    $result->add_confirmation( test => 1 );

    ok( $result->needs_confirmation, 'confirmation needed when confirmations present' );
};

subtest 'to_hashref()' => sub {

    plan tests => 6;

    my $result = Koha::Result::Availability->new();

    $result->add_blocker( blocker1 => 'b1' );
    $result->add_confirmation( confirm1 => 'c1' );
    $result->add_warning( warning1 => 'w1' );
    $result->set_context( item   => 'test_item' );
    $result->set_context( patron => 'test_patron' );

    my $hashref = $result->to_hashref();

    is( ref($hashref),                    'HASH',        'returns hashref' );
    is( $hashref->{blockers}->{blocker1}, 'b1',          'blockers included' );
    is( $hashref->{confirms}->{confirm1}, 'c1',          'confirmations included as confirms' );
    is( $hashref->{warnings}->{warning1}, 'w1',          'warnings included' );
    is( $hashref->{item},                 'test_item',   'context item included at top level' );
    is( $hashref->{patron},               'test_patron', 'context patron included at top level' );
};

subtest 'to_api()' => sub {

    plan tests => 5;

    my $result = Koha::Item::Availability::Checkin::Result->new();

    my $api = $result->to_api;

    is( ref($api), 'HASH', 'returns hashref' );
    is_deeply( $api->{blockers}, {}, 'blockers empty' );
    is_deeply( $api->{confirms}, {}, 'confirms empty' );
    is_deeply( $api->{warnings}, {}, 'warnings empty' );
    is( $api->{confirmation_token}, undef, 'no token when no confirmations' );
};

subtest 'to_api() with confirmations generates token' => sub {

    plan tests => 2;

    my $result = Koha::Item::Availability::Checkin::Result->new();
    $result->add_confirmation( NotIssued => 'ABC123' );

    # Need context for token generation
    my $mock_item = Test::MockObject->new();
    $mock_item->mock( 'id', sub { 42 } );
    my $mock_user = Test::MockObject->new();
    $mock_user->mock( 'id', sub { 7 } );

    $result->set_context( item => $mock_item );
    $result->set_context( user => $mock_user );

    my $api = $result->to_api;

    ok( $api->{confirmation_token}, 'token present when confirmations exist' );
    like( $api->{confirmation_token}, qr/^eyJ/, 'token looks like a JWT' );
};

subtest 'as_token() / check_token() round-trip' => sub {

    plan tests => 3;

    my $result = Koha::Item::Availability::Checkin::Result->new();
    $result->add_confirmation( NotIssued => 'ABC123' );

    my $mock_item = Test::MockObject->new();
    $mock_item->mock( 'id', sub { 99 } );
    my $mock_user = Test::MockObject->new();
    $mock_user->mock( 'id', sub { 5 } );

    $result->set_context( item => $mock_item );
    $result->set_context( user => $mock_user );

    my $token = $result->as_token;
    ok( $token,                                     'as_token generates a token' );
    ok( $result->check_token($token),               'check_token validates the token' );
    ok( !$result->check_token('totally-not-a-jwt'), 'check_token rejects invalid token' );
};

subtest 'check_token() rejects mismatched context and expired tokens' => sub {

    plan tests => 3;

    my $mock_item = Test::MockObject->new();
    $mock_item->mock( 'id', sub { 99 } );
    my $mock_other_item = Test::MockObject->new();
    $mock_other_item->mock( 'id', sub { 100 } );
    my $mock_user = Test::MockObject->new();
    $mock_user->mock( 'id', sub { 5 } );

    my $result = Koha::Item::Availability::Checkin::Result->new();
    $result->add_confirmation( NotIssued => 'ABC123' );
    $result->set_context( item => $mock_item );
    $result->set_context( user => $mock_user );
    my $token = $result->as_token;

    my $other_result = Koha::Item::Availability::Checkin::Result->new();
    $other_result->add_confirmation( NotIssued => 'ABC123' );
    $other_result->set_context( item => $mock_other_item );
    $other_result->set_context( user => $mock_user );
    ok(
        !$other_result->check_token($token),
        'A token minted for one item does not validate against a different item'
    );

    my $confirmed_differently = Koha::Item::Availability::Checkin::Result->new();
    $confirmed_differently->add_confirmation( SomethingElse => 1 );
    $confirmed_differently->set_context( item => $mock_item );
    $confirmed_differently->set_context( user => $mock_user );
    ok(
        !$confirmed_differently->check_token($token),
        'A token minted for one confirmation set does not validate against a different one'
    );

    # Directly forge an already-expired token for the same id, bypassing
    # as_token's TOKEN_EXPIRY_SECONDS, to confirm expiry is enforced.
    my $expired_token = Koha::Token->new->generate_jwt(
        {
            id      => $result->_token_id,
            expires => time - 10,
        }
    );
    ok( !$result->check_token($expired_token), 'An expired token is rejected' );
};
