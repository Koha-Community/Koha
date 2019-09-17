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

use Test::Exception;

use Koha::Database;

use t::lib::TestBuilder;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'library' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $register = $builder->build_object(
        {
            class => 'Koha::Cash::Registers',
            value => { branch => $library->branchcode },
        }
    );

    is( ref( $register->library ),
        'Koha::Library',
        'Koha::Cash::Register->library should return a Koha::Library' );

    is( $register->library->id,
        $library->id,
        'Koha::Cash::Register->library returns the correct Koha::Library' );

    $schema->storage->txn_rollback;
};

subtest 'branch_default' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $register1 = $builder->build_object(
        {
            class => 'Koha::Cash::Registers',
            value => { branch => $library->branchcode, branch_default => 1 },
        }
    );
    my $register2 = $builder->build_object(
        {
            class => 'Koha::Cash::Registers',
            value => { branch => $library->branchcode, branch_default => 0 },
        }
    );

    subtest 'store' => sub {
        plan tests => 2;

        $register1->name('Test till 1');
        ok( $register1->store(),
            "Store works as expected when branch_default is not changed" );

        $register1->branch_default(0);
        throws_ok { $register1->store(); }
        'Koha::Exceptions::Object::ReadOnlyProperty',
          'Exception thrown if direct update to branch_default is attempted';

    };

    subtest 'make_default' => sub {
        plan tests => 3;

        ok($register2->make_default,'Koha::Register->make_default ran');

        $register1 = $register1->get_from_storage;
        $register2 = $register2->get_from_storage;
        is($register1->branch_default, 0, 'register1 was unset as expected');
        is($register2->branch_default, 1, 'register2 was set as expected');
    };

    subtest 'drop_default' => sub {
        plan tests => 2;

        ok($register2->drop_default,'Koha::Register->drop_default ran');

        $register2 = $register2->get_from_storage;
        is($register2->branch_default, 0, 'register2 was unset as expected');
    };

    $schema->storage->txn_rollback;
};
