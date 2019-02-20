#!/usr/bin/perl

# Copyright 2019 Koha Development team
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

use Test::More tests => 2;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'effective_reset_password() tests' => sub {

    plan tests => 2;

    subtest 'specific overrides global' => sub {

        plan tests => 4;

        $schema->storage->txn_begin;

        my $category = $builder->build_object({
            class => 'Koha::Patron::Categories',
            value => {
                reset_password => 1
            }
        });

        t::lib::Mocks::mock_preference( 'OpacResetPassword', 0 );
        ok( $category->effective_reset_password, 'OpacResetPassword unset, but category has the flag set to 1' );

        t::lib::Mocks::mock_preference( 'OpacResetPassword', 1 );
        ok( $category->effective_reset_password, 'OpacResetPassword set and category has the flag set to 1' );

        # disable
        $category->reset_password( 0 )->store->discard_changes;

        t::lib::Mocks::mock_preference( 'OpacResetPassword', 0 );
        ok( !$category->effective_reset_password, 'OpacResetPassword unset, but category has the flag set to 0' );

        t::lib::Mocks::mock_preference( 'OpacResetPassword', 1 );
        ok( !$category->effective_reset_password, 'OpacResetPassword set and category has the flag set to 0' );

        $schema->storage->txn_rollback;
    };

    subtest 'no specific rule, global applies' => sub {

        plan tests => 2;

        $schema->storage->txn_begin;

        my $category = $builder->build_object({
            class => 'Koha::Patron::Categories',
            value => {
                reset_password => undef
            }
        });

        t::lib::Mocks::mock_preference( 'OpacResetPassword', 0 );
        ok( !$category->effective_reset_password, 'OpacResetPassword set to 0 used' );

        t::lib::Mocks::mock_preference( 'OpacResetPassword', 1 );
        ok( $category->effective_reset_password, 'OpacResetPassword set to 1 used' );

        $schema->storage->txn_rollback;
    };
};

subtest 'effective_change_password() tests' => sub {

    plan tests => 2;

    subtest 'specific overrides global' => sub {

        plan tests => 4;

        $schema->storage->txn_begin;

        my $category = $builder->build_object({
            class => 'Koha::Patron::Categories',
            value => {
                change_password => 1
            }
        });

        t::lib::Mocks::mock_preference( 'OpacPasswordChange', 0 );
        ok( $category->effective_change_password, 'OpacPasswordChange unset, but category has the flag set to 1' );

        t::lib::Mocks::mock_preference( 'OpacPasswordChange', 1 );
        ok( $category->effective_change_password, 'OpacPasswordChange set and category has the flag set to 1' );

        # disable
        $category->change_password( 0 )->store->discard_changes;

        t::lib::Mocks::mock_preference( 'OpacPasswordChange', 0 );
        ok( !$category->effective_change_password, 'OpacPasswordChange unset, but category has the flag set to 0' );

        t::lib::Mocks::mock_preference( 'OpacPasswordChange', 1 );
        ok( !$category->effective_change_password, 'OpacPasswordChange set and category has the flag set to 0' );

        $schema->storage->txn_rollback;
    };

    subtest 'no specific rule, global applies' => sub {

        plan tests => 2;

        $schema->storage->txn_begin;

        my $category = $builder->build_object({
            class => 'Koha::Patron::Categories',
            value => {
                change_password => undef
            }
        });

        t::lib::Mocks::mock_preference( 'OpacPasswordChange', 0 );
        ok( !$category->effective_change_password, 'OpacPasswordChange set to 0 used' );

        t::lib::Mocks::mock_preference( 'OpacPasswordChange', 1 );
        ok( $category->effective_change_password, 'OpacPasswordChange set to 1 used' );

        $schema->storage->txn_rollback;
    };
};
