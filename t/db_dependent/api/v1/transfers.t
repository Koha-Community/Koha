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
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Item::Transfers;
use Koha::Recalls;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 19;

    $schema->storage->txn_begin;

    Koha::Item::Transfers->search->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**1 }    # circulate flag = 1
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
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/transfers")->status_is(403);

    # No transfers, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/transfers")->status_is(200)->json_is( [] );

    my $library_a = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_b = $builder->build_object( { class => 'Koha::Libraries' } );

    my $item_0     = $builder->build_sample_item;
    my $transfer_0 = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                itemnumber => $item_0->itemnumber,
                tobranch   => $library_a->branchcode
            }
        }
    );

    # One transfer
    $t->get_ok("//$userid:$password@/api/v1/transfers")->status_is(200)->json_is( [ $transfer_0->to_api ] );

    my $item_1     = $builder->build_sample_item;
    my $transfer_1 = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                itemnumber => $item_1->itemnumber,
                tobranch   => $library_b->branchcode
            }
        }
    );

    # Filtering by destination library
    $t->get_ok( "//$userid:$password@/api/v1/transfers?to_library_id=" . $library_a->branchcode )
        ->status_is(200)
        ->json_is( '' => [ $transfer_0->to_api ], 'filtering by to_library_id returns the matching transfer' );

    # Embeds resolve through the item
    $t->get_ok( "//$userid:$password@/api/v1/transfers?to_library_id="
            . $library_a->branchcode => { 'x-koha-embed' => 'item.biblio,from_library' } )
        ->status_is(200)
        ->json_is( '/0/item/item_id'            => $item_0->itemnumber )
        ->json_is( '/0/item/biblio/title'       => $item_0->biblio->title )
        ->json_is( '/0/from_library/library_id' => $transfer_0->frombranch );

    # Warn on unsupported query parameter
    $t->get_ok("//$userid:$password@/api/v1/transfers?transfer_blah=blah")
        ->status_is(400)
        ->json_is( [ { path => '/query/transfer_blah', message => 'Malformed query string' } ] );

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 14;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**1 }    # circulate flag = 1
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
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    my $item     = $builder->build_sample_item;
    my $transfer = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                itemnumber    => $item->itemnumber,
                datesent      => \'NOW()',            # in transit
                datearrived   => undef,
                datecancelled => undef,
            }
        }
    );

    # Unauthorized access
    $t->delete_ok(
        "//$unauth_userid:$password@/api/v1/transfers/" . $transfer->id => json => { cancellation_reason => 'Manual' } )
        ->status_is(403);

    # A cancellation reason is mandatory
    $t->delete_ok( "//$userid:$password@/api/v1/transfers/" . $transfer->id )->status_is(400);

    # Not found
    $t->delete_ok( "//$userid:$password@/api/v1/transfers/"
            . ( $transfer->id + 1000 ) => json => { cancellation_reason => 'Manual' } )->status_is(404);

    # Cannot cancel an already-received transfer
    my $arrived_item     = $builder->build_sample_item;
    my $arrived_transfer = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                itemnumber    => $arrived_item->itemnumber,
                datesent      => \'NOW()',
                datearrived   => \'NOW()',
                datecancelled => undef,
            }
        }
    );
    $t->delete_ok(
        "//$userid:$password@/api/v1/transfers/" . $arrived_transfer->id => json =>
            { cancellation_reason => 'Manual' } )->status_is(400);

    # Cancel an in-transit transfer with the supplied reason
    $t->delete_ok(
        "//$userid:$password@/api/v1/transfers/" . $transfer->id => json => { cancellation_reason => 'WrongTransfer' } )
        ->status_is(204);

    $transfer->discard_changes;
    ok( defined $transfer->datecancelled, 'The transfer has been cancelled' );
    is( $transfer->cancellation_reason, 'WrongTransfer', 'The supplied cancellation reason is recorded' );

    # Cannot cancel an already-cancelled transfer
    $t->delete_ok(
        "//$userid:$password@/api/v1/transfers/" . $transfer->id => json => { cancellation_reason => 'Manual' } )
        ->status_is(400);

    $schema->storage->txn_rollback;
};

subtest 'delete() - UseRecalls integration' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'UseRecalls', 1 );

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**1 }    # circulate flag = 1
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $item     = $builder->build_sample_item;
    my $transfer = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                itemnumber    => $item->itemnumber,
                datesent      => \'NOW()',
                datearrived   => undef,
                datecancelled => undef,
            }
        }
    );

    my $recall = $builder->build_object(
        {
            class => 'Koha::Recalls',
            value => {
                item_id => $item->itemnumber,
                status  => 'in_transit',
            }
        }
    );

    $t->delete_ok(
        "//$userid:$password@/api/v1/transfers/" . $transfer->id => json => { cancellation_reason => 'Manual' } )
        ->status_is(204);

    $recall->discard_changes;
    is( $recall->status, 'requested', 'The in-transit recall was reverted when the transfer was cancelled' );

    $schema->storage->txn_rollback;
};
