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

use Test::More tests => 8;
use Test::MockModule;
use Test::Warn;

use t::lib::TestBuilder;

BEGIN {
    use_ok('C4::Accounts');
    use_ok('Koha::Object');
    use_ok('Koha::Borrower');
    use_ok('Data::Dumper');
}

can_ok( 'C4::Accounts',
    qw( recordpayment
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
        WriteOffFee )
);

my $builder = t::lib::TestBuilder->new();
my $schema  = Koha::Database->new()->schema();

my $dbh = C4::Context->dbh;
$dbh->{RaiseError}=1;
$dbh->{AutoCommit}=0;
$dbh->do(q|DELETE FROM accountlines|);
$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM borrowers|);

my $branchcode = 'CPL';
my $borrower_number;

my $context = new Test::MockModule('C4::Context');
$context->mock( 'userenv', sub {
    return {
        flags  => 1,
        id     => 'my_userid',
        branch => $branchcode,
    };
});


subtest "recordpayment() tests" => sub {

    plan tests => 10;

    # Create a borrower
    my $categorycode = $builder->build({ source => 'Category' })->{ categorycode };
    my $branchcode   = $builder->build({ source => 'Branch' })->{ branchcode };

    my $borrower = Koha::Borrower->new( {
        cardnumber => '1234567890',
        surname => 'McFly',
        firstname => 'Marty',
    } );
    $borrower->categorycode( $categorycode );
    $borrower->branchcode( $branchcode );
    $borrower->store;

    my $sth = $dbh->prepare(
        "INSERT INTO accountlines (
            borrowernumber,
            amountoutstanding )
        VALUES ( ?, ? )"
    );
    $sth->execute($borrower->borrowernumber, '100');
    $sth->execute($borrower->borrowernumber, '200');

    $sth = $dbh->prepare("SELECT count(*) FROM accountlines");
    $sth->execute;
    my $count = $sth->fetchrow_array;
    is ($count, 2, 'There is 2 lines as expected');

    # Testing recordpayment -------------------------
    # There is $100 in the account
    $sth = $dbh->prepare("SELECT amountoutstanding FROM accountlines WHERE borrowernumber=?");
    my $amountoutstanding = $dbh->selectcol_arrayref($sth, {}, $borrower->borrowernumber);
    my $amountleft = 0;
    for my $line ( @$amountoutstanding ) {
        $amountleft += $line;
    }
    ok($amountleft == 300, 'The account has 300$ as expected' );

    # We make a $20 payment
    my $borrowernumber = $borrower->borrowernumber;
    my $data = '20.00';
    my $sys_paytype;
    my $payment_note = '$20.00 payment note';
    recordpayment($borrowernumber, $data, $sys_paytype, $payment_note);
    # There is now $280 in the account
    $sth = $dbh->prepare("SELECT amountoutstanding FROM accountlines WHERE borrowernumber=?");
    $amountoutstanding = $dbh->selectcol_arrayref($sth, {}, $borrower->borrowernumber);
    $amountleft = 0;
    for my $line ( @$amountoutstanding ) {
        $amountleft += $line;
    }
    ok($amountleft == 280, 'The account has $280 as expected' );
    # Is the payment note well registered
    $sth = $dbh->prepare("SELECT note FROM accountlines WHERE borrowernumber=? ORDER BY accountlines_id DESC LIMIT 1");
    $sth->execute($borrower->borrowernumber);
    my $note = $sth->fetchrow_array;
    is($note,'$20.00 payment note', '$20.00 payment note is registered');

    # We make a -$30 payment (a NEGATIVE payment)
    $data = '-30.00';
    $payment_note = '-$30.00 payment note';
    recordpayment($borrowernumber, $data, $sys_paytype, $payment_note);
    # There is now $310 in the account
    $sth = $dbh->prepare("SELECT amountoutstanding FROM accountlines WHERE borrowernumber=?");
    $amountoutstanding = $dbh->selectcol_arrayref($sth, {}, $borrower->borrowernumber);
    $amountleft = 0;
    for my $line ( @$amountoutstanding ) {
        $amountleft += $line;
    }
    ok($amountleft == 310, 'The account has $310 as expected' );
    # Is the payment note well registered
    $sth = $dbh->prepare("SELECT note FROM accountlines WHERE borrowernumber=? ORDER BY accountlines_id DESC LIMIT 1");
    $sth->execute($borrower->borrowernumber);
    $note = $sth->fetchrow_array;
    is($note,'-$30.00 payment note', '-$30.00 payment note is registered');

    #We make a $150 payment ( > 1stLine )
    $data = '150.00';
    $payment_note = '$150.00 payment note';
    recordpayment($borrowernumber, $data, $sys_paytype, $payment_note);
    # There is now $160 in the account
    $sth = $dbh->prepare("SELECT amountoutstanding FROM accountlines WHERE borrowernumber=?");
    $amountoutstanding = $dbh->selectcol_arrayref($sth, {}, $borrower->borrowernumber);
    $amountleft = 0;
    for my $line ( @$amountoutstanding ) {
        $amountleft += $line;
    }
    ok($amountleft == 160, 'The account has $160 as expected' );
    # Is the payment note well registered
    $sth = $dbh->prepare("SELECT note FROM accountlines WHERE borrowernumber=? ORDER BY accountlines_id DESC LIMIT 1");
    $sth->execute($borrower->borrowernumber);
    $note = $sth->fetchrow_array;
    is($note,'$150.00 payment note', '$150.00 payment note is registered');

    #We make a $200 payment ( > amountleft )
    $data = '200.00';
    $payment_note = '$200.00 payment note';
    recordpayment($borrowernumber, $data, $sys_paytype, $payment_note);
    # There is now -$40 in the account
    $sth = $dbh->prepare("SELECT amountoutstanding FROM accountlines WHERE borrowernumber=?");
    $amountoutstanding = $dbh->selectcol_arrayref($sth, {}, $borrower->borrowernumber);
    $amountleft = 0;
    for my $line ( @$amountoutstanding ) {
        $amountleft += $line;
    }
    ok($amountleft == -40, 'The account has -$40 as expected, (credit situation)' );
    # Is the payment note well registered
    $sth = $dbh->prepare("SELECT note FROM accountlines WHERE borrowernumber=? ORDER BY accountlines_id DESC LIMIT 1");
    $sth->execute($borrower->borrowernumber);
    $note = $sth->fetchrow_array;
    is($note,'$200.00 payment note', '$200.00 payment note is registered');
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

$dbh->rollback;

1;
