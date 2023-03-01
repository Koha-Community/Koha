#!/usr/bin/perl

# Copyright 2015 BibLibre
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 27;
use Test::MockModule;
use Test::Exception;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Account;
use Koha::Account::DebitTypes;
use Koha::Account::Lines;
use Koha::Account::Offsets;
use Koha::Notice::Messages;
use Koha::Notice::Templates;
use Koha::DateUtils qw( dt_from_string );

use C4::Circulation qw( MarkIssueReturned );

BEGIN {
    use_ok('C4::Accounts', qw( chargelostitem purge_zero_balance_fees ));
    use_ok('Koha::Object');
    use_ok('Koha::Patron');
    use_ok('Data::Dumper');
}

can_ok( 'C4::Accounts',
    qw(
        chargelostitem
        purge_zero_balance_fees )
);

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

my $builder = t::lib::TestBuilder->new;
my $library = $builder->build( { source => 'Branch' } );

my $branchcode = $library->{branchcode};

my $context = Test::MockModule->new('C4::Context');
$context->mock( 'userenv', sub {
    return {
        flags  => 1,
        id     => 'my_userid',
        branch => $branchcode,
    };
});
$context->mock( 'interface', sub { return "commandline" } );
my $userenv_branchcode = $branchcode;

# Testing purge_zero_balance_fees

# The 3rd value in the insert is 'days ago' --
# 0 => today
# 1 => yesterday
# etc.

my $sth = $dbh->prepare(
    "INSERT INTO accountlines (
         borrowernumber,
         amountoutstanding,
         date,
         description,
         interface,
         credit_type_code,
         debit_type_code
     )
     VALUES ( ?, ?, (select date_sub(CURRENT_DATE, INTERVAL ? DAY) ), ?, ?, ?, ? )"
);

my $days = 5;

my @test_data = (
    { amount => 0     , days_ago => 0         , description =>'purge_zero_balance_fees should not delete 0 balance fees with date today'                     , delete => 0, credit_type => undef, debit_type => 'OVERDUE' } ,
    { amount => 0     , days_ago => $days - 1 , description =>'purge_zero_balance_fees should not delete 0 balance fees with date before threshold day'      , delete => 0, credit_type => undef, debit_type => 'OVERDUE' } ,
    { amount => 0     , days_ago => $days     , description =>'purge_zero_balance_fees should not delete 0 balance fees with date on threshold day'          , delete => 0, credit_type => undef, debit_type => 'OVERDUE' } ,
    { amount => 0     , days_ago => $days + 1 , description =>'purge_zero_balance_fees should delete 0 balance fees with date after threshold day'           , delete => 1, credit_type => undef, debit_type => 'OVERDUE' } ,
    { amount => undef , days_ago => $days + 1 , description =>'purge_zero_balance_fees should delete NULL balance fees with date after threshold day'        , delete => 1, credit_type => undef, debit_type => 'OVERDUE' } ,
    { amount => 5     , days_ago => $days - 1 , description =>'purge_zero_balance_fees should not delete fees with positive amout owed before threshold day' , delete => 0, credit_type => undef, debit_type => 'OVERDUE' } ,
    { amount => 5     , days_ago => $days     , description =>'purge_zero_balance_fees should not delete fees with positive amout owed on threshold day'     , delete => 0, credit_type => undef, debit_type => 'OVERDUE' } ,
    { amount => 5     , days_ago => $days + 1 , description =>'purge_zero_balance_fees should not delete fees with positive amout owed after threshold day'  , delete => 0, credit_type => undef, debit_type => 'OVERDUE' } ,
    { amount => -5    , days_ago => $days - 1 , description =>'purge_zero_balance_fees should not delete fees with negative amout owed before threshold day' , delete => 0, credit_type => 'PAYMENT', debit_type => undef } ,
    { amount => -5    , days_ago => $days     , description =>'purge_zero_balance_fees should not delete fees with negative amout owed on threshold day'     , delete => 0, credit_type => 'PAYMENT', debit_type => undef } ,
    { amount => -5    , days_ago => $days + 1 , description =>'purge_zero_balance_fees should not delete fees with negative amout owed after threshold day'  , delete => 0, credit_type => 'PAYMENT', debit_type => undef }
);
my $categorycode = $builder->build({ source => 'Category' })->{categorycode};
my $borrower = Koha::Patron->new( { firstname => 'Test', surname => 'Patron', categorycode => $categorycode, branchcode => $branchcode } )->store();

for my $data ( @test_data ) {
    $sth->execute(
        $borrower->borrowernumber,
        $data->{amount},
        $data->{days_ago},
        $data->{description},
        'commandline',
        $data->{credit_type},
        $data->{debit_type}
    );
}

purge_zero_balance_fees( $days );

$sth = $dbh->prepare(
            "select count(*) = 0 as deleted
             from accountlines
             where description = ?"
       );

#
sub is_delete_correct {
    my $should_delete = shift;
    my $description = shift;
    $sth->execute( $description );
    my $test = $sth->fetchrow_hashref();
    is( $test->{deleted}, $should_delete, $description )
}

for my $data  (@test_data) {
    is_delete_correct( $data->{delete}, $data->{description});
}

$dbh->do(q|DELETE FROM accountlines|);

subtest "Koha::Account::pay - always AutoReconcile + notes tests" => sub {

    plan tests => 17;

    # Create a borrower
    my $categorycode = $builder->build({ source => 'Category' })->{ categorycode };
    my $branchcode   = $builder->build({ source => 'Branch' })->{ branchcode };

    my $borrower = Koha::Patron->new( {
        cardnumber => '1234567890',
        surname => 'McFly',
        firstname => 'Marty',
    } );
    $borrower->categorycode( $categorycode );
    $borrower->branchcode( $branchcode );
    $borrower->store;

    my $account = Koha::Account->new({ patron_id => $borrower->id });

    my $line1 = $account->add_debit({ type => 'ACCOUNT', amount => 100, interface => 'commandline' });
    my $line2 = $account->add_debit({ type => 'ACCOUNT', amount => 200, interface => 'commandline' });

    $sth = $dbh->prepare("SELECT count(*) FROM accountlines");
    $sth->execute;
    my $count = $sth->fetchrow_array;
    is($count, 2, 'There is 2 lines as expected');

    # There is $100 in the account
    $sth = $dbh->prepare("SELECT amountoutstanding FROM accountlines WHERE borrowernumber=?");
    my $outstanding_debt = $account->outstanding_debits->total_outstanding;
    is($outstanding_debt, 300, 'The account has $300 outstanding debt as expected' );
    my $outstanding_credit = $account->outstanding_credits->total_outstanding;
    is($outstanding_credit, 0, 'The account has $0 outstanding credit as expected' );

    # We make a $20 payment
    my $borrowernumber = $borrower->borrowernumber;
    my $data = '20.00';
    my $payment_note = '$20.00 payment note';
    my $id = $account->pay( { amount => $data, note => $payment_note, payment_type => "TEST_TYPE" } )->{payment_id};

    my $accountline = Koha::Account::Lines->find( $id );
    is( $accountline->payment_type, "TEST_TYPE", "Payment type passed into pay is set in account line correctly" );

    # There is now $280 in the account
    $outstanding_debt = $account->outstanding_debits->total_outstanding;
    is($outstanding_debt, 280, 'The account has $280 outstanding debt as expected' );
    $outstanding_credit = $account->outstanding_credits->total_outstanding;
    is($outstanding_credit, 0, 'The account has $0 outstanding credit as expected' );

    # Is the payment note well registered
    is($accountline->note,'$20.00 payment note', '$20.00 payment note is registered');

    # We attempt to make a -$30 payment (a NEGATIVE payment)
    $data = '-30.00';
    $payment_note = '-$30.00 payment note';
    throws_ok { $account->pay( { amount => $data, note => $payment_note } ) }
    'Koha::Exceptions::Account::AmountNotPositive',
      'Croaked on call to pay with negative amount';

    #We make a $150 payment ( > 1stLine )
    $data = '150.00';
    $payment_note = '$150.00 payment note';
    $id = $account->pay( { amount => $data, note => $payment_note } )->{payment_id};

    # There is now $130 in the account
    $outstanding_debt = $account->outstanding_debits->total_outstanding;
    is($outstanding_debt, 130, 'The account has $130 outstanding debt as expected' );
    $outstanding_credit = $account->outstanding_credits->total_outstanding;
    is($outstanding_credit, 0, 'The account has $0 outstanding credit as expected' );

    # Is the payment note well registered
    $accountline = Koha::Account::Lines->find( $id );
    is($accountline->note,'$150.00 payment note', '$150.00 payment note is registered');

    #We make a $200 payment ( > amountleft )
    $data = '200.00';
    $payment_note = '$200.00 payment note';
    $id = $account->pay( { amount => $data, note => $payment_note } )->{payment_id};

    # There is now -$70 in the account
    $outstanding_debt = $account->outstanding_debits->total_outstanding;
    is($outstanding_debt, 0, 'The account has $0 outstanding debt as expected' );
    $outstanding_credit = $account->outstanding_credits->total_outstanding;
    is($outstanding_credit, -70, 'The account has -$70 outstanding credit as expected' );

    # Is the payment note well registered
    $accountline = Koha::Account::Lines->find( $id );
    is($accountline->note,'$200.00 payment note', '$200.00 payment note is registered');

    my $line3 = $account->add_debit({ type => 'ACCOUNT', amount => 42, interface => 'commandline' });
    $id = $account->pay( { lines => [$line3], amount => 42 } )->{payment_id};
    $accountline = Koha::Account::Lines->find( $id );
    is( $accountline->amount()+0, -42, "Payment paid the specified fine" );
    $line3 = Koha::Account::Lines->find( $line3->id );
    is( $line3->amountoutstanding+0, 0, "Specified fine is paid" );
    is( $accountline->branchcode, undef, 'branchcode passed, then undef' );
};

subtest "Koha::Account::pay particular line tests" => sub {

    plan tests => 5;

    # Create a borrower
    my $categorycode = $builder->build({ source => 'Category' })->{ categorycode };
    my $branchcode   = $builder->build({ source => 'Branch' })->{ branchcode };

    my $borrower = Koha::Patron->new( {
        cardnumber => 'kylemhall',
        surname => 'Hall',
        firstname => 'Kyle',
    } );
    $borrower->categorycode( $categorycode );
    $borrower->branchcode( $branchcode );
    $borrower->store;

    my $account = Koha::Account->new({ patron_id => $borrower->id });

    my $line1 = $account->add_debit({ type => 'ACCOUNT', amount => 1, interface => 'commandline' });
    my $line2 = $account->add_debit({ type => 'ACCOUNT', amount => 2, interface => 'commandline' });
    my $line3 = $account->add_debit({ type => 'ACCOUNT', amount => 3, interface => 'commandline' });
    my $line4 = $account->add_debit({ type => 'ACCOUNT', amount => 4, interface => 'commandline' });

    is( $account->balance(), 10, "Account balance is 10" );

    $account->pay(
        {
            lines => [$line2, $line3, $line4],
            amount => 4,
        }
    );

    $_->_result->discard_changes foreach ( $line1, $line2, $line3, $line4 );

    # Line1 is not paid at all, as it was not passed in the lines param
    is( $line1->amountoutstanding+0, 1, "Line 1 was not paid" );
    # Line2 was paid in full, as it was the first in the lines list
    is( $line2->amountoutstanding+0, 0, "Line 2 was paid in full" );
    # Line3 was paid partially, as the remaining balance did not cover it entirely
    is( $line3->amountoutstanding+0, 1, "Line 3 was paid to 1.00" );
    # Line4 was not paid at all, as the payment was all used up by that point
    is( $line4->amountoutstanding+0, 4, "Line 4 was not paid" );
};

subtest "Koha::Account::pay writeoff tests" => sub {

    plan tests => 5;

    # Create a borrower
    my $categorycode = $builder->build({ source => 'Category' })->{ categorycode };
    my $branchcode   = $builder->build({ source => 'Branch' })->{ branchcode };

    my $borrower = Koha::Patron->new( {
        cardnumber => 'chelseahall',
        surname => 'Hall',
        firstname => 'Chelsea',
    } );
    $borrower->categorycode( $categorycode );
    $borrower->branchcode( $branchcode );
    $borrower->store;

    my $account = Koha::Account->new({ patron_id => $borrower->id });

    my $line = $account->add_debit({ type => 'ACCOUNT', amount => 42, interface => 'commandline' });

    is( $account->balance(), 42, "Account balance is 42" );

    my $id = $account->pay(
        {
            lines  => [$line],
            amount => 42,
            type   => 'WRITEOFF',
        }
    )->{payment_id};

    $line->_result->discard_changes();

    is( $line->amountoutstanding+0, 0, "Line was written off" );

    my $writeoff = Koha::Account::Lines->find( $id );

    is( $writeoff->credit_type_code, 'WRITEOFF', 'Type is correct for WRITEOFF' );
    is( $writeoff->description, '', 'Description is correct' );
    is( $writeoff->amount+0, -42, 'Amount is correct' );
};

subtest "More Koha::Account::pay tests" => sub {

    plan tests => 12;

    # Create a borrower
    my $category   = $builder->build({ source => 'Category' })->{ categorycode };
    my $branch     = $builder->build({ source => 'Branch' })->{ branchcode };
    $branchcode = $branch;
    my $borrowernumber = $builder->build({
        source => 'Borrower',
        value  => { categorycode => $category,
                    branchcode   => $branch }
    })->{ borrowernumber };

    my $amount = 100;
    my $accountline = $builder->build(
        {
            source => 'Accountline',
            value  => {
                borrowernumber    => $borrowernumber,
                amount            => $amount,
                amountoutstanding => $amount,
                credit_type_code  => undef,
            }
        }
    );

    my $rs = $schema->resultset('Accountline')->search({
        borrowernumber => $borrowernumber
    });

    is( $rs->count(), 1, 'Accountline created' );

    my $account = Koha::Account->new( { patron_id => $borrowernumber } );
    my $line = Koha::Account::Lines->find( $accountline->{ accountlines_id } );
    # make the full payment
    my $payment = $account->pay(
        {
            lines      => [$line],
            amount     => $amount,
            library_id => $branch,
            note       => 'A payment note'
        }
    );

    my $offsets = Koha::Account::Offsets->search({ credit_id => $payment->{payment_id} });
    is( $offsets->count, 2, 'Two offsets recorded');
    my $offset = $offsets->next;
    is( $offset->type(), 'CREATE', 'First offset type is CREATE' );
    is( $offset->amount+0, 100, 'First offset amount is 100.00' );
    $offset = $offsets->next;
    is( $offset->type(), 'APPLY', 'Second offset type is APPLY' );
    is( $offset->amount+0, -100, 'Second offset amount is -100.00' );
    is( $offset->debit_id, $accountline->{accountlines_id}, 'Second offset is against the right accountline');

    my $stat = $schema->resultset('Statistic')->search({
        branch  => $branch,
        type    => 'PAYMENT'
    }, { order_by => { -desc => 'datetime' } })->next();

    ok( defined $stat, "There's a payment log that matches the branch" );

    SKIP: {
        skip "No statistic logged", 4 unless defined $stat;

        is( $stat->type, 'payment', "Correct statistic type" );
        is( $stat->branch, $branch, "Correct branch logged to statistics" );
        is( $stat->borrowernumber, $borrowernumber, "Correct borrowernumber logged to statistics" );
        is( $stat->value+0, -$amount, "Correct amount logged to statistics" );
    }
};

subtest "Even more Koha::Account::pay tests" => sub {

    plan tests => 12;

    # Create a borrower
    my $category   = $builder->build({ source => 'Category' })->{ categorycode };
    my $branch     = $builder->build({ source => 'Branch' })->{ branchcode };
    $branchcode = $branch;
    my $borrowernumber = $builder->build({
        source => 'Borrower',
        value  => { categorycode => $category,
                    branchcode   => $branch }
    })->{ borrowernumber };

    my $amount = 100;
    my $partialamount = 60;
    my $accountline = $builder->build(
        {
            source => 'Accountline',
            value  => {
                borrowernumber    => $borrowernumber,
                amount            => $amount,
                amountoutstanding => $amount,
                credit_type_code  => undef,
            }
        }
    );

    my $rs = $schema->resultset('Accountline')->search({
        borrowernumber => $borrowernumber
    });

    is( $rs->count(), 1, 'Accountline created' );

    my $account = Koha::Account->new( { patron_id => $borrowernumber } );
    my $line = Koha::Account::Lines->find( $accountline->{ accountlines_id } );
    # make the full payment
    my $payment = $account->pay(
        {
            lines      => [$line],
            amount     => $partialamount,
            library_id => $branch,
            note       => 'A payment note'
        }
    );

    my $offsets = Koha::Account::Offsets->search({ credit_id => $payment->{payment_id} });
    is( $offsets->count, 2, 'Two offsets recorded');
    my $offset = $offsets->next;
    is( $offset->type(), 'CREATE', 'First offset type is CREATE' );
    is( $offset->amount+0, 60, 'First offset amount is 60.00' );
    $offset = $offsets->next;
    is( $offset->type(), 'APPLY', 'Second offset type is APPLY' );
    is( $offset->amount+0, -60, 'Second offset amount is -60.00' );
    is( $offset->debit_id, $accountline->{accountlines_id}, 'Second offset is against the right accountline');

    my $stat = $schema->resultset('Statistic')->search({
        branch  => $branch,
        type    => 'PAYMENT'
    }, { order_by => { -desc => 'datetime' } })->next();

    ok( defined $stat, "There's a payment log that matches the branch" );

    SKIP: {
        skip "No statistic logged", 4 unless defined $stat;

        is( $stat->type, 'payment', "Correct statistic type" );
        is( $stat->branch, $branch, "Correct branch logged to statistics" );
        is( $stat->borrowernumber, $borrowernumber, "Correct borrowernumber logged to statistics" );
        is( $stat->value+0, -$partialamount, "Correct amount logged to statistics" );
    }
};

subtest 'balance' => sub {
    plan tests => 2;

    my $patron = $builder->build({source => 'Borrower'});
    $patron = Koha::Patrons->find( $patron->{borrowernumber} );
    my $account = $patron->account;
    is( $account->balance, 0, 'balance should return 0 if the patron does not have fines' );

    my $accountline_1 = $builder->build(
        {
            source => 'Accountline',
            value  => {
                borrowernumber    => $patron->borrowernumber,
                amount            => 42,
                amountoutstanding => 42,
                credit_type_code  => undef,
            }
        }
    );
    my $accountline_2 = $builder->build(
        {
            source => 'Accountline',
            value  => {
                borrowernumber    => $patron->borrowernumber,
                amount            => -13,
                amountoutstanding => -13,
                debit_type_code   => undef,
            }
        }
    );

    my $balance = $patron->account->balance;
    is( int($balance), 29, 'balance should return the correct value');

    $patron->delete;
};

subtest "C4::Accounts::chargelostitem tests" => sub {
    plan tests => 3;

    my $branch = $builder->build( { source => 'Branch' } );
    my $branchcode = $branch->{branchcode};

    my $staff = $builder->build( { source => 'Borrower' } );
    my $staff_id = $staff->{borrowernumber};

    my $module = Test::MockModule->new('C4::Context');
    $module->mock(
        'userenv',
        sub {
            return {
                flags  => 1,
                number => $staff_id,
                branch => $branchcode,
            };
        }
    );

    my $itype_no_replace_no_fee = $builder->build({ source => 'Itemtype', value => {
            rentalcharge => 0,
            defaultreplacecost => undef,
            processfee => undef,
    }});
    my $itype_replace_no_fee = $builder->build({ source => 'Itemtype', value => {
            rentalcharge => 0,
            defaultreplacecost => 16.32,
            processfee => undef,
    }});
    my $itype_no_replace_fee = $builder->build({ source => 'Itemtype', value => {
            rentalcharge => 0,
            defaultreplacecost => undef,
            processfee => 8.16,
    }});
    my $itype_replace_fee = $builder->build({ source => 'Itemtype', value => {
            rentalcharge => 0,
            defaultreplacecost => 4.08,
            processfee => 2.04,
    }});
    my $cli_borrowernumber = $builder->build({ source => 'Borrower' })->{'borrowernumber'};
    my $cli_itemnumber1 = $builder->build_sample_item({ itype => $itype_no_replace_no_fee->{itemtype} })->itemnumber;
    my $cli_itemnumber2 = $builder->build_sample_item({ itype => $itype_replace_no_fee->{itemtype} })->itemnumber;
    my $cli_itemnumber3 = $builder->build_sample_item({ itype => $itype_no_replace_fee->{itemtype} })->itemnumber;
    my $cli_itemnumber4 = $builder->build_sample_item({ itype => $itype_replace_fee->{itemtype} })->itemnumber;
    my $cli_itemnumber5 = $builder->build_sample_item({ itype => $itype_replace_fee->{itemtype} })->itemnumber;
    my $cli_bundle1     = $builder->build_sample_item({ itype => $itype_no_replace_no_fee->{itemtype} })->itemnumber;
    $schema->resultset('ItemBundle')->create( { host => $cli_bundle1, item => $cli_itemnumber5 } );

    my $cli_issue_id_1 = $builder->build({ source => 'Issue', value => { borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber1 } })->{issue_id};
    my $cli_issue_id_2 = $builder->build({ source => 'Issue', value => { borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber2 } })->{issue_id};
    my $cli_issue_id_3 = $builder->build({ source => 'Issue', value => { borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber3 } })->{issue_id};
    my $cli_issue_id_4 = $builder->build({ source => 'Issue', value => { borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4 } })->{issue_id};
    my $cli_issue_id_4X = undef;
    my $cli_bundle_issue = $builder->build({ source => 'Issue', value => { borrowernumber => $cli_borrowernumber, itemnumber => $cli_bundle1 } })->{issue_id};

    my $lostfine;
    my $procfee;

    subtest "fee application tests" => sub {
        plan tests => 48;

        t::lib::Mocks::mock_preference('item-level_itypes', '1');
        t::lib::Mocks::mock_preference('useDefaultReplacementCost', '0');

        C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber1, 0, "Perdedor");
        $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber1, debit_type_code => 'LOST' });
        $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber1, debit_type_code => 'PROCESSING' });
        ok( !$lostfine, "No lost fine if no replacementcost or default when pref off");
        ok( !$procfee,  "No processing fee if no processing fee");
        C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber1, 6.12, "Perdedor");
        $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber1, debit_type_code => 'LOST' });
        $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber1, debit_type_code => 'PROCESSING' });
        ok( $lostfine->amount == 6.12, "Lost fine equals replacementcost when pref off and no default set");
        ok( !$procfee,  "No processing fee if no processing fee");
        $lostfine->delete();

        C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber2, 0, "Perdedor");
        $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber2, debit_type_code => 'LOST' });
        $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber2, debit_type_code => 'PROCESSING' });
        ok( !$lostfine, "No lost fine if no replacementcost but default set when pref off");
        ok( !$procfee,  "No processing fee if no processing fee");
        C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber2, 6.12, "Perdedor");
        $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber2, debit_type_code => 'LOST' });
        $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber2, debit_type_code => 'PROCESSING' });
        ok( $lostfine->amount == 6.12 , "Lost fine equals replacementcost when pref off and default set");
        ok( !$procfee,  "No processing fee if no processing fee");
        $lostfine->delete();

        C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber3, 0, "Perdedor");
        $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber3, debit_type_code => 'LOST' });
        $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber3, debit_type_code => 'PROCESSING' });
        ok( !$lostfine, "No lost fine if no replacementcost and no default set when pref off");
        ok( $procfee->amount == 8.16,  "Processing fee if processing fee");
        is( $procfee->issue_id, $cli_issue_id_3, "Processing fee issue id is correct" );
        $procfee->delete();
        C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber3, 6.12, "Perdedor");
        $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber3, debit_type_code => 'LOST' });
        $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber3, debit_type_code => 'PROCESSING' });
        ok( $lostfine->amount == 6.12 , "Lost fine equals replacementcost when pref off and no default set");
        ok( $procfee->amount == 8.16,  "Processing fee if processing fee");
        is( $procfee->issue_id, $cli_issue_id_3, "Processing fee issue id is correct" );
        $lostfine->delete();
        $procfee->delete();

        C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber4, 0, "Perdedor");
        $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, debit_type_code => 'LOST' });
        $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, debit_type_code => 'PROCESSING' });
        ok( !$lostfine, "No lost fine if no replacementcost but default set when pref off");
        ok( $procfee->amount == 2.04,  "Processing fee if processing fee");
        is( $procfee->issue_id, $cli_issue_id_4, "Processing fee issue id is correct" );
        $procfee->delete();
        C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber4, 6.12, "Perdedor");
        $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, debit_type_code => 'LOST' });
        $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, debit_type_code => 'PROCESSING' });
        ok( $lostfine->amount == 6.12 , "Lost fine equals replacementcost when pref off and default set");
        ok( $procfee->amount == 2.04,  "Processing fee if processing fee");
        is( $procfee->issue_id, $cli_issue_id_4, "Processing fee issue id is correct" );
        $lostfine->delete();
        $procfee->delete();

        t::lib::Mocks::mock_preference('useDefaultReplacementCost', '1');

        C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber1, 0, "Perdedor");
        $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber1, debit_type_code => 'LOST' });
        $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber1, debit_type_code => 'PROCESSING' });
        ok( !$lostfine, "No lost fine if no replacementcost or default when pref on");
        ok( !$procfee,  "No processing fee if no processing fee");
        C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber1, 6.12, "Perdedor");
        $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber1, debit_type_code => 'LOST' });
        $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber1, debit_type_code => 'PROCESSING' });
        is( $lostfine->amount, "6.120000", "Lost fine equals replacementcost when pref on and no default set");
        ok( !$procfee,  "No processing fee if no processing fee");

        C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber2, 0, "Perdedor");
        $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber2, debit_type_code => 'LOST' });
        $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber2, debit_type_code => 'PROCESSING' });
        is( $lostfine->amount(), "16.320000", "Lost fine is default if no replacementcost but default set when pref on");
        ok( !$procfee,  "No processing fee if no processing fee");
        $lostfine->delete();
        C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber2, 6.12, "Perdedor");
        $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber2, debit_type_code => 'LOST' });
        $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber2, debit_type_code => 'PROCESSING' });
        is( $lostfine->amount, "6.120000" , "Lost fine equals replacementcost when pref on and default set");
        ok( !$procfee,  "No processing fee if no processing fee");

        C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber3, 0, "Perdedor");
        $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber3, debit_type_code => 'LOST' });
        $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber3, debit_type_code => 'PROCESSING' });
        ok( !$lostfine, "No lost fine if no replacementcost and default not set when pref on");
        is( $procfee->amount, "8.160000",  "Processing fee if processing fee");
        is( $procfee->issue_id, $cli_issue_id_3, "Processing fee issue id is correct" );
        $procfee->delete();
        C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber3, 6.12, "Perdedor");
        $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber3, debit_type_code => 'LOST' });
        $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber3, debit_type_code => 'PROCESSING' });
        is( $lostfine->amount, "6.120000", "Lost fine equals replacementcost when pref on and no default set");
        is( $procfee->amount, "8.160000",  "Processing fee if processing fee");
        is( $procfee->issue_id, $cli_issue_id_3, "Processing fee issue id is correct" );

        C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber4, 0, "Perdedor");
        $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, debit_type_code => 'LOST' });
        $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, debit_type_code => 'PROCESSING' });
        is( $lostfine->amount, "4.080000", "Lost fine is default if no replacementcost but default set when pref on");
        is( $procfee->amount, "2.040000",  "Processing fee if processing fee");
        is( $procfee->issue_id, $cli_issue_id_4, "Processing fee issue id is correct" );
        $lostfine->delete();
        $procfee->delete();
        C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber4, 6.12, "Perdedor");
        $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, debit_type_code => 'LOST' });
        $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, debit_type_code => 'PROCESSING' });
        is( $lostfine->amount, "6.120000", "Lost fine equals replacementcost when pref on and default set");
        is( $procfee->amount, "2.040000",  "Processing fee if processing fee");
        is( $procfee->issue_id, $cli_issue_id_4, "Processing fee issue id is correct" );
        C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber4, 6.12, "Perdedor");
        my $lostfines = Koha::Account::Lines->search({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, debit_type_code => 'LOST' });
        my $procfees  = Koha::Account::Lines->search({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, debit_type_code => 'PROCESSING' });
        ok( $lostfines->count == 1 , "Lost fine cannot be double charged for the same issue_id");
        ok( $procfees->count == 1,  "Processing fee cannot be double charged for the same issue_id");
        MarkIssueReturned($cli_borrowernumber, $cli_itemnumber4);
        $cli_issue_id_4X = $builder->build({ source => 'Issue', value => { borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4 } })->{issue_id};
        C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber4, 6.12, "Perdedor");
        $lostfines = Koha::Account::Lines->search({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, debit_type_code => 'LOST' });
        $procfees  = Koha::Account::Lines->search({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, debit_type_code => 'PROCESSING' });
        ok( $lostfines->count == 2 , "Lost fine can be charged twice for the same item if they are distinct issue_id's");
        ok( $procfees->count == 2,  "Processing fee can be charged twice for the same item if they are distinct issue_id's");
        $lostfines->delete();
        $procfees->delete();

        C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber5, 6.12, "Bundle");
        $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber5, debit_type_code => 'LOST' });
        $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber5, debit_type_code => 'PROCESSING' });
        is( $lostfine->amount, "6.120000", "Lost fine equals replacementcost when pref on and default set (Bundle)");
        is( $procfee->amount, "2.040000",  "Processing fee if processing fee (Bundle)");
        is( $lostfine->issue_id, $cli_bundle_issue, "Lost fine issue id matched to bundle issue");
        is( $procfee->issue_id, $cli_bundle_issue, "Processing fee issue id matched to bundle issue");
        $lostfine->delete();
        $procfee->delete();
    };

    subtest "basic fields tests" => sub {
        plan tests => 12;

        t::lib::Mocks::mock_preference('ProcessingFeeNote', 'Test Note');
        C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber4, '1.99', "Perdedor");

        # Lost Item Fee
        $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, debit_type_code => 'LOST' });
        ok($lostfine, "Lost fine created");
        is($lostfine->manager_id, $staff_id, "Lost fine manager_id set correctly");
        is($lostfine->issue_id, $cli_issue_id_4X, "Lost fine issue_id set correctly");
        is($lostfine->description, "Perdedor", "Lost fine issue_id set correctly");
        is($lostfine->note, '', "Lost fine does not contain a note");
        is($lostfine->branchcode, $branchcode, "Lost fine branchcode set correctly");

        # Processing Fee
        $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, debit_type_code => 'PROCESSING' });
        ok($procfee, "Processing fee created");
        is($procfee->manager_id, $staff_id, "Processing fee manager_id set correctly");
        is($procfee->issue_id, $cli_issue_id_4X, "Processing fee issue_id set correctly");
        is($procfee->description, "Perdedor", "Processing fee issue_id set correctly");
        is($procfee->note, C4::Context->preference("ProcessingFeeNote"), "Processing fee contains note matching ProcessingFeeNote");
        is($procfee->branchcode, $branchcode, "Processing fee branchcode set correctly");
        $lostfine->delete();
        $procfee->delete();
    };

    subtest "FinesLog tests" => sub {
        plan tests => 2;

        my $action_logs = $schema->resultset('ActionLog')->search()->count;

        t::lib::Mocks::mock_preference( 'FinesLog', 0 );
        C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber4, 0, "Perdedor");
        $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, debit_type_code => 'LOST' });
        $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, debit_type_code => 'PROCESSING' });
        is( $schema->resultset('ActionLog')->count(), $action_logs + 0, 'No logs were added' );
        $lostfine->delete();
        $procfee->delete();

        t::lib::Mocks::mock_preference( 'FinesLog', 1 );
        C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber4, 0, "Perdedor");
        $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, debit_type_code => 'LOST' });
        $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, debit_type_code => 'PROCESSING' });
        is( $schema->resultset('ActionLog')->count(), $action_logs + 2, 'Logs were added' );
        $lostfine->delete();
        $procfee->delete();
    };

    # Cleanup - this must be replaced with a transaction per subtest
    Koha::Patrons->find($cli_borrowernumber)->checkouts->delete;
};

subtest "Koha::Account::non_issues_charges tests" => sub {
    plan tests => 6;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $account = $patron->account;

    my $res    = 3;
    my $rent   = 5;
    my $manual = 7;
    my $print = 4;
    $account->add_debit(
        {
            description => 'a Res fee',
            type        => 'RESERVE',
            amount      => $res,
            interface   => 'commandline'
        }
    );
    $account->add_debit(
        {
            description => 'a Rental fee',
            type        => 'RENT',
            amount      => $rent,
            interface   => 'commandline'
        }
    );
    Koha::Account::DebitTypes->find_or_create(
        {
            code        => 'Copie',
            description => 'Fee for copie',
            is_system   => 0
        }
    )->store;
    Koha::Account::Line->new(
        {
            borrowernumber    => $patron->borrowernumber,
            description       => 'a Manual invoice fee',
            debit_type_code   => 'Copie',
            amountoutstanding => $manual,
            interface         => 'commandline'
        }
    )->store;

    my ( $total, $non_issues_charges ) = ( $account->balance, $account->non_issues_charges );
    my $other_charges = $total - $non_issues_charges;
    is(
        $account->balance,
        $res + $rent + $manual,
        'Total charges should be Res + Rent + Manual'
    );
    is( $non_issues_charges, 15,
        'All types should count towards the non issue charge' );
    is( $other_charges, 0, 'There shouldn\'t be any non-included charges' );

    Koha::Account::DebitTypes->find_or_create(
        {
            code        => 'Print',
            description => 'Charge for using the printer',
            is_system   => 0,
            restricts_checkouts => 0
        }
    )->store;
    Koha::Account::Line->new(
        {
            borrowernumber    => $patron->borrowernumber,
            description       => 'Non-restricting fee',
            debit_type_code   => 'Print',
            amountoutstanding => $print,
            interface         => 'commandline'
        }
    )->store;

    my ( $new_total, $new_non_issues_charges ) = ( $account->balance, $account->non_issues_charges );
    my $new_other_charges = $new_total - $new_non_issues_charges;
    is(
        $account->balance,
        $res + $rent + $manual + $print,
        'Total charges should be Res + Rent + Manual + Print'
    );
    is( $new_non_issues_charges, 15,
        'All types except Print should count towards the non issue charge' );
    is( $new_other_charges, 4, 'There should be non-included charges for Print' );

};

subtest "Koha::Account::non_issues_charges tests" => sub {
    plan tests => 9;

    my $patron = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => {
                firstname    => 'Test',
                surname      => 'Patron',
                categorycode => $categorycode,
                branchcode   => $branchcode
            }
        }
    );

    my $debit = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            date              => '1970-01-01 00:00:01',
            amountoutstanding => 0,
            interface         => 'commandline',
            debit_type_code   => 'LOST'
        }
    )->store();
    my $credit = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            date              => '1970-01-01 00:00:01',
            amountoutstanding => -5,
            interface         => 'commandline',
            credit_type_code  => 'PAYMENT'
        }
    )->store();
    my $offset = Koha::Account::Offset->new(
        {
            credit_id => $credit->id,
            debit_id  => $debit->id,
            type      => 'APPLY',
            amount    => 0
        }
    )->store();
    purge_zero_balance_fees( 1 );
    my $debit_2 = Koha::Account::Lines->find( $debit->id );
    my $credit_2 = Koha::Account::Lines->find( $credit->id );
    ok( $debit_2, 'Debit was correctly not deleted when credit has balance' );
    ok( $credit_2, 'Credit was correctly not deleted when credit has balance' );
    is( Koha::Account::Lines->count({ borrowernumber => $patron->id }), 2, "The 2 account lines still exists" );

    $debit = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            date              => '1970-01-01 00:00:01',
            amountoutstanding => 5,
            interface         => 'commanline',
            debit_type_code   => 'LOST'
        }
    )->store();
    $credit = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            date              => '1970-01-01 00:00:01',
            amountoutstanding => 0,
            interface         => 'commandline',
            credit_type_code  => 'PAYMENT'
        }
    )->store();
    $offset = Koha::Account::Offset->new(
        {
            credit_id => $credit->id,
            debit_id  => $debit->id,
            type      => 'APPLY',
            amount    => 0
        }
    )->store();
    purge_zero_balance_fees( 1 );
    $debit_2 = $credit_2 = undef;
    $debit_2 = Koha::Account::Lines->find( $debit->id );
    $credit_2 = Koha::Account::Lines->find( $credit->id );
    ok( $debit_2, 'Debit was correctly not deleted when debit has balance' );
    ok( $credit_2, 'Credit was correctly not deleted when debit has balance' );
    is( Koha::Account::Lines->count({ borrowernumber => $patron->id }), 2 + 2, "The 2 + 2 account lines still exists" );

    $debit = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            date              => '1970-01-01 00:00:01',
            amountoutstanding => 0,
            interface         => 'commandline',
            debit_type_code   => 'LOST'
        }
    )->store();
    $credit = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->id,
            date              => '1970-01-01 00:00:01',
            amountoutstanding => 0,
            interface         => 'commandline',
            credit_type_code  => 'PAYMENT'
        }
    )->store();
    $offset = Koha::Account::Offset->new(
        {
            credit_id => $credit->id,
            debit_id  => $debit->id,
            type      => 'APPLY',
            amount    => 0
        }
    )->store();
    purge_zero_balance_fees( 1 );
    $debit_2 = Koha::Account::Lines->find( $debit->id );
    $credit_2 = Koha::Account::Lines->find( $credit->id );
    ok( !$debit_2, 'Debit was correctly deleted' );
    ok( !$credit_2, 'Credit was correctly deleted' );
    is( Koha::Account::Lines->count({ borrowernumber => $patron->id }), 2 + 2, "The 2 + 2 account lines still exists, the last 2 have been deleted ok" );
};


subtest "Koha::Account::Offset credit & debit tests" => sub {

    plan tests => 4;

    # Create a borrower
    my $categorycode = $builder->build({ source => 'Category' })->{ categorycode };
    my $branchcode   = $builder->build({ source => 'Branch' })->{ branchcode };

    my $borrower = Koha::Patron->new( {
        cardnumber => 'kyliehall',
        surname => 'Hall',
        firstname => 'Kylie',
    } );
    $borrower->categorycode( $categorycode );
    $borrower->branchcode( $branchcode );
    $borrower->store;

    my $account = Koha::Account->new({ patron_id => $borrower->id });

    my $line1 = Koha::Account::Line->new(
        {
            borrowernumber    => $borrower->borrowernumber,
            amount            => 10,
            amountoutstanding => 10,
            interface         => 'commandline',
            debit_type_code   => 'LOST'
        }
    )->store();
    my $line2 = Koha::Account::Line->new(
        {
            borrowernumber    => $borrower->borrowernumber,
            amount            => 20,
            amountoutstanding => 20,
            interface         => 'commandline',
            debit_type_code   => 'LOST'
        }
    )->store();

    my $id = $account->pay(
        {
            lines  => [$line1, $line2],
            amount => 30,
        }
    )->{payment_id};

    # Test debit and credit methods for Koha::Account::Offset
    my $account_offset = Koha::Account::Offsets->find( { credit_id => $id, debit_id => $line1->id } );
    is( $account_offset->debit->id, $line1->id, "Koha::Account::Offset->debit gets correct accountline" );
    is( $account_offset->credit->id, $id, "Koha::Account::Offset->credit gets correct accountline" );

    $account_offset = Koha::Account::Offset->new(
        {
            credit_id => undef,
            debit_id  => undef,
            type      => 'CREATE',
            amount    => 0,
        }
    )->store();

    is( $account_offset->debit, undef, "Koha::Account::Offset->debit returns undef if no associated debit" );
    is( $account_offset->credit, undef, "Koha::Account::Offset->credit returns undef if no associated credit" );
};

subtest "Payment notice tests" => sub {

    plan tests => 8;

    Koha::Notice::Messages->delete();
    # Create a patron
    my $patron = $builder->build_object({ class => 'Koha::Patrons' });

    my $manager = $builder->build_object({ class => "Koha::Patrons" });
    my $context = Test::MockModule->new('C4::Context');
    $context->mock( 'userenv', sub {
        return {
            number     => $manager->borrowernumber,
            branch     => $manager->branchcode,
        };
    });
    my $account = Koha::Account->new({ patron_id => $patron->borrowernumber });

    my $line = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->borrowernumber,
            amountoutstanding => 27,
            interface         => 'commandline',
            debit_type_code   => 'LOST'
        }
    )->store();

    my $letter = Koha::Notice::Templates->find( { code => 'ACCOUNT_PAYMENT' } );
    $letter->content('[%- USE Price -%]A payment of [% credit.amount * -1 | $Price %] has been applied to your account. Your [% branch.branchcode %]');
    $letter->store();

    t::lib::Mocks::mock_preference('UseEmailReceipts', '0');
    my $id = $account->pay( { amount => 1 } )->{payment_id};
    is( Koha::Notice::Messages->search()->count(), 0, 'Notice for payment not sent if UseEmailReceipts is disabled' );

    $id = $account->pay( { amount => 1, type => 'WRITEOFF' } )->{payment_id};
    is( Koha::Notice::Messages->search()->count(), 0, 'Notice for writeoff not sent if UseEmailReceipts is disabled' );

    t::lib::Mocks::mock_preference('UseEmailReceipts', '1');

    $id = $account->pay( { amount => 12, library_id => $branchcode } )->{payment_id};
    my $notice = Koha::Notice::Messages->search()->next();
    is( $notice->subject, 'Account payment', 'Notice subject is correct for payment' );
    is( $notice->letter_code, 'ACCOUNT_PAYMENT', 'Notice letter code is correct for payment' );
    is( $notice->content, "A payment of 12.00 has been applied to your account. Your $branchcode", 'Notice content is correct for payment' );
    $notice->delete();

    $letter = Koha::Notice::Templates->find( { code => 'ACCOUNT_WRITEOFF' } );
    $letter->content('[%- USE Price -%]A writeoff of [% credit.amount * -1 | $Price %] has been applied to your account. Your [% branch.branchcode %]');
    $letter->store();

    $id = $account->pay( { amount => 13, type => 'WRITEOFF', library_id => $branchcode  } )->{payment_id};
    $notice = Koha::Notice::Messages->search()->next();
    is( $notice->subject, 'Account writeoff', 'Notice subject is correct for payment' );
    is( $notice->letter_code, 'ACCOUNT_WRITEOFF', 'Notice letter code is correct for writeoff' );
    is( $notice->content, "A writeoff of 13.00 has been applied to your account. Your $branchcode", 'Notice content is correct for writeoff' );
};

1;
