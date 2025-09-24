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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 4;

use Koha::Account::DebitType;
use Koha::Account::DebitTypes;
use Koha::Database;

use t::lib::TestBuilder;

use Try::Tiny;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder               = t::lib::TestBuilder->new;
my $number_of_debit_types = Koha::Account::DebitTypes->search->count;

my $new_debit_type_1 = Koha::Account::DebitType->new(
    {
        code            => '3CODE',
        description     => 'my description 3',
        can_be_invoiced => 1,
        default_amount  => 0.45,
    }
)->store;

my $new_debit_type_2 = Koha::Account::DebitType->new(
    {
        code            => '4CODE',
        description     => 'my description 4',
        can_be_invoiced => 1,
    }
)->store;

my $retrieved_debit_types_all = Koha::Account::DebitTypes->search();
try {
    $retrieved_debit_types_all->delete;
} catch {
    ok(
        $_->isa('Koha::Exceptions::CannotDeleteDefault'),
        'A system debit type cannot be deleted via the set'
    );
};
is(
    Koha::Account::DebitTypes->search->count,
    $number_of_debit_types + 2,
    'System debit types cannot be deleted as a set'
);

my $retrieved_debit_types_limited =
    Koha::Account::DebitTypes->search( { code => { 'in' => [ $new_debit_type_1->code, $new_debit_type_2->code ] } } );
$retrieved_debit_types_limited->delete;
is(
    Koha::Account::DebitTypes->search->count,
    $number_of_debit_types, 'Non-system debit types can be deleted as a set'
);

$schema->storage->txn_rollback;

1;
