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
# along with Koha; if not, see <http://www.gnu.org/licenses>

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 5;
use Test::Exception;
use Test::MockModule;

use DateTime;

use Koha::Account;
use Koha::Account::Lines;
use Koha::Account::Offsets;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'total_outstanding() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    my $lines = Koha::Account::Lines->search( { borrowernumber => $patron->id } );
    is( $lines->total_outstanding, 0, 'total_outstanding returns 0 if no lines (undef case)' );

    my $debit_1 = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            debit_type_code   => "OVERDUE",
            status            => "RETURNED",
            amount            => 10,
            amountoutstanding => 10,
            interface         => 'commandline',
        }
    )->store;

    my $debit_2 = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            debit_type_code   => "OVERDUE",
            status            => "RETURNED",
            amount            => 10,
            amountoutstanding => 10,
            interface         => 'commandline',
        }
    )->store;

    $lines = Koha::Account::Lines->search( { borrowernumber => $patron->id } );
    is( $lines->total_outstanding, 20, 'total_outstanding sums correctly' );

    my $credit_1 = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            credit_type_code  => "PAYMENT",
            amount            => -10,
            amountoutstanding => -10,
            interface         => 'commandline',
        }
    )->store;

    $lines = Koha::Account::Lines->search( { borrowernumber => $patron->id } );
    is( $lines->total_outstanding, 10, 'total_outstanding sums correctly' );

    my $credit_2 = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            credit_type_code  => "PAYMENT",
            amount            => -10,
            amountoutstanding => -10,
            interface         => 'commandline',
        }
    )->store;

    $lines = Koha::Account::Lines->search( { borrowernumber => $patron->id } );
    is( $lines->total_outstanding, 0, 'total_outstanding sums correctly' );

    my $credit_3 = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            credit_type_code  => "PAYMENT",
            amount            => -100,
            amountoutstanding => -100,
            interface         => 'commandline',
        }
    )->store;

    $lines = Koha::Account::Lines->search( { borrowernumber => $patron->id } );
    is( $lines->total_outstanding, -100, 'total_outstanding sums correctly' );

    $schema->storage->txn_rollback;
};

subtest 'total() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    my $lines = Koha::Account::Lines->search( { borrowernumber => $patron->id } );
    is( $lines->total, 0, 'total returns 0 if no lines (undef case)' );

    my $debit_1 = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            debit_type_code   => "OVERDUE",
            status            => "RETURNED",
            amount            => 10,
            amountoutstanding => 10,
            interface         => 'commandline',
        }
    )->store;

    my $debit_2 = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            debit_type_code   => "OVERDUE",
            status            => "RETURNED",
            amount            => 10,
            amountoutstanding => 10,
            interface         => 'commandline',
        }
    )->store;

    $lines = Koha::Account::Lines->search( { borrowernumber => $patron->id } );
    is( $lines->total, 20, 'total sums correctly' );

    my $credit_1 = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            credit_type_code  => "PAYMENT",
            amount            => -10,
            amountoutstanding => -10,
            interface         => 'commandline',
        }
    )->store;

    $lines = Koha::Account::Lines->search( { borrowernumber => $patron->id } );
    is( $lines->total, 10, 'total sums correctly' );

    my $credit_2 = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            credit_type_code  => "PAYMENT",
            amount            => -10,
            amountoutstanding => -10,
            interface         => 'commandline',
        }
    )->store;

    $lines = Koha::Account::Lines->search( { borrowernumber => $patron->id } );
    is( $lines->total, 0, 'total sums correctly' );

    my $credit_3 = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            credit_type_code  => "PAYMENT",
            amount            => -100,
            amountoutstanding => -100,
            interface         => 'commandline',
        }
    )->store;

    $lines = Koha::Account::Lines->search( { borrowernumber => $patron->id } );
    is( $lines->total, -100, 'total sums correctly' );

    $schema->storage->txn_rollback;
};

subtest 'credits_total() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    my $lines = Koha::Account::Lines->search( { borrowernumber => $patron->id } );
    is( $lines->credits_total, 0, 'credits_total returns 0 if no lines (undef case)' );

    my $debit_1 = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            debit_type_code   => "OVERDUE",
            status            => "RETURNED",
            amount            => 10,
            amountoutstanding => 10,
            interface         => 'commandline',
        }
    )->store;

    my $debit_2 = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            debit_type_code   => "OVERDUE",
            status            => "RETURNED",
            amount            => 10,
            amountoutstanding => 10,
            interface         => 'commandline',
        }
    )->store;

    $lines = Koha::Account::Lines->search( { borrowernumber => $patron->id } );
    is( $lines->credits_total, 0, 'credits_total sums correctly' );

    my $credit_1 = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            credit_type_code  => "PAYMENT",
            amount            => -10,
            amountoutstanding => -10,
            interface         => 'commandline',
        }
    )->store;

    $lines = Koha::Account::Lines->search( { borrowernumber => $patron->id } );
    is( $lines->credits_total, -10, 'credits_total sums correctly' );

    my $credit_2 = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            credit_type_code  => "PAYMENT",
            amount            => -10,
            amountoutstanding => -10,
            interface         => 'commandline',
        }
    )->store;

    $lines = Koha::Account::Lines->search( { borrowernumber => $patron->id } );
    is( $lines->credits_total, -20, 'credits_total sums correctly' );

    my $credit_3 = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            credit_type_code  => "PAYMENT",
            amount            => -100,
            amountoutstanding => -100,
            interface         => 'commandline',
        }
    )->store;

    $lines = Koha::Account::Lines->search( { borrowernumber => $patron->id } );
    is( $lines->credits_total, -120, 'credits_total sums correctly' );

    $schema->storage->txn_rollback;
};

subtest 'debits_total() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    my $lines = Koha::Account::Lines->search( { borrowernumber => $patron->id } );
    is( $lines->debits_total, 0, 'debits_total returns 0 if no lines (undef case)' );

    my $debit_1 = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            debit_type_code   => "OVERDUE",
            status            => "RETURNED",
            amount            => 10,
            amountoutstanding => 0,
            interface         => 'commandline',
        }
    )->store;

    my $debit_2 = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            debit_type_code   => "OVERDUE",
            status            => "RETURNED",
            amount            => 10,
            amountoutstanding => 0,
            interface         => 'commandline',
        }
    )->store;

    $lines = Koha::Account::Lines->search( { borrowernumber => $patron->id } );
    is( $lines->debits_total, 20, 'debits_total sums correctly' );

    my $credit_1 = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            credit_type_code  => "PAYMENT",
            amount            => -10,
            amountoutstanding => 0,
            interface         => 'commandline',
        }
    )->store;

    $lines = Koha::Account::Lines->search( { borrowernumber => $patron->id } );
    is( $lines->debits_total, 20, 'debits_total sums correctly' );

    my $credit_2 = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            credit_type_code  => "PAYMENT",
            amount            => -10,
            amountoutstanding => 0,
            interface         => 'commandline',
        }
    )->store;

    $lines = Koha::Account::Lines->search( { borrowernumber => $patron->id } );
    is( $lines->debits_total, 20, 'debits_total sums correctly' );

    my $credit_3 = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            credit_type_code  => "PAYMENT",
            amount            => -100,
            amountoutstanding => 0,
            interface         => 'commandline',
        }
    )->store;

    $lines = Koha::Account::Lines->search( { borrowernumber => $patron->id } );
    is( $lines->debits_total, 20, 'debits_total sums correctly' );

    $schema->storage->txn_rollback;
};

1;
