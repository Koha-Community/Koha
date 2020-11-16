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

use Test::More tests => 10;
use Test::MockModule;
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
my $branchcode2 = $builder->build({ source => 'Branch' })->{branchcode};
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

    plan tests => 62;

    $t->get_ok( "//$userid_1:$password@/api/v1/holds" )
      ->status_is(200)
      ->json_has('/0')
      ->json_has('/1')
      ->json_hasnt('/2');

    $t->get_ok( "//$userid_1:$password@/api/v1/holds?priority=2" )
      ->status_is(200)
      ->json_is('/0/patron_id', $patron_2->borrowernumber)
      ->json_hasnt('/1');

    # While suspended_until is date-time, it's always set to midnight.
    my $expected_suspended_until = $suspended_until->strftime('%FT00:00:00%z');
    substr($expected_suspended_until, -2, 0, ':');

    $t->put_ok( "//$userid_1:$password@/api/v1/holds/$reserve_id" => json => $put_data )
      ->status_is(200)
      ->json_is( '/hold_id', $reserve_id )
      ->json_is( '/suspended_until', $expected_suspended_until )
      ->json_is( '/priority', 2 )
      ->json_is( '/pickup_library_id', $branchcode );

    # Change only pickup library, everything else should remain
    $t->put_ok( "//$userid_1:$password@/api/v1/holds/$reserve_id" => json => { pickup_library_id => $branchcode2 } )
      ->status_is(200)
      ->json_is( '/hold_id', $reserve_id )
      ->json_is( '/suspended_until', $expected_suspended_until )
      ->json_is( '/priority', 2 )
      ->json_is( '/pickup_library_id', $branchcode2 );

    # Reset suspended_until, everything else should remain
    $t->put_ok( "//$userid_1:$password@/api/v1/holds/$reserve_id" => json => { suspended_until => undef } )
      ->status_is(200)
      ->json_is( '/hold_id', $reserve_id )
      ->json_is( '/suspended_until', undef )
      ->json_is( '/priority', 2 )
      ->json_is( '/pickup_library_id', $branchcode2 );

    $t->delete_ok( "//$userid_3:$password@/api/v1/holds/$reserve_id" )
      ->status_is(204, 'SWAGGER3.2.4')
      ->content_is('', 'SWAGGER3.3.4');

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
      ->status_is(204, 'SWAGGER3.2.4')
      ->content_is('', 'SWAGGER3.3.4');

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

    my $to_delete_patron  = $builder->build_object({ class => 'Koha::Patrons' });
    my $deleted_patron_id = $to_delete_patron->borrowernumber;
    $to_delete_patron->delete;

    my $tmp_patron_id = $post_data->{patron_id};
    $post_data->{patron_id} = $deleted_patron_id;
    $t->post_ok( "//$userid_3:$password@/api/v1/holds" => json => $post_data )
      ->status_is(400)
      ->json_is( { error => 'patron_id not found' } );

    # Restore the original patron_id as it is expected by the next subtest
    # FIXME: this tests need to be rewritten from scratch
    $post_data->{patron_id} = $tmp_patron_id;
};

subtest 'Reserves with itemtype' => sub {
    plan tests => 10;

    my $post_data = {
        patron_id => int($patron_1->borrowernumber),
        biblio_id => int($biblio_1->biblionumber),
        pickup_library_id => $branchcode,
        item_type => $itemtype,
    };

    $t->delete_ok( "//$userid_3:$password@/api/v1/holds/$reserve_id" )
      ->status_is(204, 'SWAGGER3.2.4')
      ->content_is('', 'SWAGGER3.3.4');

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

    plan tests => 24;

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
            value => { suspend => 0, suspend_until => undef, waitingdate => undef, found => undef }
        }
    );

    ok( !$hold->is_suspended, 'Hold is not suspended' );
    $t->post_ok( "//$userid:$password@/api/v1/holds/" . $hold->id . "/suspension" )
        ->status_is( 201, 'Hold suspension created' );

    $hold->discard_changes;    # refresh object

    ok( $hold->is_suspended, 'Hold is suspended' );
    $t->json_is('/end_date', undef, 'Hold suspension has no end date');

    my $end_date = output_pref({
      dt         => dt_from_string( undef ),
      dateformat => 'rfc3339',
      dateonly   => 1
    });

    $t->post_ok( "//$userid:$password@/api/v1/holds/" . $hold->id . "/suspension" => json => { end_date => $end_date } );

    $hold->discard_changes;    # refresh object

    ok( $hold->is_suspended, 'Hold is suspended' );
    $t->json_is(
      '/end_date',
      output_pref({
        dt         => dt_from_string( $hold->suspend_until ),
        dateformat => 'rfc3339',
        dateonly   => 1
      }),
      'Hold suspension has correct end date'
    );

    $t->delete_ok( "//$userid:$password@/api/v1/holds/" . $hold->id . "/suspension" )
      ->status_is(204, 'SWAGGER3.2.4')
      ->content_is('', 'SWAGGER3.3.4');

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
      ->status_is(204, 'SWAGGER3.2.4')
      ->content_is('', 'SWAGGER3.3.4');

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

subtest 'add() tests (maxreserves behaviour)' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    $dbh->do('DELETE FROM reserves');

    Koha::CirculationRules->new->delete;

    my $password = 'AbcdEFG123';

    my $patron = $builder->build_object(
        { class => 'Koha::Patrons', value => { userid => 'tomasito', flags => 1 } } );
    $patron->set_password({ password => $password, skip_validation => 1 });
    my $userid = $patron->userid;

    Koha::CirculationRules->set_rules(
        {
            itemtype     => undef,
            branchcode   => undef,
            categorycode => undef,
            rules        => {
                reservesallowed => 3
            }
        }
    );

    Koha::CirculationRules->set_rules(
        {
            branchcode   => undef,
            categorycode => $patron->categorycode,
            rules        => {
                max_holds   => 4,
            }
        }
    );

    my $biblio_1 = $builder->build_sample_biblio;
    my $item_1   = $builder->build_sample_item({ biblionumber => $biblio_1->biblionumber });
    my $biblio_2 = $builder->build_sample_biblio;
    my $item_2   = $builder->build_sample_item({ biblionumber => $biblio_2->biblionumber });
    my $biblio_3 = $builder->build_sample_biblio;
    my $item_3   = $builder->build_sample_item({ biblionumber => $biblio_3->biblionumber });

    # Disable logging
    t::lib::Mocks::mock_preference( 'HoldsLog',      0 );
    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );
    t::lib::Mocks::mock_preference( 'maxreserves',   2 );
    t::lib::Mocks::mock_preference( 'AllowHoldPolicyOverride', 0 );

    my $post_data = {
        patron_id => $patron->borrowernumber,
        biblio_id => $biblio_1->biblionumber,
        pickup_library_id => $item_1->home_branch->branchcode,
        item_type => $item_1->itype,
    };

    $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $post_data )
      ->status_is(201);

    $post_data = {
        patron_id => $patron->borrowernumber,
        biblio_id => $biblio_2->biblionumber,
        pickup_library_id => $item_2->home_branch->branchcode,
        item_id   => $item_2->itemnumber
    };

    $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $post_data )
      ->status_is(201);

    $post_data = {
        patron_id => $patron->borrowernumber,
        biblio_id => $biblio_3->biblionumber,
        pickup_library_id => $item_1->home_branch->branchcode,
        item_id   => $item_3->itemnumber
    };

    $t->post_ok( "//$userid:$password@/api/v1/holds" => json => $post_data )
      ->status_is(403)
      ->json_is( { error => 'Hold cannot be placed. Reason: tooManyReserves' } );

    $schema->storage->txn_rollback;
};

subtest 'pickup_locations() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $library_1 = $builder->build_object({ class => 'Koha::Libraries', value => { marcorgcode => 'A' } });
    my $library_2 = $builder->build_object({ class => 'Koha::Libraries', value => { marcorgcode => 'B' } });
    my $library_3 = $builder->build_object({ class => 'Koha::Libraries', value => { marcorgcode => 'C' } });

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { userid => 'tomasito', flags => 1 }
        }
    );
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    my $item_class = Test::MockModule->new('Koha::Item');
    $item_class->mock(
        'pickup_locations',
        sub {
            my ( $self, $params ) = @_;
            my $mock_patron = $params->{patron};
            is( $mock_patron->borrowernumber,
                $patron->borrowernumber, 'Patron passed correctly' );
            return Koha::Libraries->search(
                {
                    branchcode => {
                        '-in' => [
                            $library_1->branchcode,
                            $library_2->branchcode
                        ]
                    }
                },
                {   # we make sure no surprises in the order of the result
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
            is( $mock_patron->borrowernumber,
                $patron->borrowernumber, 'Patron passed correctly' );
            return Koha::Libraries->search(
                {
                    branchcode => {
                        '-in' => [
                            $library_2->branchcode,
                            $library_3->branchcode
                        ]
                    }
                },
                {   # we make sure no surprises in the order of the result
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

    $t->get_ok( "//$userid:$password@/api/v1/holds/"
          . $hold_1->id
          . "/pickup_locations" )
      ->json_is( [ $library_2->to_api, $library_3->to_api ] );

    $t->get_ok( "//$userid:$password@/api/v1/holds/"
          . $hold_2->id
          . "/pickup_locations" )
      ->json_is( [ $library_1->to_api, $library_2->to_api ] );

    $schema->storage->txn_rollback;
};
