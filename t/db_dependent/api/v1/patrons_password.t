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
use Test::More tests => 3;

use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Patrons;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'set() (authorized user tests)' => sub {

    plan tests => 21;

    $schema->storage->txn_begin;

    my $privileged_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 1 }
        }
    );
    my $password = 'thePassword123';
    $privileged_patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $privileged_patron->userid;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    t::lib::Mocks::mock_preference( 'minPasswordLength',     3 );
    t::lib::Mocks::mock_preference( 'RequireStrongPassword', 0 );

    my $new_password = 'abc';

    $t->post_ok( "//$userid:$password@/api/v1/patrons/"
            . $patron->id
            . "/password" => json => { password => $new_password, password_2 => $new_password } )->status_is(200)
        ->json_is('');

    $t->post_ok( "//$userid:$password@/api/v1/patrons/"
            . $patron->id
            . "/password" => json => { password => $new_password, password_2 => 'cde' } )->status_is(400)
        ->json_is( { error => 'Passwords don\'t match' } );

    t::lib::Mocks::mock_preference( 'minPasswordLength', 5 );

    $t->post_ok( "//$userid:$password@/api/v1/patrons/"
            . $patron->id
            . "/password" => json => { password => $new_password, password_2 => $new_password } )->status_is(400)
        ->json_is( { error => 'Password length (3) is shorter than required (5)' } );

    $new_password = 'abc   ';
    $t->post_ok( "//$userid:$password@/api/v1/patrons/"
            . $patron->id
            . "/password" => json => { password => $new_password, password_2 => $new_password } )->status_is(400)
        ->json_is( { error => '[Password contains leading/trailing whitespace character(s)]' } );

    $new_password = 'abcdefg';
    $t->post_ok( "//$userid:$password@/api/v1/patrons/"
            . $patron->id
            . "/password" => json => { password => $new_password, password_2 => $new_password } )->status_is(200)
        ->json_is('');

    t::lib::Mocks::mock_preference( 'RequireStrongPassword', 1 );
    $t->post_ok( "//$userid:$password@/api/v1/patrons/"
            . $patron->id
            . "/password" => json => { password => $new_password, password_2 => $new_password } )->status_is(400)
        ->json_is( { error => '[Password is too weak]' } );

    $new_password = 'ABcde123%&';
    $t->post_ok( "//$userid:$password@/api/v1/patrons/"
            . $patron->id
            . "/password" => json => { password => $new_password, password_2 => $new_password } )->status_is(200)
        ->json_is('');

    $schema->storage->txn_rollback;
};

subtest 'set_public() (unprivileged user tests)' => sub {

    plan tests => 21;

    $schema->storage->txn_begin;

    my $category = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => { change_password => 0 }      # disallow changing password for the patron category
        }
    );
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { categorycode => $category->id }
        }
    );

    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid       = $patron->userid;
    my $other_patron = $builder->build_object( { class => 'Koha::Patrons' } );

    # Enable the public API
    t::lib::Mocks::mock_preference( 'RESTPublicAPI', 1 );

    t::lib::Mocks::mock_preference( 'OpacPasswordChange',    0 );
    t::lib::Mocks::mock_preference( 'minPasswordLength',     3 );
    t::lib::Mocks::mock_preference( 'RequireStrongPassword', 0 );

    my $new_password = 'abc';

    $t->post_ok(
        "//$userid:$password@/api/v1/public/patrons/" . $patron->id . "/password" => json => {
            password          => $new_password,
            password_repeated => $new_password,
            old_password      => 'blah'
        }
    )->status_is(403)->json_is( { error => 'Changing password is forbidden' } );

    $t->post_ok(
        "/api/v1/public/patrons/" . $patron->id . "/password" => json => {
            password          => $new_password,
            password_repeated => $new_password,
            old_password      => $password
        }
    )->status_is(401)->json_is(
        '/error',
        "Authentication failure."
    );

    t::lib::Mocks::mock_preference( 'OpacPasswordChange', 1 );

    $t->post_ok(
        "//$userid:$password@/api/v1/public/patrons/" . $other_patron->id . "/password" => json => {
            password          => $new_password,
            password_repeated => $new_password,
            old_password      => $password
        }
    )->status_is(403)->json_is(
        '/error',
        "Changing other patron's password is forbidden"
    );

    $t->post_ok(
        "//$userid:$password@/api/v1/public/patrons/" . $patron->id . "/password" => json => {
            password          => $new_password,
            password_repeated => $new_password,
            old_password      => $password
        }
    )->status_is(403)->json_is( { error => 'Changing password is forbidden' } );

    # Allow password changing to the patron category
    $category->change_password(1)->store;

    $t->post_ok(
        "//$userid:$password@/api/v1/public/patrons/" . $patron->id . "/password" => json => {
            password          => $new_password,
            password_repeated => 'wrong_password',
            old_password      => $password
        }
    )->status_is(400)->json_is( { error => "Passwords don't match" } );

    $t->post_ok(
        "//$userid:$password@/api/v1/public/patrons/" . $patron->id . "/password" => json => {
            password          => $new_password,
            password_repeated => $new_password,
            old_password      => 'badpassword'
        }
    )->status_is(400)->json_is( { error => "Invalid password" } );

    $t->post_ok(
        "//$userid:$password@/api/v1/public/patrons/" . $patron->id . "/password" => json => {
            password          => $new_password,
            password_repeated => $new_password,
            old_password      => $password
        }
    )->status_is(200)->json_is('');

    $schema->storage->txn_rollback;
};
