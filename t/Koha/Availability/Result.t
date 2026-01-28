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

use Test::More tests => 9;
use Test::NoWarnings;

use Koha::Availability::Result;

subtest 'new() creates empty result' => sub {

    plan tests => 5;

    my $result = Koha::Availability::Result->new();

    isa_ok( $result, 'Koha::Availability::Result', 'new() returns Result object' );
    is( ref( $result->blockers ),      'HASH', 'blockers is a hashref' );
    is( ref( $result->confirmations ), 'HASH', 'confirmations is a hashref' );
    is( ref( $result->warnings ),      'HASH', 'warnings is a hashref' );
    is( ref( $result->context ),       'HASH', 'context is a hashref' );
};

subtest 'add_blocker()' => sub {

    plan tests => 3;

    my $result = Koha::Availability::Result->new();

    $result->add_blocker( test_blocker => 'value' );

    is( $result->blockers->{test_blocker}, 'value', 'blocker added' );
    is( keys %{ $result->blockers },       1,       'one blocker present' );
    isa_ok( $result->add_blocker( another => 1 ), 'Koha::Availability::Result', 'returns self for chaining' );
};

subtest 'add_confirmation()' => sub {

    plan tests => 3;

    my $result = Koha::Availability::Result->new();

    $result->add_confirmation( test_confirm => 'value' );

    is( $result->confirmations->{test_confirm}, 'value', 'confirmation added' );
    is( keys %{ $result->confirmations },       1,       'one confirmation present' );
    isa_ok( $result->add_confirmation( another => 1 ), 'Koha::Availability::Result', 'returns self for chaining' );
};

subtest 'add_warning()' => sub {

    plan tests => 3;

    my $result = Koha::Availability::Result->new();

    $result->add_warning( test_warning => 'value' );

    is( $result->warnings->{test_warning}, 'value', 'warning added' );
    is( keys %{ $result->warnings },       1,       'one warning present' );
    isa_ok( $result->add_warning( another => 1 ), 'Koha::Availability::Result', 'returns self for chaining' );
};

subtest 'set_context()' => sub {

    plan tests => 3;

    my $result = Koha::Availability::Result->new();

    $result->set_context( item => 'test_item' );

    is( $result->context->{item},   'test_item', 'context value set' );
    is( keys %{ $result->context }, 1,           'one context value present' );
    isa_ok(
        $result->set_context( patron => 'test_patron' ), 'Koha::Availability::Result',
        'returns self for chaining'
    );
};

subtest 'available()' => sub {

    plan tests => 2;

    my $result = Koha::Availability::Result->new();

    ok( $result->available, 'available when no blockers' );

    $result->add_blocker( test => 1 );

    ok( !$result->available, 'not available when blockers present' );
};

subtest 'needs_confirmation()' => sub {

    plan tests => 2;

    my $result = Koha::Availability::Result->new();

    ok( !$result->needs_confirmation, 'no confirmation needed when empty' );

    $result->add_confirmation( test => 1 );

    ok( $result->needs_confirmation, 'confirmation needed when confirmations present' );
};

subtest 'to_hashref()' => sub {

    plan tests => 6;

    my $result = Koha::Availability::Result->new();

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
