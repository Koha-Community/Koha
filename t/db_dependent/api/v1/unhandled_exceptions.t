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
use Test::More tests => 2;
use Test::MockModule;
use Test::Mojo;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Database;
use Koha::Exceptions;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'unhandled_exception() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $authorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**4 }    # borrowers flag = 4
        }
    );
    my $password = 'thePassword123';
    $authorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $authorized_patron->userid;

    my $message = 'delete died';

    my $mock_patron = Test::MockModule->new('Koha::Patron');
    $mock_patron->mock( 'delete', sub { Koha::Exception->throw($message); } );

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    $t->delete_ok( "//$userid:$password@/api/v1/patrons/" . $patron->id )->status_is('500')->json_is(
        {
            error      => 'Something went wrong, check Koha logs for details.',
            error_code => 'internal_server_error',
        }
    );

    $schema->storage->txn_rollback;
};
