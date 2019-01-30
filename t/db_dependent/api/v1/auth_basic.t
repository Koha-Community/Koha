#!/usr/bin/env perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Test::More tests => 2;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'success tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

    my $password = 'AbcdEFG123';

    my $patron = $builder->build_object(
        { class => 'Koha::Patrons', value => { userid => 'tomasito', flags => 2**4 } } );
    $patron->set_password({ password => $password });
    my $userid = $patron->userid;

    $t->get_ok("//$userid:$password@/api/v1/patrons")
      ->status_is( 200, 'Successful authentication and permissions check' );

    $patron->flags(undef)->store;

    $t->get_ok("//$userid:$password@/api/v1/patrons")
      ->status_is( 403, 'Successful authentication and not enough permissions' )
      ->json_is(
        '/error' => 'Authorization failure. Missing required permission(s).',
        'Error message returned'
      );

    $schema->storage->txn_rollback;
};

subtest 'failure tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $password     = 'AbcdEFG123';
    my $bad_password = '123456789';

    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

    my $patron = $builder->build_object(
        { class => 'Koha::Patrons', value => { userid => 'tomasito', flags => 2**4 } } );
    $patron->set_password({ password => $password });
    my $userid = $patron->userid;

    $t->get_ok("//@/api/v1/patrons")
      ->status_is( 401, 'No credentials passed' );

    $t->get_ok("//$userid:$bad_password@/api/v1/patrons")
      ->status_is( 403, 'Failed authentication, invalid password' )
      ->json_is( '/error' => 'Invalid password', 'Error message returned' );

    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 0 );

    $t->get_ok("//$userid:$password@/api/v1/patrons")
      ->status_is( 401, 'Basic authentication is disabled' )
      ->json_is( '/error' => 'Basic authentication disabled', 'Expected error message rendered' );

    $schema->storage->txn_rollback;
};

1;
