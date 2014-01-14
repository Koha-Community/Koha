#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 3;
use t::lib::Mocks;

BEGIN {
        use_ok('C4::Log');
}

t::lib::Mocks::mock_preference('BorrowersLog', 1);
t::lib::Mocks::mock_preference('CataloguingLog', 1);
t::lib::Mocks::mock_preference('IssueLog', 1);
t::lib::Mocks::mock_preference('ReturnLog', 1);
t::lib::Mocks::mock_preference('SubscriptionLog', 1);
t::lib::Mocks::mock_preference('LetterLog', 1);
t::lib::Mocks::mock_preference('FinesLog', 1);

ok( my $hash=GetLogStatus(),"Testing GetLogStatus");

ok( $hash->{BorrowersLog}, 'Testing hash is non empty');
