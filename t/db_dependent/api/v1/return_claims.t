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

use Test::More tests => 4;

use Test::Mojo;
use Test::Warn;
use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Circulation qw( AddIssue );

use Koha::Checkouts::ReturnClaims;
use Koha::Database;
use Koha::DateUtils qw(dt_from_string);

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );
my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'claim_returned() tests' => sub {

    plan tests => 9;

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

    t::lib::Mocks::mock_userenv({ branchcode => $librarian->branchcode });

    my $item  = $builder->build_sample_item;
    my $issue = AddIssue( $patron, $item->barcode, dt_from_string->add( weeks => 2 ) );

    t::lib::Mocks::mock_preference( 'ClaimReturnedChargeFee', 'ask' );
    t::lib::Mocks::mock_preference( 'ClaimReturnedLostValue', '99' );

    ## Valid id
    $t->post_ok(
        "//$userid:$password@/api/v1/return_claims" => json => {
            item_id         => $item->itemnumber,
            charge_lost_fee => Mojo::JSON->false,
            created_by      => $librarian->id,
            notes           => "This is a test note."
        }
    )->status_is(201)->header_like(
        Location => qr|^\/api\/v1\/return_claims/\d*|,
        'SWAGGER3.4.1'
    );

    my $claim_id = $t->tx->res->json->{claim_id};

    ## Duplicate id
    warning_like {
        $t->post_ok(
            "//$userid:$password@/api/v1/return_claims" => json => {
                item_id         => $item->itemnumber,
                charge_lost_fee => Mojo::JSON->false,
                created_by      => $librarian->id,
                notes           => "This is a test note."
            }
        )->status_is(409)
    }
    qr/DBD::mysql::st execute failed: Duplicate entry/;

    $issue->delete;

    $t->post_ok(
        "//$userid:$password@/api/v1/return_claims" => json => {
            item_id         => $item->itemnumber,
            charge_lost_fee => Mojo::JSON->false,
            created_by      => $librarian->id,
            notes           => "This is a test note."
        }
    )->status_is(404)
     ->json_is( '/error' => 'Checkout not found' );

    $schema->storage->txn_rollback;
};

subtest 'update_notes() tests' => sub {

    plan tests => 8;

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

    my $item = $builder->build_sample_item;

    t::lib::Mocks::mock_userenv( { branchcode => $item->homebranch } )
      ;    # needed by AddIssue

    my $issue = AddIssue( $librarian, $item->barcode,
        dt_from_string->add( weeks => 2 ) );

    my $claim = $issue->claim_returned(
        {
            created_by => $librarian->borrowernumber,
            notes      => 'Dummy notes'
        }
    );

    my $claim_id = $claim->id;

    # Test editing a claim note
    ## Valid claim id
    $t->put_ok(
        "//$userid:$password@/api/v1/return_claims/$claim_id/notes" => json => {
            notes      => "This is a different test note.",
            updated_by => $librarian->id,
        }
    )->status_is(200);

    $claim->discard_changes;

    is( $claim->notes,      "This is a different test note." );
    is( $claim->updated_by, $librarian->id );
    ok( $claim->updated_on );

    # Make sure the claim doesn't exist on the DB anymore
    $claim->delete;

    ## Bad claim id
    $t->put_ok(
        "//$userid:$password@/api/v1/return_claims/$claim_id/notes" => json => {
            notes      => "This is a different test note.",
            updated_by => $librarian->id,
        }
    )->status_is(404)
     ->json_is( '/error' => 'Claim not found' );

    $schema->storage->txn_rollback;
};

subtest 'resolve_claim() tests' => sub {

    plan tests => 13;

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

    my $item = $builder->build_sample_item;

    t::lib::Mocks::mock_userenv( { branchcode => $item->homebranch } ); # needed by AddIssue

    # Picking 1 that should exist
    my $ClaimReturnedLostValue = 1;
    t::lib::Mocks::mock_preference('ClaimReturnedLostValue', $ClaimReturnedLostValue);

    my $issue = AddIssue( $librarian, $item->barcode, dt_from_string->add( weeks => 2 ) );

    my $claim = $issue->claim_returned(
        {
            created_by => $librarian->borrowernumber,
            notes      => 'Dummy notes'
        }
    );

    my $claim_id = $claim->id;

    $claim->set(
        {
            created_by => undef,
            updated_by => undef,
        }
    )->store; # resolve the claim must work even if the created_by patron has been removed

    # Resolve a claim
    $t->put_ok(
        "//$userid:$password@/api/v1/return_claims/$claim_id/resolve" => json => {
            resolved_by => $librarian->id,
            resolution  => "FOUNDINLIB",
        }
    )->status_is(200);

    $claim->discard_changes;
    is( $claim->resolution, "FOUNDINLIB" );
    is( $claim->resolved_by, $librarian->id );
    is( $claim->updated_by, $librarian->id );
    ok( $claim->resolved_on );

    is( $claim->checkout->item->itemlost, $ClaimReturnedLostValue );

    $claim->update({resolution => undef, resolved_by => undef, resolved_on => undef });
    $t->put_ok(
        "//$userid:$password@/api/v1/return_claims/$claim_id/resolve" => json => {
            resolved_by => $librarian->id,
            resolution  => "FOUNDINLIB",
            new_lost_status => 0,
        }
    )->status_is(200);
    is( $claim->get_from_storage->checkout->item->itemlost, 0 );


    # Make sure the claim doesn't exist on the DB anymore
    $claim->delete;

    ## Invalid claim id
    $t->put_ok(
        "//$userid:$password@/api/v1/return_claims/$claim_id/resolve" => json =>
        {
            resolved_by => $librarian->id,
            resolution  => "FOUNDINLIB",
        }
    )->status_is(404)
     ->json_is( '/error' => 'Claim not found' );

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 7;

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

    my $item = $builder->build_sample_item;

    t::lib::Mocks::mock_userenv({ branchcode => $item->homebranch });

    my $issue = C4::Circulation::AddIssue( $librarian,
        $item->barcode, dt_from_string->add( weeks => 2 ) );

    my $claim = $issue->claim_returned(
        {
            created_by => $librarian->borrowernumber,
            notes      => 'Dummy notes'
        }
    );

    # Test deleting a return claim
    $t->delete_ok("//$userid:$password@/api/v1/return_claims/" . $claim->id)
      ->status_is( 204, 'SWAGGER3.2.4' )
      ->content_is( '', 'SWAGGER3.3.4' );

    my $THE_claim = Koha::Checkouts::ReturnClaims->find($claim->id);
    isnt( $THE_claim, "Return claim was deleted" );

    $t->delete_ok("//$userid:$password@/api/v1/return_claims/" . $claim->id)
      ->status_is(404)
      ->json_is( '/error' => 'Claim not found' );

    $schema->storage->txn_rollback;
};
