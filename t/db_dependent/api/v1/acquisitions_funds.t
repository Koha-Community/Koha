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
use Test::More tests => 15;
use Test::Mojo;
use t::lib::TestBuilder;
use t::lib::Mocks;

use JSON qw(encode_json);

use C4::Budgets;

use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

$schema->storage->txn_begin;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

my $librarian = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => { flags => 2052 }
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
my $unauth_password = 'thePassword123';
$patron->set_password( { password => $unauth_password, skip_validation => 1 } );
my $unauth_userid = $patron->userid;

my $fund_name = 'Periodiques';

my $fund = $builder->build_object(
    {
        class => 'Koha::Acquisition::Funds',
        value => {
            budget_amount => '123.132000',
            budget_name   => $fund_name,
            budget_notes  => 'This is a note'
        }
    }
);

$t->get_ok('/api/v1/acquisitions/funds')->status_is(401);

$t->get_ok('/api/v1/acquisitions/funds/?name=testFund')->status_is(401);

$t->get_ok("//$unauth_userid:$unauth_password@/api/v1/acquisitions/funds")->status_is(403);

$t->get_ok( "//$unauth_userid:$unauth_password@/api/v1/acquisitions/funds?name=" . $fund_name )->status_is(403);

$t->get_ok("//$userid:$password@/api/v1/acquisitions/funds")->status_is(200);

$t->get_ok( "//$userid:$password@/api/v1/acquisitions/funds?name=" . $fund_name )->status_is(200)
    ->json_like( '/0/name' => qr/$fund_name/ );

$schema->storage->txn_rollback;

subtest 'list_owners() and list_users() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $patron_with_permission =
        $builder->build_object( { class => 'Koha::Patrons', value => { flags => 2**11 } } );    ## 11 == acquisition
    my $patron_without_permission =
        $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    my $superlibrarian =
        $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );
    my $password = 'thePassword123';
    $superlibrarian->set_password( { password => $password, skip_validation => 1 } );
    $superlibrarian->discard_changes;

    my $userid = $superlibrarian->userid;

    # Restrict the query to a know list of patrons
    my $api_filter = encode_json(
        { 'me.patron_id' => [ $patron_with_permission->id, $patron_without_permission->id, $superlibrarian->id ] } );

    $t->get_ok("//$userid:$password@/api/v1/acquisitions/funds/owners?q=$api_filter")->status_is(200)->json_is(
        [
            $patron_with_permission->to_api( { user => $patron_with_permission } ),
            $superlibrarian->to_api( { user => $superlibrarian } )
        ]
    );

    $t->get_ok("//$userid:$password@/api/v1/acquisitions/funds/users?q=$api_filter")->status_is(200)->json_is(
        [
            $patron_with_permission->to_api( { user => $patron_with_permission } ),
            $superlibrarian->to_api( { user => $superlibrarian } )
        ]
    );

    $schema->storage->txn_rollback;
};
