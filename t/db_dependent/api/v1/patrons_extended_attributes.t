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
use Test::More tests => 6;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

my $t = Test::Mojo->new('Koha::REST::V1');

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list_patron_attributes() tests' => sub {

    plan tests => 10;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**4 }    # 'borrowers' flag == 4
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    $t->get_ok( "//$userid:$password@/api/v1/patrons/" . $patron->id . '/extended_attributes' )
        ->status_is( 200, 'REST3.2.2' )
        ->json_is( [] );

    # Let's add 3 attributes
    foreach my $i ( 1 .. 5 ) {
        $builder->build_object( { class => 'Koha::Patron::Attributes', value => { borrowernumber => $patron->id } } );
    }

    $t->get_ok( "//$userid:$password@/api/v1/patrons/" . $patron->id . '/extended_attributes' )
        ->status_is( 200, 'REST3.2.2' )
        ->json_is( '' => $patron->extended_attributes->to_api, 'Extended attributes retrieved correctly' );

    my $non_existent_patron    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $non_existent_patron_id = $non_existent_patron->id;

    # get rid of the patron
    $non_existent_patron->delete;

    $t->get_ok( "//$userid:$password@/api/v1/patrons/" . $non_existent_patron_id . '/extended_attributes' )
        ->status_is(404)
        ->json_is( '/error' => 'Patron not found' );

    subtest 'nullable value' => sub {

        # FIXME This is not correct, we should remove the NULLABLE clause at the DBMS level
        # This test will need to be adjusted on bug 32331
        plan tests => 3;

        my $user = $builder->build_object( { class => 'Koha::Patrons' } );

        $builder->build_object(
            {
                class => 'Koha::Patron::Attributes',
                value => { borrowernumber => $user->id, attribute => undef }
            }
        );

        $t->get_ok( "//$userid:$password@/api/v1/patrons/" . $user->id . '/extended_attributes' )
            ->status_is( 200, 'REST3.2.2' )
            ->json_is(
            '' => $user->extended_attributes->to_api,
            'Extended attributes retrieved correctly'
            );

    };

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**4 }    # 'borrowers' flag == 4
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    my $mandatory_attr_type = $builder->build_object(
        {
            class => 'Koha::Patron::Attribute::Types',
            value => {
                mandatory     => 1,
                repeatable    => 0,
                unique_id     => 0,
                category_code => undef
            }
        }
    );
    my $repeatable_attr_type = $builder->build_object(
        {
            class => 'Koha::Patron::Attribute::Types',
            value => {
                mandatory     => 0,
                repeatable    => 1,
                unique_id     => 0,
                category_code => undef
            }
        }
    );
    my $unique_attr_type = $builder->build_object(
        {
            class => 'Koha::Patron::Attribute::Types',
            value => {
                mandatory     => 0,
                repeatable    => 0,
                unique_id     => 1,
                category_code => undef
            }
        }
    );

    my $non_existent_patron    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $non_existent_patron_id = $non_existent_patron->id;

    # get rid of the patron
    $non_existent_patron->delete;

    $t->post_ok( "//$userid:$password@/api/v1/patrons/"
            . $non_existent_patron_id
            . '/extended_attributes' => json => { type => $repeatable_attr_type->code, value => 'something' } )
        ->status_is(404)
        ->json_is( '/error' => 'Patron not found' );

    my $response =
        $t->post_ok( "//$userid:$password@/api/v1/patrons/"
            . $patron->id
            . '/extended_attributes' => json => { type => $repeatable_attr_type->code, value => 'something' } )
        ->status_is(201)
        ->tx->res->json;

    is_deeply(
        Koha::Patron::Attributes->find( $response->{extended_attribute_id} )->to_api,
        $response,
        "The returned object is on the DB"
    );

    subtest 'Repeatability tests' => sub {
        $t->post_ok( "//$userid:$password@/api/v1/patrons/"
                . $patron->id
                . '/extended_attributes' => json => { type => $repeatable_attr_type->code, value => 'something' } )
            ->status_is( 201, 'Repeatable attributes go through' );

        # Let's add a non-repeatable one
        $patron->add_extended_attribute( { code => $unique_attr_type->code, attribute => 'non_repeatable_1' } );
        $t->post_ok( "//$userid:$password@/api/v1/patrons/"
                . $patron->id
                . '/extended_attributes' => json => { type => $unique_attr_type->code, value => 'non_repeatable_2' } )
            ->status_is(409)
            ->json_is( '/error' => 'Tried to add more than one non-repeatable attributes. type='
                . $unique_attr_type->code
                . ' value=non_repeatable_2' );
    };

    subtest 'Attribute uniqueness tests' => sub {

        plan tests => 3;

        my $patron_2 = $builder->build_object( { class => 'Koha::Patrons' } );
        $t->post_ok( "//$userid:$password@/api/v1/patrons/"
                . $patron_2->id
                . '/extended_attributes' => json => { type => $unique_attr_type->code, value => 'non_repeatable_1' } )
            ->status_is(409)
            ->json_is( '/error' => 'Your action breaks a unique constraint on the attribute. type='
                . $unique_attr_type->code
                . ' value=non_repeatable_1' );
    };

    subtest 'Invalid type tests' => sub {

        plan tests => 3;

        my $invalid_type_obj = $builder->build_object( { class => 'Koha::Patron::Attribute::Types' } );
        my $invalid_type     = $invalid_type_obj->code;
        $invalid_type_obj->delete;

        $t->post_ok( "//$userid:$password@/api/v1/patrons/"
                . $patron->id
                . '/extended_attributes' => json => { type => $invalid_type, value => 'blah' } )
            ->status_is(400)
            ->json_is( '/error' => "Tried to use an invalid attribute type. type=$invalid_type" );
    };

    $schema->storage->txn_rollback;
};

subtest 'overwrite() tests' => sub {

    plan tests => 29;

    $schema->storage->txn_begin;

    Koha::Patron::Attribute::Types->delete;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**4 }    # 'borrowers' flag == 4
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    my $mandatory_attr_type = $builder->build_object(
        {
            class => 'Koha::Patron::Attribute::Types',
            value => {
                mandatory     => 1,
                repeatable    => 0,
                unique_id     => 0,
                category_code => undef
            }
        }
    );
    my $repeatable_attr_type = $builder->build_object(
        {
            class => 'Koha::Patron::Attribute::Types',
            value => {
                mandatory     => 0,
                repeatable    => 1,
                unique_id     => 0,
                category_code => undef
            }
        }
    );
    my $unique_attr_type = $builder->build_object(
        {
            class => 'Koha::Patron::Attribute::Types',
            value => {
                mandatory     => 0,
                repeatable    => 0,
                unique_id     => 1,
                category_code => undef
            }
        }
    );
    my $invalid_type_obj = $builder->build_object( { class => 'Koha::Patron::Attribute::Types' } );
    my $invalid_type     = $invalid_type_obj->code;
    $invalid_type_obj->delete;

    my $non_existent_patron    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $non_existent_patron_id = $non_existent_patron->id;

    # get rid of the patron
    $non_existent_patron->delete;

    $t->put_ok( "//$userid:$password@/api/v1/patrons/"
            . $non_existent_patron_id
            . '/extended_attributes' => json => [ { type => $repeatable_attr_type->code, value => 'something' } ] )
        ->status_is(404)
        ->json_is( '/error' => 'Patron not found' );

    $t->put_ok( "//$userid:$password@/api/v1/patrons/"
            . $patron->id
            . '/extended_attributes' => json => [ { type => $invalid_type, value => 'something' } ] )
        ->status_is(400)
        ->json_is( '/error' => "Tried to use an invalid attribute type. type=$invalid_type" );

    my $unique_value = 'The only one!';
    my $dummy_patron = $builder->build_object( { class => 'Koha::Patrons' } );
    $dummy_patron->add_extended_attribute( { code => $unique_attr_type->code, attribute => $unique_value } );

    $t->put_ok( "//$userid:$password@/api/v1/patrons/"
            . $patron->id
            . '/extended_attributes' => json => [ { type => $unique_attr_type->code, value => $unique_value } ] )
        ->status_is(409)
        ->json_is( '/error' => "Your action breaks a unique constraint on the attribute. type="
            . $unique_attr_type->code
            . " value=$unique_value" );

    my $value_1 = 'value_1';
    my $value_2 = 'value_2';

    $t->put_ok(
        "//$userid:$password@/api/v1/patrons/" . $patron->id . '/extended_attributes' => json => [
            { type => $unique_attr_type->code, value => $value_1 },
            { type => $unique_attr_type->code, value => $value_2 }
        ]
        )
        ->status_is(409)
        ->json_is( '/error' => "Tried to add more than one non-repeatable attributes. type="
            . $unique_attr_type->code
            . " value=$value_2" );

    $t->put_ok( "//$userid:$password@/api/v1/patrons/"
            . $patron->id
            . '/extended_attributes' => json => [ { type => $unique_attr_type->code, value => $value_1 } ] )
        ->status_is(400)
        ->json_is( '/error' => "Missing mandatory extended attribute (type=" . $mandatory_attr_type->code . ')' );

    $patron->add_extended_attribute( { code => $repeatable_attr_type->code, attribute => 'repeatable_1' } );
    $patron->add_extended_attribute( { code => $repeatable_attr_type->code, attribute => 'repeatable_2' } );
    $patron->add_extended_attribute( { code => $mandatory_attr_type->code,  attribute => 'mandatory' } );
    $patron->add_extended_attribute( { code => $unique_attr_type->code,     attribute => 'unique' } );

    $t->get_ok( "//$userid:$password@/api/v1/patrons/" . $patron->id . '/extended_attributes' )
        ->status_is( 200, 'REST3.2.2' )
        ->json_is( '' => $patron->extended_attributes->to_api, 'Extended attributes retrieved correctly' );

    my $updated_attributes = [
        {
            type  => $repeatable_attr_type->code,
            value => 'updated_repeatable_1'
        },
        {
            type  => $repeatable_attr_type->code,
            value => 'updated_repeatable_2'
        },
        {
            type  => $repeatable_attr_type->code,
            value => 'updated_repeatable_3'
        },
        {
            type  => $mandatory_attr_type->code,
            value => 'updated_mandatory'
        }
    ];

    $t->put_ok(
        "//$userid:$password@/api/v1/patrons/" . $patron->id . '/extended_attributes' => json => $updated_attributes )
        ->status_is(200)
        ->json_is( '/0/type'  => $updated_attributes->[0]->{type} )
        ->json_is( '/0/value' => $updated_attributes->[0]->{value} )
        ->json_is( '/1/type'  => $updated_attributes->[1]->{type} )
        ->json_is( '/1/value' => $updated_attributes->[1]->{value} )
        ->json_is( '/2/type'  => $updated_attributes->[2]->{type} )
        ->json_is( '/2/value' => $updated_attributes->[2]->{value} )
        ->json_is( '/3/type'  => $updated_attributes->[3]->{type} )
        ->json_is( '/3/value' => $updated_attributes->[3]->{value} )
        ->json_hasnt('/4');

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**4 }    # 'borrowers' flag == 4
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    my $attr_type = $builder->build_object(
        {
            class => 'Koha::Patron::Attribute::Types',
            value => {
                mandatory     => 0,
                repeatable    => 1,
                unique_id     => 0,
                category_code => undef
            }
        }
    );

    my $dummy_patron = $builder->build_object( { class => 'Koha::Patrons' } );

    my $attr = $dummy_patron->add_extended_attribute( { code => $attr_type->code, attribute => 'blah' } );

    $t->delete_ok( "//$userid:$password@/api/v1/patrons/" . $dummy_patron->id . '/extended_attributes/' . $attr->id )
        ->status_is( 204, 'REST3.2.4' )
        ->content_is( '', 'REST3.3.4' );

    $t->delete_ok( "//$userid:$password@/api/v1/patrons/" . $dummy_patron->id . '/extended_attributes/' . $attr->id )
        ->status_is(404)
        ->json_is( '/error' => 'Attribute not found' );

    $dummy_patron->delete;

    $t->delete_ok( "//$userid:$password@/api/v1/patrons/" . $dummy_patron->id . '/extended_attributes/' . $attr->id )
        ->status_is(404)
        ->json_is( '/error' => 'Patron not found' );

    $schema->storage->txn_rollback;
};

subtest 'update() tests' => sub {

    plan tests => 12;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**4 }    # 'borrowers' flag == 4
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    my $repeatable_attr_type = $builder->build_object(
        {
            class => 'Koha::Patron::Attribute::Types',
            value => {
                mandatory     => 0,
                repeatable    => 1,
                unique_id     => 0,
                category_code => undef
            }
        }
    );
    my $unique_attr_type = $builder->build_object(
        {
            class => 'Koha::Patron::Attribute::Types',
            value => {
                mandatory     => 0,
                repeatable    => 0,
                unique_id     => 1,
                category_code => undef
            }
        }
    );

    # Add a unique attribute to our patron
    my $unique_attribute = $patron->add_extended_attribute(
        {
            code      => $unique_attr_type->code,
            attribute => 'WOW'
        }
    );

    # Let's have an attribute ID we are sure doesn't exist on the DB
    my $non_existent_attribute = $patron->add_extended_attribute(
        {
            code      => $repeatable_attr_type->code,
            attribute => 'BOO'
        }
    );
    my $non_existent_attribute_id = $non_existent_attribute->id;
    $non_existent_attribute->delete;

    my $non_existent_patron    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $non_existent_patron_id = $non_existent_patron->id;

    # get rid of the patron
    $non_existent_patron->delete;

    $t->patch_ok( "//$userid:$password@/api/v1/patrons/"
            . $non_existent_patron_id
            . '/extended_attributes/'
            . 123 => json => { value => 'something' } )->status_is(404)->json_is( '/error' => 'Patron not found' );

    $t->patch_ok( "//$userid:$password@/api/v1/patrons/"
            . $patron->id
            . '/extended_attributes/'
            . $non_existent_attribute_id => json => { value => 'something' } )
        ->status_is(404)
        ->json_is( '/error' => 'Attribute not found' );

    my $response =
        $t->patch_ok( "//$userid:$password@/api/v1/patrons/"
            . $patron->id
            . '/extended_attributes/'
            . $unique_attribute->id => json => { value => 'HEY' } )->status_is(200)->tx->res->json;

    is_deeply(
        Koha::Patron::Attributes->find( $response->{extended_attribute_id} )->to_api,
        $response,
        "The returned object is on the DB"
    );

    my $unique_value = 'HEHE';

    # Add a patron with the unique attribute to test changing to it
    $builder->build_object( { class => 'Koha::Patrons' } )->add_extended_attribute(
        {
            code      => $unique_attr_type->code,
            attribute => $unique_value
        }
    );

    $t->patch_ok( "//$userid:$password@/api/v1/patrons/"
            . $patron->id
            . '/extended_attributes/'
            . $unique_attribute->id => json => { value => $unique_value } )
        ->status_is(409)
        ->json_is( '/error' => "Your action breaks a unique constraint on the attribute. type="
            . $unique_attr_type->code
            . " value=$unique_value" );

    $schema->storage->txn_rollback;
};
