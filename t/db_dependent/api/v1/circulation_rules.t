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

subtest 'list_rules() tests' => sub {

    my $expected_rules = [ keys %{ Koha::CirculationRules->rule_kinds } ];

    plan tests => ( scalar( @{$expected_rules} ) * 2 ) + 39;

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

    note("Effective rules by default");
    ## Authorized user tests
    # No circulation_rules, so all keys in the returned hash should be undefined
    $t->get_ok("//$userid:$password@/api/v1/circulation_rules")->status_is(200);

    # Extract and decode the JSON response
    my $json = $t->tx->res->json;
    note("No rules defined");
    foreach my $key ( @{$expected_rules} ) {
        ok( exists $json->[0]->{$key}, "Key '$key' exists in the JSON response" );
        is( $json->[0]->{$key}, undef, "'$key' is undefined" );
    }

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

    note("One default rule defined");
    $t->get_ok("//$userid:$password@/api/v1/circulation_rules")->status_is(200)
        ->json_is( '/0/fine'     => 2,     "Default fine rule is returned as expected" )
        ->json_is( '/0/finedays' => undef, "Rule finedays is undefined as expected" );

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

    note("Two default rules defined");
    $t->get_ok("//$userid:$password@/api/v1/circulation_rules")->status_is(200)
        ->json_is( '/0/fine'     => 2, "Default fine rule is returned as expected" )
        ->json_is( '/0/finedays' => 5, "Default finedays rule is returned as expected" );

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

    note("Two default rules and one branch rule defined");
    $t->get_ok("//$userid:$password@/api/v1/circulation_rules?library_id=$branchcode")->status_is(200)
        ->json_is( '/0/fine' => 4, "Branch specific fine rule is returned when library is added to request query" )
        ->json_is(
        '/0/finedays' => 5,
        "Default finedays rule is returned when library is added to request query but no branch specific rule is defined"
        );

    $t->get_ok("//$userid:$password@/api/v1/circulation_rules")->status_is(200)
        ->json_is( '/0/fine'     => 2, "Default fine rule returned when no library is added to request query" )
        ->json_is( '/0/finedays' => 5, "Default finedays rule returned when no library is added to request query" );

    # Limit to only rules we're interested in
    $t->get_ok("//$userid:$password@/api/v1/circulation_rules?rules=fine,finedays")->status_is(200)
        ->json_is( '/0' => { fine => 2, finedays => 5 }, "Only the two rules we asked for are returned" );

    # Warn on unsupported query parameter
    $t->get_ok("//$userid:$password@/api/v1/circulation_rules?rules_blah=blah")->status_is(400)
        ->json_is( [ { path => '/query/rules_blah', message => 'Malformed query string' } ] );

    # Make sure we have a non-existent library
    my $library_to_delete    = $builder->build_object( { class => 'Koha::Libraries' } );
    my $non_existent_library = $library_to_delete->branchcode;
    $library_to_delete->delete;

    # Warn on incorrect query parameter value
    $t->get_ok("//$userid:$password@/api/v1/circulation_rules?library_id=$non_existent_library")->status_is(400)
        ->json_is(
        '' => {
            error      => 'Invalid parameter value',
            error_code => 'invalid_parameter_value',
            path       => '/query/library_id',
            values     => {
                uri   => '/api/v1/libraries',
                field => 'library_id'
            }
        },
        "Invalid parameter value handled correctly"
        );

    # Make sure we have a non-existent category
    my $category_to_delete    = $builder->build_object( { class => 'Koha::Patron::Categories' } );
    my $non_existent_category = $category_to_delete->categorycode;
    $category_to_delete->delete;

    # Warn on incorrect query parameter value
    $t->get_ok("//$userid:$password@/api/v1/circulation_rules?patron_category_id=$non_existent_category")
        ->status_is(400)->json_is(
        '' => {
            error      => 'Invalid parameter value',
            error_code => 'invalid_parameter_value',
            path       => '/query/patron_category_id',
            values     => {
                uri   => '/api/v1/patron_categories',
                field => 'patron_category_id'
            }
        },
        "Invalid parameter value handled correctly"
        );

    # Make sure we have a non-existent itemtype
    my $itemtype_to_delete    = $builder->build_object( { class => 'Koha::ItemTypes' } );
    my $non_existent_itemtype = $itemtype_to_delete->itemtype;
    $itemtype_to_delete->delete;

    # Warn on incorrect query parameter value
    $t->get_ok("//$userid:$password@/api/v1/circulation_rules?item_type_id=$non_existent_itemtype")->status_is(400)
        ->json_is(
        '' => {
            error      => 'Invalid parameter value',
            error_code => 'invalid_parameter_value',
            path       => '/query/item_type_id',
            values     => {
                uri   => '/api/v1/item_types',
                field => 'item_type_id'
            }
        },
        "Invalid parameter value handled correctly"
        );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/circulation_rules")->status_is(403);

    subtest 'effective=false tests' => sub {

        my $count = scalar( @{$expected_rules} );

        plan tests => ( $count * 2 ) + $count + 10;

        # All rules
        $t->get_ok("//$userid:$password@/api/v1/circulation_rules?effective=0")->status_is(200);

        # Extract and decode the JSON response
        my $json = $t->tx->res->json;

        # Check if the response is an array
        is( ref $json,          'ARRAY', 'Response is an array' );
        is( scalar( @{$json} ), 2,       'Response contains 2 rule sets' );

        # Iterate over each hash in the array
        my $index = 0;
        foreach my $hash ( @{$json} ) {
            my $pointer = Mojo::JSON::Pointer->new($hash);

            # First rule set should march default, default, default
            if ( $index == 0 ) {
                ok(        $pointer->get('/branchcode') eq "*"
                        && $pointer->get('/itemtype') eq '*'
                        && $pointer->get('/categorycode') eq '*', "Default rules returned first" );
            }

            # Iterate over the list of expected keys for each hash
            foreach my $key ( @{$expected_rules} ) {
                ok( $pointer->contains( '/' . $key ), "Hash contains key '$key'" );
            }

            $index++;
        }

        # Filter on library
        $t->get_ok("//$userid:$password@/api/v1/circulation_rules?effective=0&library_id=$branchcode")->status_is(200);

        # Extract and decode the JSON response
        $json = $t->tx->res->json;

        # Check if the response is an array
        is( ref $json,          'ARRAY', 'Response is an array' );
        is( scalar( @{$json} ), 1,       'Filtered response contains 1 rule set' );

        $index = 0;
        foreach my $hash ( @{$json} ) {
            my $pointer = Mojo::JSON::Pointer->new($hash);

            # First (and only) rule set should match branchcode, default, default.
            if ( $index == 0 ) {
                ok(        $pointer->get('/branchcode') eq $branchcode
                        && $pointer->get('/itemtype') eq '*'
                        && $pointer->get('/categorycode') eq '*', "Branchcode rule set returned when filtered" );
            }

            # Iterate over the list of expected keys for each hash
            foreach my $key ( @{$expected_rules} ) {
                ok( $pointer->contains( '/' . $key ), "Hash contains key '$key'" );
            }

            $index++;
        }

    };
    $schema->storage->txn_rollback;
};
