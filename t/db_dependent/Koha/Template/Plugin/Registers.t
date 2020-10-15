#!/usr/bin/perl

# Copyright PTFS Europe 2020

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Test::More tests => 4;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Context;
use Koha::Database;

BEGIN {
    use_ok('Koha::Template::Plugin::Registers');
}

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'session_register_id' => sub {

    plan tests => 3;

    my $plugin = Koha::Template::Plugin::Registers->new();
    ok( $plugin, "Plugin initialized" );
    is( $plugin->session_register_id,
        '', "Returns empty string if no userenv is set" );
    t::lib::Mocks::mock_userenv( { register_id => '1' } );
    is( $plugin->session_register_id,
        '1', "Returns the register id when set in the userenv" );

    # Unset the userenv
    C4::Context->_new_userenv(undef);
};

subtest 'session_register_name' => sub {

    plan tests => 3;

    my $plugin = Koha::Template::Plugin::Registers->new();
    ok( $plugin, "Plugin initialized" );
    is( $plugin->session_register_name,
        '', "Returns empty string if no userenv is set" );
    t::lib::Mocks::mock_userenv( { register_name => 'Register One' } );
    is( $plugin->session_register_name,
        'Register One', "Returns the register name when set in the userenv" );

    # Unset the userenv
    C4::Context->_new_userenv(undef);
};

subtest 'all() tests' => sub {

    plan tests => 20;

    $schema->storage->txn_begin;

    my $library1 = $builder->build_object(
        {
            class => 'Koha::Libraries'
        }
    );
    my $register1 = $builder->build_object(
        {
            class => 'Koha::Cash::Registers',
            value => {
                branch         => $library1->branchcode,
                branch_default => 0
            }
        }
    );
    my $register2 = $builder->build_object(
        {
            class => 'Koha::Cash::Registers',
            value => {
                branch         => $library1->branchcode,
                branch_default => 1
            }
        }
    );

    my $library2 = $builder->build_object(
        {
            class => 'Koha::Libraries'
        }
    );
    my $register3 = $builder->build_object(
        {
            class => 'Koha::Cash::Registers',
            value => {
                branch => $library2->branchcode
            }
        }
    );

    my $plugin = Koha::Template::Plugin::Registers->new();
    ok( $plugin, "Plugin initialized" );

    my $result = $plugin->all;
    is( ref($result), 'ARRAY', "Return arrayref (no userenv, no filters)" );
    is( scalar( @{$result} ),
        3, "Array contains all 3 registers (no userenv, no filters)" );
    for my $register ( @{$result} ) {
        is( $register->{selected}, 0, "Register is not selected (no userenv)" );
    }

    $result = $plugin->all( { filters => { current_branch => 1 } } );
    is( ref($result), 'ARRAY',
        "Return arrayref (no userenv, filters: current_branch)" );

    t::lib::Mocks::mock_userenv( { branchcode => $library1->branchcode } );
    $result = $plugin->all;
    is( ref($result), 'ARRAY',
        "Return arrayref (userenv: branchcode, no filters)" );
    is( scalar( @{$result} ),
        3, "Array contains all 3 registers (userenv: branchcode, no filters)" );
    for my $register ( @{$result} ) {
        is( $register->{selected}, 0,
            "Register is not selected (userenv: branchcode, no filters)" );
    }

    $result = $plugin->all( { filters => { current_branch => 1 } } );
    is( ref($result), 'ARRAY',
        "Return arrayref (userenv: branchcode, filters: current_branch)" );
    is(
        scalar( @{$result} ),
        2,
"Array contains 2 branch registers (userenv: branchcode, filters: current_branch)"
    );
    for my $register ( @{$result} ) {
        is( $register->{selected}, 0,
"Register is not selected (userenv: branchcode, filters: current_branch)"
        );
    }

    t::lib::Mocks::mock_userenv(
        { branchcode => $library1->branchcode, register_id => $register2->id }
    );
    $result = $plugin->all( { filters => { current_branch => 1 } } );
    is( ref($result), 'ARRAY',
"Return arrayref (userenv: branchcode + register_id, filters: current_branch)"
    );
    is(
        scalar( @{$result} ),
        2,
"Array contains 2 branch registers (userenv: branchcode + register_id, filters: current_branch)"
    );
    for my $register ( @{$result} ) {
        my $selected = ( $register->{id} == $register2->id ) ? 1 : 0;
        is( $register->{selected}, $selected,
"Register is selected $selected (userenv: brancode, filters: current_branch)"
        );
    }

    $schema->storage->txn_rollback;
};

1;
