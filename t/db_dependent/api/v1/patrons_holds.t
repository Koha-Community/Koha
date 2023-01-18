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

use Test::More tests => 1;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

my $t = Test::Mojo->new('Koha::REST::V1');

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 2 ** 4 } # 'borrowers' flag == 4
    });
    my $password = 'thePassword123';
    $patron->set_password({ password => $password, skip_validation => 1 });
    my $userid = $patron->userid;

    $t->get_ok("//$userid:$password@/api/v1/patrons/" . $patron->id . '/holds')
      ->status_is( 200, 'SWAGGER3.2.2' )
      ->json_is( [] );

    my $hold_1 = $builder->build_object({ class => 'Koha::Holds', value => { borrowernumber => $patron->id } });
    my $hold_2 = $builder->build_object({ class => 'Koha::Holds', value => { borrowernumber => $patron->id } });

    $t->get_ok("//$userid:$password@/api/v1/patrons/" . $patron->id . '/holds?_order_by=+me.hold_id')
      ->status_is( 200, 'SWAGGER3.2.2' )
      ->json_is( '' => [ $hold_1->to_api, $hold_2->to_api ], 'Holds retrieved' );

    my $non_existent_patron = $builder->build_object({ class => 'Koha::Patrons' });
    my $non_existent_patron_id = $non_existent_patron->id;
    # get rid of the patron
    $non_existent_patron->delete;

    $t->get_ok("//$userid:$password@/api/v1/patrons/" . $non_existent_patron_id . '/holds')
      ->status_is( 404 )
      ->json_is( '/error' => 'Patron not found' );

    $schema->storage->txn_rollback;
};
