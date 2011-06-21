#!/usr/bin/perl

use strict;
use warnings;
use C4::Context;

my $dbh = C4::Context->dbh;

$dbh->do("ALTER TABLE issues CHANGE date_due date_due datetime");
$dbh->do("ALTER TABLE issues CHANGE returndate returndate datetime");
$dbh->do("ALTER TABLE issues CHANGE lastreneweddate lastreneweddate datetime");
$dbh->do("ALTER TABLE issues CHANGE issuedate issuedate datetime");
$dbh->do("ALTER TABLE old_issues CHANGE date_due date_due datetime");
$dbh->do("ALTER TABLE old_issues CHANGE returndate returndate datetime");
$dbh->do("ALTER TABLE old_issues CHANGE lastreneweddate lastreneweddate datetime");
$dbh->do("ALTER TABLE old_issues CHANGE issuedate issuedate datetime");
$dbh->do(q{update issues set date_due = addtime(date_due, '0 23:0:0') where hour(date_due) = 0});
