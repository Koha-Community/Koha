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

use Test::More tests => 1;
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Auth;
use Koha::StockRotationStages;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

subtest 'move() tests' => sub {

    plan tests => 16;

    $schema->storage->txn_begin;

    my ( $unauthorized_borrowernumber, $unauthorized_session_id ) =
      create_user_and_session( { authorized => 0 } );
    my ( $authorized_borrowernumber, $authorized_session_id ) =
      create_user_and_session( { authorized => 1 } );

    my $library1 = $builder->build({ source => 'Branch' });
    my $library2 = $builder->build({ source => 'Branch' });
    my $rota = $builder->build({ source => 'Stockrotationrota' });
    my $stage1 = $builder->build({
        source => 'Stockrotationstage',
        value  => {
            branchcode_id => $library1->{branchcode},
            rota_id       => $rota->{rota_id},
        }
    });
    my $stage2 = $builder->build({
        source => 'Stockrotationstage',
        value  => {
            branchcode_id => $library2->{branchcode},
            rota_id       => $rota->{rota_id},
        }
    });
    my $rota_id = $rota->{rota_id};
    my $stage1_id = $stage1->{stage_id};

    # Unauthorized attempt to update
    my $tx = $t->ua->build_tx(
      PUT => "/api/v1/rotas/$rota_id/stages/$stage1_id/position" =>
      json => 2
    );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $unauthorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(403);

    # Invalid attempt to move a stage on a non-existant rota
    $tx = $t->ua->build_tx(
      PUT => "/api/v1/rotas/99999999/stages/$stage1_id/position" =>
      json => 2
    );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(404)
      ->json_is( '/error' => "Not found - Invalid rota or stage ID" );

    # Invalid attempt to move an non-existant stage
    $tx = $t->ua->build_tx(
      PUT => "/api/v1/rotas/$rota_id/stages/999999999/position" =>
      json => 2
    );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(404)
      ->json_is( '/error' => "Not found - Invalid rota or stage ID" );

    # Invalid attempt to move stage to current position
    my $curr_position = $stage1->{position};
    $tx = $t->ua->build_tx(
      PUT => "/api/v1/rotas/$rota_id/stages/$stage1_id/position" =>
      json => $curr_position
    );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(400)
      ->json_is( '/error' => "Bad request - new position invalid" );

    # Invalid attempt to move stage to invalid position
    $tx = $t->ua->build_tx(
      PUT => "/api/v1/rotas/$rota_id/stages/$stage1_id/position" =>
      json => 99999999
    );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(400)
      ->json_is( '/error' => "Bad request - new position invalid" );

    # Valid, authorised move
    $tx = $t->ua->build_tx(
      PUT => "/api/v1/rotas/$rota_id/stages/$stage1_id/position" =>
      json => 2
    );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(200);

    $schema->storage->txn_rollback;
};

sub create_user_and_session {

    my $args  = shift;
    my $flags = ( $args->{authorized} ) ? $args->{authorized} : 0;
    my $dbh   = C4::Context->dbh;

    my $user = $builder->build(
        {
            source => 'Borrower',
            value  => {
                flags => $flags
            }
        }
    );

    # Create a session for the authorized user
    my $session = C4::Auth::get_session('');
    $session->param( 'number',   $user->{borrowernumber} );
    $session->param( 'id',       $user->{userid} );
    $session->param( 'ip',       '127.0.0.1' );
    $session->param( 'lasttime', time() );
    $session->flush;

    if ( $args->{authorized} ) {
        $dbh->do( "
            INSERT INTO user_permissions (borrowernumber,module_bit,code)
            VALUES (?,3,'parameters_remaining_permissions')", undef,
            $user->{borrowernumber} );
    }

    return ( $user->{borrowernumber}, $session->id );
}

1;
