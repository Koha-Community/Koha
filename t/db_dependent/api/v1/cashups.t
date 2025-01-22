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

use Test::NoWarnings;
use Test::More tests => 3;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Cash::Register::Cashups;
use Koha::Cash::Register::Cashups;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 17;

    $schema->storage->txn_begin;

    Koha::Cash::Register::Cashups->search->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 25**2 }    # cash_management flag = 25
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

    ## Authorized user tests
    # No cash register, so 404 should be returned
    my $cash_register_to_delete = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $non_existent_cr_id      = $cash_register_to_delete->id;
    $cash_register_to_delete->delete;

    $t->get_ok("//$userid:$password@/api/v1/cash_registers/$non_existent_cr_id/cashups")->status_is(404)
        ->json_is( '/error' => 'Register not found' );

    my $register    = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $register_id = $register->id;

    # No cashups, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/cash_registers/$register_id/cashups")->status_is(200)->json_is( [] );

    my $cashup = $builder->build_object(
        {
            class => 'Koha::Cash::Register::Cashups',
            value => {
                register_id => $register->id,
                code        => 'CASHUP',
                timestamp   => \'NOW() - INTERVAL 15 MINUTE'
            }
        }
    );

    # One cashup created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/cash_registers/$register_id/cashups")->status_is(200)
        ->json_is( [ $cashup->to_api ] );

    my $another_cashup = $builder->build_object(
        {
            class => 'Koha::Cash::Register::Cashups',
            value => {
                register_id => $register->id,
                code        => 'CASHUP',
                timestamp   => \'NOW()'
            }
        }
    );

    # One more cashup created, both should be returned
    $t->get_ok("//$userid:$password@/api/v1/cash_registers/$register_id/cashups")->status_is(200)
        ->json_is( [ $another_cashup->to_api, $cashup->to_api, ] );

    # Warn on unsupported query parameter
    $t->get_ok("//$userid:$password@/api/v1/cash_registers/$register_id/cashups?cashup_blah=blah")->status_is(400)
        ->json_is(
        [
            {
                path    => '/query/cashup_blah',
                message => 'Malformed query string'
            }
        ]
        );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/cash_registers/$register_id/cashups")->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $cashup    = $builder->build_object( { class => 'Koha::Cash::Register::Cashups' } );
    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 25**2 }    # cash_management flag = 25
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

    $t->get_ok( "//$userid:$password@/api/v1/cashups/" . $cashup->id )->status_is(200)->json_is( $cashup->to_api );

    $t->get_ok( "//$unauth_userid:$password@/api/v1/cashups/" . $cashup->id )->status_is(403);

    my $cashup_to_delete = $builder->build_object( { class => 'Koha::Cash::Register::Cashups' } );
    my $non_existent_id  = $cashup_to_delete->id;
    $cashup_to_delete->delete;

    $t->get_ok("//$userid:$password@/api/v1/cashups/$non_existent_id")->status_is(404)
        ->json_is( '/error' => 'Cashup not found' );

    $schema->storage->txn_rollback;
};
