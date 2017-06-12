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

use Test::More tests => 25;
use Test::MockModule;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Account;
use Koha::Account::Lines;
use Koha::Account::Offsets;
use Koha::DateUtils qw( dt_from_string );

BEGIN {
    use_ok('C4::Accounts');
    use_ok('Koha::Object');
    use_ok('Koha::Patron');
    use_ok('Data::Dumper');
}

can_ok( 'C4::Accounts',
    qw(
        getnextacctno
        chargelostitem
        manualinvoice
        getcharges
        ModNote
        getcredits
        getrefunds
        ReversePayment
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
my $categorycode = $builder->build({ source => 'Category' })->{categorycode};
my $borrower = Koha::Patron->new( { firstname => 'Test', surname => 'Patron', categorycode => $categorycode, branchcode => $branchcode } )->store();

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

    plan tests => 13;

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
    my $id = $account->pay( { amount => $data, note => $payment_note, payment_type => "TEST_TYPE" } );

    my $accountline = Koha::Account::Lines->find( $id );
    is( $accountline->payment_type, "TEST_TYPE", "Payment type passed into pay is set in account line correctly" );

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

    is( $account->balance(), 10, "Account balance is 10" );

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

    my $line = Koha::Account::Line->new({ borrowernumber => $borrower->borrowernumber, amountoutstanding => 42 })->store();

    is( $account->balance(), 42, "Account balance is 42" );

    my $id = $account->pay(
        {
            lines  => [$line],
            amount => 42,
            type   => 'writeoff',
        }
    );

    $line->_result->discard_changes();

    is( $line->amountoutstanding, "0.000000", "Line was written off" );

    my $writeoff = Koha::Account::Lines->find( $id );

    is( $writeoff->accounttype, 'W', 'Type is correct' );
    is( $writeoff->description, 'Writeoff', 'Description is correct' );
    is( $writeoff->amount, '-42.000000', 'Amount is correct' );
};

subtest "More Koha::Account::pay tests" => sub {

    plan tests => 8;

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

    my $account = Koha::Account->new( { patron_id => $borrowernumber } );
    my $line = Koha::Account::Lines->find( $accountline->{ accountlines_id } );
    # make the full payment
    $account->pay({ lines => [$line], amount => $amount, library_id => $branch, note => 'A payment note' });

    my $offset = Koha::Account::Offsets->search({ debit_id => $accountline->{accountlines_id} })->next();
    is( $offset->amount(), '-100.000000', 'Offset amount is -100.00' );
    is( $offset->type(), 'Payment', 'Offset type is Payment' );

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

subtest "Even more Koha::Account::pay tests" => sub {

    plan tests => 8;

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

    my $account = Koha::Account->new( { patron_id => $borrowernumber } );
    my $line = Koha::Account::Lines->find( $accountline->{ accountlines_id } );
    # make the full payment
    $account->pay({ lines => [$line], amount => $partialamount, library_id => $branch, note => 'A payment note' });

    my $offset = Koha::Account::Offsets->search( { debit_id => $accountline->{ accountlines_id } } )->next();
    is( $offset->amount, '-60.000000', 'Offset amount is -60.00' );
    is( $offset->type, 'Payment', 'Offset type is payment' );

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

subtest "Koha::Account::chargelostitem tests" => sub {
    plan tests => 32;

    my $lostfine;
    my $procfee;

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
    my $cli_itemnumber1 = $builder->build({ source => 'Item', value => { itype => $itype_no_replace_no_fee->{itemtype} } })->{'itemnumber'};
    my $cli_itemnumber2 = $builder->build({ source => 'Item', value => { itype => $itype_replace_no_fee->{itemtype} } })->{'itemnumber'};
    my $cli_itemnumber3 = $builder->build({ source => 'Item', value => { itype => $itype_no_replace_fee->{itemtype} } })->{'itemnumber'};
    my $cli_itemnumber4 = $builder->build({ source => 'Item', value => { itype => $itype_replace_fee->{itemtype} } })->{'itemnumber'};
    my $duck = Koha::Items->find({itemnumber=>$cli_itemnumber1});

    t::lib::Mocks::mock_preference('item-level_itypes', '1');
    t::lib::Mocks::mock_preference('useDefaultReplacementCost', '0');

    C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber1, 0, "Perdedor");
    $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber1, accounttype => 'L' });
    $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber1, accounttype => 'PF' });
    ok( !$lostfine, "No lost fine if no replacementcost or default when pref off");
    ok( !$procfee,  "No processing fee if no processing fee");
    C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber1, 6.12, "Perdedor");
    $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber1, accounttype => 'L' });
    $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber1, accounttype => 'PF' });
    ok( $lostfine->amount == 6.12, "Lost fine equals replacementcost when pref off and no default set");
    ok( !$procfee,  "No processing fee if no processing fee");
    $lostfine->delete();

    C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber2, 0, "Perdedor");
    $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber2, accounttype => 'L' });
    $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber2, accounttype => 'PF' });
    ok( !$lostfine, "No lost fine if no replacementcost but default set when pref off");
    ok( !$procfee,  "No processing fee if no processing fee");
    C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber2, 6.12, "Perdedor");
    $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber2, accounttype => 'L' });
    $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber2, accounttype => 'PF' });
    ok( $lostfine->amount == 6.12 , "Lost fine equals replacementcost when pref off and default set");
    ok( !$procfee,  "No processing fee if no processing fee");
    $lostfine->delete();

    C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber3, 0, "Perdedor");
    $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber3, accounttype => 'L' });
    $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber3, accounttype => 'PF' });
    ok( !$lostfine, "No lost fine if no replacementcost and no default set when pref off");
    ok( $procfee->amount == 8.16,  "Processing fee if processing fee");
    $procfee->delete();
    C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber3, 6.12, "Perdedor");
    $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber3, accounttype => 'L' });
    $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber3, accounttype => 'PF' });
    ok( $lostfine->amount == 6.12 , "Lost fine equals replacementcost when pref off and no default set");
    ok( $procfee->amount == 8.16,  "Processing fee if processing fee");
    $lostfine->delete();
    $procfee->delete();

    C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber4, 0, "Perdedor");
    $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, accounttype => 'L' });
    $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, accounttype => 'PF' });
    ok( !$lostfine, "No lost fine if no replacementcost but default set when pref off");
    ok( $procfee->amount == 2.04,  "Processing fee if processing fee");
    $procfee->delete();
    C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber4, 6.12, "Perdedor");
    $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, accounttype => 'L' });
    $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, accounttype => 'PF' });
    ok( $lostfine->amount == 6.12 , "Lost fine equals replacementcost when pref off and default set");
    ok( $procfee->amount == 2.04,  "Processing fee if processing fee");
    $lostfine->delete();
    $procfee->delete();

    t::lib::Mocks::mock_preference('useDefaultReplacementCost', '1');

    C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber1, 0, "Perdedor");
    $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber1, accounttype => 'L' });
    $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber1, accounttype => 'PF' });
    ok( !$lostfine, "No lost fine if no replacementcost or default when pref on");
    ok( !$procfee,  "No processing fee if no processing fee");
    C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber1, 6.12, "Perdedor");
    $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber1, accounttype => 'L' });
    $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber1, accounttype => 'PF' });
    is( $lostfine->amount, "6.120000", "Lost fine equals replacementcost when pref on and no default set");
    ok( !$procfee,  "No processing fee if no processing fee");

    C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber2, 0, "Perdedor");
    $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber2, accounttype => 'L' });
    $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber2, accounttype => 'PF' });
    is( $lostfine->amount(), "16.320000", "Lost fine is default if no replacementcost but default set when pref on");
    ok( !$procfee,  "No processing fee if no processing fee");
    $lostfine->delete();
    C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber2, 6.12, "Perdedor");
    $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber2, accounttype => 'L' });
    $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber2, accounttype => 'PF' });
    is( $lostfine->amount, "6.120000" , "Lost fine equals replacementcost when pref on and default set");
    ok( !$procfee,  "No processing fee if no processing fee");

    C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber3, 0, "Perdedor");
    $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber3, accounttype => 'L' });
    $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber3, accounttype => 'PF' });
    ok( !$lostfine, "No lost fine if no replacementcost and default not set when pref on");
    is( $procfee->amount, "8.160000",  "Processing fee if processing fee");
    $procfee->delete();
    C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber3, 6.12, "Perdedor");
    $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber3, accounttype => 'L' });
    $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber3, accounttype => 'PF' });
    is( $lostfine->amount, "6.120000", "Lost fine equals replacementcost when pref on and no default set");
    is( $procfee->amount, "8.160000",  "Processing fee if processing fee");

    C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber4, 0, "Perdedor");
    $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, accounttype => 'L' });
    $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, accounttype => 'PF' });
    is( $lostfine->amount, "4.080000", "Lost fine is default if no replacementcost but default set when pref on");
    is( $procfee->amount, "2.040000",  "Processing fee if processing fee");
    $lostfine->delete();
    $procfee->delete();
    C4::Accounts::chargelostitem( $cli_borrowernumber, $cli_itemnumber4, 6.12, "Perdedor");
    $lostfine = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, accounttype => 'L' });
    $procfee  = Koha::Account::Lines->find({ borrowernumber => $cli_borrowernumber, itemnumber => $cli_itemnumber4, accounttype => 'PF' });
    is( $lostfine->amount, "6.120000", "Lost fine equals replacementcost when pref on and default set");
    is( $procfee->amount, "2.040000",  "Processing fee if processing fee");
};

subtest "Koha::Account::non_issues_charges tests" => sub {
    plan tests => 21;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    my $today  = dt_from_string;
    my $res    = 3;
    my $rent   = 5;
    my $manual = 7;
    Koha::Account::Line->new(
        {
            borrowernumber    => $patron->borrowernumber,
            accountno         => 1,
            date              => $today,
            description       => 'a Res fee',
            accounttype       => 'Res',
            amountoutstanding => $res,
        }
    )->store;
    Koha::Account::Line->new(
        {
            borrowernumber    => $patron->borrowernumber,
            accountno         => 2,
            date              => $today,
            description       => 'a Rental fee',
            accounttype       => 'Rent',
            amountoutstanding => $rent,
        }
    )->store;
    Koha::Account::Line->new(
        {
            borrowernumber    => $patron->borrowernumber,
            accountno         => 3,
            date              => $today,
            description       => 'a Manual invoice fee',
            accounttype       => 'Copie',
            amountoutstanding => $manual,
        }
    )->store;
    Koha::AuthorisedValue->new(
        {
            category         => 'MANUAL_INV',
            authorised_value => 'Copie',
            lib              => 'Fee for copie',
        }
    )->store;

    my $account = $patron->account;

    t::lib::Mocks::mock_preference( 'HoldsInNoissuesCharge',   0 );
    t::lib::Mocks::mock_preference( 'RentalsInNoissuesCharge', 0 );
    t::lib::Mocks::mock_preference( 'ManInvInNoissuesCharge',  0 );
    my ( $total, $non_issues_charges ) = ( $account->balance, $account->non_issues_charges );
    my $other_charges = $total - $non_issues_charges;
    is(
        $account->balance,
        $res + $rent + $manual,
        'Total charges should be Res + Rent + Manual'
    );
    is( $non_issues_charges, 0,
        'If 0|0|0 there should not have non issues charges' );
    is( $other_charges, 15, 'If 0|0|0 there should only have other charges' );

    t::lib::Mocks::mock_preference( 'HoldsInNoissuesCharge',   0 );
    t::lib::Mocks::mock_preference( 'RentalsInNoissuesCharge', 0 );
    t::lib::Mocks::mock_preference( 'ManInvInNoissuesCharge',  1 );
    ( $total, $non_issues_charges ) = ( $account->balance, $account->non_issues_charges );
    $other_charges = $total - $non_issues_charges;
    is(
        $total,
        $res + $rent + $manual,
        'Total charges should be Res + Rent + Manual'
    );
    is( $non_issues_charges, $manual,
        'If 0|0|1 Only Manual should be a non issue charge' );
    is(
        $other_charges,
        $res + $rent,
        'If 0|0|1 Res + Rent should be other charges'
    );

    t::lib::Mocks::mock_preference( 'HoldsInNoissuesCharge',   0 );
    t::lib::Mocks::mock_preference( 'RentalsInNoissuesCharge', 1 );
    t::lib::Mocks::mock_preference( 'ManInvInNoissuesCharge',  0 );
    ( $total, $non_issues_charges ) = ( $account->balance, $account->non_issues_charges );
    $other_charges = $total - $non_issues_charges;
    is(
        $total,
        $res + $rent + $manual,
        'Total charges should be Res + Rent + Manual'
    );
    is( $non_issues_charges, $rent,
        'If 0|1|0 Only Rental should be a non issue charge' );
    is(
        $other_charges,
        $res + $manual,
        'If 0|1|0 Rent + Manual should be other charges'
    );

    t::lib::Mocks::mock_preference( 'HoldsInNoissuesCharge',   0 );
    t::lib::Mocks::mock_preference( 'RentalsInNoissuesCharge', 1 );
    t::lib::Mocks::mock_preference( 'ManInvInNoissuesCharge',  1 );
    ( $total, $non_issues_charges ) = ( $account->balance, $account->non_issues_charges );
    $other_charges = $total - $non_issues_charges;
    is(
        $total,
        $res + $rent + $manual,
        'Total charges should be Res + Rent + Manual'
    );
    is(
        $non_issues_charges,
        $rent + $manual,
        'If 0|1|1 Rent + Manual should be non issues charges'
    );
    is( $other_charges, $res, 'If 0|1|1 there should only have other charges' );

    t::lib::Mocks::mock_preference( 'HoldsInNoissuesCharge',   1 );
    t::lib::Mocks::mock_preference( 'RentalsInNoissuesCharge', 0 );
    t::lib::Mocks::mock_preference( 'ManInvInNoissuesCharge',  0 );
    ( $total, $non_issues_charges ) = ( $account->balance, $account->non_issues_charges );
    $other_charges = $total - $non_issues_charges;
    is(
        $total,
        $res + $rent + $manual,
        'Total charges should be Res + Rent + Manual'
    );
    is( $non_issues_charges, $res,
        'If 1|0|0 Only Res should be non issues charges' );
    is(
        $other_charges,
        $rent + $manual,
        'If 1|0|0 Rent + Manual should be other charges'
    );

    t::lib::Mocks::mock_preference( 'HoldsInNoissuesCharge',   1 );
    t::lib::Mocks::mock_preference( 'RentalsInNoissuesCharge', 1 );
    t::lib::Mocks::mock_preference( 'ManInvInNoissuesCharge',  0 );
    ( $total, $non_issues_charges ) = ( $account->balance, $account->non_issues_charges );
    $other_charges = $total - $non_issues_charges;
    is(
        $total,
        $res + $rent + $manual,
        'Total charges should be Res + Rent + Manual'
    );
    is(
        $non_issues_charges,
        $res + $rent,
        'If 1|1|0 Res + Rent should be non issues charges'
    );
    is( $other_charges, $manual,
        'If 1|1|0 Only Manual should be other charges' );

    t::lib::Mocks::mock_preference( 'HoldsInNoissuesCharge',   1 );
    t::lib::Mocks::mock_preference( 'RentalsInNoissuesCharge', 1 );
    t::lib::Mocks::mock_preference( 'ManInvInNoissuesCharge',  1 );
    ( $total, $non_issues_charges ) = ( $account->balance, $account->non_issues_charges );
    $other_charges = $total - $non_issues_charges;
    is(
        $total,
        $res + $rent + $manual,
        'Total charges should be Res + Rent + Manual'
    );
    is(
        $non_issues_charges,
        $res + $rent + $manual,
        'If 1|1|1 Res + Rent + Manual should be non issues charges'
    );
    is( $other_charges, 0, 'If 1|1|1 there should not have any other charges' );
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

    my $debit = Koha::Account::Line->new({ borrowernumber => $patron->id, date => '1900-01-01', amountoutstanding => 0 })->store();
    my $credit = Koha::Account::Line->new({ borrowernumber => $patron->id, date => '1900-01-01', amountoutstanding => -5 })->store();
    my $offset = Koha::Account::Offset->new({ credit_id => $credit->id, debit_id => $debit->id, type => 'Payment' })->store();
    purge_zero_balance_fees( 1 );
    my $debit_2 = Koha::Account::Lines->find( $debit->id );
    my $credit_2 = Koha::Account::Lines->find( $credit->id );
    ok( $debit_2, 'Debit was correctly not deleted when credit has balance' );
    ok( $credit_2, 'Credit was correctly not deleted when credit has balance' );
    is( Koha::Account::Lines->count({ borrowernumber => $patron->id }), 2, "The 2 account lines still exists" );

    $debit = Koha::Account::Line->new({ borrowernumber => $patron->id, date => '1900-01-01', amountoutstanding => 5 })->store();
    $credit = Koha::Account::Line->new({ borrowernumber => $patron->id, date => '1900-01-01', amountoutstanding => 0 })->store();
    $offset = Koha::Account::Offset->new({ credit_id => $credit->id, debit_id => $debit->id, type => 'Payment' })->store();
    purge_zero_balance_fees( 1 );
    $debit_2 = $credit_2 = undef;
    $debit_2 = Koha::Account::Lines->find( $debit->id );
    $credit_2 = Koha::Account::Lines->find( $credit->id );
    ok( $debit_2, 'Debit was correctly not deleted when debit has balance' );
    ok( $credit_2, 'Credit was correctly not deleted when debit has balance' );
    is( Koha::Account::Lines->count({ borrowernumber => $patron->id }), 2 + 2, "The 2 + 2 account lines still exists" );

    $debit = Koha::Account::Line->new({ borrowernumber => $patron->id, date => '1900-01-01', amountoutstanding => 0 })->store();
    $credit = Koha::Account::Line->new({ borrowernumber => $patron->id, date => '1900-01-01', amountoutstanding => 0 })->store();
    $offset = Koha::Account::Offset->new({ credit_id => $credit->id, debit_id => $debit->id, type => 'Payment' })->store();
    purge_zero_balance_fees( 1 );
    $debit_2 = Koha::Account::Lines->find( $debit->id );
    $credit_2 = Koha::Account::Lines->find( $credit->id );
    ok( !$debit_2, 'Debit was correctly deleted' );
    ok( !$credit_2, 'Credit was correctly deleted' );
    is( Koha::Account::Lines->count({ borrowernumber => $patron->id }), 2 + 2, "The 2 + 2 account lines still exists, the last 2 have been deleted ok" );
};

1;
