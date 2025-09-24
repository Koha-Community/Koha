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
use Test::More tests => 2;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::StockRotationStages;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'move() tests' => sub {

    plan tests => 16;

    $schema->storage->txn_begin;

    my $authorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**24 }    # stockrotation => 24
        }
    );
    my $password = 'thePassword123';
    $authorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $auth_userid = $authorized_patron->userid;

    my $unauthorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    $unauthorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $unauthorized_patron->userid;

    my $library1 = $builder->build( { source => 'Branch' } );
    my $library2 = $builder->build( { source => 'Branch' } );
    my $rota     = $builder->build( { source => 'Stockrotationrota' } );
    my $stage1   = $builder->build(
        {
            source => 'Stockrotationstage',
            value  => {
                branchcode_id => $library1->{branchcode},
                rota_id       => $rota->{rota_id},
            }
        }
    );
    my $stage2 = $builder->build(
        {
            source => 'Stockrotationstage',
            value  => {
                branchcode_id => $library2->{branchcode},
                rota_id       => $rota->{rota_id},
            }
        }
    );
    my $rota_id   = $rota->{rota_id};
    my $stage1_id = $stage1->{stage_id};

    # Unauthorized attempt to update
    $t->put_ok( "//$unauth_userid:$password@/api/v1/rotas/$rota_id/stages/$stage1_id/position" => json => 2 )
        ->status_is(403);

    # Invalid attempt to move a stage on a non-existent rota
    $t->put_ok( "//$auth_userid:$password@/api/v1/rotas/99999999/stages/$stage1_id/position" => json => 2 )
        ->status_is(404)->json_is( '/error' => "Rota not found" );

    # Invalid attempt to move an non-existent stage
    $t->put_ok( "//$auth_userid:$password@/api/v1/rotas/$rota_id/stages/999999999/position" => json => 2 )
        ->status_is(404)->json_is( '/error' => "Stage not found" );

    # Invalid attempt to move stage to current position
    my $curr_position = $stage1->{position};
    $t->put_ok( "//$auth_userid:$password@/api/v1/rotas/$rota_id/stages/$stage1_id/position" => json => $curr_position )
        ->status_is(400)->json_is( '/error' => "Bad request - new position invalid" );

    # Invalid attempt to move stage to invalid position
    $t->put_ok( "//$auth_userid:$password@/api/v1/rotas/$rota_id/stages/$stage1_id/position" => json => 99999999 )
        ->status_is(400)->json_is( '/error' => "Bad request - new position invalid" );

    # Valid, authorised move
    $t->put_ok( "//$auth_userid:$password@/api/v1/rotas/$rota_id/stages/$stage1_id/position" => json => 2 )
        ->status_is(200);

    $schema->storage->txn_rollback;
};
