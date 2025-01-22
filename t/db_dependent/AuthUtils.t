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

use Test::NoWarnings;
use Test::More tests => 3;
use Test::Exception;
use Test::MockModule;
use t::lib::Mocks;
use t::lib::TestBuilder;
use Koha::AuthUtils;

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

$schema->storage->txn_begin;

my $category1 = $builder->build_object(
    {
        class => 'Koha::Patron::Categories',
        value => { min_password_length => 15, require_strong_password => 1 }
    }
);
my $category2 = $builder->build_object(
    {
        class => 'Koha::Patron::Categories',
        value => { min_password_length => 5, require_strong_password => undef }
    }
);
my $category3 = $builder->build_object(
    {
        class => 'Koha::Patron::Categories',
        value => { min_password_length => undef, require_strong_password => 1 }
    }
);
my $category4 = $builder->build_object(
    {
        class => 'Koha::Patron::Categories',
        value => { min_password_length => undef, require_strong_password => undef }
    }
);

my $p_2l         = '1A';
my $p_3l_weak    = '123';
my $p_3l_strong  = '1Ab';
my $p_5l_weak    = 'abcde';
my $p_15l_weak   = '0123456789abcdf';
my $p_5l_strong  = 'Abc12';
my $p_15l_strong = '0123456789AbCdF';

subtest 'is_password_valid for category' => sub {
    plan tests => 15;

    my ( $is_valid, $error );

    t::lib::Mocks::mock_preference( 'RequireStrongPassword', 0 );
    t::lib::Mocks::mock_preference( 'minPasswordLength',     3 );

    #Category 1 - override=>1, length=>15, strong=>1
    ( $is_valid, $error ) = Koha::AuthUtils::is_password_valid( $p_5l_strong, $category1 );
    is( $is_valid, 0,           'min password length for this category is 15' );
    is( $error,    'too_short', 'min password length for this category is 15' );

    ( $is_valid, $error ) = Koha::AuthUtils::is_password_valid( $p_15l_weak, $category1 );
    is( $is_valid, 0,          'password should be strong for this category' );
    is( $error,    'too_weak', 'password should be strong for this category' );

    ( $is_valid, $error ) = Koha::AuthUtils::is_password_valid( $p_15l_strong, $category1 );
    is( $is_valid, 1, 'password should be ok for this category' );

    #Category 2 - override=>1, length=>5, strong=>0
    ( $is_valid, $error ) = Koha::AuthUtils::is_password_valid( $p_3l_strong, $category2 );
    is( $is_valid, 0,           'min password length for this category is 5' );
    is( $error,    'too_short', 'min password length for this category is 5' );

    ( $is_valid, $error ) = Koha::AuthUtils::is_password_valid( $p_5l_weak, $category2 );
    is( $is_valid, 1, 'password should be ok for this category' );

    #Category 3 - override=>0, length=>20, strong=>0
    ( $is_valid, $error ) = Koha::AuthUtils::is_password_valid( $p_3l_weak, $category3 );
    is( $is_valid, 0,          'password should be strong' );
    is( $error,    'too_weak', 'password should be strong' );

    ( $is_valid, $error ) = Koha::AuthUtils::is_password_valid( $p_3l_strong, $category3 );
    is( $is_valid, 1, 'password should be ok' );

    #Category 4 - default settings - override=>undef, length=>undef, strong=>undef
    ( $is_valid, $error ) = Koha::AuthUtils::is_password_valid( $p_3l_weak, $category4 );
    is( $is_valid, 1, 'password should be ok' );

    t::lib::Mocks::mock_preference( 'minPasswordLength', 0 );
    ( $is_valid, $error ) = Koha::AuthUtils::is_password_valid( $p_2l, $category4 );
    is( $is_valid, 0,           '3 is absolute minimum password' );
    is( $error,    'too_short', '3 is absolute minimum password' );

    throws_ok { Koha::AuthUtils::is_password_valid($p_2l); }
    'Koha::Exceptions::Password::NoCategoryProvided',
        'Category should always be provided';

};

subtest 'generate_password for category' => sub {
    plan tests => 5;

    my ( $is_valid, $error );

    t::lib::Mocks::mock_preference( 'RequireStrongPassword', 0 );
    t::lib::Mocks::mock_preference( 'minPasswordLength',     3 );

    #Category 4
    my $password = Koha::AuthUtils::generate_password($category4);
    ( $is_valid, $error ) = Koha::AuthUtils::is_password_valid( $password, $category4 );
    is( $is_valid, 1, 'password should be ok' );

    #Category 3
    $password = Koha::AuthUtils::generate_password($category3);
    ( $is_valid, $error ) = Koha::AuthUtils::is_password_valid( $password, $category3 );
    is( $is_valid, 1, 'password should be ok' );

    #Category 2
    $password = Koha::AuthUtils::generate_password($category2);
    ( $is_valid, $error ) = Koha::AuthUtils::is_password_valid( $password, $category2 );
    is( $is_valid, 1, 'password should be ok' );

    #Category 1
    $password = Koha::AuthUtils::generate_password($category1);
    ( $is_valid, $error ) = Koha::AuthUtils::is_password_valid( $password, $category1 );
    is( $is_valid, 1, 'password should be ok' );

    throws_ok { Koha::AuthUtils::generate_password(); }
    'Koha::Exceptions::Password::NoCategoryProvided',
        'Category should always be provided';

};

$schema->storage->txn_rollback;
