#!/usr/bin/env perl

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

use Test::NoWarnings;
use Test::More tests => 3;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::DateUtils qw( dt_from_string );

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'success tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

    my $password = 'AbcdEFG123';

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { userid => 'tomasito' } } );
    $patron->set_password( { password => $password } );

    my $userid     = $patron->userid;
    my $cardnumber = $patron->cardnumber;

    my $stash;
    my $interface;
    my $userenv;

    $t->app->hook(
        after_dispatch => sub {
            $stash     = shift->stash;
            $interface = C4::Context->interface;
            $userenv   = C4::Context->userenv;
        }
    );

    subtest '`userid` login' => sub {

        plan tests => 10;

        $patron->flags( 2**4 )->store;

        $t->get_ok("//$userid:$password@/api/v1/patrons")
            ->status_is( 200, 'Successful authentication and permissions check' );

        my $user = $stash->{'koha.user'};
        ok( defined $user, 'The \'koha.user\' object is defined in the stash' )
            and is( ref($user),            'Koha::Patron',          'Stashed koha.user object type is Koha::Patron' )
            and is( $user->borrowernumber, $patron->borrowernumber, 'The stashed user is the right one' );
        is( $userenv->{number}, $patron->borrowernumber, 'userenv set correctly' );
        is( $interface,         'api',                   "Interface correctly set to \'api\'" );

        $patron->flags(undef)->store;

        $t->get_ok("//$userid:$password@/api/v1/patrons")
            ->status_is( 403, 'Successful authentication and not enough permissions' )->json_is(
            '/error' => 'Authorization failure. Missing required permission(s).',
            'Error message returned'
            );
    };

    subtest '`cardnumber` login' => sub {

        plan tests => 10;

        $patron->flags( 2**4 )->store;

        $t->get_ok("//$cardnumber:$password@/api/v1/patrons")
            ->status_is( 200, 'Successful authentication and permissions check' );

        my $user = $stash->{'koha.user'};
        ok( defined $user, 'The \'koha.user\' object is defined in the stash' )
            and is( ref($user),            'Koha::Patron',          'Stashed koha.user object type is Koha::Patron' )
            and is( $user->borrowernumber, $patron->borrowernumber, 'The stashed user is the right one' );
        is( $userenv->{number}, $patron->borrowernumber, 'userenv set correctly' );
        is( $interface,         'api',                   "Interface correctly set to \'api\'" );

        $patron->flags(undef)->store;

        $t->get_ok("//$cardnumber:$password@/api/v1/patrons")
            ->status_is( 403, 'Successful authentication and not enough permissions' )->json_is(
            '/error' => 'Authorization failure. Missing required permission(s).',
            'Error message returned'
            );
    };

    $schema->storage->txn_rollback;
};

subtest 'failure tests' => sub {

    plan tests => 13;

    $schema->storage->txn_begin;

    my $password     = 'AbcdEFG123';
    my $bad_password = '123456789';

    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

    my $patron =
        $builder->build_object( { class => 'Koha::Patrons', value => { userid => 'tomasito', flags => 2**4 } } );
    $patron->set_password( { password => $password } );
    my $userid = $patron->userid;

    $t->get_ok("//$userid:$password@/api/v1/patrons")->status_is( 200, 'All good' );

    # expire patron's password
    $patron->password_expiration_date( dt_from_string->subtract( days => 1 ) )->store;

    $t->get_ok("//$userid:$password@/api/v1/patrons")->status_is(403)
        ->json_is( '/error' => 'Password has expired', 'Password expired' );

    $t->get_ok("//@/api/v1/patrons")->status_is( 401, 'No credentials passed' );

    $t->get_ok("//$userid:$bad_password@/api/v1/patrons")->status_is( 403, 'Failed authentication, invalid password' )
        ->json_is( '/error' => 'Invalid password', 'Error message returned' );

    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 0 );

    $t->get_ok("//$userid:$password@/api/v1/patrons")->status_is( 401, 'Basic authentication is disabled' )
        ->json_is( '/error' => 'Basic authentication disabled', 'Expected error message rendered' );

    $schema->storage->txn_rollback;
};

1;
