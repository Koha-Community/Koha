#!/usr/bin/perl

# Copyright 2018 Koha Development team
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
use Test::More tests => 3;

use Koha::Account::Offsets;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'total() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $line = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => { debit_type_code => 'OVERDUE', credit_type_code => undef }
        }
    );

    my $amount_1 = 100;
    my $amount_2 = 200;
    my $amount_3 = -100;
    my $amount_4 = -300;
    my $amount_5 = 500;

    my $offset_1 =
        Koha::Account::Offset->new( { type => 'OVERDUE_INCREASE', amount => $amount_1, debit_id => $line->id } )->store;
    my $offset_2 =
        Koha::Account::Offset->new( { type => 'OVERDUE_INCREASE', amount => $amount_2, debit_id => $line->id } )->store;
    my $offset_3 =
        Koha::Account::Offset->new( { type => 'OVERDUE_DECREASE', amount => $amount_3, debit_id => $line->id } )->store;
    my $offset_4 =
        Koha::Account::Offset->new( { type => 'OVERDUE_DECREASE', amount => $amount_4, debit_id => $line->id } )->store;
    my $offset_5 =
        Koha::Account::Offset->new( { type => 'OVERDUE_INCREASE', amount => $amount_5, debit_id => $line->id } )->store;

    my $debits = Koha::Account::Offsets->search( { type => 'OVERDUE_INCREASE', debit_id => $line->id } );
    is( $debits->total, $amount_1 + $amount_2 + $amount_5 );

    my $credits = Koha::Account::Offsets->search( { type => 'OVERDUE_DECREASE', debit_id => $line->id } );
    is( $credits->total, $amount_3 + $amount_4 );

    my $all = Koha::Account::Offsets->search( { debit_id => $line->id } );
    is( $all->total, $amount_1 + $amount_2 + $amount_3 + $amount_4 + $amount_5 );

    my $none = Koha::Account::Offsets->search( { debit_id => $line->id + 1 } );
    is( $none->total, 0, 'No offsets, returns 0' );

    $schema->storage->txn_rollback;
};

subtest 'filter_by_non_reversible() and filter_by_reversible() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $account = $patron->account;

    my $manual_fee = $account->add_debit( { amount => 11, interface => 'intranet', type => 'MANUAL' } );

    $account->pay( { amount => 1, type => 'WRITEOFF' } );
    $account->pay( { amount => 2, type => 'DISCOUNT' } );
    $account->pay( { amount => 3, type => 'CANCELLATION' } );
    $account->pay( { amount => 4, type => 'PAYMENT' } );
    $account->pay( { amount => 5, type => 'CREDIT' } );

    # non-reversible offsets
    is(
        $manual_fee->debit_offsets->filter_by_non_reversible->count,
        3, '3 non-reversible offsets'
    );
    is(
        $manual_fee->debit_offsets->filter_by_non_reversible->total,
        -6, '-6 the total amount of the non-reversible offsets'
    );

    # reversible offsets
    is(
        $manual_fee->debit_offsets->filter_by_reversible->count,
        2, 'The right reversible offsets count'
    );
    is(
        $manual_fee->debit_offsets->filter_by_reversible->total,
        -5, 'The right total amount of the reversible offsets'
    );

    $schema->storage->txn_rollback;
};
