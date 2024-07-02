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

use Koha::CirculationRules;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list_effective_rules() tests' => sub {

    plan tests => 26;

    $schema->storage->txn_begin;

    my $categorycode = $builder->build( { source => 'Category' } )->{'categorycode'};
    my $itemtype     = $builder->build( { source => 'Itemtype' } )->{'itemtype'};
    my $branchcode   = $builder->build( { source => 'Branch' } )->{'branchcode'};
    Koha::CirculationRules->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2 }     # circulate
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
    # No circulation_rules, so empty hash should be returned
    $t->get_ok("//$userid:$password@/api/v1/circulation_rules")->status_is(200)->json_is( {} );

    # One rule created, should get returned
    ok(
        Koha::CirculationRule->new(
            {
                branchcode   => undef,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'fine',
                rule_value   => 2,
            }
        )->store,
        'Given I added an issuing rule branchcode => undef,' . ' categorycode => undef, itemtype => undef,'
    );

    $t->get_ok("//$userid:$password@/api/v1/circulation_rules")->status_is(200)
        ->json_is( '' => { 'fine' => 2 }, "Our single rule is returned" );

    # Two circulation_rules created, they should both be returned
    ok(
        Koha::CirculationRule->new(
            {
                branchcode   => undef,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'finedays',
                rule_value   => 5,
            }
        )->store,
        'Given I added another issuing rule branchcode => undef,' . ' categorycode => undef, itemtype => undef,'
    );

    $t->get_ok("//$userid:$password@/api/v1/circulation_rules")->status_is(200)->json_is(
        '' => {
            fine     => 2,
            finedays => 5,
        },
        "Two default rules are returned"
    );

    # Specificity works, three circulation_rules stored, one branchcode specific
    ok(
        Koha::CirculationRule->new(
            {
                branchcode   => $branchcode,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'fine',
                rule_value   => 4,
            }
        )->store,
        "Given I added an issuing rule branchcode => $branchcode," . ' categorycode => undef, itemtype => undef,'
    );

    $t->get_ok("//$userid:$password@/api/v1/circulation_rules?library_id=$branchcode")->status_is(200)->json_is(
        '' => {
            fine     => 4,
            finedays => 5,
        },
        "Branch specific rule is returned when library is added to request query"
    );

    $t->get_ok("//$userid:$password@/api/v1/circulation_rules")->status_is(200)->json_is(
        '' => {
            fine     => 2,
            finedays => 5,
        },
        "Default rules are returned when no library is added to request query"
    );

    # Warn on unsupported query parameter
    $t->get_ok("//$userid:$password@/api/v1/circulation_rules?rules_blah=blah")->status_is(400)
        ->json_is( [ { path => '/query/rules_blah', message => 'Malformed query string' } ] );

    # Warn on incorrect query parameter value
    $t->get_ok("//$userid:$password@/api/v1/circulation_rules?library_id=SMITH")->status_is(400)->json_is(
        '' => {
            error      => 'Invalid parameter value',
            error_code => 'invalid_parameter_value',
            path       => '/query/library',
            values     => {
                uri   => '/api/v1/libraries',
                field => 'library_id'
            }
        },
        "Invalid parameter value handled correctly"
    );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/circulation_rules")->status_is(403);

    $schema->storage->txn_rollback;
};
