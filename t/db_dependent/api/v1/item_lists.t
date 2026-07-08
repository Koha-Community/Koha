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
use Test::MockModule;
use Test::More tests => 12;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Item::Lists;
use Koha::Item::ListContent;
use Koha::Item::ListShares;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

sub get_privileged_user {
    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**2 + 2**33 }    # catalogue flag = 2, item_lists flag = 33
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );

    return ( $librarian->userid, $librarian->borrowernumber, $password, $librarian );
}

sub get_unprivileged_staff {
    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**2 }
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );

    return ( $librarian->userid, $librarian->borrowernumber, $password, $librarian );
}

sub get_unprivileged_user {
    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );

    return ( $librarian->userid, $librarian->borrowernumber, $password, $librarian );
}

subtest 'list()' => sub {
    plan tests => 13;

    $schema->storage->txn_begin;

    Koha::Item::Lists->search()->delete();

    my ( $u, $bn, $p, $librarian ) = get_privileged_user();
    my ( $ux, $bnx, $px ) = get_unprivileged_user();

    $t->get_ok("/api/v1/item-lists")->status_is(401);

    $t->get_ok("//$ux:$px@/api/v1/item-lists")->status_is(403);

    $t->get_ok("//$u:$p@/api/v1/item-lists")->status_is(200)->json_is( [] );

    my $list = $builder->build_object( { class => 'Koha::Item::Lists', value => { visibility => 'public' } } );

    $t->get_ok("//$u:$p@/api/v1/item-lists")->status_is(200)->json_is( [ $list->to_api( { user => $librarian } ) ] );

    $list->delete();

    $t->get_ok("//$u:$p@/api/v1/item-lists")->status_is(200)->json_is( [] );

    $schema->storage->txn_rollback;
};

subtest 'create()' => sub {
    plan tests => 20;

    $schema->storage->txn_begin;

    Koha::Item::Lists->search()->delete();

    my ( $u,  $bn,  $p )  = get_privileged_user();
    my ( $ux, $bnx, $px ) = get_unprivileged_user();
    my ( $uy, $bny, $py ) = get_unprivileged_staff();

    my $list_template = {
        name       => 'Test name',
        visibility => 'public',
        owner      => $bn
    };

    my $list_template_invalid = {
        name            => 'Test name',
        visibility      => 'wrong',
        owner           => $bn,
        extra_parameter => 5
    };

    $t->post_ok( "/api/v1/item-lists" => json => $list_template )->status_is(401);

    $t->post_ok( "//$ux:$px@/api/v1/item-lists" => json => $list_template )->status_is(403);

    $t->post_ok( "//$uy:$py@/api/v1/item-lists" => json => $list_template )->status_is(403);

    $t->post_ok( "//$u:$p@/api/v1/item-lists" => json => $list_template_invalid )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: extra_parameter.",
                path    => "/body"
            }
        ]
    );

    delete $list_template_invalid->{extra_parameter};

    $t->post_ok( "//$u:$p@/api/v1/item-lists" => json => $list_template_invalid )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Not in enum list: private, group, public.",
                path    => "/body/visibility"
            }
        ]
    );

    $t->post_ok( "//$u:$p@/api/v1/item-lists" => json => $list_template )
        ->status_is(201)
        ->json_is( '/name',       $list_template->{name} )
        ->json_is( '/visibility', $list_template->{visibility} );

    my $list = Koha::Item::Lists->find( { name => $list_template->{name} } );
    is( $list->name,       $list_template->{name} );
    is( $list->visibility, $list_template->{visibility} );

    # Creating list with a duplicate name fails
    $t->post_ok( "//$u:$p@/api/v1/item-lists" => json => $list_template )->status_is(409);

    $schema->storage->txn_rollback;
};

subtest 'update()' => sub {
    plan tests => 22;

    $schema->storage->txn_begin;

    Koha::Item::Lists->search()->delete();

    my ( $u,  $bn,  $p )  = get_privileged_user();
    my ( $ux, $bnx, $px ) = get_unprivileged_user();

    my $list_template = {
        name       => 'Test name',
        visibility => 'public',
        owner      => $bn
    };

    my $list_template_invalid = {
        name            => 'Test name',
        visibility      => 'wrong',
        owner           => $bn,
        extra_parameter => 5
    };

    my $list    = $builder->build_object( { class => 'Koha::Item::Lists', value => { visibility => 'public' } } );
    my $list_id = $list->id;

    $t->put_ok( "/api/v1/item-lists/$list_id" => json => $list_template )->status_is(401);

    $t->put_ok( "//$ux:$px@/api/v1/item-lists/$list_id" => json => $list_template )->status_is(403);

    $t->put_ok( "//$u:$p@/api/v1/item-lists/$list_id" => json => $list_template_invalid )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: extra_parameter.",
                path    => "/body"
            }
        ]
    );

    delete $list_template_invalid->{extra_parameter};

    $t->put_ok( "//$u:$p@/api/v1/item-lists/$list_id" => json => $list_template_invalid )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Not in enum list: private, group, public.",
                path    => "/body/visibility"
            }
        ]
    );

    {
        my $m = Test::MockModule->new('Koha::Item::List')->mock( can_be_updated_by => 0 );
        $t->put_ok( "//$u:$p@/api/v1/item-lists/$list_id" => json => $list_template )->status_is(403);
    }

    $t->put_ok( "//$u:$p@/api/v1/item-lists/$list_id" => json => $list_template )
        ->status_is(200)
        ->json_is( '/name',       $list_template->{name} )
        ->json_is( '/visibility', $list_template->{visibility} );

    $list->discard_changes();
    is( $list->name,       $list_template->{name} );
    is( $list->visibility, $list_template->{visibility} );

    # Changing name to duplicate fails
    my $duplicate_list = $builder->build_object(
        { class => 'Koha::Item::Lists', value => { visibility => 'public', name => 'Duplicate name' } } );
    my $duplicate_list_id       = $duplicate_list->id;
    my $duplicate_list_template = {
        name       => 'Duplicate name',
        visibility => 'public',
        owner      => $bn
    };
    $t->put_ok( "//$u:$p@/api/v1/item-lists/$list_id" => json => $duplicate_list_template )->status_is(409);

    # But keeping the same name on the same list is fine
    $t->put_ok( "//$u:$p@/api/v1/item-lists/$duplicate_list_id" => json => $duplicate_list_template )->status_is(200);

    $schema->storage->txn_rollback;
};

subtest 'get()' => sub {
    plan tests => 17;

    $schema->storage->txn_begin;

    Koha::Item::Lists->search()->delete();

    my ( $u, $bn, $p, $librarian ) = get_privileged_user();
    my ( $ux, $bnx, $px ) = get_unprivileged_user();

    my $list     = $builder->build_object( { class => 'Koha::Item::Lists', value => { visibility => 'public' } } );
    my $list2    = $builder->build_object( { class => 'Koha::Item::Lists', value => { visibility => 'public' } } );
    my $list_id  = $list->id;
    my $list2_id = $list2->id;

    $t->get_ok("/api/v1/item-lists/$list_id")->status_is(401);

    $t->get_ok("//$ux:$px@/api/v1/item-lists/$list_id")->status_is(403);

    {
        my $m = Test::MockModule->new('Koha::Item::List')->mock( can_be_read_by => 0 );
        $t->get_ok("//$u:$p@/api/v1/item-lists/$list_id")->status_is(403);
    }

    $t->get_ok("//$u:$p@/api/v1/item-lists/$list_id")
        ->status_is(200)
        ->json_is( $list->to_api( { user => $librarian } ) );

    $t->get_ok("//$u:$p@/api/v1/item-lists/$list2_id")
        ->status_is(200)
        ->json_is( $list2->to_api( { user => $librarian } ) );

    $list->delete();

    $t->get_ok("//$u:$p@/api/v1/item-lists/$list_id")->status_is(404);

    $t->get_ok("//$u:$p@/api/v1/item-lists/$list2_id")
        ->status_is(200)
        ->json_is( $list2->to_api( { user => $librarian } ) );

    $schema->storage->txn_rollback;
};

subtest 'delete()' => sub {
    plan tests => 14;

    $schema->storage->txn_begin;

    Koha::Item::Lists->search()->delete();

    my ( $u,  $bn,  $p )  = get_privileged_user();
    my ( $ux, $bnx, $px ) = get_unprivileged_user();

    my $list     = $builder->build_object( { class => 'Koha::Item::Lists', value => { visibility => 'public' } } );
    my $list2    = $builder->build_object( { class => 'Koha::Item::Lists', value => { visibility => 'public' } } );
    my $list_id  = $list->id;
    my $list2_id = $list2->id;

    $t->delete_ok("/api/v1/item-lists/$list_id")->status_is(401);

    $t->delete_ok("//$ux:$px@/api/v1/item-lists/$list_id")->status_is(403);

    {
        my $m = Test::MockModule->new('Koha::Item::List')->mock( can_be_deleted_by => 0 );
        $t->delete_ok("//$u:$p@/api/v1/item-lists/$list_id")->status_is(403);
    }

    $t->delete_ok("//$u:$p@/api/v1/item-lists/$list_id")->status_is(204);

    is( Koha::Item::Lists->search( { id => $list_id } )->count(),  0 );
    is( Koha::Item::Lists->search( { id => $list2_id } )->count(), 1 );

    $t->delete_ok("//$u:$p@/api/v1/item-lists/$list2_id")->status_is(204);

    is( Koha::Item::Lists->search( { id => $list_id } )->count(),  0 );
    is( Koha::Item::Lists->search( { id => $list2_id } )->count(), 0 );

    $schema->storage->txn_rollback;
};

subtest 'list_items()' => sub {
    plan tests => 15;

    $schema->storage->txn_begin;

    Koha::Item::Lists->search()->delete();

    my ( $u,  $bn,  $p )  = get_privileged_user();
    my ( $ux, $bnx, $px ) = get_unprivileged_user();

    my $list    = $builder->build_object( { class => 'Koha::Item::Lists', value => { visibility => 'public' } } );
    my $list_id = $list->id;

    $t->get_ok("/api/v1/item-lists/$list_id/items")->status_is(401);

    $t->get_ok("//$ux:$px@/api/v1/item-lists/$list_id/items")->status_is(403);

    {
        my $m = Test::MockModule->new('Koha::Item::List')->mock( can_be_read_by => 0 );
        $t->get_ok("//$u:$p@/api/v1/item-lists/$list_id/items")->status_is(403);
    }

    $t->get_ok("//$u:$p@/api/v1/item-lists/$list_id/items")->status_is(200)->json_is( [] );

    my $item = $builder->build_object( { class => 'Koha::Items' } );

    Koha::Item::ListContent->new(
        {
            item_list_id => $list->id,
            itemnumber   => $item->itemnumber,
        }
    )->store();

    $t->get_ok("//$u:$p@/api/v1/item-lists/$list_id/items")->status_is(200)->json_is( [ $item->to_api() ] );

    Koha::Item::ListContents->search(
        {
            item_list_id => $list->id,
            itemnumber   => $item->itemnumber,
        }
    )->delete();

    $t->get_ok("//$u:$p@/api/v1/item-lists/$list_id/items")->status_is(200)->json_is( [] );

    $schema->storage->txn_rollback;
};

subtest 'add_items()' => sub {
    plan tests => 24;

    $schema->storage->txn_begin;

    Koha::Items->search()->delete();
    Koha::Item::Lists->search()->delete();

    my ( $u,  $bn,  $p )  = get_privileged_user();
    my ( $ux, $bnx, $px ) = get_unprivileged_user();

    my $list    = $builder->build_object( { class => 'Koha::Item::Lists', value => { visibility => 'public' } } );
    my $item1   = $builder->build_object( { class => 'Koha::Items' } );
    my $item2   = $builder->build_object( { class => 'Koha::Items' } );
    my $item3   = $builder->build_object( { class => 'Koha::Items' } );
    my $list_id = $list->id;

    $t->post_ok( "/api/v1/item-lists/$list_id/items" => json => { external_ids => [ $item1->barcode ] } )
        ->status_is(401);

    $t->post_ok( "//$ux:$px@/api/v1/item-lists/$list_id/items" => json => { item_id => [ $item1->barcode ] } )
        ->status_is(403);

    {
        my $m = Test::MockModule->new('Koha::Item::List')->mock( can_be_managed_by => 0 );
        $t->post_ok( "//$u:$p@/api/v1/item-lists/$list_id/items" => json => { external_ids => [ $item1->barcode ] } )
            ->status_is(403);
    }

    is( Koha::Item::ListContents->search( { item_list_id => $list_id } )->count(), 0 );

    $t->post_ok( "//$u:$p@/api/v1/item-lists/$list_id/items" => json => { external_ids => [ $item1->barcode ] } )
        ->status_is(201);

    is( Koha::Item::ListContents->search( { item_list_id => $list_id } )->count(), 1 );

    $t->post_ok( "//$u:$p@/api/v1/item-lists/$list_id/items" => json =>
            { item_ids => [ $item2->itemnumber ], external_ids => [ $item3->barcode ] } )->status_is(201);

    is( Koha::Item::ListContents->search( { item_list_id => $list_id } )->count(), 3 );

    $t->post_ok( "//$u:$p@/api/v1/item-lists/$list_id/items" => json =>
            { item_ids => [ $item2->itemnumber ], external_ids => [ $item2->barcode ] } )->status_is(201);

    $t->post_ok( "//$u:$p@/api/v1/item-lists/$list_id/items" => json => { item_ids => [9999] } )
        ->status_is(404)
        ->json_is(
        "/errors" => [
            {
                message => "Unrecognised itemnumbers: 9999",
                path    => "/item_ids"
            }
        ]
        );

    $t->post_ok( "//$u:$p@/api/v1/item-lists/$list_id/items" => json => { external_ids => ["9999"] } )
        ->status_is(404)
        ->json_is(
        "/errors" => [
            {
                message => "Unrecognised barcodes: 9999",
                path    => "/external_ids"
            }
        ]
        );

    $t->post_ok(
        "//$u:$p@/api/v1/item-lists/$list_id/items" => json => { item_ids => [9999], external_ids => ["9999"] } )
        ->status_is(404)
        ->json_is(
        "/errors" => [
            {
                message => "Unrecognised itemnumbers: 9999",
                path    => "/item_ids"
            },
            {
                message => "Unrecognised barcodes: 9999",
                path    => "/external_ids"
            }
        ]
        );

    $schema->storage->txn_rollback;
};

subtest 'remove_items()' => sub {
    plan tests => 17;

    $schema->storage->txn_begin;

    Koha::Items->search()->delete();
    Koha::Item::Lists->search()->delete();

    my ( $u,  $bn,  $p )  = get_privileged_user();
    my ( $ux, $bnx, $px ) = get_unprivileged_user();

    my $list     = $builder->build_object( { class => 'Koha::Item::Lists', value => { visibility => 'public' } } );
    my $item1    = $builder->build_object( { class => 'Koha::Items' } );
    my $item2    = $builder->build_object( { class => 'Koha::Items' } );
    my $item3    = $builder->build_object( { class => 'Koha::Items' } );
    my $list_id  = $list->id;
    my $item1_id = $item1->itemnumber;
    my $item2_id = $item2->itemnumber;
    my $item3_id = $item3->itemnumber;

    Koha::Item::ListContent->new(
        {
            item_list_id => $list->id,
            itemnumber   => $item1->itemnumber,
        }
    )->store();

    Koha::Item::ListContent->new(
        {
            item_list_id => $list->id,
            itemnumber   => $item2->itemnumber,
        }
    )->store();

    Koha::Item::ListContent->new(
        {
            item_list_id => $list->id,
            itemnumber   => $item3->itemnumber,
        }
    )->store();

    $t->delete_ok( "/api/v1/item-lists/$list_id/items" => json => { item_ids => [$item1_id] } )->status_is(401);

    $t->delete_ok( "//$ux:$px@/api/v1/item-lists/$list_id/items" => json => { item_ids => [$item1_id] } )
        ->status_is(403);

    {
        my $m = Test::MockModule->new('Koha::Item::List')->mock( can_be_managed_by => 0 );
        $t->delete_ok( "//$u:$p@/api/v1/item-lists/$list_id/items" => json => { item_ids => [$item1_id] } )
            ->status_is(403);
    }

    is(
        Koha::Item::ListContents->search( { item_list_id => $list_id, itemnumber => $item1->itemnumber } )->count(),
        1
    );

    $t->delete_ok( "//$u:$p@/api/v1/item-lists/$list_id/items" => json => { item_ids => [$item1_id] } )->status_is(204);

    is(
        Koha::Item::ListContents->search( { item_list_id => $list_id, itemnumber => $item1->itemnumber } )->count(),
        0
    );

    $t->delete_ok( "//$u:$p@/api/v1/item-lists/$list_id/items" => json => { item_ids => [$item1_id] } )->status_is(204);

    is(
        Koha::Item::ListContents->search( { item_list_id => $list_id, itemnumber => $item1->itemnumber } )->count(),
        0
    );
    is( Koha::Item::ListContents->search( { item_list_id => $list_id } )->count(), 2 );

    $t->delete_ok( "//$u:$p@/api/v1/item-lists/$list_id/items" => json => { item_ids => [ $item2_id, $item3_id ] } )
        ->status_is(204);

    is( Koha::Item::ListContents->search( { item_list_id => $list_id } )->count(), 0 );

    $schema->storage->txn_rollback;
};

subtest 'list_shares()' => sub {
    plan tests => 15;

    $schema->storage->txn_begin;

    my ( $u,  $bn,  $p )  = get_privileged_user();
    my ( $ux, $bnx, $px ) = get_unprivileged_user();

    my $list    = $builder->build_object( { class => 'Koha::Item::Lists', value => { visibility => 'public' } } );
    my $list_id = $list->id;

    $t->get_ok("/api/v1/item-lists/$list_id/shares")->status_is(401);

    $t->get_ok("//$ux:$px@/api/v1/item-lists/$list_id/shares")->status_is(403);

    {
        my $m = Test::MockModule->new('Koha::Item::List')->mock( can_be_updated_by => 0 );
        $t->get_ok("//$u:$p@/api/v1/item-lists/$list_id/shares")->status_is(403);
    }

    $t->get_ok("//$u:$p@/api/v1/item-lists/$list_id/shares")->status_is(200)->json_is( [] );

    my $share = Koha::Item::ListShare->new(
        {
            item_list_id   => $list->id,
            borrowernumber => $bnx,
            permission     => 'view'
        }
    )->store();
    $share->discard_changes();

    $t->get_ok("//$u:$p@/api/v1/item-lists/$list_id/shares")->status_is(200)->json_is( [ $share->to_api() ] );

    $share->delete();

    $t->get_ok("//$u:$p@/api/v1/item-lists/$list_id/shares")->status_is(200)->json_is( [] );

    $schema->storage->txn_rollback;
};

subtest 'add_share()' => sub {
    plan tests => 30;

    $schema->storage->txn_begin;

    Koha::Patrons->search()->delete();
    Koha::Item::Lists->search()->delete();

    my ( $u,  $bn,  $p )  = get_privileged_user();
    my ( $ux, $bnx, $px ) = get_unprivileged_user();

    my $owner = $builder->build_object( { class => 'Koha::Patrons', } );
    my $list  = $builder->build_object(
        { class => 'Koha::Item::Lists', value => { visibility => 'public', owner => $owner->borrowernumber } } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons', } );
    my $list_id = $list->id;

    $t->put_ok( "/api/v1/item-lists/$list_id/shares" => json => { patron_id => $patron->id, permission => 'view' } )
        ->status_is(401);

    $t->put_ok(
        "//$ux:$px@/api/v1/item-lists/$list_id/shares" => json => { patron_id => $patron->id, permission => 'view' } )
        ->status_is(403);

    {
        my $m = Test::MockModule->new('Koha::Item::List')->mock( can_be_updated_by => 0 );
        $t->put_ok(
            "//$u:$p@/api/v1/item-lists/$list_id/shares" => json => { patron_id => $patron->id, permission => 'view' } )
            ->status_is(403);
    }

    is( Koha::Item::ListShares->search( { item_list_id => $list_id } )->count(), 0 );

    $t->put_ok(
        "//$u:$p@/api/v1/item-lists/$list_id/shares" => json => { patron_id => $patron->id, permission => 'view' } )
        ->status_is(200);

    is( Koha::Item::ListShares->search( { item_list_id => $list_id } )->count(), 1 );
    is(
        Koha::Item::ListShares->search(
            { item_list_id => $list_id, borrowernumber => $patron->id, permission => 'view' }
        )->count(),
        1
    );
    is(
        Koha::Item::ListShares->search(
            { item_list_id => $list_id, borrowernumber => $patron->id, permission => 'edit' }
        )->count(),
        0
    );

    $t->put_ok(
        "//$u:$p@/api/v1/item-lists/$list_id/shares" => json => { patron_id => $patron->id, permission => 'edit' } )
        ->status_is(200);

    is( Koha::Item::ListShares->search( { item_list_id => $list_id } )->count(), 1 );
    is(
        Koha::Item::ListShares->search(
            { item_list_id => $list_id, borrowernumber => $patron->id, permission => 'view' }
        )->count(),
        0
    );
    is(
        Koha::Item::ListShares->search(
            { item_list_id => $list_id, borrowernumber => $patron->id, permission => 'edit' }
        )->count(),
        1
    );

    $t->put_ok(
        "//$u:$p@/api/v1/item-lists/$list_id/shares" => json => { patron_id => $patron->id, permission => 'view' } )
        ->status_is(200);

    is( Koha::Item::ListShares->search( { item_list_id => $list_id } )->count(), 1 );
    is(
        Koha::Item::ListShares->search(
            { item_list_id => $list_id, borrowernumber => $patron->id, permission => 'view' }
        )->count(),
        1
    );
    is(
        Koha::Item::ListShares->search(
            { item_list_id => $list_id, borrowernumber => $patron->id, permission => 'edit' }
        )->count(),
        0
    );

    $t->put_ok(
        "//$u:$p@/api/v1/item-lists/$list_id/shares" => json => { patron_id => $owner->id, permission => 'view' } )
        ->status_is(409);

    $t->put_ok(
        "//$u:$p@/api/v1/item-lists/$list_id/shares" => json => { patron_id => $patron->id, permission => 'delete' } )
        ->status_is(400);
    $t->put_ok( "//$u:$p@/api/v1/item-lists/$list_id/shares" => json => { patron_id => 9999, permission => 'view' } )
        ->status_is(404);
    $t->put_ok( "//$u:$p@/api/v1/item-lists/9999/shares" => json => { patron_id => $patron->id, permission => 'view' } )
        ->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'remove_share()' => sub {
    plan tests => 22;

    $schema->storage->txn_begin;

    Koha::Patrons->search()->delete();
    Koha::Item::Lists->search()->delete();

    my ( $u,  $bn,  $p )  = get_privileged_user();
    my ( $ux, $bnx, $px ) = get_unprivileged_user();

    my $list       = $builder->build_object( { class => 'Koha::Item::Lists', value => { visibility => 'public' } } );
    my $patron1    = $builder->build_object( { class => 'Koha::Patrons', } );
    my $patron2    = $builder->build_object( { class => 'Koha::Patrons', } );
    my $patron1_id = $patron1->id;
    my $patron2_id = $patron2->id;
    my $list_id    = $list->id;

    Koha::Item::ListShare->new(
        {
            item_list_id   => $list_id,
            borrowernumber => $patron1->id,
            permission     => 'view'
        }
    )->store();

    Koha::Item::ListShare->new(
        {
            item_list_id   => $list_id,
            borrowernumber => $patron2->id,
            permission     => 'edit'
        }
    )->store();

    $t->delete_ok("/api/v1/item-lists/$list_id/shares/$patron1_id")->status_is(401);

    $t->delete_ok("//$ux:$px@/api/v1/item-lists/$list_id/shares/$patron1_id")->status_is(403);

    {
        my $m = Test::MockModule->new('Koha::Item::List')->mock( can_be_updated_by => 0 );
        $t->delete_ok("//$u:$p@/api/v1/item-lists/$list_id/shares/$patron1_id")->status_is(403);
    }

    is( Koha::Item::ListShares->search( { item_list_id => $list_id } )->count(), 2 );

    $t->delete_ok("//$u:$p@/api/v1/item-lists/$list_id/shares/$patron1_id")->status_is(204);

    is( Koha::Item::ListShares->search( { item_list_id => $list_id } )->count(), 1 );
    is( Koha::Item::ListShares->search( { item_list_id => $list_id, borrowernumber => $patron1->id } )->count(), 0 );
    is( Koha::Item::ListShares->search( { item_list_id => $list_id, borrowernumber => $patron2->id } )->count(), 1 );

    $t->delete_ok("//$u:$p@/api/v1/item-lists/$list_id/shares/$patron2_id")->status_is(204);

    is( Koha::Item::ListShares->search( { item_list_id => $list_id } )->count(), 0 );

    $t->delete_ok("//$u:$p@/api/v1/item-lists/$list_id/shares/$patron1_id")->status_is(204);

    is( Koha::Item::ListShares->search( { item_list_id => $list_id } )->count(), 0 );

    $t->delete_ok("//$u:$p@/api/v1/item-lists/$list_id/shares/9999")->status_is(404);
    $t->delete_ok("//$u:$p@/api/v1/item-lists/9999/shares")->status_is(404);

    $schema->storage->txn_rollback;
};
