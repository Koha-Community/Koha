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

use Test::More tests => 15;
use Test::MockModule;
use Test::Exception;

use DateTime;

use Koha::Account;
use Koha::Account::CreditTypes;
use Koha::Account::Lines;
use Koha::Account::Offsets;
use Koha::DateUtils qw( dt_from_string );

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
$schema->storage->dbh->{PrintError} = 0;
my $builder = t::lib::TestBuilder->new;
C4::Context->interface('commandline');

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

    plan tests => 10;

    $schema->storage->txn_begin;

    my $patron  = $builder->build_object({ class => 'Koha::Patrons' });
    my $account = $patron->account;

    my @generated_lines;
    push @generated_lines, $account->add_debit({ amount => 1, interface => 'commandline', type => 'OVERDUE' });
    push @generated_lines, $account->add_debit({ amount => 2, interface => 'commandline', type => 'OVERDUE' });
    push @generated_lines, $account->add_debit({ amount => 3, interface => 'commandline', type => 'OVERDUE' });
    push @generated_lines, $account->add_debit({ amount => 4, interface => 'commandline', type => 'OVERDUE' });

    my $lines     = $account->outstanding_debits();

    is( ref($lines), 'Koha::Account::Lines', 'Called in scalar context, outstanding_debits returns a Koha::Account::Lines object' );
    is( $lines->total_outstanding, 10, 'Outstandig debits total is correctly calculated' );

    my $patron_2 = $builder->build_object({ class => 'Koha::Patrons' });
    Koha::Account::Line->new(
        {
            borrowernumber    => $patron_2->id,
            amountoutstanding => -2,
            interface         => 'commandline',
            credit_type_code  => 'PAYMENT'
        }
    )->store;
    my $just_one = Koha::Account::Line->new(
        {
            borrowernumber    => $patron_2->id,
            amount            => 3,
            amountoutstanding => 3,
            interface         => 'commandline',
            debit_type_code   => 'OVERDUE'
        }
    )->store;
    Koha::Account::Line->new(
        {
            borrowernumber    => $patron_2->id,
            amount            => -6,
            amountoutstanding => -6,
            interface         => 'commandline',
            credit_type_code  => 'PAYMENT'
        }
    )->store;
    $lines = $patron_2->account->outstanding_debits();
    is( $lines->total_outstanding, 3, "Total if some outstanding debits and some credits is only debits" );
    is( $lines->count, 1, "With 1 outstanding debits, we get back a Lines object with 1 lines" );
    my $the_line = Koha::Account::Lines->find( $just_one->id );
    is_deeply( $the_line->unblessed, $lines->next->unblessed, "We get back the one correct line");

    my $patron_3  = $builder->build_object({ class => 'Koha::Patrons' });
    my $account_3 = $patron_3->account;
    $account_3->add_credit( { amount => 2,   interface => 'commandline' } );
    $account_3->add_credit( { amount => 20,  interface => 'commandline' } );
    $account_3->add_credit( { amount => 200, interface => 'commandline' } );
    $lines = $account_3->outstanding_debits();
    is( $lines->total_outstanding, 0, "Total if no outstanding debits total is 0" );
    is( $lines->count, 0, "With 0 outstanding debits, we get back a Lines object with 0 lines" );

    my $patron_4  = $builder->build_object({ class => 'Koha::Patrons' });
    my $account_4 = $patron_4->account;
    $lines = $account_4->outstanding_debits();
    is( $lines->total_outstanding, 0, "Total if no outstanding debits is 0" );
    is( $lines->count, 0, "With no outstanding debits, we get back a Lines object with 0 lines" );

    # create a pathological credit with amountoutstanding > 0 (BZ 14591)
    Koha::Account::Line->new(
        {
            borrowernumber    => $patron_4->id,
            amount            => -3,
            amountoutstanding => 3,
            interface         => 'commandline',
            credit_type_code  => 'PAYMENT'
        }
    )->store();
    $lines = $account_4->outstanding_debits();
    is( $lines->count, 0, 'No credits are confused with debits because of the amountoutstanding value' );

    $schema->storage->txn_rollback;
};

subtest 'outstanding_credits() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $patron  = $builder->build_object({ class => 'Koha::Patrons' });
    my $account = $patron->account;

    my @generated_lines;
    push @generated_lines, $account->add_credit({ amount => 1, interface => 'commandline' });
    push @generated_lines, $account->add_credit({ amount => 2, interface => 'commandline' });
    push @generated_lines, $account->add_credit({ amount => 3, interface => 'commandline' });
    push @generated_lines, $account->add_credit({ amount => 4, interface => 'commandline' });

    my $lines     = $account->outstanding_credits();

    is( ref($lines), 'Koha::Account::Lines', 'Called in scalar context, outstanding_credits returns a Koha::Account::Lines object' );
    is( $lines->total_outstanding, -10, 'Outstandig credits total is correctly calculated' );

    my $patron_2 = $builder->build_object({ class => 'Koha::Patrons' });
    $account  = $patron_2->account;
    $lines       = $account->outstanding_credits();
    is( $lines->total_outstanding, 0, "Total if no outstanding credits is 0" );
    is( $lines->count, 0, "With no outstanding credits, we get back a Lines object with 0 lines" );

    # create a pathological debit with amountoutstanding < 0 (BZ 14591)
    Koha::Account::Line->new(
        {
            borrowernumber    => $patron_2->id,
            amount            => 2,
            amountoutstanding => -3,
            interface         => 'commandline',
            debit_type_code   => 'OVERDUE'
        }
    )->store();
    $lines = $account->outstanding_credits();
    is( $lines->count, 0, 'No debits are confused with credits because of the amountoutstanding value' );

    $schema->storage->txn_rollback;
};

subtest 'add_credit() tests' => sub {

    plan tests => 22;

    $schema->storage->txn_begin;

    # delete logs and statistics
    my $action_logs = $schema->resultset('ActionLog')->search()->count;
    my $statistics = $schema->resultset('Statistic')->search()->count;

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $account = Koha::Account->new( { patron_id => $patron->borrowernumber } );

    is( $account->balance, 0, 'Patron has no balance' );

    # Disable logs
    t::lib::Mocks::mock_preference( 'FinesLog', 0 );

    throws_ok {
        $account->add_credit(
            {
                amount      => 25,
                description => 'Payment of 25',
                library_id  => $patron->branchcode,
                note        => 'not really important',
                type        => 'PAYMENT',
                user_id     => $patron->id
            }
        );
    }
    'Koha::Exceptions::MissingParameter', 'Exception thrown if interface parameter missing';

    my $line_1 = $account->add_credit(
        {
            amount      => 25,
            description => 'Payment of 25',
            library_id  => $patron->branchcode,
            note        => 'not really important',
            type        => 'PAYMENT',
            user_id     => $patron->id,
            interface   => 'commandline'
        }
    );

    is( $account->balance, -25, 'Patron has a balance of -25' );
    is( $schema->resultset('ActionLog')->count(), $action_logs + 0, 'No log was added' );
    is( $schema->resultset('Statistic')->count(), $statistics + 1, 'Action added to statistics' );
    is( $line_1->credit_type_code, 'PAYMENT', 'Account type is correctly set' );
    ok( $line_1->amount < 0, 'Credit amount is stored as a negative' );

    # Enable logs
    t::lib::Mocks::mock_preference( 'FinesLog', 1 );

    my $line_2 = $account->add_credit(
        {   amount      => 37,
            description => 'Payment of 37',
            library_id  => $patron->branchcode,
            note        => 'not really important',
            user_id     => $patron->id,
            interface   => 'commandline'
        }
    );

    is( $account->balance, -62, 'Patron has a balance of -25' );
    is( $schema->resultset('ActionLog')->count(), $action_logs + 1, 'Log was added' );
    is( $schema->resultset('Statistic')->count(), $statistics + 2, 'Action added to statistics' );
    is( $line_2->credit_type_code, 'PAYMENT', 'Account type is correctly set' );
    ok( $line_1->amount < 0, 'Credit amount is stored as a negative' );

    # offsets have the credit_id set to accountlines_id, and debit_id is undef
    my $offset_1 = Koha::Account::Offsets->search({ credit_id => $line_1->id })->next;
    my $offset_2 = Koha::Account::Offsets->search({ credit_id => $line_2->id })->next;

    is( $offset_1->credit_id, $line_1->id, 'No debit_id is set for credits' );
    is( $offset_1->debit_id, undef, 'No debit_id is set for credits' );
    ok( $offset_1->amount > 0, 'Credit creation offset is a positive' );
    is( $offset_2->credit_id, $line_2->id, 'No debit_id is set for credits' );
    is( $offset_2->debit_id, undef, 'No debit_id is set for credits' );
    ok( $offset_2->amount > 0, 'Credit creation offset is a positive' );

    my $line_3 = $account->add_credit(
        {
            amount      => 20,
            description => 'Manual credit applied',
            library_id  => $patron->branchcode,
            user_id     => $patron->id,
            type        => 'FORGIVEN',
            interface   => 'commandline'
        }
    );

    is( $schema->resultset('ActionLog')->count(), $action_logs + 2, 'Log was added' );
    is( $schema->resultset('Statistic')->count(), $statistics + 2, 'No action added to statistics, because of credit type' );

    # Enable cash registers
    t::lib::Mocks::mock_preference( 'UseCashRegisters', 1 );
    throws_ok {
        $account->add_credit(
            {
                amount       => 20,
                description  => 'Cash payment without cash register',
                library_id   => $patron->branchcode,
                user_id      => $patron->id,
                payment_type => 'CASH',
                interface    => 'intranet'
            }
        );
    }
    'Koha::Exceptions::Account::RegisterRequired',
      'Exception thrown for UseCashRegisters:1 + payment_type:CASH + cash_register:undef';

    # Disable cash registers
    t::lib::Mocks::mock_preference( 'UseCashRegisters', 0 );

    my $item = $builder->build_sample_item;

    my $checkout = Koha::Checkout->new(
        {
            borrowernumber => $patron->id,
            itemnumber     => $item->id,
            date_due       => \'NOW()',
            branchcode     => $patron->branchcode,
            issuedate      => \'NOW()',
        }
    )->store();

    my $line_4 = $account->add_credit(
        {
            amount      => 20,
            description => 'Manual credit applied',
            library_id  => $patron->branchcode,
            user_id     => $patron->id,
            type        => 'FORGIVEN',
            interface   => 'commandline',
            issue_id    => $checkout->id
        }
    );

    is( $line_4->issue_id, $checkout->id, 'The issue ID matches the checkout ID' );

    $schema->storage->txn_rollback;
};

subtest 'add_debit() tests' => sub {

    plan tests => 14;

    $schema->storage->txn_begin;

    # delete logs and statistics
    my $action_logs = $schema->resultset('ActionLog')->search()->count;
    my $statistics  = $schema->resultset('Statistic')->search()->count;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $account =
      Koha::Account->new( { patron_id => $patron->borrowernumber } );

    is( $account->balance, 0, 'Patron has no balance' );

    throws_ok {
    $account->add_debit(
        {
            amount      => -5,
            description => 'amount validation failure',
            library_id  => $patron->branchcode,
            note        => 'this should fail anyway',
            type        => 'RENT',
            user_id     => $patron->id,
            interface   => 'commandline'
        }
    ); } 'Koha::Exceptions::Account::AmountNotPositive', 'Expected validation exception thrown (amount)';

    throws_ok {
        local *STDERR;
        open STDERR, '>', '/dev/null';
        $account->add_debit(
            {
                amount      => 5,
                description => 'type validation failure',
                library_id  => $patron->branchcode,
                note        => 'this should fail anyway',
                type        => 'failure',
                user_id     => $patron->id,
                interface   => 'commandline'
            }
        );
        close STDERR;
    }
    'Koha::Exceptions::Account::UnrecognisedType',
      'Expected validation exception thrown (type)';

    throws_ok {
    $account->add_debit(
        {
            amount      => 25,
            description => 'Rental charge of 25',
            library_id  => $patron->branchcode,
            note        => 'not really important',
            type        => 'RENT',
            user_id     => $patron->id
        }
    ); } 'Koha::Exceptions::MissingParameter', 'Exception thrown if interface parameter missing';

    # Disable logs
    t::lib::Mocks::mock_preference( 'FinesLog', 0 );

    my $line_1 = $account->add_debit(
        {
            amount      => 25,
            description => 'Rental charge of 25',
            library_id  => $patron->branchcode,
            note        => 'not really important',
            type        => 'RENT',
            user_id     => $patron->id,
            interface   => 'commandline'
        }
    );

    is( $account->balance, 25, 'Patron has a balance of 25' );
    is(
        $schema->resultset('ActionLog')->count(),
        $action_logs + 0,
        'No log was added'
    );
    is(
        $line_1->debit_type_code,
        'RENT',
        'Account type is correctly set'
    );

    # Enable logs
    t::lib::Mocks::mock_preference( 'FinesLog', 1 );

    my $line_2   = $account->add_debit(
        {
            amount      => 37,
            description => 'Rental charge of 37',
            library_id  => $patron->branchcode,
            note        => 'not really important',
            type        => 'RENT',
            user_id     => $patron->id,
            interface   => 'commandline'
        }
    );

    is( $account->balance, 62, 'Patron has a balance of 62' );
    is(
        $schema->resultset('ActionLog')->count(),
        $action_logs + 1,
        'Log was added'
    );
    is(
        $line_2->debit_type_code,
        'RENT',
        'Account type is correctly set'
    );

    # offsets have the debit_id set to accountlines_id, and credit_id is undef
    my $offset_1 =
      Koha::Account::Offsets->search( { debit_id => $line_1->id } )->next;
    my $offset_2 =
      Koha::Account::Offsets->search( { debit_id => $line_2->id } )->next;

    is( $offset_1->debit_id,  $line_1->id, 'debit_id is set for debit 1' );
    is( $offset_1->credit_id, undef,       'credit_id is not set for debit 1' );
    is( $offset_2->debit_id,  $line_2->id, 'debit_id is set for debit 2' );
    is( $offset_2->credit_id, undef,       'credit_id is not set for debit 2' );

    $schema->storage->txn_rollback;
};

subtest 'lines() tests' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $patron  = $builder->build_object({ class => 'Koha::Patrons' });
    my $account = $patron->account;

    # Add Credits
    $account->add_credit({ amount => 1, interface => 'commandline' });
    $account->add_credit({ amount => 2, interface => 'commandline' });
    $account->add_credit({ amount => 3, interface => 'commandline' });
    $account->add_credit({ amount => 4, interface => 'commandline' });

    # Add Debits
    $account->add_debit({ amount => 1, interface => 'commandline', type => 'OVERDUE' });
    $account->add_debit({ amount => 2, interface => 'commandline', type => 'OVERDUE' });
    $account->add_debit({ amount => 3, interface => 'commandline', type => 'OVERDUE' });
    $account->add_debit({ amount => 4, interface => 'commandline', type => 'OVERDUE' });

    # Paid Off
    $account->add_credit( { amount => 1, interface => 'commandline' } )
        ->apply( { debits => [ $account->outstanding_debits->as_list ] } );

    my $lines = $account->lines;
    is( $lines->_resultset->count, 9, "All accountlines (debits, credits and paid off) were fetched");

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
        $account->add_credit({ amount => 1, interface => 'commandline' });
        $account->add_credit({ amount => 2, interface => 'commandline' });
        $account->add_credit({ amount => 3, interface => 'commandline' });
        $account->add_credit({ amount => 4, interface => 'commandline' });
        $account->add_credit({ amount => 5, interface => 'commandline' });

        # Add Debits
        $account->add_debit({ amount => 1, interface => 'commandline', type => 'OVERDUE' });
        $account->add_debit({ amount => 2, interface => 'commandline', type => 'OVERDUE' });
        $account->add_debit({ amount => 3, interface => 'commandline', type => 'OVERDUE' });
        $account->add_debit({ amount => 4, interface => 'commandline', type => 'OVERDUE' });

        # Paid Off
        Koha::Account::Line->new(
            {
                borrowernumber    => $patron->id,
                amount            => 1,
                amountoutstanding => 0,
                interface         => 'commandline',
                debit_type_code   => 'OVERDUE'
            }
        )->store;
        Koha::Account::Line->new(
            {
                borrowernumber    => $patron->id,
                amount            => 1,
                amountoutstanding => 0,
                interface         => 'commandline',
                debit_type_code   => 'OVERDUE'
            }
        )->store;

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
        $account->add_credit({ amount => 1, interface => 'commandline' });
        $account->add_credit({ amount => 2, interface => 'commandline' });
        $account->add_credit({ amount => 3, interface => 'commandline' });
        $account->add_credit({ amount => 4, interface => 'commandline' });

        # Add Debits
        $account->add_debit({ amount => 1, interface => 'commandline', type => 'OVERDUE' });
        $account->add_debit({ amount => 2, interface => 'commandline', type => 'OVERDUE' });
        $account->add_debit({ amount => 3, interface => 'commandline', type => 'OVERDUE' });
        $account->add_debit({ amount => 4, interface => 'commandline', type => 'OVERDUE' });

        # Paid Off
        Koha::Account::Line->new(
            {
                borrowernumber    => $patron->id,
                amount            => 1,
                amountoutstanding => 0,
                interface         => 'commandline',
                debit_type_code   => 'OVERDUE'
            }
        )->store;
        Koha::Account::Line->new(
            {
                borrowernumber    => $patron->id,
                amount            => 1,
                amountoutstanding => 0,
                interface         => 'commandline',
                debit_type_code   => 'OVERDUE'
            }
        )->store;

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
        $account->add_credit({ amount => 1, interface => 'commandline' });
        $account->add_credit({ amount => 2, interface => 'commandline' });
        $account->add_credit({ amount => 3, interface => 'commandline' });
        $account->add_credit({ amount => 4, interface => 'commandline' });

        # Add Debits
        $account->add_debit({ amount => 1, interface => 'commandline', type => 'OVERDUE' });
        $account->add_debit({ amount => 2, interface => 'commandline', type => 'OVERDUE' });
        $account->add_debit({ amount => 3, interface => 'commandline', type => 'OVERDUE' });
        $account->add_debit({ amount => 4, interface => 'commandline', type => 'OVERDUE' });
        $account->add_debit({ amount => 5, interface => 'commandline', type => 'OVERDUE' });

        # Paid Off
        Koha::Account::Line->new(
            {
                borrowernumber    => $patron->id,
                amount            => 1,
                amountoutstanding => 0,
                interface         => 'commandline',
                debit_type_code   => 'OVERDUE'
            }
        )->store;
        Koha::Account::Line->new(
            {
                borrowernumber    => $patron->id,
                amount            => 1,
                amountoutstanding => 0,
                interface         => 'commandline',
                debit_type_code   => 'OVERDUE'
            }
        )->store;

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
        $account->add_credit({ amount => 1, interface => 'commandline' });
        $account->add_credit({ amount => 3, interface => 'commandline' });

        # Add Debits
        my $debit_1 = $account->add_debit({ amount => 1, interface => 'commandline', type => 'OVERDUE' });
        my $debit_2 = $account->add_debit({ amount => 2, interface => 'commandline', type => 'OVERDUE' });
        my $debit_3 = $account->add_debit({ amount => 3, interface => 'commandline', type => 'OVERDUE' });

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

subtest 'pay() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    # Disable renewing upon fine payment
    t::lib::Mocks::mock_preference( 'RenewAccruingItemWhenPaid', 0 );


    my $patron  = $builder->build_object({ class => 'Koha::Patrons' });
    my $library = $builder->build_object({ class => 'Koha::Libraries' });
    my $account = $patron->account;

    t::lib::Mocks::mock_preference( 'RequirePaymentType', 1 );
    throws_ok {
        $account->pay(
            {
                amount       => 5,
                interface    => 'intranet'
            }
        );
    }
    'Koha::Exceptions::Account::PaymentTypeRequired',
      'Exception thrown for RequirePaymentType:1 + payment_type:undef';

    t::lib::Mocks::mock_preference( 'RequirePaymentType', 0 );
    my $context = Test::MockModule->new('C4::Context');
    $context->mock( 'userenv', { branch => $library->id } );

    my $credit_1_id = $account->pay({ amount => 200 })->{payment_id};
    my $credit_1    = Koha::Account::Lines->find( $credit_1_id );

    is( $credit_1->branchcode, undef, 'No branchcode is set if library_id was not passed' );

    my $credit_2_id = $account->pay({ amount => 150, library_id => $library->id })->{payment_id};
    my $credit_2    = Koha::Account::Lines->find( $credit_2_id );

    is( $credit_2->branchcode, $library->id, 'branchcode set because library_id was passed' );
    # Enable cash registers
    t::lib::Mocks::mock_preference( 'UseCashRegisters', 1 );
    throws_ok {
        $account->pay(
            {
                amount       => 20,
                payment_type => 'CASH',
                interface    => 'intranet'
            }
        );
    }
    'Koha::Exceptions::Account::RegisterRequired',
      'Exception thrown for UseCashRegisters:1 + payment_type:CASH + cash_register:undef';

    # Disable cash registers
    t::lib::Mocks::mock_preference( 'UseCashRegisters', 0 );

    # Undef userenv
    $context->mock( 'userenv', undef );
    my $result = $account->pay(
        {
            amount => 20,
            payment_Type => 'CASH',
            interface => 'intranet'
        }
    );
    ok($result, "Koha::Account->pay functions without a userenv");
    my $payment = Koha::Account::Lines->find({accountlines_id => $result->{payment_id}});
    is($payment->manager_id, undef, "manager_id left undefined when no userenv found");

    subtest 'UseEmailReceipts tests' => sub {

        plan tests => 5;

        t::lib::Mocks::mock_preference( 'UseEmailReceipts', 1 );

        my %params;

        my $mocked_letters = Test::MockModule->new('C4::Letters');
        # we want to test the params
        $mocked_letters->mock( 'GetPreparedLetter', sub {
            %params = @_;
            return 1;
        });
        # we don't care about EnqueueLetter for now
        $mocked_letters->mock( 'EnqueueLetter', sub {
            return 1;
        });

        $schema->storage->txn_begin;

        my $patron  = $builder->build_object({ class => 'Koha::Patrons' });
        my $account = $patron->account;

        my $debit_1 = $account->add_debit( { amount => 5,  interface => 'commandline', type => 'OVERDUE' } );
        my $debit_2 = $account->add_debit( { amount => 10,  interface => 'commandline', type => 'OVERDUE' } );

        $account->pay({ amount => 6, lines => [ $debit_1, $debit_2 ] });
        my @offsets = @{$params{substitute}{offsets}};

        is( scalar @offsets, 2, 'Two offsets related to payment' );
        is( ref($offsets[0]), 'Koha::Account::Offset', 'Type is correct' );
        is( ref($offsets[1]), 'Koha::Account::Offset', 'Type is correct' );
        is( $offsets[0]->type, 'APPLY', 'Only APPLY offsets are passed to the notice' );
        is( $offsets[1]->type, 'APPLY', 'Only APPLY offsets are passed to the notice' );

        $schema->storage->txn_rollback;
    };

    $schema->storage->txn_rollback;
};

subtest 'pay() handles lost items when paying a specific lost fee' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $account = $patron->account;

    my $context = Test::MockModule->new('C4::Context');
    $context->mock( 'userenv', { branch => $library->id } );

    my $biblio = $builder->build_sample_biblio();
    my $item =
      $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );

    my $checkout = Koha::Checkout->new(
        {
            borrowernumber => $patron->id,
            itemnumber     => $item->id,
            date_due       => \'NOW()',
            branchcode     => $patron->branchcode,
            issuedate      => \'NOW()',
        }
    )->store();

    $item->itemlost('1')->store();

    my $accountline = Koha::Account::Line->new(
        {
            issue_id       => $checkout->id,
            borrowernumber => $patron->id,
            itemnumber     => $item->id,
            date           => \'NOW()',
            debit_type_code    => 'LOST',
            interface      => 'cli',
            amount => '1',
            amountoutstanding => '1',
        }
    )->store();

    $account->pay(
        {
            amount     => .5,
            library_id => $library->id,
            lines      => [$accountline],
        }
    );

    $accountline = Koha::Account::Lines->find( $accountline->id );
    is( $accountline->amountoutstanding+0, .5, 'Account line was paid down by half' );

    $checkout = Koha::Checkouts->find( $checkout->id );
    ok( $checkout, 'Item still checked out to patron' );

    $account->pay(
        {
            amount     => 0.5,
            library_id => $library->id,
            lines      => [$accountline],
        }
    );

    $accountline = Koha::Account::Lines->find( $accountline->id );
    is( $accountline->amountoutstanding+0, 0, 'Account line was paid down by half' );

    $checkout = Koha::Checkouts->find( $checkout->id );
    ok( !$checkout, 'Item was removed from patron account' );

    subtest 'item was not checked out to the same patron' => sub {
        plan tests => 1;

        my $patron_2 = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { branchcode => $library->branchcode }
            }
        );
        $item->itemlost('1')->store();
        C4::Accounts::chargelostitem( $patron->borrowernumber, $item->itemnumber, 5, "lost" );
        my $accountline = Koha::Account::Lines->search(
            {
                borrowernumber  => $patron->borrowernumber,
                itemnumber      => $item->itemnumber,
                debit_type_code => 'LOST'
            }
        )->next;
        my $checkout = Koha::Checkout->new(
            {
                borrowernumber => $patron_2->borrowernumber,
                itemnumber     => $item->itemnumber,
                date_due       => \'NOW()',
                branchcode     => $patron_2->branchcode,
                issuedate      => \'NOW()',
            }
        )->store();

        $patron->account->pay(
            {
                amount     => 5,
                library_id => $library->branchcode,
                lines      => [$accountline],
            }
        );

        ok(
            Koha::Checkouts->find( $checkout->issue_id ),
            'If the item is checked out to another patron, a lost item should not be returned if lost fee is paid'
        );

    };

    $schema->storage->txn_rollback;
};

subtest 'pay() handles lost items when paying by amount ( not specifying the lost fee )' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    # Enable AccountAutoReconcile
    t::lib::Mocks::mock_preference( 'AccountAutoReconcile', 1 );

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $account = $patron->account;

    my $context = Test::MockModule->new('C4::Context');
    $context->mock( 'userenv', { branch => $library->id } );

    my $biblio = $builder->build_sample_biblio();
    my $item =
      $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );

    my $checkout = Koha::Checkout->new(
        {
            borrowernumber => $patron->id,
            itemnumber     => $item->id,
            date_due       => \'NOW()',
            branchcode     => $patron->branchcode,
            issuedate      => \'NOW()',
        }
    )->store();

    $item->itemlost('1')->store();

    my $accountline = Koha::Account::Line->new(
        {
            issue_id       => $checkout->id,
            borrowernumber => $patron->id,
            itemnumber     => $item->id,
            date           => \'NOW()',
            debit_type_code    => 'LOST',
            interface      => 'cli',
            amount => '1',
            amountoutstanding => '1',
        }
    )->store();

    $account->pay(
        {
            amount     => .5,
            library_id => $library->id,
        }
    );

    $accountline = Koha::Account::Lines->find( $accountline->id );
    is( $accountline->amountoutstanding+0, .5, 'Account line was paid down by half' );

    $checkout = Koha::Checkouts->find( $checkout->id );
    ok( $checkout, 'Item still checked out to patron' );

    $account->pay(
        {
            amount     => .5,,
            library_id => $library->id,
        }
    );

    $accountline = Koha::Account::Lines->find( $accountline->id );
    is( $accountline->amountoutstanding+0, 0, 'Account line was paid down by half' );

    $checkout = Koha::Checkouts->find( $checkout->id );
    ok( !$checkout, 'Item was removed from patron account' );

    $schema->storage->txn_rollback;
};

subtest 'pay() renews items when appropriate' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $account = $patron->account;

    my $context = Test::MockModule->new('C4::Context');
    $context->mock( 'userenv', { branch => $library->id } );

    my $biblio = $builder->build_sample_biblio();
    my $item =
      $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );

    my $now = dt_from_string();
    my $seven_weeks = DateTime::Duration->new(weeks => 7);
    my $five_weeks = DateTime::Duration->new(weeks => 5);
    my $seven_weeks_ago = $now - $seven_weeks;
    my $five_weeks_ago = $now - $five_weeks;

    my $checkout = Koha::Checkout->new(
        {
            borrowernumber => $patron->id,
            itemnumber     => $item->id,
            date_due       => $five_weeks_ago,
            branchcode     => $patron->branchcode,
            issuedate      => $seven_weeks_ago
        }
    )->store();

    my $accountline = Koha::Account::Line->new(
        {
            issue_id       => $checkout->id,
            borrowernumber => $patron->id,
            itemnumber     => $item->id,
            date           => \'NOW()',
            debit_type_code => 'OVERDUE',
            status         => 'UNRETURNED',
            interface      => 'cli',
            amount => '1',
            amountoutstanding => '1',
        }
    )->store();

    # Enable renewing upon fine payment
    t::lib::Mocks::mock_preference( 'RenewAccruingItemWhenPaid', 1 );
    my $called = 0;
    my $module = Test::MockModule->new('C4::Circulation');
    $module->mock('AddRenewal', sub { $called = 1; });
    $module->mock('CanBookBeRenewed', sub { return 1; });
    my $result = $account->pay(
        {
            amount     => '1',
            library_id => $library->id,
        }
    );

    is( $called, 1, 'RenewAccruingItemWhenPaid causes C4::Circulation::AddRenew to be called when appropriate' );
    is(ref($result->{renew_result}), 'ARRAY', "Pay result contains 'renew_result' ARRAY" );
    is( scalar @{$result->{renew_result}}, 1, "renew_result contains one renewal result" );
    is( $result->{renew_result}->[0]->{itemnumber}, $item->id, "renew_result contains itemnumber of renewed item" );

    # Reset test by adding a new overdue
    Koha::Account::Line->new(
        {
            issue_id       => $checkout->id,
            borrowernumber => $patron->id,
            itemnumber     => $item->id,
            date           => \'NOW()',
            debit_type_code => 'OVERDUE',
            status         => 'UNRETURNED',
            interface      => 'cli',
            amount => '1',
            amountoutstanding => '1',
        }
    )->store();
    $called = 0;

    t::lib::Mocks::mock_preference( 'RenewAccruingItemWhenPaid', 0 );
    $result = $account->pay(
        {
            amount     => '1',
            library_id => $library->id,
        }
    );

    is( $called, 0, 'C4::Circulation::AddRenew NOT called when RenewAccruingItemWhenPaid disabled' );
    is(ref($result->{renew_result}), 'ARRAY', "Pay result contains 'renew_result' ARRAY" );
    is( scalar @{$result->{renew_result}}, 0, "renew_result contains no renewal results" );

    $schema->storage->txn_rollback;
};

subtest 'Koha::Account::Line::apply() handles lost items' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $account = $patron->account;

    my $context = Test::MockModule->new('C4::Context');
    $context->mock( 'userenv', { branch => $library->id } );

    my $biblio = $builder->build_sample_biblio();
    my $item =
      $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );

    my $checkout = Koha::Checkout->new(
        {
            borrowernumber => $patron->id,
            itemnumber     => $item->id,
            date_due       => \'NOW()',
            branchcode     => $patron->branchcode,
            issuedate      => \'NOW()',
        }
    )->store();

    $item->itemlost('1')->store();

    my $debit = Koha::Account::Line->new(
        {
            issue_id          => $checkout->id,
            borrowernumber    => $patron->id,
            itemnumber        => $item->id,
            date              => \'NOW()',
            debit_type_code       => 'LOST',
            interface         => 'cli',
            amount            => '1',
            amountoutstanding => '1',
        }
    )->store();

    my $credit = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            date              => '1970-01-01 00:00:01',
            amount            => -.5,
            amountoutstanding => -.5,
            interface         => 'commandline',
            credit_type_code  => 'PAYMENT'
        }
    )->store();
    my $debits = $account->outstanding_debits;
    $credit->apply({ debits => [ $debits->as_list ] });

    $debit = Koha::Account::Lines->find( $debit->id );
    is( $debit->amountoutstanding+0, .5, 'Account line was paid down by half' );

    $checkout = Koha::Checkouts->find( $checkout->id );
    ok( $checkout, 'Item still checked out to patron' );

    $credit = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            date              => '1970-01-01 00:00:01',
            amount            => -.5,
            amountoutstanding => -.5,
            interface         => 'commandline',
            credit_type_code  => 'PAYMENT'
        }
    )->store();
    $debits = $account->outstanding_debits;
    $credit->apply({ debits => [ $debits->as_list ] });

    $debit = Koha::Account::Lines->find( $debit->id );
    is( $debit->amountoutstanding+0, 0, 'Account line was paid down by half' );

    $checkout = Koha::Checkouts->find( $checkout->id );
    ok( !$checkout, 'Item was removed from patron account' );

    $schema->storage->txn_rollback;
};

subtest 'Koha::Account::pay() generates credit number (Koha::Account::Line->store)' => sub {
    plan tests => 38;

    $schema->storage->txn_begin;

    Koha::Account::Lines->delete();

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $account = $patron->account;

    #t::lib::Mocks::mock_userenv({ branchcode => $library->branchcode });
    my $context = Test::MockModule->new('C4::Context');
    $context->mock( 'userenv', { branch => $library->id } );

    my $now = dt_from_string;
    my $year = $now->year;
    my $month = $now->month;
    my ($accountlines_id, $accountline);

    my $credit_type = Koha::Account::CreditTypes->find('PAYMENT');
    $credit_type->credit_number_enabled(1);
    $credit_type->store();

    t::lib::Mocks::mock_preference('AutoCreditNumber', '');
    $accountlines_id = $account->pay({ amount => '1.00', library_id => $library->id })->{payment_id};
    $accountline = Koha::Account::Lines->find($accountlines_id);
    is($accountline->credit_number, undef, 'No credit number is generated when syspref is off');

    t::lib::Mocks::mock_preference('AutoCreditNumber', 'incremental');
    for my $i (1..11) {
        $accountlines_id = $account->pay({ amount => '1.00', library_id => $library->id })->{payment_id};
        $accountline = Koha::Account::Lines->find($accountlines_id);
        is($accountline->credit_number, $i, "Incremental format credit number added for payments: $i");
    }
    $accountlines_id = $account->pay({ type => 'WRITEOFF', amount => '1.00', library_id => $library->id })->{payment_id};
    $accountline = Koha::Account::Lines->find($accountlines_id);
    is($accountline->credit_number, undef, "Incremental credit number not added for writeoff");

    t::lib::Mocks::mock_preference('AutoCreditNumber', 'annual');
    for my $i (1..11) {
        $accountlines_id = $account->pay({ amount => '1.00', library_id => $library->id })->{payment_id};
        $accountline = Koha::Account::Lines->find($accountlines_id);
        is($accountline->credit_number, sprintf('%s-%04d', $year, $i), "Annual format credit number added for payments: " . sprintf('%s-%04d', $year, $i));
    }
    $accountlines_id = $account->pay({ type => 'WRITEOFF', amount => '1.00', library_id => $library->id })->{payment_id};
    $accountline = Koha::Account::Lines->find($accountlines_id);
    is($accountline->credit_number, undef, "Annual format credit number not aded for writeoff");

    t::lib::Mocks::mock_preference('AutoCreditNumber', 'branchyyyymmincr');
    for my $i (1..11) {
        $accountlines_id = $account->pay({ amount => '1.00', library_id => $library->id })->{payment_id};
        $accountline = Koha::Account::Lines->find($accountlines_id);
        is($accountline->credit_number, sprintf('%s%d%02d%04d', $library->id, $year, $month, $i), "branchyyyymmincr format credit number added for payment: " . sprintf('%s%d%02d%04d', $library->id, $year, $month, $i));
    }
    $accountlines_id = $account->pay({ type => 'WRITEOFF', amount => '1.00', library_id => $library->id })->{payment_id};
    $accountline = Koha::Account::Lines->find($accountlines_id);
    is($accountline->credit_number, undef, "branchyyyymmincr format credit number not added for writeoff");

    throws_ok {
        Koha::Account::Line->new(
            {
                interface        => 'test',
                amount           => -1,
                credit_type_code => $credit_type->code,
                credit_number    => 42
            }
        )->store;
    }
    'Koha::Exceptions::Account',
"Exception thrown when AutoCreditNumber is enabled but credit_number is already defined";

    $schema->storage->txn_rollback;
};

subtest 'Koha::Account::payout_amount() tests' => sub {
    plan tests => 39;

    $schema->storage->txn_begin;

    # delete logs and statistics
    my $action_logs = $schema->resultset('ActionLog')->search()->count;
    my $statistics  = $schema->resultset('Statistic')->search()->count;

    my $staff = $builder->build_object( { class => 'Koha::Patrons' } );
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $register =
      $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $account =
      Koha::Account->new( { patron_id => $patron->borrowernumber } );

    is( $account->balance, 0, 'Test patron has no balance' );

    my $payout_params = {
        payout_type => 'CASH',
        branch      => $library->id,
        register_id => $register->id,
        staff_id    => $staff->id,
        interface   => 'intranet',
        amount      => -10,
    };

    my @required_fields =
      ( 'interface', 'staff_id', 'branch', 'payout_type', 'amount' );
    for my $required_field (@required_fields) {
        my $this_payout = { %{$payout_params} };
        delete $this_payout->{$required_field};

        throws_ok {
            $account->payout_amount($this_payout);
        }
        'Koha::Exceptions::MissingParameter',
          "Exception thrown if $required_field parameter missing";
    }

    throws_ok {
        $account->payout_amount($payout_params);
    }
    'Koha::Exceptions::Account::AmountNotPositive',
      'Expected validation exception thrown (amount not positive)';

    $payout_params->{amount} = 10;
    throws_ok {
        $account->payout_amount($payout_params);
    }
    'Koha::Exceptions::ParameterTooHigh',
      'Expected validation exception thrown (amount greater than outstanding)';

    # Enable cash registers
    t::lib::Mocks::mock_preference( 'UseCashRegisters', 1 );
    throws_ok {
        $account->payout_amount($payout_params);
    }
    'Koha::Exceptions::Account::RegisterRequired',
'Exception thrown for UseCashRegisters:1 + payout_type:CASH + cash_register:undef';

    # Disable cash registers
    t::lib::Mocks::mock_preference( 'UseCashRegisters', 0 );

    # Add some outstanding credits
    my $credit_1 = $account->add_credit( { amount => 2,  interface => 'commandline' } );
    my $credit_2 = $account->add_credit( { amount => 3,  interface => 'commandline' } );
    my $credit_3 = $account->add_credit( { amount => 5,  interface => 'commandline' } );
    my $credit_4 = $account->add_credit( { amount => 10, interface => 'commandline' } );
    my $credits = $account->outstanding_credits();
    is( $credits->count, 4, "Found 4 credits with outstanding amounts" );
    is( $credits->total_outstanding + 0, -20, "Total -20 outstanding credit" );

    my $payout = $account->payout_amount($payout_params);
    is(ref($payout), 'Koha::Account::Line', 'Return the Koha::Account::Line object for the payout');
    is($payout->amount + 0, 10, "Payout amount recorded correctly");
    is($payout->amountoutstanding + 0, 0, "Full amount was paid out");
    $credits = $account->outstanding_credits();
    is($credits->count, 1, "Payout was applied against oldest outstanding credits first");
    is($credits->total_outstanding + 0, -10, "Total of 10 outstanding credit remaining");

    my $offsets = Koha::Account::Offsets->search( { debit_id => $payout->id } );
    is( $offsets->count, 4, 'Four offsets generated' );
    my $offset = $offsets->next;
    is( $offset->type, 'CREATE', 'CREATE offset added for payout line' );
    is( $offset->amount * 1, 10, 'Correct offset amount recorded' );
    $offset = $offsets->next;
    is( $offset->credit_id, $credit_1->id, "Offset added against credit_1");
    is( $offset->type,       'APPLY', "APPLY used for offset_type" );
    is( $offset->amount * 1, -2,      'Correct amount offset against credit_1' );
    $offset = $offsets->next;
    is( $offset->credit_id, $credit_2->id, "Offset added against credit_2");
    is( $offset->type,       'APPLY', "APPLY used for offset_type" );
    is( $offset->amount * 1, -3,      'Correct amount offset against credit_2' );
    $offset = $offsets->next;
    is( $offset->credit_id, $credit_3->id, "Offset added against credit_3");
    is( $offset->type,       'APPLY', "APPLY used for offset_type" );
    is( $offset->amount * 1, -5,      'Correct amount offset against credit_3' );

    my $credit_5 = $account->add_credit( { amount => 5, interface => 'commandline' } );
    $credits = $account->outstanding_credits();
    is($credits->count, 2, "New credit added");
    $payout_params->{amount} = 2.50;
    $payout_params->{credits} = [$credit_5];
    $payout = $account->payout_amount($payout_params);

    $credits = $account->outstanding_credits();
    is($credits->count, 2, "Second credit not fully paid off");
    is($credits->total_outstanding + 0, -12.50, "12.50 outstanding credit remaining");
    $credit_4->discard_changes;
    $credit_5->discard_changes;
    is($credit_4->amountoutstanding + 0, -10, "Credit 4 unaffected when credit_5 was passed to payout_amount");
    is($credit_5->amountoutstanding + 0, -2.50, "Credit 5 correctly reduced when payout_amount called with credit_5 passed");

    $offsets = Koha::Account::Offsets->search( { debit_id => $payout->id } );
    is( $offsets->count, 2, 'Two offsets generated' );
    $offset = $offsets->next;
    is( $offset->type, 'CREATE', 'CREATE offset added for payout line' );
    is( $offset->amount * 1, 2.50, 'Correct offset amount recorded' );
    $offset = $offsets->next;
    is( $offset->credit_id, $credit_5->id, "Offset added against credit_5");
    is( $offset->type,       'APPLY', "APPLY used for offset_type" );
    is( $offset->amount * 1, -2.50,      'Correct amount offset against credit_5' );

    $schema->storage->txn_rollback;
};

subtest 'Koha::Account::payin_amount() tests' => sub {
    plan tests => 36;

    $schema->storage->txn_begin;

    # delete logs and statistics
    my $action_logs = $schema->resultset('ActionLog')->search()->count;
    my $statistics  = $schema->resultset('Statistic')->search()->count;

    my $staff = $builder->build_object( { class => 'Koha::Patrons' } );
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $register =
      $builder->build_object( { class => 'Koha::Cash::Registers' } );
    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $account =
      Koha::Account->new( { patron_id => $patron->borrowernumber } );

    is( $account->balance, 0, 'Test patron has no balance' );

    my $payin_params = {
        type  => 'PAYMENT',
        payment_type => 'CASH',
        branch       => $library->id,
        register_id  => $register->id,
        staff_id     => $staff->id,
        interface    => 'intranet',
        amount       => -10,
    };

    my @required_fields =
      ( 'interface', 'amount', 'type' );
    for my $required_field (@required_fields) {
        my $this_payin = { %{$payin_params} };
        delete $this_payin->{$required_field};

        throws_ok {
            $account->payin_amount($this_payin);
        }
        'Koha::Exceptions::MissingParameter',
          "Exception thrown if $required_field parameter missing";
    }

    throws_ok {
        $account->payin_amount($payin_params);
    }
    'Koha::Exceptions::Account::AmountNotPositive',
      'Expected validation exception thrown (amount not positive)';

    $payin_params->{amount} = 10;

    # Enable cash registers
    t::lib::Mocks::mock_preference( 'UseCashRegisters', 1 );
    throws_ok {
        $account->payin_amount($payin_params);
    }
    'Koha::Exceptions::Account::RegisterRequired',
'Exception thrown for UseCashRegisters:1 + payment_type:CASH + cash_register:undef';

    # Disable cash registers
    t::lib::Mocks::mock_preference( 'UseCashRegisters', 0 );

    # Enable AccountAutoReconcile
    t::lib::Mocks::mock_preference( 'AccountAutoReconcile', 1 );

    # Add some outstanding debits
    my $debit_1 = $account->add_debit( { amount => 2,  interface => 'commandline', type => 'OVERDUE' } );
    my $debit_2 = $account->add_debit( { amount => 3,  interface => 'commandline', type => 'OVERDUE' } );
    my $debit_3 = $account->add_debit( { amount => 5,  interface => 'commandline', type => 'OVERDUE' } );
    my $debit_4 = $account->add_debit( { amount => 10, interface => 'commandline', type => 'OVERDUE' } );
    my $debits = $account->outstanding_debits();
    is( $debits->count, 4, "Found 4 debits with outstanding amounts" );
    is( $debits->total_outstanding + 0, 20, "Total 20 outstanding debit" );

    my $payin = $account->payin_amount($payin_params);
    is(ref($payin), 'Koha::Account::Line', 'Return the Koha::Account::Line object for the payin');
    is($payin->amount + 0, -10, "Payin amount recorded correctly");
    is($payin->amountoutstanding + 0, 0, "Full amount was used to pay debts");
    $debits = $account->outstanding_debits();
    is($debits->count, 1, "Payin was applied against oldest outstanding debits first");
    is($debits->total_outstanding + 0, 10, "Total of 10 outstanding debit remaining");

    my $offsets = Koha::Account::Offsets->search( { credit_id => $payin->id } );
    is( $offsets->count, 4, 'Four offsets generated' );
    my $offset = $offsets->next;
    is( $offset->type, 'CREATE', 'CREATE offset added for payin line' );
    is( $offset->amount * 1, 10, 'Correct offset amount recorded' );
    $offset = $offsets->next;
    is( $offset->debit_id, $debit_1->id, "Offset added against debit_1");
    is( $offset->type,       'APPLY', "APPLY used for offset_type" );
    is( $offset->amount * 1, -2,      'Correct amount offset against debit_1' );
    $offset = $offsets->next;
    is( $offset->debit_id, $debit_2->id, "Offset added against debit_2");
    is( $offset->type,       'APPLY', "APPLY used for offset_type" );
    is( $offset->amount * 1, -3,      'Correct amount offset against debit_2' );
    $offset = $offsets->next;
    is( $offset->debit_id, $debit_3->id, "Offset added against debit_3");
    is( $offset->type,       'APPLY', "APPLY used for offset_type" );
    is( $offset->amount * 1, -5,      'Correct amount offset against debit_3' );

    my $debit_5 = $account->add_debit( { amount => 5, interface => 'commandline', type => 'OVERDUE' } );
    $debits = $account->outstanding_debits();
    is($debits->count, 2, "New debit added");
    $payin_params->{amount} = 2.50;
    $payin_params->{debits} = [$debit_5];
    $payin = $account->payin_amount($payin_params);

    $debits = $account->outstanding_debits();
    is($debits->count, 2, "Second debit not fully paid off");
    is($debits->total_outstanding + 0, 12.50, "12.50 outstanding debit remaining");
    $debit_4->discard_changes;
    $debit_5->discard_changes;
    is($debit_4->amountoutstanding + 0, 10, "Debit 4 unaffected when debit_5 was passed to payin_amount");
    is($debit_5->amountoutstanding + 0, 2.50, "Debit 5 correctly reduced when payin_amount called with debit_5 passed");

    $offsets = Koha::Account::Offsets->search( { credit_id => $payin->id } );
    is( $offsets->count, 2, 'Two offsets generated' );
    $offset = $offsets->next;
    is( $offset->type, 'CREATE', 'CREATE offset added for payin line' );
    is( $offset->amount * 1, 2.50, 'Correct offset amount recorded' );
    $offset = $offsets->next;
    is( $offset->debit_id, $debit_5->id, "Offset added against debit_5");
    is( $offset->type,       'APPLY', "APPLY used for offset_type" );
    is( $offset->amount * 1, -2.50,      'Correct amount offset against debit_5' );

    $schema->storage->txn_rollback;
};
