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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Test::More tests => 8;
use Test::Mojo;
use t::lib::TestBuilder;
use t::lib::Mocks;

use DateTime;

use C4::Context;
use Koha::Patrons;
use C4::Reserves;
use C4::Items;

use Koha::Database;
use Koha::DateUtils;
use Koha::Biblios;
use Koha::Biblioitems;
use Koha::Items;
use Koha::CirculationRules;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

$schema->storage->txn_begin;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

my $categorycode = $builder->build({ source => 'Category' })->{categorycode};
my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};
my $itemtype = $builder->build({ source => 'Itemtype' })->{itemtype};

# Generic password for everyone
my $password = 'thePassword123';

# User without any permissions
my $nopermission = $builder->build_object({
    class => 'Koha::Patrons',
    value => {
        branchcode   => $branchcode,
        categorycode => $categorycode,
        flags        => 0
    }
});
$nopermission->set_password( { password => $password, skip_validation => 1 } );
my $nopermission_userid = $nopermission->userid;

my $patron_1 = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            categorycode => $categorycode,
            branchcode   => $branchcode,
            surname      => 'Test Surname',
            flags        => 80, #borrowers and reserveforothers flags
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
            flags        => 16, # borrowers flag
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
            flags        => 64, # reserveforothers flag
        }
    }
);
$patron_3->set_password( { password => $password, skip_validation => 1 } );
my $userid_3 = $patron_3->userid;

my $biblio_1 = $builder->build_sample_biblio;
my $item_1   = $builder->build_sample_item({ biblionumber => $biblio_1->biblionumber, itype => $itemtype });

my $biblio_2 = $builder->build_sample_biblio;
my $item_2   = $builder->build_sample_item({ biblionumber => $biblio_2->biblionumber, itype => $itemtype });

my $dbh = C4::Context->dbh;
$dbh->do('DELETE FROM reserves');
Koha::CirculationRules->search()->delete();
Koha::CirculationRules->set_rules(
    {
        categorycode => undef,
        branchcode   => undef,
        itemtype     => undef,
        rules        => {
            reservesallowed => 1,
            holds_per_record => 99
        }
    }
);

my $reserve_id = C4::Reserves::AddReserve($branchcode, $patron_1->borrowernumber,
    $biblio_1->biblionumber, undef, 1, undef, undef, undef, '', $item_1->itemnumber);

# Add another reserve to be able to change first reserve's rank
my $reserve_id2 = C4::Reserves::AddReserve($branchcode, $patron_2->borrowernumber,
    $biblio_1->biblionumber, undef, 2, undef, undef, undef, '', $item_1->itemnumber);

my $suspended_until = DateTime->now->add(days => 10)->truncate( to => 'day' );
my $expiration_date = DateTime->now->add(days => 10)->truncate( to => 'day' );

my $post_data = {
    patron_id => int($patron_1->borrowernumber),
    biblio_id => int($biblio_1->biblionumber),
    item_id => int($item_1->itemnumber),
    pickup_library_id => $branchcode,
    expiration_date => output_pref({ dt => $expiration_date, dateformat => 'rfc3339', dateonly => 1 }),
    priority => 2,
};
my $put_data = {
    priority => 2,
    suspended_until => output_pref({ dt => $suspended_until, dateformat => 'rfc3339' }),
};

subtest "Test endpoints without authentication" => sub {
    plan tests => 8;
    $t->get_ok('/api/v1/holds')
      ->status_is(401);
    $t->post_ok('/api/v1/holds')
      ->status_is(401);
    $t->put_ok('/api/v1/holds/0')
      ->status_is(401);
    $t->delete_ok('/api/v1/holds/0')
      ->status_is(401);
};

subtest "Test endpoints without permission" => sub {

    plan tests => 10;

    $t->get_ok( "//$nopermission_userid:$password@/api/v1/holds?patron_id=" . $patron_1->borrowernumber ) # no permission
      ->status_is(403);

    $t->get_ok( "//$userid_3:$password@/api/v1/holds?patron_id=" . $patron_1->borrowernumber )    # no permission
      ->status_is(403);

    $t->post_ok( "//$nopermission_userid:$password@/api/v1/holds" => json => $post_data )
      ->status_is(403);

    $t->put_ok( "//$nopermission_userid:$password@/api/v1/holds/0" => json => $put_data )
      ->status_is(403);

    $t->delete_ok( "//$nopermission_userid:$password@/api/v1/holds/0" )
      ->status_is(403);
};

subtest "Test endpoints with permission" => sub {

    plan tests => 44;

    $t->get_ok( "//$userid_1:$password@/api/v1/holds" )
      ->status_is(200)
      ->json_has('/0')
      ->json_has('/1')
      ->json_hasnt('/2');

    $t->get_ok( "//$userid_1:$password@/api/v1/holds?priority=2" )
      ->status_is(200)
      ->json_is('/0/patron_id', $patron_2->borrowernumber)
      ->json_hasnt('/1');

    $t->put_ok( "//$userid_1:$password@/api/v1/holds/$reserve_id" => json => $put_data )
      ->status_is(200)
      ->json_is( '/hold_id', $reserve_id )
      ->json_is( '/suspended_until', output_pref({ dt => $suspended_until, dateformat => 'rfc3339' }) )
      ->json_is( '/priority', 2 );

    $t->delete_ok( "//$userid_3:$password@/api/v1/holds/$reserve_id" )
      ->status_is(200);

    $t->put_ok( "//$userid_3:$password@/api/v1/holds/$reserve_id" => json => $put_data )
      ->status_is(404)
      ->json_has('/error');

    $t->delete_ok( "//$userid_3:$password@/api/v1/holds/$reserve_id" )
      ->status_is(404)
      ->json_has('/error');

    $t->get_ok( "//$userid_2:$password@/api/v1/holds?patron_id=" . $patron_1->borrowernumber )
      ->status_is(200)
      ->json_is([]);

    my $inexisting_borrowernumber = $patron_2->borrowernumber * 2;
    $t->get_ok( "//$userid_1:$password@/api/v1/holds?patron_id=$inexisting_borrowernumber")
      ->status_is(200)
      ->json_is([]);

    $t->delete_ok( "//$userid_3:$password@/api/v1/holds/$reserve_id2" )
      ->status_is(200);

    $t->post_ok( "//$userid_3:$password@/api/v1/holds" => json => $post_data )
      ->status_is(201)
      ->json_has('/hold_id');
    # Get id from response
    $reserve_id = $t->tx->res->json->{hold_id};

    $t->get_ok( "//$userid_1:$password@/api/v1/holds?patron_id=" . $patron_1->borrowernumber )
      ->status_is(200)
      ->json_is('/0/hold_id', $reserve_id)
      ->json_is('/0/expiration_date', output_pref({ dt => $expiration_date, dateformat => 'rfc3339', dateonly => 1 }))
      ->json_is('/0/pickup_library_id', $branchcode);

    $t->post_ok( "//$userid_3:$password@/api/v1/holds" => json => $post_data )
      ->status_is(403)
      ->json_like('/error', qr/itemAlreadyOnHold/);

    $post_data->{biblionumber} = int($biblio_2->biblionumber);
    $post_data->{itemnumber}   = int($item_2->itemnumber);

    $t->post_ok( "//$userid_3:$password@/api/v1/holds" => json => $post_data )
      ->status_is(403)
      ->json_like('/error', qr/itemAlreadyOnHold/);
};

subtest 'Reserves with itemtype' => sub {
    plan tests => 9;

    my $post_data = {
        patron_id => int($patron_1->borrowernumber),
        biblio_id => int($biblio_1->biblionumber),
        pickup_library_id => $branchcode,
        item_type => $itemtype,
    };

    $t->delete_ok( "//$userid_3:$password@/api/v1/holds/$reserve_id" )
      ->status_is(200);

    $t->post_ok( "//$userid_3:$password@/api/v1/holds" => json => $post_data )
      ->status_is(201)
      ->json_has('/hold_id');

    $reserve_id = $t->tx->res->json->{hold_id};

    $t->get_ok( "//$userid_1:$password@/api/v1/holds?patron_id=" . $patron_1->borrowernumber )
      ->status_is(200)
      ->json_is('/0/hold_id', $reserve_id)
      ->json_is('/0/item_type', $itemtype);
};


subtest 'test AllowHoldDateInFuture' => sub {

    plan tests => 6;

    $dbh->do('DELETE FROM reserves');

    my $future_hold_date = DateTime->now->add(days => 10)->truncate( to => 'day' );

    my $post_data = {
        patron_id => int($patron_1->borrowernumber),
        biblio_id => int($biblio_1->biblionumber),
        item_id => int($item_1->itemnumber),
        pickup_library_id => $branchcode,
        expiration_date => output_pref({ dt => $expiration_date, dateformat => 'rfc3339', dateonly => 1 }),
        hold_date => output_pref({ dt => $future_hold_date, dateformat => 'rfc3339', dateonly => 1 }),
        priority => 2,
    };

    t::lib::Mocks::mock_preference( 'AllowHoldDateInFuture', 0 );

    $t->post_ok( "//$userid_3:$password@/api/v1/holds" => json => $post_data )
      ->status_is(400)
      ->json_has('/error');

    t::lib::Mocks::mock_preference( 'AllowHoldDateInFuture', 1 );

    $t->post_ok( "//$userid_3:$password@/api/v1/holds" => json => $post_data )
      ->status_is(201)
      ->json_is('/hold_date', output_pref({ dt => $future_hold_date, dateformat => 'rfc3339', dateonly => 1 }));
};

subtest 'test AllowHoldPolicyOverride' => sub {

    plan tests => 5;

    $dbh->do('DELETE FROM reserves');

    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            itemtype     => undef,
            branchcode   => undef,
            rules        => {
                holdallowed              => 1
            }
        }
    );

    t::lib::Mocks::mock_preference( 'AllowHoldPolicyOverride', 0 );

    $t->post_ok( "//$userid_3:$password@/api/v1/holds" => json => $post_data )
      ->status_is(403)
      ->json_has('/error');

    t::lib::Mocks::mock_preference( 'AllowHoldPolicyOverride', 1 );

    $t->post_ok( "//$userid_3:$password@/api/v1/holds" => json => $post_data )
      ->status_is(201);
};

$schema->storage->txn_rollback;

subtest 'suspend and resume tests' => sub {

    plan tests => 21;

    $schema->storage->txn_begin;

    my $password = 'AbcdEFG123';

    my $patron = $builder->build_object(
        { class => 'Koha::Patrons', value => { userid => 'tomasito', flags => 1 } } );
    $patron->set_password({ password => $password, skip_validation => 1 });
    my $userid = $patron->userid;

    # Disable logging
    t::lib::Mocks::mock_preference( 'HoldsLog',      0 );
    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

    my $hold = $builder->build_object(
        {   class => 'Koha::Holds',
            value => { suspend => 0, suspend_until => undef, waitingdate => undef }
        }
    );

    ok( !$hold->is_suspended, 'Hold is not suspended' );
    $t->post_ok( "//$userid:$password@/api/v1/holds/" . $hold->id . "/suspension" )
        ->status_is( 201, 'Hold suspension created' );

    $hold->discard_changes;    # refresh object

    ok( $hold->is_suspended, 'Hold is suspended' );
    $t->json_is(
        '/end_date',
        output_pref(
            {   dt         => dt_from_string( $hold->suspend_until ),
                dateformat => 'rfc3339',
                dateonly   => 1
            }
        )
    );

    $t->delete_ok( "//$userid:$password@/api/v1/holds/" . $hold->id . "/suspension" )
      ->status_is( 204, "Correct status when deleting a resource" )
      ->json_is( undef );

    # Pass a an expiration date for the suspension
    my $date = dt_from_string()->add( days => 5 );
    $t->post_ok(
              "//$userid:$password@/api/v1/holds/"
            . $hold->id
            . "/suspension" => json => {
            end_date =>
                output_pref( { dt => $date, dateformat => 'rfc3339', dateonly => 1 } )
            }
    )->status_is( 201, 'Hold suspension created' )
        ->json_is( '/end_date',
        output_pref( { dt => $date, dateformat => 'rfc3339', dateonly => 1 } ) )
        ->header_is( Location => "/api/v1/holds/" . $hold->id . "/suspension", 'The Location header is set' );

    $t->delete_ok( "//$userid:$password@/api/v1/holds/" . $hold->id . "/suspension" )
      ->status_is( 204, "Correct status when deleting a resource" )
      ->json_is( undef );

    $hold->set_waiting->discard_changes;

    $t->post_ok( "//$userid:$password@/api/v1/holds/" . $hold->id . "/suspension" )
      ->status_is( 400, 'Cannot suspend waiting hold' )
      ->json_is( '/error', 'Found hold cannot be suspended. Status=W' );

    $hold->set_waiting(1)->discard_changes;

    $t->post_ok( "//$userid:$password@/api/v1/holds/" . $hold->id . "/suspension" )
      ->status_is( 400, 'Cannot suspend waiting hold' )
      ->json_is( '/error', 'Found hold cannot be suspended. Status=T' );

    $schema->storage->txn_rollback;
};

subtest 'PUT /holds/{hold_id}/priority tests' => sub {

    plan tests => 14;

    $schema->storage->txn_begin;

    my $password = 'AbcdEFG123';

    my $library  = $builder->build_object({ class => 'Koha::Libraries' });
    my $patron_np = $builder->build_object(
        { class => 'Koha::Patrons', value => { flags => 0 } } );
    $patron_np->set_password( { password => $password, skip_validation => 1 } );
    my $userid_np = $patron_np->userid;

    my $patron = $builder->build_object(
        { class => 'Koha::Patrons', value => { flags => 0 } } );
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
            $library->branchcode,  $patron_1->borrowernumber,
            $biblio->biblionumber, undef,
            1
        )
    );
    my $hold_2 = Koha::Holds->find(
        AddReserve(
            $library->branchcode,  $patron_2->borrowernumber,
            $biblio->biblionumber, undef,
            2
        )
    );
    my $hold_3 = Koha::Holds->find(
        AddReserve(
            $library->branchcode,  $patron_3->borrowernumber,
            $biblio->biblionumber, undef,
            3
        )
    );

    $t->put_ok( "//$userid_np:$password@/api/v1/holds/"
          . $hold_3->id
          . "/priority" => json => 1 )->status_is(403);

    $t->put_ok( "//$userid:$password@/api/v1/holds/"
          . $hold_3->id
          . "/priority" => json => 1 )->status_is(200)->json_is(1);

    is( $hold_1->discard_changes->priority, 2, 'Priority adjusted correctly' );
    is( $hold_2->discard_changes->priority, 3, 'Priority adjusted correctly' );
    is( $hold_3->discard_changes->priority, 1, 'Priority adjusted correctly' );

    $t->put_ok( "//$userid:$password@/api/v1/holds/"
          . $hold_3->id
          . "/priority" => json => 3 )->status_is(200)->json_is(3);

    is( $hold_1->discard_changes->priority, 1, 'Priority adjusted correctly' );
    is( $hold_2->discard_changes->priority, 2, 'Priority adjusted correctly' );
    is( $hold_3->discard_changes->priority, 3, 'Priority adjusted correctly' );

    $schema->storage->txn_rollback;
};