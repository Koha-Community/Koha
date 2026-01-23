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
use Test::More tests => 2;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Patron::Attributes;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth',       1 );
t::lib::Mocks::mock_preference( 'ChildNeedsGuarantor', 0 );

subtest 'list() tests' => sub {

    plan tests => 14;

    $schema->storage->txn_begin;

    my $patron_category =
        $builder->build( { source => 'Category', value => { category_type => 'A', can_be_guarantee => 0 } } )
        ->{categorycode};

    Koha::Patrons->search->update( { flags => 0, categorycode => $patron_category } );
    $schema->resultset('UserPermission')->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**28 }
        }
    );

    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    ## Authorized user tests
    # One erm_user created, should get returned
    $librarian->discard_changes;
    $t->get_ok("//$userid:$password@/api/v1/erm/users")
        ->status_is(200)
        ->json_is( [ $librarian->to_api( { user => $librarian } ) ] );

    my $another_erm_user = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**28 }
        }
    );

    # Two erm_users created, only self is returned without permission to view_any_borrower
    $t->get_ok("//$userid:$password@/api/v1/erm/users")
        ->status_is(200)
        ->json_is( [ $librarian->to_api( { user => $librarian } ) ] );

    my $dbh = C4::Context->dbh;
    $dbh->do(
        q{INSERT INTO user_permissions( borrowernumber, module_bit, code ) VALUES (?, ?, ?)}, undef,
        ( $librarian->borrowernumber, 4, 'view_borrower_infos_from_any_libraries' )
    );

    # Two erm_users created, they should both be returned
    $t->get_ok("//$userid:$password@/api/v1/erm/users")
        ->status_is(200)
        ->json_is(
        [ $librarian->to_api( { user => $librarian } ), $another_erm_user->to_api( { user => $another_erm_user } ) ] );

    # Warn on unsupported query parameter
    $t->get_ok("//$userid:$password@/api/v1/erm/users?blah=blah")
        ->status_is(400)
        ->json_is( [ { path => '/query/blah', message => 'Malformed query string' } ] );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/erm/users")->status_is(403);

    $schema->storage->txn_rollback;
};
