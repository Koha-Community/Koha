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
use t::lib::Dates;

use C4::Auth;
use Koha::Database;

use JSON qw(encode_json);

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    # delete all patrons
    Koha::Patrons->search->delete;

    # delete all categories
    Koha::Patron::Categories->search->delete;

    $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => { categorycode => 'TEST', description => 'Test' }
        }
    );

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**3, categorycode => 'TEST' }    # parameters flag = 3
        }
    );

    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    $t->get_ok("//$userid:$password@/api/v1/patron_categories")->status_is(200);

    $t->get_ok("//$userid:$password@/api/v1/patron_categories")->status_is(200)->json_has('/0/name')
        ->json_is( '/0/name' => 'Test' )->json_hasnt('/1');

    $schema->storage->txn_rollback;

};
