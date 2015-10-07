#!/usr/bin/perl
#
# Copyright 2011 MJ Ray and software.coop
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;
use Test::More tests => 7;

use C4::Context;
use Koha::DateUtils;

use t::lib::Mocks qw/mock_preference/; # to mock CronjobLog
use Data::Dumper;

$| = 1;

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
    my $date = output_pref( { dt => dt_from_string, datenonly => 1, dateformat => 'iso' } );
    $success = scalar(@{GetLogs( $date, $date, "", undef, undef, "", "") } );
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

# Make sure we can rollback.
my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

# We want numbers to be the same between runs.
$dbh->do("DELETE FROM action_logs;");

t::lib::Mocks::mock_preference('CronjobLog',0);
cronlogaction();
my $cronJobCount = $dbh->selectrow_array("SELECT COUNT(*) FROM action_logs WHERE module='CRONJOBS';",{});
is($cronJobCount,0,"Cronjob not logged as expected.");

t::lib::Mocks::mock_preference('CronjobLog',1);
cronlogaction();
$cronJobCount = $dbh->selectrow_array("SELECT COUNT(*) FROM action_logs WHERE module='CRONJOBS';",{});
is($cronJobCount,1,"Cronjob logged as expected.");

$dbh->rollback();
