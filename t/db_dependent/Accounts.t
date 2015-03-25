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

use strict;
use warnings;

use Test::More tests => 15;
use Test::Warn;

BEGIN {
    use_ok('C4::Accounts');
    use_ok('Koha::Object');
    use_ok('Koha::Borrower');
    use_ok('Data::Dumper');
}

can_ok(	'C4::Accounts',
	qw(	recordpayment
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
		WriteOffFee	)
);

my $dbh = C4::Context->dbh;
$dbh->{RaiseError}=1;
$dbh->{AutoCommit}=0;
$dbh->do(q|DELETE FROM accountlines|);
$dbh->do(q|DELETE FROM borrowers|);
$dbh->do(q|DELETE FROM issues|);

# Mock userenv
local $SIG{__WARN__} = sub { warn $_[0] unless $_[0] =~ /redefined/ };
my $userenv;
*C4::Context::userenv = \&Mock_userenv;
$userenv = { flags => 1, id => 'my_userid', branch => 'CPL' };

# A Borrower for the tests ----------------------
my $categorycode = Koha::Database->new()->schema()->resultset('Category')->first()->categorycode();
my $branchcode = Koha::Database->new()->schema()->resultset('Branch')->first()->branchcode();

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



$dbh->rollback;


# Sub -------------------------------------------

# C4::Context->userenv
sub Mock_userenv {
    return $userenv;
}