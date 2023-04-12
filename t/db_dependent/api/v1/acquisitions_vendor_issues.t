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

use Koha::Acquisition::Booksellers;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 11;

    $schema->storage->txn_begin;

    my $vendor = $builder->build_object( { class => 'Koha::Acquisition::Booksellers' } );
    my $vendor_id = $vendor->id;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2 ** 11 }
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    # No issues, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/acquisitions/vendors/$vendor_id/issues")
      ->status_is(200)
      ->json_is( [] );

    my $issue = Koha::Acquisition::Bookseller::Issue->new(
        {
            vendor_id => $vendor_id,
            type      => 'MAINTENANCE',
            notes     => 'a vendor issue'
        }
    )->store;
    # One issue created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/acquisitions/vendors/$vendor_id/issues")
      ->status_is(200)
      ->json_is( [$issue->to_api] );
    # Embed the AV description
    $t->get_ok("//$userid:$password@/api/v1/acquisitions/vendors/$vendor_id/issues"
        => { 'x-koha-embed' => '+strings' })
      ->status_is(200)
      ->json_is( [$issue->to_api({ strings => 1 })] );

    $vendor->delete;
    # No vendor, should get 404
    $t->get_ok("//$userid:$password@/api/v1/acquisitions/vendors/$vendor_id/issues")
      ->status_is(404);

    $schema->storage->txn_rollback;
};
