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

use Koha::ERM::Agreements;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 17;

    $schema->storage->txn_begin;

    Koha::ERM::Agreements->search->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 27 ** 2 }
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
    # No agreements, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/erm/agreements")
      ->status_is(200)
      ->json_is( [] );

    my $agreement = $builder->build_object({ class => 'Koha::ERM::Agreements' });

    # One agreement created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/erm/agreements")
      ->status_is(200)
      ->json_is( [$agreement->to_api] );

    my $another_agreement = $builder->build_object(
        { class => 'Koha::ERM::Agreements', value => { vendor_id => $agreement->vendor_id } } );
    my $agreement_with_another_vendor_id = $builder->build_object({ class => 'Koha::ERM::Agreements' });

    # Two agreements created, they should both be returned
    $t->get_ok("//$userid:$password@/api/v1/erm/agreements")
      ->status_is(200)
      ->json_is([$agreement->to_api,
                 $another_agreement->to_api,
                 $agreement_with_another_vendor_id->to_api
                 ] );

    # Filtering works, two agreements sharing vendor_id
    $t->get_ok("//$userid:$password@/api/v1/erm/agreements?vendor_id=" . $agreement->vendor_id )
      ->status_is(200)
      ->json_is([ $agreement->to_api,
                  $another_agreement->to_api
                  ]);

    # Warn on unsupported query parameter
    $t->get_ok("//$userid:$password@/api/v1/erm/agreements?blah=blah" )
      ->status_is(400)
      ->json_is( [{ path => '/query/blah', message => 'Malformed query string'}] );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/erm/agreements")
      ->status_is(403);

    $schema->storage->txn_rollback;
};

