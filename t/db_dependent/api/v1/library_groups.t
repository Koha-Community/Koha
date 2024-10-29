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
use Test::Mojo;
use Test::Warn;
use Test::NoWarnings;

use t::lib::TestBuilder;
use t::lib::Mocks;

use List::Util qw(min);

use Koha::Library::Groups;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 4 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    my $root_group1 = Koha::Library::Group->new(
        {
            title => "LibGroup1",
        }
    )->store();

    my $lg1groupA =
        Koha::Library::Group->new( { parent_id => $root_group1->id, title => 'LibGroup1 SubGroupA' } )->store();
    my $lg1groupA1 =
        Koha::Library::Group->new( { parent_id => $lg1groupA->id, title => 'LibGroup1 SubGroupA SubGroup1' } )->store();
    my $lg1groupA2 =
        Koha::Library::Group->new( { parent_id => $lg1groupA->id, title => 'LibGroup1 SubGroupA SubGroup2' } )->store();
    my $lg1groupB =
        Koha::Library::Group->new( { parent_id => $root_group1->id, title => 'LibGroup1 SubGroupB' } )->store();

    ## Authorized user tests
    # Make sure we are returned with the correct amount of libraries
    $t->get_ok("//$userid:$password@/api/v1/library_groups")->status_is( 200, 'SWAGGER3.2.2' );

    my $response_count = scalar @{ $t->tx->res->json };
    my $expected_count = Koha::Library::Groups->count;
    is( $response_count, $expected_count, 'Results count is as expected' );

    $schema->storage->txn_rollback;
};
