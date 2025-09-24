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
use Test::More tests => 2;
use Test::Mojo;

use JSON qw(encode_json);

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Virtualshelves;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list_public() tests' => sub {

    plan tests => 30;

    $schema->storage->txn_begin;

    my $password = 'thePassword123';

    my $patron_1 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron_2 = $builder->build_object( { class => 'Koha::Patrons' } );

    $patron_1->set_password( { password => $password, skip_validation => 1 } );
    my $patron_1_userid = $patron_1->userid;

    $patron_2->set_password( { password => $password, skip_validation => 1 } );
    my $patron_2_userid = $patron_2->userid;

    my $list_1 =
        $builder->build_object( { class => 'Koha::Virtualshelves', value => { owner => $patron_1->id, public => 1 } } );
    my $list_2 =
        $builder->build_object( { class => 'Koha::Virtualshelves', value => { owner => $patron_1->id, public => 0 } } );
    my $list_3 =
        $builder->build_object( { class => 'Koha::Virtualshelves', value => { owner => $patron_2->id, public => 1 } } );
    my $list_4 =
        $builder->build_object( { class => 'Koha::Virtualshelves', value => { owner => $patron_2->id, public => 0 } } );

    my $q = encode_json(
        {
            list_id => {
                -in => [
                    $list_1->id,
                    $list_2->id,
                    $list_3->id,
                    $list_4->id,
                ]
            }
        }
    );

    # anonymous
    $t->get_ok("/api/v1/public/lists?q=$q")->status_is( 200, "Anonymous users can only fetch public lists" )
        ->json_is( [ $list_1->to_api( { public => 1 } ), $list_3->to_api( { public => 1 } ) ] );

    $t->get_ok("/api/v1/public/lists?q=$q&only_public=1")
        ->status_is( 200, "Anonymous users can only fetch public lists" )
        ->json_is( [ $list_1->to_api( { public => 1 } ), $list_3->to_api( { public => 1 } ) ] );

    $t->get_ok("/api/v1/public/lists?q=$q&only_mine=1")
        ->status_is( 400, "Passing only_mine on an anonymous session generates a 400 code" )
        ->json_is( '/error_code' => q{only_mine_forbidden} );

    $t->get_ok("//$patron_1_userid:$password@/api/v1/public/lists?q=$q&only_mine=1")
        ->status_is( 200, "Passing only_mine with a logged in user makes it return only their lists" )
        ->json_is( [ $list_1->to_api( { public => 1 } ), $list_2->to_api( { public => 1 } ) ] );

    $t->get_ok("//$patron_2_userid:$password@/api/v1/public/lists?q=$q&only_mine=1")
        ->status_is( 200, "Passing only_mine with a logged in user makes it return only their lists" )
        ->json_is( [ $list_3->to_api( { public => 1 } ), $list_4->to_api( { public => 1 } ) ] );

    # only public
    $t->get_ok("//$patron_1_userid:$password@/api/v1/public/lists?q=$q&only_public=1")
        ->status_is( 200, "Passing only_public with a logged in user makes it return only public lists" )
        ->json_is( [ $list_1->to_api( { public => 1 } ), $list_3->to_api( { public => 1 } ) ] );

    $t->get_ok("//$patron_2_userid:$password@/api/v1/public/lists?q=$q&only_public=1")
        ->status_is( 200, "Passing only_public with a logged in user makes it return only public lists" )
        ->json_is( [ $list_1->to_api( { public => 1 } ), $list_3->to_api( { public => 1 } ) ] );

    $t->get_ok("//$patron_1_userid:$password@/api/v1/public/lists?q=$q")
        ->status_is( 200, "Not filtering with only_mine or only_public makes it return all accessible lists" )
        ->json_is(
        [ $list_1->to_api( { public => 1 } ), $list_2->to_api( { public => 1 } ), $list_3->to_api( { public => 1 } ) ]
        );

    $t->get_ok("//$patron_2_userid:$password@/api/v1/public/lists?q=$q")
        ->status_is( 200, "Not filtering with only_mine or only_public makes it return all accessible lists" )
        ->json_is(
        [ $list_1->to_api( { public => 1 } ), $list_3->to_api( { public => 1 } ), $list_4->to_api( { public => 1 } ) ]
        );

    # conflicting params
    $t->get_ok("//$patron_1_userid:$password@/api/v1/public/lists?q=$q&only_public=1&only_mine=1")
        ->status_is( 200, "Passing only_public with a logged in user makes it return only public lists" )
        ->json_is( [ $list_1->to_api( { public => 1 } ) ] );

    $schema->storage->txn_rollback;
};
