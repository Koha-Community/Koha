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

use Test::More tests => 2;
use Test::NoWarnings;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Cash::Registers;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    Koha::Cash::Registers->search->delete;

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

    $t->get_ok("//$userid:$password@/api/v1/cash_registers")->status_is(200)->json_is( [] );

    my $register = $builder->build_object( { class => 'Koha::Cash::Registers' } );

    my $new_register = $builder->build_object( { class => 'Koha::Cash::Registers' } );

    # One more register created, both should be returned
    $t->get_ok("//$userid:$password@/api/v1/cash_registers")->status_is(200)
        ->json_is( [ $register->to_api, $new_register->to_api, ] );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/cash_registers")->status_is(403);

    $schema->storage->txn_rollback;
};
