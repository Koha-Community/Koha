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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 2;

use Koha::Database;

use t::lib::TestBuilder;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'search' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my $manager  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $register = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $cashup1  = $builder->build_object(
        {
            class => 'Koha::Cash::Register::Actions',
            value => {
                manager_id  => $manager->borrowernumber,
                register_id => $register->id,
                code        => 'CASHOUT'
            },
        }
    );
    my $cashup2 = $builder->build_object(
        {
            class => 'Koha::Cash::Register::Actions',
            value => {
                manager_id  => $manager->borrowernumber,
                register_id => $register->id,
                code        => 'CASHUP'
            },
        }
    );

    my $cashups = Koha::Cash::Register::Cashups->search();

    is(
        ref($cashups),
        'Koha::Cash::Register::Cashups',
        'Returns a Koha::Cash::Register::Cashups resultset'
    );
    is( $cashups->count, 1, 'Returns only CASHUP actions' );
    is(
        ref( $cashups->next ),
        'Koha::Cash::Register::Cashup',
        'Result is a Koha::Cash::Register::Cashup object'
    );

    $schema->storage->txn_rollback;
};

1;
