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

use Test::NoWarnings;
use Test::More tests => 5;

use Test::Exception;

use Koha::Database;

use t::lib::TestBuilder;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'library' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $register = $builder->build_object(
        {
            class => 'Koha::Cash::Registers',
            value => { branch => $library->branchcode },
        }
    );

    is(
        ref( $register->library ),
        'Koha::Library',
        'Koha::Cash::Register->library should return a Koha::Library'
    );

    is(
        $register->library->id,
        $library->id,
        'Koha::Cash::Register->library returns the correct Koha::Library'
    );

    $schema->storage->txn_rollback;
};

subtest 'accountlines' => sub {
    plan tests => 5;

    $schema->storage->txn_begin;

    my $register = $builder->build_object( { class => 'Koha::Cash::Registers' } );

    my $accountlines = $register->accountlines;
    is(
        ref($accountlines), 'Koha::Account::Lines',
        'Koha::Cash::Register->accountlines should always return a Koha::Account::Lines set'
    );
    is(
        $accountlines->count, 0,
        'Koha::Cash::Register->accountlines should always return the correct number of accountlines'
    );

    my $accountline1 = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => { register_id => $register->id },
        }
    );
    my $accountline2 = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => { register_id => $register->id },
        }
    );

    $accountlines = $register->accountlines;
    is(
        ref($accountlines), 'Koha::Account::Lines',
        'Koha::Cash::Register->accountlines should return a set of Koha::Account::Lines'
    );
    is(
        $accountlines->count, 2,
        'Koha::Cash::Register->accountlines should return the correct number of accountlines'
    );

    $accountline1->delete;
    is(
        $register->accountlines->next->id, $accountline2->id,
        'Koha::Cash::Register->accountlines should return the correct acocuntlines'
    );

    $schema->storage->txn_rollback;
};

subtest 'branch_default' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;
    my $library   = $builder->build_object( { class => 'Koha::Libraries' } );
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
        ok(
            $register1->store(),
            "Store works as expected when branch_default is not changed"
        );

        $register1->branch_default(0);
        throws_ok { $register1->store(); }
        'Koha::Exceptions::Object::ReadOnlyProperty',
            'Exception thrown if direct update to branch_default is attempted';

    };

    subtest 'make_default' => sub {
        plan tests => 3;

        ok( $register2->make_default, 'Koha::Register->make_default ran' );

        $register1 = $register1->get_from_storage;
        $register2 = $register2->get_from_storage;
        is( $register1->branch_default, 0, 'register1 was unset as expected' );
        is( $register2->branch_default, 1, 'register2 was set as expected' );
    };

    subtest 'drop_default' => sub {
        plan tests => 2;

        ok( $register2->drop_default, 'Koha::Register->drop_default ran' );

        $register2 = $register2->get_from_storage;
        is( $register2->branch_default, 0, 'register2 was unset as expected' );
    };

    $schema->storage->txn_rollback;
};

subtest 'cashup' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my $register = $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );

    my $cashup1;
    subtest 'add_cashup' => sub {
        plan tests => 6;

        ok(
            $cashup1 = $register->add_cashup( { manager_id => $patron->id, amount => '12.00' } ),
            'call successfull'
        );

        is(
            ref($cashup1),
            'Koha::Cash::Register::Cashup',
            'return is Koha::Cash::Register::Cashup'
        );
        is(
            $cashup1->code, 'CASHUP',
            'CASHUP code set in Koha::Cash::Register::Cashup'
        );
        is(
            $cashup1->manager_id, $patron->id,
            'manager_id set correctly in Koha::Cash::Register::Cashup'
        );
        is(
            $cashup1->amount, '12.000000',
            'amount set correctly in Koha::Cash::Register::Cashup'
        );
        isnt(
            $cashup1->timestamp, undef,
            'timestamp set in Koha::Cash::Register::Cashup'
        );
    };

    subtest 'last_cashup' => sub {
        plan tests => 3;

        my $cashup2 = $register->add_cashup( { manager_id => $patron->id, amount => '6.00' } );

        my $last_cashup = $register->last_cashup;
        is(
            ref($last_cashup),
            'Koha::Cash::Register::Cashup',
            'A cashup was returned when one existed'
        );
        is(
            $last_cashup->id, $cashup2->id,
            'The most recent cashup was returned'
        );
        $cashup1->delete;
        $cashup2->delete;
        $last_cashup = $register->last_cashup;
        is( $last_cashup, undef, 'undef is returned when no cashup exists' );
    };

    subtest 'cashups' => sub {
        plan tests => 4;

        my $cashups = $register->cashups;
        is(
            ref($cashups), 'Koha::Cash::Register::Cashups',
            'Koha::Cash::Register->cashups should always return a Koha::Cash::Register::Cashups set'
        );
        is(
            $cashups->count, 0,
            'Koha::Cash::Register->cashups should always return the correct number of cashups'
        );

        my $cashup3 = $register->add_cashup( { manager_id => $patron->id, amount => '6.00' } );

        $cashups = $register->cashups;
        is(
            ref($cashups), 'Koha::Cash::Register::Cashups',
            'Koha::Cash::Register->cashups should return a Koha::Cash::Register::Cashups set'
        );
        is(
            $cashups->count, 1,
            'Koha::Cash::Register->cashups should return the correct number of cashups'
        );

        $cashup3->delete;
    };

    subtest 'outstanding_accountlines' => sub {
        plan tests => 6;

        my $accountlines = $register->outstanding_accountlines;
        is(
            ref($accountlines), 'Koha::Account::Lines',
            'Koha::Cash::Register->outstanding_accountlines should always return a Koha::Account::Lines set'
        );
        is(
            $accountlines->count, 0,
            'Koha::Cash::Register->outstanding_accountlines should always return the correct number of accountlines'
        );

        my $accountline1 = $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => { register_id => $register->id, date => \'NOW() - INTERVAL 5 MINUTE' },
            }
        );
        my $accountline2 = $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => { register_id => $register->id, date => \'NOW() - INTERVAL 5 MINUTE' },
            }
        );

        $accountlines = $register->outstanding_accountlines;
        is( $accountlines->count, 2, 'No cashup, all accountlines returned' );

        my $cashup3 = $register->add_cashup( { manager_id => $patron->id, amount => '2.50' } );

        $accountlines = $register->outstanding_accountlines;
        is( $accountlines->count, 0, 'Cashup added, no accountlines returned' );

        my $accountline3 = $builder->build_object(
            {
                class => 'Koha::Account::Lines',
                value => { register_id => $register->id },
            }
        );

        # Fake the cashup timestamp to make sure it's before the accountline we just added,
        # we can't trust that these two actions are more than a second apart in a test
        $cashup3->timestamp( \'NOW() - INTERVAL 2 MINUTE' )->store;

        $accountlines = $register->outstanding_accountlines;
        is(
            $accountlines->count, 1,
            'Accountline added, one accountline returned'
        );
        is(
            $accountlines->next->id,
            $accountline3->id, 'Correct accountline returned'
        );
    };

    $schema->storage->txn_rollback;
};
