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
use Test::More tests => 4;
use t::lib::TestBuilder;

use Koha::Database;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'overdue_fines' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my $checkout = $builder->build_object(
        {
            class => 'Koha::Checkouts',
        }
    );

    my $overdueline = Koha::Account::Line->new(
        {
            issue_id          => $checkout->id,
            borrowernumber    => $checkout->borrowernumber,
            itemnumber        => $checkout->itemnumber,
            branchcode        => $checkout->branchcode,
            date              => \'NOW()',
            debit_type_code   => 'OVERDUE',
            status            => 'UNRETURNED',
            interface         => 'cli',
            amount            => '1',
            amountoutstanding => '1',
        }
    )->store();

    my $accountline = Koha::Account::Line->new(
        {
            issue_id          => $checkout->id,
            borrowernumber    => $checkout->borrowernumber,
            itemnumber        => $checkout->itemnumber,
            branchcode        => $checkout->branchcode,
            date              => \'NOW()',
            debit_type_code   => 'LOST',
            status            => '',
            interface         => 'cli',
            amount            => '1',
            amountoutstanding => '1',
        }
    )->store();

    my $overdue_fines = $checkout->overdue_fines;
    is(
        ref($overdue_fines), 'Koha::Account::Lines',
        'Koha::Checkout->overdue_fines should return a Koha::Account::Lines'
    );
    is( $overdue_fines->count, 1, "Koha::Checkout->overdue_fines returns only overdue fines" );

    my $overdue = $overdue_fines->next;
    is(
        ref($overdue), 'Koha::Account::Line',
        'next returns a Koha::Account::Line'
    );

    is(
        $overdueline->id,
        $overdue->id,
        'Koha::Checkout->overdue_fines should return the correct overdue_fines'
    );

    $schema->storage->txn_rollback;
};

subtest 'library() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $checkout = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => { branchcode => $library->branchcode }
        }
    );

    is( ref( $checkout->library ),      'Koha::Library',      'Object type is correct' );
    is( $checkout->library->branchcode, $library->branchcode, 'Right library linked' );

    $schema->storage->txn_rollback;
};

subtest 'renewals() tests' => sub {

    plan tests => 2;
    $schema->storage->txn_begin;

    my $checkout = $builder->build_object( { class => 'Koha::Checkouts' } );
    my $renewal1 = $builder->build_object(
        {
            class => 'Koha::Checkouts::Renewals',
            value => { checkout_id => undef }
        }
    );
    $renewal1->checkout_id( $checkout->issue_id )->store();
    my $renewal2 = $builder->build_object(
        {
            class => 'Koha::Checkouts::Renewals',
            value => { checkout_id => undef }
        }
    );
    $renewal2->checkout_id( $checkout->issue_id )->store();

    is( ref( $checkout->renewals ), 'Koha::Checkouts::Renewals', 'Object set type is correct' );
    is( $checkout->renewals->count, 2,                           "Count of renewals is correct" );

    $schema->storage->txn_rollback;
};
