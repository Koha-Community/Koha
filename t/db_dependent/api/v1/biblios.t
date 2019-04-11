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

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Auth;
use Koha::Biblios;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'delete() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 9 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    my $item      = $builder->build_sample_item();
    my $biblio_id = $item->biblionumber;

    # Bibs with items cannot be deleted
    $t->delete_ok("//$userid:$password@/api/v1/biblios/$biblio_id")
      ->status_is(409);

    $item->delete();

    # Bibs with no items can be deleted
    $t->delete_ok("//$userid:$password@/api/v1/biblios/$biblio_id")
      ->status_is(200)->content_is(q{""});

    $t->delete_ok("//$userid:$password@/api/v1/biblios/$biblio_id")
      ->status_is(404);

    $schema->storage->txn_rollback;
};
