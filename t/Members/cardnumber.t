#!/usr/bin/env perl

use Modern::Perl;
use Test::More tests => 23;

use t::lib::Mocks;

use_ok('C4::Members');

BEGIN {
    t::lib::Mocks::mock_dbh;
}

my $dbh = C4::Context->dbh;
my $rs = [];

t::lib::Mocks::mock_preference('BorrowerMandatoryField', '');
my $pref = "10";
t::lib::Mocks::mock_preference('CardnumberLength', $pref);
is_deeply( [ C4::Members::get_cardnumber_length() ], [ 10, 10 ], '10 => min=10 and max=10');
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{123456789} ), 2, "123456789 is shorter than $pref");
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{1234567890123456} ), 2, "1234567890123456 is longer than $pref");
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{1234567890} ), 0, "1234567890 is equal to $pref");

$pref = q|10,10|; # Same as before !
t::lib::Mocks::mock_preference('CardnumberLength', $pref);
is_deeply( [ C4::Members::get_cardnumber_length() ], [ 10, 10 ], '10,10 => min=10 and max=10');
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{123456789} ), 2, "123456789 is shorter than $pref");
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{1234567890123456} ), 2, "1234567890123456 is longer than $pref");
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{1234567890} ), 0, "1234567890 is equal to $pref");

$pref = q|8,10|; # between 8 and 10 chars
t::lib::Mocks::mock_preference('CardnumberLength', $pref);
is_deeply( [ C4::Members::get_cardnumber_length() ], [ 8, 10 ], '8,10 => min=8 and max=10');
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{12345678} ), 0, "12345678 matches $pref");
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{1234567890123456} ), 2, "1234567890123456 is longer than $pref");
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{1234567} ), 2, "1234567 is shorter than $pref");
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{1234567890} ), 0, "1234567890 matches $pref");

$pref = q|8,|; # At least 8 chars
t::lib::Mocks::mock_preference('CardnumberLength', $pref);
is_deeply( [ C4::Members::get_cardnumber_length() ], [ 8, 16 ], '8, => min=8 and max=16');
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{1234567} ), 2, "1234567 is shorter than $pref");
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{1234567890123456} ), 0, "1234567890123456 matches $pref");
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{1234567890} ), 0, "1234567890 matches $pref");

$pref = q|,8|; # max 8 chars
t::lib::Mocks::mock_preference('CardnumberLength', $pref);
is_deeply( [ C4::Members::get_cardnumber_length() ], [ 0, 8 ], ',8 => min=0 and max=8');
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{1234567} ), 0, "1234567 matches $pref");
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{1234567890123456} ), 2, "1234567890123456 is longer than $pref");
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{1234567890} ), 2, "1234567890 is longer than $pref");

t::lib::Mocks::mock_preference('BorrowerMandatoryField', 'cardnumber');
is_deeply( [ C4::Members::get_cardnumber_length() ], [ 1, 8 ], ',8 => min=1 and max=8 if cardnumber is mandatory');
