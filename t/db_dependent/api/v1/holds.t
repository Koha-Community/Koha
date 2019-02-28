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

use Test::More tests => 5;
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

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

$schema->storage->txn_begin;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

$ENV{REMOTE_ADDR} = '127.0.0.1';
my $t = Test::Mojo->new('Koha::REST::V1');
my $tx;

my $categorycode = $builder->build({ source => 'Category' })->{categorycode};
my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};
my $itemtype = $builder->build({ source => 'Itemtype' })->{itemtype};

# User without any permissions
my $nopermission = $builder->build({
    source => 'Borrower',
    value => {
        branchcode   => $branchcode,
        categorycode => $categorycode,
        flags        => 0
    }
});
my $session_nopermission = C4::Auth::get_session('');
$session_nopermission->param('number', $nopermission->{ borrowernumber });
$session_nopermission->param('id', $nopermission->{ userid });
$session_nopermission->param('ip', '127.0.0.1');
$session_nopermission->param('lasttime', time());
$session_nopermission->flush;

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

# Get sessions
my $session = C4::Auth::get_session('');
$session->param('number', $patron_1->borrowernumber);
$session->param('id', $patron_1->userid);
$session->param('ip', '127.0.0.1');
$session->param('lasttime', time());
$session->flush;
my $session2 = C4::Auth::get_session('');
$session2->param('number', $patron_2->borrowernumber);
$session2->param('id', $patron_2->userid);
$session2->param('ip', '127.0.0.1');
$session2->param('lasttime', time());
$session2->flush;
my $session3 = C4::Auth::get_session('');
$session3->param('number', $patron_3->borrowernumber);
$session3->param('id', $patron_3->userid);
$session3->param('ip', '127.0.0.1');
$session3->param('lasttime', time());
$session3->flush;

my $biblionumber = create_biblio('RESTful Web APIs');
my $item = create_item($biblionumber, 'TEST000001');
my $itemnumber = $item->{itemnumber};
$item->{itype} = $itemtype;
C4::Items::ModItem($item, $biblionumber, $itemnumber);

my $biblionumber2 = create_biblio('RESTful Web APIs');
my $item2 = create_item($biblionumber2, 'TEST000002');
my $itemnumber2 = $item2->{itemnumber};

my $dbh = C4::Context->dbh;
$dbh->do('DELETE FROM reserves');
$dbh->do('DELETE FROM issuingrules');
    $dbh->do(q{
        INSERT INTO issuingrules (categorycode, branchcode, itemtype, reservesallowed)
        VALUES (?, ?, ?, ?)
    }, {}, '*', '*', '*', 1);

my $reserve_id = C4::Reserves::AddReserve($branchcode, $patron_1->borrowernumber,
    $biblionumber, undef, 1, undef, undef, undef, '', $itemnumber);

# Add another reserve to be able to change first reserve's rank
my $reserve_id2 = C4::Reserves::AddReserve($branchcode, $patron_2->borrowernumber,
    $biblionumber, undef, 2, undef, undef, undef, '', $itemnumber);

my $suspended_until = DateTime->now->add(days => 10)->truncate( to => 'day' );
my $expiration_date = DateTime->now->add(days => 10)->truncate( to => 'day' );

my $post_data = {
    patron_id => int($patron_1->borrowernumber),
    biblio_id => int($biblionumber),
    item_id => int($itemnumber),
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

    $tx = $t->ua->build_tx(GET => "/api/v1/holds?patron_id=" . $patron_1->borrowernumber);
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx) # no permission
      ->status_is(403);
    $tx = $t->ua->build_tx(GET => "/api/v1/holds?patron_id=" . $patron_1->borrowernumber);
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx) # reserveforothers permission
      ->status_is(403);
    $tx = $t->ua->build_tx(POST => "/api/v1/holds" => json => $post_data );
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx) # no permission
      ->status_is(403);
    $tx = $t->ua->build_tx(PUT => "/api/v1/holds/0" => json => $put_data );
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx) # no permission
      ->status_is(403);
    $tx = $t->ua->build_tx(DELETE => "/api/v1/holds/0");
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx) # no permission
      ->status_is(403);
};

subtest "Test endpoints with permission" => sub {

    plan tests => 44;

    $tx = $t->ua->build_tx(GET => '/api/v1/holds');
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_has('/0')
      ->json_has('/1')
      ->json_hasnt('/2');

    $tx = $t->ua->build_tx(GET => '/api/v1/holds?priority=2');
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/0/patron_id', $patron_2->borrowernumber)
      ->json_hasnt('/1');

    $tx = $t->ua->build_tx(PUT => "/api/v1/holds/$reserve_id" => json => $put_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is( '/hold_id', $reserve_id )
      ->json_is( '/suspended_until', output_pref({ dt => $suspended_until, dateformat => 'rfc3339' }) )
      ->json_is( '/priority', 2 );

    $tx = $t->ua->build_tx(DELETE => "/api/v1/holds/$reserve_id");
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(200);

    $tx = $t->ua->build_tx(PUT => "/api/v1/holds/$reserve_id" => json => $put_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(404)
      ->json_has('/error');

    $tx = $t->ua->build_tx(DELETE => "/api/v1/holds/$reserve_id");
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(404)
      ->json_has('/error');

    $tx = $t->ua->build_tx(GET => "/api/v1/holds?patron_id=" . $patron_1->borrowernumber);
    $tx->req->cookies({name => 'CGISESSID', value => $session2->id}); # get with borrowers flag
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is([]);

    my $inexisting_borrowernumber = $patron_2->borrowernumber * 2;
    $tx = $t->ua->build_tx(GET => "/api/v1/holds?patron_id=$inexisting_borrowernumber");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is([]);

    $tx = $t->ua->build_tx(DELETE => "/api/v1/holds/$reserve_id2");
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(200);

    $tx = $t->ua->build_tx(POST => "/api/v1/holds" => json => $post_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(201)
      ->json_has('/hold_id');
    $reserve_id = $t->tx->res->json->{hold_id};

    $tx = $t->ua->build_tx(GET => "/api/v1/holds?patron_id=" . $patron_1->borrowernumber);
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/0/hold_id', $reserve_id)
      ->json_is('/0/expiration_date', output_pref({ dt => $expiration_date, dateformat => 'rfc3339', dateonly => 1 }))
      ->json_is('/0/pickup_library_id', $branchcode);

    $tx = $t->ua->build_tx(POST => "/api/v1/holds" => json => $post_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(403)
      ->json_like('/error', qr/itemAlreadyOnHold/);

    $post_data->{biblionumber} = int($biblionumber2);
    $post_data->{itemnumber} = int($itemnumber2);
    $tx = $t->ua->build_tx(POST => "/api/v1/holds" => json => $post_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(403)
      ->json_like('/error', qr/itemAlreadyOnHold/);
};

subtest 'Reserves with itemtype' => sub {
    plan tests => 9;

    my $post_data = {
        patron_id => int($patron_1->borrowernumber),
        biblio_id => int($biblionumber),
        pickup_library_id => $branchcode,
        item_type => $itemtype,
    };

    $tx = $t->ua->build_tx(DELETE => "/api/v1/holds/$reserve_id");
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(200);

    $tx = $t->ua->build_tx(POST => "/api/v1/holds" => json => $post_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(201)
      ->json_has('/hold_id');

    $reserve_id = $t->tx->res->json->{hold_id};

    $tx = $t->ua->build_tx(GET => "/api/v1/holds?patron_id=" . $patron_1->borrowernumber);
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/0/hold_id', $reserve_id)
      ->json_is('/0/item_type', $itemtype);
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

sub create_biblio {
    my ($title) = @_;

    my $biblio = Koha::Biblio->new( { title => $title } )->store;
    my $biblioitem = Koha::Biblioitem->new({biblionumber => $biblio->biblionumber})->store;

    return $biblio->biblionumber;
}

sub create_item {
    my ( $biblionumber, $barcode ) = @_;

    Koha::Items->search( { barcode => $barcode } )->delete;
    my $builder = t::lib::TestBuilder->new;
    my $item    = $builder->build(
        {
            source => 'Item',
            value  => {
                biblionumber     => $biblionumber,
                barcode          => $barcode,
            }
        }
    );

    return $item;
}
