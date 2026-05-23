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
use Test::More tests => 3;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Checkouts;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'overdues_count unauthorized' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    $t->get_ok( "/api/v1/patrons/" . $patron->borrowernumber . "/overdues_count" )->status_is(401);

    $schema->storage->txn_rollback;
};

subtest 'overdues_count' => sub {
    plan tests => 8;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**4 }    # borrowers flag
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    # No checkouts - 0 overdues
    $t->get_ok( "//$userid:$password\@/api/v1/patrons/" . $patron->borrowernumber . "/overdues_count" )
        ->status_is(200)
        ->json_is(0);

    # Add an overdue checkout
    my $item = $builder->build_sample_item();
    $builder->build(
        {
            source => 'Issue',
            value  => {
                borrowernumber => $patron->borrowernumber,
                itemnumber     => $item->itemnumber,
                date_due       => '2020-01-01 00:00:00',
                branchcode     => $patron->branchcode,
            }
        }
    );

    $t->get_ok( "//$userid:$password\@/api/v1/patrons/" . $patron->borrowernumber . "/overdues_count" )
        ->status_is(200)
        ->json_is(1);

    # Non-existent patron
    $t->get_ok("//$userid:$password\@/api/v1/patrons/999999999/overdues_count")->status_is(404);

    $schema->storage->txn_rollback;
};
