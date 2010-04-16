#!/usr/bin/perl
#use strict;
#use warnings; FIXME - Bug 2505
use C4::Context;
my $dbh=C4::Context->dbh;
$dbh->do("ALTER TABLE `subscription` ADD `enddate` date default NULL");
$dbh->do("ALTER TABLE subscriptionhistory CHANGE enddate histenddate DATE default NULL");
print "Upgrade to $DBversion done ( Adding enddate to subscription)\n";

