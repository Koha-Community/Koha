#!/usr/bin/perl

# Copyright 2020 Koha Development team
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
use Test::More tests => 3;

use Koha::Database;

use t::lib::TestBuilder;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'manager' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $manager = $builder->build_object( { class => 'Koha::Patrons' } );
    my $action  = $builder->build_object(
        {
            class => 'Koha::Cash::Register::Actions',
            value => { manager_id => $manager->borrowernumber },
        }
    );

    is(
        ref( $action->manager ),
        'Koha::Patron',
        'Koha::Cash::Register::Action->manager should return a Koha::Patron'
    );

    is(
        $action->manager->id, $manager->id,
        'Koha::Cash::Registeri::Action->manager returns the correct Koha::Patron'
    );

    $schema->storage->txn_rollback;

};

subtest 'register' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $register = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $action   = $builder->build_object(
        {
            class => 'Koha::Cash::Register::Actions',
            value => { register_id => $register->id },
        }
    );

    is(
        ref( $action->register ),
        'Koha::Cash::Register',
        'Koha::Cash::Register::Action->register should return a Koha::Cash::Register'
    );

    is(
        $action->register->id, $register->id,
        'Koha::Cash::Register::Action->register returns the correct Koha::Cash::Register'
    );

    $schema->storage->txn_rollback;

};

1;
