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

use Test::More tests => 19;
use Test::NoWarnings;
use Test::MockModule;
use Test::Mojo;
use t::lib::TestBuilder;
use t::lib::Mocks;

use DateTime;
use JSON       qw( from_json );
use Mojo::JSON qw(encode_json);

use C4::Context;
use Koha::Patrons;
use C4::Reserves qw( AddReserve CanItemBeReserved CanBookBeReserved );
use C4::Items;

use Koha::ActionLogs;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Biblios;
use Koha::Biblioitems;
use Koha::Items;
use Koha::CirculationRules;
use Koha::Old::Holds;
use Koha::Patron::Debarments qw(AddDebarment);

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

$schema->storage->txn_begin;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

my $categorycode = $builder->build( { source => 'Category' } )->{categorycode};
my $branchcode   = $builder->build( { source => 'Branch' } )->{branchcode};
my $branchcode2  = $builder->build( { source => 'Branch' } )->{branchcode};
my $itemtype     = $builder->build( { source => 'Itemtype' } )->{itemtype};

# Generic password for everyone
my $password = 'thePassword123';

# User without any permissions
my $nopermission = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            branchcode   => $branchcode,
            categorycode => $categorycode,
            flags        => 0
        }
    }
);
$nopermission->set_password( { password => $password, skip_validation => 1 } );
my $nopermission_userid = $nopermission->userid;

my $patron_1 = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            categorycode => $categorycode,
            branchcode   => $branchcode,
            surname      => 'Test Surname',
            flags        => 80,               #borrowers and reserveforothers flags
        }
    }
);
$patron_1->set_password( { password => $password, skip_validation => 1 } );
my $userid_1 = $patron_1->userid;

my $patron_2 = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            categorycode => $categorycode,
            branchcode   => $branchcode,
            surname      => 'Test Surname 2',
            flags        => 16,                 # borrowers flag
        }
    }
);
$patron_2->set_password( { password => $password, skip_validation => 1 } );
my $userid_2 = $patron_2->userid;

my $patron_3 = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            categorycode => $categorycode,
            branchcode   => $branchcode,
            surname      => 'Test Surname 3',
            flags        => 64,                 # reserveforothers flag
        }
    }
);
$patron_3->set_password( { password => $password, skip_validation => 1 } );
my $userid_3 = $patron_3->userid;

my $biblio_1 = $builder->build_sample_biblio;
my $item_1   = $builder->build_sample_item( { biblionumber => $biblio_1->biblionumber, itype => $itemtype } );

my $biblio_2 = $builder->build_sample_biblio;
my $item_2   = $builder->build_sample_item( { biblionumber => $biblio_2->biblionumber, itype => $itemtype } );

my $dbh = C4::Context->dbh;
$dbh->do('DELETE FROM reserves');
Koha::CirculationRules->search()->delete();
Koha::CirculationRules->set_rules(
    {
        categorycode => undef,
        branchcode   => undef,
        itemtype     => undef,
        rules        => {
            reservesallowed  => 1,
            holds_per_record => 99
        }
    }
);

my $reserve_id = C4::Reserves::AddReserve(
    {
        branchcode     => $branchcode,
        borrowernumber => $patron_1->borrowernumber,
        biblionumber   => $biblio_1->biblionumber,
        priority       => 1,
        itemnumber     => $item_1->itemnumber,
    }
);

# Add another reserve to be able to change first reserve's rank
my $reserve_id2 = C4::Reserves::AddReserve(
    {
        branchcode     => $branchcode,
        borrowernumber => $patron_2->borrowernumber,
        biblionumber   => $biblio_1->biblionumber,
        priority       => 2,
        itemnumber     => $item_1->itemnumber,
    }
);

my $suspended_until = DateTime->now->add( days => 10 )->truncate( to => 'day' );
my $expiration_date = DateTime->now->add( days => 10 )->truncate( to => 'day' );

my $post_data = {
    patron_id         => $patron_1->borrowernumber,
    biblio_id         => $biblio_1->biblionumber,
    item_id           => $item_1->itemnumber,
    pickup_library_id => $branchcode,
    expiration_date   => output_pref( { dt => $expiration_date, dateformat => 'iso', dateonly => 1 } ),
};
my $patch_data = {
    priority        => 2,
    suspended_until => output_pref( { dt => $suspended_until, dateformat => 'rfc3339' } ),
};

subtest "Test endpoints without authentication" => sub {
    plan tests => 8;
    $t->get_ok('/api/v1/holds')->status_is(401);
    $t->post_ok('/api/v1/holds')->status_is(401);
    $t->patch_ok('/api/v1/holds/0')->status_is(401);
    $t->delete_ok('/api/v1/holds/0')->status_is(401);
};

subtest "Test endpoints without permission" => sub {

    plan tests => 10;

    $t->get_ok(
        "//$nopermission_userid:$password@/api/v1/holds?patron_id=" . $patron_1->borrowernumber )    # no permission
        ->status_is(403);

    $t->get_ok( "//$userid_2:$password@/api/v1/holds?patron_id=" . $patron_1->borrowernumber )       # no permission
        ->status_is(403);

    $t->post_ok( "//$nopermission_userid:$password@/api/v1/holds" => json => $post_data )->status_is(403);

    $t->patch_ok( "//$nopermission_userid:$password@/api/v1/holds/0" => json => $patch_data )->status_is(403);

    $t->delete_ok("//$nopermission_userid:$password@/api/v1/holds/0")->status_is(403);
};

subtest "Test endpoints with permission" => sub {

    plan tests => 45;

    # Prevent warning 'No reserves HOLD_CANCELLATION letter transported by email'
    my $mock_letters = Test::MockModule->new('C4::Letters');
    $mock_letters->mock( 'GetPreparedLetter', sub { return } );

    $t->get_ok("//$userid_1:$password@/api/v1/holds")->status_is(200)->json_has('/0')->json_has('/1')->json_hasnt('/2');

    $t->get_ok("//$userid_1:$password@/api/v1/holds?priority=2")->status_is(200)
        ->json_is( '/0/patron_id', $patron_2->borrowernumber )->json_hasnt('/1');

    $t->delete_ok("//$userid_3:$password@/api/v1/holds/$reserve_id")->status_is( 204, 'REST3.2.4' )
        ->content_is( '', 'REST3.3.4' );

    $t->patch_ok( "//$userid_3:$password@/api/v1/holds/$reserve_id" => json => $patch_data )->status_is(404)
        ->json_has('/error');

    $t->delete_ok("//$userid_3:$password@/api/v1/holds/$reserve_id")->status_is(404)->json_has('/error');

    $t->get_ok( "//$userid_3:$password@/api/v1/holds?patron_id=" . $patron_1->borrowernumber )->status_is(200)
        ->json_is( [] );

    my $inexisting_borrowernumber = $patron_2->borrowernumber * 2;
    $t->get_ok("//$userid_1:$password@/api/v1/holds?patron_id=$inexisting_borrowernumber")->status_is(200)
        ->json_is( [] );

    $t->delete_ok( "//$userid_3:$password@/api/v1/holds/$reserve_id2" => json => "Cancellation reason" )
        ->status_is( 204, 'REST3.2.4' )->content_is( '', 'REST3.3.4' );

    # Make sure pickup location checks doesn't get in the middle
    my $mock_biblio = Test::MockModule->new('Koha::Biblio');
    $mock_biblio->mock( 'pickup_locations', sub { return Koha::Libraries->search; } );
    my $mock_item = Test::MockModule->new('Koha::Item');
    $mock_item->mock( 'pickup_locations', sub { return Koha::Libraries->search } );

    $t->post_ok( "//$userid_3:$password@/api/v1/holds" => json => $post_data )->status_is(201)->json_has('/hold_id')
        ->header_is( 'Location' => '/api/v1/holds/' . $t->tx->res->json->{hold_id}, "REST3.4.1" );

    # Get id from response
    $reserve_id = $t->tx->res->json->{hold_id};

    $t->get_ok( "//$userid_1:$password@/api/v1/holds?patron_id=" . $patron_1->borrowernumber )->status_is(200)
        ->json_is( '/0/hold_id',         $reserve_id )
        ->json_is( '/0/expiration_date', output_pref( { dt => $expiration_date, dateformat => 'iso', dateonly => 1 } ) )
        ->json_is( '/0/pickup_library_id', $branchcode );

    $t->post_ok( "//$userid_3:$password@/api/v1/holds" => json => $post_data )->status_is(403)
        ->json_like( '/error', qr/itemAlreadyOnHold/ );

    $post_data->{biblio_id} = $biblio_2->biblionumber;
    $post_data->{item_id}   = $item_2->itemnumber;

    $t->post_ok( "//$userid_3:$password@/api/v1/holds" => json => $post_data )->status_is(403)
        ->json_like( '/error', qr/Hold cannot be placed. Reason: tooManyReserves/ );

    my $to_delete_patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $deleted_patron_id = $to_delete_patron->borrowernumber;
    $to_delete_patron->delete;

    my $tmp_patron_id = $post_data->{patron_id};
    $post_data->{patron_id} = $deleted_patron_id;
    $t->post_ok( "//$userid_3:$password@/api/v1/holds" => json => $post_data )->status_is(400)
        ->json_is( { error => 'patron_id not found' } );

    # Restore the original patron_id as it is expected by the next subtest
    # FIXME: this tests need to be rewritten from scratch
    $post_data->{patron_id} = $tmp_patron_id;
};

subtest 'Reserves with itemtype' => sub {
    plan tests => 10;

    my $post_data = {
        patron_id         => int( $patron_1->borrowernumber ),
        biblio_id         => int( $biblio_1->biblionumber ),
        pickup_library_id => $branchcode,
        item_type         => $itemtype,
    };

    $t->delete_ok("//$userid_3:$password@/api/v1/holds/$reserve_id")->status_is( 204, 'REST3.2.4' )
        ->content_is( '', 'REST3.3.4' );

    # Make sure pickup location checks doesn't get in the middle
    my $mock_biblio = Test::MockModule->new('Koha::Biblio');
    $mock_biblio->mock( 'pickup_locations', sub { return Koha::Libraries->search; } );
    my $mock_item = Test::MockModule->new('Koha::Item');
    $mock_item->mock( 'pickup_locations', sub { return Koha::Libraries->search } );

    $t->post_ok( "//$userid_3:$password@/api/v1/holds" => json => $post_data )->status_is(201)->json_has('/hold_id');

    $reserve_id = $t->tx->res->json->{hold_id};

    $t->get_ok( "//$userid_1:$password@/api/v1/holds?patron_id=" . $patron_1->borrowernumber )->status_is(200)
        ->json_is( '/0/hold_id', $reserve_id )->json_is( '/0/item_type', $itemtype );
};

subtest 'test AllowHoldDateInFuture' => sub {

    plan tests => 6;

    $dbh->do('DELETE FROM reserves');

    my $future_hold_date = DateTime->now->add( days => 10 )->truncate( to => 'day' );

    my $post_data = {
        patron_id         => $patron_1->borrowernumber,
        biblio_id         => $biblio_1->biblionumber,
        item_id           => $item_1->itemnumber,
        pickup_library_id => $branchcode,
        expiration_date   => output_pref( { dt => $expiration_date,  dateformat => 'iso', dateonly => 1 } ),
        hold_date         => output_pref( { dt => $future_hold_date, dateformat => 'iso', dateonly => 1 } ),
    };

    t::lib::Mocks::mock_preference( 'AllowHoldDateInFuture', 0 );

    $t->post_ok( "//$userid_3:$password@/api/v1/holds" => json => $post_data )->status_is(400)->json_has('/error');

    t::lib::Mocks::mock_preference( 'AllowHoldDateInFuture', 1 );

    # Make sure pickup location checks doesn't get in the middle
    my $mock_biblio = Test::MockModule->new('Koha::Biblio');
    $mock_biblio->mock( 'pickup_locations', sub { return Koha::Libraries->search; } );
    my $mock_item = Test::MockModule->new('Koha::Item');
    $mock_item->mock( 'pickup_locations', sub { return Koha::Libraries->search } );

    $t->post_ok( "//$userid_3:$password@/api/v1/holds" => json => $post_data )->status_is(201)
        ->json_is( '/hold_date', output_pref( { dt => $future_hold_date, dateformat => 'iso', dateonly => 1 } ) );
};

$schema->storage->txn_rollback;

subtest 'x-koha-override and AllowHoldPolicyOverride tests' => sub {

    plan tests => 18;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 1 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    $patron->discard_changes;
    my $userid = $patron->userid;

    my $renegade_library = $builder->build_object( { class => 'Koha::Libraries' } );

    t::lib::Mocks::mock_preference( 'AllowHoldPolicyOverride', 0 );

    # Make sure pickup location checks doesn't get in the middle
    my $mock_biblio = Test::MockModule->new('Koha::Biblio');
    $mock_biblio->mock(
        'pickup_locations',
        sub { return Koha::Libraries->search( { branchcode => { '!=' => $renegade_library->branchcode } } ); }
    );
    my $mock_item = Test::MockModule->new('Koha::Item');
    $mock_item->mock(
        'pickup_locations',
        sub { return Koha::Libraries->search( { branchcode => { '!=' => $renegade_library->branchcode } } ) }
    );

    my $can_item_be_reserved_result;
    my $mock_reserves = Test::MockModule->new('C4::Reserves');
    $mock_reserves->mock(
        'CanItemBeReserved',
        sub {
            return $can_item_be_reserved_result;
        }
    );

    my $item = $builder->build_sample_item;

    my $post_data = {
        item_id           => $item->id,
        biblio_id         => $item->biblionumber,
        patron_id         => $patron->id,
        pickup_library_id => $patron->branchcode,
    };

    $can_item_be_reserved_result = { status => 'ageRestricted' };

    $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $post_data )->status_is(403)
        ->json_is( '/error' => "Hold cannot be placed. Reason: ageRestricted" );

    # x-koha-override doesn't override if AllowHoldPolicyOverride not set
    $t->post_ok( "//$userid:$password@/api/v1/holds" => { 'x-koha-override' => 'any' } => json => $post_data )
        ->status_is(403);

    t::lib::Mocks::mock_preference( 'AllowHoldPolicyOverride', 1 );

    $can_item_be_reserved_result = { status => 'pickupNotInHoldGroup' };

    $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $post_data )->status_is(403)
        ->json_is( '/error' => "Hold cannot be placed. Reason: pickupNotInHoldGroup" );

    # x-koha-override overrides the status
    $t->post_ok( "//$userid:$password@/api/v1/holds" => { 'x-koha-override' => 'any' } => json => $post_data )
        ->status_is(201);

    $can_item_be_reserved_result = { status => 'OK' };

    # x-koha-override works when status not need override
    $t->post_ok( "//$userid:$password@/api/v1/holds" => { 'x-koha-override' => 'any' } => json => $post_data )
        ->status_is(201);

    # Test pickup locations can be overridden
    $post_data->{pickup_library_id} = $renegade_library->branchcode;

    $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $post_data )->status_is(400);

    $t->post_ok( "//$userid:$password@/api/v1/holds" => { 'x-koha-override' => 'any' } => json => $post_data )
        ->status_is(201);

    t::lib::Mocks::mock_preference( 'AllowHoldPolicyOverride', 0 );

    $t->post_ok( "//$userid:$password@/api/v1/holds" => { 'x-koha-override' => 'any' } => json => $post_data )
        ->status_is(400);

    $schema->storage->txn_rollback;
};

subtest 'suspend and resume tests' => sub {

    plan tests => 24;

    $schema->storage->txn_begin;

    my $password = 'AbcdEFG123';

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { userid => 'tomasito', flags => 0 } } );
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $patron->borrowernumber,
                module_bit     => 6,
                code           => 'place_holds',
            },
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    # Disable logging
    t::lib::Mocks::mock_preference( 'HoldsLog',      0 );
    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

    my $hold = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { suspend => 0, suspend_until => undef, waitingdate => undef, found => undef }
        }
    );

    ok( !$hold->is_suspended, 'Hold is not suspended' );
    $t->post_ok( "//$userid:$password@/api/v1/holds/" . $hold->id . "/suspension" )
        ->status_is( 201, 'Hold suspension created' );

    $hold->discard_changes;    # refresh object

    ok( $hold->is_suspended, 'Hold is suspended' );
    $t->json_is( '/end_date', undef, 'Hold suspension has no end date' );

    my $end_date = output_pref(
        {
            dt         => dt_from_string(undef),
            dateformat => 'iso',
            dateonly   => 1
        }
    );

    $t->post_ok(
        "//$userid:$password@/api/v1/holds/" . $hold->id . "/suspension" => json => { end_date => $end_date } );

    $hold->discard_changes;    # refresh object

    ok( $hold->is_suspended, 'Hold is suspended' );
    $t->json_is(
        '/end_date',
        output_pref(
            {
                dt         => dt_from_string( $hold->suspend_until ),
                dateformat => 'iso',
                dateonly   => 1
            }
        ),
        'Hold suspension has correct end date'
    );

    $t->delete_ok( "//$userid:$password@/api/v1/holds/" . $hold->id . "/suspension" )->status_is( 204, 'REST3.2.4' )
        ->content_is( '', 'REST3.3.4' );

    # Pass a an expiration date for the suspension
    my $date = dt_from_string()->add( days => 5 );
    $t->post_ok( "//$userid:$password@/api/v1/holds/"
            . $hold->id
            . "/suspension" => json =>
            { end_date => output_pref( { dt => $date, dateformat => 'iso', dateonly => 1 } ) } )
        ->status_is( 201, 'Hold suspension created' )->json_is(
        '/end_date',
        output_pref( { dt => $date, dateformat => 'iso', dateonly => 1 } )
    )->header_is( Location => "/api/v1/holds/" . $hold->id . "/suspension", 'The Location header is set' );

    $t->delete_ok( "//$userid:$password@/api/v1/holds/" . $hold->id . "/suspension" )->status_is( 204, 'REST3.2.4' )
        ->content_is( '', 'REST3.3.4' );

    $hold->set_waiting->discard_changes;

    $t->post_ok( "//$userid:$password@/api/v1/holds/" . $hold->id . "/suspension" )
        ->status_is( 400, 'Cannot suspend waiting hold' )
        ->json_is( '/error', 'Found hold cannot be suspended. Status=W' );

    $hold->set_transfer->discard_changes;

    $t->post_ok( "//$userid:$password@/api/v1/holds/" . $hold->id . "/suspension" )
        ->status_is( 400, 'Cannot suspend hold on transfer' )
        ->json_is( '/error', 'Found hold cannot be suspended. Status=T' );

    $schema->storage->txn_rollback;
};

subtest 'suspend bulk tests' => sub {

    plan tests => 16;

    $schema->storage->txn_begin;

    my $password = 'AbcdEFG123';

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { userid => 'tomasito', flags => 0 } } );
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $patron->borrowernumber,
                module_bit     => 6,
                code           => 'place_holds',
            },
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    # Disable logging
    t::lib::Mocks::mock_preference( 'HoldsLog',      0 );
    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

    my $hold = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { suspend => 0, suspend_until => undef, waitingdate => undef, found => undef }
        }
    );

    my $hold_2 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { suspend => 0, suspend_until => undef, waitingdate => undef, found => undef }
        }
    );

    ok( !$hold->is_suspended,   'Hold is not suspended' );
    ok( !$hold_2->is_suspended, 'Hold is not suspended' );

    $t->post_ok(
        "//$userid:$password@/api/v1/holds/suspension_bulk" => json => { hold_ids => [ $hold->id, $hold_2->id ] } )
        ->status_is( 201, 'Hold bulk suspension created' );

    $hold->discard_changes;
    $hold_2->discard_changes;

    ok( $hold->is_suspended,   'Hold is suspended' );
    ok( $hold_2->is_suspended, 'Hold is suspended' );

    $hold->resume;
    $hold_2->resume;

    ok( !$hold->is_suspended,   'Hold is not suspended' );
    ok( !$hold_2->is_suspended, 'Hold is not suspended' );

    $t->post_ok( "//$userid:$password@/api/v1/holds/suspension_bulk" => json =>
            { end_date => "2024-07-30", hold_ids => [ $hold->id, $hold_2->id ] } )
        ->status_is( 201, 'Hold bulk suspension created' )
        ->json_is( { end_date => "2024-07-30", hold_ids => [ $hold->id, $hold_2->id ] } );

    $hold->discard_changes;
    $hold_2->discard_changes;

    $hold_2->delete;

    $hold->resume;
    ok( !$hold->is_suspended, 'Hold is not suspended' );

    $t->post_ok( "//$userid:$password@/api/v1/holds/suspension_bulk" => json => { hold_ids => [ $hold_2->id ] } )
        ->status_is( 404, 'Hold bulk suspension failed. Hold not found' );
    ok( !$hold->is_suspended, 'Hold is not suspended. Bulk suspension failed' );

    $hold->discard_changes;

    ok( !$hold->is_suspended, 'Hold is not suspended. Bulk suspension failed' );

    $schema->storage->txn_rollback;
};

subtest 'PUT /holds/{hold_id}/priority tests' => sub {

    plan tests => 14;

    $schema->storage->txn_begin;

    my $password = 'AbcdEFG123';

    my $library   = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron_np = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    $patron_np->set_password( { password => $password, skip_validation => 1 } );
    my $userid_np = $patron_np->userid;

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $patron->borrowernumber,
                module_bit     => 6,
                code           => 'modify_holds_priority',
            },
        }
    );

    # Disable logging
    t::lib::Mocks::mock_preference( 'HoldsLog',      0 );
    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

    my $biblio   = $builder->build_sample_biblio;
    my $patron_1 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode }
        }
    );
    my $patron_2 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode }
        }
    );
    my $patron_3 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode }
        }
    );

    my $hold_1 = Koha::Holds->find(
        AddReserve(
            {
                branchcode     => $library->branchcode,
                borrowernumber => $patron_1->borrowernumber,
                biblionumber   => $biblio->biblionumber,
                priority       => 1,
            }
        )
    );
    my $hold_2 = Koha::Holds->find(
        AddReserve(
            {
                branchcode     => $library->branchcode,
                borrowernumber => $patron_2->borrowernumber,
                biblionumber   => $biblio->biblionumber,
                priority       => 2,
            }
        )
    );
    my $hold_3 = Koha::Holds->find(
        AddReserve(
            {
                branchcode     => $library->branchcode,
                borrowernumber => $patron_3->borrowernumber,
                biblionumber   => $biblio->biblionumber,
                priority       => 3,
            }
        )
    );

    $t->put_ok( "//$userid_np:$password@/api/v1/holds/" . $hold_3->id . "/priority" => json => 1 )->status_is(403);

    $t->put_ok( "//$userid:$password@/api/v1/holds/" . $hold_3->id . "/priority" => json => 1 )->status_is(200)
        ->json_is(1);

    is( $hold_1->discard_changes->priority, 2, 'Priority adjusted correctly' );
    is( $hold_2->discard_changes->priority, 3, 'Priority adjusted correctly' );
    is( $hold_3->discard_changes->priority, 1, 'Priority adjusted correctly' );

    $t->put_ok( "//$userid:$password@/api/v1/holds/" . $hold_3->id . "/priority" => json => 3 )->status_is(200)
        ->json_is(3);

    is( $hold_1->discard_changes->priority, 1, 'Priority adjusted correctly' );
    is( $hold_2->discard_changes->priority, 2, 'Priority adjusted correctly' );
    is( $hold_3->discard_changes->priority, 3, 'Priority adjusted correctly' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests (maxreserves behaviour)' => sub {

    plan tests => 11;

    $schema->storage->txn_begin;

    $dbh->do('DELETE FROM reserves');

    Koha::CirculationRules->new->delete;

    my $password = 'AbcdEFG123';

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { userid => 'tomasito', flags => 1 } } );
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    Koha::CirculationRules->set_rules(
        {
            itemtype     => undef,
            branchcode   => undef,
            categorycode => undef,
            rules        => { reservesallowed => 3 }
        }
    );

    Koha::CirculationRules->set_rules(
        {
            branchcode   => undef,
            categorycode => $patron->categorycode,
            rules        => {
                max_holds => 4,
            }
        }
    );

    my $biblio_1 = $builder->build_sample_biblio;
    my $item_1   = $builder->build_sample_item( { biblionumber => $biblio_1->biblionumber } );
    my $biblio_2 = $builder->build_sample_biblio;
    my $item_2   = $builder->build_sample_item( { biblionumber => $biblio_2->biblionumber } );
    my $biblio_3 = $builder->build_sample_biblio;
    my $item_3   = $builder->build_sample_item( { biblionumber => $biblio_3->biblionumber } );

    # Make sure pickup location checks doesn't get in the middle
    my $mock_biblio = Test::MockModule->new('Koha::Biblio');
    $mock_biblio->mock( 'pickup_locations', sub { return Koha::Libraries->search; } );
    my $mock_item = Test::MockModule->new('Koha::Item');
    $mock_item->mock( 'pickup_locations', sub { return Koha::Libraries->search } );

    # Disable logging
    t::lib::Mocks::mock_preference( 'HoldsLog',                0 );
    t::lib::Mocks::mock_preference( 'RESTBasicAuth',           1 );
    t::lib::Mocks::mock_preference( 'maxreserves',             2 );
    t::lib::Mocks::mock_preference( 'AllowHoldPolicyOverride', 0 );

    my $post_data = {
        patron_id         => $patron->borrowernumber,
        biblio_id         => $biblio_1->biblionumber,
        pickup_library_id => $item_1->home_branch->branchcode,
        item_type         => $item_1->itype,
    };

    $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $post_data )->status_is(201);

    $post_data = {
        patron_id         => $patron->borrowernumber,
        biblio_id         => $biblio_2->biblionumber,
        pickup_library_id => $item_2->home_branch->branchcode,
        item_id           => $item_2->itemnumber
    };

    $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $post_data )->status_is(201);

    $post_data = {
        patron_id         => $patron->borrowernumber,
        biblio_id         => $biblio_3->biblionumber,
        pickup_library_id => $item_1->home_branch->branchcode,
        item_id           => $item_3->itemnumber
    };

    $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $post_data )->status_is(409)->json_is(
        {
            error      => 'Hold cannot be placed. Reason: hold_limit',
            error_code => 'hold_limit'
        }
    );

    t::lib::Mocks::mock_preference( 'maxreserves', 0 );

    $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $post_data )
        ->status_is( 201, 'maxreserves == 0 => no limit' );

    # cleanup for the next tests
    my $hold_id = $t->tx->res->json->{hold_id};
    Koha::Holds->find($hold_id)->delete;

    t::lib::Mocks::mock_preference( 'maxreserves', undef );

    $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $post_data )
        ->status_is( 201, 'maxreserves == undef => no limit' );

    $schema->storage->txn_rollback;
};

subtest 'add() + can_place_holds() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $password = 'AbcdEFG123';

    my $library = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );
    my $staff   = $builder->build_object( { class => 'Koha::Patrons',   value => { flags           => 1 } } );
    $staff->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $staff->userid;

    subtest "'expired' tests" => sub {

        plan tests => 5;

        t::lib::Mocks::mock_preference( 'BlockExpiredPatronOpacActions', 'hold' );

        my $patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { dateexpiry => \'DATE_ADD(NOW(), INTERVAL -1 DAY)' }
            }
        );

        my $item = $builder->build_sample_item( { library => $library->id } );

        my $post_data = {
            patron_id         => $patron->id,
            pickup_library_id => $item->holdingbranch,
            item_id           => $item->id
        };

        $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $post_data )
            ->status_is( 409, "Expected error related to 'expired'" )
            ->json_is( { error => "Hold cannot be placed. Reason: expired", error_code => 'expired' } );

        $t->post_ok( "//$userid:$password@/api/v1/holds" => { 'x-koha-override' => 'expired' } => json => $post_data )
            ->status_is( 201, "Override works for 'expired'" );
    };

    subtest "'debt_limit' tests" => sub {

        plan tests => 7;

        # Add a patron, making sure it is not (yet) expired
        my $patron = $builder->build_object( { class => 'Koha::Patrons', } );
        $patron->account->add_debit( { amount => 10, interface => 'opac', type => 'ACCOUNT' } );

        my $item = $builder->build_sample_item( { library => $library->id } );

        my $post_data = {
            patron_id         => $patron->id,
            pickup_library_id => $item->holdingbranch,
            item_id           => $item->id
        };

        t::lib::Mocks::mock_preference( 'maxoutstanding', '5' );

        $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $post_data )
            ->status_is( 409, "Expected error related to 'debt_limit'" )
            ->json_is( { error => "Hold cannot be placed. Reason: debt_limit", error_code => 'debt_limit' } );

        my $hold_id =
            $t->post_ok(
            "//$userid:$password@/api/v1/holds" => { 'x-koha-override' => 'debt_limit' } => json => $post_data )
            ->status_is( 201, "Override works for 'debt_limit'" )->tx->res->json->{hold_id};

        Koha::Holds->find($hold_id)->delete();

        t::lib::Mocks::mock_preference( 'maxoutstanding', undef );

        $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $post_data )
            ->status_is( 201, "No 'maxoutstanding', can place holds" );
    };

    subtest "'bad_address' tests" => sub {

        plan tests => 5;

        # Add a patron, making sure it is not (yet) expired
        my $patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => {
                    gonenoaddress => 1,
                }
            }
        );

        my $item = $builder->build_sample_item( { library => $library->id } );

        my $post_data = {
            patron_id         => $patron->id,
            pickup_library_id => $item->holdingbranch,
            item_id           => $item->id
        };

        $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $post_data )
            ->status_is( 409, "Expected error related to 'bad_address'" )
            ->json_is( { error => "Hold cannot be placed. Reason: bad_address", error_code => 'bad_address' } );

        $t->post_ok(
            "//$userid:$password@/api/v1/holds" => { 'x-koha-override' => 'bad_address' } => json => $post_data )
            ->status_is( 201, "Override works for 'bad_address'" );
    };

    subtest "'card_lost' tests" => sub {

        plan tests => 5;

        # Add a patron, making sure it is not (yet) expired
        my $patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => {
                    lost => 1,
                }
            }
        );

        my $item = $builder->build_sample_item( { library => $library->id } );

        my $post_data = {
            patron_id         => $patron->id,
            pickup_library_id => $item->holdingbranch,
            item_id           => $item->id
        };

        $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $post_data )
            ->status_is( 409, "Expected error related to 'card_lost'" )
            ->json_is( { error => "Hold cannot be placed. Reason: card_lost", error_code => 'card_lost' } );

        $t->post_ok( "//$userid:$password@/api/v1/holds" => { 'x-koha-override' => 'card_lost' } => json => $post_data )
            ->status_is( 201, "Override works for 'card_lost'" );
    };

    subtest "'restricted' tests" => sub {

        plan tests => 5;

        # Add a patron, making sure it is not (yet) expired
        my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
        AddDebarment( { borrowernumber => $patron->borrowernumber } );
        $patron->discard_changes();

        my $item = $builder->build_sample_item( { library => $library->id } );

        my $post_data = {
            patron_id         => $patron->id,
            pickup_library_id => $item->holdingbranch,
            item_id           => $item->id
        };

        $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $post_data )
            ->status_is( 409, "Expected error related to 'restricted'" )
            ->json_is( { error => "Hold cannot be placed. Reason: restricted", error_code => 'restricted' } );

        $t->post_ok(
            "//$userid:$password@/api/v1/holds" => { 'x-koha-override' => 'restricted' } => json => $post_data )
            ->status_is( 201, "Override works for 'restricted'" );
    };

    subtest "'hold_limit' tests" => sub {

        plan tests => 7;

        # Add a patron, making sure it is not (yet) expired
        my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

        # Add a hold
        $builder->build_object( { class => 'Koha::Holds', value => { borrowernumber => $patron->borrowernumber } } );

        t::lib::Mocks::mock_preference( 'maxreserves', 1 );

        my $item = $builder->build_sample_item( { library => $library->id } );

        my $post_data = {
            patron_id         => $patron->id,
            pickup_library_id => $item->holdingbranch,
            item_id           => $item->id
        };

        $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $post_data )
            ->status_is( 409, "Expected error related to 'hold_limit'" )
            ->json_is( { error => "Hold cannot be placed. Reason: hold_limit", error_code => 'hold_limit' } );

        my $hold_id = $t->post_ok(
            "//$userid:$password@/api/v1/holds" => { 'x-koha-override' => 'hold_limit' } => json => $post_data )
            ->status_is( 201, "Override works for 'hold_limit'" )->tx->res->json->{hold_id};

        Koha::Holds->find($hold_id)->delete();

        t::lib::Mocks::mock_preference( 'maxreserves', undef );

        $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $post_data )
            ->status_is( 201, "No 'max_reserves', can place holds" );
    };

    subtest "Multiple blocking conditions tests" => sub {

        plan tests => 8;

        t::lib::Mocks::mock_preference( 'BlockExpiredPatronOpacActions', 'hold' );

        my $patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { dateexpiry => \'DATE_ADD(NOW(), INTERVAL -1 DAY)' }
            }
        );

        t::lib::Mocks::mock_preference( 'maxoutstanding', '5' );
        $patron->account->add_debit( { amount => 10, interface => 'opac', type => 'ACCOUNT' } );

        my $item = $builder->build_sample_item( { library => $library->id } );

        my $post_data = {
            patron_id         => $patron->id,
            pickup_library_id => $item->holdingbranch,
            item_id           => $item->id
        };

        ## NOTICE: this tests rely on 'expired' being checked before 'debt_limit' in Koha::Patron->can_place_holds

        # patron meets 'expired' and 'debt_limit'
        $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $post_data )
            ->status_is( 409, "Expected error related to 'expired'" )
            ->json_is( { error => "Hold cannot be placed. Reason: expired", error_code => 'expired' } );

        # patron meets 'expired' AND 'debt_limit'
        $t->post_ok( "//$userid:$password@/api/v1/holds" => { 'x-koha-override' => 'expired' } => json => $post_data )
            ->status_is( 409, "Expected error related to 'debt_limit'" )
            ->json_is( { error => "Hold cannot be placed. Reason: debt_limit", error_code => 'debt_limit' } );

        $t->post_ok(
            "//$userid:$password@/api/v1/holds" => { 'x-koha-override' => 'expired,debt_limit' } => json => $post_data )
            ->status_is( 201, "Override works for both 'expired' and 'debt_limit'" );
    };
};

subtest 'pickup_locations() tests' => sub {

    plan tests => 15;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'AllowHoldPolicyOverride', 0 );

    # Small trick to ease testing
    Koha::Libraries->search->update( { pickup_location => 0 } );

    my @libraries;
    for my $marcorgcode ( 'A' .. 'Z' ) {
        my $is_pickup_location = $marcorgcode ne 'Z' ? 1 : 0;
        my $library            = $builder->build_object(
            {
                class => 'Koha::Libraries',
                value => { marcorgcode => $marcorgcode, pickup_location => $is_pickup_location }
            }
        );
        my $library_api = $library->to_api;
        $library_api->{needs_override} = Mojo::JSON->false;
        push @libraries, $library_api;
    }

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { userid => 'tomasito', flags => 0 }
        }
    );
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $patron->borrowernumber,
                module_bit     => 6,
                code           => 'place_holds',
            },
        }
    );

    my $item_class = Test::MockModule->new('Koha::Item');
    $item_class->mock(
        'pickup_locations',
        sub {
            my ( $self, $params ) = @_;
            my $mock_patron = $params->{patron};
            is(
                $mock_patron->borrowernumber,
                $patron->borrowernumber, 'Patron passed correctly'
            );
            return Koha::Libraries->search(
                {
                    branchcode => {
                        '-in' => [
                            $libraries[0]->{library_id},
                            $libraries[1]->{library_id},
                        ]
                    }
                },
                {    # we make sure no surprises in the order of the result
                    order_by => { '-asc' => 'marcorgcode' }
                }
            );
        }
    );

    my $biblio_class = Test::MockModule->new('Koha::Biblio');
    $biblio_class->mock(
        'pickup_locations',
        sub {
            my ( $self, $params ) = @_;
            my $mock_patron = $params->{patron};
            is(
                $mock_patron->borrowernumber,
                $patron->borrowernumber, 'Patron passed correctly'
            );
            return Koha::Libraries->search(
                {
                    branchcode => {
                        '-in' => [
                            $libraries[1]->{library_id},
                            $libraries[2]->{library_id},
                        ]
                    }
                },
                {    # we make sure no surprises in the order of the result
                    order_by => { '-asc' => 'marcorgcode' }
                }
            );
        }
    );

    my $item = $builder->build_sample_item;

    # biblio-level hold
    my $hold_1 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                itemnumber     => undef,
                biblionumber   => $item->biblionumber,
                borrowernumber => $patron->borrowernumber
            }
        }
    );

    # item-level hold
    my $hold_2 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                itemnumber     => $item->itemnumber,
                biblionumber   => $item->biblionumber,
                borrowernumber => $patron->borrowernumber
            }
        }
    );

    $t->get_ok( "//$userid:$password@/api/v1/holds/" . $hold_1->id . "/pickup_locations" )
        ->json_is( [ $libraries[1], $libraries[2] ] );

    $t->get_ok( "//$userid:$password@/api/v1/holds/" . $hold_2->id . "/pickup_locations" )
        ->json_is( [ $libraries[0], $libraries[1] ] );

    # filtering works!
    $t->get_ok( "//$userid:$password@/api/v1/holds/"
            . $hold_2->id
            . '/pickup_locations?q={"marc_org_code": { "-like": "A%" }}' )->json_is( [ $libraries[0] ] );

    t::lib::Mocks::mock_preference( 'AllowHoldPolicyOverride', 1 );
    t::lib::Mocks::mock_preference( 'RESTdefaultPageSize',     20 );

    # biblio-level mock doesn't include libraries[1] and $libraries[2] as valid pickup location
    $_->{needs_override}            = Mojo::JSON->true for @libraries;
    $libraries[1]->{needs_override} = Mojo::JSON->false;
    $libraries[2]->{needs_override} = Mojo::JSON->false;

    $t->get_ok( "//$userid:$password@/api/v1/holds/" . $hold_1->id . "/pickup_locations?_order_by=marc_org_code" )
        ->json_is( [ @libraries[ 0 .. 19 ] ] );

    # Library "Z" is not listed
    $t->get_ok(
        "//$userid:$password@/api/v1/holds/" . $hold_1->id . "/pickup_locations?_order_by=marc_org_code&_page=2" )
        ->json_is( [ @libraries[ 20 .. 24 ] ] );

    $schema->storage->txn_rollback;
};

subtest 'edit() tests' => sub {

    plan tests => 47;

    $schema->storage->txn_begin;

    my $password = 'AbcdEFG123';

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $patron->borrowernumber,
                module_bit     => 6,
                code           => 'modify_holds_priority',
            },
        }
    );

    # Disable logging
    t::lib::Mocks::mock_preference( 'HoldsLog',                0 );
    t::lib::Mocks::mock_preference( 'RESTBasicAuth',           1 );
    t::lib::Mocks::mock_preference( 'AllowHoldPolicyOverride', 1 );

    my $mock_biblio = Test::MockModule->new('Koha::Biblio');
    my $mock_item   = Test::MockModule->new('Koha::Item');

    my $library_1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_3 = $builder->build_object( { class => 'Koha::Libraries' } );

    # let's control what Koha::Biblio->pickup_locations returns, for testing
    $mock_biblio->mock(
        'pickup_locations',
        sub {
            return Koha::Libraries->search( { branchcode => [ $library_2->branchcode, $library_3->branchcode ] } );
        }
    );

    # let's mock what Koha::Item->pickup_locations returns, for testing
    $mock_item->mock(
        'pickup_locations',
        sub {
            return Koha::Libraries->search( { branchcode => [ $library_2->branchcode, $library_3->branchcode ] } );
        }
    );

    my $biblio = $builder->build_sample_biblio;
    my $item   = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );

    # Test biblio-level holds
    my $biblio_hold = $builder->build_object(
        {
            class => "Koha::Holds",
            value => {
                biblionumber   => $biblio->biblionumber,
                branchcode     => $library_3->branchcode,
                itemnumber     => undef,
                priority       => 1,
                reservedate    => '2022-01-01',
                expirationdate => '2022-03-01'
            }
        }
    );

    my $biblio_hold_api_data = $biblio_hold->to_api;
    my $biblio_hold_data     = {
        pickup_library_id => $library_1->branchcode,
        priority          => $biblio_hold_api_data->{priority}
    };

    $t->patch_ok( "//$userid:$password@/api/v1/holds/" . $biblio_hold->id => json => $biblio_hold_data )
        ->status_is(400)->json_is( { error => 'The supplied pickup location is not valid' } );

    $t->put_ok( "//$userid:$password@/api/v1/holds/" . $biblio_hold->id => json => $biblio_hold_data )->status_is(400)
        ->json_is( { error => 'The supplied pickup location is not valid' } );

    $biblio_hold->discard_changes;
    is( $biblio_hold->branchcode, $library_3->branchcode, 'branchcode remains untouched' );

    $t->patch_ok( "//$userid:$password@/api/v1/holds/"
            . $biblio_hold->id => { 'x-koha-override' => 'any' } => json => $biblio_hold_data )->status_is(200)
        ->json_has( '/pickup_library_id' => $library_1->id );

    $t->put_ok( "//$userid:$password@/api/v1/holds/"
            . $biblio_hold->id => { 'x-koha-override' => 'any' } => json => $biblio_hold_data )->status_is(200)
        ->json_has( '/pickup_library_id' => $library_1->id );

    $biblio_hold_data->{pickup_library_id} = $library_2->branchcode;
    $t->patch_ok( "//$userid:$password@/api/v1/holds/" . $biblio_hold->id => json => $biblio_hold_data )
        ->status_is(200);

    $biblio_hold->discard_changes;
    is( $biblio_hold->branchcode, $library_2->id, 'Pickup location changed correctly' );

    $t->put_ok( "//$userid:$password@/api/v1/holds/" . $biblio_hold->id => json => $biblio_hold_data )->status_is(200);

    $biblio_hold->discard_changes;
    is( $biblio_hold->branchcode, $library_2->id, 'Pickup location changed correctly' );

    $biblio_hold_data = {
        hold_date       => '2022-01-02',
        expiration_date => '2022-03-02'
    };

    $t->patch_ok( "//$userid:$password@/api/v1/holds/" . $biblio_hold->id => json => $biblio_hold_data )
        ->status_is(200);

    $biblio_hold->discard_changes;
    is( $biblio_hold->reservedate,    '2022-01-02', 'Hold date changed correctly' );
    is( $biblio_hold->expirationdate, '2022-03-02', 'Expiration date changed correctly' );

    # Test item-level holds
    my $item_hold = $builder->build_object(
        {
            class => "Koha::Holds",
            value => {
                biblionumber   => $biblio->biblionumber,
                branchcode     => $library_3->branchcode,
                itemnumber     => $item->itemnumber,
                priority       => 1,
                suspend        => 0,
                suspend_until  => undef,
                reservedate    => '2022-01-01',
                expirationdate => '2022-03-01'
            }
        }
    );

    my $item_hold_api_data = $item_hold->to_api;
    my $item_hold_data     = {
        pickup_library_id => $library_1->branchcode,
        priority          => $item_hold_api_data->{priority}
    };

    $t->patch_ok( "//$userid:$password@/api/v1/holds/" . $item_hold->id => json => $item_hold_data )->status_is(400)
        ->json_is( { error => 'The supplied pickup location is not valid' } );

    $t->put_ok( "//$userid:$password@/api/v1/holds/" . $item_hold->id => json => $item_hold_data )->status_is(400)
        ->json_is( { error => 'The supplied pickup location is not valid' } );

    $item_hold->discard_changes;
    is( $item_hold->branchcode, $library_3->branchcode, 'branchcode remains untouched' );

    $t->patch_ok( "//$userid:$password@/api/v1/holds/"
            . $item_hold->id => { 'x-koha-override' => 'any' } => json => $item_hold_data )->status_is(200)
        ->json_has( '/pickup_library_id' => $library_1->id );

    $t->put_ok( "//$userid:$password@/api/v1/holds/"
            . $item_hold->id => { 'x-koha-override' => 'any' } => json => $item_hold_data )->status_is(200)
        ->json_has( '/pickup_library_id' => $library_1->id );

    $item_hold_data->{pickup_library_id} = $library_2->branchcode;
    $t->patch_ok( "//$userid:$password@/api/v1/holds/" . $item_hold->id => json => $item_hold_data )->status_is(200);

    $t->put_ok( "//$userid:$password@/api/v1/holds/" . $item_hold->id => json => $item_hold_data )->status_is(200);

    $item_hold->discard_changes;
    is( $item_hold->branchcode, $library_2->id, 'Pickup location changed correctly' );

    is( $item_hold->suspend,       0,     'Location change should not activate suspended status' );
    is( $item_hold->suspend_until, undef, 'Location change should keep suspended_until be undef' );

    $item_hold_data = {
        hold_date       => '2022-01-02',
        expiration_date => '2022-03-02'
    };

    $t->patch_ok( "//$userid:$password@/api/v1/holds/" . $item_hold->id => json => $item_hold_data )->status_is(200);

    $item_hold->discard_changes;
    is( $item_hold->reservedate,    '2022-01-02', 'Hold date changed correctly' );
    is( $item_hold->expirationdate, '2022-03-02', 'Expiration date changed correctly' );

    $schema->storage->txn_rollback;

};

subtest 'add() tests' => sub {

    plan tests => 24;

    $schema->storage->txn_begin;

    my $password = 'AbcdEFG123';

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $patron->borrowernumber,
                module_bit     => 6,
                code           => 'modify_holds_priority',
            },
        }
    );

    # Disable logging
    t::lib::Mocks::mock_preference( 'HoldsLog',      0 );
    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

    my $mock_biblio = Test::MockModule->new('Koha::Biblio');
    my $mock_item   = Test::MockModule->new('Koha::Item');

    my $library_1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_3 = $builder->build_object( { class => 'Koha::Libraries' } );

    # let's control what Koha::Biblio->pickup_locations returns, for testing
    $mock_biblio->mock(
        'pickup_locations',
        sub {
            return Koha::Libraries->search( { branchcode => [ $library_2->branchcode, $library_3->branchcode ] } );
        }
    );

    # let's mock what Koha::Item->pickup_locations returns, for testing
    $mock_item->mock(
        'pickup_locations',
        sub {
            return Koha::Libraries->search( { branchcode => [ $library_2->branchcode, $library_3->branchcode ] } );
        }
    );

    my $can_biblio_be_reserved = 'OK';
    my $can_item_be_reserved   = 'OK';

    my $mock_reserves = Test::MockModule->new('C4::Reserves');

    $mock_reserves->mock(
        'CanItemBeReserved',
        sub {
            return { status => $can_item_be_reserved };
        }

    );
    $mock_reserves->mock(
        'CanBookBeReserved',
        sub {
            return { status => $can_biblio_be_reserved };
        }

    );

    my $biblio = $builder->build_sample_biblio;
    my $item   = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );

    # Test biblio-level holds
    my $biblio_hold = $builder->build_object(
        {
            class => "Koha::Holds",
            value => {
                biblionumber => $biblio->biblionumber,
                branchcode   => $library_3->branchcode,
                itemnumber   => undef,
                priority     => 1,
            }
        }
    );

    my $biblio_hold_api_data = $biblio_hold->to_api;
    $biblio_hold->delete;
    my $biblio_hold_data = {
        biblio_id         => $biblio_hold_api_data->{biblio_id},
        patron_id         => $biblio_hold_api_data->{patron_id},
        pickup_library_id => $library_1->branchcode,
    };

    $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $biblio_hold_data )->status_is(400)
        ->json_is( { error => 'The supplied pickup location is not valid' } );

    $biblio_hold_data->{pickup_library_id} = $library_2->branchcode;
    $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $biblio_hold_data )->status_is(201);

    # Test biblio-level holds
    my $item_group = Koha::Biblio::ItemGroup->new( { biblio_id => $biblio->id } )->store();
    $biblio_hold = $builder->build_object(
        {
            class => "Koha::Holds",
            value => {
                biblionumber  => $biblio->biblionumber,
                branchcode    => $library_3->branchcode,
                itemnumber    => undef,
                priority      => 1,
                item_group_id => $item_group->id,
            }
        }
    );

    $biblio_hold_api_data = $biblio_hold->to_api;
    $biblio_hold->delete;
    $biblio_hold_data = {
        biblio_id         => $biblio_hold_api_data->{biblio_id},
        patron_id         => $biblio_hold_api_data->{patron_id},
        pickup_library_id => $library_1->branchcode,
    };

    $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $biblio_hold_data )->status_is(400)
        ->json_is( { error => 'The supplied pickup location is not valid' } );

    $biblio_hold_data->{pickup_library_id} = $library_2->branchcode;
    $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $biblio_hold_data )->status_is(201);

    # Test item-level holds
    my $item_hold = $builder->build_object(
        {
            class => "Koha::Holds",
            value => {
                biblionumber => $biblio->biblionumber,
                branchcode   => $library_3->branchcode,
                itemnumber   => $item->itemnumber,
                priority     => 1,
            }
        }
    );

    my $item_hold_api_data = $item_hold->to_api;
    $item_hold->delete;
    my $item_hold_data = {
        biblio_id         => $item_hold_api_data->{biblio_id},
        item_id           => $item_hold_api_data->{item_id},
        patron_id         => $item_hold_api_data->{patron_id},
        pickup_library_id => $library_1->branchcode,
    };

    $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $item_hold_data )->status_is(400)
        ->json_is( { error => 'The supplied pickup location is not valid' } );

    $can_item_be_reserved   = 'notReservable';
    $can_biblio_be_reserved = 'OK';

    $item_hold_data->{pickup_library_id} = $library_2->branchcode;

    $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $item_hold_data )
        ->status_is( 403, 'Item checks performed when both biblio_id and item_id passed (Bug 35053)' )
        ->json_is( { error => 'Hold cannot be placed. Reason: notReservable' } );

    $can_item_be_reserved   = 'OK';
    $can_biblio_be_reserved = 'OK';

    $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $item_hold_data )->status_is(201);

    # empty cases
    $mock_biblio->mock(
        'pickup_locations',
        sub {
            return Koha::Libraries->new->empty;
        }
    );

    $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $biblio_hold_data )->status_is(400)
        ->json_is( { error => 'The supplied pickup location is not valid' } );

    # empty cases
    $mock_item->mock(
        'pickup_locations',
        sub {
            return Koha::Libraries->new->empty;
        }
    );

    $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $item_hold_data )->status_is(400)
        ->json_is( { error => 'The supplied pickup location is not valid' } );

    $schema->storage->txn_rollback;
};

subtest 'PUT /holds/{hold_id}/pickup_location tests' => sub {

    plan tests => 37;

    $schema->storage->txn_begin;

    my $password = 'AbcdEFG123';

    # library_1 and library_2 are available pickup locations, not library_3
    my $library_1 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );
    my $library_2 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );
    my $library_3 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 0 } } );

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $patron->borrowernumber,
                module_bit     => 6,
                code           => 'place_holds',
            },
        }
    );

    # Disable logging
    t::lib::Mocks::mock_preference( 'HoldsLog',      0 );
    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

    my $biblio = $builder->build_sample_biblio;
    my $item   = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $library_1->branchcode
        }
    );

    # biblio-level hold
    my $hold = Koha::Holds->find(
        AddReserve(
            {
                branchcode     => $library_1->branchcode,
                borrowernumber => $patron->borrowernumber,
                biblionumber   => $biblio->biblionumber,
                priority       => 1,
                itemnumber     => undef,
            }
        )
    );

    $t->put_ok( "//$userid:$password@/api/v1/holds/"
            . $hold->id
            . "/pickup_location" => json => { pickup_library_id => $library_2->branchcode } )->status_is(200)
        ->json_is( { pickup_library_id => $library_2->branchcode } );

    is( $hold->discard_changes->branchcode, $library_2->branchcode, 'pickup library adjusted correctly' );

    $t->put_ok( "//$userid:$password@/api/v1/holds/"
            . $hold->id
            . "/pickup_location" => json => { pickup_library_id => $library_3->branchcode } )->status_is(400)
        ->json_is( { error => '[The supplied pickup location is not valid]' } );

    is( $hold->discard_changes->branchcode, $library_2->branchcode, 'pickup library unchanged' );

    # item-level hold
    $hold = Koha::Holds->find(
        AddReserve(
            {
                branchcode     => $library_1->branchcode,
                borrowernumber => $patron->borrowernumber,
                biblionumber   => $biblio->biblionumber,
                priority       => 1,
                itemnumber     => $item->itemnumber,
            }
        )
    );

    # Attempt to use an invalid pickup locations ends in 400
    $t->put_ok( "//$userid:$password@/api/v1/holds/"
            . $hold->id
            . "/pickup_location" => json => { pickup_library_id => $library_3->branchcode } )->status_is(400)
        ->json_is( { error => '[The supplied pickup location is not valid]' } );

    is( $hold->discard_changes->branchcode, $library_1->branchcode, 'pickup library unchanged' );

    t::lib::Mocks::mock_preference( 'AllowHoldPolicyOverride', 1 );

    # Attempt to use an invalid pickup locations with override succeeds
    $t->put_ok( "//$userid:$password@/api/v1/holds/"
            . $hold->id
            . "/pickup_location" => { 'x-koha-override' => 'any' } => json =>
            { pickup_library_id => $library_2->branchcode } )->status_is(200)
        ->json_is( { pickup_library_id => $library_2->branchcode } );

    is( $hold->discard_changes->branchcode, $library_2->branchcode, 'pickup library changed' );

    t::lib::Mocks::mock_preference( 'AllowHoldPolicyOverride', 0 );

    $t->put_ok( "//$userid:$password@/api/v1/holds/"
            . $hold->id
            . "/pickup_location" => json => { pickup_library_id => $library_2->branchcode } )->status_is(200)
        ->json_is( { pickup_library_id => $library_2->branchcode } );

    is( $hold->discard_changes->branchcode, $library_2->branchcode, 'pickup library adjusted correctly' );

    $t->put_ok( "//$userid:$password@/api/v1/holds/"
            . $hold->id
            . "/pickup_location" => json => { pickup_library_id => $library_3->branchcode } )->status_is(400)
        ->json_is( { error => '[The supplied pickup location is not valid]' } );

    is( $hold->discard_changes->branchcode, $library_2->branchcode, 'invalid pickup library not used' );

    $t->put_ok( "//$userid:$password@/api/v1/holds/"
            . $hold->id
            . "/pickup_location" => { 'x-koha-override' => 'any' } => json =>
            { pickup_library_id => $library_3->branchcode } )->status_is(400)
        ->json_is( { error => '[The supplied pickup location is not valid]' } );

    is(
        $hold->discard_changes->branchcode, $library_2->branchcode,
        'invalid pickup library not used, even if x-koha-override is passed'
    );

    my $waiting_hold       = $builder->build_object( { class => 'Koha::Holds', value => { found => 'W' } } );
    my $in_processing_hold = $builder->build_object( { class => 'Koha::Holds', value => { found => 'P' } } );
    my $in_transit_hold    = $builder->build_object( { class => 'Koha::Holds', value => { found => 'T' } } );

    $t->put_ok( "//$userid:$password@/api/v1/holds/"
            . $waiting_hold->id
            . "/pickup_location" => json => { pickup_library_id => $library_2->branchcode } )->status_is(409)
        ->json_is( { error => q{Cannot change pickup location}, error_code => 'hold_waiting' } );

    $t->put_ok( "//$userid:$password@/api/v1/holds/"
            . $in_processing_hold->id
            . "/pickup_location" => json => { pickup_library_id => $library_2->branchcode } )->status_is(409)
        ->json_is( { error => q{Cannot change pickup location}, error_code => 'hold_in_processing' } );

    $t->put_ok( "//$userid:$password@/api/v1/holds/"
            . $in_transit_hold->id
            . "/pickup_location" => json => { pickup_library_id => $library_2->branchcode } )->status_is(200)
        ->json_is( { pickup_library_id => $library_2->branchcode } );

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 13;

    $schema->storage->txn_begin;

    my $password = 'AbcdEFG123';
    my $patron   = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    # Only have 'place_holds' subpermission
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $patron->borrowernumber,
                module_bit     => 6,
                code           => 'place_holds',
            },
        }
    );

    # Disable logging
    t::lib::Mocks::mock_preference( 'HoldsLog',      0 );
    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

    my $biblio = $builder->build_sample_biblio;
    my $item   = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $patron->branchcode
        }
    );

    # Add a hold
    my $hold = Koha::Holds->find(
        AddReserve(
            {
                branchcode     => $patron->branchcode,
                borrowernumber => $patron->borrowernumber,
                biblionumber   => $biblio->biblionumber,
                priority       => 1,
                itemnumber     => undef,
            }
        )
    );

    $t->delete_ok( "//$userid:$password@/api/v1/holds/" . $hold->id )->status_is( 204, 'REST3.2.4' )
        ->content_is( '', 'REST3.3.4' );

    $hold = Koha::Holds->find(
        AddReserve(
            {
                branchcode     => $patron->branchcode,
                borrowernumber => $patron->borrowernumber,
                biblionumber   => $biblio->biblionumber,
                priority       => 1,
                itemnumber     => undef,
            }
        )
    );

    $t->delete_ok( "//$userid:$password@/api/v1/holds/" . $hold->id => { 'x-koha-override' => q{} } )
        ->status_is( 204, 'Same behavior if header not set' )->content_is('');

    $hold = Koha::Holds->find(
        AddReserve(
            {
                branchcode     => $patron->branchcode,
                borrowernumber => $patron->borrowernumber,
                biblionumber   => $biblio->biblionumber,
                priority       => 1,
                itemnumber     => undef,
            }
        )
    );

    $t->delete_ok(
        "//$userid:$password@/api/v1/holds/" . $hold->id => { 'x-koha-override' => q{cancellation-request-flow} } )
        ->status_is( 204, 'Same behavior if header set but hold not waiting' )->content_is('');

    $hold = Koha::Holds->find(
        AddReserve(
            {
                branchcode     => $patron->branchcode,
                borrowernumber => $patron->borrowernumber,
                biblionumber   => $biblio->biblionumber,
                priority       => 1,
                itemnumber     => $item->id,
            }
        )
    );

    $hold->set_waiting;

    is( $hold->cancellation_requests->count, 0 );

    $t->delete_ok(
        "//$userid:$password@/api/v1/holds/" . $hold->id => { 'x-koha-override' => q{cancellation-request-flow} } )
        ->status_is( 202, 'Cancellation request accepted' );

    is( $hold->cancellation_requests->count, 1 );

    $schema->storage->txn_rollback;
};

subtest 'delete_bulk) tests' => sub {

    plan tests => 12;

    $schema->storage->txn_begin;

    my $password = 'AbcdEFG123';
    my $patron   = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    # Only have 'place_holds' subpermission
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $patron->borrowernumber,
                module_bit     => 6,
                code           => 'place_holds',
            },
        }
    );

    # Disable logging
    t::lib::Mocks::mock_preference( 'HoldsLog',      0 );
    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

    my $biblio = $builder->build_sample_biblio;
    my $item   = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $patron->branchcode
        }
    );

    # Add a hold
    my $hold = Koha::Holds->find(
        AddReserve(
            {
                branchcode     => $patron->branchcode,
                borrowernumber => $patron->borrowernumber,
                biblionumber   => $biblio->biblionumber,
                priority       => 1,
                itemnumber     => undef,
            }
        )
    );

    $t->delete_ok( "//$userid:$password@/api/v1/holds/cancellation_bulk" => json => { hold_ids => [ $hold->id ] } )
        ->status_is( 204, 'REST3.2.4' )->content_is( '', 'REST3.3.4' );

    is( $hold->get_from_storage, undef, "Hold has been successfully deleted" );

    my $hold_2 = Koha::Holds->find(
        AddReserve(
            {
                branchcode     => $patron->branchcode,
                borrowernumber => $patron->borrowernumber,
                biblionumber   => $biblio->biblionumber,
                priority       => 1,
                itemnumber     => undef,
            }
        )
    );

    # Prevent warning 'No reserves HOLD_CANCELLATION letter transported by email'
    my $mock_letters = Test::MockModule->new('C4::Letters');
    $mock_letters->mock( 'GetPreparedLetter', sub { return } );

    $t->delete_ok( "//$userid:$password@/api/v1/holds/cancellation_bulk" => json =>
            { hold_ids => [ $hold_2->id ], cancellation_reason => 'DAMAGED' } )->status_is( 204, 'REST3.2.4' )
        ->content_is( '', 'REST3.3.4' );

    my $old_hold_2 = Koha::Old::Holds->find( $hold_2->id );
    is( $old_hold_2->cancellation_reason, 'DAMAGED', "Hold successfully deleted with provided cancellation reason" );

    my $hold_3 = Koha::Holds->find(
        AddReserve(
            {
                branchcode     => $patron->branchcode,
                borrowernumber => $patron->borrowernumber,
                biblionumber   => $biblio->biblionumber,
                priority       => 1,
                itemnumber     => undef,
            }
        )
    );

    $t->delete_ok( "//$userid:$password@/api/v1/holds/cancellation_bulk" => json =>
            { hold_ids => [ $hold_2->id, $hold_3->id ], cancellation_reason => 'DAMAGED' } )
        ->status_is( 404, 'REST3.2.4' )
        ->content_is( '{"error":"Hold not found","error_code":"not_found"}', 'REST3.3.4' );

    isnt( $hold_3->get_from_storage, undef, "Hold 3 has not been deleted because cancellation_bulk failed." );

    $schema->storage->txn_rollback;
};

subtest 'PUT /holds/{hold_id}/lowest_priority tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $password = 'AbcdEFG123';

    my $library_1 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $patron->borrowernumber,
                module_bit     => 6,
                code           => 'modify_holds_priority',
            },
        }
    );

    # Disable logging
    t::lib::Mocks::mock_preference( 'HoldsLog',      0 );
    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

    my $biblio = $builder->build_sample_biblio;

    # biblio-level hold
    my $hold = Koha::Holds->find(
        AddReserve(
            {
                branchcode     => $library_1->branchcode,
                borrowernumber => $patron->borrowernumber,
                biblionumber   => $biblio->biblionumber,
                priority       => 1,
                itemnumber     => undef,
            }
        )
    );

    $t->put_ok( "//$userid:$password@/api/v1/holds/0" . "/lowest_priority" )->status_is(404);

    $t->put_ok( "//$userid:$password@/api/v1/holds/" . $hold->id . "/lowest_priority" )->status_is(200);

    is( $hold->discard_changes->lowestPriority, 1, 'Priority set to lowest' );

    $schema->storage->txn_rollback;
};

subtest 'Bug 40866: API hold creation with override logs confirmations' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 1 }
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

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $biblio  = $builder->build_sample_biblio;

    t::lib::Mocks::mock_preference( 'AllowHoldPolicyOverride', 1 );
    t::lib::Mocks::mock_preference( 'HoldsLog',                1 );

    # Clear any existing logs
    Koha::ActionLogs->search( { module => 'HOLDS', action => 'CREATE' } )->delete;

    my $post_data = {
        patron_id         => $patron->id,
        biblio_id         => $biblio->id,
        pickup_library_id => $library->branchcode,
    };

    # Create hold with override
    my $hold_id =
        $t->post_ok( "//$userid:$password@/api/v1/holds" => { 'x-koha-override' => 'any' } => json => $post_data )
        ->status_is(201)->tx->res->json->{hold_id};

    ok( $hold_id, 'Hold created via API with override' );

    # Verify the hold was logged with override information
    my $logs = Koha::ActionLogs->search(
        {
            module => 'HOLDS',
            action => 'CREATE',
            object => $hold_id
        },
        { order_by => { -desc => 'timestamp' } }
    );

    is( $logs->count, 1, 'One log entry created for API hold with override' );

    my $log      = $logs->next;
    my $log_data = eval { from_json( $log->info ) };
    ok( !$@, 'Log info is valid JSON' );
    is_deeply(
        $log_data->{confirmations},
        ['HOLD_POLICY_OVERRIDE'],
        'HOLD_POLICY_OVERRIDE logged in confirmations array'
    );

    $schema->storage->txn_rollback;
};
