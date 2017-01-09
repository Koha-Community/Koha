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

use Test::More tests => 21;
use Test::MockModule;
use Test::Warn;

use t::lib::TestBuilder;

use Koha::Account::Lines;
use Koha::Account::Line;

BEGIN {
    use_ok('C4::Accounts');
    use_ok('Koha::Object');
    use_ok('Koha::Patron');
    use_ok('Data::Dumper');
}

can_ok( 'C4::Accounts',
    qw(
        makepayment
        getnextacctno
        chargelostitem
        manualinvoice
        getcharges
        ModNote
        getcredits
        getrefunds
        ReversePayment
        recordpayment_selectaccts
        makepartialpayment
        WriteOffFee
        purge_zero_balance_fees )
);

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

my $builder = t::lib::TestBuilder->new;
my $library = $builder->build( { source => 'Branch' } );

$dbh->do(q|DELETE FROM accountlines|);
$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM borrowers|);

my $branchcode = $library->{branchcode};
my $borrower_number;

my $context = new Test::MockModule('C4::Context');
$context->mock( 'userenv', sub {
    return {
        flags  => 1,
        id     => 'my_userid',
        branch => $branchcode,
    };
});

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
         description
     )
     VALUES ( ?, ?, (select date_sub(CURRENT_DATE, INTERVAL ? DAY) ), ? )"
);

my $days = 5;

my @test_data = (
    { amount => 0     , days_ago => 0         , description =>'purge_zero_balance_fees should not delete 0 balance fees with date today'                     , delete => 0 } ,
    { amount => 0     , days_ago => $days - 1 , description =>'purge_zero_balance_fees should not delete 0 balance fees with date before threshold day'      , delete => 0 } ,
    { amount => 0     , days_ago => $days     , description =>'purge_zero_balance_fees should not delete 0 balance fees with date on threshold day'          , delete => 0 } ,
    { amount => 0     , days_ago => $days + 1 , description =>'purge_zero_balance_fees should delete 0 balance fees with date after threshold day'           , delete => 1 } ,
    { amount => undef , days_ago => $days + 1 , description =>'purge_zero_balance_fees should delete NULL balance fees with date after threshold day'        , delete => 1 } ,
    { amount => 5     , days_ago => $days - 1 , description =>'purge_zero_balance_fees should not delete fees with positive amout owed before threshold day'  , delete => 0 } ,
    { amount => 5     , days_ago => $days     , description =>'purge_zero_balance_fees should not delete fees with positive amout owed on threshold day'      , delete => 0 } ,
    { amount => 5     , days_ago => $days + 1 , description =>'purge_zero_balance_fees should not delete fees with positive amout owed after threshold day'   , delete => 0 } ,
    { amount => -5    , days_ago => $days - 1 , description =>'purge_zero_balance_fees should not delete fees with negative amout owed before threshold day' , delete => 0 } ,
    { amount => -5    , days_ago => $days     , description =>'purge_zero_balance_fees should not delete fees with negative amout owed on threshold day'     , delete => 0 } ,
    { amount => -5    , days_ago => $days + 1 , description =>'purge_zero_balance_fees should not delete fees with negative amout owed after threshold day'  , delete => 0 }
);

my $borrower = Koha::Patron->new( { firstname => 'Test', surname => 'Patron', categorycode => 'PT', branchcode => $branchcode } )->store();

for my $data ( @test_data ) {
    $sth->execute($borrower->borrowernumber, $data->{amount}, $data->{days_ago}, $data->{description});
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

subtest "Koha::Account::pay tests" => sub {

    plan tests => 12;

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

    my $line1 = Koha::Account::Line->new({ borrowernumber => $borrower->borrowernumber, amountoutstanding => 100 })->store();
    my $line2 = Koha::Account::Line->new({ borrowernumber => $borrower->borrowernumber, amountoutstanding => 200 })->store();

    $sth = $dbh->prepare("SELECT count(*) FROM accountlines");
    $sth->execute;
    my $count = $sth->fetchrow_array;
    is($count, 2, 'There is 2 lines as expected');

    # There is $100 in the account
    $sth = $dbh->prepare("SELECT amountoutstanding FROM accountlines WHERE borrowernumber=?");
    my $amountoutstanding = $dbh->selectcol_arrayref($sth, {}, $borrower->borrowernumber);
    my $amountleft = 0;
    for my $line ( @$amountoutstanding ) {
        $amountleft += $line;
    }
    is($amountleft, 300, 'The account has 300$ as expected' );

    # We make a $20 payment
    my $borrowernumber = $borrower->borrowernumber;
    my $data = '20.00';
    my $payment_note = '$20.00 payment note';
    $account->pay( { amount => $data, note => $payment_note } );

    # There is now $280 in the account
    $sth = $dbh->prepare("SELECT amountoutstanding FROM accountlines WHERE borrowernumber=?");
    $amountoutstanding = $dbh->selectcol_arrayref($sth, {}, $borrower->borrowernumber);
    $amountleft = 0;
    for my $line ( @$amountoutstanding ) {
        $amountleft += $line;
    }
    is($amountleft, 280, 'The account has $280 as expected' );

    # Is the payment note well registered
    $sth = $dbh->prepare("SELECT note FROM accountlines WHERE borrowernumber=? ORDER BY accountlines_id DESC LIMIT 1");
    $sth->execute($borrower->borrowernumber);
    my $note = $sth->fetchrow_array;
    is($note,'$20.00 payment note', '$20.00 payment note is registered');

    # We make a -$30 payment (a NEGATIVE payment)
    $data = '-30.00';
    $payment_note = '-$30.00 payment note';
    $account->pay( { amount => $data, note => $payment_note } );

    # There is now $310 in the account
    $sth = $dbh->prepare("SELECT amountoutstanding FROM accountlines WHERE borrowernumber=?");
    $amountoutstanding = $dbh->selectcol_arrayref($sth, {}, $borrower->borrowernumber);
    $amountleft = 0;
    for my $line ( @$amountoutstanding ) {
        $amountleft += $line;
    }
    is($amountleft, 310, 'The account has $310 as expected' );
    # Is the payment note well registered
    $sth = $dbh->prepare("SELECT note FROM accountlines WHERE borrowernumber=? ORDER BY accountlines_id DESC LIMIT 1");
    $sth->execute($borrower->borrowernumber);
    $note = $sth->fetchrow_array;
    is($note,'-$30.00 payment note', '-$30.00 payment note is registered');

    #We make a $150 payment ( > 1stLine )
    $data = '150.00';
    $payment_note = '$150.00 payment note';
    $account->pay( { amount => $data, note => $payment_note } );

    # There is now $160 in the account
    $sth = $dbh->prepare("SELECT amountoutstanding FROM accountlines WHERE borrowernumber=?");
    $amountoutstanding = $dbh->selectcol_arrayref($sth, {}, $borrower->borrowernumber);
    $amountleft = 0;
    for my $line ( @$amountoutstanding ) {
        $amountleft += $line;
    }
    is($amountleft, 160, 'The account has $160 as expected' );

    # Is the payment note well registered
    $sth = $dbh->prepare("SELECT note FROM accountlines WHERE borrowernumber=? ORDER BY accountlines_id DESC LIMIT 1");
    $sth->execute($borrower->borrowernumber);
    $note = $sth->fetchrow_array;
    is($note,'$150.00 payment note', '$150.00 payment note is registered');

    #We make a $200 payment ( > amountleft )
    $data = '200.00';
    $payment_note = '$200.00 payment note';
    $account->pay( { amount => $data, note => $payment_note } );

    # There is now -$40 in the account
    $sth = $dbh->prepare("SELECT amountoutstanding FROM accountlines WHERE borrowernumber=?");
    $amountoutstanding = $dbh->selectcol_arrayref($sth, {}, $borrower->borrowernumber);
    $amountleft = 0;
    for my $line ( @$amountoutstanding ) {
        $amountleft += $line;
    }
    is($amountleft, -40, 'The account has -$40 as expected, (credit situation)' );

    # Is the payment note well registered
    $sth = $dbh->prepare("SELECT note FROM accountlines WHERE borrowernumber=? ORDER BY accountlines_id DESC LIMIT 1");
    $sth->execute($borrower->borrowernumber);
    $note = $sth->fetchrow_array;
    is($note,'$200.00 payment note', '$200.00 payment note is registered');

    my $line3 = Koha::Account::Line->new({ borrowernumber => $borrower->borrowernumber, amountoutstanding => 42, accounttype => 'TEST' })->store();
    my $payment_id = $account->pay( { lines => [$line3], amount => 42 } );
    my $payment = Koha::Account::Lines->find( $payment_id );
    is( $payment->amount(), '-42.000000', "Payment paid the specified fine" );
    $line3 = Koha::Account::Lines->find( $line3->id );
    is( $line3->amountoutstanding, '0.000000', "Specified fine is paid" );
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

    my $line1 = Koha::Account::Line->new({ borrowernumber => $borrower->borrowernumber, amountoutstanding => 1 })->store();
    my $line2 = Koha::Account::Line->new({ borrowernumber => $borrower->borrowernumber, amountoutstanding => 2 })->store();
    my $line3 = Koha::Account::Line->new({ borrowernumber => $borrower->borrowernumber, amountoutstanding => 3 })->store();
    my $line4 = Koha::Account::Line->new({ borrowernumber => $borrower->borrowernumber, amountoutstanding => 4 })->store();

    is( $account->balance(), "10.000000", "Account balance is 10" );

    $account->pay(
        {
            lines => [$line2, $line3, $line4],
            amount => 4,
        }
    );

    $_->_result->discard_changes foreach ( $line1, $line2, $line3, $line4 );

    # Line1 is not paid at all, as it was not passed in the lines param
    is( $line1->amountoutstanding, "1.000000", "Line 1 was not paid" );
    # Line2 was paid in full, as it was the first in the lines list
    is( $line2->amountoutstanding, "0.000000", "Line 2 was paid in full" );
    # Line3 was paid partially, as the remaining balance did not cover it entirely
    is( $line3->amountoutstanding, "1.000000", "Line 3 was paid to 1.00" );
    # Line4 was not paid at all, as the payment was all used up by that point
    is( $line4->amountoutstanding, "4.000000", "Line 4 was not paid" );
};

subtest "makepayment() tests" => sub {

    plan tests => 6;

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
    my $accountline = $builder->build({ source => 'Accountline',
        value  => { borrowernumber => $borrowernumber,
                    amount => $amount,
                    amountoutstanding => $amount }
    });

    my $rs = $schema->resultset('Accountline')->search({
        borrowernumber => $borrowernumber
    });

    is( $rs->count(), 1, 'Accountline created' );

    # make the full payment
    makepayment(
        $accountline->{ accountlines_id }, $borrowernumber,
        $accountline->{ accountno },       $amount,
        $borrowernumber, $branch, 'A payment note' );

    # TODO: someone should write actual tests for makepayment()

    my $stat = $schema->resultset('Statistic')->search({
        branch  => $branch,
        type    => 'payment'
    }, { order_by => { -desc => 'datetime' } })->next();

    ok( defined $stat, "There's a payment log that matches the branch" );

    SKIP: {
        skip "No statistic logged", 4 unless defined $stat;

        is( $stat->type, 'payment', "Correct statistic type" );
        is( $stat->branch, $branch, "Correct branch logged to statistics" );
        is( $stat->borrowernumber, $borrowernumber, "Correct borrowernumber logged to statistics" );
        is( $stat->value, "$amount" . "\.0000", "Correct amount logged to statistics" );
    }
};

subtest "makepartialpayment() tests" => sub {

    plan tests => 6;

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
    my $accountline = $builder->build({ source => 'Accountline',
        value  => { borrowernumber => $borrowernumber,
                    amount => $amount,
                    amountoutstanding => $amount }
    });

    my $rs = $schema->resultset('Accountline')->search({
        borrowernumber => $borrowernumber
    });

    is( $rs->count(), 1, 'Accountline created' );

    # make the full payment
    makepartialpayment(
        $accountline->{ accountlines_id }, $borrowernumber,
        $accountline->{ accountno },       $partialamount,
        $borrowernumber, $branch, 'A payment note' );

    # TODO: someone should write actual tests for makepartialpayment()

    my $stat = $schema->resultset('Statistic')->search({
        branch  => $branch,
        type    => 'payment'
    }, { order_by => { -desc => 'datetime' } })->next();

    ok( defined $stat, "There's a payment log that matches the branch" );

    SKIP: {
        skip "No statistic logged", 4 unless defined $stat;

        is( $stat->type, 'payment', "Correct statistic type" );
        is( $stat->branch, $branch, "Correct branch logged to statistics" );
        is( $stat->borrowernumber, $borrowernumber, "Correct borrowernumber logged to statistics" );
        is( $stat->value, "$partialamount" . "\.0000", "Correct amount logged to statistics" );
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
                amountoutstanding => 42
            }
        }
    );
    my $accountline_2 = $builder->build(
        {
            source => 'Accountline',
            value  => {
                borrowernumber    => $patron->borrowernumber,
                amount            => -13,
                amountoutstanding => -13
            }
        }
    );

    my $balance = $patron->account->balance;
    is( int($balance), 29, 'balance should return the correct value');

    $patron->delete;
};

1;
