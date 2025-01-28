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
use Test::More tests => 6;
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use List::Util qw(min);

use Koha::Biblio::ItemGroups;
use Koha::Libraries;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth',    1 );
t::lib::Mocks::mock_preference( 'EnableItemGroups', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {
    plan tests => 9;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 4 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    my $biblio    = $builder->build_sample_biblio();
    my $biblio_id = $biblio->id;

    $t->get_ok("//$userid:$password@/api/v1/biblios/$biblio_id/item_groups")->status_is( 200, 'REST3.2.2' );
    my $response_count = scalar @{ $t->tx->res->json };
    is( $response_count, 0, 'Results count is 2' );

    my $item_group_1 =
        Koha::Biblio::ItemGroup->new( { biblio_id => $biblio->id, display_order => 1, description => "Vol 1" } )
        ->store();

    $t->get_ok("//$userid:$password@/api/v1/biblios/$biblio_id/item_groups")->status_is( 200, 'REST3.2.2' );
    $response_count = scalar @{ $t->tx->res->json };
    is( $response_count, 1, 'Results count is 2' );

    my $item_group_2 =
        Koha::Biblio::ItemGroup->new( { biblio_id => $biblio->id, display_order => 2, description => "Vol 2" } )
        ->store();

    $t->get_ok("//$userid:$password@/api/v1/biblios/$biblio_id/item_groups")->status_is( 200, 'REST3.2.2' );

    $response_count = scalar @{ $t->tx->res->json };
    is( $response_count, 2, 'Results count is 2' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $authorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 1 }
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

    my $biblio     = $builder->build_sample_biblio();
    my $biblio_id  = $biblio->id;
    my $item_group = { description => 'Vol 1', display_order => 1 };

    # Unauthorized attempt
    $t->post_ok( "//$unauth_userid:$password@/api/v1/biblios/$biblio_id/item_groups" => json => $item_group )
        ->status_is(403);

    # Authorized attempt
    $t->post_ok( "//$auth_userid:$password@/api/v1/biblios/$biblio_id/item_groups" => json => $item_group )
        ->status_is( 201, 'REST3.2.1' );

    # Invalid biblio id
    $t->post_ok( "//$auth_userid:$password@/api/v1/biblios/XXX/item_groups" => json => $item_group )->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'update() tests' => sub {
    plan tests => 9;

    $schema->storage->txn_begin;

    my $authorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 1 }
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

    my $biblio    = $builder->build_sample_biblio();
    my $biblio_id = $biblio->id;
    my $item_group =
        Koha::Biblio::ItemGroup->new( { biblio_id => $biblio->id, display_order => 1, description => "Vol 1" } )
        ->store();
    my $item_group_id = $item_group->id;

    # Unauthorized attempt
    $t->put_ok( "//$unauth_userid:$password@/api/v1/biblios/$biblio_id/item_groups/$item_group_id" => json =>
            { description => 'New unauthorized desc change' } )->status_is(403);

    # Authorized attempt
    $t->put_ok( "//$auth_userid:$password@/api/v1/biblios/$biblio_id/item_groups/$item_group_id" => json =>
            { description => "Vol A" } )->status_is( 200, 'REST3.2.1' )
        ->json_has( '/description' => "Vol A", 'REST3.3.3' );

    # Invalid biblio id
    $t->put_ok(
        "//$auth_userid:$password@/api/v1/biblios/XXX/item_groups/$item_group_id" => json => { description => "Vol A" }
    )->status_is(404);

    # Invalid item group id
    $t->put_ok(
        "//$auth_userid:$password@/api/v1/biblios/$biblio_id/item_groups/XXX" => json => { description => "Vol A" } )
        ->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {
    plan tests => 9;

    $schema->storage->txn_begin;

    my $authorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 1 }
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

    my $biblio    = $builder->build_sample_biblio();
    my $biblio_id = $biblio->id;
    my $item_group =
        Koha::Biblio::ItemGroup->new( { biblio_id => $biblio->id, display_order => 1, description => "Vol 1" } )
        ->store();
    my $item_groupid = $item_group->id;

    $t->delete_ok("//$auth_userid:$password@/api/v1/biblios/$biblio_id/item_groups/$item_groupid")
        ->status_is( 204, 'REST3.2.4' )->content_is( '', 'REST3.3.4' );

    # Unauthorized attempt to delete
    $t->delete_ok("//$unauth_userid:$password@/api/v1/biblios/$biblio_id/item_groups/$item_groupid")->status_is(403);

    $t->delete_ok("//$auth_userid:$password@/api/v1/biblios/XXX/item_groups/$item_groupid")->status_is(404);

    $t->delete_ok("//$auth_userid:$password@/api/v1/biblios/$biblio_id/item_groups/XXX")->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'volume items add() + delete() tests' => sub {
    plan tests => 14;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 4 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    my $biblio    = $builder->build_sample_biblio();
    my $biblio_id = $biblio->id;

    my $item_group =
        Koha::Biblio::ItemGroup->new( { biblio_id => $biblio->id, display_order => 1, description => "Vol 1" } )
        ->store();
    my $item_groupid = $item_group->id;

    my @items = $item_group->items->as_list;
    is( scalar(@items), 0, 'Item group has no items' );

    my $item_1    = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );
    my $item_1_id = $item_1->id;

    $t->post_ok(
        "//$userid:$password@/api/v1/biblios/XXX/item_groups/$item_groupid/items" => json => { item_id => $item_1->id }
    )->status_is(409)->json_is( { error => 'Item group does not belong to passed biblio_id' } );

    $t->post_ok( "//$userid:$password@/api/v1/biblios/$biblio_id/item_groups/$item_groupid/items" => json =>
            { item_id => $item_1->id } )->status_is( 201, 'REST3.2.1' );

    @items = $item_group->items;
    is( scalar(@items), 1, 'Item group now has one item' );

    my $item_2    = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );
    my $item_2_id = $item_2->id;

    $t->post_ok( "//$userid:$password@/api/v1/biblios/$biblio_id/item_groups/$item_groupid/items" => json =>
            { item_id => $item_2->id } )->status_is( 201, 'REST3.2.1' );

    @items = $item_group->items->as_list;
    is( scalar(@items), 2, 'Item group now has two items' );

    $t->delete_ok("//$userid:$password@/api/v1/biblios/$biblio_id/item_groups/$item_groupid/items/$item_1_id")
        ->status_is( 204, 'REST3.2.4' )->content_is( '', 'REST3.3.4' );

    @items = $item_group->items;
    is( scalar(@items), 1, 'Item group now has one item' );

    $schema->storage->txn_rollback;
};
