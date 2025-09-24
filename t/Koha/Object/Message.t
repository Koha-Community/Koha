#!/usr/bin/perl

# Copyright 2020 Koha Development team
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

use Test::NoWarnings;
use Test::More tests => 3;
use Test::Exception;

BEGIN {
    use_ok('Koha::Object::Message');
}

subtest 'new() tests' => sub {

    plan tests => 11;

    my $some_error = 'Some error';

    my $message = Koha::Object::Message->new( { message => $some_error } );
    is( ref($message),     'Koha::Object::Message', 'Type is correct' );
    is( $message->message, $some_error,             'The message attribute has the right value' );
    is( $message->type,    'error',                 'If omitted, the type is error' );

    $message = Koha::Object::Message->new( { message => $some_error, type => 'callback' } );
    is( ref($message),     'Koha::Object::Message', 'Type is correct' );
    is( $message->message, $some_error,             'The message attribute has the right value' );
    is( $message->type,    'callback',              'type is correct' );

    $message = Koha::Object::Message->new( { message => $some_error, payload => { some => 'structure' } } );
    is( ref($message),     'Koha::Object::Message', 'Type is correct' );
    is( $message->message, $some_error,             'The message attribute has the right value' );
    is_deeply( $message->payload, { some => 'structure' }, 'payload is correct' );

    throws_ok { Koha::Object::Message->new( { blah => 'ohh' } ); }
    'Koha::Exceptions::MissingParameter',
        'Exception thrown if required parameter missing';

    like( "$@", qr/Mandatory parameter missing: 'message'/, 'Expected exception message' );
};
