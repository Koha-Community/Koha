#!/usr/bin/perl

# Copyright Koha-Suomi Oy 2017
#
# This file is part of Koha.
#

use C4::Context;

my $dbh = C4::Context->dbh();

$dbh->do("UPDATE deletedborrowers SET othernames = NULL WHERE othernames = '';");
$dbh->do("ALTER TABLE deletedborrowers MODIFY COLUMN othernames VARCHAR(50);");
$dbh->do("ALTER TABLE deletedborrowers ADD UNIQUE (`othernames`);");
print "Upgrade done (KD-205-2-SelfServiceHoldsPickup)\n";
