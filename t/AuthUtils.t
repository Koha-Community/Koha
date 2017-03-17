# This file is part of Koha.
#
# Copyright (C) 2013 Equinox Software, Inc.
# Copyright 2017 Koha Development Team
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
use Test::More tests => 3;

use t::lib::Mocks;
use Koha::AuthUtils qw/hash_password/;

my $hash1 = hash_password('password');
my $hash2 = hash_password('password');

ok($hash1 ne $hash2, 'random salts used when generating password hash');

subtest 'is_password_valid' => sub {
    plan tests => 12;

    my ( $is_valid, $error );

    t::lib::Mocks::mock_preference('RequireStrongPassword', 0);
    t::lib::Mocks::mock_preference('minPasswordLength', 0);
    ( $is_valid, $error ) = Koha::AuthUtils::is_password_valid( '12' );
    is( $is_valid, 0, 'min password size should be 3' );
    is( $error, 'too_short', 'min password size should be 3' );
    ( $is_valid, $error ) = Koha::AuthUtils::is_password_valid( ' 123' );
    is( $is_valid, 0, 'password should not contain leading spaces' );
    is( $error, 'has_whitespaces', 'password should not contain leading spaces' );
    ( $is_valid, $error ) = Koha::AuthUtils::is_password_valid( '123 ' );
    is( $is_valid, 0, 'password should not contain trailing spaces' );
    is( $error, 'has_whitespaces', 'password should not contain trailing spaces' );
    ( $is_valid, $error ) = Koha::AuthUtils::is_password_valid( '123' );
    is( $is_valid, 1, 'min password size should be 3' );

    t::lib::Mocks::mock_preference('RequireStrongPassword', 1);
    t::lib::Mocks::mock_preference('minPasswordLength', 8);
    ( $is_valid, $error ) = Koha::AuthUtils::is_password_valid( '12345678' );
    is( $is_valid, 0, 'password should be strong' );
    is( $error, 'too_weak', 'password should be strong' );
    ( $is_valid, $error ) = Koha::AuthUtils::is_password_valid( 'abcd1234' );
    is( $is_valid, 0, 'strong password should contain uppercase' );
    is( $error, 'too_weak', 'strong password should contain uppercase' );

    ( $is_valid, $error ) = Koha::AuthUtils::is_password_valid( 'abcD1234' );
    is( $is_valid, 1, 'strong password should contain uppercase' );
};

subtest 'generate_password' => sub {
    plan tests => 1;
    t::lib::Mocks::mock_preference('RequireStrongPassword', 1);
    t::lib::Mocks::mock_preference('minPasswordLength', 8);
    my $all_valid = 1;
    for ( 1 .. 10 ) {
        my $password = Koha::AuthUtils::generate_password;
        my ( $is_valid, undef ) = Koha::AuthUtils::is_password_valid( $password );
        $all_valid = 0 unless $is_valid;
    }
    is ( $all_valid, 1, 'generate_password should generate valid passwords' );
};
