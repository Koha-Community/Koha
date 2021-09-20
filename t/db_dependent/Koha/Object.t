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

use Test::More tests => 18;
use Test::Exception;
use Test::Warn;
use DateTime;

use C4::Context;
use C4::Circulation; # AddIssue
use C4::Biblio; # AddBiblio

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Libraries;
use Koha::Patrons;
use Koha::ApiKeys;

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
    $object->store();
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

    plan tests => 8;

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

    $schema->storage->txn_rollback;
};

subtest "to_api() tests" => sub {

    plan tests => 26;

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
    my $illrequest = $builder->build_object({ class => 'Koha::Illrequests' });
    is_deeply( $illrequest->to_api, $illrequest->TO_JSON, 'If no overloaded to_api_mapping method, return TO_JSON' );

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

    my $hold_api = $hold->to_api(
        {
            embed => { 'item' => {} }
        }
    );

    is( ref($hold_api->{item}), 'HASH', 'Single nested object works correctly' );
    is( $hold_api->{item}->{item_id}, $item->itemnumber, 'Object embedded correctly' );

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
    'Koha::Exceptions::Exception',
"An exception is thrown if a blessed object to embed doesn't implement to_api";

    is(
        "$@",
        "Asked to embed items but its return value doesn't implement to_api",
        "Exception message correct"
    );

    $schema->storage->txn_rollback;
};

subtest "to_api_mapping() tests" => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $illrequest = $builder->build_object({ class => 'Koha::Illrequests' });
    is_deeply( $illrequest->to_api_mapping, {}, 'If no to_api_mapping present, return empty hashref' );

    $schema->storage->txn_rollback;
};

subtest "from_api_mapping() tests" => sub {

    plan tests => 3;

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

    plan tests => 12;

    my $patron = Koha::Patron->new();

    my $attrs = $patron->attributes_from_api(
        {
            updated_on => '2019-12-27T14:53:00',
        }
    );

    ok( exists $attrs->{updated_on},
        'No translation takes place if no mapping' );
    is(
        ref( $attrs->{updated_on} ),
        'DateTime',
        'Given a string, a timestamp field is converted into a DateTime object'
    );

    $attrs = $patron->attributes_from_api(
        {
            last_seen  => '2019-12-27T14:53:00'
        }
    );

    ok( exists $attrs->{lastseen},
        'Translation takes place because of the defined mapping' );
    is(
        ref( $attrs->{lastseen} ),
        'DateTime',
        'Given a string, a datetime field is converted into a DateTime object'
    );

    $attrs = $patron->attributes_from_api(
        {
            date_of_birth  => '2019-12-27'
        }
    );

    ok( exists $attrs->{dateofbirth},
        'Translation takes place because of the defined mapping' );
    is(
        ref( $attrs->{dateofbirth} ),
        'DateTime',
        'Given a string, a date field is converted into a DateTime object'
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

    # Booleans
    $attrs = $patron->attributes_from_api(
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

    # Using Koha::ApiKey to test Koha::Object>-store
    # Simple object with foreign keys and unique key

    $schema->storage->txn_begin;

    # Create a patron to make sure its ID doesn't exist on the DB
    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    my $patron_id = $patron->id;
    $patron->delete;

    my $api_key = Koha::ApiKey->new({ patron_id => $patron_id, secret => 'a secret', description => 'a description' });

    my $print_error = $schema->storage->dbh->{PrintError};
    $schema->storage->dbh->{PrintError} = 0;
    throws_ok
        { $api_key->store }
        'Koha::Exceptions::Object::FKConstraint',
        'Exception is thrown correctly';
    is(
        $@->message,
        "Broken FK constraint",
        'Exception message is correct'
    );
    is(
        $@->broken_fk,
        'patron_id',
        'Exception field is correct'
    );

    $patron = $builder->build_object({ class => 'Koha::Patrons' });
    $api_key = $builder->build_object({ class => 'Koha::ApiKeys' });

    my $new_api_key = Koha::ApiKey->new({
        patron_id => $patron_id,
        secret => $api_key->secret,
        description => 'a description',
    });

    throws_ok
        { $new_api_key->store }
        'Koha::Exceptions::Object::DuplicateID',
        'Exception is thrown correctly';

    is(
        $@->message,
        'Duplicate ID',
        'Exception message is correct'
    );

    like(
       $@->duplicate_id,
       qr/(api_keys\.)?secret/,
       'Exception field is correct (note that MySQL 8 is displaying the tablename)'
    );

    $schema->storage->dbh->{PrintError} = $print_error;

    # Successful test
    $api_key->set({ secret => 'Manuel' });
    my $ret = $api_key->store;
    is( ref($ret), 'Koha::ApiKey', 'store() returns the object on success' );

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron_category = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => { category_type => 'P', enrolmentfee => 0 }
        }
    );

    $patron = eval {
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

        my $print_error = $schema->storage->dbh->{PrintError};
        $schema->storage->dbh->{PrintError} = 0;

        try {
            $patron->lastseen('wrong_value')->store;
        } catch {
            ok( $_->isa('Koha::Exceptions::Object::BadValue'), 'Exception thrown correctly' );
            like( $_->property, qr/(borrowers\.)?lastseen/, 'Column should be the expected one' ); # The table name is not always displayed, it depends on the DBMS version
            is( $_->value, 'wrong_value', 'Value should be the expected one' );
        };

        $schema->storage->dbh->{PrintError} = $print_error;
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
    my $item = $builder->build_object(
        {
            class => 'Koha::Items',
            value => {
                homebranch    => $library->branchcode,
                holdingbranch => $library->branchcode,
                biblionumber  => $biblio->biblionumber,
                itemlost      => 0,
                withdrawn     => 0,
            }
        }
    );

    my $issue = AddIssue( $patron->unblessed, $item->barcode, DateTime->now->subtract( days => 1 ) );
    my $overdues = Koha::Patrons->find( $patron->id )->get_overdues; # Koha::Patron->get_overdue prefetches
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
