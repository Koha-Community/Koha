#!/usr/bin/perl

# Copyright 2016 Koha Development team
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

use t::lib::TestBuilder;
use t::lib::Mocks;
use Test::Exception;

use C4::Context;
use Koha::Database;
use Koha::Patron::Attribute::Types;

my $schema  = Koha::Database->new->schema;
my $dbh     = C4::Context->dbh;
my $builder = t::lib::TestBuilder->new;

subtest 'new() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    # Cleanup before running the tests
    Koha::Patron::Attribute::Types->search()->delete();

    my $attribute_type = Koha::Patron::Attribute::Type->new(
        {
            code        => 'code',
            description => 'description',
            repeatable  => 0
        }
    )->store();

    is(
        Koha::Patron::Attribute::Types->search()->count,
        1, 'Only one object created'
    );

    my $cateogory_code = $builder->build( { source => 'Category' } )->{categorycode};

    my $attribute_type_with_category = Koha::Patron::Attribute::Type->new(
        {
            code          => 'code_2',
            description   => 'description',
            category_code => $cateogory_code,
            repeatable    => 0
        }
    )->store();

    is(
        Koha::Patron::Attribute::Types->search()->count,
        2, 'Two objects created'
    );

    $schema->storage->txn_rollback;
};

subtest 'store' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    # Create 2 attribute types without restrictions:
    # Repeatable and can have the same values
    my $attr_type_1 = $builder->build_object(
        {
            class => 'Koha::Patron::Attribute::Types',
            value => { repeatable => 1, unique_id => 0 }
        }
    );
    my $attr_type_2 = $builder->build_object(
        {
            class => 'Koha::Patron::Attribute::Types',
            value => { repeatable => 1, unique_id => 0 }
        }
    );

    # Patron 1 has twice the attribute 1 and attribute 2
    # Patron 2 has attribute 1 and attribute 2="42"
    # Patron 3 has attribute 2="42"
    # Attribute 1 cannot remove repeatable
    # Attribute 2 cannot set unique_id
    my $patron_1 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron_2 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron_3 = $builder->build_object( { class => 'Koha::Patrons' } );

    my $attribute_111 = $builder->build_object(
        {
            class => 'Koha::Patron::Attributes',
            value => {
                borrowernumber => $patron_1->borrowernumber,
                code           => $attr_type_1->code
            }
        }
    );
    my $attribute_112 = $builder->build_object(
        {
            class => 'Koha::Patron::Attributes',
            value => {
                borrowernumber => $patron_1->borrowernumber,
                code           => $attr_type_1->code
            }
        }
    );

    my $attribute_211 = $builder->build_object(
        {
            class => 'Koha::Patron::Attributes',
            value => {
                borrowernumber => $patron_2->borrowernumber,
                code           => $attr_type_1->code
            }
        }
    );
    my $attribute_221 = $builder->build_object(
        {
            class => 'Koha::Patron::Attributes',
            value => {
                borrowernumber => $patron_2->borrowernumber,
                code           => $attr_type_2->code,
                attribute      => '42',
            }
        }
    );

    my $attribute_321 = $builder->build_object(
        {
            class => 'Koha::Patron::Attributes',
            value => {
                borrowernumber => $patron_3->borrowernumber,
                code           => $attr_type_2->code,
                attribute      => '42',
            }
        }
    );

    throws_ok {
        $attr_type_1->repeatable(0)->store;
    }
    'Koha::Exceptions::Patron::Attribute::Type::CannotChangeProperty', "";

    $attribute_112->delete;
    ok( $attr_type_1->set( { unique_id => 1, repeatable => 0 } )->store );

    throws_ok {
        $attr_type_2->unique_id(1)->store;
    }
    'Koha::Exceptions::Patron::Attribute::Type::CannotChangeProperty', "";

    $attribute_321->attribute(43)->store;
    ok( $attr_type_2->set( { unique_id => 1, repeatable => 0 } )->store );

    $schema->storage->txn_rollback;

};

subtest 'library_limits() tests' => sub {

    plan tests => 13;

    $schema->storage->txn_begin;

    # Cleanup before running the tests
    Koha::Patron::Attribute::Types->search()->delete();

    my $attribute_type = Koha::Patron::Attribute::Type->new(
        {
            code        => 'code',
            description => 'description',
            repeatable  => 0
        }
    )->store();

    my $library = $builder->build( { source => 'Branch' } )->{branchcode};

    my $library_limits = $attribute_type->library_limits();
    is(
        $library_limits, undef,
        'No branch limitations defined for attribute type'
    );

    my $print_error = $dbh->{PrintError};
    $dbh->{PrintError} = 0;

    throws_ok {
        $attribute_type->library_limits( ['fake'] );
    }
    'Koha::Exceptions::CannotAddLibraryLimit',
        'Exception thrown on single invalid branchcode';
    $library_limits = $attribute_type->library_limits();
    is(
        $library_limits, undef,
        'No branch limitations defined for attribute type'
    );

    throws_ok {
        $attribute_type->library_limits( [ 'fake', $library ] );
    }
    'Koha::Exceptions::CannotAddLibraryLimit',
        'Exception thrown on invalid branchcode present';

    $library_limits = $attribute_type->library_limits();
    is(
        $library_limits, undef,
        'No branch limitations defined for attribute type'
    );

    $dbh->{PrintError} = $print_error;

    $attribute_type->library_limits( [$library] );
    $library_limits = $attribute_type->library_limits;
    is( $library_limits->count, 1, 'Library limits correctly set (count)' );
    my $limit_library = $library_limits->next;
    ok(
        $limit_library->isa('Koha::Library'),
        'Library limits correctly set (type)'
    );
    is(
        $limit_library->branchcode,
        $library, 'Library limits correctly set (value)'
    );

    my $another_library  = $builder->build( { source => 'Branch' } )->{branchcode};
    my @branchcodes_list = ( $library, $another_library );

    $attribute_type->library_limits( \@branchcodes_list );
    $library_limits = $attribute_type->library_limits;
    is( $library_limits->count, 2, 'Library limits correctly set (count)' );

    while ( $limit_library = $library_limits->next ) {
        ok(
            $limit_library->isa('Koha::Library'),
            'Library limits correctly set (type)'
        );
        ok(
            eval {
                grep { $limit_library->branchcode eq $_ } @branchcodes_list;
            },
            'Library limits correctly set (values)'
        );
    }

    $schema->storage->txn_rollback;
};

subtest 'add_library_limit() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    # Cleanup before running the tests
    Koha::Patron::Attribute::Types->search()->delete();

    my $attribute_type = Koha::Patron::Attribute::Type->new(
        {
            code        => 'code',
            description => 'description',
            repeatable  => 0
        }
    )->store();

    throws_ok { $attribute_type->add_library_limit() }
    'Koha::Exceptions::MissingParameter', 'branchcode parameter is mandatory';

    my $library = $builder->build( { source => 'Branch' } )->{branchcode};
    $attribute_type->add_library_limit($library);
    my $rs = Koha::Database->schema->resultset('BorrowerAttributeTypesBranch')->search( { bat_code => 'code' } );
    is( $rs->count, 1, 'Library limit successfully added (count)' );
    is(
        $rs->next->b_branchcode->branchcode,
        $library, 'Library limit successfully added (value)'
    );

    my $print_error = $dbh->{PrintError};
    $dbh->{PrintError} = 0;

    throws_ok {
        $attribute_type->add_library_limit('fake');
    }
    'Koha::Exceptions::CannotAddLibraryLimit',
        'Exception thrown on invalid branchcode';

    $dbh->{PrintError} = $print_error;

    $schema->storage->txn_rollback;
};

subtest 'del_library_limit() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    # Cleanup before running the tests
    Koha::Patron::Attribute::Types->search()->delete();

    my $attribute_type = Koha::Patron::Attribute::Type->new(
        {
            code        => 'code',
            description => 'description',
            repeatable  => 0
        }
    )->store();

    throws_ok { $attribute_type->del_library_limit() }
    'Koha::Exceptions::MissingParameter',
        'branchcode parameter is mandatory';

    my $library = $builder->build( { source => 'Branch' } )->{branchcode};
    $attribute_type->add_library_limit($library);

    is(
        $attribute_type->del_library_limit($library),
        1, 'Library limit successfully deleted'
    );

    my $print_error = $dbh->{PrintError};
    $dbh->{PrintError} = 0;

    throws_ok {
        $attribute_type->del_library_limit($library);
    }
    'Koha::Exceptions::ObjectNotFound',
        'Exception thrown on non-existent library limit';

    throws_ok {
        $attribute_type->del_library_limit('fake');
    }
    'Koha::Exceptions::ObjectNotFound',
        'Exception thrown on non-existent library limit';

    $dbh->{PrintError} = $print_error;

    $schema->storage->txn_rollback;
};

subtest 'replace_library_limits() tests' => sub {

    plan tests => 10;

    $schema->storage->txn_begin;

    # Cleanup before running the tests
    Koha::Patron::Attribute::Types->search()->delete();

    my $attribute_type = Koha::Patron::Attribute::Type->new(
        {
            code        => 'code',
            description => 'description',
            repeatable  => 0
        }
    )->store();

    $attribute_type->replace_library_limits( [] );
    my $library_limits = $attribute_type->library_limits;
    is( $library_limits, undef, 'Replacing with empty array yields no library limits' );

    my $library_1 = $builder->build( { source => 'Branch' } )->{branchcode};
    my $library_2 = $builder->build( { source => 'Branch' } )->{branchcode};
    my $library_3 = $builder->build( { source => 'Branch' } )->{branchcode};

    $attribute_type->replace_library_limits( [$library_1] );
    $library_limits = $attribute_type->library_limits;
    is(
        $library_limits->count, 1,
        'Successfully adds a single library limit'
    );
    my $library_limit = $library_limits->next;
    is(
        $library_limit->branchcode,
        $library_1, 'Library limit correctly set'
    );

    my @branchcodes_list = ( $library_1, $library_2, $library_3 );
    $attribute_type->replace_library_limits( [ $library_1, $library_2, $library_3 ] );
    $library_limits = $attribute_type->library_limits;
    is( $library_limits->count, 3, 'Successfully adds two library limit' );

    while ( my $limit_library = $library_limits->next ) {
        ok(
            $limit_library->isa('Koha::Library'),
            'Library limits correctly set (type)'
        );
        ok(
            eval {
                grep { $limit_library->branchcode eq $_ } @branchcodes_list;
            },
            'Library limits correctly set (values)'
        );
    }

    $schema->storage->txn_rollback;
};

subtest 'search_with_library_limits() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    # Cleanup before running the tests
    Koha::Patron::Attribute::Types->search()->delete();

    my $object_code_1 =
        $builder->build_object( { class => 'Koha::Patron::Attribute::Types', value => { code => 'code_1' } } );
    my $object_code_2 =
        $builder->build_object( { class => 'Koha::Patron::Attribute::Types', value => { code => 'code_2' } } );
    my $object_code_3 =
        $builder->build_object( { class => 'Koha::Patron::Attribute::Types', value => { code => 'code_3' } } );
    my $object_code_4 =
        $builder->build_object( { class => 'Koha::Patron::Attribute::Types', value => { code => 'code_4' } } );

    is( Koha::Patron::Attribute::Types->search()->count, 4, 'Three objects created' );

    my $branch_1 = $builder->build( { source => 'Branch' } )->{branchcode};
    my $branch_2 = $builder->build( { source => 'Branch' } )->{branchcode};

    $object_code_1->library_limits( [$branch_1] );
    $object_code_2->library_limits( [$branch_2] );
    $object_code_3->library_limits( [ $branch_1, $branch_2 ] );

    my $results = Koha::Patron::Attribute::Types->search_with_library_limits( {}, { order_by => 'code' }, $branch_1 );

    is( $results->count, 3, '3 attribute types are available for the specified branch' );

    $results = Koha::Patron::Attribute::Types->search_with_library_limits( {}, { order_by => 'code' }, $branch_2 );

    is( $results->count, 3, '3 attribute types are available for the specified branch' );

    $results = Koha::Patron::Attribute::Types->search_with_library_limits( {}, { order_by => 'code' }, undef );

    is( $results->count, 4, 'All attribute types are available with no library pssed' );

    t::lib::Mocks::mock_userenv( { branchcode => $branch_2 } );

    $results = Koha::Patron::Attribute::Types->search_with_library_limits( {}, { order_by => 'code' }, undef );

    is( $results->count, 3, '3 attribute types are available with no library passed' );

    $results = Koha::Patron::Attribute::Types->search_with_library_limits();

    is( $results->count, 3, 'No crash if no params passed' );

    $schema->storage->txn_rollback;
};

