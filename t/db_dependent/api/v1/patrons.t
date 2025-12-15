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
use Test::More tests => 8;
use Test::MockModule;
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;
use t::lib::Dates;

use C4::Auth;
use C4::Members::Messaging;
use Koha::Database;
use Koha::DateUtils qw(dt_from_string output_pref);
use Koha::Exceptions::Patron;
use Koha::Exceptions::Patron::Attribute;
use Koha::Old::Patrons;
use Koha::Patron::Attributes;
use Koha::Patron::Debarments qw( AddDebarment );
use Koha::Notice::Messages;

use JSON qw(encode_json);

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

### Mock Letters
my $mocked_letters = Test::MockModule->new('C4::Letters');
$mocked_letters->mock(
    'GetPreparedLetter',
    sub {
        return 1;
    }
);
my $message_has_content = 1;
my $letter_enqueued;
$mocked_letters->mock(
    'EnqueueLetter',
    sub {
        $letter_enqueued = $message_has_content ? 1 : 0;

        # return a 'message_id'
        return $message_has_content ? 42 : undef;
    }
);
$mocked_letters->mock(
    'SendQueuedMessages',
    sub {
        my $params = shift;
        return 1;
    }
);

subtest 'list() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;
    unauthorized_access_tests( 'GET', undef, undef );
    $schema->storage->txn_rollback;

    subtest 'librarian access tests' => sub {

        plan tests => 15;

        $schema->storage->txn_begin;

        my $librarian = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { flags => 2**2 }    # catalog only, no additional permissions
            }
        );

        # Ensure our librarian can see users from all branches (once list_borrowers is added)
        $builder->build(
            {
                source => 'UserPermission',
                value  => {
                    borrowernumber => $librarian->borrowernumber,
                    module_bit     => 4,
                    code           => 'view_borrower_infos_from_any_libraries',
                },
            }
        );

        my $password = 'thePassword123';
        $librarian->set_password( { password => $password, skip_validation => 1 } );
        my $userid = $librarian->userid;

        $t->get_ok("//$userid:$password@/api/v1/patrons/")->status_is( 403, 'Basic librarian unable to see patrons' );

        $builder->build(
            {
                source => 'UserPermission',
                value  => {
                    borrowernumber => $librarian->borrowernumber,
                    module_bit     => 4,
                    code           => 'list_borrowers',
                },
            }
        );

        $t->get_ok("//$userid:$password@/api/v1/patrons")->status_is( 200, 'list_borrowers makes /patrons accessible' );

        $t->get_ok( "//$userid:$password@/api/v1/patrons?cardnumber=" . $librarian->cardnumber )->status_is(200)
            ->json_is( '/0/cardnumber' => $librarian->cardnumber );

        $t->get_ok( "//$userid:$password@/api/v1/patrons?q={\"cardnumber\":\"" . $librarian->cardnumber . "\"}" )
            ->status_is(200)->json_is( '/0/cardnumber' => $librarian->cardnumber );

        $t->get_ok( "//$userid:$password@/api/v1/patrons?address2=" . $librarian->address2 )->status_is(200)
            ->json_is( '/0/address2' => $librarian->address2 );

        subtest 'restricted & expired' => sub {

            plan tests => 13;

            my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

            AddDebarment( { borrowernumber => $patron->borrowernumber } );

            $t->get_ok( "//$userid:$password@/api/v1/patrons?restricted="
                    . Mojo::JSON->true
                    . "&cardnumber="
                    . $patron->cardnumber )->status_is(200)->json_has('/0/restricted')
                ->json_is( '/0/restricted' => Mojo::JSON->true )->json_has('/0/expired')
                ->json_is( '/0/expired'    => Mojo::JSON->false )->json_hasnt('/1');

            $patron->dateexpiry( dt_from_string->subtract( days => 2 ) )->store;
            $t->get_ok( "//$userid:$password@/api/v1/patrons/" . $patron->borrowernumber )->status_is(200)
                ->json_has('/expired')->json_is( '/expired' => Mojo::JSON->true );

            $t->get_ok( "//$userid:$password@/api/v1/patrons?"
                    . 'q={"extended_attributes.type":"CODE"}' => { 'x-koha-embed' => 'extended_attributes' } )
                ->status_is( 200, "Works, doesn't explode" );
        };

        subtest 'searching date and date-time fields' => sub {

            plan tests => 12;

            my $date_of_birth = '1980-06-18';
            my $last_seen     = '2021-06-25 14:05:35';

            my $patron = $builder->build_object(
                {
                    class => 'Koha::Patrons',
                    value => {
                        dateofbirth => $date_of_birth,
                        lastseen    => $last_seen,
                    }
                }
            );

            my $last_seen_rfc3339 = $last_seen . "z";

            $t->get_ok( "//$userid:$password@/api/v1/patrons?date_of_birth="
                    . $date_of_birth
                    . "&cardnumber="
                    . $patron->cardnumber )->status_is(200)
                ->json_is( '/0/patron_id' => $patron->id, 'Filtering by date works' );

            $t->get_ok( "//$userid:$password@/api/v1/patrons?last_seen="
                    . $last_seen_rfc3339
                    . "&cardnumber="
                    . $patron->cardnumber )->status_is(200)
                ->json_is( '/0/patron_id' => $patron->id, 'Filtering by date-time works' );

            my $q = encode_json(
                {
                    date_of_birth => $date_of_birth,
                    cardnumber    => $patron->cardnumber,
                }
            );

            $t->get_ok("//$userid:$password@/api/v1/patrons?q=$q")->status_is(200)
                ->json_is( '/0/patron_id' => $patron->id, 'Filtering by date works' );

            $q = encode_json(
                {
                    last_seen  => $last_seen_rfc3339,
                    cardnumber => $patron->cardnumber,
                }
            );

            $t->get_ok("//$userid:$password@/api/v1/patrons?q=$q")->status_is(200)
                ->json_is( '/0/patron_id' => $patron->id, 'Filtering by date-time works' );
        };

        $schema->storage->txn_rollback;
    };

    subtest 'search_limited() tests' => sub {

        plan tests => 9;

        $schema->storage->txn_begin;

        my $library_1 = $builder->build_object( { class => 'Koha::Libraries' } );
        my $library_2 = $builder->build_object( { class => 'Koha::Libraries' } );

        my $patron_1 =
            $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $library_1->id } } );
        my $patron_2 =
            $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $library_1->id } } );
        my $patron_3 =
            $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $library_2->id } } );

        my @libraries_where_can_see_patrons = ( $library_1->id, $library_2->id );

        my $mocked_patron = Test::MockModule->new('Koha::Patron');
        $mocked_patron->mock(
            'libraries_where_can_see_patrons',
            sub {
                return @libraries_where_can_see_patrons;
            }
        );

        my $librarian = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { flags => 2**4 }    # borrowers flag = 4
            }
        );
        my $password = 'thePassword123';
        $librarian->set_password( { password => $password, skip_validation => 1 } );
        my $userid = $librarian->userid;

        $t->get_ok( "//$userid:$password@/api/v1/patrons?_order_by=patron_id&q="
                . encode_json( { library_id => [ $library_1->id, $library_2->id ] } ) )->status_is(200)
            ->json_is( '/0/patron_id' => $patron_1->id )->json_is( '/1/patron_id' => $patron_2->id )
            ->json_is( '/2/patron_id' => $patron_3->id );

        @libraries_where_can_see_patrons = ( $library_2->id );

        my $res =
            $t->get_ok( "//$userid:$password@/api/v1/patrons?_order_by=patron_id&q="
                . encode_json( { library_id => [ $library_1->id, $library_2->id ] } ) )->status_is(200)
            ->json_is( '/0/patron_id' => $patron_3->id, 'Returns the only allowed patron' )->tx->res->json;

        is( scalar @{$res}, 1, 'Only one patron returned' );

        $schema->storage->txn_rollback;
    };
};

subtest 'get() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;
    unauthorized_access_tests( 'GET', -1, undef );
    $schema->storage->txn_rollback;

    subtest 'librarian access tests' => sub {

        plan tests => 8;

        $schema->storage->txn_begin;

        my $librarian = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { flags => 2**2 }    # catalog only, no additional permissions
            }
        );

        # Ensure our librarian can see users from all branches (once list_borrowers is added)
        $builder->build(
            {
                source => 'UserPermission',
                value  => {
                    borrowernumber => $librarian->borrowernumber,
                    module_bit     => 4,
                    code           => 'view_borrower_infos_from_any_libraries',
                },
            }
        );

        my $password = 'thePassword123';
        $librarian->set_password( { password => $password, skip_validation => 1 } );
        my $userid = $librarian->userid;

        my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

        $t->get_ok( "//$userid:$password@/api/v1/patrons/" . $patron->id )
            ->status_is( 403, 'Basic librarian unable to see patrons' );

        $builder->build(
            {
                source => 'UserPermission',
                value  => {
                    borrowernumber => $librarian->borrowernumber,
                    module_bit     => 4,
                    code           => 'list_borrowers',
                },
            }
        );

        $t->get_ok( "//$userid:$password@/api/v1/patrons/" . $patron->id )
            ->status_is( 200, 'list_borrowers permission makes patron visible' )
            ->json_is( '/patron_id' => $patron->id )->json_is( '/category_id' => $patron->categorycode )
            ->json_is( '/surname'   => $patron->surname )->json_is( '/patron_card_lost' => Mojo::JSON->false );

        $schema->storage->txn_rollback;
    };

    subtest 'search_limited() tests' => sub {

        plan tests => 12;

        $schema->storage->txn_begin;

        my $library_1 = $builder->build_object( { class => 'Koha::Libraries' } );
        my $library_2 = $builder->build_object( { class => 'Koha::Libraries' } );
        my $library_3 = $builder->build_object( { class => 'Koha::Libraries' } );

        my $patron_1 =
            $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $library_1->id } } );
        my $patron_2 =
            $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $library_2->id } } );
        my $patron_3 =
            $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $library_3->id } } );

        my @libraries_where_can_see_patrons = ( $library_1->id, $library_2->id );

        my $mocked_patron = Test::MockModule->new('Koha::Patron');
        $mocked_patron->mock(
            'libraries_where_can_see_patrons',
            sub {
                return @libraries_where_can_see_patrons;
            }
        );

        my $librarian = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { flags => 2**4, branchcode => $library_3->id }    # borrowers flag = 4
            }
        );
        my $password = 'thePassword123';
        $librarian->set_password( { password => $password, skip_validation => 1 } );
        my $userid = $librarian->userid;

        $t->get_ok( "//$userid:$password@/api/v1/patrons/" . $patron_1->id )->status_is(200)
            ->json_is( '/patron_id' => $patron_1->id );

        $t->get_ok( "//$userid:$password@/api/v1/patrons/" . $patron_2->id )->status_is(200)
            ->json_is( '/patron_id' => $patron_2->id );

        @libraries_where_can_see_patrons = ( $library_1->id );

        $t->get_ok( "//$userid:$password@/api/v1/patrons/" . $patron_1->id )->status_is(200)
            ->json_is( '/patron_id' => $patron_1->id );

        $t->get_ok( "//$userid:$password@/api/v1/patrons/" . $patron_2->id )->status_is(404)
            ->json_is( '/error' => 'Patron not found' );

        $schema->storage->txn_rollback;
    };

    subtest '+strings' => sub {

        plan tests => 4;

        $schema->storage->txn_begin;

        my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

        my $librarian = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { flags => 2**4 }    # borrowers flag = 4
            }
        );
        my $password = 'thePassword123';
        $librarian->set_password( { password => $password, skip_validation => 1 } );
        my $userid = $librarian->userid;

        $t->get_ok( "//$userid:$password@/api/v1/patrons/" . $patron->id => { "x-koha-embed" => "+strings" } )
            ->status_is(200)
            ->json_has( '/_strings/library_id' => { str => $patron->library->branchname, type => 'library' } )
            ->json_has(
            '/_strings/category_id' => { str => $patron->category->description, type => 'patron_category' } );

        $schema->storage->txn_rollback;
    };
};

subtest 'add() tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**4 }    # borrowers flag = 4
        }
    );
    my $patron = $builder->build_object( { class => 'Koha::Patrons' } )->to_api( { user => $librarian } );

    unauthorized_access_tests( 'POST', undef, $patron );

    $schema->storage->txn_rollback;

    subtest 'librarian access tests' => sub {
        plan tests => 40;

        $schema->storage->txn_begin;

        my $extended_attrs_exception;
        my $type = 'hey';
        my $code = 'ho';
        my $attr = "Let's go";

        # Disable trigger to notify patrons of password changes for these tests
        t::lib::Mocks::mock_preference( 'NotifyPasswordChange', 0 );

        # Mock early, so existing mandatory attributes don't break all the tests
        my $mocked_patron = Test::MockModule->new('Koha::Patron');

        my $librarian = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { flags => 2**4 }    # borrowers flag = 4
            }
        );

        my $patron    = $builder->build_object( { class => 'Koha::Patrons' } );
        my $newpatron = $patron->to_api( { user => $librarian } );

        # delete RO attributes
        delete $newpatron->{patron_id};
        delete $newpatron->{restricted};
        delete $newpatron->{expired};
        delete $newpatron->{anonymized};

        my $password = 'thePassword123';
        $librarian->set_password( { password => $password, skip_validation => 1 } );
        my $userid = $librarian->userid;
        t::lib::Mocks::mock_preference( 'PatronDuplicateMatchingAddFields', 'firstname|surname|dateofbirth' );

        $t->post_ok( "//$userid:$password@/api/v1/patrons" => json => $newpatron )->status_is(409)
            ->json_is( '/error' => "A patron record matching these details already exists" );

        # Create a library just to make sure its ID doesn't exist on the DB
        my $library_to_delete  = $builder->build_object( { class => 'Koha::Libraries' } );
        my $deleted_library_id = $library_to_delete->id;

        # Delete library
        $library_to_delete->delete;

        $newpatron->{library_id} = $deleted_library_id;

        # Test duplicate userid constraint
        $t->post_ok( "//$userid:$password@/api/v1/patrons" => { 'x-confirm-not-duplicate' => 1 } => json => $newpatron )
            ->status_is(400)->json_is( '/error' => "Problem with " . $newpatron->{userid} );

        $newpatron->{library_id} = $patron->branchcode;

        # Test duplicate cardnumber constraint
        $newpatron->{userid} = undef;    # force regeneration
        warning_like {
            $t->post_ok(
                "//$userid:$password@/api/v1/patrons" => { 'x-confirm-not-duplicate' => 1 } => json => $newpatron )
                ->status_is(409)->json_has( '/error', 'Fails when trying to POST duplicate cardnumber' )
                ->json_like( '/conflict' => qr/(borrowers\.)?cardnumber/ );
        }
        qr/DBD::mysql::st execute failed: Duplicate entry '(.*?)' for key '(borrowers\.)?cardnumber'/;

        # Create a library just to make sure its ID doesn't exist on the DB
        my $category_to_delete  = $builder->build_object( { class => 'Koha::Patron::Categories' } );
        my $deleted_category_id = $category_to_delete->id;

        # Delete library
        $category_to_delete->delete;

        $newpatron->{category_id} = $deleted_category_id;    # Test invalid patron category

        $t->post_ok( "//$userid:$password@/api/v1/patrons" => { 'x-confirm-not-duplicate' => 1 } => json => $newpatron )
            ->status_is(400)->json_is( '/error' => "Given category_id does not exist" );
        $newpatron->{category_id} = $patron->categorycode;

        $newpatron->{falseproperty} = "Non existent property";

        $t->post_ok( "//$userid:$password@/api/v1/patrons" => json => $newpatron )->status_is(400);

        delete $newpatron->{falseproperty};

        my $patron_to_delete = $builder->build_object( { class => 'Koha::Patrons' } );
        $newpatron = $patron_to_delete->to_api( { user => $librarian } );

        # delete RO attributes
        delete $newpatron->{patron_id};
        delete $newpatron->{restricted};
        delete $newpatron->{expired};
        delete $newpatron->{anonymized};
        $patron_to_delete->delete;

        # Set a date field
        $newpatron->{date_of_birth} = '1980-06-18';

        # Set a date-time field
        $newpatron->{last_seen} = output_pref( { dt => dt_from_string->add( days => -1 ), dateformat => 'rfc3339' } );

        # Test welcome email sending with AutoEmailNewUser = 0 but welcome_yes override
        t::lib::Mocks::mock_preference( 'AutoEmailNewUser', 0 );
        $letter_enqueued = 0;
        $t->post_ok(
            "//$userid:$password@/api/v1/patrons" => { 'x-koha-override' => 'welcome_yes' } => json => $newpatron )
            ->status_is( 201, 'Patron created successfully' )->header_like(
            Location => qr|^\/api\/v1\/patrons/\d*|,
            'REST3.4.1'
        )->json_has( '/patron_id', 'got a patron_id' )->json_is( '/cardnumber' => $newpatron->{cardnumber} )
            ->json_is( '/surname'       => $newpatron->{surname} )->json_is( '/firstname' => $newpatron->{firstname} )
            ->json_is( '/date_of_birth' => $newpatron->{date_of_birth}, 'Date field set (Bug 28585)' )
            ->json_is( '/last_seen'     => $newpatron->{last_seen},     'Date-time field set (Bug 28585)' );

        my $p = Koha::Patrons->find( { cardnumber => $newpatron->{cardnumber} } );
        is( $letter_enqueued, 1, "Patron got welcome notice due to welcome_yes override" );

        # Test when AutoEmailNewUser = 1 but welcome_no override
        $newpatron->{cardnumber} = "NewCard12345";
        $newpatron->{userid}     = "newuserid";
        $letter_enqueued         = 0;
        t::lib::Mocks::mock_preference( 'AutoEmailNewUser', 1 );
        $t->post_ok( "//$userid:$password@/api/v1/patrons" =>
                { 'x-koha-override' => 'welcome_no', 'x-confirm-not-duplicate' => 1 } => json => $newpatron )
            ->status_is( 201, 'Patron created successfully with welcome_no override' );
        is( $letter_enqueued, 0, "No welcome notice sent due to welcome_no override" );

        # Test when AutoEmailNewUser = 1 with no overrides
        $newpatron->{cardnumber} = "NewCard54321";
        $newpatron->{userid}     = "newuserid2";
        $letter_enqueued         = 0;
        t::lib::Mocks::mock_preference( 'AutoEmailNewUser', 1 );
        $t->post_ok( "//$userid:$password@/api/v1/patrons" => { 'x-confirm-not-duplicate' => 1 } => json => $newpatron )
            ->status_is( 201, 'Patron created successfully with AutoEmailNewUser = 1' );
        is( $letter_enqueued, 1, "Welcome notice sent due to AutoEmailNewUser = 1" );

        # Test case when patron has no valid email address
        $mocked_patron->mock( 'notice_email_address', sub { return; } );
        $newpatron->{cardnumber} = "NewCard99999";
        $newpatron->{userid}     = "newuserid3";
        $letter_enqueued         = 0;
        t::lib::Mocks::mock_preference( 'AutoEmailNewUser', 1 );
        $t->post_ok( "//$userid:$password@/api/v1/patrons" => { 'x-confirm-not-duplicate' => 1 } => json => $newpatron )
            ->status_is( 201, 'Patron created successfully but email will not be sent' );
        is( $letter_enqueued, 0, "No welcome notice sent due to missing email address" );
        $mocked_patron->unmock('notice_email_address');

        # Test case when notice template returns an empty string
        $newpatron->{cardnumber} = "NewCardPidgeon";
        $newpatron->{userid}     = "newuserid4";
        $letter_enqueued         = 0;
        $message_has_content     = 0;
        t::lib::Mocks::mock_preference( 'AutoEmailNewUser', 1 );
        $t->post_ok( "//$userid:$password@/api/v1/patrons" => { 'x-confirm-not-duplicate' => 1 } => json => $newpatron )
            ->status_is( 201, 'Patron created successfully with AutoEmailNewUser = 1 and empty WELCOME notice' );
        is( $letter_enqueued, 0, "Welcome not sent as it would be empty" );
        $message_has_content = 1;

        subtest 'extended_attributes handling tests' => sub {

            plan tests => 29;

            $mocked_patron->mock(
                'extended_attributes',
                sub {

                    if ($extended_attrs_exception) {
                        if (   $extended_attrs_exception eq 'Koha::Exceptions::Patron::Attribute::NonRepeatable'
                            or $extended_attrs_exception eq 'Koha::Exceptions::Patron::Attribute::UniqueIDConstraint' )
                        {
                            $extended_attrs_exception->throw(
                                attribute => Koha::Patron::Attribute->new( { code => $code, attribute => $attr } ) );
                        } else {
                            $extended_attrs_exception->throw( type => $type );
                        }
                    }
                    return [];
                }
            );

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
            )->status_is(400)->json_is( '/error' => "Missing mandatory extended attribute (type=$type)" );

            is( Koha::Patrons->search->count, $patrons_count, 'No patron added' );

            # Bug 40219: Test that welcome email is not sent when extended attribute validation fails
            t::lib::Mocks::mock_preference( 'AutoEmailNewUser', 1 );
            $letter_enqueued          = 0;
            $extended_attrs_exception = 'Koha::Exceptions::Patron::MissingMandatoryExtendedAttribute';
            $t->post_ok(
                "//$userid:$password\@/api/v1/patrons" => json => {
                    "firstname"   => "Bug",
                    "surname"     => "FortyZeroTwoOneNine",
                    "address"     => "Somewhere",
                    "category_id" => "ST",
                    "city"        => "TestCity",
                    "library_id"  => "MPL",
                    "email"       => 'bug40219@test.com'
                }
            )->status_is(400)->json_is( '/error' => "Missing mandatory extended attribute (type=$type)" );
            is( $letter_enqueued, 0, 'Bug 40219: No welcome email sent when extended attribute validation fails' );

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
            )->status_is(400)->json_is( '/error' => "Tried to use an invalid attribute type. type=$type" );

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
                ->json_is( '/error' => "Tried to add more than one non-repeatable attributes. type=$code value=$attr" );

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
                ->json_is(
                '/error' => "Your action breaks a unique constraint on the attribute. type=$code value=$attr" );

            is( Koha::Patrons->search->count, $patrons_count, 'No patron added' );

            $mocked_patron->unmock('extended_attributes');

            # Temporarily get rid of mandatory attribute types
            Koha::Patron::Attribute::Types->search( { mandatory => 1 } )->delete;

            # Create a couple attribute attribute types
            my $repeatable_1 = $builder->build_object(
                {
                    class => 'Koha::Patron::Attribute::Types',
                    value => {
                        mandatory     => 0,
                        repeatable    => 1,
                        unique_id     => 0,
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
                        unique_id     => 0,
                        category_code => 'ST'
                    }
                }
            );
            my $non_repeatable = $builder->build_object(
                {
                    class => 'Koha::Patron::Attribute::Types',
                    value => {
                        mandatory     => 0,
                        repeatable    => 0,
                        unique_id     => 0,
                        category_code => 'ST'
                    }
                }
            );
            my $unique_id = $builder->build_object(
                {
                    class => 'Koha::Patron::Attribute::Types',
                    value => {
                        mandatory     => 0,
                        repeatable    => 1,
                        unique_id     => 1,
                        category_code => 'ST'
                    }
                }
            );

            my $patron_id = $t->post_ok(
                "//$userid:$password@/api/v1/patrons" => json => {
                    "firstname"           => "Katrina",
                    "surname"             => "Fischer",
                    "address"             => "Somewhere",
                    "category_id"         => "ST",
                    "city"                => "Konstanz",
                    "library_id"          => "MPL",
                    "extended_attributes" => [
                        { type => $repeatable_1->code,   value => 'a' },
                        { type => $repeatable_1->code,   value => 'b' },
                        { type => $repeatable_1->code,   value => 'c' },
                        { type => $repeatable_2->code,   value => 'd' },
                        { type => $repeatable_2->code,   value => 'e' },
                        { type => $non_repeatable->code, value => 'single' },
                        { type => $unique_id->code,      value => 'unique1' }
                    ]
                }
            )->status_is( 201, 'Patron added' )->tx->res->json->{patron_id};
            my $extended_attributes =
                join( ' ', sort map { $_->attribute } Koha::Patrons->find($patron_id)->extended_attributes->as_list );
            is( $extended_attributes, 'a b c d e single unique1', 'Extended attributes are stored correctly' );

            # Test non-repeatable constraint in real scenario
            $t->post_ok(
                "//$userid:$password@/api/v1/patrons" => json => {
                    "firstname"           => "Another",
                    "surname"             => "User",
                    "address"             => "Somewhere",
                    "category_id"         => "ST",
                    "city"                => "Konstanz",
                    "library_id"          => "MPL",
                    "extended_attributes" => [
                        { type => $non_repeatable->code, value => 'first' },
                        { type => $non_repeatable->code, value => 'second' }
                    ]
                }
            )->status_is(400)->json_like( '/error' => qr/Tried to add more than one non-repeatable attributes/ );

            # Test unique ID constraint in real scenario
            $t->post_ok(
                "//$userid:$password@/api/v1/patrons" => json => {
                    "firstname"           => "Another",
                    "surname"             => "User",
                    "address"             => "Somewhere",
                    "category_id"         => "ST",
                    "city"                => "Konstanz",
                    "library_id"          => "MPL",
                    "extended_attributes" => [ { type => $unique_id->code, value => 'unique1' } ]
                }
            )->status_is(400)->json_like( '/error' => qr/Your action breaks a unique constraint on the attribute/ );
        };

        subtest 'default patron messaging preferences handling' => sub {

            plan tests => 6;

            t::lib::Mocks::mock_preference( 'EnhancedMessagingPreferences', 1 );

            C4::Members::Messaging::SetMessagingPreference(
                {
                    categorycode            => 'ST',
                    message_attribute_id    => 1,
                    message_transport_types => ['email'],
                    wants_digest            => 1
                }
            );

            my $patron_id = $t->post_ok(
                "//$userid:$password@/api/v1/patrons" => json => {
                    "firstname"   => "Nick",
                    "surname"     => "Clemens",
                    "address"     => "Somewhere",
                    "category_id" => "ST",
                    "city"        => "Smallville",
                    "library_id"  => "MPL",
                }
            )->status_is( 201, 'Patron added' )->tx->res->json->{patron_id};

            my $messaging_preferences = C4::Members::Messaging::GetMessagingPreferences(
                { borrowernumber => $patron_id, message_name => 'Item_Due' } );

            is_deeply(
                $messaging_preferences,
                {
                    letter_code  => 'DUEDGST',
                    wants_digest => 1,
                    transports   => { email => 'DUEDGST' }
                },
                'Default messaging preferences set correctly'
            );

            # Test with EnhancedMessagingPreferences disabled
            t::lib::Mocks::mock_preference( 'EnhancedMessagingPreferences', 0 );

            my $patron_id2 = $t->post_ok(
                "//$userid:$password@/api/v1/patrons" => json => {
                    "firstname"   => "David",
                    "surname"     => "Nolan",
                    "address"     => "Elsewhere",
                    "category_id" => "ST",
                    "city"        => "Bigtown",
                    "library_id"  => "MPL",
                }
            )->status_is( 201, 'Patron added with EnhancedMessagingPreferences disabled' )
                ->tx->res->json->{patron_id};

            # No messaging preferences should be set
            my $no_messaging_preferences = C4::Members::Messaging::GetMessagingPreferences(
                { borrowernumber => $patron_id2, message_name => 'Item_Due' } );

            ok(
                !$no_messaging_preferences->{transports}->{email},
                'No email messaging preferences set when EnhancedMessagingPreferences disabled'
            );
        };

        $schema->storage->txn_rollback;
    };
};

subtest 'update() tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;
    unauthorized_access_tests( 'PUT', 123, { email => 'nobody@example.com' } );
    $schema->storage->txn_rollback;

    subtest 'librarian access tests' => sub {

        plan tests => 44;

        $schema->storage->txn_begin;

        my $authorized_patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { flags => 1 }
            }
        );
        my $password = 'thePassword123';
        $authorized_patron->set_password( { password => $password, skip_validation => 1 } );
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
        my $newpatron = $unauthorized_patron->to_api( { user => $authorized_patron } );

        # delete RO attributes
        delete $newpatron->{patron_id};
        delete $newpatron->{restricted};
        delete $newpatron->{expired};
        delete $newpatron->{anonymized};

        $t->put_ok( "//$userid:$password@/api/v1/patrons/-1" => json => $newpatron )->status_is(404)
            ->json_has( '/error', 'Fails when trying to PUT nonexistent patron' );

        # Create a library just to make sure its ID doesn't exist on the DB
        my $category_to_delete  = $builder->build_object( { class => 'Koha::Patron::Categories' } );
        my $deleted_category_id = $category_to_delete->id;

        # Delete library
        $category_to_delete->delete;

        # Use an invalid category
        $newpatron->{category_id} = $deleted_category_id;

        $t->put_ok( "//$userid:$password@/api/v1/patrons/" . $patron_2->borrowernumber => json => $newpatron )
            ->status_is(400)->json_is( '/error' => "Given category_id does not exist" );

        # Restore the valid category
        $newpatron->{category_id} = $patron_2->categorycode;

        # Create a library just to make sure its ID doesn't exist on the DB
        my $library_to_delete  = $builder->build_object( { class => 'Koha::Libraries' } );
        my $deleted_library_id = $library_to_delete->id;

        # Delete library
        $library_to_delete->delete;

        # Use an invalid library_id
        $newpatron->{library_id} = $deleted_library_id;

        warning_like {
            $t->put_ok( "//$userid:$password@/api/v1/patrons/" . $patron_2->borrowernumber => json => $newpatron )
                ->status_is(400)->json_is( '/error' => "Given library_id does not exist" );
        }
        qr/DBD::mysql::st execute failed: Cannot add or update a child row: a foreign key constraint fails/;

        # Restore the valid library_id
        $newpatron->{library_id} = $patron_2->branchcode;

        # Use an invalid attribute
        $newpatron->{falseproperty} = "Non existent property";

        $t->put_ok( "//$userid:$password@/api/v1/patrons/" . $patron_2->borrowernumber => json => $newpatron )
            ->status_is(400)->json_is( '/errors/0/message' => 'Properties not allowed: falseproperty.' );

        # Get rid of the invalid attribute
        delete $newpatron->{falseproperty};

        # Set both cardnumber and userid to already existing values
        $newpatron->{cardnumber} = $patron_1->cardnumber;
        $newpatron->{userid}     = $patron_1->userid;

        $t->put_ok( "//$userid:$password@/api/v1/patrons/" . $patron_2->borrowernumber => json => $newpatron )
            ->status_is(400)->json_has( '/error', "Problem with userid " . $patron_1->userid );

        $newpatron->{cardnumber} = $patron_1->id . $patron_2->id;
        $newpatron->{userid}     = "user" . $patron_1->id . $patron_2->id;
        $newpatron->{surname}    = "user" . $patron_1->id . $patron_2->id;

        ## Trying to set to null on specially handled cases
        # Special case: a date
        $newpatron->{date_of_birth} = undef;

        # Special case: a date-time
        $newpatron->{last_seen} = undef;

        my $result =
            $t->put_ok( "//$userid:$password@/api/v1/patrons/" . $patron_2->borrowernumber => json => $newpatron )
            ->status_is( 200, 'Patron updated successfully' );

        # Put back the RO attributes
        $newpatron->{patron_id}  = $unauthorized_patron->to_api( { user => $authorized_patron } )->{patron_id};
        $newpatron->{restricted} = $unauthorized_patron->to_api( { user => $authorized_patron } )->{restricted};
        $newpatron->{expired}    = $unauthorized_patron->to_api( { user => $authorized_patron } )->{expired};
        $newpatron->{anonymized} = $unauthorized_patron->to_api( { user => $authorized_patron } )->{anonymized};

        my $got                 = $result->tx->res->json;
        my $updated_on_got      = delete $got->{updated_on};
        my $updated_on_expected = delete $newpatron->{updated_on};
        is_deeply( $got, $newpatron, 'Returned patron from update matches expected' );
        is(
            t::lib::Dates::compare(
                dt_from_string( $updated_on_got,      'rfc3339' ),
                dt_from_string( $updated_on_expected, 'rfc3339' )
            ),
            0,
            'updated_on values matched'
        );

        is(
            Koha::Patrons->find( $patron_2->id )->cardnumber,
            $newpatron->{cardnumber}, 'Patron is really updated!'
        );

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
        delete $newpatron->{expired};
        delete $newpatron->{anonymized};

        # attempt to update
        $authorized_patron->flags( 2**4 )->store;    # borrowers flag = 4
        $t->put_ok( "//$userid:$password@/api/v1/patrons/" . $superlibrarian->borrowernumber => json => $newpatron )
            ->status_is( 403, "Non-superlibrarian user change of superlibrarian email forbidden" )
            ->json_is( { error => "Not enough privileges to change a superlibrarian's email" } );

        # attempt to unset
        $newpatron->{email} = undef;
        $t->put_ok( "//$userid:$password@/api/v1/patrons/" . $superlibrarian->borrowernumber => json => $newpatron )
            ->status_is( 403, "Non-superlibrarian user change of superlibrarian email to undefined forbidden" )
            ->json_is( { error => "Not enough privileges to change a superlibrarian's email" } );

        $newpatron->{email}           = $superlibrarian->email;
        $newpatron->{secondary_email} = 'nonsense@no.no';

        # attempt to update
        $t->put_ok( "//$userid:$password@/api/v1/patrons/" . $superlibrarian->borrowernumber => json => $newpatron )
            ->status_is( 403, "Non-superlibrarian user change of superlibrarian secondary_email forbidden" )
            ->json_is( { error => "Not enough privileges to change a superlibrarian's email" } );

        # attempt to unset
        $newpatron->{secondary_email} = undef;
        $t->put_ok( "//$userid:$password@/api/v1/patrons/" . $superlibrarian->borrowernumber => json => $newpatron )
            ->status_is(
            403,
            "Non-superlibrarian user change of superlibrarian secondary_email to undefined forbidden"
        )->json_is( { error => "Not enough privileges to change a superlibrarian's email" } );

        $newpatron->{secondary_email}  = $superlibrarian->emailpro;
        $newpatron->{altaddress_email} = 'nonsense@no.no';

        # attempt to update
        $t->put_ok( "//$userid:$password@/api/v1/patrons/" . $superlibrarian->borrowernumber => json => $newpatron )
            ->status_is( 403, "Non-superlibrarian user change of superlibrarian altaddress_email forbidden" )
            ->json_is( { error => "Not enough privileges to change a superlibrarian's email" } );

        # attempt to unset
        $newpatron->{altaddress_email} = undef;
        $t->put_ok( "//$userid:$password@/api/v1/patrons/" . $superlibrarian->borrowernumber => json => $newpatron )
            ->status_is(
            403,
            "Non-superlibrarian user change of superlibrarian altaddress_email to undefined forbidden"
        )->json_is( { error => "Not enough privileges to change a superlibrarian's email" } );

        # update patron without sending email
        delete $newpatron->{email};
        delete $newpatron->{secondary_email};
        delete $newpatron->{altaddress_email};

        # Set a date field
        $newpatron->{date_of_birth} = '1980-06-18';

        # Set a date-time field
        $newpatron->{last_seen} = output_pref( { dt => dt_from_string->add( days => -1 ), dateformat => 'rfc3339' } );

        $t->put_ok( "//$userid:$password@/api/v1/patrons/" . $superlibrarian->borrowernumber => json => $newpatron )
            ->status_is( 200, "Non-superlibrarian user can edit superlibrarian successfully if not changing email" )
            ->json_is( '/date_of_birth' => $newpatron->{date_of_birth}, 'Date field set (Bug 28585)' )
            ->json_is( '/last_seen'     => $newpatron->{last_seen},     'Date-time field set (Bug 28585)' );

        subtest "extended_attributes tests" => sub {

            plan tests => 29;

            my $attr_type_repeatable = $builder->build_object(
                {
                    class => 'Koha::Patron::Attribute::Types',
                    value => { repeatable => 1, unique_id => 0, mandatory => 0, category_code => undef }
                }
            );

            my $attr_type_unique = $builder->build_object(
                {
                    class => 'Koha::Patron::Attribute::Types',
                    value => { repeatable => 0, unique_id => 1, mandatory => 0, category_code => undef }
                }
            );

            my $attr_type_mandatory = $builder->build_object(
                {
                    class => 'Koha::Patron::Attribute::Types',
                    value => { repeatable => 0, unique_id => 0, mandatory => 1, category_code => undef }
                }
            );

            my $deleted_attr_type = $builder->build_object( { class => 'Koha::Patron::Attribute::Types' } );
            my $deleted_attr_code = $deleted_attr_type->code;
            $deleted_attr_type->delete;

            # Make the mandatory attribute mandatory for the patron
            $builder->build(
                {
                    source => 'BorrowerAttributeTypesBranch',
                    value  => {
                        bat_code     => $attr_type_mandatory->code,
                        b_branchcode => undef,
                    }
                }
            );

            $newpatron->{extended_attributes} = [
                { type => $deleted_attr_code, value => 'potato' },
            ];

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
                ->json_is(
                '/error' => "Missing mandatory extended attribute (type=" . $attr_type_mandatory->code . ")" );

            $t->put_ok( "//$userid:$password@/api/v1/patrons/"
                    . $superlibrarian->borrowernumber => { 'x-koha-embed' => 'extended_attributes' } => json =>
                    $newpatron )->status_is(400)
                ->json_is( '/error'      => 'Tried to use an invalid attribute type. type=' . $deleted_attr_code )
                ->json_is( '/error_code' => 'invalid_attribute_type' );

            # Add a 'unique' attribute to force failure
            my $unique_attr = $builder->build_object(
                { class => 'Koha::Patron::Attributes', value => { code => $attr_type_unique->code } } );

            $newpatron->{extended_attributes} = [
                { type => $attr_type_repeatable->code, value => 'a' },
                { type => $attr_type_repeatable->code, value => 'b' },
                { type => $attr_type_mandatory->code,  value => 'thing' },
                { type => $attr_type_unique->code,     value => $unique_attr->attribute }
            ];

            $t->put_ok( "//$userid:$password@/api/v1/patrons/"
                    . $superlibrarian->borrowernumber => { 'x-koha-embed' => 'extended_attributes' } => json =>
                    $newpatron )->status_is(400)
                ->json_is( '/error' => 'Your action breaks a unique constraint on the attribute. type='
                    . $attr_type_unique->code
                    . ' value='
                    . $unique_attr->attribute )->json_is( '/error_code' => 'attribute_not_unique' );

            $newpatron->{extended_attributes} = [
                { type => $attr_type_repeatable->code, value => 'a' },
                { type => $attr_type_repeatable->code, value => 'b' },
                { type => $attr_type_mandatory->code,  value => 'thing' },
                { type => $attr_type_unique->code,     value => $unique_attr->attribute }
            ];

            $t->put_ok( "//$userid:$password@/api/v1/patrons/"
                    . $superlibrarian->borrowernumber => { 'x-koha-embed' => 'extended_attributes' } => json =>
                    $newpatron )->status_is(400)
                ->json_is( '/error' => 'Your action breaks a unique constraint on the attribute. type='
                    . $attr_type_unique->code
                    . ' value='
                    . $unique_attr->attribute )->json_is( '/error_code' => 'attribute_not_unique' );

            $newpatron->{extended_attributes} = [
                { type => $attr_type_repeatable->code, value => 'a' },
                { type => $attr_type_mandatory->code,  value => 'ping' },
                { type => $attr_type_mandatory->code,  value => 'pong' },
            ];

            $t->put_ok( "//$userid:$password@/api/v1/patrons/"
                    . $superlibrarian->borrowernumber => { 'x-koha-embed' => 'extended_attributes' } => json =>
                    $newpatron )->status_is(400)
                ->json_is( '/error' => 'Tried to add more than one non-repeatable attributes. type='
                    . $attr_type_mandatory->code
                    . ' value=pong' )->json_is( '/error_code' => 'non_repeatable_attribute' );

            my $unique_value = $unique_attr->attribute;
            $unique_attr->delete;

            $newpatron->{extended_attributes} = [
                { type => $attr_type_repeatable->code, value => 'a' },
                { type => $attr_type_repeatable->code, value => 'b' },
                { type => $attr_type_mandatory->code,  value => 'thing' },
                { type => $attr_type_unique->code,     value => $unique_value }
            ];

            my $extended_attributes =
                $t->put_ok( "//$userid:$password@/api/v1/patrons/"
                    . $superlibrarian->borrowernumber => { 'x-koha-embed' => 'extended_attributes' } => json =>
                    $newpatron )->status_is(200)->tx->res->json->{extended_attributes};

            my @sorted_extended_attributes =
                sort { $a->{extended_attribute_id} <=> $b->{extended_attribute_id} } @{$extended_attributes};

            foreach my $i ( 0 .. 3 ) {
                is( $newpatron->{extended_attributes}->[$i]->{type}, $sorted_extended_attributes[$i]->{type} );
                is( $newpatron->{extended_attributes}->[$i]->{code}, $sorted_extended_attributes[$i]->{code} );
            }
        };

        $schema->storage->txn_rollback;
    };
};

subtest 'delete() tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;
    unauthorized_access_tests( 'DELETE', 123, undef );
    $schema->storage->txn_rollback;

    subtest 'librarian access test' => sub {

        plan tests => 21;

        $schema->storage->txn_begin;

        my $authorized_patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { flags => 2**4 }    # borrowers flag = 4
            }
        );
        my $password = 'thePassword123';
        $authorized_patron->set_password( { password => $password, skip_validation => 1 } );
        my $userid = $authorized_patron->userid;

        $t->delete_ok("//$userid:$password@/api/v1/patrons/-1")->status_is( 404, 'Patron not found' );

        my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

        t::lib::Mocks::mock_preference( 'AnonymousPatron', $patron->borrowernumber );
        $t->delete_ok( "//$userid:$password@/api/v1/patrons/" . $patron->borrowernumber )
            ->status_is( 409, 'Anonymous patron cannot be deleted' )->json_is(
            {
                error      => 'Anonymous patron cannot be deleted',
                error_code => 'is_anonymous_patron'
            }
            );
        t::lib::Mocks::mock_preference( 'AnonymousPatron', 0 );    # back to default

        t::lib::Mocks::mock_preference( 'borrowerRelationship', 'parent' );

        my $checkout = $builder->build_object(
            {
                class => 'Koha::Checkouts',
                value => { borrowernumber => $patron->borrowernumber }
            }
        );
        my $debit     = $patron->account->add_debit( { amount => 10, interface => 'intranet', type => 'MANUAL' } );
        my $guarantee = $builder->build_object( { class => 'Koha::Patrons' } );

        $guarantee->add_guarantor( { guarantor_id => $patron->id, relationship => 'parent' } );

        $t->delete_ok( "//$userid:$password@/api/v1/patrons/" . $patron->borrowernumber )
            ->status_is( 409, 'Patron with checkouts cannot be deleted' )->json_is(
            {
                error      => 'Pending checkouts prevent deletion',
                error_code => 'has_checkouts'
            }
            );

        # Make sure it has no pending checkouts
        $checkout->delete;

        $t->delete_ok( "//$userid:$password@/api/v1/patrons/" . $patron->borrowernumber )
            ->status_is( 409, 'Patron with debt cannot be deleted' )->json_is(
            {
                error      => 'Pending debts prevent deletion',
                error_code => 'has_debt'
            }
            );

        # Make sure it has no debt
        $patron->account->pay( { amount => 10, debits => [$debit] } );

        $t->delete_ok( "//$userid:$password@/api/v1/patrons/" . $patron->borrowernumber )
            ->status_is( 409, 'Patron with guarantees cannot be deleted' )->json_is(
            {
                error      => 'Patron is a guarantor and it prevents deletion',
                error_code => 'has_guarantees'
            }
            );

        # Remove guarantee
        $patron->guarantee_relationships->delete;

        $patron->protected(1)->store();

        $t->delete_ok( "//$userid:$password@/api/v1/patrons/" . $patron->borrowernumber )
            ->status_is( 409, 'Protected patron cannot be deleted' )->json_is(
            {
                error      => 'Protected patrons cannot be deleted',
                error_code => 'is_protected'
            }
            );

        $patron->protected(0)->store();

        $t->delete_ok( "//$userid:$password@/api/v1/patrons/" . $patron->borrowernumber )
            ->status_is( 204, 'REST3.2.4' )->content_is( '', 'REST3.3.4' );

        my $deleted_patrons = Koha::Old::Patrons->search( { borrowernumber => $patron->borrowernumber } );
        is( $deleted_patrons->count, 1, 'The patron has been moved to the vault' );

        $schema->storage->txn_rollback;
    };
};

subtest 'guarantors_can_see_charges() tests' => sub {

    plan tests => 17;

    t::lib::Mocks::mock_preference( 'RESTPublicAPI', 1 );
    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { privacy_guarantor_fines => 0 } } );
    my $other_patron_id = $builder->build_object( { class => 'Koha::Patrons' } )->borrowernumber;
    my $password        = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid    = $patron->userid;
    my $patron_id = $patron->borrowernumber;

    t::lib::Mocks::mock_preference( 'AllowPatronToSetFinesVisibilityForGuarantor', 0 );

    $t->put_ok(
        "/api/v1/public/patrons/$other_patron_id/guarantors/can_see_charges" => json => { allowed => Mojo::JSON->true }
    )->status_is(401)->json_is( { error => "Authentication failure." } );

    $t->put_ok( "//$userid:$password@/api/v1/public/patrons/$other_patron_id/guarantors/can_see_charges" => json =>
            { allowed => Mojo::JSON->true } )->status_is(403)
        ->json_is( { error => "Unprivileged user cannot access another user's resources" } );

    $t->put_ok( "//$userid:$password@/api/v1/public/patrons/$patron_id/guarantors/can_see_charges" => json =>
            { allowed => Mojo::JSON->true } )->status_is(403)
        ->json_is( '/error', 'The current configuration doesn\'t allow the requested action.' );

    t::lib::Mocks::mock_preference( 'AllowPatronToSetFinesVisibilityForGuarantor', 1 );

    $t->put_ok( "//$userid:$password@/api/v1/public/patrons/$patron_id/guarantors/can_see_charges" => json =>
            { allowed => Mojo::JSON->true } )->status_is(200)->json_is( {} );

    ok( $patron->discard_changes->privacy_guarantor_fines, 'privacy_guarantor_fines has been set correctly' );

    $t->put_ok( "//$userid:$password@/api/v1/public/patrons/$patron_id/guarantors/can_see_charges" => json =>
            { allowed => Mojo::JSON->false } )->status_is(200)->json_is( {} );

    ok( !$patron->discard_changes->privacy_guarantor_fines, 'privacy_guarantor_fines has been set correctly' );

    $schema->storage->txn_rollback;
};

subtest 'guarantors_can_see_checkouts() tests' => sub {

    plan tests => 17;

    t::lib::Mocks::mock_preference( 'RESTPublicAPI', 1 );
    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { privacy_guarantor_checkouts => 0 } } );
    my $other_patron_id = $builder->build_object( { class => 'Koha::Patrons' } )->borrowernumber;
    my $password        = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid    = $patron->userid;
    my $patron_id = $patron->borrowernumber;

    $t->put_ok( "/api/v1/public/patrons/$other_patron_id/guarantors/can_see_checkouts" => json =>
            { allowed => Mojo::JSON->true } )->status_is(401)->json_is( { error => "Authentication failure." } );

    $t->put_ok( "//$userid:$password@/api/v1/public/patrons/$other_patron_id/guarantors/can_see_checkouts" => json =>
            { allowed => Mojo::JSON->true } )->status_is(403)
        ->json_is( { error => "Unprivileged user cannot access another user's resources" } );

    t::lib::Mocks::mock_preference( 'AllowPatronToSetCheckoutsVisibilityForGuarantor', 0 );

    $t->put_ok( "//$userid:$password@/api/v1/public/patrons/$patron_id/guarantors/can_see_checkouts" => json =>
            { allowed => Mojo::JSON->true } )->status_is(403)
        ->json_is( '/error', 'The current configuration doesn\'t allow the requested action.' );

    t::lib::Mocks::mock_preference( 'AllowPatronToSetCheckoutsVisibilityForGuarantor', 1 );

    $t->put_ok( "//$userid:$password@/api/v1/public/patrons/$patron_id/guarantors/can_see_checkouts" => json =>
            { allowed => Mojo::JSON->true } )->status_is(200)->json_is( {} );

    ok( $patron->discard_changes->privacy_guarantor_checkouts, 'privacy_guarantor_checkouts has been set correctly' );

    $t->put_ok( "//$userid:$password@/api/v1/public/patrons/$patron_id/guarantors/can_see_checkouts" => json =>
            { allowed => Mojo::JSON->false } )->status_is(200)->json_is( {} );

    ok( !$patron->discard_changes->privacy_guarantor_checkouts, 'privacy_guarantor_checkouts has been set correctly' );

    $schema->storage->txn_rollback;
};

# Centralized tests for 401s and 403s assuming the endpoint requires
# borrowers flag for access
sub unauthorized_access_tests {
    my ( $verb, $patron_id, $json ) = @_;

    my $endpoint = '/api/v1/patrons';
    $endpoint .= ($patron_id) ? "/$patron_id" : '';

    subtest 'unauthorized access tests' => sub {
        plan tests => 5;

        my $verb_ok = lc($verb) . '_ok';

        $t->$verb_ok( $endpoint => json => $json )->status_is(401);

        my $unauthorized_patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { flags => 0 }
            }
        );
        my $password = "thePassword123!";
        $unauthorized_patron->set_password( { password => $password, skip_validation => 1 } );
        my $unauth_userid = $unauthorized_patron->userid;

        $t->$verb_ok( "//$unauth_userid:$password\@$endpoint" => json => $json )->status_is(403)
            ->json_has('/required_permissions');
    };
}
