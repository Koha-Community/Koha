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

use Test::More tests => 2;
use Test::MockModule;
use Test::Mojo;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Database;
use Koha::Exceptions;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'render_resource_not_found() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $authorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 1 },
        }
    );
    my $password = 'thePassword123';
    $authorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $authorized_patron->userid;

    my $mock_cities = Test::MockModule->new('Koha::REST::V1::Cities');
    $mock_cities->mock(
        'get',
        sub {
            my $c = shift->openapi->valid_input or return;
            $c->render_resource_not_found;
        }
    );

    my $t = Test::Mojo->new('Koha::REST::V1');

    $t->get_ok("//$userid:$password@/api/v1/cities/1")->status_is('404')->json_is(
        {
            error      => 'Resource not found',
            error_code => 'not_found',
        }
    );

    $mock_cities->mock(
        'get',
        sub {
            my $c = shift->openapi->valid_input or return;
            $c->render_resource_not_found("Thing");
        }
    );

    $t->get_ok("//$userid:$password@/api/v1/cities/1")->status_is('404')->json_is(
        {
            error      => 'Thing not found',
            error_code => 'not_found',
        }
    );

    $schema->storage->txn_rollback;
};

subtest 'render_resource_deleted() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $authorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 1 },
        }
    );
    my $password = 'thePassword123';
    $authorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $authorized_patron->userid;

    my $mock_cities = Test::MockModule->new('Koha::REST::V1::Cities');
    $mock_cities->mock(
        'delete',
        sub {
            my $c = shift->openapi->valid_input or return;
            return $c->render_resource_deleted;
        }
    );

    my $t = Test::Mojo->new('Koha::REST::V1');

    $t->delete_ok("//$userid:$password@/api/v1/cities/1")->status_is('204')->content_is(q{});

    $schema->storage->txn_rollback;
};
