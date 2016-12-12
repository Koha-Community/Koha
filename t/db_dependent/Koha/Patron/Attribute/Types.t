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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 5;

use t::lib::TestBuilder;
use t::lib::Mocks;
use Test::Exception;

use C4::Context;
use Koha::Database;
use Koha::Patron::Attribute::Type;
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
        {   code        => 'code',
            description => 'description',
            repeatable  => 0
        }
    )->store();

    is( Koha::Patron::Attribute::Types->search()->count,
        1, 'Only one object created' );

    my $cateogory_code
        = $builder->build( { source => 'Category' } )->{categorycode};

    my $attribute_type_with_category = Koha::Patron::Attribute::Type->new(
        {   code          => 'code_2',
            description   => 'description',
            category_code => $cateogory_code,
            repeatable    => 0
        }
    )->store();

    is( Koha::Patron::Attribute::Types->search()->count,
        2, 'Two objects created' );

    $schema->storage->txn_rollback;
};

subtest 'library_limits() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    # Cleanup before running the tests
    Koha::Patron::Attribute::Types->search()->delete();

    my $attribute_type = Koha::Patron::Attribute::Type->new(
        {   code        => 'code',
            description => 'description',
            repeatable  => 0
        }
    )->store();

    my $library = $builder->build( { source => 'Branch' } )->{branchcode};

    my $library_limits = $attribute_type->library_limits();
    is_deeply( $library_limits, [],
        'No branch limitations defined for attribute type' );

    my $print_error = $dbh->{PrintError};
    $dbh->{PrintError} = 0;

    throws_ok {
        $library_limits = $attribute_type->library_limits( ['fake'] );
    }
    'Koha::Exceptions::CannotAddLibraryLimit',
        'Exception thrown on single invalid branchcode';

    throws_ok {
        $library_limits
            = $attribute_type->library_limits( [ 'fake', $library ] );
    }
    'Koha::Exceptions::CannotAddLibraryLimit',
        'Exception thrown on invalid branchcode present';

    $dbh->{PrintError} = $print_error;

    $library_limits = $attribute_type->library_limits( [$library] );
    is_deeply( $library_limits, [1], 'Library limits correctly set' );

    my $another_library
        = $builder->build( { source => 'Branch' } )->{branchcode};

    $library_limits
        = $attribute_type->library_limits( [ $library, $another_library ] );
    is_deeply( $library_limits, [ 1, 1 ], 'Library limits correctly set' );

    $schema->storage->txn_rollback;
};

subtest 'add_library_limit() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    # Cleanup before running the tests
    Koha::Patron::Attribute::Types->search()->delete();

    my $attribute_type = Koha::Patron::Attribute::Type->new(
        {   code        => 'code',
            description => 'description',
            repeatable  => 0
        }
    )->store();

    throws_ok { $attribute_type->add_library_limit() }
    'Koha::Exceptions::MissingParameter',
        'branchcode parameter is mandatory';

    my $library = $builder->build( { source => 'Branch' } )->{branchcode};
    is( $attribute_type->add_library_limit($library),
        1, 'Library limit successfully added' );

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
        {   code        => 'code',
            description => 'description',
            repeatable  => 0
        }
    )->store();

    throws_ok { $attribute_type->del_library_limit() }
    'Koha::Exceptions::MissingParameter',
        'branchcode parameter is mandatory';

    my $library = $builder->build( { source => 'Branch' } )->{branchcode};
    $attribute_type->add_library_limit($library);

    is( $attribute_type->del_library_limit($library),
        1, 'Library limit successfully deleted' );

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

    plan tests => 6;

    $schema->storage->txn_begin;

    # Cleanup before running the tests
    Koha::Patron::Attribute::Types->search()->delete();

    my $attribute_type = Koha::Patron::Attribute::Type->new(
        {   code        => 'code',
            description => 'description',
            repeatable  => 0
        }
    )->store();

    is_deeply( $attribute_type->replace_library_limits( [] ),
        [], 'Replacing with empty array returns an empty array as expected' );

    is_deeply( $attribute_type->library_limits(),
        [], 'Replacing with empty array yields no library limits' );

    my $library_1 = $builder->build({ source => 'Branch'})->{branchcode};
    my $library_2 = $builder->build({ source => 'Branch'})->{branchcode};

    is_deeply( $attribute_type->replace_library_limits( [$library_1] ),
        [ 1 ], 'Successfully adds a single library limit' );

    is_deeply( $attribute_type->library_limits(),
        [ $library_1 ], 'Library limit correctly set' );

    is_deeply( $attribute_type->replace_library_limits( [$library_1, $library_2] ),
        [ 1, 1 ], 'Successfully adds two library limit' );

    is_deeply( $attribute_type->library_limits(),
        [ $library_1, $library_2 ], 'Library limit correctly set' );

    $schema->storage->txn_rollback;
};

1;
