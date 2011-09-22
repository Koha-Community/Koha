#!/usr/bin/perl
#
# Copyright 2011 MJ Ray and software.coop
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;
use Test::More tests => 5;
use C4::Log;

BEGIN {
	use_ok('C4::Log');
}
my $success;

eval {
    # FIXME: are we sure there is an member number 1?
    # FIXME: can we remove this log entry somehow?
    logaction("MEMBERS","MODIFY",1,"test operation");
    $success = 1;
} or do {
    diag($@);
    $success = 0;
};
ok($success, "logaction seemed to work");

eval {
    # FIXME: US formatted date hardcoded into test for now
    $success = scalar(@{GetLogs("","","",undef,undef,"","")});
} or do {
    diag($@);
    $success = 0;
};
ok($success, "GetLogs returns results for an open search");

eval {
    # FIXME: US formatted date hardcoded into test for now
    $success = scalar(@{GetLogs("09/01/2011","10/01/2011","",undef,undef,"","")});
} or do {
    diag($@);
    $success = 0;
};
ok($success, "GetLogs accepts dates in an All-matching search");

eval {
    $success = scalar(@{GetLogs("","","",["MEMBERS"],["MODIFY"],1,"")});
} or do {
    diag($@);
    $success = 0;
};
ok($success, "GetLogs seemed to find ".$success." like our test record in a tighter search");
