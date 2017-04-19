#!/usr/bin/perl

# Copyright Koha-Suomi Oy 2017
#
# This file is part of Koha.
#

use C4::Context;

my $dbh = C4::Context->dbh();

$dbh->do("UPDATE borrowers SET othernames = NULL WHERE othernames = '';");
$dbh->do("ALTER TABLE borrowers MODIFY COLUMN othernames VARCHAR(50);");
$dbh->do("ALTER TABLE borrowers ADD UNIQUE (`othernames`);");
print "Upgrade done (KD-205-SelfServiceHoldsPickup)\n";
