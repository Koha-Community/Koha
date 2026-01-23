#!/usr/bin/perl

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

use Koha::Patrons;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'basic tests' => sub {

    plan tests => 12;

    $schema->storage->txn_begin;

    my $privileged_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 1 }
        }
    );
    my $password = 'thePassword123';
    $privileged_patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $privileged_patron->userid;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    my $new_password = 'abc';

    $t->put_ok( "//$userid:$password@/api/v1/patrons/"
            . $patron->id
            . "/password/expiration_date" => json => { expiration_date => '2021-01-01' } )->status_is(200)->json_is('');

    $t->put_ok( "//$userid:$password@/api/v1/patrons/"
            . $patron->id
            . "/password/expiration_date" => json => { expiration_date => '01/13/2021' } )
        ->status_is(400)
        ->json_is( '/errors/0/message' => 'Does not match date format.' );

    $t->put_ok( "//$userid:$password@/api/v1/patrons/"
            . $patron->id
            . "/password/expiration_date" => json => { expiration_date => '13/01/2021' } )
        ->status_is(400)
        ->json_is( '/errors/0/message' => 'Does not match date format.' );

    $privileged_patron->flags(0)->store();

    $t->put_ok( "//$userid:$password@/api/v1/patrons/"
            . $patron->id
            . "/password/expiration_date" => json => { expiration_date => '2021-01-01' } )->status_is(403)->json_is(
        {
            error                  => "Authorization failure. Missing required permission(s).",
            "required_permissions" => { "superlibrarian" => "1" }
        }
            );

    $schema->storage->txn_rollback;
};
