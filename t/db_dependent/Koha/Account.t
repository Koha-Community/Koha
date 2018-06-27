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

    plan tests => 12;

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

    my $patron_2 = $builder->build_object({ class => 'Koha::Patrons' });
    Koha::Account::Line->new({ borrowernumber => $patron_2->id, amountoutstanding => -2 })->store;
    my $just_one = Koha::Account::Line->new({ borrowernumber => $patron_2->id, amountoutstanding =>  3 })->store;
    Koha::Account::Line->new({ borrowernumber => $patron_2->id, amountoutstanding => -6 })->store;
    ( $total, $lines ) =  Koha::Account->new({ patron_id => $patron_2->id })->outstanding_debits();
    is( $total, 3, "Total if some outstanding debits and some credits is only debits" );
    is( $lines->count, 1, "With 1 outstanding debits, we get back a Lines object with 1 lines" );
    my $the_line = Koha::Account::Lines->find( $just_one->id );
    is_deeply( $the_line->unblessed, $lines->next->unblessed, "We get back the one correct line");

    my $patron_3 = $builder->build_object({ class => 'Koha::Patrons' });
    Koha::Account::Line->new({ borrowernumber => $patron_2->id, amountoutstanding => -2 })->store;
    Koha::Account::Line->new({ borrowernumber => $patron_2->id, amountoutstanding => -20 })->store;
    Koha::Account::Line->new({ borrowernumber => $patron_2->id, amountoutstanding => -200 })->store;
    ( $total, $lines ) =  Koha::Account->new({ patron_id => $patron_3->id })->outstanding_debits();
    is( $total, 0, "Total if no outstanding debits total is 0" );
    is( $lines->count, 0, "With 0 outstanding debits, we get back a Lines object with 0 lines" );

    $schema->storage->txn_rollback;
};
