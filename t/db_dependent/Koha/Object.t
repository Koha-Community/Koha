#!/usr/bin/perl

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

use Test::More tests => 21;
use Test::Exception;
use Test::Warn;
use DateTime;

use C4::Context;
use C4::Circulation qw( AddIssue );
use C4::Biblio qw( AddBiblio );

use Koha::Database;

use Koha::Acquisition::Orders;
use Koha::ApiKeys;
use Koha::AuthorisedValueCategories;
use Koha::AuthorisedValues;
use Koha::DateUtils qw( dt_from_string );
use Koha::Libraries;
use Koha::Patrons;
use Koha::Library::Groups;

use JSON;
use Scalar::Util qw( isvstring );
use Try::Tiny;

use t::lib::TestBuilder;
use t::lib::Mocks;

BEGIN {
    use_ok('Koha::Object');
    use_ok('Koha::Patron');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

subtest 'is_changed / make_column_dirty' => sub {
    plan tests => 11;

    $schema->storage->txn_begin;

    my $categorycode = $builder->build({ source => 'Category' })->{categorycode};
    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};

    my $object = Koha::Patron->new();
    $object->categorycode( $categorycode );
    $object->branchcode( $branchcode );
    $object->surname("Test Surname");
    $object->store->discard_changes;
    is( $object->is_changed(), 0, "Object is unchanged" );
    $object->surname("Test Surname");
    is( $object->is_changed(), 0, "Object is still unchanged" );
    $object->surname("Test Surname 2");
    is( $object->is_changed(), 1, "Object is changed" );

    $object->store();
    is( $object->is_changed(), 0, "Object no longer marked as changed after being stored" );

    $object->set({ firstname => 'Test Firstname' });
    is( $object->is_changed(), 1, "Object is changed after Set" );
    $object->store();
    is( $object->is_changed(), 0, "Object no longer marked as changed after being stored" );

    # Test make_column_dirty
    is( $object->make_column_dirty('firstname'), '', 'make_column_dirty returns empty string on success' );
    is( $object->make_column_dirty('firstname'), 1, 'make_column_dirty returns 1 if already dirty' );
    is( $object->is_changed, 1, "Object is changed after make dirty" );
    $object->store;
    is( $object->is_changed, 0, "Store clears dirty mark" );
    $object->make_column_dirty('firstname');
    $object->discard_changes;
    is( $object->is_changed, 0, "Discard clears dirty mark too" );

    $schema->storage->txn_rollback;
};

subtest 'in_storage' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my $categorycode = $builder->build({ source => 'Category' })->{categorycode};
    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};

    my $object = Koha::Patron->new();
    is( $object->in_storage, 0, "Object is not in storage" );
    $object->categorycode( $categorycode );
    $object->branchcode( $branchcode );
    $object->surname("Test Surname");
    $object->store();
    is( $object->in_storage, 1, "Object is now stored" );
    $object->surname("another surname");
    is( $object->in_storage, 1 );

    my $borrowernumber = $object->borrowernumber;
    my $patron = $schema->resultset('Borrower')->find( $borrowernumber );
    is( $patron->surname(), "Test Surname", "Object found in database" );

    $object->delete();
    $patron = $schema->resultset('Borrower')->find( $borrowernumber );
    ok( ! $patron, "Object no longer found in database" );
    is( $object->in_storage, 0, "Object is not in storage" );

    $schema->storage->txn_rollback;
};

subtest 'id' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my $categorycode = $builder->build({ source => 'Category' })->{categorycode};
    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};

    my $patron = Koha::Patron->new({categorycode => $categorycode, branchcode => $branchcode })->store;
    is( $patron->id, $patron->borrowernumber );

    $schema->storage->txn_rollback;
};

subtest 'get_column' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my $categorycode = $builder->build({ source => 'Category' })->{categorycode};
    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};

    my $patron = Koha::Patron->new({categorycode => $categorycode, branchcode => $branchcode })->store;
    is( $patron->get_column('borrowernumber'), $patron->borrowernumber, 'get_column should retrieve the correct value' );

    $schema->storage->txn_rollback;
};

subtest 'discard_changes' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my $patron = $builder->build( { source => 'Borrower' } );
    $patron = Koha::Patrons->find( $patron->{borrowernumber} );
    $patron->dateexpiry(dt_from_string);
    $patron->discard_changes;
    is(
        dt_from_string( $patron->dateexpiry ),
        dt_from_string->truncate( to => 'day' ),
        'discard_changes should refresh the object'
    );

    $schema->storage->txn_rollback;
};

subtest 'TO_JSON tests' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $dt = dt_from_string();
    my $borrowernumber = $builder->build(
        { source => 'Borrower',
          value => { lost => 1,
                     sms_provider_id => undef,
                     gonenoaddress => 0,
                     updated_on => $dt,
                     lastseen   => $dt, } })->{borrowernumber};

    my $patron = Koha::Patrons->find($borrowernumber);
    my $lost = $patron->TO_JSON()->{lost};
    my $gonenoaddress = $patron->TO_JSON->{gonenoaddress};
    my $updated_on = $patron->TO_JSON->{updated_on};
    my $lastseen = $patron->TO_JSON->{lastseen};

    ok( $lost->isa('JSON::PP::Boolean'), 'Boolean attribute type is correct' );
    is( $lost, 1, 'Boolean attribute value is correct (true)' );

    ok( $gonenoaddress->isa('JSON::PP::Boolean'), 'Boolean attribute type is correct' );
    is( $gonenoaddress, 0, 'Boolean attribute value is correct (false)' );

    is( $patron->TO_JSON->{sms_provider_id}, undef, 'Undef values should not be casted to 0' );

    ok( !isvstring($patron->borrowernumber), 'Integer values are not coded as strings' );

    my $rfc3999_regex = qr/
            (?<year>\d{4})
            -
            (?<month>\d{2})
            -
            (?<day>\d{2})
            ([Tt\s])
            (?<hour>\d{2})
            :
            (?<minute>\d{2})
            :
            (?<second>\d{2})
            (([Zz])|([\+|\-]([01][0-9]|2[0-3]):[0-5][0-9]))
        /xms;
    like( $updated_on, $rfc3999_regex, "Date-time $updated_on formatted correctly");
    like( $lastseen, $rfc3999_regex, "Date-time $updated_on formatted correctly");

    # Test JSON doesn't receive strings
    my $order = $builder->build_object({ class => 'Koha::Acquisition::Orders' });
    $order = Koha::Acquisition::Orders->find( $order->ordernumber );
    is_deeply( $order->TO_JSON, decode_json( encode_json( $order->TO_JSON ) ), 'Orders are similar' );

    $schema->storage->txn_rollback;
};

subtest "to_api() tests" => sub {

    plan tests => 31;

    $schema->storage->txn_begin;

    my $city = $builder->build_object({ class => 'Koha::Cities' });

    # THE mapping
    # cityid       => 'city_id',
    # city_country => 'country',
    # city_name    => 'name',
    # city_state   => 'state',
    # city_zipcode => 'postal_code'

    my $api_city = $city->to_api;

    is( $api_city->{city_id},     $city->cityid,       'Attribute translated correctly' );
    is( $api_city->{country},     $city->city_country, 'Attribute translated correctly' );
    is( $api_city->{name},        $city->city_name,    'Attribute translated correctly' );
    is( $api_city->{state},       $city->city_state,   'Attribute translated correctly' );
    is( $api_city->{postal_code}, $city->city_zipcode, 'Attribute translated correctly' );

    # Lets emulate an undef
    my $city_class = Test::MockModule->new('Koha::City');
    $city_class->mock( 'to_api_mapping',
        sub {
            return {
                cityid       => 'city_id',
                city_country => 'country',
                city_name    => 'name',
                city_state   => 'state',
                city_zipcode => undef
            };
        }
    );

    $api_city = $city->to_api;

    is( $api_city->{city_id},     $city->cityid,       'Attribute translated correctly' );
    is( $api_city->{country},     $city->city_country, 'Attribute translated correctly' );
    is( $api_city->{name},        $city->city_name,    'Attribute translated correctly' );
    is( $api_city->{state},       $city->city_state,   'Attribute translated correctly' );
    ok( !exists $api_city->{postal_code}, 'Attribute removed' );

    # Pick a class that won't have a mapping for the API
    my $action_log = $builder->build_object({ class => 'Koha::ActionLogs' });
    is_deeply( $action_log->to_api, $action_log->TO_JSON, 'If no overloaded to_api_mapping method, return TO_JSON' );

    my $biblio = $builder->build_sample_biblio();
    my $item = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });
    my $hold = $builder->build_object({ class => 'Koha::Holds', value => { itemnumber => $item->itemnumber } });

    my $embeds = { 'items' => {} };

    my $biblio_api = $biblio->to_api({ embed => $embeds });

    ok(exists $biblio_api->{items}, 'Items where embedded in biblio results');
    is($biblio_api->{items}->[0]->{item_id}, $item->itemnumber, 'Item matches');
    ok(!exists $biblio_api->{items}->[0]->{holds}, 'No holds info should be embedded yet');

    $embeds = (
        {
            'items' => {
                'children' => {
                    'holds' => {}
                }
            },
            'biblioitem' => {}
        }
    );
    $biblio_api = $biblio->to_api({ embed => $embeds });

    ok(exists $biblio_api->{items}, 'Items where embedded in biblio results');
    is($biblio_api->{items}->[0]->{item_id}, $item->itemnumber, 'Item still matches');
    ok(exists $biblio_api->{items}->[0]->{holds}, 'Holds info should be embedded');
    is($biblio_api->{items}->[0]->{holds}->[0]->{hold_id}, $hold->reserve_id, 'Hold matches');
    is_deeply($biblio_api->{biblioitem}, $biblio->biblioitem->to_api, 'More than one root');

    my $_strings = {
        location => {
            category => 'ASD',
            str      => 'Estante alto',
            type     => 'av'
        }
    };

    # mock Koha::Item so it implements 'strings_map'
    my $item_mock = Test::MockModule->new('Koha::Item');
    $item_mock->mock(
        'strings_map',
        sub {
            return $_strings;
        }
    );

    my $hold_api = $hold->to_api(
        {
            embed => { 'item' => { strings => 1 } }
        }
    );

    is( ref($hold_api->{item}), 'HASH', 'Single nested object works correctly' );
    is( $hold_api->{item}->{item_id}, $item->itemnumber, 'Object embedded correctly' );
    is_deeply(
        $hold_api->{item}->{_strings},
        $_strings,
        '_strings correctly added to nested embed'
    );

    # biblio with no items
    my $new_biblio = $builder->build_sample_biblio;
    my $new_biblio_api = $new_biblio->to_api({ embed => $embeds });

    is_deeply( $new_biblio_api->{items}, [], 'Empty list if no items' );

    my $biblio_class = Test::MockModule->new('Koha::Biblio');
    $biblio_class->mock( 'undef_result', sub { return; } );

    $new_biblio_api = $new_biblio->to_api({ embed => ( { 'undef_result' => {} } ) });
    ok( exists $new_biblio_api->{undef_result}, 'If a method returns undef, then the attribute is defined' );
    is( $new_biblio_api->{undef_result}, undef, 'If a method returns undef, then the attribute is undef' );

    $biblio_class->mock( 'items',
        sub { return [ bless { itemnumber => 1 }, 'Somethings' ]; } );

    throws_ok {
        $new_biblio_api = $new_biblio->to_api(
            { embed => { 'items' => { children => { asd => {} } } } } );
    }
    'Koha::Exception',
"An exception is thrown if a blessed object to embed doesn't implement to_api";

    is(
        $@->message,
        "Asked to embed items but its return value doesn't implement to_api",
        "Exception message correct"
    );


    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                biblionumber   => $biblio->biblionumber,
                borrowernumber => $patron->borrowernumber
            }
        }
    );
    $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                biblionumber   => $biblio->biblionumber,
                borrowernumber => $patron->borrowernumber
            }
        }
    );

    my $patron_api = $patron->to_api(
        {
            embed => { holds_count => { is_count => 1 } }
        }
    );
    is( $patron_api->{holds_count}, $patron->holds->count, 'Count embeds are supported and work as expected' );

    throws_ok
        {
            $patron->to_api({ embed => { holds_count => {} } });
        }
        'Koha::Exceptions::Object::MethodNotCoveredByTests',
        'Unknown method exception thrown if is_count not specified';

    subtest 'unprivileged request tests' => sub {

        my @all_attrs = Koha::Libraries->columns();
        my $public_attrs = { map { $_ => 1 } @{ Koha::Library->public_read_list() } };
        my $mapping = Koha::Library->to_api_mapping;

        plan tests => scalar @all_attrs * 2;

        # Create a sample library
        my $library = $builder->build_object( { class => 'Koha::Libraries' } );

        my $unprivileged_representation = $library->to_api({ public => 1 });
        my $privileged_representation   = $library->to_api;

        foreach my $attr (@all_attrs) {
            my $mapped = exists $mapping->{$attr} ? $mapping->{$attr} : $attr;
            if ( defined($mapped) ) {
                ok(
                    exists $privileged_representation->{$mapped},
                    "Attribute '$attr' is present when privileged"
                );
                if ( exists $public_attrs->{$attr} ) {
                    ok(
                        exists $unprivileged_representation->{$mapped},
                        "Attribute '$attr' is present when public"
                    );
                }
                else {
                    ok(
                        !exists $unprivileged_representation->{$mapped},
                        "Attribute '$attr' is not present when public"
                    );
                }
            }
            else {
                ok(
                    !exists $privileged_representation->{$attr},
                    "Unmapped attribute '$attr' is not present when privileged"
                );
                ok(
                    !exists $unprivileged_representation->{$attr},
                    "Unmapped attribute '$attr' is not present when public"
                );
            }
        }
    };

    subtest 'Authorised values expansion' => sub {

        plan tests => 4;

        $schema->storage->txn_begin;

        # new category
        my $category = $builder->build_object({ class => 'Koha::AuthorisedValueCategories' });
        # add two countries
        my $argentina = $builder->build_object(
            {   class => 'Koha::AuthorisedValues',
                value => {
                    category => $category->category_name,
                    lib      => 'AR (Argentina)',
                    lib_opac => 'Argentina',
                }
            }
        );
        my $france = $builder->build_object(
            {   class => 'Koha::AuthorisedValues',
                value => {
                    category => $category->category_name,
                    lib      => 'FR (France)',
                    lib_opac => 'France',
                }
            }
        );

        my $city_mock = Test::MockModule->new('Koha::City');
        $city_mock->mock(
            'strings_map',
            sub {
                my ( $self, $params ) = @_;

                my $av = Koha::AuthorisedValues->find(
                    {
                        authorised_value => $self->city_country,
                        category         => $category->category_name,
                    }
                );

                return {
                    city_country => {
                        category => $av->category,
                        str      => ( $params->{public} ) ? $av->lib_opac : $av->lib,
                        type     => 'av',
                    }
                };
            }
        );
        $city_mock->mock( 'public_read_list', sub { return [ 'city_id', 'city_country', 'city_name', 'city_state' ] } );

        my $cordoba = $builder->build_object(
            {   class => 'Koha::Cities',
                value => { city_country => $argentina->authorised_value, city_name => 'Cordoba' }
            }
        );
        my $marseille = $builder->build_object(
            {   class => 'Koha::Cities',
                value => { city_country => $france->authorised_value, city_name => 'Marseille' }
            }
        );

        my $mobj = $marseille->to_api( { strings => 1, public => 1 } );
        my $cobj = $cordoba->to_api( { strings => 1, public => 0 } );

        ok( exists $mobj->{_strings}, '_strings exists for Marseille' );
        ok( exists $cobj->{_strings}, '_strings exists for Córdoba' );

        is_deeply(
            $mobj->{_strings}->{country},
            {
                category => $category->category_name,
                str      => $france->lib_opac,
                type     => 'av',
            },
            'Authorised value for country expanded'
        );
        is_deeply(
            $cobj->{_strings}->{country},
            {
                category => $category->category_name,
                str      => $argentina->lib,
                type     => 'av'
            },
            'Authorised value for country expanded'
        );

        $schema->storage->txn_rollback;
    };

    $schema->storage->txn_rollback;
};

subtest "to_api_mapping() tests" => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $action_log = $builder->build_object({ class => 'Koha::ActionLogs' });
    is_deeply( $action_log->to_api_mapping, {}, 'If no to_api_mapping present, return empty hashref' );

    $schema->storage->txn_rollback;
};

subtest "from_api_mapping() tests" => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $city = $builder->build_object({ class => 'Koha::Cities' });

    # Lets emulate an undef
    my $city_class = Test::MockModule->new('Koha::City');
    $city_class->mock( 'to_api_mapping',
        sub {
            return {
                cityid       => 'city_id',
                city_country => 'country',
                city_zipcode => undef
            };
        }
    );

    is_deeply(
        $city->from_api_mapping,
        {
            city_id => 'cityid',
            country => 'city_country'
        },
        'Mapping returns correctly, undef ommited'
    );

    $city_class->unmock( 'to_api_mapping');
    $city_class->mock( 'to_api_mapping',
        sub {
            return {
                cityid       => 'city_id',
                city_country => 'country',
                city_zipcode => 'postal_code'
            };
        }
    );

    is_deeply(
        $city->from_api_mapping,
        {
            city_id => 'cityid',
            country => 'city_country'
        },
        'Reverse mapping is cached'
    );

    # Get a fresh object
    $city = $builder->build_object({ class => 'Koha::Cities' });
    is_deeply(
        $city->from_api_mapping,
        {
            city_id     => 'cityid',
            country     => 'city_country',
            postal_code => 'city_zipcode'
        },
        'Fresh mapping loaded'
    );

    $city_class->unmock( 'to_api_mapping');
    $city_class->mock( 'to_api_mapping', undef );

    # Get a fresh object
    $city = $builder->build_object({ class => 'Koha::Cities' });
    is_deeply(
        $city->from_api_mapping,
        {},
        'No to_api_mapping then empty hashref'
    );

    $city_class->unmock( 'to_api_mapping');
    $city_class->mock( 'to_api_mapping', sub { return; } );

    # Get a fresh object
    $city = $builder->build_object({ class => 'Koha::Cities' });
    is_deeply(
        $city->from_api_mapping,
        {},
        'Empty to_api_mapping then empty hashref'
    );

    $schema->storage->txn_rollback;
};

subtest 'set_from_api() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $city = $builder->build_object({ class => 'Koha::Cities' });
    my $city_unblessed = $city->unblessed;
    my $attrs = {
        name        => 'Cordoba',
        country     => 'Argentina',
        postal_code => '5000'
    };
    $city->set_from_api($attrs);

    is( $city->city_state, $city_unblessed->{city_state}, 'Untouched attributes are preserved' );
    is( $city->city_name, $attrs->{name}, 'city_name updated correctly' );
    is( $city->city_country, $attrs->{country}, 'city_country updated correctly' );
    is( $city->city_zipcode, $attrs->{postal_code}, 'city_zipcode updated correctly' );

    $schema->storage->txn_rollback;
};

subtest 'new_from_api() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $attrs = {
        name        => 'Cordoba',
        country     => 'Argentina',
        postal_code => '5000'
    };
    my $city = Koha::City->new_from_api($attrs);

    is( ref($city), 'Koha::City', 'Object type is correct' );
    is( $city->city_name,    $attrs->{name}, 'city_name updated correctly' );
    is( $city->city_country, $attrs->{country}, 'city_country updated correctly' );
    is( $city->city_zipcode, $attrs->{postal_code}, 'city_zipcode updated correctly' );

    $schema->storage->txn_rollback;
};

subtest 'attributes_from_api() tests' => sub {

    plan tests => 2;

    subtest 'date and date-time handling tests' => sub {

        plan tests => 12;

        my $patron = Koha::Patron->new();

        my $attrs = $patron->attributes_from_api(
            {
                updated_on     => '2019-12-27T14:53:00Z',
                last_seen      => '2019-12-27T14:53:00Z',
                date_of_birth  => '2019-12-27',
            }
        );

        ok( exists $attrs->{updated_on},
            'No translation takes place if no mapping' );
        is(
            $attrs->{updated_on},
            '2019-12-27 14:53:00',
            'Given an rfc3339 formatted datetime string, a timestamp field is converted into an SQL formatted datetime string'
        );

        ok( exists $attrs->{lastseen},
            'Translation takes place because of the defined mapping' );
        is(
            $attrs->{lastseen},
            '2019-12-27 14:53:00',
            'Given an rfc3339 formatted datetime string, a datetime field is converted into an SQL formatted datetime string'
        );

        ok( exists $attrs->{dateofbirth},
            'Translation takes place because of the defined mapping' );
        is(
            $attrs->{dateofbirth},
            '2019-12-27',
            'Given an rfc3339 formatted date string, a date field is converted into an SQL formatted date string'
        );

        $attrs = $patron->attributes_from_api(
            {
                last_seen      => undef,
                date_of_birth  => undef,
            }
        );

        ok( exists $attrs->{lastseen},
            'undef parameter is not skipped (Bug 29157)' );
        is(
            $attrs->{lastseen},
            undef,
            'Given undef, a datetime field is set to undef (Bug 29157)'
        );

        ok( exists $attrs->{dateofbirth},
            'undef parameter is not skipped (Bug 29157)' );
        is(
            $attrs->{dateofbirth},
            undef,
            'Given undef, a date field is set to undef (Bug 29157)'
        );

        throws_ok
            {
                $attrs = $patron->attributes_from_api(
                    {
                        date_of_birth => '20141205',
                    }
                );
            }
            'Koha::Exceptions::BadParameter',
            'Bad date throws an exception';

        is(
            $@->parameter,
            'date_of_birth',
            'Exception parameter is the API field name, not the DB one'
        );
    };

    subtest 'booleans handling tests' => sub {

        plan tests => 4;

        my $patron = Koha::Patron->new;

        my $attrs = $patron->attributes_from_api(
            {
                incorrect_address => Mojo::JSON->true,
                patron_card_lost  => Mojo::JSON->false,
            }
        );

        ok( exists $attrs->{gonenoaddress}, 'Attribute gets translated' );
        is( $attrs->{gonenoaddress}, 1, 'Boolean correctly translated to integer (true => 1)' );
        ok( exists $attrs->{lost}, 'Attribute gets translated' );
        is( $attrs->{lost}, 0, 'Boolean correctly translated to integer (false => 0)' );
    };
};

subtest "Test update method" => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};
    my $library = Koha::Libraries->find( $branchcode );
    $library->update({ branchname => 'New_Name', branchcity => 'AMS' });
    is( $library->branchname, 'New_Name', 'Changed name with update' );
    is( $library->branchcity, 'AMS', 'Changed city too' );
    is( $library->is_changed, 0, 'Change should be stored already' );
    try {
        $library->update({
            branchcity => 'NYC', not_a_column => 53, branchname => 'Name3',
        });
        fail( 'It should not be possible to update an unexisting column without an error from Koha::Object/DBIx' );
    } catch {
        ok( $_->isa('Koha::Exceptions::Object'), 'Caught error when updating wrong column' );
        $library->discard_changes; #requery after failing update
    };
    # Check if the columns are not updated
    is( $library->branchcity, 'AMS', 'First column not updated' );
    is( $library->branchname, 'New_Name', 'Third column not updated' );

    $schema->storage->txn_rollback;
};

subtest 'store() tests' => sub {

    plan tests => 16;

    # Using Koha::Library::Groups to test Koha::Object>-store
    # Simple object with foreign keys and unique key

    $schema->storage->txn_begin;

    # Create a library to make sure its ID doesn't exist on the DB
    my $library = $builder->build_object({ class => 'Koha::Libraries' });
    my $branchcode = $library->branchcode;
    $library->delete;

    my $library_group = Koha::Library::Group->new(
        {
            branchcode      => $library->branchcode,
            title => 'a title',
        }
    );

    my $dbh = $schema->storage->dbh;
    {
        local *STDERR;
        open STDERR, '>', '/dev/null';
        throws_ok
            { $library_group->store }
            'Koha::Exceptions::Object::FKConstraint',
            'Exception is thrown correctly';
        is(
            $@->message,
            "Broken FK constraint",
            'Exception message is correct'
        );
        is(
            $@->broken_fk,
            'branchcode',
            'Exception field is correct'
        );

        $library_group = $builder->build_object({ class => 'Koha::Library::Groups' });

        my $new_library_group = Koha::Library::Group->new(
            {
                branchcode      => $library_group->branchcode,
                title        => $library_group->title,
            }
        );

        throws_ok
            { $new_library_group->store }
            'Koha::Exceptions::Object::DuplicateID',
            'Exception is thrown correctly';

        is(
            $@->message,
            'Duplicate ID',
            'Exception message is correct'
        );

        like(
           $@->duplicate_id,
           qr/(library_groups\.)?title/,
           'Exception field is correct (note that MySQL 8 is displaying the tablename)'
        );
        close STDERR;
    }

    # Successful test
    $library_group->set({ title => 'Manuel' });
    my $ret = $library_group->store;
    is( ref($ret), 'Koha::Library::Group', 'store() returns the object on success' );

    $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron_category = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => { category_type => 'P', enrolmentfee => 0 }
        }
    );

    my $patron = eval {
        Koha::Patron->new(
            {
                categorycode    => $patron_category->categorycode,
                branchcode      => $library->branchcode,
                dateofbirth     => "", # date will be set to NULL
                sms_provider_id => "", # Integer will be set to NULL
                privacy         => "", # privacy cannot be NULL but has a default value
            }
        )->store;
    };
    is( $@, '', 'No error should be raised by ->store if empty strings are passed' );
    is( $patron->privacy, 1, 'Default value for privacy should be set to 1' );
    is( $patron->dateofbirth,     undef, 'dateofbirth must have been set to undef');
    is( $patron->sms_provider_id, undef, 'sms_provider_id must have been set to undef');

    my $itemtype = eval {
        Koha::ItemType->new(
            {
                itemtype        => 'IT4test',
                rentalcharge    => "",
                notforloan      => "",
                hideinopac      => "",
            }
        )->store;
    };
    is( $@, '', 'No error should be raised by ->store if empty strings are passed' );
    is( $itemtype->rentalcharge, undef, 'decimal DEFAULT NULL should default to null');
    is( $itemtype->notforloan, undef, 'int DEFAULT NULL should default to null');
    is( $itemtype->hideinopac, 0, 'int NOT NULL DEFAULT 0 should default to 0');

    subtest 'Bad value tests' => sub {

        plan tests => 3;

        my $patron = $builder->build_object({ class => 'Koha::Patrons' });


        try {
            local *STDERR;
            open STDERR, '>', '/dev/null';
            $patron->lastseen('wrong_value')->store;
            close STDERR;
        } catch {
            ok( $_->isa('Koha::Exceptions::Object::BadValue'), 'Exception thrown correctly' );
            like( $_->property, qr/(borrowers\.)?lastseen/, 'Column should be the expected one' ); # The table name is not always displayed, it depends on the DBMS version
            is( $_->value, 'wrong_value', 'Value should be the expected one' );
        };
    };

    $schema->storage->txn_rollback;
};

subtest 'unblessed_all_relateds' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    # FIXME It's very painful to create an issue in tests!
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    t::lib::Mocks::mock_userenv({ branchcode => $library->branchcode });

    my $patron_category = $builder->build(
        {
            source => 'Category',
            value  => {
                category_type                 => 'P',
                enrolmentfee                  => 0,
                BlockExpiredPatronOpacActions => -1, # Pick the pref value
            }
        }
    );
    my $patron_data = {
        firstname =>  'firstname',
        surname => 'surname',
        categorycode => $patron_category->{categorycode},
        branchcode => $library->branchcode,
    };
    my $patron = Koha::Patron->new($patron_data)->store;
    my ($biblionumber) = AddBiblio( MARC::Record->new, '' );
    my $biblio = Koha::Biblios->find( $biblionumber );
    my $itemtype = $builder->build({ source => 'Itemtype' })->{itemtype};
    my $item = $builder->build_object(
        {
            class => 'Koha::Items',
            value => {
                homebranch    => $library->branchcode,
                holdingbranch => $library->branchcode,
                biblionumber  => $biblio->biblionumber,
                itemlost      => 0,
                withdrawn     => 0,
                itype         => $itemtype
            }
        }
    );

    my $issue = AddIssue( $patron, $item->barcode, DateTime->now->subtract( days => 1 ) );
    my $overdues = Koha::Patrons->find( $patron->id )->overdues; # Koha::Patron->overdues prefetches
    my $overdue = $overdues->next->unblessed_all_relateds;
    is( $overdue->{issue_id}, $issue->issue_id, 'unblessed_all_relateds has field from the original table (issues)' );
    is( $overdue->{title}, $biblio->title, 'unblessed_all_relateds has field from other tables (biblio)' );
    is( $overdue->{homebranch}, $item->homebranch, 'unblessed_all_relateds has field from other tables (items)' );

    $schema->storage->txn_rollback;
};

subtest 'get_from_storage' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio;

    my $old_title = $biblio->title;
    my $new_title = 'new_title';
    Koha::Biblios->find( $biblio->biblionumber )->title($new_title)->store;

    is( $biblio->title, $old_title, 'current $biblio should not be modified' );
    is( $biblio->get_from_storage->title,
        $new_title, 'get_from_storage should return an updated object' );

    Koha::Biblios->find( $biblio->biblionumber )->delete;
    is( ref($biblio), 'Koha::Biblio', 'current $biblio should not be deleted' );
    is( $biblio->get_from_storage, undef,
        'get_from_storage should return undef if the object has been deleted' );

    $schema->storage->txn_rollback;
};

subtest 'prefetch_whitelist() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $biblio = Koha::Biblio->new;

    my $prefetch_whitelist = $biblio->prefetch_whitelist;

    ok(
        exists $prefetch_whitelist->{orders},
        'Relationship matching method name is listed'
    );
    is(
        $prefetch_whitelist->{orders},
        'Koha::Acquisition::Order',
        'Guessed the non-standard object class correctly'
    );

    is(
        $prefetch_whitelist->{items},
        'Koha::Item',
        'Guessed the standard object class correctly'
    );

    $schema->storage->txn_rollback;
};

subtest 'set_or_blank' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $item = $builder->build_sample_item;
    my $item_info = $item->unblessed;
    $item = $item->set_or_blank($item_info);
    is_deeply($item->unblessed, $item_info, 'set_or_blank assign the correct value if unchanged');

    # int not null
    delete $item_info->{itemlost};
    $item = $item->set_or_blank($item_info);
    is($item->itemlost, 0, 'set_or_blank should have set itemlost to 0, default value defined in DB');

    # int nullable
    delete $item_info->{restricted};
    $item = $item->set_or_blank($item_info);
    is($item->restricted, undef, 'set_or_blank should have set restristed to null' );

    # datetime nullable
    delete $item_info->{dateaccessioned};
    $item = $item->set_or_blank($item_info);
    is($item->dateaccessioned, undef, 'set_or_blank should have set dateaccessioned to null');

    # timestamp not null
    delete $item_info->{timestamp};
    $item = $item->set_or_blank($item_info);
    isnt($item->timestamp, undef, 'set_or_blank should have set timestamp to a correct value');

    $schema->storage->txn_rollback;
};

subtest 'messages() and add_message() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $patron = Koha::Patron->new;

    my @messages = @{ $patron->object_messages };
    is( scalar @messages, 0, 'No messages' );

    $patron->add_message({ message => "message_1" });
    $patron->add_message({ message => "message_2" });

    @messages = @{ $patron->object_messages };

    is( scalar @messages, 2, 'Messages are returned' );
    is( ref($messages[0]), 'Koha::Object::Message', 'Right type returned' );
    is( ref($messages[1]), 'Koha::Object::Message', 'Right type returned' );
    is( $messages[0]->message, 'message_1', 'Right message recorded' );

    my $patron_id = $builder->build_object({ class => 'Koha::Patrons' })->id;
    # get a patron from the DB, ->new is not called, ->object_messages should initialize _messages as an empty arrayref
    $patron = Koha::Patrons->find( $patron_id );

    isnt( $patron->object_messages, undef, '->messages initializes the array if required' );
    is( scalar @{ $patron->object_messages }, 0, '->messages returns an empty arrayref' );

    $schema->storage->txn_rollback;
};
