#!/usr/bin/perl

# Copyright 2023 Koha Development team
#
# This file is part of Koha
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

use Koha::ILL::Requests;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'patron() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $patron_module = Test::MockModule->new('Koha::Patron');

    my $patroncategory = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => { can_place_ill_in_opac => 1, BlockExpiredPatronOpacActions => 'ill_request' }
        }
    );
    my $patron =
        $builder->build_object( { class => 'Koha::Patrons', value => { categorycode => $patroncategory->id } } );
    my $request =
        $builder->build_object( { class => 'Koha::ILL::Requests', value => { borrowernumber => $patron->id } } );

    my $req_patron = $request->patron;
    is( ref($req_patron), 'Koha::Patron' );
    is( $req_patron->id,  $patron->id );

    $request = $builder->build_object( { class => 'Koha::ILL::Requests', value => { borrowernumber => undef } } );

    is( $request->patron, undef );

    # patron is not expired, is allowed
    $patron_module->mock( 'is_expired', sub { return 0; } );
    is( $request->can_patron_place_ill_in_opac($patron), 1 );

    # patron is expired, is not allowed
    $patron_module->mock( 'is_expired', sub { return 1; } );
    is( $request->can_patron_place_ill_in_opac($patron), 0 );

    $schema->storage->txn_rollback;
};

subtest 'extended_attributes() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $request = $builder->build_object( { class => 'Koha::ILL::Requests' } );

    is(
        $request->extended_attributes->count, 0,
        'extended_attributes() returns empty if no extended attributes are set'
    );

    my $attribute = $builder->build_object(
        {
            class => 'Koha::ILL::Request::Attributes',
            value => {
                illrequest_id => $request->illrequest_id,
                type          => 'custom_attribute',
                value         => 'custom_value'
            }
        }
    );

    is_deeply(
        $request->extended_attributes->next, $attribute,
        'extended_attributes() returns empty if no extended attributes are set'
    );

    $request->extended_attributes(
        [
            { type => 'type',  value => 'type_value' },
            { type => 'type2', value => 'type2_value' },
        ]
    );

    is(
        $request->extended_attributes->count, 3,
        'extended_attributes() returns the correct amount of attributes'
    );

    is(
        $request->extended_attributes->find( { type => 'type' } )->value, 'type_value',
        'extended_attributes() contains the correct attribute'
    );

    $schema->storage->txn_rollback;
};

subtest 'get_type_disclaimer_value() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $request = $builder->build_object( { class => 'Koha::ILL::Requests' } );

    is(
        $request->get_type_disclaimer_value, undef,
        'get_type_disclaimer_value() returns undef if no get_type_disclaimer_value is set'
    );

    $builder->build_object(
        {
            class => 'Koha::ILL::Request::Attributes',
            value => {
                illrequest_id => $request->illrequest_id,
                type          => 'type_disclaimer_value',
                value         => 'Yes'
            }
        }
    );

    is(
        $request->get_type_disclaimer_value, "Yes",
        'get_type_disclaimer_value() returns the value if is set'
    );

    $schema->storage->txn_rollback;
};

subtest 'get_type_disclaimer_date() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $request = $builder->build_object( { class => 'Koha::ILL::Requests' } );

    is(
        $request->get_type_disclaimer_date, undef,
        'get_type_disclaimer_date() returns undef if no get_type_disclaimer_date is set'
    );

    $builder->build_object(
        {
            class => 'Koha::ILL::Request::Attributes',
            value => {
                illrequest_id => $request->illrequest_id,
                type          => 'type_disclaimer_date',
                value         => '2023-11-27T14:27:01'
            }
        }
    );

    is(
        $request->get_type_disclaimer_date, "2023-11-27T14:27:01",
        'get_type_disclaimer_date() returns the value if is set'
    );

    $schema->storage->txn_rollback;
};

subtest 'get_backend_plugin() tests' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $request = $builder->build_object( { class => 'Koha::ILL::Requests' } );
    t::lib::Mocks::mock_config( 'enable_plugins', 0 );
    is(
        $request->get_backend_plugin, undef,
        'get_backend_plugin returns undef if plugins are disabled'
    );

    $schema->storage->txn_rollback;
};

subtest 'copyright clearance methods tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    # Test set_copyright_clearance_confirmed with truthy value
    my $request = $builder->build_object( { class => 'Koha::ILL::Requests' } );

    $request->set_copyright_clearance_confirmed(1);

    my $attr = $request->extended_attributes->find( { type => 'copyrightclearance_confirmed' } );
    ok( $attr, 'Copyright clearance attribute created' );
    is( $attr->value, 1, 'Copyright clearance value set to 1' );

    # Test setting to false creates attribute with value 0
    my $request2 = $builder->build_object( { class => 'Koha::ILL::Requests' } );
    $request2->set_copyright_clearance_confirmed(0);

    my $attr2 = $request2->extended_attributes->find( { type => 'copyrightclearance_confirmed' } );
    ok( $attr2, 'Attribute created for false value' );
    is( $attr2->value, 0, 'False value normalized to 0' );

    # Test setting to false when already true updates the value
    $request->set_copyright_clearance_confirmed(0);
    my $attr_after_false = $request->extended_attributes->find( { type => 'copyrightclearance_confirmed' } );
    ok( $attr_after_false, 'Attribute still exists after setting to false' );
    is( $attr_after_false->value, 0, 'Attribute value updated to 0 when set to false' );

    # Test get_copyright_clearance_confirmed returns boolean values
    is( $request->get_copyright_clearance_confirmed,  0, 'Returns 0 when set to false' );
    is( $request2->get_copyright_clearance_confirmed, 0, 'Returns 0 when set to false value' );

    $schema->storage->txn_rollback;
};

subtest 'add_or_update_attributes() tests' => sub {

    plan tests => 13;

    $schema->storage->txn_begin;

    my $request = $builder->build_object( { class => 'Koha::ILL::Requests' } );

    # Test adding new attributes
    $request->add_or_update_attributes(
        {
            title  => 'Test Title',
            author => 'Test Author',
            isbn   => '1234567890'
        }
    );

    my $title_attr  = $request->extended_attributes->find( { type => 'title' } );
    my $author_attr = $request->extended_attributes->find( { type => 'author' } );
    my $isbn_attr   = $request->extended_attributes->find( { type => 'isbn' } );

    ok( $title_attr, 'Title attribute created' );
    is( $title_attr->value, 'Test Title', 'Title value set correctly' );
    ok( $author_attr, 'Author attribute created' );
    is( $author_attr->value, 'Test Author', 'Author value set correctly' );
    ok( $isbn_attr, 'ISBN attribute created' );
    is( $isbn_attr->value, '1234567890', 'ISBN value set correctly' );

    # Test updating existing attributes
    $request->add_or_update_attributes(
        {
            title  => 'Updated Title',
            author => 'Test Author',     # Same value, should not update
            year   => '2023'             # New attribute
        }
    );

    $title_attr->discard_changes;
    $author_attr->discard_changes;
    my $year_attr = $request->extended_attributes->find( { type => 'year' } );

    is( $title_attr->value,  'Updated Title', 'Title attribute updated' );
    is( $author_attr->value, 'Test Author',   'Author attribute unchanged when same value' );
    ok( $year_attr, 'Year attribute created' );
    is( $year_attr->value, '2023', 'Year value set correctly' );

    # Test with empty/undefined values (should be skipped)
    $request->add_or_update_attributes(
        {
            empty_field => '',
            undef_field => undef,
            valid_field => 'valid'
        }
    );

    my $empty_attr = $request->extended_attributes->find( { type => 'empty_field' } );
    my $undef_attr = $request->extended_attributes->find( { type => 'undef_field' } );
    my $valid_attr = $request->extended_attributes->find( { type => 'valid_field' } );

    is( $empty_attr, undef, 'Empty value skipped' );
    is( $undef_attr, undef, 'Undefined value skipped' );
    ok( $valid_attr, 'Valid value processed' );

    $schema->storage->txn_rollback;
};
