#!/usr/bin/perl

# Copyright 2015 Koha Development team
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

use Test::More tests => 6;

use Koha::Database;

use t::lib::TestBuilder;

BEGIN {
    use_ok('Koha::Acquisition::Invoice::Adjustments');
}

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $nb_of_adjs = Koha::Acquisition::Invoice::Adjustments->search->count;
my $budget_id = $builder->build({source=>'Aqbudget'})->{budget_id};
my $invoice_id = $builder->build({source=>'Aqinvoice'})->{invoiceid};

my $new_adj = Koha::Acquisition::Invoice::Adjustment->new({
    note => 'noted',
    invoiceid => $invoice_id,
    adjustment => '3',
    reason => 'unreasonable',
    budget_id => $budget_id,
})->store;

like( $new_adj->adjustment_id, qr|^\d+$|, 'Adding a new adjustment should have set the adjustment_id');

my $new_adj2 = Koha::Acquisition::Invoice::Adjustment->new({
    note => 'not noted',
    invoiceid => $invoice_id,
    adjustment => '-3',
    reason => 'unreasonable',
    budget_id => $budget_id,
})->store;

ok( $new_adj->adjustment_id < $new_adj2->adjustment_id, 'Adding a new adjustment should increment');
is( Koha::Acquisition::Invoice::Adjustments->search->count, $nb_of_adjs + 2, 'The 2 adjustments should have been added' );

my $retrieved_adj = Koha::Acquisition::Invoice::Adjustments->find( $new_adj->adjustment_id );
is( $retrieved_adj->reason, $new_adj->reason, 'Find an adjustment by id should return the correct adjustment' );

$retrieved_adj->delete;
is( Koha::Acquisition::Invoice::Adjustments->search->count, $nb_of_adjs + 1, 'Delete should have deleted the adjustment' );

$schema->storage->txn_rollback;
