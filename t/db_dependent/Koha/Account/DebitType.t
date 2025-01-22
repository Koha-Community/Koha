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
use Test::More tests => 8;

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

is(
    Koha::Account::DebitTypes->search->count,
    $number_of_debit_types + 2,
    '2 debit types added successfully'
);

my $retrieved_debit_type_1 = Koha::Account::DebitTypes->find( $new_debit_type_1->code );
is(
    $retrieved_debit_type_1->description,
    $new_debit_type_1->description,
    'Find a debit type by code should return the correct one (non-system)'
);
ok(
    !$retrieved_debit_type_1->is_system,
    'Non-system debit type identified correctly by "is_system"'
);

my $retrieved_debit_type_system = Koha::Account::DebitTypes->find('OVERDUE');
is(
    $retrieved_debit_type_system->code,
    'OVERDUE',
    'Find a debit type by code should return the correct one (system)'
);
ok(
    $retrieved_debit_type_system->is_system,
    'System debit type identified correctly by "is_system"'
);

try {
    $retrieved_debit_type_system->delete;
} catch {
    ok(
        $_->isa('Koha::Exceptions::CannotDeleteDefault'),
        'A system debit type cannot be deleted'
    );
};
$retrieved_debit_type_1->delete;
is(
    Koha::Account::DebitTypes->search->count,
    $number_of_debit_types + 1,
    'A non-system debit type can be deleted'
);

$schema->storage->txn_rollback;

1;
