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

use Test::More tests => 6;
use Test::Exception;

use Koha::Account;
use Koha::Account::Lines;
use Koha::Account::Offsets;


use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'new' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    throws_ok { Koha::Account->new(); } qr/No patron id passed in!/, 'Croaked on bad call to new';

    my $patron  = $builder->build_object({ class => 'Koha::Patrons' });
    my $account = Koha::Account->new( { patron_id => $patron->borrowernumber } );
    is( defined $account, 1, "Account is defined" );

    $schema->storage->txn_rollback;
};

subtest 'outstanding_debits() tests' => sub {

    plan tests => 22;

    $schema->storage->txn_begin;

    my $patron  = $builder->build_object({ class => 'Koha::Patrons' });
    my $account = $patron->account;

    my @generated_lines;
    push @generated_lines, Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 1, amountoutstanding => 1 })->store;
    push @generated_lines, Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 2, amountoutstanding => 2 })->store;
    push @generated_lines, Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 3, amountoutstanding => 3 })->store;
    push @generated_lines, Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 4, amountoutstanding => 4 })->store;

    my $lines     = $account->outstanding_debits();
    my @lines_arr = $account->outstanding_debits();

    is( ref($lines), 'Koha::Account::Lines', 'Called in scalar context, outstanding_debits returns a Koha::Account::Lines object' );
    is( $lines->total_outstanding, 10, 'Outstandig debits total is correctly calculated' );

    my $i = 0;
    foreach my $line ( @{ $lines->as_list } ) {
        my $fetched_line = Koha::Account::Lines->find( $generated_lines[$i]->id );
        is_deeply( $line->unblessed, $fetched_line->unblessed, "Fetched line matches the generated one ($i)" );
        is_deeply( $lines_arr[$i]->unblessed, $fetched_line->unblessed, "Fetched line matches the generated one ($i)" );
        is( ref($lines_arr[$i]), 'Koha::Account::Line', 'outstanding_debits returns a list of Koha::Account::Line objects in list context' );
        $i++;
    }
    my $patron_2 = $builder->build_object({ class => 'Koha::Patrons' });
    Koha::Account::Line->new({ borrowernumber => $patron_2->id, amountoutstanding => -2 })->store;
    my $just_one = Koha::Account::Line->new({ borrowernumber => $patron_2->id, amount => 3, amountoutstanding =>  3 })->store;
    Koha::Account::Line->new({ borrowernumber => $patron_2->id, amount => -6, amountoutstanding => -6 })->store;
    $lines = $patron_2->account->outstanding_debits();
    is( $lines->total_outstanding, 3, "Total if some outstanding debits and some credits is only debits" );
    is( $lines->count, 1, "With 1 outstanding debits, we get back a Lines object with 1 lines" );
    my $the_line = Koha::Account::Lines->find( $just_one->id );
    is_deeply( $the_line->unblessed, $lines->next->unblessed, "We get back the one correct line");

    my $patron_3 = $builder->build_object({ class => 'Koha::Patrons' });
    Koha::Account::Line->new({ borrowernumber => $patron_2->id, amount => -2,   amountoutstanding => -2 })->store;
    Koha::Account::Line->new({ borrowernumber => $patron_2->id, amount => -20,  amountoutstanding => -20 })->store;
    Koha::Account::Line->new({ borrowernumber => $patron_2->id, amount => -200, amountoutstanding => -200 })->store;
    $lines = $patron_3->account->outstanding_debits();
    is( $lines->total_outstanding, 0, "Total if no outstanding debits total is 0" );
    is( $lines->count, 0, "With 0 outstanding debits, we get back a Lines object with 0 lines" );

    my $patron_4  = $builder->build_object({ class => 'Koha::Patrons' });
    my $account_4 = $patron_4->account;
    $lines = $account_4->outstanding_debits();
    is( $lines->total_outstanding, 0, "Total if no outstanding debits is 0" );
    is( $lines->count, 0, "With no outstanding debits, we get back a Lines object with 0 lines" );

    # create a pathological credit with amountoutstanding > 0 (BZ 14591)
    Koha::Account::Line->new({ borrowernumber => $patron_4->id, amount => -3, amountoutstanding => 3 })->store();
    $lines = $account_4->outstanding_debits();
    is( $lines->count, 0, 'No credits are confused with debits because of the amountoutstanding value' );

    $schema->storage->txn_rollback;
};

subtest 'outstanding_credits() tests' => sub {

    plan tests => 17;

    $schema->storage->txn_begin;

    my $patron  = $builder->build_object({ class => 'Koha::Patrons' });
    my $account = $patron->account;

    my @generated_lines;
    push @generated_lines, $account->add_credit({ amount => 1 });
    push @generated_lines, $account->add_credit({ amount => 2 });
    push @generated_lines, $account->add_credit({ amount => 3 });
    push @generated_lines, $account->add_credit({ amount => 4 });

    my $lines     = $account->outstanding_credits();
    my @lines_arr = $account->outstanding_credits();

    is( ref($lines), 'Koha::Account::Lines', 'Called in scalar context, outstanding_credits returns a Koha::Account::Lines object' );
    is( $lines->total_outstanding, -10, 'Outstandig credits total is correctly calculated' );

    my $i = 0;
    foreach my $line ( @{ $lines->as_list } ) {
        my $fetched_line = Koha::Account::Lines->find( $generated_lines[$i]->id );
        is_deeply( $line->unblessed, $fetched_line->unblessed, "Fetched line matches the generated one ($i)" );
        is_deeply( $lines_arr[$i]->unblessed, $fetched_line->unblessed, "Fetched line matches the generated one ($i)" );
        is( ref($lines_arr[$i]), 'Koha::Account::Line', 'outstanding_debits returns a list of Koha::Account::Line objects in list context' );
        $i++;
    }

    my $patron_2 = $builder->build_object({ class => 'Koha::Patrons' });
    $account  = $patron_2->account;
    $lines       = $account->outstanding_credits();
    is( $lines->total_outstanding, 0, "Total if no outstanding credits is 0" );
    is( $lines->count, 0, "With no outstanding credits, we get back a Lines object with 0 lines" );

    # create a pathological debit with amountoutstanding < 0 (BZ 14591)
    Koha::Account::Line->new({ borrowernumber => $patron_2->id, amount => 2, amountoutstanding => -3 })->store();
    $lines = $account->outstanding_credits();
    is( $lines->count, 0, 'No debits are confused with credits because of the amountoutstanding value' );

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

subtest 'lines() tests' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $patron  = $builder->build_object({ class => 'Koha::Patrons' });
    my $account = $patron->account;

    my @generated_lines;

    # Add Credits
    push @generated_lines, $account->add_credit({ amount => 1 });
    push @generated_lines, $account->add_credit({ amount => 2 });
    push @generated_lines, $account->add_credit({ amount => 3 });
    push @generated_lines, $account->add_credit({ amount => 4 });

    # Add Debits
    push @generated_lines, Koha::Account::Line->new({ borrowernumber => $patron->id, amountoutstanding => 1 })->store;
    push @generated_lines, Koha::Account::Line->new({ borrowernumber => $patron->id, amountoutstanding => 2 })->store;
    push @generated_lines, Koha::Account::Line->new({ borrowernumber => $patron->id, amountoutstanding => 3 })->store;
    push @generated_lines, Koha::Account::Line->new({ borrowernumber => $patron->id, amountoutstanding => 4 })->store;

    # Paid Off
    push @generated_lines, Koha::Account::Line->new({ borrowernumber => $patron->id, amountoutstanding => 0 })->store;
    push @generated_lines, Koha::Account::Line->new({ borrowernumber => $patron->id, amountoutstanding => 0 })->store;

    my $lines = $account->lines;
    is( $lines->_resultset->count, 10, "All accountlines (debits, credits and paid off) were fetched");

    $schema->storage->txn_rollback;
};

subtest 'reconcile_balance' => sub {

    plan tests => 4;

    subtest 'more credit than debit' => sub {

        plan tests => 6;

        $schema->storage->txn_begin;

        my $patron  = $builder->build_object({ class => 'Koha::Patrons' });
        my $account = $patron->account;

        # Add Credits
        $account->add_credit({ amount => 1 });
        $account->add_credit({ amount => 2 });
        $account->add_credit({ amount => 3 });
        $account->add_credit({ amount => 4 });
        $account->add_credit({ amount => 5 });

        # Add Debits TODO: replace for calls to add_debit when time comes
        Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 1, amountoutstanding => 1 })->store;
        Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 2, amountoutstanding => 2 })->store;
        Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 3, amountoutstanding => 3 })->store;
        Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 4, amountoutstanding => 4 })->store;

        # Paid Off
        Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 1, amountoutstanding => 0 })->store;
        Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 1, amountoutstanding => 0 })->store;

        is( $account->balance(), -5, "Account balance is -5" );
        is( $account->outstanding_debits->total_outstanding, 10, 'Outstanding debits sum 10' );
        is( $account->outstanding_credits->total_outstanding, -15, 'Outstanding credits sum -15' );

        $account->reconcile_balance();

        is( $account->balance(), -5, "Account balance is -5" );
        is( $account->outstanding_debits->total_outstanding, 0, 'No outstanding debits' );
        is( $account->outstanding_credits->total_outstanding, -5, 'Outstanding credits sum -5' );

        $schema->storage->txn_rollback;
    };

    subtest 'same debit as credit' => sub {

        plan tests => 6;

        $schema->storage->txn_begin;

        my $patron  = $builder->build_object({ class => 'Koha::Patrons' });
        my $account = $patron->account;

        # Add Credits
        $account->add_credit({ amount => 1 });
        $account->add_credit({ amount => 2 });
        $account->add_credit({ amount => 3 });
        $account->add_credit({ amount => 4 });

        # Add Debits TODO: replace for calls to add_debit when time comes
        Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 1, amountoutstanding => 1 })->store;
        Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 2, amountoutstanding => 2 })->store;
        Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 3, amountoutstanding => 3 })->store;
        Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 4, amountoutstanding => 4 })->store;

        # Paid Off
        Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 1, amountoutstanding => 0 })->store;
        Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 1, amountoutstanding => 0 })->store;

        is( $account->balance(), 0, "Account balance is 0" );
        is( $account->outstanding_debits->total_outstanding, 10, 'Outstanding debits sum 10' );
        is( $account->outstanding_credits->total_outstanding, -10, 'Outstanding credits sum -10' );

        $account->reconcile_balance();

        is( $account->balance(), 0, "Account balance is 0" );
        is( $account->outstanding_debits->total_outstanding, 0, 'No outstanding debits' );
        is( $account->outstanding_credits->total_outstanding, 0, 'Outstanding credits sum 0' );

        $schema->storage->txn_rollback;
    };

    subtest 'more debit than credit' => sub {

        plan tests => 6;

        $schema->storage->txn_begin;

        my $patron  = $builder->build_object({ class => 'Koha::Patrons' });
        my $account = $patron->account;

        # Add Credits
        $account->add_credit({ amount => 1 });
        $account->add_credit({ amount => 2 });
        $account->add_credit({ amount => 3 });
        $account->add_credit({ amount => 4 });

        # Add Debits TODO: replace for calls to add_debit when time comes
        Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 1, amountoutstanding => 1 })->store;
        Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 2, amountoutstanding => 2 })->store;
        Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 3, amountoutstanding => 3 })->store;
        Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 4, amountoutstanding => 4 })->store;
        Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 5, amountoutstanding => 5 })->store;

        # Paid Off
        Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 1, amountoutstanding => 0 })->store;
        Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 1, amountoutstanding => 0 })->store;

        is( $account->balance(), 5, "Account balance is 5" );
        is( $account->outstanding_debits->total_outstanding, 15, 'Outstanding debits sum 15' );
        is( $account->outstanding_credits->total_outstanding, -10, 'Outstanding credits sum -10' );

        $account->reconcile_balance();

        is( $account->balance(), 5, "Account balance is 5" );
        is( $account->outstanding_debits->total_outstanding, 5, 'Outstanding debits sum 5' );
        is( $account->outstanding_credits->total_outstanding, 0, 'Outstanding credits sum 0' );

        $schema->storage->txn_rollback;
    };

    subtest 'credits are applied to older debits first' => sub {

        plan tests => 9;

        $schema->storage->txn_begin;

        my $patron  = $builder->build_object({ class => 'Koha::Patrons' });
        my $account = $patron->account;

        # Add Credits
        $account->add_credit({ amount => 1 });
        $account->add_credit({ amount => 3 });

        # Add Debits TODO: replace for calls to add_debit when time comes
        my $debit_1 = Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 1, amountoutstanding => 1 })->store;
        my $debit_2 = Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 2, amountoutstanding => 2 })->store;
        my $debit_3 = Koha::Account::Line->new({ borrowernumber => $patron->id, amount => 3, amountoutstanding => 3 })->store;

        is( $account->balance(), 2, "Account balance is 2" );
        is( $account->outstanding_debits->total_outstanding, 6, 'Outstanding debits sum 6' );
        is( $account->outstanding_credits->total_outstanding, -4, 'Outstanding credits sum -4' );

        $account->reconcile_balance();

        is( $account->balance(), 2, "Account balance is 2" );
        is( $account->outstanding_debits->total_outstanding, 2, 'Outstanding debits sum 2' );
        is( $account->outstanding_credits->total_outstanding, 0, 'Outstanding credits sum 0' );

        $debit_1->discard_changes;
        is( $debit_1->amountoutstanding + 0, 0, 'Old debit payed' );
        $debit_2->discard_changes;
        is( $debit_2->amountoutstanding + 0, 0, 'Old debit payed' );
        $debit_3->discard_changes;
        is( $debit_3->amountoutstanding + 0, 2, 'Newest debit only partially payed' );

        $schema->storage->txn_rollback;
    };
};
