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

use Test::More tests => 32;
use Test::MockModule;
use Test::Mojo;
use Test::Warn;
use t::lib::Mocks;
use t::lib::TestBuilder;

use DateTime;

use C4::Context;
use C4::Circulation;

use Koha::Checkouts::ReturnClaims;
use Koha::Database;
use Koha::DateUtils;

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );
my $t = Test::Mojo->new('Koha::REST::V1');

$schema->storage->txn_begin;

my $dbh = C4::Context->dbh;

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
my $unauth_password = 'thePassword000';
$patron->set_password(
    { password => $unauth_password, skip_validattion => 1 } );
my $unauth_userid = $patron->userid;
my $patron_id     = $patron->borrowernumber;

my $branchcode = $builder->build( { source => 'Branch' } )->{branchcode};
my $module     = new Test::MockModule('C4::Context');
$module->mock( 'userenv', sub { { branch => $branchcode } } );

my $item1       = $builder->build_sample_item;
my $itemnumber1 = $item1->itemnumber;

my $date_due = DateTime->now->add( weeks => 2 );
my $issue1 =
  C4::Circulation::AddIssue( $patron->unblessed, $item1->barcode, $date_due );

t::lib::Mocks::mock_preference( 'ClaimReturnedChargeFee', 'ask' );
t::lib::Mocks::mock_preference( 'ClaimReturnedLostValue', '99' );

# Test creating a return claim
## Invalid id
$t->post_ok(
    "//$userid:$password@/api/v1/return_claims" => json => {
        item_id         => 1,
        charge_lost_fee => Mojo::JSON->false,
        created_by      => $librarian->id,
        notes           => "This is a test note."
    }
)->status_is(404)
 ->json_is( '/error' => 'Checkout not found' );

## Valid id
$t->post_ok(
    "//$userid:$password@/api/v1/return_claims" => json => {
        item_id         => $itemnumber1,
        charge_lost_fee => Mojo::JSON->false,
        created_by      => $librarian->id,
        notes           => "This is a test note."
    }
)->status_is(201)
 ->header_like( Location => qr|^\/api\/v1\/return_claims/\d*|, 'SWAGGER3.4.1');

my $claim_id = $t->tx->res->json->{claim_id};

## Duplicate id
warning_like {
        $t->post_ok(
            "//$userid:$password@/api/v1/return_claims" => json => {
                item_id         => $itemnumber1,
                charge_lost_fee => Mojo::JSON->false,
                created_by      => $librarian->id,
                notes           => "This is a test note."
            }
        )->status_is(409)
    }
    qr/^DBD::mysql::st execute failed: Duplicate entry/;

# Test editing a claim note
## Valid claim id
$t->put_ok(
    "//$userid:$password@/api/v1/return_claims/$claim_id/notes" => json => {
        notes      => "This is a different test note.",
        updated_by => $librarian->id,
    }
)->status_is(200);
my $claim = Koha::Checkouts::ReturnClaims->find($claim_id);
is( $claim->notes,      "This is a different test note." );
is( $claim->updated_by, $librarian->id );
ok( $claim->updated_on );

## Bad claim id
$t->put_ok(
    "//$userid:$password@/api/v1/return_claims/99999999999/notes" => json => {
        notes      => "This is a different test note.",
        updated_by => $librarian->id,
    }
)->status_is(404)
 ->json_is( '/error' => 'Claim not found' );

# Resolve a claim
## Valid claim id
$t->put_ok(
    "//$userid:$password@/api/v1/return_claims/$claim_id/resolve" => json => {
        resolved_by => $librarian->id,
        resolution  => "FOUNDINLIB",
    }
)->status_is(200);
$claim = Koha::Checkouts::ReturnClaims->find($claim_id);
is( $claim->resolution, "FOUNDINLIB" );
is( $claim->updated_by, $librarian->id );
ok( $claim->resolved_on );

## Invalid claim id
$t->put_ok(
    "//$userid:$password@/api/v1/return_claims/999999999999/resolve" => json => {
        resolved_by => $librarian->id,
        resolution  => "FOUNDINLIB",
    }
)->status_is(404)
 ->json_is( '/error' => 'Claim not found' );

# Test deleting a return claim
$t->delete_ok("//$userid:$password@/api/v1/return_claims/$claim_id")
  ->status_is( 204, 'SWAGGER3.2.4' )
  ->content_is( '', 'SWAGGER3.3.4' );
$claim = Koha::Checkouts::ReturnClaims->find($claim_id);
isnt( $claim, "Return claim was deleted" );

$t->delete_ok("//$userid:$password@/api/v1/return_claims/$claim_id")
  ->status_is(404)
  ->json_is( '/error' => 'Claim not found' );
