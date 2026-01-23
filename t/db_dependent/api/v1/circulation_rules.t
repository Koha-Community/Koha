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
    $t->get_ok("//$userid:$password@/api/v1/circulation_rules")
        ->status_is(200)
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
    $t->get_ok("//$userid:$password@/api/v1/circulation_rules")
        ->status_is(200)
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
    $t->get_ok("//$userid:$password@/api/v1/circulation_rules?library_id=$branchcode")
        ->status_is(200)
        ->json_is( '/0/fine' => 4, "Branch specific fine rule is returned when library is added to request query" )
        ->json_is(
        '/0/finedays' => 5,
        "Default finedays rule is returned when library is added to request query but no branch specific rule is defined"
        );

    $t->get_ok("//$userid:$password@/api/v1/circulation_rules")
        ->status_is(200)
        ->json_is( '/0/fine'     => 2, "Default fine rule returned when no library is added to request query" )
        ->json_is( '/0/finedays' => 5, "Default finedays rule returned when no library is added to request query" );

    # Limit to only rules we're interested in
    $t->get_ok("//$userid:$password@/api/v1/circulation_rules?rules=fine,finedays")->status_is(200)->json_is(
        '/0' => {
            context => { item_type_id => '*', patron_category_id => '*', library_id => '*' }, fine => 2, finedays => 5
        },
        "Only the two rules we asked for are returned"
    );

    # Warn on unsupported query parameter
    $t->get_ok("//$userid:$password@/api/v1/circulation_rules?rules_blah=blah")
        ->status_is(400)
        ->json_is( [ { path => '/query/rules_blah', message => 'Malformed query string' } ] );

    # Make sure we have a non-existent library
    my $library_to_delete    = $builder->build_object( { class => 'Koha::Libraries' } );
    my $non_existent_library = $library_to_delete->branchcode;
    $library_to_delete->delete;

    # Warn on incorrect query parameter value
    $t->get_ok("//$userid:$password@/api/v1/circulation_rules?library_id=$non_existent_library")
        ->status_is(400)
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
        ->status_is(400)
        ->json_is(
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
    $t->get_ok("//$userid:$password@/api/v1/circulation_rules?item_type_id=$non_existent_itemtype")
        ->status_is(400)
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
                ok(        $pointer->get('/context/library_id') eq "*"
                        && $pointer->get('/context/item_type_id') eq '*'
                        && $pointer->get('/context/patron_category_id') eq '*', "Default rules returned first" );
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
                ok(
                           $pointer->get('/context/library_id') eq $branchcode
                        && $pointer->get('/context/item_type_id') eq '*'
                        && $pointer->get('/context/patron_category_id') eq '*',
                    "Branchcode rule set returned when filtered"
                );
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

subtest 'set_rules() tests' => sub {
    plan tests => 28;

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
    note("Authorized user setting rules");

    my $rules_to_set = {
        context => {
            library_id         => $branchcode,
            patron_category_id => $categorycode,
            item_type_id       => $itemtype,
        },
        fine     => 5,
        finedays => 7,
    };

    $t->put_ok( "//$userid:$password@/api/v1/circulation_rules" => json => $rules_to_set )->status_is(200);

    # Verify the rules were set
    my $json = $t->tx->res->json;
    is( $json->{fine},     5, "Fine rule set correctly" );
    is( $json->{finedays}, 7, "Finedays rule set correctly" );

    # Invalid item_type_id
    note("Invalid item_type_id");
    $rules_to_set->{context}->{item_type_id} = 'invalid_itemtype';
    $t->put_ok( "//$userid:$password@/api/v1/circulation_rules" => json => $rules_to_set )
        ->status_is(400)
        ->json_is( '/error_code' => 'invalid_parameter_value', "Handled invalid item_type_id" );

    # Invalid library_id
    note("Invalid library_id");
    $rules_to_set->{context}->{item_type_id} = $itemtype;
    $rules_to_set->{context}->{library_id}   = 'invalid_library';
    $t->put_ok( "//$userid:$password@/api/v1/circulation_rules" => json => $rules_to_set )
        ->status_is(400)
        ->json_is( '/error_code' => 'invalid_parameter_value', "Handled invalid library_id" );

    # Invalid patron_category_id
    note("Invalid patron_category_id");
    $rules_to_set->{context}->{library_id}         = $branchcode;
    $rules_to_set->{context}->{patron_category_id} = 'invalid_category';
    $t->put_ok( "//$userid:$password@/api/v1/circulation_rules" => json => $rules_to_set )
        ->status_is(400)
        ->json_is( '/error_code' => 'invalid_parameter_value', "Handled invalid patron_category_id" );

    # Unauthorized user tests
    note("Unauthorized user trying to set rules");
    $t->put_ok( "//$unauth_userid:$password@/api/v1/circulation_rules" => json => $rules_to_set )->status_is(403);

    # Reset to valid context
    $rules_to_set->{context}->{patron_category_id} = $categorycode;

    # Updating existing rules
    note("Updating existing rules");
    $rules_to_set->{fine} = 10;
    $t->put_ok( "//$userid:$password@/api/v1/circulation_rules" => json => $rules_to_set )->status_is(200);

    # Verify the rules were updated
    $json = $t->tx->res->json;
    is( $json->{fine},     10, "Fine rule updated correctly" );
    is( $json->{finedays}, 7,  "Finedays rule remains the same" );

    # Setting rules with '*' context
    note("Setting rules with '*' context");
    $rules_to_set->{context}->{library_id}         = '*';
    $rules_to_set->{context}->{patron_category_id} = '*';
    $rules_to_set->{context}->{item_type_id}       = '*';
    $t->put_ok( "//$userid:$password@/api/v1/circulation_rules" => json => $rules_to_set )->status_is(200);

    # Verify the rules were set for wildcard context
    $json = $t->tx->res->json;
    is( $json->{fine},     10, "Fine rule set correctly for wildcard context" );
    is( $json->{finedays}, 7,  "Finedays rule set correctly for wildcard context" );

    # Setting rules empty and undefined
    note("Setting rules to empty and undefined");
    $rules_to_set->{fine}     = '';
    $rules_to_set->{finedays} = undef;
    $t->put_ok( "//$userid:$password@/api/v1/circulation_rules" => json => $rules_to_set )->status_is(200);

    # Verify the rules were updated
    $json = $t->tx->res->json;
    is( $json->{fine},     '',    "Fine rule updated correctly" );
    is( $json->{finedays}, undef, "Finedays rule remains the same" );

    # Verify that the explicit undef results in a rule deletion
    my $rules = Koha::CirculationRules->search(
        { categorycode => undef, branchcode => undef, itemtype => undef, rule_name => 'finedays' } );
    is( $rules->count, 0, "Finedays rule deleted from database" );

    $schema->storage->txn_rollback;
};
