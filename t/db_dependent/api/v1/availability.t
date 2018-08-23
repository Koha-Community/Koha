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

use Test::More tests => 2;
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Auth;
use Koha::Biblio::Availability;
use Koha::Item::Availability;
use Koha::Database;

require t::db_dependent::Koha::Availability::Helpers;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

subtest '/availability/biblio' => sub {
    plan tests => 2;

    subtest '/hold' => sub {
        plan tests => 34;

        $schema->storage->txn_begin;

        set_default_circulation_rules();
        set_default_system_preferences();

        my $item = build_a_test_item();
        my $item2 = build_a_test_item(
            scalar Koha::Biblios->find($item->biblionumber),
            scalar Koha::Biblioitems->find($item->biblioitemnumber)
        );
        my $item3 = build_a_test_item();

        my ($patron, $session_id) = create_user_and_session();
        $patron = Koha::Patrons->find($patron);
        my $route = '/api/v1/availability/biblio/hold';
        my $tx = $t->ua->build_tx( GET => $route . '?biblionumber='.$item->biblionumber );
        $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(200)
          ->json_has('/0/availability')
          ->json_is('/0/availability/available' => Mojo::JSON->true)
          ->json_is('/0/item_availabilities/0/availability/available' => Mojo::JSON->true)
          ->json_is('/0/item_availabilities/1/availability/available' => Mojo::JSON->true)
          ->json_is('/0/hold_queue_length' => 0);

        C4::Reserves::AddReserve($patron->branchcode, $patron->borrowernumber,
                                 $item3->biblionumber);
        $tx = $t->ua->build_tx( GET => $route . '?biblionumber='.$item3->biblionumber );
        $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(200)
          ->json_is('/0/hold_queue_length' => 1);

        $tx = $t->ua->build_tx( GET => $route . '?biblionumber='.$item->biblionumber.'&limit_items=1' );
        $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(200)
          ->json_has('/0/availability')
          ->json_has('/0/item_availabilities/0')
          ->json_hasnt('/0/item_availabilities/1');

        $patron->gonenoaddress('1')->store;
        $item2->notforloan('1')->store;
        $tx = $t->ua->build_tx( GET => $route . '?biblionumber='.$item->biblionumber );
        $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(200)
          ->json_has('/0/availability')
          ->json_is('/0/availability/available' => Mojo::JSON->false)
          ->json_is('/0/availability/unavailabilities/Patron::GoneNoAddress' => {})
          ->json_is('/0/item_availabilities/0/itemnumber' => $item->itemnumber)
          ->json_is('/0/item_availabilities/0/availability/available' => Mojo::JSON->true)
          ->json_is('/0/item_availabilities/1/itemnumber' => $item2->itemnumber)
          ->json_is('/0/item_availabilities/1/availability/available' => Mojo::JSON->false)
          ->json_is('/0/item_availabilities/1/availability/unavailabilities/Item::NotForLoan' => {
            code => "Not For Loan",
            status => 1,
            });
        $patron->gonenoaddress('0')->store;
        $item2->notforloan('0')->store;

        my $patron2 = build_a_test_patron();
        $tx = $t->ua->build_tx( GET => $route . '?biblionumber='.$item->biblionumber.'&borrowernumber='.$patron2->borrowernumber );
        $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(403);

        my $branch = Koha::Libraries->find(
        $builder->build({ source => 'Branch' })->{'branchcode'});
        t::lib::Mocks::mock_preference('UseBranchTransferLimits', 1);
        t::lib::Mocks::mock_preference('BranchTransferLimitsType', 'itemtype');
        C4::Circulation::CreateBranchTransferLimit(
            $branch->branchcode,
            $item->holdingbranch,
            $item->effective_itemtype
        );

        $tx = $t->ua->build_tx( GET => $route . '?biblionumber='.$item->biblionumber.'&branchcode='.$branch->branchcode );
        $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(200)
          ->json_has('/0/availability')
          ->json_is('/0/availability/available' => Mojo::JSON->true)
          ->json_is('/0/item_availabilities/0/availability/available' => Mojo::JSON->true)
          ->json_is('/0/item_availabilities/1/availability/available' => Mojo::JSON->false)
          ->json_is('/0/item_availabilities/1/availability/unavailabilities/Item::CannotBeTransferred' => {
                from_library => $item->holdingbranch,
                to_library => $branch->branchcode,});

        $schema->storage->txn_rollback;
    };

    subtest '/search' => sub {
        plan tests => 21;

        $schema->storage->txn_begin;

        set_default_circulation_rules();
        set_default_system_preferences();

        my ($patron, $session_id) = create_user_and_session();
        $patron = Koha::Patrons->find($patron);

        my $item = build_a_test_item();
        my $item2 = build_a_test_item(
            scalar Koha::Biblios->find($item->biblionumber),
            scalar Koha::Biblioitems->find($item->biblioitemnumber)
        );
        my $item3 = build_a_test_item(
            scalar Koha::Biblios->find($item->biblionumber),
            scalar Koha::Biblioitems->find($item->biblioitemnumber)
        );
        my $route = '/api/v1/availability/biblio/search';
        my $tx = $t->ua->build_tx( GET => $route . '?biblionumber='.$item->biblionumber );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(200)
          ->json_has('/0/availability')
          ->json_is('/0/availability/available' => Mojo::JSON->true)
          ->json_is('/0/item_availabilities/0/availability/available' => Mojo::JSON->true)
          ->json_is('/0/item_availabilities/1/availability/available' => Mojo::JSON->true)
          ->json_is('/0/hold_queue_length' => 0);

        C4::Reserves::AddReserve($patron->branchcode, $patron->borrowernumber,
                                 $item3->biblionumber);
        C4::Reserves::AddReserve($patron->branchcode, $patron->borrowernumber,
                                 $item3->biblionumber);

        $item2->notforloan('1')->store;
        $tx = $t->ua->build_tx( GET => $route . '?biblionumber='.$item->biblionumber );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(200)
          ->json_has('/0/availability')
          ->json_is('/0/availability/available' => Mojo::JSON->false)
          ->json_is('/0/item_availabilities/0/itemnumber' => $item->itemnumber)
          ->json_is('/0/item_availabilities/0/availability/available' => Mojo::JSON->false)
          ->json_is('/0/item_availabilities/2/itemnumber' => $item3->itemnumber)
          ->json_is('/0/item_availabilities/2/availability/available' => Mojo::JSON->false)
          ->json_is('/0/item_availabilities/1/itemnumber' => $item2->itemnumber)
          ->json_is('/0/item_availabilities/1/availability/available' => Mojo::JSON->false)
          ->json_is('/0/hold_queue_length' => 2)
          ->json_is('/0/item_availabilities/0/availability/unavailabilities/Item::Held' => {
                borrowernumber => $patron->borrowernumber
            })
          ->json_is('/0/item_availabilities/1/availability/unavailabilities/Item::NotForLoan' => {
            code => "Not For Loan",
            status => 1,
            })
          ->json_is('/0/item_availabilities/2/availability/unavailabilities/Item::Held' => {
                borrowernumber => $patron->borrowernumber
            });

        $schema->storage->txn_rollback;
    };
};

subtest '/availability/item' => sub {
    plan tests => 3;

    subtest '/hold' => sub {
        plan tests => 21;

        $schema->storage->txn_begin;

        set_default_circulation_rules();
        set_default_system_preferences();

        my $item = build_a_test_item();
        my ($patron, $session_id) = create_user_and_session();
        $patron = Koha::Patrons->find($patron);
        my $route = '/api/v1/availability/item/hold';
        my $tx = $t->ua->build_tx( GET => $route . '?itemnumber='.$item->itemnumber );
        $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(200)
          ->json_has('/0/availability')
          ->json_is('/0/availability/available' => Mojo::JSON->true);

        C4::Reserves::AddReserve($patron->branchcode, $patron->borrowernumber,
            $item->biblionumber, undef, undef, undef, undef, undef, undef,
            $item->itemnumber);

        $patron->gonenoaddress('1')->store;
        $item->notforloan('1')->store;
        $tx = $t->ua->build_tx( GET => $route . '?itemnumber='.$item->itemnumber );
        $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(200)
          ->json_has('/0/availability')
          ->json_is('/0/availability/available' => Mojo::JSON->false)
          ->json_is('/0/itemnumber' => $item->itemnumber)
          ->json_is('/0/hold_queue_length' => 1)
          ->json_is('/0/ccode' => $item->ccode)
          ->json_is('/0/sub_location' => $item->sub_location)
          ->json_is('/0/itemcallnumber_display' => $item->cn_sort)
          ->json_is('/0/availability/unavailabilities/Patron::GoneNoAddress' => {})
          ->json_is('/0/availability/unavailabilities/Item::NotForLoan' => {
            code => "Not For Loan",
            status => 1,
            });
        $patron->gonenoaddress('0')->store;
        $item->notforloan('0')->store;

        my $patron2 = build_a_test_patron();
        $tx = $t->ua->build_tx( GET => $route . '?itemnumber='.$item->itemnumber.'&borrowernumber='.$patron2->borrowernumber );
        $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(403);

        my $branch = Koha::Libraries->find(
        $builder->build({ source => 'Branch' })->{'branchcode'});
        t::lib::Mocks::mock_preference('UseBranchTransferLimits', 1);
        t::lib::Mocks::mock_preference('BranchTransferLimitsType', 'itemtype');
        C4::Circulation::CreateBranchTransferLimit(
            $branch->branchcode,
            $item->holdingbranch,
            $item->effective_itemtype
        );

        $tx = $t->ua->build_tx( GET => $route . '?itemnumber='.$item->itemnumber.'&branchcode='.$branch->branchcode );
        $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(200)
          ->json_is('/0/availability/available' => Mojo::JSON->false)
          ->json_is('/0/availability/unavailabilities/Item::CannotBeTransferred' => {
                from_library => $item->holdingbranch,
                to_library => $branch->branchcode,});

        $schema->storage->txn_rollback;
    };

    subtest '/checkout' => sub {
        plan tests => 12;

        $schema->storage->txn_begin;

        set_default_circulation_rules();
        set_default_system_preferences();

        my $item = build_a_test_item();
        my ($patron, $session_id) = create_user_and_session();
        $patron = Koha::Patrons->find($patron);
        my $route = '/api/v1/availability/item/checkout';
        my $tx = $t->ua->build_tx( GET => $route . '?itemnumber='.$item->itemnumber );
        $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(200)
          ->json_has('/0/availability')
          ->json_is('/0/availability/available' => Mojo::JSON->true);

        $item->notforloan('1')->store;
        $tx = $t->ua->build_tx( GET => $route . '?itemnumber='.$item->itemnumber );
        $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(200)
          ->json_has('/0/availability')
          ->json_is('/0/availability/available' => Mojo::JSON->false)
          ->json_is('/0/itemnumber' => $item->itemnumber)
          ->json_is('/0/availability/unavailabilities/Item::NotForLoan' => {
            code => "Not For Loan",
            status => 1,
            });
        $item->notforloan('0')->store;

        my $patron2 = build_a_test_patron();
        $tx = $t->ua->build_tx( GET => $route . '?itemnumber='.$item->itemnumber.'&borrowernumber='.$patron2->borrowernumber );
        $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(403);

        $schema->storage->txn_rollback;
    };

    subtest '/search' => sub {
        plan tests => 15;

        $schema->storage->txn_begin;

        set_default_circulation_rules();
        set_default_system_preferences();

        my $item = build_a_test_item();
        my $item2 = build_a_test_item(
            scalar Koha::Biblios->find($item->biblionumber),
            scalar Koha::Biblioitems->find($item->biblioitemnumber)
        );
        my $route = '/api/v1/availability/biblio/search';
        my $tx = $t->ua->build_tx( GET => $route . '?biblionumber='.$item->biblionumber );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(200)
          ->json_has('/0/availability')
          ->json_is('/0/availability/available' => Mojo::JSON->true)
          ->json_is('/0/item_availabilities/0/availability/available' => Mojo::JSON->true)
          ->json_is('/0/item_availabilities/1/availability/available' => Mojo::JSON->true);

        $item2->notforloan('1')->store;
        $tx = $t->ua->build_tx( GET => $route . '?biblionumber='.$item->biblionumber );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(200)
          ->json_has('/0/availability')
          ->json_is('/0/availability/available' => Mojo::JSON->true)
          ->json_is('/0/item_availabilities/0/itemnumber' => $item->itemnumber)
          ->json_is('/0/item_availabilities/0/availability/available' => Mojo::JSON->true)
          ->json_is('/0/item_availabilities/1/itemnumber' => $item2->itemnumber)
          ->json_is('/0/item_availabilities/1/availability/available' => Mojo::JSON->false)
          ->json_is('/0/item_availabilities/1/availability/unavailabilities/Item::NotForLoan' => {
            code => "Not For Loan",
            status => 1,
            });

        $schema->storage->txn_rollback;
    };
};

sub create_user_and_session {

    my $args  = shift;
    my $flags = ( $args->{authorized} ) ? $args->{authorized} : 0;
    my $dbh   = C4::Context->dbh;

    my $user = $builder->build(
        {
            source => 'Borrower',
            value  => {
                flags => $flags,
                debarred => undef,
                debarredcomment => undef,
                lost => undef,
                gonenoaddress => undef,
                dateexpiry => output_pref({ dt => dt_from_string()->add_duration( # expires in 100 days
                              DateTime::Duration->new(days => 100)), dateformat => 'iso', dateonly => 1 }),
                dateofbirth => '1950-10-10',
            }
        }
    );

    # Create a session for the authorized user
    my $session = t::lib::Mocks::mock_session({borrower => $user});

    if ( $args->{authorized} ) {
        $dbh->do( "
            INSERT INTO user_permissions (borrowernumber,module_bit,code)
            VALUES (?,3,'parameters_remaining_permissions')", undef,
            $user->{borrowernumber} );
    }

    return ( $user->{borrowernumber}, $session->id );
}

1;
