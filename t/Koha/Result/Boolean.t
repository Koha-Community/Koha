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
use Test::More tests => 5;

use_ok('Koha::Result::Boolean');

subtest 'new() tests' => sub {

    plan tests => 2;

    subtest 'bool context' => sub {

        plan tests => 4;

        ok(
            Koha::Result::Boolean->new,
            'Defaults to true if initialized without the parameter'
        );
        ok(
            Koha::Result::Boolean->new('Martin'),
            'Evals to true in boolean context if set an expression that evals to true'
        );
        ok(
            !Koha::Result::Boolean->new(0),
            'Evals to false in boolean context if set a false expression'
        );
        ok(
            !Koha::Result::Boolean->new(""),
            'Evals to false in boolean context if set a false expression'
        );
    };

    subtest '== context' => sub {

        plan tests => 4;

        cmp_ok(
            Koha::Result::Boolean->new, '==', 1,
            'Defaults 1 if initialized without the parameter'
        );
        cmp_ok(
            Koha::Result::Boolean->new('Martin'), '==', 1,
            'Evals 1 if set an expression that evals to true'
        );
        cmp_ok(
            Koha::Result::Boolean->new(0), '==', 0,
            'Evals 0 if set a false expression'
        );
        cmp_ok(
            Koha::Result::Boolean->new(""), '==', 0,
            'Evals 0 if set a false expression'
        );
    };
};

subtest 'set_value() tests' => sub {

    plan tests => 4;

    my $bool = Koha::Result::Boolean->new;

    ok(
        !$bool->set_value(),
        'Undef makes it eval to false'
    );
    ok(
        $bool->set_value('Martin'),
        'Evals to true in boolean context if set an expression that evals to true'
    );
    ok(
        !$bool->set_value(0),
        'Evals to false in boolean context if set a false expression'
    );
    ok(
        !$bool->set_value(""),
        'Evals to false in boolean context if set a false expression'
    );

};

subtest 'messages() and add_message() tests' => sub {

    plan tests => 5;

    my $bool = Koha::Result::Boolean->new();

    my @messages = @{ $bool->messages };
    is( scalar @messages, 0, 'No messages' );

    $bool->add_message( { message => "message_1" } );
    $bool->add_message( { message => "message_2" } );

    @messages = @{ $bool->messages };

    is( scalar @messages,      2,                       'Messages are returned' );
    is( ref( $messages[0] ),   'Koha::Object::Message', 'Right type returned' );
    is( ref( $messages[1] ),   'Koha::Object::Message', 'Right type returned' );
    is( $messages[0]->message, 'message_1',             'Right message recorded' );
};
