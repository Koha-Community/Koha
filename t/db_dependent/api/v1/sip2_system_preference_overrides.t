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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 6;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::SIP2::SystemPreferenceOverrides;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 20;

    $schema->storage->txn_begin;

    Koha::SIP2::SystemPreferenceOverrides->search->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**31 }
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    ## Authorized user tests
    # No system preference overrides, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/sip2/system_preference_overrides")->status_is(200)->json_is( [] );

    my $sys_pref_override = $builder->build_object( { class => 'Koha::SIP2::SystemPreferenceOverrides' } );

    # One system preference override created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/sip2/system_preference_overrides")->status_is(200)
        ->json_is( [ $sys_pref_override->to_api ] );

    my $another_system_preference_override = $builder->build_object(
        {
            class => 'Koha::SIP2::SystemPreferenceOverrides',
            value => { variable => 'koha' }
        }
    );

    # Two system preference overrides created, they should both be returned
    $t->get_ok("//$userid:$password@/api/v1/sip2/system_preference_overrides")->status_is(200)->json_is(
        [
            $sys_pref_override->to_api,
            $another_system_preference_override->to_api,
        ]
    );

    # Attempt to search by name like 'ko'
    $sys_pref_override->delete;
    $another_system_preference_override->delete;
    $t->get_ok(qq~//$userid:$password@/api/v1/sip2/system_preference_overrides?q=[{"me.variable":{"like":"%ko%"}}]~)
        ->status_is(200)->json_is( [] );

    my $system_preference_override_to_search = $builder->build_object(
        {
            class => 'Koha::SIP2::SystemPreferenceOverrides',
            value => {
                variable => 'koha',
            }
        }
    );

    # Search works, searching for name like 'ko'
    $t->get_ok(qq~//$userid:$password@/api/v1/sip2/system_preference_overrides?q=[{"me.variable":{"like":"%ko%"}}]~)
        ->status_is(200)->json_is( [ $system_preference_override_to_search->to_api ] );

    # Warn on unsupported query parameter
    $t->get_ok("//$userid:$password@/api/v1/sip2/system_preference_overrides?blah=blah")->status_is(400)
        ->json_is( [ { path => '/query/blah', message => 'Malformed query string' } ] );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/sip2/system_preference_overrides")->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $sys_pref_override = $builder->build_object( { class => 'Koha::SIP2::SystemPreferenceOverrides' } );
    my $librarian         = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**31 }
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    # This system preference override exists, should get returned
    $t->get_ok( "//$userid:$password@/api/v1/sip2/system_preference_overrides/"
            . $sys_pref_override->sip_system_preference_override_id )->status_is(200)
        ->json_is( $sys_pref_override->to_api );

    # Unauthorized access
    $t->get_ok( "//$unauth_userid:$password@/api/v1/sip2/system_preference_overrides/"
            . $sys_pref_override->sip_system_preference_override_id )->status_is(403);

    # Attempt to get non-existent system preference override
    my $system_preference_override_to_delete =
        $builder->build_object( { class => 'Koha::SIP2::SystemPreferenceOverrides' } );
    my $non_existent_id = $system_preference_override_to_delete->sip_system_preference_override_id;
    $system_preference_override_to_delete->delete;

    $t->get_ok("//$userid:$password@/api/v1/sip2/system_preference_overrides/$non_existent_id")->status_is(404)
        ->json_is( '/error' => 'System preference override not found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 18;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**31 }
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    my $sys_pref_override = {
        variable => "mypref",
        value    => "myvalue",
    };

    # Unauthorized attempt to write
    $t->post_ok( "//$unauth_userid:$password@/api/v1/sip2/system_preference_overrides" => json => $sys_pref_override )
        ->status_is(403);

    # Authorized attempt to write invalid data
    my $system_preference_override_with_invalid_field = {
        blah     => "system preference override Blah",
        variable => "mypref",
        value    => "myvalue",
    };

    $t->post_ok( "//$userid:$password@/api/v1/sip2/system_preference_overrides" => json =>
            $system_preference_override_with_invalid_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
            );

    # Authorized attempt to write
    my $sip_system_preference_override_id =
        $t->post_ok( "//$userid:$password@/api/v1/sip2/system_preference_overrides" => json => $sys_pref_override )
        ->status_is( 201, 'REST3.2.1' )->header_like(
        Location => qr|^/api/v1/sip2/system_preference_overrides/\d*|,
        'REST3.4.1'
    )->json_is( '/name' => $sys_pref_override->{name} )
        ->json_is( '/implementation' => $sys_pref_override->{implementation} )
        ->json_is( '/retries'        => $sys_pref_override->{retries} )
        ->json_is( '/timeout' => $sys_pref_override->{timeout} )->tx->res->json->{sip_system_preference_override_id};

    # Authorized attempt to create with null id
    $sys_pref_override->{sip_system_preference_override_id} = undef;
    $t->post_ok( "//$userid:$password@/api/v1/sip2/system_preference_overrides" => json => $sys_pref_override )
        ->status_is(400)->json_has('/errors');

    # Authorized attempt to create with existing id
    $sys_pref_override->{sip_system_preference_override_id} = $sip_system_preference_override_id;

    $t->post_ok( "//$userid:$password@/api/v1/sip2/system_preference_overrides" => json => $sys_pref_override )
        ->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Read-only.",
                path    => "/body/sip_system_preference_override_id"
            }
        ]
        );

    $schema->storage->txn_rollback;
};

subtest 'update() tests' => sub {

    plan tests => 15;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**31 }
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    my $sip_system_preference_override_id =
        $builder->build_object( { class => 'Koha::SIP2::SystemPreferenceOverrides' } )
        ->sip_system_preference_override_id;

    # Unauthorized attempt to update
    $t->put_ok(
        "//$unauth_userid:$password@/api/v1/sip2/system_preference_overrides/$sip_system_preference_override_id" =>
            json => { name => 'New unauthorized name change' } )->status_is(403);

    # Attempt partial update on a PUT
    my $system_preference_override_with_missing_field = {
        variable => "mypref",
    };

    $t->put_ok(
        "//$userid:$password@/api/v1/sip2/system_preference_overrides/$sip_system_preference_override_id" => json =>
            $system_preference_override_with_missing_field )->status_is(400)
        ->json_is( "/errors" => [ { message => "Missing property.", path => "/body/value" } ] );

    # Full object update on PUT
    my $system_preference_override_with_updated_field = {
        variable => "mypref",
        value    => "mynewvalue",
    };

    $t->put_ok(
        "//$userid:$password@/api/v1/sip2/system_preference_overrides/$sip_system_preference_override_id" => json =>
            $system_preference_override_with_updated_field )->status_is(200)->json_is( '/value' => 'mynewvalue' );

    # Authorized attempt to write invalid data
    my $system_preference_override_with_invalid_field = {
        blah     => "system preference override Blah",
        variable => "mypref",
        value    => "mynewvalue",
    };

    $t->put_ok(
        "//$userid:$password@/api/v1/sip2/system_preference_overrides/$sip_system_preference_override_id" => json =>
            $system_preference_override_with_invalid_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
            );

    # Attempt to update non-existent system preference override
    my $system_preference_override_to_delete =
        $builder->build_object( { class => 'Koha::SIP2::SystemPreferenceOverrides' } );
    my $non_existent_id = $system_preference_override_to_delete->id;
    $system_preference_override_to_delete->delete;

    $t->put_ok( "//$userid:$password@/api/v1/sip2/system_preference_overrides/$non_existent_id" => json =>
            $system_preference_override_with_updated_field )->status_is(404);

    # Wrong method (POST)
    $system_preference_override_with_updated_field->{sip_system_preference_override_id} = 2;

    $t->post_ok(
        "//$userid:$password@/api/v1/sip2/system_preference_overrides/$sip_system_preference_override_id" => json =>
            $system_preference_override_with_updated_field )->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**31 }
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    my $sip_system_preference_override_id =
        $builder->build_object( { class => 'Koha::SIP2::SystemPreferenceOverrides' } )
        ->sip_system_preference_override_id;

    # Unauthorized attempt to delete
    $t->delete_ok(
        "//$unauth_userid:$password@/api/v1/sip2/system_preference_overrides/$sip_system_preference_override_id")
        ->status_is(403);

    # Delete existing system preference override
    $t->delete_ok("//$userid:$password@/api/v1/sip2/system_preference_overrides/$sip_system_preference_override_id")
        ->status_is( 204, 'REST3.2.4' )->content_is( '', 'REST3.3.4' );

    # Attempt to delete non-existent system preference override
    $t->delete_ok("//$userid:$password@/api/v1/sip2/system_preference_overrides/$sip_system_preference_override_id")
        ->status_is(404);

    $schema->storage->txn_rollback;
};
