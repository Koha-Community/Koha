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
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 6;
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::SearchFilters;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    Koha::SearchFilters->search()->delete();

    my $patron_1 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 3 }
        }
    );
    my $password = 'thePassword123';
    $patron_1->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron_1->userid;

    # Create test context
    my $search_filter_1 = $builder->build_object(
        {
            class => 'Koha::SearchFilters',
            value => {
                name         => 'Test1',
                query        => 'kw:this',
                limits       => 'mc-itype,phr:BK',
                opac         => 1,
                staff_client => 1
            }
        }
    );
    my $search_filter_2 = $builder->build_object(
        {
            class => 'Koha::SearchFilters',
            value => {
                name         => 'Test2',
                query        => 'kw:that',
                limits       => 'mc-itype,phr:BK',
                opac         => 0,
                staff_client => 1
            }
        }
    );
    my $search_filter_3 = $builder->build_object(
        {
            class => 'Koha::SearchFilters',
            value => {
                name         => 'Test3',
                query        => 'kw:any',
                limits       => 'mc-itype,phr:CD',
                opac         => 0,
                staff_client => 0
            }
        }
    );
    my $search_filter_4 = $builder->build_object(
        {
            class => 'Koha::SearchFilters',
            value => {
                name         => 'Test4',
                query        => 'kw:some',
                limits       => 'mc-itype,phr:CD',
                opac         => 1,
                staff_client => 0
            }
        }
    );

    # Make sure we are returned with the correct amount of macros
    $t->get_ok("//$userid:$password@/api/v1/search_filters")->status_is( 200, 'REST3.2.2' )
        ->json_has('/0/search_filter_id')->json_has('/1/search_filter_id')->json_has('/2/search_filter_id')
        ->json_has('/3/search_filter_id');

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 3 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    my $search_filter_1 = $builder->build_object( { class => 'Koha::SearchFilters' } );
    my $search_filter_2 = $builder->build_object( { class => 'Koha::SearchFilters' } );
    my $search_filter_3 = $builder->build_object( { class => 'Koha::SearchFilters' } );

    $t->get_ok( "//$userid:$password@/api/v1/search_filters/" . $search_filter_1->id )
        ->status_is( 200, 'Filter retrieved correctly' )->json_is( $search_filter_1->to_api );

    my $non_existent_code = $search_filter_1->id;
    $search_filter_1->delete;

    $t->get_ok( "//$userid:$password@/api/v1/search_filters/" . $non_existent_code )->status_is(404)
        ->json_is( '/error' => 'Search filter not found' );

    $patron->flags(4)->store;
    $t->get_ok( "//$userid:$password/api/v1/search_filters/" . $search_filter_2->id )
        ->status_is( 401, 'Cannot search filters without permission' )
        ->json_is( '/error' => 'Authentication failure.' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 17;

    $schema->storage->txn_begin;

    my $authorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $authorized_patron->borrowernumber,
                module_bit     => 3,
                code           => 'manage_search_filters',
            },
        }
    );

    my $password = 'thePassword123';
    $authorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $auth_userid = $authorized_patron->userid;

    my $unauthorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    $unauthorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $unauthorized_patron->userid;

    my $search_filter        = $builder->build_object( { class => 'Koha::SearchFilters' } );
    my $search_filter_values = $search_filter->to_api;
    delete $search_filter_values->{search_filter_id};
    $search_filter->delete;

    # Unauthorized attempt to write
    $t->post_ok( "//$unauth_userid:$password@/api/v1/search_filters" => json => $search_filter_values )->status_is(403);

    # Authorized attempt to write invalid data
    my $search_filter_with_invalid_field = {%$search_filter_values};
    $search_filter_with_invalid_field->{'coffee_filter'} = 'Chemex';

    $t->post_ok( "//$auth_userid:$password@/api/v1/search_filters" => json => $search_filter_with_invalid_field )
        ->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: coffee_filter.",
                path    => "/body"
            }
        ]
        );

    # Authorized attempt to write
    $t->post_ok( "//$auth_userid:$password@/api/v1/search_filters" => json => $search_filter_values )
        ->status_is( 201, 'REST3.2.1' )->json_has( '/search_filter_id', 'We generated a new id' )
        ->json_is( '/name'         => $search_filter_values->{name},         'The name matches what we supplied' )
        ->json_is( '/query'        => $search_filter_values->{query},        'The query matches what we supplied' )
        ->json_is( '/limits'       => $search_filter_values->{limits},       'The limits match what we supplied' )
        ->json_is( '/opac'         => $search_filter_values->{opac},         'The limits match what we supplied' )
        ->json_is( '/staff_client' => $search_filter_values->{staff_client}, 'The limits match what we supplied' )
        ->header_like( Location => qr|^\/api\/v1\/search_filters\/d*|, 'Correct location' );

    # save the library_id
    my $search_filter_id = 999;

    # Authorized attempt to create with existing id
    $search_filter_values->{search_filter_id} = $search_filter_id;

    $t->post_ok( "//$auth_userid:$password@/api/v1/search_filters" => json => $search_filter_values )->status_is(400)
        ->json_is(
        '/errors' => [
            {
                message => "Read-only.",
                path    => "/body/search_filter_id"
            }
        ]
        );

    $schema->storage->txn_rollback;
};

subtest 'update() tests' => sub {

    plan tests => 15;

    $schema->storage->txn_begin;

    my $authorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $authorized_patron->borrowernumber,
                module_bit     => 3,
                code           => 'manage_search_filters',
            },
        }
    );

    my $password = 'thePassword123';
    $authorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $auth_userid = $authorized_patron->userid;

    my $unauthorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    $unauthorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $unauthorized_patron->userid;

    my $search_filter        = $builder->build_object( { class => 'Koha::SearchFilters' } );
    my $search_filter_id     = $search_filter->id;
    my $search_filter_values = $search_filter->to_api;
    delete $search_filter_values->{search_filter_id};

    # Unauthorized attempt to update
    $t->put_ok( "//$unauth_userid:$password@/api/v1/search_filters/$search_filter_id" => json =>
            { name => 'New unauthorized name change' } )->status_is(403);

    my $search_filter_update = {
        name   => "Filter update",
        query  => "ti:The hobbit",
        limits => "mc-ccode:fantasy",
    };

    my $test = $t->put_ok(
        "//$auth_userid:$password@/api/v1/search_filters/$search_filter_id" => json => $search_filter_update )
        ->status_is( 200, 'Authorized user can update a macro' )
        ->json_is( '/search_filter_id' => $search_filter_id,               'We get back the id' )
        ->json_is( '/name'             => $search_filter_update->{name},   'We get back the name' )
        ->json_is( '/query'            => $search_filter_update->{query},  'We get back our query' )
        ->json_is( '/limits'           => $search_filter_update->{limits}, 'We get back our limits' )
        ->json_is( '/opac'             => 1,                               'We get back our opac visibility unchanged' )
        ->json_is( '/staff_client'     => 1, 'We get back our staff client visibility unchanged' );

    # Authorized attempt to write invalid data
    my $search_filter_with_invalid_field = {%$search_filter_update};
    $search_filter_with_invalid_field->{'coffee_filter'} = 'Chemex';

    $t->put_ok( "//$auth_userid:$password@/api/v1/search_filters/$search_filter_id" => json =>
            $search_filter_with_invalid_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: coffee_filter.",
                path    => "/body"
            }
        ]
            );

    my $non_existent_macro = $builder->build_object( { class => 'Koha::SearchFilters' } );
    my $non_existent_code  = $non_existent_macro->id;
    $non_existent_macro->delete;

    $t->put_ok( "//$auth_userid:$password@/api/v1/search_filters/$non_existent_code" => json => $search_filter_update )
        ->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $authorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $authorized_patron->borrowernumber,
                module_bit     => 3,
                code           => 'manage_search_filters',
            },
        }
    );

    my $password = 'thePassword123';
    $authorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $auth_userid = $authorized_patron->userid;

    my $unauthorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    $unauthorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $unauthorized_patron->userid;

    my $search_filter      = $builder->build_object( { class => 'Koha::SearchFilters' } );
    my $search_filter_2    = $builder->build_object( { class => 'Koha::SearchFilters' } );
    my $search_filter_id   = $search_filter->id;
    my $search_filter_2_id = $search_filter_2->id;

    # Unauthorized attempt to delete
    $t->delete_ok("//$unauth_userid:$password@/api/v1/search_filters/$search_filter_2_id")
        ->status_is( 403, "Cannot delete search filter without permission" );

    $t->delete_ok("//$auth_userid:$password@/api/v1/search_filters/$search_filter_id")
        ->status_is( 204, 'Can delete search filter with permission' );

    $schema->storage->txn_rollback;
};
