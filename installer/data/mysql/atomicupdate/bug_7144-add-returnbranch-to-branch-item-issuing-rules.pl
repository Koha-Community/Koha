#! /usr/bin/perl
use strict;
use warnings;
use C4::Context;
my $dbh=C4::Context->dbh;

$dbh->do("ALTER TABLE default_circ_rules ADD
		COLUMN `returnbranch` varchar(15) default NULL AFTER `holdallowed`");
$dbh->do("ALTER TABLE branch_item_rules ADD
		COLUMN `returnbranch` varchar(15) default NULL AFTER `holdallowed`");
$dbh->do("ALTER TABLE default_branch_circ_rules ADD
		COLUMN `returnbranch` varchar(15) default NULL AFTER `holdallowed`");
$dbh->do("ALTER TABLE default_branch_item_rules ADD
		COLUMN `returnbranch` varchar(15) default NULL AFTER `holdallowed`");

# set the default rule to the current value of HomeOrHoldingBranchReturn (default to 'homebranch' if need be)
my $homeorholdingbranchreturn = C4::Context->prefernce('HomeOrHoldingBranchReturn') || 'homebranch';
$dbh->do("UPDATE default_circ_rules SET returnbranch = '$homeorholdingbranchreturn'");

print "Upgrade done (Adding 'returnbranch' to branch/item issuing rules tables)\n";
