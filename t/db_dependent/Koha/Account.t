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

use Test::More tests => 3;

use Koha::Account;
use Koha::Account::Lines;
use Koha::Account::Offsets;

use t::lib::Mocks;
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

    my $account = $patron->account;
    my $lines   = $account->outstanding_debits();

    is( $lines->total_outstanding, 10, 'Outstandig debits total is correctly calculated' );

    my $i = 0;
    foreach my $line ( @{ $lines->as_list } ) {
        my $fetched_line = Koha::Account::Lines->find( $generated_lines[$i]->id );
        is_deeply( $line->unblessed, $fetched_line->unblessed, "Fetched line matches the generated one ($i)" );
        $i++;
    }

    my $patron_2 = $builder->build_object({ class => 'Koha::Patrons' });
    Koha::Account::Line->new({ borrowernumber => $patron_2->id, amountoutstanding => -2 })->store;
    my $just_one = Koha::Account::Line->new({ borrowernumber => $patron_2->id, amountoutstanding =>  3 })->store;
    Koha::Account::Line->new({ borrowernumber => $patron_2->id, amountoutstanding => -6 })->store;
    $lines = $patron_2->account->outstanding_debits();
    is( $lines->total_outstanding, 3, "Total if some outstanding debits and some credits is only debits" );
    is( $lines->count, 1, "With 1 outstanding debits, we get back a Lines object with 1 lines" );
    my $the_line = Koha::Account::Lines->find( $just_one->id );
    is_deeply( $the_line->unblessed, $lines->next->unblessed, "We get back the one correct line");

    my $patron_3 = $builder->build_object({ class => 'Koha::Patrons' });
    Koha::Account::Line->new({ borrowernumber => $patron_2->id, amountoutstanding => -2 })->store;
    Koha::Account::Line->new({ borrowernumber => $patron_2->id, amountoutstanding => -20 })->store;
    Koha::Account::Line->new({ borrowernumber => $patron_2->id, amountoutstanding => -200 })->store;
    $lines = $patron_3->account->outstanding_debits();
    is( $lines->total_outstanding, 0, "Total if no outstanding debits total is 0" );
    is( $lines->count, 0, "With 0 outstanding debits, we get back a Lines object with 0 lines" );

    my $patron_4 = $builder->build_object({ class => 'Koha::Patrons' });
    $lines = $patron_4->account->outstanding_debits();
    is( $lines->total_outstanding, 0, "Total if no outstanding debits is 0" );
    is( $lines->count, 0, "With no outstanding debits, we get back a Lines object with 0 lines" );

    $schema->storage->txn_rollback;
};

subtest 'outstanding_credits() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $patron  = $builder->build_object({ class => 'Koha::Patrons' });
    my $account = Koha::Account->new({ patron_id => $patron->id });

    my @generated_lines;
    push @generated_lines, $account->add_credit({ amount => 1 });
    push @generated_lines, $account->add_credit({ amount => 2 });
    push @generated_lines, $account->add_credit({ amount => 3 });
    push @generated_lines, $account->add_credit({ amount => 4 });

    my ( $total, $lines ) = $account->outstanding_credits();

    is( $total, -10, 'Outstandig credits total is correctly calculated' );

    my $i = 0;
    foreach my $line ( @{ $lines->as_list } ) {
        my $fetched_line = Koha::Account::Lines->find( $generated_lines[$i]->id );
        is_deeply( $line->unblessed, $fetched_line->unblessed, "Fetched line matches the generated one ($i)" );
        $i++;
    }

    $schema->storage->txn_rollback;
};

subtest 'add_credit() tests' => sub {

    plan tests => 15;

    $schema->storage->txn_begin;

    # delete logs and statistics
    my $action_logs = $schema->resultset('ActionLog')->search()->count;
    my $statistics = $schema->resultset('Statistic')->search()->count;

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $account = Koha::Account->new( { patron_id => $patron->borrowernumber } );

    is( $account->balance, 0, 'Patron has no balance' );

    # Disable logs
    t::lib::Mocks::mock_preference( 'FinesLog', 0 );

    my $line_1 = $account->add_credit(
        {   amount      => 25,
            description => 'Payment of 25',
            library_id  => $patron->branchcode,
            note        => 'not really important',
            type        => 'payment',
            user_id     => $patron->id
        }
    );

    is( $account->balance, -25, 'Patron has a balance of -25' );
    is( $schema->resultset('ActionLog')->count(), $action_logs + 0, 'No log was added' );
    is( $schema->resultset('Statistic')->count(), $statistics + 1, 'Action added to statistics' );
    is( $line_1->accounttype, $Koha::Account::account_type->{'payment'}, 'Account type is correctly set' );

    # Enable logs
    t::lib::Mocks::mock_preference( 'FinesLog', 1 );

    my $sip_code = "1";
    my $line_2 = $account->add_credit(
        {   amount      => 37,
            description => 'Payment of 37',
            library_id  => $patron->branchcode,
            note        => 'not really important',
            user_id     => $patron->id,
            sip         => $sip_code
        }
    );

    is( $account->balance, -62, 'Patron has a balance of -25' );
    is( $schema->resultset('ActionLog')->count(), $action_logs + 1, 'Log was added' );
    is( $schema->resultset('Statistic')->count(), $statistics + 2, 'Action added to statistics' );
    is( $line_2->accounttype, $Koha::Account::account_type->{'payment'} . $sip_code, 'Account type is correctly set' );

    # offsets have the credit_id set to accountlines_id, and debit_id is undef
    my $offset_1 = Koha::Account::Offsets->search({ credit_id => $line_1->id })->next;
    my $offset_2 = Koha::Account::Offsets->search({ credit_id => $line_2->id })->next;

    is( $offset_1->credit_id, $line_1->id, 'No debit_id is set for credits' );
    is( $offset_1->debit_id, undef, 'No debit_id is set for credits' );
    is( $offset_2->credit_id, $line_2->id, 'No debit_id is set for credits' );
    is( $offset_2->debit_id, undef, 'No debit_id is set for credits' );

    my $line_3 = $account->add_credit(
        {   amount      => 20,
            description => 'Manual credit applied',
            library_id  => $patron->branchcode,
            user_id     => $patron->id,
            type        => 'forgiven'
        }
    );

    is( $schema->resultset('ActionLog')->count(), $action_logs + 2, 'Log was added' );
    is( $schema->resultset('Statistic')->count(), $statistics + 2, 'No action added to statistics, because of credit type' );

    $schema->storage->txn_rollback;
};
