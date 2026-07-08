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
use Test::More tests => 4;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Items;
use Koha::Item::Lists;
use Koha::Item::ListContent;
use Koha::Item::ListShares;
use Koha::Libraries;
use Koha::Library::Groups;
use Koha::Patron;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'managing items' => sub {
    plan tests => 8;

    $schema->storage->txn_begin;

    my $list  = $builder->build_object( { class => 'Koha::Item::Lists' } );
    my $item1 = $builder->build_object( { class => 'Koha::Items' } );
    my $item2 = $builder->build_object( { class => 'Koha::Items' } );

    is( $list->items->count, 0 );

    $list->add_item( $item1->itemnumber );
    is( $list->items->count, 1 );

    $list->add_item( $item2->itemnumber );
    is( $list->items->count, 2 );

    $list->remove_item( $item1->itemnumber );
    is( $list->items->count, 1 );

    $list->add_item( $item2->itemnumber );
    is( $list->items->count, 1 );

    $list->remove_item( $item2->itemnumber );
    is( $list->items->count, 0 );

    $list->add_item( $item1->itemnumber );
    $list->add_item( $item2->itemnumber );
    is( $list->items->count, 2 );

    $list->remove_items( [ $item1->itemnumber, $item2->itemnumber ] );
    is( $list->items->count, 0 );

    $schema->storage->txn_rollback;
};

subtest 'managing shares' => sub {
    plan tests => 23;

    $schema->storage->txn_begin;

    my $list    = $builder->build_object( { class => 'Koha::Item::Lists' } );
    my $patron1 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron2 = $builder->build_object( { class => 'Koha::Patrons' } );

    is( $list->item_list_shares->count, 0 );

    $list->share( { borrowernumber => $patron1->borrowernumber, permission => 'view' } );
    is( $list->item_list_shares->count, 1 );
    ok( $list->is_shared_with( { borrowernumber  => $patron1->borrowernumber } ) );
    ok( $list->is_shared_with( { borrowernumber  => $patron1->borrowernumber, permission => 'view' } ) );
    ok( !$list->is_shared_with( { borrowernumber => $patron1->borrowernumber, permission => 'edit' } ) );
    ok( !$list->is_shared_with( { borrowernumber => $patron2->borrowernumber } ) );

    $list->share( { borrowernumber => $patron2->borrowernumber, permission => 'edit' } );
    is( $list->item_list_shares->count, 2 );
    ok( $list->is_shared_with( { borrowernumber => $patron1->borrowernumber, permission => 'view' } ) );
    ok( $list->is_shared_with( { borrowernumber => $patron2->borrowernumber } ) );
    ok( $list->is_shared_with( { borrowernumber => $patron2->borrowernumber, permission => 'edit' } ) );

    $list->share( { borrowernumber => $patron1->borrowernumber, permission => 'edit' } );
    $list->share( { borrowernumber => $patron2->borrowernumber, permission => 'view' } );
    is( $list->item_list_shares->count, 2 );
    ok( $list->is_shared_with( { borrowernumber  => $patron1->borrowernumber, permission => 'edit' } ) );
    ok( $list->is_shared_with( { borrowernumber  => $patron2->borrowernumber, permission => 'view' } ) );
    ok( !$list->is_shared_with( { borrowernumber => $patron1->borrowernumber, permission => 'view' } ) );
    ok( !$list->is_shared_with( { borrowernumber => $patron2->borrowernumber, permission => 'edit' } ) );

    $list->remove_share( $patron1->borrowernumber );
    is( $list->item_list_shares->count, 1 );
    ok( !$list->is_shared_with( { borrowernumber => $patron1->borrowernumber } ) );
    ok( $list->is_shared_with( { borrowernumber  => $patron2->borrowernumber, permission => 'view' } ) );

    $list->remove_share( $patron1->borrowernumber );
    is( $list->item_list_shares->count, 1 );
    ok( $list->is_shared_with( { borrowernumber => $patron2->borrowernumber } ) );

    $list->remove_share( $patron2->borrowernumber );
    is( $list->item_list_shares->count, 0 );
    ok( !$list->is_shared_with( { borrowernumber => $patron1->borrowernumber } ) );
    ok( !$list->is_shared_with( { borrowernumber => $patron2->borrowernumber } ) );

    $schema->storage->txn_rollback;
};

subtest 'permissions' => sub {
    plan tests => 105;

    $schema->storage->txn_begin;

    Koha::Item::Lists->new->delete();

    t::lib::Mocks::mock_userenv();

    my $library1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library2 = $builder->build_object( { class => 'Koha::Libraries' } );

    my $patron1 =
        $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $library1->branchcode } } );
    my $patron2 =
        $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $library2->branchcode } } );
    my $list = $builder->build_object(
        { class => 'Koha::Item::Lists', value => { visibility => 'private', owner => $patron1->borrowernumber } } );

    $patron2->set_permissions( {} );

    ok( $list->can_be_read_by($patron1) );
    ok( $list->can_be_updated_by($patron1) );
    ok( $list->can_be_deleted_by($patron1) );
    ok( $list->can_be_managed_by($patron1) );
    is( Koha::Item::Lists->get_readable_lists($patron1)->count,   1 );
    is( Koha::Item::Lists->get_manageable_lists($patron1)->count, 1 );

    ok( !$list->can_be_read_by($patron2) );
    ok( !$list->can_be_updated_by($patron2) );
    ok( !$list->can_be_deleted_by($patron2) );
    ok( !$list->can_be_managed_by($patron2) );
    is( Koha::Item::Lists->get_readable_lists($patron2)->count,   0 );
    is( Koha::Item::Lists->get_manageable_lists($patron2)->count, 0 );

    $list->share( { borrowernumber => $patron2->borrowernumber, permission => 'view' } );
    ok( $list->can_be_read_by($patron2) );
    ok( !$list->can_be_updated_by($patron2) );
    ok( !$list->can_be_deleted_by($patron2) );
    ok( !$list->can_be_managed_by($patron2) );
    is( Koha::Item::Lists->get_readable_lists($patron2)->count,   1 );
    is( Koha::Item::Lists->get_manageable_lists($patron2)->count, 0 );

    $list->share( { borrowernumber => $patron2->borrowernumber, permission => 'edit' } );
    ok( $list->can_be_read_by($patron2) );
    ok( $list->can_be_updated_by($patron2) );
    ok( $list->can_be_deleted_by($patron2) );
    ok( $list->can_be_managed_by($patron2) );
    is( Koha::Item::Lists->get_readable_lists($patron2)->count,   1 );
    is( Koha::Item::Lists->get_manageable_lists($patron2)->count, 1 );

    $list->remove_share( $patron2->borrowernumber );
    ok( !$list->can_be_read_by($patron2) );
    ok( !$list->can_be_updated_by($patron2) );
    ok( !$list->can_be_deleted_by($patron2) );
    ok( !$list->can_be_managed_by($patron2) );
    is( Koha::Item::Lists->get_readable_lists($patron2)->count,   0 );
    is( Koha::Item::Lists->get_manageable_lists($patron2)->count, 0 );

    $list->update( { visibility => 'public' } );
    ok( $list->can_be_read_by($patron2) );
    ok( !$list->can_be_updated_by($patron2) );
    ok( !$list->can_be_deleted_by($patron2) );
    ok( !$list->can_be_managed_by($patron2) );
    is( Koha::Item::Lists->get_readable_lists($patron2)->count,   1 );
    is( Koha::Item::Lists->get_manageable_lists($patron2)->count, 0 );

    $patron2->set_permissions( { item_lists => { edit_item_lists => 1 } } );
    ok( $list->can_be_read_by($patron2) );
    ok( $list->can_be_updated_by($patron2) );
    ok( !$list->can_be_deleted_by($patron2) );
    ok( !$list->can_be_managed_by($patron2) );
    is( Koha::Item::Lists->get_readable_lists($patron2)->count,   1 );
    is( Koha::Item::Lists->get_manageable_lists($patron2)->count, 0 );

    $patron2->set_permissions( { item_lists => { delete_item_lists => 1 } } );
    ok( $list->can_be_read_by($patron2) );
    ok( !$list->can_be_updated_by($patron2) );
    ok( $list->can_be_deleted_by($patron2) );
    ok( !$list->can_be_managed_by($patron2) );
    is( Koha::Item::Lists->get_readable_lists($patron2)->count,   1 );
    is( Koha::Item::Lists->get_manageable_lists($patron2)->count, 0 );

    $patron2->set_permissions( { item_lists => { manage_item_list_contents => 1 } } );
    ok( $list->can_be_read_by($patron2) );
    ok( !$list->can_be_updated_by($patron2) );
    ok( !$list->can_be_deleted_by($patron2) );
    ok( $list->can_be_managed_by($patron2) );
    is( Koha::Item::Lists->get_readable_lists($patron2)->count,   1 );
    is( Koha::Item::Lists->get_manageable_lists($patron2)->count, 1 );

    $patron2->set_permissions(
        { item_lists => { edit_item_lists => 1, delete_item_lists => 1, manage_item_list_contents => 1 } } );
    ok( $list->can_be_read_by($patron2) );
    ok( $list->can_be_updated_by($patron2) );
    ok( $list->can_be_deleted_by($patron2) );
    ok( $list->can_be_managed_by($patron2) );
    is( Koha::Item::Lists->get_readable_lists($patron2)->count,   1 );
    is( Koha::Item::Lists->get_manageable_lists($patron2)->count, 1 );

    $patron2->set_permissions( {} );
    $list->update( { visibility => 'group' } );
    ok( !$list->can_be_read_by($patron2) );
    ok( !$list->can_be_updated_by($patron2) );
    ok( !$list->can_be_deleted_by($patron2) );
    ok( !$list->can_be_managed_by($patron2) );
    is( Koha::Item::Lists->get_readable_lists($patron2)->count,   0 );
    is( Koha::Item::Lists->get_manageable_lists($patron2)->count, 0 );

    # Need extra permissions for non-read actions
    $patron2->update( { branchcode => $library1->branchcode } );

    # We have to clear the cache on libraries_where_can_see_things for these tests
    $patron2 = Koha::Patrons->find( $patron2->borrowernumber );
    ok( $list->can_be_read_by($patron2) );
    ok( !$list->can_be_updated_by($patron2) );
    ok( !$list->can_be_deleted_by($patron2) );
    ok( !$list->can_be_managed_by($patron2) );
    is( Koha::Item::Lists->get_readable_lists($patron2)->count,   1 );
    is( Koha::Item::Lists->get_manageable_lists($patron2)->count, 0 );

    $patron2->set_permissions( { item_lists => { edit_item_lists => 1, manage_item_list_contents => 1 } } );
    ok( $list->can_be_read_by($patron2) );
    ok( $list->can_be_updated_by($patron2) );
    ok( !$list->can_be_deleted_by($patron2) );
    ok( $list->can_be_managed_by($patron2) );
    is( Koha::Item::Lists->get_readable_lists($patron2)->count,   1 );
    is( Koha::Item::Lists->get_manageable_lists($patron2)->count, 1 );

    $patron2->set_permissions();
    $patron2->update( { branchcode => $library2->branchcode } );
    $patron2 = Koha::Patrons->find( $patron2->borrowernumber );
    ok( !$list->can_be_read_by($patron2) );
    is( Koha::Item::Lists->get_readable_lists($patron2)->count,   0 );
    is( Koha::Item::Lists->get_manageable_lists($patron2)->count, 0 );

    my $parent_group = $builder->build_object( { class => 'Koha::Library::Groups' } );
    my $child1_group = $builder->build_object(
        {
            class => 'Koha::Library::Groups',
            value => { branchcode => $library1->branchcode, parent_id => $parent_group->id }
        }
    );
    $patron2 = Koha::Patrons->find( $patron2->borrowernumber );
    ok( !$list->can_be_read_by($patron2) );
    is( Koha::Item::Lists->get_readable_lists($patron2)->count,   0 );
    is( Koha::Item::Lists->get_manageable_lists($patron2)->count, 0 );

    $list->share( { borrowernumber => $patron2->borrowernumber, permission => 'edit' } );
    ok( $list->can_be_read_by($patron2) );
    ok( $list->can_be_managed_by($patron2) );
    is( Koha::Item::Lists->get_readable_lists($patron2)->count,   1 );
    is( Koha::Item::Lists->get_manageable_lists($patron2)->count, 1 );

    $list->remove_share( $patron2->borrowernumber );
    my $child2_group = $builder->build_object(
        {
            class => 'Koha::Library::Groups',
            value => { branchcode => $library2->branchcode, parent_id => $parent_group->id }
        }
    );

    $patron2 = Koha::Patrons->find( $patron2->borrowernumber );
    ok( $list->can_be_read_by($patron2) );
    is( Koha::Item::Lists->get_readable_lists($patron2)->count,   1 );
    is( Koha::Item::Lists->get_manageable_lists($patron2)->count, 0 );

    $list->update( { visibility => 'private' } );
    ok( !$list->can_be_read_by($patron2) );
    ok( !$list->can_be_updated_by($patron2) );
    ok( !$list->can_be_deleted_by($patron2) );
    ok( !$list->can_be_managed_by($patron2) );
    is( Koha::Item::Lists->get_readable_lists($patron2)->count,   0 );
    is( Koha::Item::Lists->get_manageable_lists($patron2)->count, 0 );

    $list->update( { owner => undef } );
    ok( $list->can_be_read_by($patron1) );
    ok( $list->can_be_read_by($patron2) );
    ok( $list->can_be_managed_by($patron1) );
    ok( $list->can_be_managed_by($patron2) );
    is( Koha::Item::Lists->get_readable_lists($patron1)->count,   1 );
    is( Koha::Item::Lists->get_manageable_lists($patron1)->count, 1 );
    is( Koha::Item::Lists->get_readable_lists($patron2)->count,   1 );
    is( Koha::Item::Lists->get_manageable_lists($patron2)->count, 1 );

    $schema->storage->txn_rollback;
};
