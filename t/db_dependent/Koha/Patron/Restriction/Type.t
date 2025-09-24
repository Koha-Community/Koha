#!/usr/bin/perl

# Copyright 2022 Koha Development team
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
# along with Koha; if not, see <https://www.gnu.org/licenses>

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 4;
use Test::Exception;

use Koha::Database;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

use_ok('Koha::Patron::Restriction::Type');

subtest 'delete() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    # Default restriction type
    my $default_restriction_type = Koha::Patron::Restriction::Types->find( { is_default => 1 } );
    throws_ok { $default_restriction_type->delete }
    'Koha::Exceptions::CannotDeleteDefault',
        'Delete exception thrown on current default';

    # System restriction type
    my $system_restriction_type = $builder->build_object(
        {
            class => 'Koha::Patron::Restriction::Types',
            value => {
                is_system  => 1,
                is_default => 0,
            }
        }
    )->store;
    throws_ok { $system_restriction_type->delete }
    'Koha::Exceptions::CannotDeleteSystem',
        'Delete exception thrown on system type';

    # Used restriction type
    my $used_restriction_type = $builder->build_object(
        {
            class => 'Koha::Patron::Restriction::Types',
            value => {
                is_system  => 0,
                is_default => 0,
            }
        }
    )->store;
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
        }
    )->store;
    Koha::Patron::Debarments::AddDebarment(
        {
            borrowernumber => $patron->borrowernumber,
            expiration     => '9999-06-10',
            type           => $used_restriction_type->code,
            comment        => 'Test 1',
        }
    );
    ok( $used_restriction_type->delete, 'Used restriction type deleted' );
    my $restrictions    = $patron->restrictions;
    my $THE_restriction = $restrictions->next;
    is(
        $THE_restriction->type->code,
        $default_restriction_type->code,
        'Used restriction updated to default'
    );

    $schema->storage->txn_rollback;
};

subtest 'make_default() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    # Get current default restriction type
    my $current_default = Koha::Patron::Restriction::Types->find( { is_default => 1 } );

    # New non-default restriction type
    my $new_default = $builder->build_object(
        {
            class => 'Koha::Patron::Restriction::Types',
            value => { is_system => 0, is_default => 0 }
        }
    );

    $new_default->make_default;

    $current_default->discard_changes;
    is( $current_default->is_default, 0, 'is_default set to false on prior default' );
    is( $new_default->is_default,     1, 'is_default set true on new default' );

    $schema->storage->txn_rollback;
};

1;
