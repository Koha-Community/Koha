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
use Test::MockModule;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

my $t = Test::Mojo->new('Koha::REST::V1');

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**4 }    # 'borrowers' flag == 4
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    $t->get_ok( "//$userid:$password@/api/v1/patrons/" . $patron->id . '/hold_groups' )
        ->status_is( 200, 'REST3.2.2' )
        ->json_is( [] );

    my $hold_group_1 = $builder->build_object(
        {
            class => 'Koha::HoldGroups',
            value => { borrowernumber => $patron->id }
        }
    );
    my $hold_1 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { borrowernumber => $patron->id, hold_group_id => $hold_group_1->hold_group_id }
        }
    );
    my $hold_2 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { borrowernumber => $patron->id, hold_group_id => $hold_group_1->hold_group_id }
        }
    );
    my $hold_3 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { borrowernumber => $patron->id, hold_group_id => $hold_group_1->hold_group_id }
        }
    );

    $t->get_ok( "//$userid:$password@/api/v1/patrons/" . $patron->id . '/hold_groups' => { 'x-koha-embed' => 'holds' } )
        ->status_is( 200, 'REST3.2.2' )
        ->json_has( "/0/holds", "holds object correctly embedded" );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 15;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**6 }    # reserveforothers flag = 6
        }
    );
    my $other_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**6 }    # reserveforothers flag = 6
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    my $hold_1 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { borrowernumber => $patron->id, hold_group_id => undef, found => undef }
        }
    );
    my $hold_2 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { borrowernumber => $patron->id, hold_group_id => undef, found => undef }
        }
    );
    my $hold_3 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { borrowernumber => $other_patron->id, hold_group_id => undef, found => 'W' }
        }
    );

    $t->post_ok(
        "//$userid:$password@/api/v1/patrons/" . $patron->id . "/hold_groups" => json => { hold_ids => [333] } )
        ->status_is( 400, 'REST3.2.1' )
        ->json_is(
        { error => 'One or more holds do not exist: 333', error_code => "HoldDoesNotExist", hold_ids => [333] } );

    $t->post_ok( "//$userid:$password@/api/v1/patrons/"
            . $other_patron->id
            . "/hold_groups" => json => { hold_ids => [ $hold_3->reserve_id ] } )
        ->status_is( 400, 'REST3.2.1' )
        ->json_is(
        {
            error      => 'One or more holds have already been found: ' . $hold_3->item->barcode,
            error_code => "HoldHasAlreadyBeenFound", barcodes => [ $hold_3->item->barcode ]
        }
        );

    $t->post_ok( "//$userid:$password@/api/v1/patrons/"
            . $patron->id
            . "/hold_groups" => json => { hold_ids => [ $hold_3->reserve_id ] } )
        ->status_is( 400, 'REST3.2.1' )
        ->json_is(
        {
            error      => 'One or more holds do not belong to patron: ' . $hold_3->reserve_id,
            error_code => "HoldDoesNotBelongToPatron", hold_ids => [ $hold_3->reserve_id ]
        }
        );

    $t->post_ok( "//$userid:$password@/api/v1/patrons/"
            . $patron->id
            . "/hold_groups" => json => { hold_ids => [ $hold_1->reserve_id, $hold_2->reserve_id ] } )
        ->status_is( 201, 'REST3.2.1' )
        ->json_has( "/holds", "holds object correctly embedded" );

    $t->post_ok( "//$userid:$password@/api/v1/patrons/"
            . $patron->id
            . "/hold_groups" => json => { hold_ids => [ $hold_1->reserve_id, $hold_2->reserve_id ] } )
        ->status_is( 400, 'REST3.2.1' )
        ->json_is(
        {
                  error => "One or more holds already belong to a hold group: "
                . $hold_1->reserve_id . ", "
                . $hold_2->reserve_id,
            error_code => "HoldAlreadyBelongsToHoldGroup",
            hold_ids   => [ $hold_1->reserve_id, $hold_2->reserve_id ]
        }
        );

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {
    plan tests => 8;

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
            value => { flags => 4 }
        }
    );
    $unauthorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $unauthorized_patron->userid;

    my $hold_1 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { borrowernumber => $authorized_patron->id, hold_group_id => undef, found => undef }
        }
    );
    my $hold_2 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { borrowernumber => $authorized_patron->id, hold_group_id => undef, found => undef }
        }
    );

    my $hold_3 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { borrowernumber => $unauthorized_patron->borrowernumber, hold_group_id => undef, found => undef }
        }
    );
    my $hold_4 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { borrowernumber => $unauthorized_patron->borrowernumber, hold_group_id => undef, found => undef }
        }
    );

    my $unauth_hold_group = $unauthorized_patron->create_hold_group( [ $hold_3->reserve_id, $hold_4->reserve_id ] );
    my $hold_group        = $authorized_patron->create_hold_group( [ $hold_1->reserve_id, $hold_2->reserve_id ] );

    # Unauthorized attempt to delete
    $t->delete_ok( "//$unauth_userid:$password@/api/v1/patrons/"
            . $unauthorized_patron->borrowernumber
            . "/hold_groups/"
            . $unauth_hold_group->hold_group_id )->status_is(403);

    # Attempt to delete a hold group of another patron
    $t->delete_ok( "//$auth_userid:$password@/api/v1/patrons/"
            . $authorized_patron->borrowernumber
            . "/hold_groups/"
            . $unauth_hold_group->hold_group_id )->status_is(404);

    # Successful deletion
    $t->delete_ok( "//$auth_userid:$password@/api/v1/patrons/"
            . $authorized_patron->borrowernumber
            . "/hold_groups/"
            . $hold_group->hold_group_id )->status_is( 204, 'REST3.2.4' )->content_is( '', 'REST3.3.4' );

    my $nonexistent_hold = Koha::HoldGroups->find( $hold_group->hold_group_id );
    is( $nonexistent_hold, undef, 'The hold group does not exist after deletion' );

    $schema->storage->txn_rollback;
};
