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

use Koha::SIP2::Accounts;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 23;

    $schema->storage->txn_begin;

    Koha::SIP2::Accounts->search->delete;

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
    # No accounts, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/sip2/accounts")->status_is(200)->json_is( [] );

    my $account = $builder->build_object( { class => 'Koha::SIP2::Accounts' } );

    # One account created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/sip2/accounts")->status_is(200)->json_is( [ $account->to_api ] );

    my $another_account = $builder->build_object(
        {
            class => 'Koha::SIP2::Accounts',
            value => { login_id => 'koha' }
        }
    );

    # Two accounts created, they should both be returned
    $t->get_ok("//$userid:$password@/api/v1/sip2/accounts")->status_is(200)->json_is(
        [
            $account->to_api,
            $another_account->to_api,
        ]
    );

    # Filtering works, single account with queried sip_account_id
    $t->get_ok( "//$userid:$password@/api/v1/sip2/accounts?sip_account_id=" . $another_account->sip_account_id )
        ->status_is(200)
        ->json_is( [ $another_account->to_api ] );

    # Attempt to search by login_id like 'ko'
    $account->delete;
    $another_account->delete;
    $t->get_ok(qq~//$userid:$password@/api/v1/sip2/accounts?q=[{"me.login_id":{"like":"%ko%"}}]~)
        ->status_is(200)
        ->json_is( [] );

    my $account_to_search = $builder->build_object(
        {
            class => 'Koha::SIP2::Accounts',
            value => {
                login_id => 'koha',
            }
        }
    );

    # Search works, searching for login_id like 'ko'
    $t->get_ok(qq~//$userid:$password@/api/v1/sip2/accounts?q=[{"me.login_id":{"like":"%ko%"}}]~)
        ->status_is(200)
        ->json_is( [ $account_to_search->to_api ] );

    # Warn on unsupported query parameter
    $t->get_ok("//$userid:$password@/api/v1/sip2/accounts?blah=blah")
        ->status_is(400)
        ->json_is( [ { path => '/query/blah', message => 'Malformed query string' } ] );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/sip2/accounts")->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $account   = $builder->build_object( { class => 'Koha::SIP2::Accounts' } );
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

    # This account exists, should get returned
    $t->get_ok( "//$userid:$password@/api/v1/sip2/accounts/" . $account->sip_account_id )
        ->status_is(200)
        ->json_is( $account->to_api );

    # Unauthorized access
    $t->get_ok( "//$unauth_userid:$password@/api/v1/sip2/accounts/" . $account->sip_account_id )->status_is(403);

    # Attempt to get non-existent account
    my $account_to_delete = $builder->build_object( { class => 'Koha::SIP2::Accounts' } );
    my $non_existent_id   = $account_to_delete->sip_account_id;
    $account_to_delete->delete;

    $t->get_ok("//$userid:$password@/api/v1/sip2/accounts/$non_existent_id")
        ->status_is(404)
        ->json_is( '/error' => 'Account not found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 16;

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
    my $account_obj   = $builder->build_object( { class => 'Koha::SIP2::Institutions' } );

    my $account = {
        login_id           => "koha",
        sip_institution_id => $account_obj->sip_institution_id,
    };

    # Unauthorized attempt to write
    $t->post_ok( "//$unauth_userid:$password@/api/v1/sip2/accounts" => json => $account )->status_is(403);

    # Authorized attempt to write invalid data
    my $account_with_invalid_field = {
        blah               => "Account Blah",
        login_id           => "koha",
        sip_institution_id => $account->{sip_institution_id},
    };

    $t->post_ok( "//$userid:$password@/api/v1/sip2/accounts" => json => $account_with_invalid_field )
        ->status_is(400)
        ->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
        );

    # Authorized attempt to write
    my $sip_account_id =
        $t->post_ok( "//$userid:$password@/api/v1/sip2/accounts" => json => $account )
        ->status_is( 201, 'REST3.2.1' )
        ->header_like(
        Location => qr|^/api/v1/sip2/accounts/\d*|,
        'REST3.4.1'
        )
        ->json_is( '/login_id'           => $account->{login_id} )
        ->json_is( '/sip_institution_id' => $account->{sip_institution_id} )
        ->tx->res->json->{sip_account_id};

    # Authorized attempt to create with null id
    $account->{sip_account_id} = undef;
    $t->post_ok( "//$userid:$password@/api/v1/sip2/accounts" => json => $account )->status_is(400)->json_has('/errors');

    # Authorized attempt to create with existing id
    $account->{sip_account_id} = $sip_account_id;

    $t->post_ok( "//$userid:$password@/api/v1/sip2/accounts" => json => $account )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Read-only.",
                path    => "/body/sip_account_id"
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

    my $sip_account_id = $builder->build_object( { class => 'Koha::SIP2::Accounts' } )->sip_account_id;

    # Unauthorized attempt to update
    $t->put_ok( "//$unauth_userid:$password@/api/v1/sip2/accounts/$sip_account_id" => json =>
            { name => 'New unauthorized name change' } )->status_is(403);

    my $account = $builder->build_object( { class => 'Koha::SIP2::Institutions' } );

    # Attempt partial update on a PUT
    my $account_with_missing_field = {
        sip_institution_id => $account->sip_institution_id,
    };

    $t->put_ok( "//$userid:$password@/api/v1/sip2/accounts/$sip_account_id" => json => $account_with_missing_field )
        ->status_is(400)
        ->json_is( "/errors" => [ { message => "Missing property.", path => "/body/login_id" } ] );

    # Full object update on PUT
    my $account_with_updated_field = {
        login_id           => "new koha",
        sip_institution_id => $account->sip_institution_id,
    };

    $t->put_ok( "//$userid:$password@/api/v1/sip2/accounts/$sip_account_id" => json => $account_with_updated_field )
        ->status_is(200)
        ->json_is( '/login_id' => 'new koha' );

    # Authorized attempt to write invalid data
    my $account_with_invalid_field = {
        blah               => "Account Blah",
        login_id           => "koha",
        sip_institution_id => $account->sip_institution_id,
    };

    $t->put_ok( "//$userid:$password@/api/v1/sip2/accounts/$sip_account_id" => json => $account_with_invalid_field )
        ->status_is(400)
        ->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
        );

    # Attempt to update non-existent account
    my $account_to_delete = $builder->build_object( { class => 'Koha::SIP2::Accounts' } );
    my $non_existent_id   = $account_to_delete->id;
    $account_to_delete->delete;

    $t->put_ok( "//$userid:$password@/api/v1/sip2/accounts/$non_existent_id" => json => $account_with_updated_field )
        ->status_is(404);

    # Wrong method (POST)
    $account_with_updated_field->{sip_account_id} = 2;

    $t->post_ok( "//$userid:$password@/api/v1/sip2/accounts/$sip_account_id" => json => $account_with_updated_field )
        ->status_is(404);

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

    my $sip_account_id = $builder->build_object( { class => 'Koha::SIP2::Accounts' } )->sip_account_id;

    # Unauthorized attempt to delete
    $t->delete_ok("//$unauth_userid:$password@/api/v1/sip2/accounts/$sip_account_id")->status_is(403);

    # Delete existing account
    $t->delete_ok("//$userid:$password@/api/v1/sip2/accounts/$sip_account_id")
        ->status_is( 204, 'REST3.2.4' )
        ->content_is( '', 'REST3.3.4' );

    # Attempt to delete non-existent account
    $t->delete_ok("//$userid:$password@/api/v1/sip2/accounts/$sip_account_id")->status_is(404);

    $schema->storage->txn_rollback;
};
