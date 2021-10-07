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

use Test::More tests => 7;
use Test::MockModule;
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;
use t::lib::Dates;

use C4::Auth;
use Koha::Database;
use Koha::Exceptions::Patron;
use Koha::Exceptions::Patron::Attribute;
use Koha::Patron::Attributes;
use Koha::Patron::Debarments qw/AddDebarment/;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;
    unauthorized_access_tests('GET', undef, undef);
    $schema->storage->txn_rollback;

    subtest 'librarian access tests' => sub {
        plan tests => 16;

        $schema->storage->txn_begin;

        my $librarian = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { flags => 2**4 }    # borrowers flag = 4
            }
        );
        my $password = 'thePassword123';
        $librarian->set_password( { password => $password, skip_validation => 1 } );
        my $userid = $librarian->userid;

        $t->get_ok("//$userid:$password@/api/v1/patrons")
          ->status_is(200);

        $t->get_ok("//$userid:$password@/api/v1/patrons?cardnumber=" . $librarian->cardnumber)
          ->status_is(200)
          ->json_is('/0/cardnumber' => $librarian->cardnumber);

        $t->get_ok("//$userid:$password@/api/v1/patrons?q={\"cardnumber\":\"" . $librarian->cardnumber ."\"}")
          ->status_is(200)
          ->json_is('/0/cardnumber' => $librarian->cardnumber);

        $t->get_ok("//$userid:$password@/api/v1/patrons?address2=" . $librarian->address2)
          ->status_is(200)
          ->json_is('/0/address2' => $librarian->address2);

        my $patron = $builder->build_object({ class => 'Koha::Patrons' });
        AddDebarment({ borrowernumber => $patron->borrowernumber });

        $t->get_ok("//$userid:$password@/api/v1/patrons?restricted=" . Mojo::JSON->true . "&cardnumber=" . $patron->cardnumber )
          ->status_is(200)
          ->json_has('/0/restricted')
          ->json_is( '/0/restricted' => Mojo::JSON->true )
          ->json_hasnt('/1');

        $schema->storage->txn_rollback;
    };
};

subtest 'get() tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;
    unauthorized_access_tests('GET', -1, undef);
    $schema->storage->txn_rollback;

    subtest 'librarian access tests' => sub {
        plan tests => 6;

        $schema->storage->txn_begin;

        my $librarian = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { flags => 2**4 }    # borrowers flag = 4
            }
        );
        my $password = 'thePassword123';
        $librarian->set_password( { password => $password, skip_validation => 1 } );
        my $userid = $librarian->userid;

        my $patron = $builder->build_object({ class => 'Koha::Patrons' });

        $t->get_ok("//$userid:$password@/api/v1/patrons/" . $patron->id)
          ->status_is(200)
          ->json_is('/patron_id'        => $patron->id)
          ->json_is('/category_id'      => $patron->categorycode )
          ->json_is('/surname'          => $patron->surname)
          ->json_is('/patron_card_lost' => Mojo::JSON->false );

        $schema->storage->txn_rollback;
    };
};

subtest 'add() tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } )->to_api;

    unauthorized_access_tests('POST', undef, $patron);

    $schema->storage->txn_rollback;

    subtest 'librarian access tests' => sub {
        plan tests => 22;

        $schema->storage->txn_begin;

        my $extended_attrs_exception;
        my $type = 'hey';
        my $code = 'ho';
        my $attr = "Let's go";

        # Mock early, so existing mandatory attributes don't break all the tests
        my $mocked_patron = Test::MockModule->new('Koha::Patron');
        $mocked_patron->mock(
            'extended_attributes',
            sub {

                if ($extended_attrs_exception) {
                    if ( $extended_attrs_exception eq 'Koha::Exceptions::Patron::Attribute::NonRepeatable'
                        or $extended_attrs_exception eq 'Koha::Exceptions::Patron::Attribute::UniqueIDConstraint'
                      )
                    {
                        $extended_attrs_exception->throw(
                            attribute => Koha::Patron::Attribute->new(
                                { code => $code, attribute => $attr }
                            )
                        );
                    }
                    else {
                        $extended_attrs_exception->throw( type => $type );
                    }
                }
                return [];
            }
        );

        my $patron = $builder->build_object({ class => 'Koha::Patrons' });
        my $newpatron = $patron->to_api;
        # delete RO attributes
        delete $newpatron->{patron_id};
        delete $newpatron->{restricted};
        delete $newpatron->{anonymized};

        # Create a library just to make sure its ID doesn't exist on the DB
        my $library_to_delete = $builder->build_object({ class => 'Koha::Libraries' });
        my $deleted_library_id = $library_to_delete->id;
        # Delete library
        $library_to_delete->delete;

        my $librarian = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { flags => 2**4 }    # borrowers flag = 4
            }
        );
        my $password = 'thePassword123';
        $librarian->set_password( { password => $password, skip_validation => 1 } );
        my $userid = $librarian->userid;

        $newpatron->{library_id} = $deleted_library_id;

        warning_like {
            $t->post_ok("//$userid:$password@/api/v1/patrons" => json => $newpatron)
              ->status_is(409)
              ->json_is('/error' => "Duplicate ID"); }
            qr/DBD::mysql::st execute failed: Duplicate entry/;

        $newpatron->{library_id} = $patron->branchcode;

        # Create a library just to make sure its ID doesn't exist on the DB
        my $category_to_delete = $builder->build_object({ class => 'Koha::Patron::Categories' });
        my $deleted_category_id = $category_to_delete->id;
        # Delete library
        $category_to_delete->delete;

        $newpatron->{category_id} = $deleted_category_id; # Test invalid patron category

        $t->post_ok("//$userid:$password@/api/v1/patrons" => json => $newpatron)
          ->status_is(400)
          ->json_is('/error' => "Given category_id does not exist");
        $newpatron->{category_id} = $patron->categorycode;

        $newpatron->{falseproperty} = "Non existent property";

        $t->post_ok("//$userid:$password@/api/v1/patrons" => json => $newpatron)
          ->status_is(400);

        delete $newpatron->{falseproperty};

        my $patron_to_delete = $builder->build_object({ class => 'Koha::Patrons' });
        $newpatron = $patron_to_delete->to_api;
        # delete RO attributes
        delete $newpatron->{patron_id};
        delete $newpatron->{restricted};
        delete $newpatron->{anonymized};
        $patron_to_delete->delete;

        $t->post_ok("//$userid:$password@/api/v1/patrons" => json => $newpatron)
          ->status_is(201, 'Patron created successfully')
          ->header_like(
            Location => qr|^\/api\/v1\/patrons/\d*|,
            'SWAGGER3.4.1'
          )
          ->json_has('/patron_id', 'got a patron_id')
          ->json_is( '/cardnumber' => $newpatron->{ cardnumber })
          ->json_is( '/surname'    => $newpatron->{ surname })
          ->json_is( '/firstname'  => $newpatron->{ firstname });

        warning_like {
            $t->post_ok("//$userid:$password@/api/v1/patrons" => json => $newpatron)
              ->status_is(409)
              ->json_has( '/error', 'Fails when trying to POST duplicate cardnumber' )
              ->json_like( '/conflict' => qr/(borrowers\.)?cardnumber/ ); }
            qr/DBD::mysql::st execute failed: Duplicate entry '(.*?)' for key '(borrowers\.)?cardnumber'/;

        subtest 'extended_attributes handling tests' => sub {

            plan tests => 19;

            my $patrons_count = Koha::Patrons->search->count;

            $extended_attrs_exception = 'Koha::Exceptions::Patron::MissingMandatoryExtendedAttribute';
            $t->post_ok(
                "//$userid:$password@/api/v1/patrons" => json => {
                    "firstname"   => "Katrina",
                    "surname"     => "Fischer",
                    "address"     => "Somewhere",
                    "category_id" => "ST",
                    "city"        => "Konstanz",
                    "library_id"  => "MPL"
                }
            )->status_is(400)
              ->json_is( '/error' =>
                  "Missing mandatory extended attribute (type=$type)" );

            is( Koha::Patrons->search->count, $patrons_count, 'No patron added' );

            $extended_attrs_exception = 'Koha::Exceptions::Patron::Attribute::InvalidType';
            $t->post_ok(
                "//$userid:$password@/api/v1/patrons" => json => {
                    "firstname"   => "Katrina",
                    "surname"     => "Fischer",
                    "address"     => "Somewhere",
                    "category_id" => "ST",
                    "city"        => "Konstanz",
                    "library_id"  => "MPL"
                }
            )->status_is(400)
              ->json_is( '/error' =>
                  "Tried to use an invalid attribute type. type=$type" );

            is( Koha::Patrons->search->count, $patrons_count, 'No patron added' );

            $extended_attrs_exception = 'Koha::Exceptions::Patron::Attribute::NonRepeatable';
            $t->post_ok(
                "//$userid:$password@/api/v1/patrons" => json => {
                    "firstname"   => "Katrina",
                    "surname"     => "Fischer",
                    "address"     => "Somewhere",
                    "category_id" => "ST",
                    "city"        => "Konstanz",
                    "library_id"  => "MPL"
                }
            )->status_is(400)
              ->json_is( '/error' =>
                  "Tried to add more than one non-repeatable attributes. type=$code value=$attr" );

            is( Koha::Patrons->search->count, $patrons_count, 'No patron added' );

            $extended_attrs_exception = 'Koha::Exceptions::Patron::Attribute::UniqueIDConstraint';
            $t->post_ok(
                "//$userid:$password@/api/v1/patrons" => json => {
                    "firstname"   => "Katrina",
                    "surname"     => "Fischer",
                    "address"     => "Somewhere",
                    "category_id" => "ST",
                    "city"        => "Konstanz",
                    "library_id"  => "MPL"
                }
            )->status_is(400)
              ->json_is( '/error' =>
                  "Your action breaks a unique constraint on the attribute. type=$code value=$attr" );

            is( Koha::Patrons->search->count, $patrons_count, 'No patron added' );

            $mocked_patron->unmock('extended_attributes');
            # Temporarily get rid of mandatory attribute types
            Koha::Patron::Attribute::Types->search({ mandatory => 1 })->delete;
            # Create a couple attribute attribute types
            my $repeatable_1 = $builder->build_object(
                {
                    class => 'Koha::Patron::Attribute::Types',
                    value => {
                        mandatory     => 0,
                        repeatable    => 1,
                        unique        => 0,
                        category_code => 'ST'
                    }
                }
            );
            my $repeatable_2 = $builder->build_object(
                {
                    class => 'Koha::Patron::Attribute::Types',
                    value => {
                        mandatory     => 0,
                        repeatable    => 1,
                        unique        => 0,
                        category_code => 'ST'
                    }
                }
            );

            my $patron_id = $t->post_ok(
                "//$userid:$password@/api/v1/patrons" => json => {
                    "firstname"   => "Katrina",
                    "surname"     => "Fischer",
                    "address"     => "Somewhere",
                    "category_id" => "ST",
                    "city"        => "Konstanz",
                    "library_id"  => "MPL",
                    "extended_attributes" => [
                        { type => $repeatable_1->code, value => 'a' },
                        { type => $repeatable_1->code, value => 'b' },
                        { type => $repeatable_1->code, value => 'c' },
                        { type => $repeatable_2->code, value => 'd' },
                        { type => $repeatable_2->code, value => 'e' }
                    ]
                }
            )->status_is(201, 'Patron added')->tx->res->json->{patron_id};
            my $extended_attributes = join( ' ', sort map {$_->attribute} Koha::Patrons->find($patron_id)->extended_attributes->as_list);
            is( $extended_attributes, 'a b c d e', 'Extended attributes are stored correctly');
        };

        $schema->storage->txn_rollback;
    };
};

subtest 'update() tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;
    unauthorized_access_tests('PUT', 123, {email => 'nobody@example.com'});
    $schema->storage->txn_rollback;

    subtest 'librarian access tests' => sub {
        plan tests => 42;

        $schema->storage->txn_begin;

        my $authorized_patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { flags => 1 }
            }
        );
        my $password = 'thePassword123';
        $authorized_patron->set_password(
            { password => $password, skip_validation => 1 } );
        my $userid = $authorized_patron->userid;

        my $unauthorized_patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { flags => 0 }
            }
        );
        $unauthorized_patron->set_password( { password => $password, skip_validation => 1 } );
        my $unauth_userid = $unauthorized_patron->userid;

        my $patron_1  = $authorized_patron;
        my $patron_2  = $unauthorized_patron;
        my $newpatron = $unauthorized_patron->to_api;
        # delete RO attributes
        delete $newpatron->{patron_id};
        delete $newpatron->{restricted};
        delete $newpatron->{anonymized};

        $t->put_ok("//$userid:$password@/api/v1/patrons/-1" => json => $newpatron)
          ->status_is(404)
          ->json_has('/error', 'Fails when trying to PUT nonexistent patron');

        # Create a library just to make sure its ID doesn't exist on the DB
        my $category_to_delete = $builder->build_object({ class => 'Koha::Patron::Categories' });
        my $deleted_category_id = $category_to_delete->id;
        # Delete library
        $category_to_delete->delete;

        # Use an invalid category
        $newpatron->{category_id} = $deleted_category_id;

        $t->put_ok("//$userid:$password@/api/v1/patrons/" . $patron_2->borrowernumber => json => $newpatron)
          ->status_is(400)
          ->json_is('/error' => "Given category_id does not exist");

        # Restore the valid category
        $newpatron->{category_id} = $patron_2->categorycode;

        # Create a library just to make sure its ID doesn't exist on the DB
        my $library_to_delete = $builder->build_object({ class => 'Koha::Libraries' });
        my $deleted_library_id = $library_to_delete->id;
        # Delete library
        $library_to_delete->delete;

        # Use an invalid library_id
        $newpatron->{library_id} = $deleted_library_id;

        warning_like {
            $t->put_ok("//$userid:$password@/api/v1/patrons/" . $patron_2->borrowernumber => json => $newpatron)
              ->status_is(400)
              ->json_is('/error' => "Given library_id does not exist"); }
            qr/DBD::mysql::st execute failed: Cannot add or update a child row: a foreign key constraint fails/;

        # Restore the valid library_id
        $newpatron->{library_id} = $patron_2->branchcode;

        # Use an invalid attribute
        $newpatron->{falseproperty} = "Non existent property";

        $t->put_ok( "//$userid:$password@/api/v1/patrons/" . $patron_2->borrowernumber => json => $newpatron )
          ->status_is(400)
          ->json_is('/errors/0/message' =>
                    'Properties not allowed: falseproperty.');

        # Get rid of the invalid attribute
        delete $newpatron->{falseproperty};

        # Set both cardnumber and userid to already existing values
        $newpatron->{cardnumber} = $patron_1->cardnumber;
        $newpatron->{userid}     = $patron_1->userid;

        warning_like {
            $t->put_ok( "//$userid:$password@/api/v1/patrons/" . $patron_2->borrowernumber => json => $newpatron )
              ->status_is(409)
              ->json_has( '/error', "Fails when trying to update to an existing cardnumber or userid")
              ->json_like( '/conflict' => qr/(borrowers\.)?cardnumber/ ); }
            qr/DBD::mysql::st execute failed: Duplicate entry '(.*?)' for key '(borrowers\.)?cardnumber'/;

        $newpatron->{ cardnumber } = $patron_1->id . $patron_2->id;
        $newpatron->{ userid }     = "user" . $patron_1->id.$patron_2->id;
        $newpatron->{ surname }    = "user" . $patron_1->id.$patron_2->id;

        ## Trying to set to null on specially handled cases
        # Special case: a date
        $newpatron->{ date_of_birth } = undef;
        # Special case: a date-time
        $newpatron->{ last_seen } = undef;

        my $result = $t->put_ok( "//$userid:$password@/api/v1/patrons/" . $patron_2->borrowernumber => json => $newpatron )
          ->status_is(200, 'Patron updated successfully');

        # Put back the RO attributes
        $newpatron->{patron_id} = $unauthorized_patron->to_api->{patron_id};
        $newpatron->{restricted} = $unauthorized_patron->to_api->{restricted};
        $newpatron->{anonymized} = $unauthorized_patron->to_api->{anonymized};

        my $got = $result->tx->res->json;
        my $updated_on_got = delete $got->{updated_on};
        my $updated_on_expected = delete $newpatron->{updated_on};
        is_deeply($got, $newpatron, 'Returned patron from update matches expected');
        t::lib::Dates::compare( $updated_on_got, $updated_on_expected, 'updated_on values matched' );


        is(Koha::Patrons->find( $patron_2->id )->cardnumber,
           $newpatron->{ cardnumber }, 'Patron is really updated!');

        my $superlibrarian = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { flags => 1 }
            }
        );

        $newpatron->{cardnumber} = $superlibrarian->cardnumber;
        $newpatron->{userid}     = $superlibrarian->userid;
        $newpatron->{email}      = 'nosense@no.no';
        # delete RO attributes
        delete $newpatron->{patron_id};
        delete $newpatron->{restricted};
        delete $newpatron->{anonymized};

        # attempt to update
        $authorized_patron->flags( 2**4 )->store; # borrowers flag = 4
        $t->put_ok( "//$userid:$password@/api/v1/patrons/" . $superlibrarian->borrowernumber => json => $newpatron )
          ->status_is(403, "Non-superlibrarian user change of superlibrarian email forbidden")
          ->json_is( { error => "Not enough privileges to change a superlibrarian's email" } );

        # attempt to unset
        $newpatron->{email} = undef;
        $t->put_ok( "//$userid:$password@/api/v1/patrons/" . $superlibrarian->borrowernumber => json => $newpatron )
          ->status_is(403, "Non-superlibrarian user change of superlibrarian email to undefined forbidden")
          ->json_is( { error => "Not enough privileges to change a superlibrarian's email" } );

        $newpatron->{email}           = $superlibrarian->email;
        $newpatron->{secondary_email} = 'nonsense@no.no';

        # attempt to update
        $t->put_ok( "//$userid:$password@/api/v1/patrons/" . $superlibrarian->borrowernumber => json => $newpatron )
          ->status_is(403, "Non-superlibrarian user change of superlibrarian secondary_email forbidden")
          ->json_is( { error => "Not enough privileges to change a superlibrarian's email" } );

        # attempt to unset
        $newpatron->{secondary_email} = undef;
        $t->put_ok( "//$userid:$password@/api/v1/patrons/" . $superlibrarian->borrowernumber => json => $newpatron )
          ->status_is(403, "Non-superlibrarian user change of superlibrarian secondary_email to undefined forbidden")
          ->json_is( { error => "Not enough privileges to change a superlibrarian's email" } );

        $newpatron->{secondary_email}  = $superlibrarian->emailpro;
        $newpatron->{altaddress_email} = 'nonsense@no.no';

        # attempt to update
        $t->put_ok( "//$userid:$password@/api/v1/patrons/" . $superlibrarian->borrowernumber => json => $newpatron )
          ->status_is(403, "Non-superlibrarian user change of superlibrarian altaddress_email forbidden")
          ->json_is( { error => "Not enough privileges to change a superlibrarian's email" } );

        # attempt to unset
        $newpatron->{altaddress_email} = undef;
        $t->put_ok( "//$userid:$password@/api/v1/patrons/" . $superlibrarian->borrowernumber => json => $newpatron )
          ->status_is(403, "Non-superlibrarian user change of superlibrarian altaddress_email to undefined forbidden")
          ->json_is( { error => "Not enough privileges to change a superlibrarian's email" } );

        # update patron without sending email
        delete $newpatron->{email};
        delete $newpatron->{secondary_email};
        delete $newpatron->{altaddress_email};
        $t->put_ok( "//$userid:$password@/api/v1/patrons/" . $superlibrarian->borrowernumber => json => $newpatron )
          ->status_is(200, "Non-superlibrarian user can edit superlibrarian successfully if not changing email");
#  ->json_is( { error => "Not enough privileges to change a superlibrarian's email" } );

        $schema->storage->txn_rollback;
    };
};

subtest 'delete() tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;
    unauthorized_access_tests('DELETE', 123, undef);
    $schema->storage->txn_rollback;

    subtest 'librarian access test' => sub {
        plan tests => 8;

        $schema->storage->txn_begin;

        my $authorized_patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { flags => 2**4 }    # borrowers flag = 4
            }
        );
        my $password = 'thePassword123';
        $authorized_patron->set_password(
            { password => $password, skip_validation => 1 } );
        my $userid = $authorized_patron->userid;

        $t->delete_ok("//$userid:$password@/api/v1/patrons/-1")
          ->status_is(404, 'Patron not found');

        my $patron = $builder->build_object({ class => 'Koha::Patrons' });

        t::lib::Mocks::mock_preference('AnonymousPatron', $patron->borrowernumber);
        $t->delete_ok("//$userid:$password@/api/v1/patrons/" . $patron->borrowernumber)
          ->status_is(403, 'Anonymous patron cannot be deleted')
          ->json_is( { error => 'Anonymous patron cannot be deleted' } );

        t::lib::Mocks::mock_preference('AnonymousPatron', 0); # back to default
        $t->delete_ok("//$userid:$password@/api/v1/patrons/" . $patron->borrowernumber)
          ->status_is(204, 'SWAGGER3.2.4')
          ->content_is('', 'SWAGGER3.3.4');

        $schema->storage->txn_rollback;
    };
};

subtest 'guarantors_can_see_charges() tests' => sub {

    plan tests => 11;

    t::lib::Mocks::mock_preference( 'RESTPublicAPI', 1 );
    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

    $schema->storage->txn_begin;

    my $patron = $builder->build_object({ class => 'Koha::Patrons', value => { privacy_guarantor_fines => 0 } });
    my $password = 'thePassword123';
    $patron->set_password({ password => $password, skip_validation => 1 });
    my $userid = $patron->userid;
    my $patron_id = $patron->borrowernumber;

    t::lib::Mocks::mock_preference( 'AllowPatronToSetFinesVisibilityForGuarantor', 0 );

    $t->put_ok( "//$userid:$password@/api/v1/public/patrons/$patron_id/guarantors/can_see_charges" => json => { allowed => Mojo::JSON->true } )
      ->status_is( 403 )
      ->json_is( '/error', 'The current configuration doesn\'t allow the requested action.' );

    t::lib::Mocks::mock_preference( 'AllowPatronToSetFinesVisibilityForGuarantor', 1 );

    $t->put_ok( "//$userid:$password@/api/v1/public/patrons/$patron_id/guarantors/can_see_charges" => json => { allowed => Mojo::JSON->true } )
      ->status_is( 200 )
      ->json_is( {} );

    ok( $patron->discard_changes->privacy_guarantor_fines, 'privacy_guarantor_fines has been set correctly' );

    $t->put_ok( "//$userid:$password@/api/v1/public/patrons/$patron_id/guarantors/can_see_charges" => json => { allowed => Mojo::JSON->false } )
      ->status_is( 200 )
      ->json_is( {} );

    ok( !$patron->discard_changes->privacy_guarantor_fines, 'privacy_guarantor_fines has been set correctly' );

    $schema->storage->txn_rollback;
};

subtest 'guarantors_can_see_checkouts() tests' => sub {

    plan tests => 11;

    t::lib::Mocks::mock_preference( 'RESTPublicAPI', 1 );
    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

    $schema->storage->txn_begin;

    my $patron = $builder->build_object({ class => 'Koha::Patrons', value => { privacy_guarantor_checkouts => 0 } });
    my $password = 'thePassword123';
    $patron->set_password({ password => $password, skip_validation => 1 });
    my $userid = $patron->userid;
    my $patron_id = $patron->borrowernumber;

    t::lib::Mocks::mock_preference( 'AllowPatronToSetCheckoutsVisibilityForGuarantor', 0 );

    $t->put_ok( "//$userid:$password@/api/v1/public/patrons/$patron_id/guarantors/can_see_checkouts" => json => { allowed => Mojo::JSON->true } )
      ->status_is( 403 )
      ->json_is( '/error', 'The current configuration doesn\'t allow the requested action.' );

    t::lib::Mocks::mock_preference( 'AllowPatronToSetCheckoutsVisibilityForGuarantor', 1 );

    $t->put_ok( "//$userid:$password@/api/v1/public/patrons/$patron_id/guarantors/can_see_checkouts" => json => { allowed => Mojo::JSON->true } )
      ->status_is( 200 )
      ->json_is( {} );

    ok( $patron->discard_changes->privacy_guarantor_checkouts, 'privacy_guarantor_checkouts has been set correctly' );

    $t->put_ok( "//$userid:$password@/api/v1/public/patrons/$patron_id/guarantors/can_see_checkouts" => json => { allowed => Mojo::JSON->false } )
      ->status_is( 200 )
      ->json_is( {} );

    ok( !$patron->discard_changes->privacy_guarantor_checkouts, 'privacy_guarantor_checkouts has been set correctly' );

    $schema->storage->txn_rollback;
};

# Centralized tests for 401s and 403s assuming the endpoint requires
# borrowers flag for access
sub unauthorized_access_tests {
    my ($verb, $patron_id, $json) = @_;

    my $endpoint = '/api/v1/patrons';
    $endpoint .= ($patron_id) ? "/$patron_id" : '';

    subtest 'unauthorized access tests' => sub {
        plan tests => 5;

        my $verb_ok = lc($verb) . '_ok';

        $t->$verb_ok($endpoint => json => $json)
          ->status_is(401);

        my $unauthorized_patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { flags => 0 }
            }
        );
        my $password = "thePassword123!";
        $unauthorized_patron->set_password(
            { password => $password, skip_validation => 1 } );
        my $unauth_userid = $unauthorized_patron->userid;

        $t->$verb_ok( "//$unauth_userid:$password\@$endpoint" => json => $json )
          ->status_is(403)
          ->json_has('/required_permissions');
    };
}
