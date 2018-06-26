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

use Test::More tests => 1;

use Koha::Account;
use Koha::Account::Lines;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'outstanding_debits() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object({ class => 'Koha::Patrons' });

    my @generated_lines;
    push @generated_lines, Koha::Account::Line->new({ borrowernumber => $patron->id, amountoutstanding => 1 })->store;
    push @generated_lines, Koha::Account::Line->new({ borrowernumber => $patron->id, amountoutstanding => 2 })->store;
    push @generated_lines, Koha::Account::Line->new({ borrowernumber => $patron->id, amountoutstanding => 3 })->store;
    push @generated_lines, Koha::Account::Line->new({ borrowernumber => $patron->id, amountoutstanding => 4 })->store;

    my $account = Koha::Account->new({ patron_id => $patron->id });
    my ( $total, $lines ) = $account->outstanding_debits();

    is( $total, 10, 'Outstandig debits total is correctly calculated' );

    my $i = 0;
    foreach my $line ( @{ $lines->as_list } ) {
        my $fetched_line = Koha::Account::Lines->find( $generated_lines[$i]->id );
        is_deeply( $line->unblessed, $fetched_line->unblessed, "Fetched line matches the generated one ($i)" );
        $i++;
    }

    ( $total, $lines ) =  Koha::Account->new({ patron_id => 'InvalidBorrowernumber' })->outstanding_debits();
    is( $total, 0, "Total if no outstanding debits is 0" );
    is( $lines->count, 0, "With no outstanding debits, we get back a Lines object with 0 lines" );


    $schema->storage->txn_rollback;
};
