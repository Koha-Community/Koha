#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 4;

BEGIN {
        use_ok('C4::SIP::ILS');
};

my $transaction = C4::SIP::ILS::Transaction::RenewAll->new();

$transaction->patron(my $patron = C4::SIP::ILS::Patron->new(23529000120056));

ok(defined $patron, "patron code: 23529000120056 is valid");

my $transaction2 = C4::SIP::ILS::Transaction::RenewAll->new();
$transaction2->patron(my $patron2 = C4::SIP::ILS::Patron->new("ABCDE12345"));

#This test assumes that the patron code ABCDE12345 is invalid
ok(!defined $patron2, "patron code: ABCDE12345 is invalid");

ok($transaction->do_renew_all(), "items renewed correctly");
