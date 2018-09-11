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

use Test::More tests => 1;
use Test::Mojo;
use Test::Warn;

use JSON::Validator::OpenAPI::Mojolicious;

subtest 'Type definition tests' => sub {

    plan tests => 4;

    # initialize Koha::REST::V1 after mocking
    my $remote_address = '127.0.0.1';
    my $t;

    $t = Test::Mojo->new('Koha::REST::V1');
    my $types = $t->app->types;

    is( $types->type('json'),
        'application/json; charset=utf8',
        'application/json gets charset added'
    );
    is( $types->type('marcxml'), 'application/marcxml+xml', 'application/marcxml+xml is defined' );
    is( $types->type('mij'),  'application/marc-in-json', 'application/marc-in-json is defined' );
    is( $types->type('marc'), 'application/marc',         'application/marc is defined' );
};
